# Release 0.1.1.103 — Correção do analyzer do campo em imagem

## Causa

O GitHub Actions da 0.1.1.102 executou `flutter analyze --no-pub` e encontrou um único problema: `test/live_match_visual_experience_test.dart` importava `dart:ui`, embora os elementos usados no teste já fossem fornecidos por `flutter_test`. Como o CI trata qualquer issue do analyzer como falha, testes e build não chegaram a rodar.

## Correção

- remove somente o import redundante `dart:ui`;
- mantém o novo campo WebP, a projeção, os jogadores, a bola, o HUD e o fallback exatamente como na 0.1.1.102;
- não altera Match Engine, regras, saves, IDs ou multi-competição.

## Validação

Executar `python3 tool/versioning.py verify` localmente. `flutter analyze`, `flutter test` e `flutter build apk --release` dependem do GitHub Actions neste ambiente.
