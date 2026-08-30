# Release 0.1.1.120 — Correção da compilação de Finanças

**pubspec:** `0.1.1+121`  
**Android versionCode:** `121`

## Correção

O `flutter analyze` da 0.1.1.119 falhava porque `FinanceBalanceOverview` não
era encerrada depois do método `build()`. Com isso, o Dart interpretava
`FinanceBalanceChart`, `FinanceMonthlyBalancePainter` e todos os componentes
seguintes como declarações internas da classe anterior, gerando uma sequência
de erros derivados.

A correção adiciona apenas o fechamento estrutural ausente, preservando o
comportamento e as integrações financeiras já implementadas.

## Teste preventivo

`AppInfo.recentReleases` também foi ajustado para manter exatamente três
releases (`0.1.1.120`, `0.1.1.119` e `0.1.1.118`), conforme o contrato existente
em `test/app_info_test.dart`. Isso evita que o CI passe da análise estática e
falhe imediatamente na etapa seguinte de testes.

## Escopo preservado

- Não altera Match Engine, resultados ou probabilidades.
- Não altera schema, saves, IDs ou persistência.
- Não cria sistema financeiro paralelo.
- Não altera regras de transferências, contratos, salários ou estádio.
