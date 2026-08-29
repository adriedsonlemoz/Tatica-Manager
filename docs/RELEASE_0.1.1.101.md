# Release 0.1.1.101 — Workflow do GitHub restaurado

## Causa real

O pacote `0.1.1.100` recebido após a edição externa não continha arquivos ou pastas ocultos. Por isso `.github/workflows/flutter-ci.yml` desapareceu do ZIP. O GitHub Manager conseguiu sincronizar o commit, mas não encontrou execução automática nem um workflow de APK com `workflow_dispatch`.

## Correção

- restaura `.github/workflows/flutter-ci.yml` byte a byte a partir da última base válida disponível (`0.1.1.97`);
- preserva os gatilhos `push` para `main`/`flutter-rebuild-stage1`, `pull_request` e `workflow_dispatch`;
- preserva a validação de versão, `flutter pub get`, `flutter analyze`, `flutter test` e `flutter build apk --release`;
- preserva a política de Artifact: somente `tatica-manager-${release}.apk`, sem `pubspec.lock`;
- restaura também `.gitignore` e `android/.gitignore`, que foram omitidos pelo mesmo processo de compactação.

## Escopo

Nenhum arquivo funcional do jogo foi substituído pela base antiga. Campo, jogadores, UI, Match Engine, controllers, `CareerState` schema 13, saves, IDs e multi-competição permanecem exatamente na base recebida como `0.1.1.100`.

## Validação

Deve ser executado `python3 tool/versioning.py verify` e conferida a presença dos arquivos ocultos dentro do ZIP. O ambiente local não possui Flutter/Dart; portanto `flutter pub get`, `flutter analyze`, `flutter test` e `flutter build apk --release` dependem do GitHub Actions.
