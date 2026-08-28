# Release 0.1.1.18 — Correção do CI do editor

## Correção

O GitHub Actions da 0.1.1.17 chegou ao `flutter analyze` e falhou com seis erros concentrados em `test/editor_experience_test.dart`:

- três strings contendo `R$` eram literais Dart normais; o `$` era interpretado como início de interpolação e gerava `missing_identifier`;
- três chamadas usavam `asciiEncode`, função inexistente; foram substituídas por `ascii.encode` de `dart:convert`.

A correção é restrita ao teste e não altera a lógica do jogo, `GameController`, persistência, Match Engine, editor ou criação de carreira.

## CI

O log da 0.1.1.17 confirmou que `flutter pub get` passou e que o job parou antes de `flutter test`/build devido aos seis erros de análise. A 0.1.1.18 deve repetir o pipeline completo para validar `analyze`, testes e APK. No ambiente local desta entrega, `flutter pub get`, `flutter analyze`, `flutter test` e `flutter build apk --release` foram realmente tentados e retornaram 127 (`flutter: command not found`), portanto não são considerados aprovados localmente.

## Versão

- release/versionName: `0.1.1.18`;
- pubspec: `0.1.1+20`;
- Android versionCode: `20`.

## Artifact

O workflow permanece configurado para publicar somente o APK versionado; `pubspec.lock` não deve ser publicado como Artifact.
