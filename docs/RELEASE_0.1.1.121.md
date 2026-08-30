# Release 0.1.1.121 — Análise estática de Finanças corrigida

**pubspec:** `0.1.1+122`  
**Android versionCode:** `122`

## Correção

O `flutter analyze` da 0.1.1.120 avançou além do erro estrutural anterior e
apontou que `finances_screen.dart` utilizava `DashboardSectionHeader` sem
importar `management_dashboard_widgets.dart`, arquivo onde o widget
compartilhado é definido.

A tela agora importa explicitamente esse componente, eliminando o erro
`undefined_method` sem duplicar widget ou criar implementação paralela.

## Limpeza da análise estática

Também foram removidas duas asserções `!` redundantes em `FinanceForecastCard`.
O próprio fluxo já promove `projectedNet` para não nulo antes da expressão,
portanto as asserções não alteravam o comportamento e apenas geravam os dois
warnings `unnecessary_non_null_assertion` encontrados pelo CI.

## Escopo preservado

- Não altera cálculos, receitas, despesas, folha ou orçamento de transferências.
- Não altera Match Engine, resultados ou probabilidades.
- Não altera schema, saves, IDs ou persistência.
- Não cria sistema financeiro paralelo.
- Não altera regras de transferências, contratos, salários ou estádio.
