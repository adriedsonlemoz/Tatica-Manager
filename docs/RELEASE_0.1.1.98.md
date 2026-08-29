# Release 0.1.1.98 — Jogadores e gramado mais nítidos

## Causa

O usuário reportou que o campo da partida ao vivo, mesmo já com perspectiva, marcações e torcida implementados, ficava "muito ruim" ao rodar de fato no app: os jogadores pareciam bonecos genéricos indistinguíveis por time e o gramado parecia apagado, sem a nitidez de referência esperada. A causa raiz foi identificada por comparação direta entre a referência aprovada e um print real do app: o token do jogador desenhava braços, pernas, cabelo e meias como traços finos separados que, na escala real de renderização (cerca de 6–9 px de largura), se tornam uma mancha borrada em vez de uma silhueta legível.

## Correções

- `match_player_visuals.dart` é reescrito para desenhar o jogador como um único token sólido de alto contraste: corpo em cápsula com o padrão do uniforme (listras, sash, metades, gradiente) simplificado para 2–3 divisões em vez de 5, cabeça única sem cabelo/pescoço, sombra de contato e brilho superior sutil; braços viram dois círculos curtos em vez de traços de linha;
- `match_pitch_visuals.dart` recebe um verde mais saturado no gramado, listras de corte com mais contraste, linhas de marcação mais grossas e um `_perspectiveInset` mais acentuado no topo do campo para reforçar o efeito de câmera de transmissão.

## Compatibilidade

Nenhuma regra de jogo foi alterada. Match Engine, eventos, placar, `CareerState` schema 13, saves, IDs e multi-competição permanecem intactos. As assinaturas públicas usadas pelos testes (`_perspectiveInset(field, perspectiveY)`, `perspectiveScale(display.y) * .58`, `ClubKitPattern.verticalStripes`, `goalkeeperDive`, `celebration`, `drawMatchBallGraphic(`) foram preservadas.

## Validação

- `python3 tool/versioning.py verify`;
- `flutter analyze`, `flutter test` e `flutter build apk --release` continuam dependentes do GitHub Actions neste ambiente (sem SDK Flutter disponível para rodar localmente).
