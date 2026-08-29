# Release 0.1.1.104 — Campo visual restaurado

## Escopo

Esta release mantém a base atual do Tática Manager e restaura somente a apresentação da partida ao vivo usada antes da reformulação iniciada na 0.1.1.92. O objetivo é recuperar o campo visual da 0.1.1.91 sem desfazer nenhuma evolução funcional posterior.

## Renderer restaurado

- `LiveMatchPitchPanel` volta à proporção `105 / 68`;
- `MatchPitchVisuals` recupera o gramado retangular, faixas, marcações, gols, vinheta e borda da 0.1.1.91;
- `MatchStadiumVisuals` recupera arquibancadas, torcida, LEDs, bancos e refletores desenhados em Canvas;
- `MatchPlayerVisuals` recupera os jogadores do renderer anterior;
- `MatchPitchGame` volta ao mapeamento linear de `FieldPoint` dentro do campo, preservando a rotação horizontal da representação.

## O que não foi revertido

Permanecem atuais o HUD, placar, faixa da rodada, timeline, controles, estatísticas, narração, replay, substituições e toda a lógica de eventos. O campo WebP e a projeção das releases 0.1.1.102/103 deixam de ser usados pelo renderer normal, mas os arquivos de imagem são mantidos no projeto por enquanto.

## Compatibilidade

- Match Engine não alterado;
- `CareerState` schema 13 preservado;
- saves e IDs persistentes preservados;
- multi-competição preservada;
- Flame continua apenas como representação visual.

## Testes

`live_match_visual_experience_test.dart` foi atualizado para proteger a geometria restaurada da 0.1.1.91 e garantir que o renderer não volte a carregar `match_field.webp` ou `stadium_crowd.webp` sem uma alteração explícita futura.

## Validação

Executar `python3 tool/versioning.py verify`, `flutter pub get`, `flutter analyze`, `flutter test` e `flutter build apk --release` quando o ambiente possuir Flutter. Neste ambiente, as etapas Flutter continuam dependentes do GitHub Actions.
