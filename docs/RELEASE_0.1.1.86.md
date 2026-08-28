# Release 0.1.1.86 — Correção do teste de substituições

## Causa real

O GitHub Actions da 0.1.1.85 chegou ao `flutter analyze` e encontrou um único erro em `test/live_substitution_pause_test.dart`: a expectativa que procurava o texto dinâmico de confirmação usava uma string Dart normal com `${plannedChanges.length}`. Como `plannedChanges` não existe no escopo do teste, o analyzer interrompia o pipeline com `undefined_identifier`.

## Correção

A expectativa passa a usar string raw (`r'...'`), de modo que `${plannedChanges.length}` seja tratado literalmente como texto procurado no arquivo `live_substitution_sheet.dart`.

## Escopo

Não houve alteração no código funcional do jogo. Permanecem intactos:

- preparação e confirmação de várias substituições em lote;
- limite de cinco substituições e três janelas;
- Home compacta da 0.1.1.85;
- `CareerState` schema 13, saves e IDs;
- fundação multi-competição, CPU, mercado, contratos e finanças;
- Match Engine e Flame.

## Validação

- `python3 tool/versioning.py verify` deve confirmar o versionamento sincronizado;
- o teste estrutural foi comparado diretamente com o conteúdo real de `live_substitution_sheet.dart`;
- `flutter analyze`, `flutter test` e `flutter build apk --release` ainda dependem do GitHub Actions neste ambiente sem Flutter/Dart.
