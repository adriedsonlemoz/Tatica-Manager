# Release 0.1.1.55 — Campo fixo durante replay

**Android versionCode:** `57`  
**pubspec:** `0.1.1+57`  
**CareerState schema:** `10`

## Correção da partida

- Remove a transformação de câmera aplicada ao canvas do campo (`translate`/`scale`/`translate`).
- O gramado permanece fixo no mesmo enquadramento durante jogo normal e replay.
- Elimina o deslocamento lateral que podia revelar uma faixa preta do estádio durante replay.
- Replays continuam reproduzindo a timeline já calculada, com movimento da bola, jogadores e efeitos de evento.

## Arquitetura e compatibilidade

- Match Engine não foi alterado.
- Nenhuma regra, evento, placar ou resultado de partida foi alterado.
- Flame continua somente como representação visual.
- CareerState permanece no schema 10, sem mudanças em IDs persistidos ou saves.

## Testes

- Regressão estrutural garante que `MatchPitchGame` não volte a aplicar `MatchCameraDirector`, `canvas.translate` ou `canvas.scale` no campo.
