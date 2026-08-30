#!/usr/bin/env python3
"""Synchronize and verify Tática Manager release metadata.

Canonical visible release is stored in al-sistemas.json as A.B.C.D.
Dart/Flutter pubspec must remain valid SemVer (A.B.C+build), so the manifest
also stores the mapped pubspecVersion. Android receives the exact visible
A.B.C.D as versionName and a monotonic integer as versionCode.
"""
from __future__ import annotations

import json
import plistlib
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / 'al-sistemas.json'


def load_manifest() -> dict:
    data = json.loads(MANIFEST.read_text(encoding='utf-8'))
    required = ['product', 'version', 'projectType', 'android', 'flutter']
    missing = [key for key in required if key not in data]
    if missing:
        raise RuntimeError(f'al-sistemas.json incompleto: {", ".join(missing)}')
    if data['projectType'] != 'flutter':
        raise RuntimeError('projectType deve ser flutter')
    if not re.fullmatch(r'\d+\.\d+\.\d+\.\d+', data['version']):
        raise RuntimeError('version deve seguir A.B.C.D, exemplo 0.1.1.3')
    if not isinstance(data['android'].get('versionCode'), int) or data['android']['versionCode'] <= 0:
        raise RuntimeError('android.versionCode deve ser inteiro positivo')
    if data['android'].get('versionName') != data['version']:
        raise RuntimeError('android.versionName deve ser igual à versão visível')
    return data


def replace_pubspec_version(expected: str) -> None:
    path = ROOT / 'pubspec.yaml'
    text = path.read_text(encoding='utf-8')
    if not re.search(r'^version:\s*.+$', text, flags=re.MULTILINE):
        raise RuntimeError('Campo version não encontrado no pubspec.yaml')
    text = re.sub(r'^version:\s*.+$', f'version: {expected}', text, count=1, flags=re.MULTILINE)
    path.write_text(text, encoding='utf-8')


