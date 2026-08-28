# Release 0.1.1.87 — Correção do teste da Home compacta

## Causa real

O GitHub Actions da 0.1.1.86 executou `flutter analyze` sem encontrar problemas e avançou para os testes. Dos 271 testes, 270 passaram. A única falha estava em `calendar_and_standings_ui_test.dart`.

O teste ainda esperava encontrar o texto `PREPARAÇÃO EM ANDAMENTO` em `home_dashboard_match.dart`, mas a revisão compacta da Home passou a renderizar o estado como `PREPARAÇÃO • <mensagem>`.

## Correção

- atualiza somente a expectativa estrutural para o rótulo realmente usado pela Home atual;
- não modifica layout, Match Engine, fadiga, táticas, eventos, saves, IDs ou regras da carreira.

## Compatibilidade

- `CareerState` schema 13 preservado;
- saves e IDs persistentes preservados;
- fundação multi-competição preservada;
- CPU, mercado e contratos preservados;
- Match Engine permanece responsável pela lógica da partida;
- Flame continua apenas como representação visual.

## Validação

O GitHub Actions anterior já confirmou `flutter analyze` sem problemas. Esta release ainda precisa ser confirmada pelo novo CI para `flutter test` e `flutter build apk --release`.
