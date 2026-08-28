# Release 0.1.1.61

## Objetivo

Corrigir os três testes estruturais revelados pelo GitHub Actions depois que o `flutter analyze` da 0.1.1.60 passou, alinhando as expectativas à arquitetura e aos textos atuais sem reverter funcionalidades.

## Correções

- `career_creation_ui_test.dart`: passa a validar o campo `País`, que substituiu o rótulo antigo `Nacionalidade` na criação simplificada do técnico.
- `finance_stadium_sponsorship_test.dart`: passa a validar as seções remodeladas `Salários` e `Patrocínios`, preservando o acesso clicável ao perfil do jogador, Estádio e administração financeira.
- `player_avatar_identity_test.dart`: passa a acompanhar a modularização da Home, validando `_playerForEvent` em `home_screen.dart` e `PlayerAvatar` nos widgets `home_dashboard_news.dart` e `home_dashboard_rankings.dart`.

## Compatibilidade

- Nenhum código funcional de produção alterado.
- `CareerState` permanece no schema 11.
- Saves e IDs persistidos permanecem intactos.
- Match Engine não foi alterado.
- GitHub Actions não foi alterado.

## Versionamento

- Release: `0.1.1.61`
- pubspec: `0.1.1+63`
- Android versionCode: `63`
