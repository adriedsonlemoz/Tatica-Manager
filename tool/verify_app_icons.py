#!/usr/bin/env python3
"""Verify the launcher/app icon resources committed to Tática Manager.

Uses only the Python standard library so it can run in GitHub Actions before
Flutter dependency resolution.
"""
from __future__ import annotations

import hashlib
import json
import struct
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def png_info(path: Path) -> tuple[int, int, int]:
    data = path.read_bytes()
    if data[:8] != b'\x89PNG\r\n\x1a\n' or data[12:16] != b'IHDR':
        raise RuntimeError(f'PNG inválido: {path}')
    width, height, _bit_depth, color_type = struct.unpack('>IIBB', data[16:26])
    return width, height, color_type


def require_png(path: Path, size: int, *, alpha: bool | None = None) -> None:
    if not path.exists():
        raise RuntimeError(f'Ícone ausente: {path.relative_to(ROOT)}')
    width, height, color_type = png_info(path)
    if (width, height) != (size, size):
        raise RuntimeError(
            f'Tamanho incorreto em {path.relative_to(ROOT)}: {width}x{height}; esperado {size}x{size}'
        )
    has_alpha = color_type in (4, 6)
    if alpha is True and not has_alpha:
        raise RuntimeError(f'Foreground sem transparência: {path.relative_to(ROOT)}')
    if alpha is False and has_alpha:
        raise RuntimeError(f'Ícone iOS/background não deve conter alpha: {path.relative_to(ROOT)}')


def verify_sources() -> None:
    base = ROOT / 'assets/brand/launcher'
    expected = json.loads((base / 'source-hashes.json').read_text(encoding='utf-8'))
    for filename, digest in expected.items():
        path = base / filename
        actual = hashlib.sha256(path.read_bytes()).hexdigest()
        if actual != digest:
            raise RuntimeError(f'Arte-fonte alterada: {filename}')
    require_png(base / 'icon-full.png', 1254, alpha=False)
    require_png(base / 'icon-foreground.png', 1254, alpha=True)
    require_png(base / 'icon-background.png', 1254, alpha=False)
    require_png(ROOT / 'assets/brand/tatica-manager-icon.png', 1024, alpha=False)


def verify_android() -> None:
    manifest = (ROOT / 'android/app/src/main/AndroidManifest.xml').read_text(encoding='utf-8')
    if 'android:icon="@mipmap/ic_launcher"' not in manifest:
        raise RuntimeError('AndroidManifest sem ic_launcher')
    if 'android:roundIcon="@mipmap/ic_launcher_round"' not in manifest:
        raise RuntimeError('AndroidManifest sem ic_launcher_round')

    anydpi = ROOT / 'android/app/src/main/res/mipmap-anydpi-v26'
    for name in ('ic_launcher.xml', 'ic_launcher_round.xml'):
        text = (anydpi / name).read_text(encoding='utf-8')
        if '@mipmap/ic_launcher_background' not in text or '@mipmap/ic_launcher_foreground' not in text:
            raise RuntimeError(f'Adaptive Icon incompleto: {name}')

    densities = {'mdpi': 1.0, 'hdpi': 1.5, 'xhdpi': 2.0, 'xxhdpi': 3.0, 'xxxhdpi': 4.0}
    for density, scale in densities.items():
        base = ROOT / f'android/app/src/main/res/mipmap-{density}'
        legacy = round(48 * scale)
        adaptive = round(108 * scale)
        require_png(base / 'ic_launcher.png', legacy)
        require_png(base / 'ic_launcher_round.png', legacy)
        require_png(base / 'ic_launcher_foreground.png', adaptive, alpha=True)
        require_png(base / 'ic_launcher_background.png', adaptive, alpha=False)


def verify_ios() -> None:
    base = ROOT / 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
    contents = json.loads((base / 'Contents.json').read_text(encoding='utf-8'))
    images = contents.get('images', [])
    if not any(item.get('idiom') == 'ios-marketing' for item in images):
        raise RuntimeError('AppIcon do iOS sem imagem ios-marketing 1024x1024')
    for item in images:
        filename = item.get('filename')
        if not filename:
            continue
        logical = float(item['size'].split('x')[0])
        scale = float(item['scale'].removesuffix('x'))
        pixels = round(logical * scale)
        require_png(base / filename, pixels, alpha=False)


def main() -> int:
    verify_sources()
    verify_android()
    verify_ios()
    print('Ícones validados: fontes preservadas, Android Adaptive/legacy e iOS AppIcon completos.')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
