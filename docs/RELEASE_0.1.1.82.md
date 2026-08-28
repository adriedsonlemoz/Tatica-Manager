# Release 0.1.1.82 — Correção do teste estrutural da Home

## Causa real

O GitHub Actions da 0.1.1.81 passou pelo `flutter analyze` e executou 267 testes. **266 passaram e apenas 1 falhou**.

A falha estava em `calendar_and_standings_ui_test.dart`: o teste procurava `Departamento\nMédico` usando uma string Dart comum. Durante a execução, `\n` era interpretado como uma quebra de linha real, enquanto o arquivo `home_screen.dart` contém corretamente os dois caracteres de escape `\` + `n` dentro do literal Flutter.

## Correção

- altera somente a expectativa do teste para uma string raw (`r"..."`);
- preserva o rótulo da Home e toda a implementação visual da 0.1.1.81;
- não altera código funcional do jogo.

## Compatibilidade

Permanecem intactos `CareerState` schema 13, saves, IDs persistentes, calendário e fundação multi-competição, CPU, mercado, contratos, finanças, Match Engine e Flame somente visual.

## Validação

O versionamento é sincronizado e verificado localmente. Flutter/Dart não estão instalados neste ambiente, portanto o novo `flutter test`, `flutter analyze` e `flutter build apk --release` ainda dependem do GitHub Actions.
