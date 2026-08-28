# Release 0.1.1.10 — Correção do CI

## Objetivo

Correção pequena e isolada antes de iniciar novas funcionalidades em chats separados.

## Alterações

- Remove o import não utilizado `../../app/state/transfer_controller.dart` de `lib/features/player/player_profile_screen.dart`.
- Corrige a falha do `flutter analyze --no-pub` observada no GitHub Actions da 0.1.1.9.
- Mantém a política do CI de publicar somente o APK versionado nos Artifacts.
- Não altera regras de mercado, calendário, temporada, partida ou persistência.

## Próxima etapa

Abrir um novo chat do Projeto para uma única funcionalidade de lógica por vez. A próxima recomendada é contratos e jogadores livres.
