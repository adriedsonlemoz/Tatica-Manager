#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

python3 tool/versioning.py verify
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --release
python3 tool/versioning.py verify

echo "Etapa validada. APK: build/app/outputs/flutter-apk/app-release.apk"
