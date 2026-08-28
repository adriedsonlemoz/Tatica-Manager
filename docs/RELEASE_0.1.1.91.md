# Release 0.1.1.91 — Home com tipografia ampliada

## Escopo

Esta release combina a correção dos erros de analyzer encontrados na 0.1.1.90 com uma revisão estritamente tipográfica da Home. Não há aumento intencional de cards nem mudança de regra de jogo.

## Home

- aumenta em 3 px/lp a base das fontes dos componentes principais da Home;
- usa `FittedBox` em títulos e áreas estreitas para reduzir risco de overflow sem ampliar os cards;
- mantém alturas declaradas de cabeçalho, finanças, Próxima Partida, confiança/panorama e atalhos;
- tabela compacta mostra `club.name` em vez de `shortName`;
- botão central passa a usar `AVANÇAR DIA` e, em dia de jogo, `JOGAR PARTIDA`;
- o nome `Campeonato Brasileiro Série A` é encurtado visualmente para `Brasileiro Série A` apenas na Home;
- escudos da Próxima Partida passam de 58 para 68 px;
- Últimas Partidas passa a carregar a rodada do fixture e mostra `R<n>` com o rótulo `RODADA`.

## Correção do analyzer da 0.1.1.90

- `pre_match_lineup_card.dart` importa `player.dart`, colocando a extension `PlayerPositionX.label` no escopo;
- `_PremiumPanel` de `pre_match_controls.dart` deixa de expor um parâmetro opcional `padding` que nunca era fornecido;
- `pre_match_and_lineup_ui_test.dart` usa aspas simples no caminho do asset;
- adiciona expectativa estrutural para proteger o import necessário ao rótulo de posição.

## Compatibilidade

Permanecem preservados `CareerState` schema 13, saves existentes, IDs persistentes, calendário e fundação multi-competição, CPU, mercado, contratos, finanças e Match Engine. Flame continua somente como camada visual da partida.

## Validação

O versionamento e o preflight estrutural são executados localmente. Como este ambiente não possui Flutter/Dart, `flutter pub get`, `flutter analyze`, `flutter test` e `flutter build apk --release` ainda dependem do GitHub Actions.
