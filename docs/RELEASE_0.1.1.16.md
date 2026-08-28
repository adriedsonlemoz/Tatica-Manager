# Release 0.1.1.16 — Correções de CI e análise

## Correções

- corrige os cinco lints reportados pelo GitHub Actions da 0.1.1.14 e ainda presentes na 0.1.1.15;
- troca parâmetros descartados `(_, __, ___)` por wildcards `(_, _, _)` em `common.dart` e `club_editor_widgets.dart`;
- simplifica a consulta nullable em `career_signing_screen.dart` com null-aware access;
- mantém intacta a lógica de carreira, editor, partidas, mercado e persistência;
- atualiza Sobre / Novidades para iniciar pela release atual;
- reforça `tool/versioning.py verify` para checar também README, handoff, prompt de continuação, primeira release de Novidades e documento da release atual.

## Versionamento

- release/versionName: `0.1.1.16`;
- pubspec: `0.1.1+18`;
- Android versionCode: `18`;
- `al-sistemas.json` permanece como fonte canônica;
- `VERSION`, `app.json`, `pubspec.yaml`, Android, `AppInfo`, README e handoff foram sincronizados.

## CI

O log analisado da 0.1.1.14 falhou em `flutter analyze --no-pub` por cinco lints. Esta release corrige exatamente esses pontos e faz varredura adicional por placeholders com múltiplos underscores.

O ambiente local desta sessão não possui Flutter/Dart. Portanto `flutter pub get`, `flutter analyze`, `flutter test` e `flutter build apk --release` devem ser validados no GitHub Actions antes de considerar o APK aprovado. O workflow continua configurado para publicar somente o APK versionado, com `archive: false`.
