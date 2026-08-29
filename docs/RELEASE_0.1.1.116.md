# Release 0.1.1.116 — Correção dos testes da Home e tema

## Escopo

Esta release corrige exclusivamente as duas regressões de teste reveladas pelo GitHub Actions da 0.1.1.115. O `flutter analyze` passou sem problemas e 287 testes foram aprovados; o workflow parou apenas porque duas expectativas estruturais ainda descreviam a Home e a paleta anteriores.

## Correções

- `test/career_onboarding_ui_test.dart` deixa de exigir os hexadecimais antigos `0xFF76D91B` e `0xFFD6B65D` e passa a validar o verde `0xFF35A94B`, o amarelo `0xFFD5A626`, as superfícies claras atuais e a base azul-grafite preservada no modo escuro;
- `test/player_avatar_identity_test.dart` deixa de procurar `playerForEvent` e `_playerForEvent` na Home antiga e passa a validar a nova composição `HomeCleanRankings` e o `PlayerAvatar` dos artilheiros em `home_clean_content.dart`;
- nenhum código funcional da Home, tema, partida, libGDX ou Match Engine é alterado.

## Compatibilidade

Permanecem preservados:

- Home clara e modo escuro persistente;
- renderer Android libGDX e Flame fallback;
- movimentação integrada da 0.1.1.113;
- Match Engine e coordenadas/eventos da partida;
- `CareerState` schema 13;
- saves existentes, IDs persistidos e fundação multi-competição.

## Validação

O log do GitHub Actions da 0.1.1.115 confirmou `flutter analyze` sem problemas e 287 testes aprovados, com duas falhas estruturais. Nesta entrega, `python3 tool/versioning.py verify` deve validar a sincronização de versão. `flutter analyze`, `flutter test` e `flutter build apk --release` dependem do GitHub Actions ou de um ambiente com Flutter instalado.
