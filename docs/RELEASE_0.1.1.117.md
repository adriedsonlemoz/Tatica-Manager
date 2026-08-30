# Release 0.1.1.117 — Correção de consistência do Estádio

**pubspec:** `0.1.1+118`  
**Android versionCode:** `118`

## Motivo da correção

O GitHub Actions da 0.1.1.116 passou pelo `flutter analyze` sem problemas e executou 284 testes: 282 passaram e 2 falharam em `visual_navigation_consistency_test.dart`. As duas falhas eram de consistência da nova interface do Estádio, não do Match Engine nem do Android.

## Contraste do Estádio

`StadiumOverviewCard` volta a derivar o acento visual de `AppColors.readableAccent(Color(club.colors.primaryHex))`. O card usa esse acento em borda e métricas, e o ícone de condição usa `AppColors.foregroundOn(primary)` quando desenhado sobre a cor do clube. Isso mantém o novo design e evita contraste ruim com clubes de cores muito claras ou escuras.

## Caixa e orçamento das obras

`StadiumScreen` calcula o valor realmente disponível para obras como o menor valor entre o orçamento do departamento Estádio e o caixa do clube. O mesmo valor é usado pela lista de infraestrutura e pelo card de próxima melhoria sugerida.

Quando a melhoria sugerida não cabe nesse limite, o card fica sem ação e mostra `Saldo/orçamento insuficiente`, evitando apresentar como disponível uma obra que seria recusada no diálogo/engine.

## Escopo preservado

- manutenção persistente preservada;
- Centro de Treinamento preservado;
- obras com duração/status preservadas;
- imagens do estádio preservadas;
- Match Engine não alterado;
- músicas não alteradas;
- regras e resultados de partidas não alterados;
- `al-sistemas.json` continua ausente.
