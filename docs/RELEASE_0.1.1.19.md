# Release 0.1.1.19 — Correção final do analyzer

## Correção

O GitHub Actions da `0.1.1.18` passou por `flutter pub get` e encontrou apenas um lint em `flutter analyze --no-pub`:

- `test/editor_experience_test.dart:3:8` — `unnecessary_import` para `dart:typed_data`.

O import foi removido porque `Uint8List` já está disponível pelo import de `package:flutter/services.dart` usado pelo mesmo teste.

A alteração é restrita ao teste e aos metadados de release. Não há mudança funcional em editor, criação de carreira, persistência, Match Engine, `GameController` ou demais regras do jogo.

## CI

O log da `0.1.1.18` confirma que as seis falhas anteriores foram resolvidas e restou somente esse lint. O pipeline da `0.1.1.19` deve repetir `pub get`, `analyze`, `test` e `build` para confirmar a sequência completa.

No ambiente local desta correção, os quatro comandos Flutter foram realmente tentados e retornaram `127` (`flutter: command not found`). Portanto, `analyze`, testes e APK não são considerados aprovados localmente e dependem do GitHub Actions.

## Versão

- release/versionName: `0.1.1.19`;
- pubspec: `0.1.1+21`;
- Android versionCode: `21`.

## Artifact

O workflow permanece configurado para publicar somente o APK versionado. `pubspec.lock` não deve ser publicado como Artifact.
