# Release 0.1.1.116 — Estádio imersivo e três novos sistemas

**pubspec:** `0.1.1+117`  
**Android versionCode:** `117`

## Objetivo

Aplicar ao jogo o design de Estádio aprovado pelo usuário e criar a base funcional dos três sistemas que antes não existiam: manutenção, Centro de Treinamento e obras com duração/status.

## Interface do Estádio

- cabeçalho simples `Estádio` com retorno;
- card do clube com escudo, temporada, saldo e orçamento de transferências;
- visão geral usando `assets/images/stadium/stadium_night.webp`;
- capacidade, público projetado, preço do ingresso e condição geral;
- cards lado a lado para Receita de Bilheteria e Manutenção;
- cards lado a lado para Centro de Treinamento e Melhorias;
- card `Próxima melhoria sugerida` usando `assets/images/stadium/covered_stands.webp`;
- usa Material Icons existentes, sem dependência visual nova.

## Sistema de manutenção

O estádio passa a persistir quatro condições de 0 a 100: Gramado, Estrutura, Segurança e Conforto. O avanço de dias produz desgaste gradual e determinístico. A ação de manutenção usa o orçamento do departamento Estádio, gera uma transação `stadiumInvestment` e restaura as quatro condições.

## Centro de Treinamento

O `Stadium` passa a persistir `trainingCenterLevel` de 1 a 5. A qualidade exibida é derivada do nível. Melhorias do CT usam orçamento real e entram no mesmo sistema de obras com prazo, sem aplicar o novo nível imediatamente. Nesta primeira base não foram inventados bônus de desenvolvimento de jogadores; esse efeito pode ser lapidado depois.

## Obras com duração e status

`StadiumProject` persiste tipo da obra, nível-alvo, custo, data de início, data de conclusão e status. `upgradeStadium` deixa de aplicar a melhoria na hora: paga e registra a obra; `StadiumEngine.advanceDay` aplica o nível somente quando a data de conclusão é alcançada. Obras concluídas permanecem no histórico.

## Retrocompatibilidade

Saves antigos continuam válidos: as novas condições recebem padrões seguros, o CT inicia no nível 1 e o histórico de obras inicia vazio. Não foi necessário alterar o schema global da carreira.

## Escopo preservado

- Match Engine não alterado;
- músicas não alteradas;
- regras/resultados de partidas não alterados;
- IDs existentes não alterados;
- `al-sistemas.json` continua ausente.
