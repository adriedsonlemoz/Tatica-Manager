# Release 0.1.1.83 — Substituições com limite de janelas

## Problema identificado

A partida já possuía o teto de cinco jogadores substituídos, mas a regra estava incompleta: cada troca individual podia acontecer em uma parada diferente. Isso permitia até cinco janelas de substituição, enquanto a regra usada pelo jogo deve limitar o time a três oportunidades durante o tempo regulamentar.

## Correção

- mantém no máximo cinco jogadores substituídos por partida;
- limita as substituições a três janelas durante o tempo regulamentar;
- duas ou mais trocas feitas no mesmo minuto contam como uma única janela;
- o intervalo não consome uma janela, mas jogadores trocados no intervalo continuam entrando no total máximo de cinco;
- a quarta janela é bloqueada com mensagem clara;
- jogador que já saiu continua impedido de retornar à partida.

## Arquitetura

A regra foi centralizada em `lib/game/match/live_substitution_rules.dart`. O `LiveMatchController` continua responsável por aplicar a troca e re-simular o restante da partida, enquanto `MatchScreen` e `LiveSubstitutionSheet` apenas consultam e apresentam os limites. Flame não recebeu nenhuma regra.

## Testes

`live_substitution_limit_test.dart` passa a validar funcionalmente:

- limite de cinco jogadores;
- múltiplas trocas no mesmo minuto usando uma janela;
- bloqueio da quarta janela;
- intervalo sem consumo de janela;
- uso da regra central pelo controller e pela tela.

`live_substitution_pause_test.dart` também passa a proteger os campos de janelas exibidos pelo fluxo.

## Compatibilidade

Não há mudança de schema ou persistência. Permanecem preservados `CareerState` schema 13, saves existentes, IDs persistentes, fundação multi-competição, calendário, CPU, mercado, contratos, finanças e Match Engine.
