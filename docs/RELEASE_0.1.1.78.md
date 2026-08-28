# Release 0.1.1.78

## Correção do GitHub Actions

O log `Flutter-Analisar-Testar-e-Gerar-APK-21-logs.zip` confirmou:

- versionamento da 0.1.1.77 válido;
- `flutter pub get` concluído;
- `flutter analyze --no-pub`: **No issues found**;
- 266 testes executados: **262 passaram e 4 falharam**;
- o build não foi iniciado porque a etapa de testes retornou erro.

Três testes (`multi_season_calendar_test`, `contract_lifecycle_test` e `season_history_test`) falhavam com `A temporada ainda não terminou.`. A causa era `CareerState.seasonComplete` confiar no flag persistido `CompetitionSeasonState.completed`, enquanto esses fluxos compatíveis com a arquitetura anterior marcavam todos os fixtures como disputados sem reconstruir antes esse flag.

A correção faz a conclusão da temporada derivar dos fixtures de cada competição carregada. O flag `completed` fica como fallback apenas quando uma competição carregada não possui fixtures persistidos. Isso mantém múltiplas competições independentes e evita bloquear saves/fluxos legados.

O quarto teste (`match_participation_fatigue_test`) não indicava perda funcional. A regra de fadiga, condição, titularidade e minutos foi extraída na fundação multi-competição para `MatchCareerImpactEngine`, mas o teste ainda procurava essas expressões em `LiveMatchController`. O teste foi atualizado para validar a delegação do controller e as regras no engine responsável, sem mover lógica de volta.

## Compatibilidade

- `CareerState` permanece no schema 13;
- nenhum ID persistente foi alterado;
- nenhuma migração SQLite nova foi necessária;
- calendário multi-competição e estados por `competitionId` permanecem;
- Match Engine não foi modificado;
- Flame continua somente visual.

## Validação local disponível

A release executa `python3 tool/versioning.py verify`. Flutter/Dart não estão instalados no ambiente local desta edição; portanto `flutter analyze`, `flutter test` e `flutter build apk --release` desta nova 0.1.1.78 dependem do próximo GitHub Actions. O log da 0.1.1.77, entretanto, confirmou que o analyzer estava limpo antes destas correções.
