# Release 0.1.1.121 — Correção do build de Finanças e Transferências

**pubspec:** `0.1.1+122`  
**Android versionCode:** `122`

## Objetivo

Corrigir a falha de análise estática registrada no log 75 sem desfazer ou
reestruturar os sistemas de Transferências, Finanças e Contratos entregues na
release anterior.

## Correções

- Corrige o fechamento de `FinanceBalanceOverview` em
  `lib/features/finances/finances_dashboard_components.dart`. A classe estava
  sem a chave de encerramento do `build`, fazendo o analyzer interpretar os
  componentes seguintes como classes internas e gerar centenas de erros em
  cascata.
- Adiciona o import explícito de `CareerState` em
  `lib/features/finances/finances_screen.dart`.
- Adiciona `domain/transfer/transfer.dart` aos imports de `market_screen.dart`,
  disponibilizando `TransferOperationResult` ao arquivo `part`
  `market_components.dart`.
- Substitui a cascade desnecessária usada apenas para ordenar jogadores em
  `contracts_screen.dart`, removendo o aviso independente restante do log.

## Escopo preservado

- Nenhuma regra de proposta, contraproposta, conclusão, venda, compra,
  empréstimo ou renovação foi alterada.
- Orçamento de transferências, caixa, parcelas, luvas, contratos, salários,
  elenco e `FinanceTransaction` continuam usando a mesma integração persistida
  da release 0.1.1.120.
- Schema da carreira, saves, Match Engine, calendário, resultados, Estádio e
  regras de partida não foram modificados.
