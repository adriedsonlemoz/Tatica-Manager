# Release 0.1.1.105 — Partida visual 2.5D

## Escopo

Esta release mantém o campo retangular restaurado na 0.1.1.104 e adiciona profundidade visual aos elementos móveis da partida. O objetivo é testar um 2.5D convincente sem trocar novamente o gramado e sem mover nenhuma responsabilidade para fora do Match Engine.

## Jogadores

- escala visual varia conforme a posição vertical: atletas mais distantes ficam menores e os mais próximos ficam maiores;
- os dois times são ordenados em uma única fila de profundidade para que quem está mais perto da câmera seja desenhado por cima;
- o renderer passa a usar o `ClubKit` real, incluindo camisa, shorts, meias e padrões de listras/faixa/metades/degradê;
- corpo recebe volume por gradiente, sombra no gramado, variação determinística de pele/cabelo e goleiro com cor contrastante;
- corrida passa a animar pernas, braços, balanço e leve inclinação conforme o deslocamento visual;
- jogadores parados recebem apenas micro-movimento ambiente, sem alterar as coordenadas da simulação.

## Bola e gol

- passes e finalizações ganham arco visual calculado somente sobre o progresso de apresentação do lance;
- sombra da bola permanece no gramado enquanto a bola sobe visualmente;
- chutes, gols, trave e defesas usam alturas diferentes;
- a rede do gol recebe uma reação curta quando o evento já apresentado é gol.

## Campo e estádio

- preserva a geometria, proporção `105 / 68` e mapeamento linear da 0.1.1.91/0.1.1.104;
- adiciona apenas iluminação, borda/sombra e profundidade discreta sem reconstruir o gramado.

## Integridade

- Match Engine não alterado;
- `CareerState` schema 13 preservado;
- saves e IDs persistentes preservados;
- multi-competição preservada;
- Flame continua exclusivamente como apresentação visual.

## Validação

Executar `python3 tool/versioning.py verify`, `flutter pub get`, `flutter analyze`, `flutter test` e `flutter build apk --release` quando Flutter estiver disponível. A validação em aparelho deve observar principalmente sobreposição dos jogadores, escala perto/longe, legibilidade dos uniformes e altura visual da bola.
