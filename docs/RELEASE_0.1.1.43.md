# Release 0.1.1.43 — Teste visual do Elenco alinhado ao PlayerCard

## Objetivo

Corrigir o único teste restante revelado pelo GitHub Actions da 0.1.1.42, sem alterar comportamento funcional.

## Causa real

O redesign do Elenco da 0.1.1.41 substituiu o `PlayerRow` por `PlayerCard`. O teste
`player_avatar_identity_test.dart` ainda procurava literalmente `showAvatar: true` e
`showCondition: true` dentro de `squad_screen.dart`, parâmetros pertencentes à
implementação anterior.

A tela nova continua exibindo avatar: `SquadScreen` instancia `PlayerCard` e o
`PlayerCard` instancia `PlayerAvatar`.

## Correção

- atualiza o teste para verificar que `squad_screen.dart` usa `PlayerCard`;
- verifica que `player_card.dart` usa `PlayerAvatar`;
- verifica que o status do card permanece habilitado por padrão;
- mantém intactos Elenco, Escalação, Autoescalação, OVR efetivo, substituições,
  Match Engine, Flame, saves e IDs persistidos.

## Testes

O GitHub Actions da 0.1.1.42 executou 173 testes: **172 passaram e 1 falhou**.
A única falha era a expectativa textual obsoleta corrigida nesta release.

## Validação local

Executar nesta entrega:

```bash
python3 tool/versioning.py sync
python3 tool/versioning.py verify
```

O ambiente local não possui Flutter/Dart; `flutter analyze`, `flutter test` e
`flutter build apk --release` permanecem para o GitHub Actions.
