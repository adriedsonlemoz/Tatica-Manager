# Release 0.1.1.77

## Correção do GitHub Actions

O log `Flutter-Analisar-Testar-e-Gerar-APK-20-logs.zip` confirmou que a 0.1.1.76 passou por versionamento, plataforma Android, ícones e dependências, mas parou em `flutter analyze` antes de testes e build.

Os dois erros tinham a mesma causa em `lib/game/competition/competition_state_engine.dart`: o ramo de uma competição sem tabela retornava `const []`, inferido pelo Dart como `List<dynamic>`, enquanto `CompetitionSeasonState` e `CompetitionStageState` exigem `List<Standing>`.

A correção:

- importa explicitamente `Standing` no engine;
- declara o resultado como `List<Standing>`;
- usa `const <Standing>[]` no caminho sem classificação;
- adiciona teste de regressão para uma competição sem tabela;
- não altera `CareerState` schema 13, IDs, saves, calendário, CPU ou Match Engine.

## Validação

- `python3 tool/versioning.py verify` é executado localmente nesta entrega;
- Flutter/Dart não estão instalados neste ambiente, portanto `flutter pub get`, `flutter analyze`, `flutter test` e `flutter build apk --release` continuam dependentes do GitHub Actions e não são declarados como executados localmente.
