# Release 0.1.1.100 — Sincronização de versão

## Causa

O usuário pediu para avançar a versão do projeto, fixando o número final (A.B.C.**D**) em `100`, para que o aplicativo de checagem de versão que ele usa detecte a mudança.

## Correções

- Nenhuma alteração de código nesta entrega — apenas a versão visível e os metadados relacionados foram sincronizados.

## Compatibilidade

Nenhuma regra de jogo foi alterada. Campo, jogadores, torcida, Match Engine, eventos, placar, `CareerState` schema 13, saves, IDs e multi-competição permanecem intactos.

## Validação

- `python3 tool/versioning.py verify`;
- `flutter analyze`, `flutter test` e `flutter build apk --release` continuam dependentes do GitHub Actions neste ambiente (sem SDK Flutter disponível para rodar localmente).
