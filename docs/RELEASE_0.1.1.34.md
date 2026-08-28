# Release 0.1.1.34 — Estabilização do CI da partida avançada

## Causa real do build anterior

O GitHub Actions da `0.1.1.33` validou versionamento, plataforma Android, ícones e `flutter pub get`, mas o job parou em `flutter analyze` com cinco apontamentos:

1. dois lints `prefer_initializing_formals` em `PlayerAvatar`;
2. referência a `Club.city`, getter que não existe no domínio atual;
3. uso de `FormationType.label` sem importar `domain/formation/formation.dart` no pré-jogo;
4. import não utilizado de `manager_profile.dart` em Configurações.

O run anterior ao da `0.1.1.33` havia falhado antes, em `tool/versioning.py verify`, por documentação fora de sincronia. Esse problema já estava resolvido no run mais recente e não era mais a causa ativa.

## Correções

- `PlayerAvatar` e `PlayerAvatar.identity` usam initializing formals compatíveis com o lint atual;
- o pré-jogo deixa de tentar exibir uma cidade que não existe em `Club`, mantendo data e estádio sem criar campo persistido artificialmente;
- o pré-jogo importa explicitamente `formation.dart`, disponibilizando `FormationTypeX.label`;
- Configurações remove o import não utilizado;
- teste de regressão do pré-jogo garante que a tela use apenas propriedades existentes do domínio e mantenha o import da formação.

## Escopo preservado

Nenhuma alteração foi feita em:

- `MatchEngine`;
- evento `woodwork`;
- replay;
- câmera;
- estádio/torcida;
- mergulho do goleiro;
- pênaltis;
- comemorações;
- `LiveMatchController`;
- regras de save, mercado, contratos ou finanças.

## Versionamento

- release/versionName: `0.1.1.34`;
- pubspec: `0.1.1+36`;
- Android versionCode: `36`.

## Validação local

O ambiente desta entrega não possui Flutter/Dart instalados. O versionamento e verificações Python são executados localmente; `flutter analyze`, `flutter test` e `flutter build apk --release` precisam ser confirmados no GitHub Actions.
