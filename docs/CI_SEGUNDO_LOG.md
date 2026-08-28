# CI — segundo log da Etapa 1

Data: 24/08/2026

## Resultado

- `flutter pub get`: passou
- `flutter analyze`: passou — `No issues found!`
- `flutter test`: falhou
- `flutter build apk --release`: não executado porque os testes interromperam o job

## Erro

Os dois testes tentavam criar uma carreira com:

```dart
CareerFactory.create(userClubId: 'aurora')
```

A seed atual não possui esse clube. Os IDs atuais seguem o padrão `br-*`, como `br-flamengo`, `br-palmeiras` etc.

Mensagem do CI:

```text
Invalid argument(s): Clube não encontrado: aurora
```

## Correção

Os testes passaram a usar:

```dart
clubSeeds.first.id
```

Assim eles usam um clube válido da própria fonte oficial de seed e deixam de depender de um identificador legado removido na reconstrução Flutter.
