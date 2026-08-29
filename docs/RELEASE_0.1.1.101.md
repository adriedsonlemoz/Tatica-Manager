# Release 0.1.1.101 — Token do jogador refeito do zero

## Causa

Após a 0.1.1.98, o usuário reportou (com print real do app) que os jogadores passaram a parecer "bonequinhos de cabeça grande": a cabeça, desenhada como um círculo separado acima do corpo, ficou desproporcionalmente grande em relação ao corpo na escala real de renderização, dominando o token e escondendo o padrão do uniforme que identifica o time. Qualquer ajuste de proporção entre duas formas (corpo + cabeça) corre o risco de repetir esse problema em telas/escala diferentes.

## Correções

- `match_player_visuals.dart` é reescrito do zero: o jogador agora é desenhado como **um único disco chapado**, sem cabeça separada. O padrão do uniforme (listras, sash, metades, gradiente) é recortado dentro do próprio disco; uma leve calota mais escura no terço superior sugere direção sem nunca se destacar como forma independente. Sombra de contato, brilho radial, cor de goleiro e anéis de jogador ativo/replay foram preservados.

## Compatibilidade

Nenhuma regra de jogo foi alterada. Gramado, Match Engine, eventos, placar, `CareerState` schema 13, saves, IDs e multi-competição permanecem intactos. As assinaturas usadas pelos testes (`ClubKitPattern.verticalStripes`, `goalkeeperDive`, `celebration`) foram mantidas.

## Validação

- `python3 tool/versioning.py verify`;
- `flutter analyze`, `flutter test` e `flutter build apk --release` continuam dependentes do GitHub Actions neste ambiente (sem SDK Flutter disponível para rodar localmente). Recomenda-se compilar e comparar com um print real antes da próxima iteração.
