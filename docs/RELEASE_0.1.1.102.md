# Release 0.1.1.102 — Campo real como cenário da partida

## Escopo

Esta release troca a estratégia visual do campo ao vivo. Em vez de tentar reconstruir gramado, linhas, gols e estádio a cada frame, o Flame passa a usar um cenário de campo pronto como fundo e mantém apenas os elementos dinâmicos por cima. O Match Engine permanece integralmente responsável pelos acontecimentos da partida.

## Novo cenário

- adiciona `assets/images/match/match_field.webp`;
- o asset foi recortado/otimizado para `1550x625`, razão exata `2.48:1` do `LiveMatchPitchPanel`;
- gramado, arquibancada, iluminação, linhas e gols ficam incorporados ao fundo;
- o renderer desenha a imagem sem crop adicional, evitando deformação no telefone.

## Jogadores e bola

- os 22 jogadores continuam sendo renderizados pelo `MatchPlayerVisuals`;
- bola, trilha, destaque de jogador, replay, comemorações e defesa de goleiro continuam dinâmicos;
- `MatchPitchVisuals.projectDisplayPoint` foi calibrado ao trapézio real do gramado da imagem: topo em ~19,4% da altura, base em ~94,7%, com convergência lateral de ~20,2% no topo;
- a rotação horizontal dos `FieldPoint` continua a mesma, portanto nenhum dado do Match Engine foi alterado.

## Fallback

Se `match_field.webp` não puder ser decodificado, o jogo volta automaticamente ao renderer anterior com `stadium_crowd.webp`, campo, linhas e gols em Canvas. Isso evita tela vazia em caso de problema de asset.

## Testes

- atualiza `live_match_visual_experience_test.dart` para validar a presença do novo asset e o caminho primário por imagem;
- adiciona regressão para os quatro limites da projeção calibrada do gramado;
- preserva as regressões que garantem ausência de `MatchEngine`/`Random` no renderer visual.

## Compatibilidade

- `CareerState` schema 13 preservado;
- saves e IDs persistentes preservados;
- multi-competição preservada;
- nenhuma regra de placar, eventos, cartões, substituições ou resultado foi modificada.

## Validação

Executar `python3 tool/versioning.py verify`, `flutter pub get`, `flutter analyze`, `flutter test` e `flutter build apk --release` quando o ambiente tiver Flutter disponível.
