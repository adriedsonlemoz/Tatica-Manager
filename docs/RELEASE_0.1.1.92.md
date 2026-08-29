# Release 0.1.1.92 — Partida ao vivo em perspectiva

## Escopo

Esta release trabalha a apresentação da partida e a Passagem do Tempo. Não altera probabilidades, timeline, resultados, cartões, substituições, táticas, persistência ou qualquer regra do Match Engine.

## Campo e estádio

- `MatchPitchVisuals` passa a projetar o campo horizontal em um quadrilátero perspectivado, mantendo as coordenadas originais do Match Engine e transformando somente a apresentação;
- linhas, áreas, círculo central, marcas de pênalti e gols acompanham a mesma projeção;
- gols recebem profundidade e malha desenhada em Canvas;
- `MatchStadiumVisuals` desenha arquibancadas, público, painéis de LED, luzes e atmosfera sem adicionar PNG/JPG/WebP;
- o painel Flame passa a usar proporção 2.20 para aproximar a câmera da referência horizontal.

## Jogadores

- `MatchPlayerVisuals` aumenta presença, sombra e volume dos bonecos;
- cada time usa o `ClubKit` já persistido no clube, incluindo padrão liso, listras verticais/horizontais, faixa, metades e degradê;
- pequenas variações determinísticas de pele/cabelo usam o `playerId` apenas para representação, sem adicionar campo ao save;
- goleiros recebem cor contrastante somente no renderer para facilitar leitura no campo.

## Transmissão

- placar ganha hierarquia maior para clubes e resultado;
- faixa da rodada passa a exibir também o estádio real da partida;
- adiciona timeline visual que mostra somente eventos já apresentados, sem revelar a timeline futura já calculada;
- controles recebem maior presença mantendo Pausar, Simular, Tática, Trocar e Áudio existentes.

## Passagem do Tempo

A transição de avanço diário passa a apresentar Hoje/Amanhã, distância da próxima partida, recuperação e os processos realmente executados pela carreira: condição/fadiga, contratos/mercado e calendário/notícias. `GameController.advanceDay()` continua sendo o mesmo.

## Compatibilidade

Permanecem preservados `CareerState` schema 13, saves, IDs persistentes, multi-competição, Match Engine e Flame como camada exclusivamente visual.

## Validação

O ambiente desta entrega não possui Flutter/Dart. `python3 tool/versioning.py verify` e preflight estrutural local devem ser executados aqui; `flutter analyze`, `flutter test` e `flutter build apk --release` dependem do GitHub Actions.
