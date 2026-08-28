# Release 0.1.1.38 — Correção do avatar do técnico

## Causa identificada no GitHub Actions

O workflow da `0.1.1.37` parou em `flutter analyze --no-pub` antes de executar testes e build. O erro era `missing_required_argument` em `lib/domain/career/manager_appearance.dart`: após a evolução dos avatares, `PlayerAvatarIdentity` passou a exigir `ageStyle`, mas a conversão da aparência do técnico ainda não fornecia esse campo.

## Correção

- `ManagerAppearance.toAvatarIdentity` passa a receber a idade do técnico e deriva `ageStyle` usando as mesmas faixas visuais já aplicadas aos jogadores;
- `ManagerAvatar` fornece `manager.ageAtStart` ao construir a identidade visual;
- foi adicionado teste de regressão garantindo as três faixas de idade e a estabilidade do seed visual;
- nenhum save, ID persistente, schema, áudio, TTS ou regra do Match Engine foi alterado.

## Versionamento

- release/versionName: `0.1.1.38`;
- pubspec: `0.1.1+40`;
- Android versionCode: `40`.

## Validação

`python3 tool/versioning.py sync` e `python3 tool/versioning.py verify` devem passar localmente. `flutter analyze`, `flutter test` e `flutter build apk --release` dependem de um ambiente com Flutter e devem ser confirmados pelo GitHub Actions antes de considerar a release validada integralmente.
