#!/usr/bin/env python3
"""Synchronize and verify Tática Manager release metadata.

The canonical visible release is stored in VERSION as A.B.C.D.
Flutter keeps a SemVer-compatible A.B.C+build entry in pubspec.yaml; its build
number is also the Android versionCode. Android receives the exact visible
A.B.C.D as versionName.
"""
from __future__ import annotations

import json
import plistlib
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
VERSION_FILE = ROOT / 'VERSION'
PUBSPEC_FILE = ROOT / 'pubspec.yaml'


def load_release() -> dict:
    if not VERSION_FILE.exists():
        raise RuntimeError('Arquivo VERSION ausente')
    version = VERSION_FILE.read_text(encoding='utf-8').strip()
    if not re.fullmatch(r'\d+\.\d+\.\d+\.\d+', version):
        raise RuntimeError('VERSION deve seguir A.B.C.D, exemplo 0.1.1.109')

    pubspec = PUBSPEC_FILE.read_text(encoding='utf-8')
    match = re.search(r'^version:\s*(\d+\.\d+\.\d+)\+(\d+)\s*$', pubspec, flags=re.MULTILINE)
    if not match:
        raise RuntimeError('pubspec.yaml deve usar version: A.B.C+build')
    expected_base = '.'.join(version.split('.')[:3])
    if match.group(1) != expected_base:
        raise RuntimeError(
            f'Base SemVer do pubspec ({match.group(1)}) diverge de VERSION ({expected_base})'
        )
    version_code = int(match.group(2))
    if version_code <= 0:
        raise RuntimeError('build number do pubspec deve ser inteiro positivo')

    app_path = ROOT / 'app.json'
    app = json.loads(app_path.read_text(encoding='utf-8')) if app_path.exists() else {}
    return {
        'version': version,
        'android': {'versionName': version, 'versionCode': version_code},
        'flutter': {'pubspecVersion': f'{expected_base}+{version_code}'},
        'name': app.get('name', 'tatica_manager'),
        'displayName': app.get('displayName', 'Tática Manager'),
        'repository': app.get('repository', 'https://github.com/adriedsonlemoz/Tatica-Manager'),
    }


def replace_pubspec_version(expected: str) -> None:
    text = PUBSPEC_FILE.read_text(encoding='utf-8')
    if not re.search(r'^version:\s*.+$', text, flags=re.MULTILINE):
        raise RuntimeError('Campo version não encontrado no pubspec.yaml')
    text = re.sub(r'^version:\s*.+$', f'version: {expected}', text, count=1, flags=re.MULTILINE)
    PUBSPEC_FILE.write_text(text, encoding='utf-8')


