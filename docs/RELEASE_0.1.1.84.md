# Release 0.1.1.84 — Substituições preparadas em lote

## Escopo

Esta release melhora somente o fluxo de substituições durante a partida ao vivo. A regra de cinco substituições e três janelas da 0.1.1.83 é preservada, mas a interface deixa de aplicar uma troca imediatamente e fechar o sheet.

## Alterações funcionais

- a janela permanece aberta após preparar uma troca;
- o usuário pode preparar várias trocas na mesma parada;
- cada preparação aparece em `TROCAS PREPARADAS` e pode ser removida antes da confirmação;
- `Adicionar troca` apenas adiciona ao lote local da janela;
- `Confirmar trocas` aplica todo o lote;
- fechar/cancelar a janela descarta as trocas ainda não confirmadas;
- várias trocas confirmadas juntas recebem o mesmo minuto e usam uma única janela;
- o limite restante de cinco jogadores continua restringindo a quantidade que pode ser preparada.

## Arquitetura

- `live_substitution_sheet.dart` mantém apenas o estado temporário das trocas preparadas;
- `LiveSubstitutionRules` valida também a quantidade solicitada em um lote;
- `LiveMatchController.substituteMany` valida todos os jogadores e a escalação final antes de alterar a sessão;
- a ressimulação é feita uma única vez depois da validação completa;
- `match_screen.dart` atualiza o renderer e apresenta os eventos somente depois da confirmação;
- Match Engine continua responsável pela lógica da partida e Flame continua apenas representando os acontecimentos.

## Testes

- atualiza o teste estrutural do fluxo de pausa/substituição para exigir lote e confirmação;
- adiciona regressão funcional para impedir que um lote ultrapasse o número restante de substituições;
- preserva as regressões de cinco substituições, três janelas, múltiplas trocas no mesmo minuto e intervalo.

## Compatibilidade

Sem alteração de schema, save ou IDs persistentes. Permanecem preservados `CareerState` schema 13, calendário multi-competição, CPU, mercado, contratos, finanças e Match Engine.
