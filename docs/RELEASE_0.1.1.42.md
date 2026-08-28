# Release 0.1.1.42 — Correção do analyzer da Escalação

## Objetivo

Corrigir o único erro do `flutter analyze` revelado pelo GitHub Actions da 0.1.1.41, sem modificar comportamento funcional.

## Causa real

`lib/features/lineup/widgets/lineup_pitch.dart` usa `assignment.slot.role.label`. O getter `label` de `PlayerPosition` é fornecido pela extensão `PlayerPositionX`, declarada em `lib/domain/player/player.dart`, mas esse arquivo não estava importado no widget do campo.

## Correção

- adiciona `import '../../../domain/player/player.dart';` em `lineup_pitch.dart`;
- mantém inalterados `LineupEngine`, `GameController`, Match Engine, Flame, Autoescalação, OVR efetivo, substituições e persistência;
- não altera schema de save, IDs persistidos ou banco SQLite.

## Testes

Nenhum teste funcional precisou ser alterado: a falha ocorria durante análise estática antes da execução da suíte. Os testes adicionados na 0.1.1.41 permanecem intactos.

## Validação

Executado neste ambiente:

```bash
python3 tool/versioning.py verify
```

O ambiente local desta entrega não possui Flutter/Dart instalados. Portanto `flutter pub get`, `flutter analyze`, `flutter test` e `flutter build apk --release` ainda precisam ser executados pelo GitHub Actions.
