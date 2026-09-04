# Release 0.1.1.138 — Recompensas globais do Manager

## Resultado

Esta release adiciona Pontos de Manager (PM) como moeda global do jogador. PM não pertence a clube ou carreira e não participa de caixa, orçamento de transferências, salários ou qualquer cálculo financeiro existente.

## Fórmula implementada

Para cada partida competitiva oficialmente concluída e salva:

- conclusão: `+5 PM`;
- vitória: `+5 PM` adicionais;
- empate: `+2 PM` adicionais;
- derrota: sem bônus de resultado;
- terceira vitória da mesma sequência: `+10 PM`;
- quinta vitória da mesma sequência: `+20 PM`;
- 10 partidas competitivas globais: `+25 PM`;
- 25 partidas competitivas globais: `+60 PM`;
- 50 partidas competitivas globais: `+120 PM`.

No encerramento oficial da temporada:

- temporada concluída: `+80 PM`;
- objetivo final da diretoria cumprido: `+50 PM`;
- campeão da liga: `+150 PM`.

Os valores de promoção (`+100 PM`), copa (`+120 PM`) e conquista especial (`+20` a `+200 PM`) estão centralizados no domínio, mas não possuem gatilhos ativos porque a base atual ainda não oferece essas condições de forma completa. Partidas não competitivas estão configuradas inicialmente para não pagar PM; a política pode ser alterada para somente a recompensa base em `RewardRules`.

## Persistência e proteção contra duplicação

O banco SQLite passa à versão 5 e recebe estruturas globais independentes de `career_saves`:

- `pm_wallet`: saldo, total recebido e total utilizado;
- `reward_events`: chave única de cada evento já processado;
- `pm_transactions`: origem, quantidade, data, ID relacionado, carreira de origem e saldo após a operação;
- `pm_progress`: total global de partidas competitivas;
- `pm_career_progress`: sequência de vitórias por carreira;
- `pm_unlocks`: reserva persistente para conteúdos futuros.

A chave de recompensa de partida é `match:<careerId>:<fixtureId>`. Como o `fixtureId` já contém competição quando necessário, temporada, rodada e número do jogo, a composição também separa partidas iguais de carreiras diferentes. O fechamento da temporada usa `season:<careerId>:<season>`.

`LiveMatchController.finishMatch` bloqueia envios simultâneos. No repositório SQLite, salvar o próximo estado da carreira, registrar o evento, inserir o histórico, atualizar o progresso e alterar o saldo ocorre dentro da mesma transação. Se qualquer etapa falhar, nenhuma delas é confirmada. Se a chave já existir, não há novo crédito.

As sequências registram uma sequência numérica por carreira. Empate e derrota zeram as vitórias; os marcos 3 e 5 têm IDs próprios e são pagos uma única vez em cada sequência. Marcos globais e recompensas anuais também possuem IDs permanentes.

Excluir uma carreira remove somente o save pela regra já existente. A carteira e o histórico de PM permanecem. Criar outra carreira não reinicializa o perfil global. O saldo possui restrição de banco que impede valor negativo, e nenhuma tela escreve saldo diretamente.

## Interface

- A Home recebe apenas um chip compacto de saldo no cabeçalho, sem card adicional ou nova rolagem.
- A Central de Carreiras também mostra a carteira, deixando claro que o saldo existe fora dos saves.
- A nova tela Recompensas reúne saldo, sequência atual, desafios de partidas e histórico.
- O pós-jogo mostra o detalhamento da recompensa da partida e o saldo resultante.
- O aviso integrado usa “Recompensa concluída”. Quando o fechamento da temporada também confirma a meta anual da diretoria, usa “Objetivo concluído” e informa o bônus e o total do evento.
- A área de utilização de PM informa que conteúdos e personalizações ainda serão adicionados; não cria compras ou benefícios fictícios.

## Compatibilidade

A migração não concede PM retroativamente. Saves antigos não registravam quais recompensas haviam sido processadas, e inferir créditos pelo histórico permitiria divergências ou duplicação. A carteira começa em zero e passa a premiar somente eventos finalizados após a atualização.

O schema serializado de `CareerState` permanece 16. Match Engine, finanças, estádio, mercado, contratos, salários e orçamento dos clubes não foram alterados pelo cálculo de PM.

## Validação

Foram adicionados testes para a fórmula de vitória, empate e derrota; marcos de sequência; interrupção da sequência por empate; marcos globais; ausência de recompensa em partidas não competitivas; fechamento de temporada; IDs permanentes já pagos; chave única de evento; restrição de saldo e commit transacional com o save.

O ambiente usado para preparar esta entrega não inclui os executáveis Flutter/Dart. Por isso, a análise e os testes Flutter devem ser executados pelo workflow oficial antes da publicação do APK.