def sync_simple_files(data: dict) -> None:
    version = data['version']
    (ROOT / 'VERSION').write_text(version + '\n', encoding='utf-8')
    app_path = ROOT / 'app.json'
    app = json.loads(app_path.read_text(encoding='utf-8')) if app_path.exists() else {}
    app.update({
        'name': data.get('name', 'tatica_manager'),
        'displayName': data.get('displayName', data['product']),
        'version': version,
        'type': 'flutter',
        'repository': data.get('repository'),
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
    candidates = [
        ROOT / 'android/app/build.gradle.kts',
        ROOT / 'android/app/build.gradle',
    ]
    path = next((p for p in candidates if p.exists()), None)
    if path is None:
        return
    text = path.read_text(encoding='utf-8')
    if path.suffix == '.kts':
        text, n_code = re.subn(r'^\s*versionCode\s*=.*$', f'        versionCode = {version_code}', text, count=1, flags=re.MULTILINE)
        text, n_name = re.subn(r'^\s*versionName\s*=.*$', f'        versionName = "{version_name}"', text, count=1, flags=re.MULTILINE)
    else:
        text, n_code = re.subn(r'^\s*versionCode\s+.*$', f'        versionCode {version_code}', text, count=1, flags=re.MULTILINE)
        text, n_name = re.subn(r'^\s*versionName\s+.*$', f'        versionName "{version_name}"', text, count=1, flags=re.MULTILINE)
    if n_code != 1 or n_name != 1:
        raise RuntimeError(f'Não foi possível sincronizar versionCode/versionName em {path}')
    path.write_text(text, encoding='utf-8')


def patch_ios(data: dict) -> None:
    path = ROOT / 'ios/Runner/Info.plist'
    if not path.exists():
        return
    with path.open('rb') as handle:
        plist = plistlib.load(handle)
    # Apple marketing version accepts up to three numeric components. Keep the
    # exact four-part Tática release in its own deterministic metadata key.
    visible = data['version']
    ios_marketing = '.'.join(visible.split('.')[:3])
    plist['CFBundleShortVersionString'] = ios_marketing
    plist['CFBundleVersion'] = str(data['android']['versionCode'])
    plist['TaticaReleaseVersion'] = visible
    with path.open('wb') as handle:
        plistlib.dump(plist, handle, sort_keys=False)


def verify(data: dict) -> None:
    errors: list[str] = []
    version = data['version']
    version_file = (ROOT / 'VERSION').read_text(encoding='utf-8').strip() if (ROOT / 'VERSION').exists() else None
    if version_file != version:
        errors.append(f'VERSION={version_file!r}; esperado {version!r}')

    app_path = ROOT / 'app.json'
    if not app_path.exists():
        errors.append('app.json ausente')
    else:
        app = json.loads(app_path.read_text(encoding='utf-8'))
        if app.get('version') != version:
            errors.append(f'app.json version={app.get("version")!r}; esperado {version!r}')
        if app.get('type') != 'flutter':
            errors.append('app.json type deve ser flutter')

    pubspec = (ROOT / 'pubspec.yaml').read_text(encoding='utf-8')
    m = re.search(r'^version:\s*(\S+)\s*$', pubspec, flags=re.MULTILINE)
    expected_pub = data['flutter']['pubspecVersion']
    if not m or m.group(1) != expected_pub:
        errors.append(f'pubspec version={m.group(1) if m else None!r}; esperado {expected_pub!r}')

    app_info_path = ROOT / 'lib/core/config/app_info.dart'
    if app_info_path.exists():
        app_info = app_info_path.read_text(encoding='utf-8')
        if f"static const String version = '{version}';" not in app_info:
            errors.append(f'AppInfo.version não está sincronizado em {app_info_path}')
        release_match = re.search(
            r"recentReleases\s*=\s*\[\s*ReleaseNote\(\s*version:\s*'([^']+)'",
            app_info,
            flags=re.DOTALL,
        )
        if not release_match or release_match.group(1) != version:
            errors.append(
                f'AppInfo.recentReleases inicia em '
                f'{release_match.group(1) if release_match else None!r}; esperado {version!r}'
            )

    version_parts = [int(part) for part in version.split('.')]
    next_version = '.'.join(str(part) for part in [*version_parts[:-1], version_parts[-1] + 1])
    next_code = data['android']['versionCode']

    documentation_checks = [
        (
            ROOT / 'README.md',
            [
                f'**Release atual:** `{version}`',
                f'**Android versionCode:** `{data["android"]["versionCode"]}`',
                f'`VERSION` — versão visível simples (`{version}`)',
                f'`pubspec.yaml` — manifesto Flutter, com versão SemVer compatível (`{data["flutter"]["pubspecVersion"]}`)',
                f'Android — plataforma versionada no repositório, com `versionName {version}` e `versionCode {data["android"]["versionCode"]}`',
                (
                    f'release de quatro partes `{version}` é representada internamente como '
                    f'`{data["flutter"]["pubspecVersion"]}`. A versão visível do aplicativo/Android '
                    f'continua sendo `{version}`'
                ),
                f'a próxima entrega normalmente será `{next_version}`',
            ],
        ),
        (
            ROOT / 'AI_HANDOFF.md',
            [
                f'**Release deste handoff:** `{version}`',
                f'**Android versionCode:** `{data["android"]["versionCode"]}`',
                f'pubspec:             {data["flutter"]["pubspecVersion"]}',
                f'versionCode:         {data["android"]["versionCode"]}',
                f'A próxima alteração/entrega normalmente deve virar `{next_version}` e usar um `versionCode` maior que {next_code}.',
            ],
        ),
        (
            ROOT / 'docs/PROMPT_CONTINUACAO_IA.md',
            [
                f'Release visível: {version}',
                f'Android versionCode: {data["android"]["versionCode"]}',
                f'pubspec: {data["flutter"]["pubspecVersion"]}',
                f'Antes de qualquer nova entrega, incremente a versão. Partindo deste handoff, a próxima normalmente será {next_version} com versionCode > {next_code}.',
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

    release_meta = data.get('release', {})
    if release_meta.get('version') != version:
        errors.append(f'al-sistemas release.version={release_meta.get("version")!r}; esperado {version!r}')
    if release_meta.get('androidVersionCode') != data['android']['versionCode']:
        errors.append(
            'al-sistemas release.androidVersionCode='
            f'{release_meta.get("androidVersionCode")!r}; esperado {data["android"]["versionCode"]!r}'
        )

    android_kts = ROOT / 'android/app/build.gradle.kts'
    android_groovy = ROOT / 'android/app/build.gradle'
    android = android_kts if android_kts.exists() else android_groovy if android_groovy.exists() else None
    if android is not None:
        text = android.read_text(encoding='utf-8')
        code = str(data['android']['versionCode'])
        if not re.search(rf'versionCode\s*(?:=\s*|\s+){re.escape(code)}\b', text):
            errors.append(f'Android versionCode não está sincronizado em {android}')
        if data['android']['versionName'] not in text:
            errors.append(f'Android versionName não está sincronizado em {android}')

    if errors:
        raise RuntimeError('Versionamento inconsistente:\n- ' + '\n- '.join(errors))


def main() -> int:
    data = load_manifest()
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
