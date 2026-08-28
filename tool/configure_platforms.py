#!/usr/bin/env python3
"""Apply and verify Tática Manager platform settings.

This script is intentionally idempotent. It configures:
- portrait-only orientation on Android/iOS;
- application display name;
- transparent Android system bars for Flutter edge-to-edge mode.
"""
from __future__ import annotations

from pathlib import Path
import plistlib
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
ANDROID_NS = 'http://schemas.android.com/apk/res/android'


def configure_android_manifest() -> None:
    path = ROOT / 'android/app/src/main/AndroidManifest.xml'
    if not path.exists():
        raise FileNotFoundError(f'AndroidManifest.xml não encontrado: {path}')

    text = path.read_text(encoding='utf-8')
    text = re.sub(
        r'android:label="[^"]*"',
        'android:label="Tática Manager"',
        text,
        count=1,
    )

    # Add screenOrientation only to MainActivity, preserving Flutter's template.
    activity_match = re.search(
        r'(<activity\b[^>]*android:name="\.MainActivity"[^>]*)(>)',
        text,
        flags=re.DOTALL,
    )
    if not activity_match:
        raise RuntimeError('MainActivity não encontrada no AndroidManifest.xml')

    activity_tag = activity_match.group(1)
    if 'android:screenOrientation=' not in activity_tag:
        activity_tag += '\n            android:screenOrientation="portrait"'
    text = text[: activity_match.start(1)] + activity_tag + text[activity_match.end(1) :]
    path.write_text(text, encoding='utf-8')


def configure_android_styles() -> None:
    candidates = [
        ROOT / 'android/app/src/main/res/values/styles.xml',
        ROOT / 'android/app/src/main/res/values-night/styles.xml',
    ]
    desired_items = [
        ('android:statusBarColor', '@android:color/transparent'),
        ('android:navigationBarColor', '@android:color/transparent'),
        ('android:windowLightStatusBar', 'false'),
        ('android:windowLightNavigationBar', 'false'),
        ('android:windowLayoutInDisplayCutoutMode', 'shortEdges'),
        ('android:windowFullscreen', 'true'),
        ('android:windowActionModeOverlay', 'true'),
        ('android:enforceNavigationBarContrast', 'false'),
        ('android:enforceStatusBarContrast', 'false'),
    ]

    for path in candidates:
        if not path.exists():
            continue
        text = path.read_text(encoding='utf-8')
        normal_match = re.search(
            r'(<style\s+name="NormalTheme"[^>]*>)(.*?)(</style>)',
            text,
            flags=re.DOTALL,
        )
        if not normal_match:
            continue
        body = normal_match.group(2)
        for name, value in desired_items:
            pattern = rf'<item\s+name="{re.escape(name)}">.*?</item>'
            replacement = f'<item name="{name}">{value}</item>'
            if re.search(pattern, body, flags=re.DOTALL):
                body = re.sub(pattern, replacement, body, flags=re.DOTALL)
            else:
                body += f'\n        {replacement}'
        replacement = normal_match.group(1) + body + normal_match.group(3)
        text = text[: normal_match.start()] + replacement + text[normal_match.end() :]
        path.write_text(text, encoding='utf-8')


def configure_ios_plist() -> None:
    path = ROOT / 'ios/Runner/Info.plist'
    if not path.exists():
        return

    with path.open('rb') as handle:
        data = plistlib.load(handle)

    data['CFBundleDisplayName'] = 'Tática Manager'
    data['UISupportedInterfaceOrientations'] = ['UIInterfaceOrientationPortrait']
    data['UISupportedInterfaceOrientations~ipad'] = ['UIInterfaceOrientationPortrait']
    data['UIStatusBarHidden'] = True
    data['UIViewControllerBasedStatusBarAppearance'] = False

    with path.open('wb') as handle:
        plistlib.dump(data, handle, sort_keys=False)


def main() -> int:
    configure_android_manifest()
    configure_android_styles()
    configure_ios_plist()
    subprocess.run([sys.executable, str(ROOT / 'tool/versioning.py'), 'sync'], check=True)
    print('Plataformas presentes configuradas: portrait + fullscreen + versão + nome do app.')
    return 0


if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f'ERRO: {exc}', file=sys.stderr)
        raise
