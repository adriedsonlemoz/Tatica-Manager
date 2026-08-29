# Release 0.1.1.97 — Correção dos testes da transmissão

## Causa

O GitHub Actions da 0.1.1.96 passou pelo `flutter analyze` sem problemas e executou 272 testes: 270 passaram e dois falharam. As duas falhas eram regressões de teste/configuração, não erros do campo ou da lógica da partida.

## Correções

- `live_match_visual_experience_test.dart` deixa de procurar a constante antiga `field.width * .018` e passa a validar a nova perspectiva por `_perspectiveInset(field, perspectiveY)`;
- o mesmo teste passa a esperar a escala atual `perspectiveScale(display.y) * .58`;
- `AppInfo.recentReleases` volta a manter exatamente três releases, como a tela Sobre/Novidades e `app_info_test.dart` já especificam.

## Compatibilidade

Nenhuma regra de jogo foi alterada. Campo, torcida, Match Engine, `CareerState` schema 13, saves, IDs e multi-competição permanecem intactos.

## Validação

- `python3 tool/versioning.py verify`;
- preflight local das expectativas alteradas;
- `flutter analyze`, `flutter test` e `flutter build apk --release` continuam dependentes do GitHub Actions neste ambiente.
