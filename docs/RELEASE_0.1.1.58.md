# Release 0.1.1.58

## Correção

- Remove o import redundante de `dart:ui` em `lib/core/diagnostics/diagnostic_service.dart`.
- Corrige o único `unnecessary_import` reportado pelo `flutter analyze` no GitHub Actions da 0.1.1.57.
- Não altera comportamento da Central de Diagnóstico, áudio, saves, `CareerState` schema 11, Match Engine ou workflow.

## Versionamento

- Release visível: `0.1.1.58`
- pubspec: `0.1.1+60`
- Android versionName: `0.1.1.58`
- Android versionCode: `60`

## Validação

Executar no CI/ambiente Flutter:

```bash
python3 tool/versioning.py verify
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```
