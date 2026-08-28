# Release 0.1.1.25

## Correção do GitHub Actions

O workflow da `0.1.1.24` parou em `flutter analyze --no-pub` antes de executar testes ou gerar o APK. A causa real foram três warnings `unnecessary_non_null_assertion` em `test/cpu_market_test.dart` nas verificações da estratégia de mercado.

A correção remove somente os operadores `!` redundantes depois de assertions `isNotNull`, preservando integralmente a lógica dos testes e do mercado.

## Arquitetura e persistência

- Nenhuma regra de mercado foi alterada.
- `GameController` não foi alterado.
- `LeagueEngine` não foi alterado.
- Não houve alteração de schema SQLite ou IDs persistidos.
- As mudanças visuais e de mercado da `0.1.1.24` permanecem intactas.

## Validação obrigatória

```bash
python3 tool/versioning.py sync
python3 tool/versioning.py verify
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

O GitHub Actions deve publicar somente `tatica-manager-0.1.1.25.apk` como Artifact, sem `pubspec.lock`.
