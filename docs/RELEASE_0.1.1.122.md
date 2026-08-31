# Release 0.1.1.122 — Limpeza final do analyzer em Finanças

**pubspec:** `0.1.1+123`  
**Android versionCode:** `123`

## Objetivo

Corrigir os três warnings restantes registrados no log 76 para permitir que a
etapa `flutter analyze --no-pub` avance no workflow, sem alterar o comportamento
funcional dos sistemas entregues anteriormente.

## Correções

- Remove as duas asserções de não-nulo (`!`) redundantes de `projectedNet` em
  `lib/features/finances/finances_dashboard_components.dart`. O valor já estava
  promovido para não nulo pelo fluxo de controle do Dart naquele bloco.
- Remove o widget privado `_FinanceExpansion` de
  `lib/features/finances/finances_screen.dart`, pois ele não possuía nenhuma
  referência após a reorganização compacta da tela de Finanças.

## Escopo preservado

- Nenhuma regra financeira, valor projetado, livro-caixa ou orçamento foi
  alterado.
- Compra, venda, renovação, contraproposta e empréstimo continuam passando pela
  Central de Negociações antes da conclusão.
- Contratos, salários, elenco, saves, schema da carreira, Estádio, calendário,
  resultados e Match Engine permanecem inalterados.
