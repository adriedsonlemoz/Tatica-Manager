# Refatoração de controladores — build 0.1.0+3

Repositório oficial: `https://github.com/adriedsonlemoz/TaticaManager2`

Esta entrega reduz o acoplamento do estado principal do jogo antes de novas mecânicas serem adicionadas.

## Problema anterior

O `GameController` concentrava ao mesmo tempo:

- carreira ativa;
- escalação e tática;
- configurações;
- preparação e conclusão da partida ao vivo;
- substituições e mudanças táticas durante a partida;
- simulação dos demais jogos da rodada;
- compra e venda de jogadores;
- renovação de contratos;
- avanço de temporada.

Esse formato funcionava para o primeiro protótipo, mas faria o arquivo crescer continuamente e transformaria o controlador em um ponto único de acoplamento.

## Nova divisão

```text
app/state/
├── career_controller.dart       # ciclo de vida dos saves
├── game_controller.dart         # sessão da carreira e ações gerais
├── live_match_controller.dart   # estado temporário e fluxo da partida
├── transfer_controller.dart     # compras, vendas e renovações
└── providers.dart               # infraestrutura compartilhada
```

### `GameController`

Permanece como fonte da `CareerState` ativa e cuida apenas de ações gerais da carreira:

- anexar/desanexar carreira;
- persistir uma alteração consolidada;
- formação;
- tática;
- escalação;
- configurações;
- avanço de temporada;
- mensagens globais da sessão.

Ele expõe `commitCareer()` para que módulos especializados entreguem uma nova `CareerState` já validada e persistível, sem duplicar acesso ao banco.

### `LiveMatchController`

Possui estado temporário próprio (`LiveMatchSession`) e concentra:

- preparar a partida;
- re-simular a partir de uma mudança tática;
- realizar substituições;
- preservar o placar/eventos já ocorridos;
- simular os demais jogos da rodada;
- aplicar estatísticas, fadiga, cartões, lesões, moral e finanças da rodada;
- finalizar a rodada e entregar a carreira atualizada ao `GameController`.

O estado da partida é apagado ao concluir uma partida e também quando o usuário abre, cria, fecha ou exclui a carreira ativa. Assim uma sessão ao vivo nunca vaza para outro save.

### `TransferController`

Concentra:

- contratação de jogador de outro clube;
- contratação de agente livre;
- venda;
- renovação contratual;
- movimentações financeiras associadas;
- correção automática da escalação quando uma saída afeta os titulares.

As regras continuam em `TransferEngine`, `ContractEngine` e `LineupEngine`. O controlador apenas coordena o caso de uso e persiste o novo estado.

## Testes adicionados

`test/controller_refactor_test.dart` cobre dois pontos de regressão arquitetural:

1. a sessão da partida pode ser criada e descartada sem remover a carreira ativa;
2. uma contratação por `TransferController` modifica a carreira, remove o agente livre da lista e persiste a alteração.

## Próxima refatoração indicada

Depois que este build passar por `flutter analyze`, `flutter test` e `flutter build apk --release`, o maior candidato passa a ser o `MatchEngine`.

A próxima divisão deve separar cálculo de força, seleção de jogadores/eventos, geração de estatísticas e trajetórias, mantendo `MatchEngine` como orquestrador Dart puro.
