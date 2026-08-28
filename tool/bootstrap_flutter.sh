#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter não está instalado ou não está no PATH." >&2
  exit 1
fi

flutter create \
  --platforms=android,ios \
  --org=com.taticamanager \
  --project-name=tatica_manager \
  .

# O template do Flutter cria um widget_test.dart para MyApp, mas este projeto
# usa TaticaManagerApp e possui testes próprios. Remova apenas o teste padrão.
if [ -f test/widget_test.dart ] && grep -q "MyApp" test/widget_test.dart; then
  rm test/widget_test.dart
fi

python3 tool/configure_platforms.py
flutter pub get

echo "Estrutura Android/iOS criada e dependências resolvidas."
