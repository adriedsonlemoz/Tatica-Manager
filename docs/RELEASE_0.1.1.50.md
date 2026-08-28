# Release 0.1.1.50 — Administração, Estádio e patrocinadores

**Android versionCode:** 52  
**pubspec:** `0.1.1+52`  
**CareerState schema:** 10

## Alterações

- Finanças passa a persistir seis orçamentos: transferências, salários, estrutura, categoria de base, estádio e outros departamentos.
- A distribuição não pode superar o caixa; o orçamento de transferências continua sincronizado com o campo já consumido pelo mercado.
- A tela mostra valores disponíveis e utilizados na temporada.
- O histórico financeiro fica clicável e detalha origem, valor, data, categoria, descrição e impacto.
- O preço do ingresso altera a demanda e a ocupação projetada.
- O Estádio permite editar nome e ingresso, ampliar arquibancadas, melhorar áreas comerciais, desbloquear estacionamento e museu e negociar o custo da obra.
- Toda obra desconta caixa e orçamento do Estádio e cria uma única movimentação financeira persistente.
- Patrocinadores passam a enviar propostas com valor, duração, bônus, objetivo, condições e prazo.
- O usuário pode aceitar, rejeitar ou contrapropor; contratos aceitos entram na receita por rodada.
- Naming rights altera o nome visível do estádio sem perder o nome original.
- Propostas comerciais chegam à Caixa de Entrada e abrem diretamente Finanças.

## Compatibilidade

O `CareerState` passa ao schema 10. O novo estado administrativo é opcional no JSON; saves da 0.1.1.49 recebem orçamentos compatíveis, contratos comerciais persistidos a partir da regra anterior e propostas novas sem alterar IDs de clube, jogador, partida ou negociação. Ao trocar de clube, orçamento e propostas são reinicializados para o novo empregador.

## Testes

Foram adicionadas regressões para save schema 9, seis orçamentos e limite de caixa, influência do ingresso na demanda, obra descontando caixa e orçamento, persistência, decisão comercial e naming rights. O ambiente da entrega não possui Flutter/Dart; `flutter analyze` e `flutter test` dependem do GitHub Actions. Nenhum APK foi gerado nesta entrega por solicitação do usuário.
