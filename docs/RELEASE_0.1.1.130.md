# Release 0.1.1.130 — Simulação de partidas mais realista

**Release visível:** `0.1.1.130`  
**Android versionCode:** `131`  
**pubspec:** `0.1.1+131`

## Correção do build

- Corrige os imports das extensões de formação e mentalidade nas telas de perfil e seleção de técnico. O erro do log 83 impedia `flutter analyze` de prosseguir para testes e APK.

## Partidas

- A força dos setores passa a combinar o overall efetivo com atributos técnicos, mentais, físicos e específicos de goleiro.
- O volume de gols e chutes varia conforme o confronto e a tática, em vez de manter uma taxa fixa para qualquer partida.
- Quem está perdendo aumenta a iniciativa no fim do jogo; o time que vence reduz a exposição de forma moderada.
- Faltas, cartões e lesões foram recalibrados. A falta usa perfil e posição do jogador; amarelos, pressão e carga física deixam de ter uma probabilidade fixa.
- Perfis de técnico CPU influenciam a organização coletiva e a CPU pode usar substituições nas partidas sem apresentação ao vivo.

## Competições e carreira

- Partidas marcadas como segundo plano continuam sem tela Flame, mas agora usam o mesmo Match Engine para produzir eventos persistidos. Assim, placar, artilharia, cartões, suspensão, condição, fadiga, moral e lesão não divergem entre ligas.
- Adiciona testes para volume de chances, reação ao placar e resolução de segundo plano com eventos individuais.
