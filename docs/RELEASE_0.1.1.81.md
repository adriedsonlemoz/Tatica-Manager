# Release 0.1.1.81 — Correção de sintaxe da Home

## Causa real

O GitHub Actions da 0.1.1.80 parou em `flutter analyze` com 33 issues. A origem era única: a classe `_HomeBackdrop`, introduzida na revisão visual da Home, terminava o método `build` com `);`, mas não fechava a própria classe antes da declaração de `_DayAdvanceTransition`.

Como consequência, o analyzer interpretava `_DayAdvanceTransition` e `_UnemployedHome` como classes declaradas dentro de outra classe, gerando uma cascata de `class_in_class`, `expected_class_member`, `undefined_method` e erros derivados.

## Correção

- fecha `_HomeBackdrop` corretamente em `home_screen.dart`;
- adiciona teste estrutural que verifica que `_DayAdvanceTransition` começa somente depois do fechamento da classe de backdrop;
- mantém exatamente o layout, os dois assets WebP e os dados reais da Home da 0.1.1.80.

## Compatibilidade

Não há alteração de schema, persistência ou gameplay. Permanecem preservados `CareerState` schema 13, saves, IDs, fundação multi-competição, CPU, mercado, contratos, finanças, Match Engine e Flame somente visual.

## Validação

`python3 tool/versioning.py verify` é executado nesta entrega. Como Flutter/Dart não estão instalados no ambiente local, `flutter analyze`, `flutter test` e `flutter build apk --release` ainda dependem do GitHub Actions.
