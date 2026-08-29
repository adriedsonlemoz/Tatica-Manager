# Release 0.1.1.96 — Correção do renderer da bola

## Causa do erro

O GitHub Actions da 0.1.1.95 parou no `flutter analyze` antes dos testes e do build. O novo `match_pitch_visuals.dart` chamava `drawMatchBall`, porém a API real já existente em `lib/core/theme/match_ball_styles.dart` se chama `drawMatchBallGraphic`. Como a função importada não era usada, o analyzer também reportou `unused_import`.

## Correção

- substitui a chamada inexistente por `drawMatchBallGraphic`;
- usa os parâmetros reais `center`, `radius` e `style`;
- mantém o mesmo sistema de estilos de bola já existente.

## Compatibilidade

Nenhuma regra de partida foi alterada. Permanecem preservados o novo campo da 0.1.1.95, torcida, Match Engine, timeline, cartões, substituições, `CareerState` schema 13, saves, IDs e fundação multi-competição.

## Validação

`python3 tool/versioning.py verify` é executado nesta entrega. O ambiente atual não possui Flutter/Dart, portanto `flutter analyze`, `flutter test` e `flutter build apk --release` ainda dependem do GitHub Actions.
