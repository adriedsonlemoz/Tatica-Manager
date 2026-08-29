# Release 0.1.1.93 — Torcida integrada à partida

## Escopo

Esta release integra o asset de torcida criado para o campo da partida e corrige o erro real encontrado pelo GitHub Actions da 0.1.1.92. Não altera nenhuma regra da simulação.

## Torcida e estádio

- adiciona `assets/images/match/stadium_crowd.webp`, convertido do PNG criado para WebP 1600x900 com cerca de 136 KB;
- `MatchPitchGame` carrega o asset de forma assíncrona e o envia para `MatchStadiumVisuals`;
- `MatchStadiumVisuals` desenha a imagem como camada de fundo com crop responsivo e escurecimento leve;
- o campo em perspectiva, gols, jogadores, bola e efeitos continuam sendo desenhados por cima no Flame;
- se o asset não puder ser carregado, o renderer preserva o estádio, público e refletores desenhados em Canvas como fallback.

## Correção do CI

O GitHub Actions da 0.1.1.92 parou no `flutter analyze` por um único erro em `test/live_match_visual_experience_test.dart`: o teste verificava `LiveMatchTimelineBar` usando a variável `screen` fora do escopo em que ela havia sido declarada. A leitura de `match_screen.dart` agora é declarada no próprio teste do renderer.

## Compatibilidade

Permanecem inalterados:

- Match Engine e suas probabilidades;
- timeline e eventos;
- cartões e substituições;
- resultado e estatísticas;
- `CareerState` schema 13;
- saves e IDs persistentes;
- fundação multi-competição;
- Flame continua exclusivamente como camada visual.

## Validação

O ambiente desta entrega não possui Flutter/Dart. `python3 tool/versioning.py verify` e o preflight estrutural são executados localmente; `flutter analyze`, `flutter test` e `flutter build apk --release` dependem do GitHub Actions.
