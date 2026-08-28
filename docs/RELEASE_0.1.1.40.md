# Release 0.1.1.40 — Estabilização dos testes visuais

## Causa identificada no GitHub Actions

A `0.1.1.39` passou integralmente por `flutter analyze --no-pub` e executou a suíte de testes. O CI registrou **163 testes aprovados e 2 falhas**:

1. `player_avatar_identity_test.dart` ainda exigia igualdade total da identidade após alterar a idade do jogador. Desde a `0.1.1.35`, `ageStyle` representa a idade aparente e deve evoluir por faixa etária, enquanto os traços faciais permanentes continuam derivados do `Player.id`. O teste estava desatualizado em relação ao comportamento intencional.
2. `app_info_test.dart` exige que **Sobre / Novidades** mantenha somente três releases. `AppInfo.recentReleases` havia acumulado seis entradas durante as microcorreções de CI, contrariando a regra já documentada desde a `0.1.1.6`.

## Correções

- o teste de avatar agora comprova separadamente que overall, condição e moral não alteram a identidade facial;
- foi adicionado teste explícito de envelhecimento visual: um mesmo `Player.id` mantém seed, pele, cabelo e todos os traços faciais, alterando somente `ageStyle` entre as faixas jovem e veterano;
- `AppInfo.recentReleases` voltou a conter exatamente as três versões mais recentes;
- nenhuma regra do Match Engine, áudio, narração TTS, save, ID persistente ou assinatura Android foi alterada.

## Versionamento

- release/versionName: `0.1.1.40`;
- pubspec: `0.1.1+42`;
- Android versionCode: `42`.

## Validação

`python3 tool/versioning.py sync` e `python3 tool/versioning.py verify` devem ser executados localmente. O ambiente desta entrega não contém Flutter/Dart, portanto `flutter pub get`, `flutter analyze`, `flutter test` e `flutter build apk --release` precisam ser confirmados pelo GitHub Actions.
