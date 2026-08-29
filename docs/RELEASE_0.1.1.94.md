# Release 0.1.1.94 — Transmissão ao vivo refinada

## Escopo

Esta release continua a revisão visual da partida ao vivo iniciada na 0.1.1.92/93. O objetivo é aproximar o enquadramento e o HUD do mockup aprovado sem alterar qualquer resultado, probabilidade ou evento do Match Engine.

## Campo e jogadores

- reduz a inclinação/trapezoide do gramado, deixando a perspectiva mais suave e próxima de uma câmera de transmissão elevada;
- aumenta a área útil do campo dentro do painel e usa proporção 2.48;
- reduz a escala dos jogadores para 72% do renderer anterior, melhorando leitura das linhas e evitando sobreposição excessiva;
- mantém uniformes reais, goleiros diferenciados, bola, gols, torcida WebP e fallback em Canvas.

## HUD da transmissão

- amplia placar, escudos, nomes, fase e relógio;
- reorganiza a faixa de Rodada/Estádio/Rodada com divisões mais próximas da referência;
- reforça timeline e botões Pausar, Simular, Tática, Trocar e Áudio;
- redesenha o painel de estatísticas: posse ganha anel gráfico, chutes e chutes no gol recebem comparação direta e cartões passam a mostrar amarelos/vermelhos visualmente;
- narração recebe cabeçalho e filtros mais presentes.

## Integridade da simulação

Todos os números continuam derivados apenas dos eventos já apresentados até o minuto/sequência atual. Nenhum evento futuro é mostrado no HUD. Match Engine, timeline, probabilidades, substituições, cartões e resultado permanecem inalterados.

## Compatibilidade

- `CareerState` schema 13 preservado;
- saves e IDs persistentes preservados;
- multi-competição preservada;
- Flame continua exclusivamente como camada visual.

## Validação

O ambiente desta entrega não possui Flutter/Dart. `python3 tool/versioning.py verify` e preflight estrutural local devem ser executados aqui; `flutter analyze`, `flutter test` e `flutter build apk --release` dependem do GitHub Actions.
