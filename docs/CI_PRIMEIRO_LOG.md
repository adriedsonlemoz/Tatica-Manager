# CI — primeira execução no GitHub Actions

Data analisada: 24/08/2026

Repositório: `https://github.com/adriedsonlemoz/TaticaManager2`

## Resultado

O workflow instalou Java 21 e Flutter 3.47.0, criou as plataformas Android/iOS, resolveu as dependências e chegou até `flutter analyze`. A falha ocorreu na análise estática, antes dos testes e do build do APK.

O log registrou 35 apontamentos. Os erros bloqueantes eram:

- `Icons.contract_rounded` inexistente;
- `Icons.strategy_outlined` e `Icons.strategy_rounded` inexistentes;
- chamadas de `LeagueEngine.generateDoubleRoundRobin` sem o parâmetro nomeado obrigatório `season:`;
- `test/widget_test.dart` criado pelo template do Flutter referenciando a classe padrão `MyApp`, que não existe neste projeto;
- `MatchPitchGame.render` sem chamar `super.render(canvas)`.

Também havia avisos/lints sobre imports e variáveis não usados, chaves em estruturas de controle, interpolação e uso de `BuildContext` após `await`.

## Correções aplicadas

- contratos passaram a usar `Icons.description_rounded`;
- atalhos de escalação passaram a usar `Icons.sports_soccer_*`;
- calendário agora chama `generateDoubleRoundRobin(..., season: ...)`;
- workflow e bootstrap removem somente o `widget_test.dart` padrão quando ele contém `MyApp`;
- `MatchPitchGame.render` chama `super.render(canvas)`;
- lints observados no primeiro log foram corrigidos;
- GitHub Actions atualizado para `actions/checkout@v5` e `actions/setup-java@v5`.

## Próxima validação

A Etapa 1 só deve ser concluída quando uma nova execução obtiver sucesso em:

1. `flutter analyze`
2. `flutter test`
3. `flutter build apk --release`
4. upload de `build/app/outputs/flutter-apk/app-release.apk` como Artifact.
