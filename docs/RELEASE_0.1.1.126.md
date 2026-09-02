# Release 0.1.1.126 — Correção do analyzer no campo compartilhado

**Release visível:** `0.1.1.126`  
**Android versionCode:** `127`

## Correção

- adiciona ao `CompactFormationPitch` o import de `player.dart`, que disponibiliza a extensão `PlayerPositionX` e seu getter `label`;
- elimina o único erro registrado no log 80: `undefined_getter` em `compact_formation_pitch.dart:140`;
- não altera o design de Escalação/Táticas, dados da carreira, regras de formação ou Match Engine.