def sync_simple_files(data: dict) -> None:
    version = data['version']
    VERSION_FILE.write_text(version + '\n', encoding='utf-8')
    app_path = ROOT / 'app.json'
    app = json.loads(app_path.read_text(encoding='utf-8')) if app_path.exists() else {}
    app.update({
        'name': data['name'],
        'displayName': data['displayName'],
        'version': version,
        'type': 'flutter',
        'repository': data['repository'],
    })
    app_path.write_text(json.dumps(app, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')
    replace_pubspec_version(data['flutter']['pubspecVersion'])


def patch_app_info(data: dict) -> None:
    path = ROOT / 'lib/core/config/app_info.dart'
    if not path.exists():
        return
    text = path.read_text(encoding='utf-8')
    text, count = re.subn(
        r"static const String version = '[^']+';",
        f"static const String version = '{data['version']}';",
        text,
        count=1,
    )
    if count != 1:
        raise RuntimeError(f'Não foi possível sincronizar AppInfo.version em {path}')
    path.write_text(text, encoding='utf-8')


def patch_android(data: dict) -> None:
    version_name = data['android']['versionName']
    version_code = data['android']['versionCode']
    candidates = [ROOT / 'android/app/build.gradle.kts', ROOT / 'android/app/build.gradle']
    path = next((p for p in candidates if p.exists()), None)
    if path is None:
        return
    text = path.read_text(encoding='utf-8')
    if path.suffix == '.kts':
        text, n_code = re.subn(
            r'^\s*versionCode\s*=.*$', f'        versionCode = {version_code}', text,
            count=1, flags=re.MULTILINE,
        )
        text, n_name = re.subn(
            r'^\s*versionName\s*=.*$', f'        versionName = "{version_name}"', text,
            count=1, flags=re.MULTILINE,
        )
    else:
        text, n_code = re.subn(
            r'^\s*versionCode\s+.*$', f'        versionCode {version_code}', text,
            count=1, flags=re.MULTILINE,
        )
        text, n_name = re.subn(
            r'^\s*versionName\s+.*$', f'        versionName "{version_name}"', text,
            count=1, flags=re.MULTILINE,
        )
    if n_code != 1 or n_name != 1:
        raise RuntimeError(f'Não foi possível sincronizar versionCode/versionName em {path}')
    path.write_text(text, encoding='utf-8')


def patch_ios(data: dict) -> None:
    path = ROOT / 'ios/Runner/Info.plist'
    if not path.exists():
        return
    with path.open('rb') as handle:
        plist = plistlib.load(handle)
    visible = data['version']
    plist['CFBundleShortVersionString'] = '.'.join(visible.split('.')[:3])
    plist['CFBundleVersion'] = str(data['android']['versionCode'])
    plist['TaticaReleaseVersion'] = visible
    with path.open('wb') as handle:
        plistlib.dump(plist, handle, sort_keys=False)


def verify(data: dict) -> None:
    errors: list[str] = []
    version = data['version']
    version_code = data['android']['versionCode']
    pubspec_version = data['flutter']['pubspecVersion']

    if (ROOT / 'al-sistemas.json').exists():
        errors.append('al-sistemas.json não deve existir nesta base')

    app_path = ROOT / 'app.json'
    if not app_path.exists():
        errors.append('app.json ausente')
    else:
        app = json.loads(app_path.read_text(encoding='utf-8'))
        if app.get('version') != version:
            errors.append(f'app.json version={app.get("version")!r}; esperado {version!r}')
        if app.get('type') != 'flutter':
            errors.append('app.json type deve ser flutter')

    pubspec = PUBSPEC_FILE.read_text(encoding='utf-8')
    if f'version: {pubspec_version}' not in pubspec:
        errors.append(f'pubspec version deve ser {pubspec_version!r}')

    app_info_path = ROOT / 'lib/core/config/app_info.dart'
    if app_info_path.exists():
        app_info = app_info_path.read_text(encoding='utf-8')
        if f"static const String version = '{version}';" not in app_info:
            errors.append(f'AppInfo.version não está sincronizado em {app_info_path}')
        release_match = re.search(
            r"recentReleases\s*=\s*\[\s*ReleaseNote\(\s*version:\s*'([^']+)'",
            app_info, flags=re.DOTALL,
        )
        if not release_match or release_match.group(1) != version:
            errors.append(
                f'AppInfo.recentReleases inicia em '
                f'{release_match.group(1) if release_match else None!r}; esperado {version!r}'
            )

    parts = [int(part) for part in version.split('.')]
    next_version = '.'.join(str(part) for part in [*parts[:-1], parts[-1] + 1])
    documentation_checks = [
        (
            ROOT / 'README.md',
            [
                f'**Release atual:** `{version}`',
                f'**Android versionCode:** `{version_code}`',
                f'`VERSION` — fonte canônica da versão visível (`{version}`)',
                f'`pubspec.yaml` — manifesto Flutter, com versão SemVer compatível (`{pubspec_version}`)',
                f'Android — plataforma versionada no repositório, com `versionName {version}` e `versionCode {version_code}`',
                f'a próxima entrega normalmente será `{next_version}`',
            ],
        ),
        (
            ROOT / 'AI_HANDOFF.md',
            [
                f'**Release deste handoff:** `{version}`',
                f'**Android versionCode:** `{version_code}`',
                f'pubspec:             {pubspec_version}',
                f'versionCode:         {version_code}',
                f'A próxima alteração/entrega normalmente deve virar `{next_version}` e usar um `versionCode` maior que {version_code}.',
            ],
        ),
        (
            ROOT / 'docs/PROMPT_CONTINUACAO_IA.md',
            [
                f'Release visível: {version}',
                f'Android versionCode: {version_code}',
                f'pubspec: {pubspec_version}',
                f'Antes de qualquer nova entrega, incremente a versão. Partindo deste handoff, a próxima normalmente será {next_version} com versionCode > {version_code}.',
            ],
        ),
    ]
    for doc_path, expected_fragments in documentation_checks:
        if not doc_path.exists():
            errors.append(f'Documentação obrigatória ausente: {doc_path}')
            continue
        doc_text = doc_path.read_text(encoding='utf-8')
        for fragment in expected_fragments:
            if fragment not in doc_text:
                errors.append(f'Documentação fora de sincronia em {doc_path}: ausente {fragment!r}')

    release_doc = ROOT / 'docs' / f'RELEASE_{version}.md'
    if not release_doc.exists():
        errors.append(f'Documentação da release ausente: {release_doc}')

    android_kts = ROOT / 'android/app/build.gradle.kts'
    android_groovy = ROOT / 'android/app/build.gradle'
    android = android_kts if android_kts.exists() else android_groovy if android_groovy.exists() else None
    if android is not None:
        text = android.read_text(encoding='utf-8')
        if not re.search(rf'versionCode\s*(?:=\s*|\s+){version_code}\b', text):
            errors.append(f'Android versionCode não está sincronizado em {android}')
        if data['android']['versionName'] not in text:
            errors.append(f'Android versionName não está sincronizado em {android}')

    if errors:
        raise RuntimeError('Versionamento inconsistente:\n- ' + '\n- '.join(errors))


def main() -> int:
    data = load_release()
    mode = sys.argv[1] if len(sys.argv) > 1 else 'verify'
    if mode == 'sync':
        sync_simple_files(data)
        patch_app_info(data)
        patch_android(data)
        patch_ios(data)
        verify(data)
        print(f'Versão sincronizada: {data["version"]} (Android code {data["android"]["versionCode"]})')
        return 0
    if mode == 'verify':
        verify(data)
        print(f'Versão validada: {data["version"]} (pubspec {data["flutter"]["pubspecVersion"]})')
        return 0
    raise SystemExit('Uso: tool/versioning.py [sync|verify]')


if __name__ == '__main__':
    raise SystemExit(main())
