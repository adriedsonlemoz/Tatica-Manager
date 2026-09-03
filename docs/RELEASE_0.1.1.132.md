# Release 0.1.1.132 — Correção do teste da simulação CPU

**Release visível:** `0.1.1.132`  
**Android versionCode:** `133`  
**pubspec:** `0.1.1+133`

## Resultado do log 85

- O `flutter analyze --no-pub` terminou sem problemas.
- 306 testes foram aprovados e somente um teste estrutural falhou.
- A falha exigia que `CpuFixtureResolver` ainda chamasse `BackgroundFixtureResolver.resolve`, contrato que deixou de ser válido na evolução de realismo da 0.1.1.130.

## Correção

- O teste agora confirma que `CpuFixtureResolver` usa o único `MatchEngine.simulate` e não retorna ao resolvedor agregado sem timeline.
- Também protege `autoSubstituteHome` e `autoSubstituteAway`, mantendo substituições automáticas nas partidas CPU.
- Código funcional, Match Engine, probabilidades, eventos, saves e interface permanecem inalterados.

Se esta release passar integralmente no CI, a etapa seguinte será implementar em conjunto as melhorias já analisadas para o campo da partida ao vivo.
