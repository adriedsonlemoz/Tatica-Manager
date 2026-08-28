# Release 0.1.1.67

## Escopo

Release corretiva baseada no log real do GitHub Actions da 0.1.1.66. O CI parou em `flutter analyze`, portanto esta entrega corrige somente os três erros e os dois warnings exibidos pelo analyzer, sem ampliar o escopo visual.

## Causa real

- `LiveMatchController` tinha um segundo encadeamento `.where(...).length` solto imediatamente depois de `previousSubstitutions.length;`, produzindo `dot_shorthand_undefined_member`.
- `match_day_presentation_screen.dart` usava `career.tactic.pressing.label` e `career.formation.label` sem importar os arquivos que declaram as extensões `PressingX` e `FormationTypeX`.
- Finanças mantinha um import e uma variável local sem uso, ambos reportados como warnings pelo analyzer.

## Correções

- Mantém `previousSubstitutions` como a única lista filtrada e usa diretamente seu `length` para contar substituições.
- Importa explicitamente `domain/tactic/tactic.dart` e `domain/formation/formation.dart` no Dia de Jogo.
- Remove o import não utilizado de `finance.dart` em `finances_dashboard_components.dart`.
- Remove a variável local `budget` sem uso em `finances_screen.dart`.

## Arquitetura e compatibilidade

- Nenhuma regra foi movida para Flame.
- O Match Engine não foi alterado.
- `CareerState` permanece no schema 11.
- Saves, IDs persistentes e o visual da 0.1.1.66 permanecem compatíveis.

## Validação

- A correção foi comparada diretamente com os cinco diagnósticos do log do GitHub Actions.
- `python3 tool/versioning.py verify` deve permanecer obrigatório antes do empacotamento.
- `flutter analyze`, `flutter test` e `flutter build apk --release` dependem de um ambiente com Flutter SDK ou do GitHub Actions.
