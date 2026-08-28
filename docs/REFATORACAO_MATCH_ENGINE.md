# Refatoração do Match Engine — build 0.1.0+4

Repositório oficial: `https://github.com/adriedsonlemoz/Tatica-Manager`

Esta entrega refatora o maior motor de regras da partida sem alterar sua API pública. `MatchEngine.simulate(...)` continua sendo o ponto de entrada usado pelos controladores e continua independente de Flutter e Flame.

## Problema anterior

`lib/game/match/engine/match_engine.dart` possuía 543 linhas e concentrava em um único arquivo:

- composição da força de ataque, meio, defesa e goleiro;
- efeito das táticas;
- cálculo de posse;
- probabilidades por minuto;
- seleção de finalizador e assistente;
- geração de gols, chutes e defesas;
- faltas, amarelos e vermelhos;
- pênaltis e lesões;
- geração de trajetórias da bola;
- estatísticas finais;
- seed determinística da partida;
- orquestração completa dos 90 minutos.

O arquivo funcionava, mas qualquer evolução do simulador faria responsabilidades diferentes crescerem juntas.

## Nova arquitetura

```text
lib/game/match/engine/
├── match_engine.dart                    # fachada/orquestrador
├── match_strength_calculator.dart       # força por setor e efeitos táticos
├── match_probability_calculator.dart    # ameaça, posse e probabilidades
├── match_player_selector.dart           # finalizador, assistente e goleiro
├── match_event_generator.dart           # criação dos eventos estruturados
├── match_timeline_generator.dart        # fluxo dos 90 minutos
├── match_statistics_calculator.dart     # estatísticas derivadas da timeline
└── match_trajectory_generator.dart      # trajetórias de passe/chute/campo
```

### `MatchEngine`

Caiu de 543 para aproximadamente 110 linhas. Agora ele:

1. resolve a seed;
2. escolhe/atribui escalações;
3. calcula a força dos dois times;
4. calcula vantagem de mando;
5. solicita a timeline;
6. calcula as estatísticas;
7. monta o `MatchResult`.

Nenhuma tela ou widget foi colocado dentro do motor.

### `MatchStrengthCalculator`

Calcula força de ataque, meio-campo, defesa e goleiro a partir dos jogadores realmente escalados e mantém os modificadores de mentalidade, pressão e linha defensiva.

Também centraliza os fatores táticos usados para ritmo de gols e posse.

### `MatchProbabilityCalculator`

Concentra as fórmulas que transformam força, mando, cartões vermelhos, fadiga da partida e tática em probabilidades do minuto.

Isso permite calibrar futuramente a distribuição estatística sem misturar a fórmula com a criação visual/textual dos eventos.

### `MatchPlayerSelector`

Centraliza a escolha de:

- finalizador;
- assistente;
- jogador aleatório envolvido em falta/lesão/cartão;
- goleiro.

As posições continuam influenciando o peso para finalização.

### `MatchEventGenerator`

Cria lotes de eventos estruturados para:

- sequência de gol;
- chute e defesa;
- falta e cartão;
- vermelho direto;
- pênalti;
- lesão;
- posse/passe.

Ele retorna também os deltas de placar e expulsões para que a timeline não precise reinterpretar textos.

### `MatchTimelineGenerator`

Controla apenas o relógio e a ordem do jogo:

- kickoff;
- 90 minutos;
- intervalo;
- seleção do tipo de acontecimento com base nas probabilidades;
- aplicação dos deltas de gols/vermelhos;
- apito final.

### `MatchStatisticsCalculator`

Deriva posse, finalizações, finalizações no alvo, escanteios, faltas e cartões a partir dos eventos produzidos.

### `MatchTrajectoryGenerator`

Mantém coordenadas de passe, chute e pontos do campo fora das regras de probabilidade e seleção de jogadores. Essas coordenadas alimentam o renderer Flame, mas o Flame continua sem decidir o resultado.

## Compatibilidade funcional

A refatoração preserva:

- assinatura pública de `MatchEngine.simulate(...)`;
- seed determinística;
- ordem de consumo do `Random` durante a simulação;
- suporte a `startMinute`, `initialScore` e `prefixEvents` para mudanças táticas/substituições ao vivo;
- tipos e textos dos eventos existentes;
- cálculo de estatísticas existente;
- independência de Flutter e Flame.

A intenção desta entrega é estrutural. Não foram adicionadas novas probabilidades ou regras de futebol para não misturar refatoração com mudança de balanceamento.

## Testes adicionados

`test/match_engine_refactor_test.dart` verifica:

1. duas simulações com a mesma seed geram exatamente o mesmo resultado serializado;
2. posse final soma 100%;
3. o cálculo de força continua respondendo à mentalidade ofensiva em Dart puro.

Os testes anteriores de carreira, liga, serialização e controladores continuam no projeto.

## Próximo alvo

Depois de `flutter analyze`, `flutter test` e `flutter build apk --release` passarem no CI, o próximo trabalho recomendado é **validar o ciclo completo de uma temporada** antes de adicionar mais mecânicas.

A validação deve cobrir:

`nova carreira → escalação → tática → partida → classificação → mercado → rodada 38 → virada de temporada → save/load → temporada seguinte`.

## Disciplina em tempo real — 0.1.1.44

`MatchDisciplineTracker` passou a acompanhar amarelos e expulsões durante a geração da timeline. O segundo amarelo deve gerar um evento vermelho explícito (`MatchCardReason.secondYellow`) e retirar imediatamente o atleta das assignments disponíveis nos minutos seguintes. Vermelho direto usa o mesmo estado de expulsão.

Essa regra pertence ao Match Engine. `LiveMatchController` apenas impede uma substituição inválida de atleta já expulso e aplica os efeitos pós-jogo; `MatchPitchGame` apenas oculta visualmente o jogador associado ao evento vermelho. Não mover essa decisão para Flame ou para widgets.

## Transmissão, simulação e rodada ao vivo — 0.1.1.51

A duração Rápida/Normal/Completa altera somente o intervalo entre os minutos apresentados. A simulação na tela não chama o motor novamente: ela escolhe um ponto da `MatchResult.events`, limpa a fila visual e move o cursor de apresentação. Assim, placar e estatísticas continuam derivados da mesma timeline.

Os jogos de CPU da rodada são preparados por `LiveRoundSimulator`, que chama o `MatchEngine.simulate(...)` existente uma única vez para cada fixture. Esses resultados são revelados progressivamente no placar da rodada e reutilizados por `LiveMatchController.finishMatch()`, evitando divergência entre o alerta ao vivo e o resultado persistido.

O renderer Flame recebe somente timeline, IDs dos titulares e cores. `MatchCameraDirector` acompanha as coordenadas já calculadas, e replay/transmissão usam a mesma câmera 2D. Nenhuma regra de probabilidade, resultado, cartão, substituição ou estatística foi movida para Flame.
