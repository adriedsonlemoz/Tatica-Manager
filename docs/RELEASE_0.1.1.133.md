# Release 0.1.1.133 — Campo ao vivo mais dinâmico

**Release visível:** `0.1.1.133`  
**Android versionCode:** `134`  
**pubspec:** `0.1.1+134`

## Formação visual real

- O campo deixa de usar posições fixas em 4-3-3.
- `LiveMatchSession` guarda as formações de mandante e visitante calculadas para a partida.
- `MatchPitchFormation` converte os slots oficiais de `FormationCatalog`, mantendo os titulares na mesma ordem usada por `LineupEngine`.

## Posse ao vivo estável

- A posse visível passa a usar a estatística oficial do Match Engine como referência.
- Passes e eventos de posse já apresentados continuam influenciando o valor, mas recebem uma amostra inicial suficiente para evitar 0%-100%.
- O indicador permanece entre 30% e 70% e converge ao resultado oficial no minuto 90.

## Movimento por fases

- Os setores acompanham lateralmente a bola e avançam ou recuam conforme o domínio.
- Goleiro, defesa, meio e ataque usam intensidades distintas para preservar a estrutura tática.
- Depois do lance, os atletas voltam ao bloco da fase atual, não às antigas posições estáticas.

## Leitura do campo

- Nomes passivos são menores e mais transparentes.
- Jogador ativo, assistência e demais envolvidos recebem prioridade visual.
- O posicionador continua tentando seis âncoras e não permite sobreposição.
- Bola, marcações das áreas, redes, traves e profundidade dos gols ficaram maiores e mais contrastadas.

## Aproximação dos lances

- Passes, faltas e cartões mantêm a câmera normal.
- Chutes, defesas, bolas na trave, pênaltis e gols recebem aproximação suave e limitada.
- Replays usam uma aproximação discreta, sempre limitada a 1,13x, e retornam gradualmente à visão completa.

O renderer continua sem calcular resultados ou probabilidades: ele apenas representa a timeline produzida pelo Match Engine.
