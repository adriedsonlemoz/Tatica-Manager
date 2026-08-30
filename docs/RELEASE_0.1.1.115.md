# Release 0.1.1.115 — Correção do cabeçalho da Home

**Android versionCode:** `116`  
**pubspec:** `0.1.1+116`

## Motivo

O GitHub Actions da 0.1.1.114 parou em `flutter analyze --no-pub` com um único erro em `lib/features/home/home_dashboard_header.dart:92`: o parâmetro nomeado `minHeight` foi usado diretamente em `Container`, mas `Container` não possui esse parâmetro.

## Correção

- substitui `Container(minHeight: 104)` por `Container(constraints: const BoxConstraints(minHeight: 104))`;
- preserva a altura mínima planejada para o cabeçalho do clube;
- não desfaz a revisão visual da Home da 0.1.1.114;
- não altera Match Engine, músicas, saves, schema, IDs, regras ou resultados.

## Validação local disponível

- `python3 tool/versioning.py sync`;
- `python3 tool/versioning.py verify`;
- verificação estrutural do arquivo corrigido e ausência do uso inválido `Container(minHeight: ...)`;
- integridade do ZIP e preservação de `.github/workflows/flutter-ci.yml`.

O ambiente de empacotamento local não possui Flutter/Dart instalado; `flutter analyze`, `flutter test` e `flutter build apk --release` devem ser confirmados pelo GitHub Actions.
