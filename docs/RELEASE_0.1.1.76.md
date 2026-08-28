# Release 0.1.1.76

## Fundação multi-competição

- `CareerState.currentSchemaVersion` passa para **13** e persiste `CompetitionSeasonState` por `competitionId`;
- cada competição mantém participantes, progresso/rodada, classificação, estatísticas de jogadores, disciplina e fases próprias;
- `CareerState.fixtures` permanece como calendário global da temporada para permitir que o mesmo clube dispute vários torneios sem calendários isolados;
- `primaryCompetitionId`, `standings` e `roundIndex` legados continuam como espelho da competição principal, preservando telas e saves existentes durante a transição;
- saves schema 12 são promovidos em memória sem trocar IDs de clubes, jogadores, técnicos ou fixtures.

## Calendário e formatos

- adiciona `CompetitionCalendarEngine` para conciliar conflitos de datas entre competições carregadas;
- adiciona `CompetitionScheduleEngine` como ponto único de geração por formato, mantendo apenas os formatos de liga realmente implementados;
- fixtures passam a persistir `stageId`, `groupId`, `tieId` e `leg`, preparando grupos, mata-mata e ida/volta sem alterar novamente o formato básico do jogo;
- os IDs históricos da Série A (`2026-r1-m1`, por exemplo) são preservados; novas competições usam o `competitionId` como prefixo para evitar colisões;
- o catálogo passa a reservar uma coleção separada para futuras competições internacionais, evitando encaixar Libertadores, Sul-Americana ou Mundial artificialmente dentro de um país.

## Partidas, CPU e Match Engine

- o **Match Engine não foi substituído nem reescrito**: continua recebendo fixture, clubes, escalações e táticas e devolvendo `MatchResult`;
- a aplicação do resultado à carreira foi isolada em `MatchCareerImpactEngine`, separando efeitos globais do atleta de estatísticas e disciplina da competição;
- `CompetitionSimulationEngine` resolve cronologicamente jogos exclusivamente CPU até a data da carreira;
- competições `full` continuam usando o Match Engine atual; `background` usa apenas o resolvedor estatístico leve já existente;
- Flame permanece exclusivamente na apresentação visual.

## Estatísticas e disciplina

- artilharia, assistências, cartões, ranking de técnicos e classificação podem consultar a competição selecionada;
- um jogador pode acumular números diferentes em Brasileiro, estadual e copa sem misturar as tabelas de cada torneio;
- suspensões ficam separadas por competição, enquanto lesão, condição, fadiga, moral e os totais globais da temporada continuam pertencendo ao atleta;
- escalação e pré-jogo consultam a suspensão da competição da próxima partida.

## Temporada e carreira do técnico

- a temporada seguinte reconstrói individualmente os estados das competições carregadas;
- o fim da temporada considera todas as competições carregadas que possuem estado no save;
- o mercado de trabalho do técnico deixa de oferecer, inclusive no fallback, clubes cuja liga não esteja carregada;
- ao assumir um clube de outra liga já carregada, essa liga pode se tornar a competição principal sem reconstruir o save; ligas `unloaded` continuam sem ativação no meio da carreira.

## Correções do GitHub Actions

O log `Flutter-Analisar-Testar-e-Gerar-APK-19-logs.zip` mostrou que o pipeline parava no `flutter analyze`, antes de testes/build. A causa era `AppColors.text` inexistente em `league_selection_step.dart`, que também tornava o `TextStyle` constante inválido. O valor foi corrigido para uma cor existente no tema e o lint de aspas do teste foi ajustado.

## Validação

- `python3 tool/versioning.py verify` deve validar `0.1.1.76` / Android versionCode `78` após a sincronização;
- testes de fundação cobrem migração schema 12 -> 13, preservação de IDs, classificações independentes, calendário concorrente, estatísticas/suspensões por competição e metadados de fase;
- Flutter/Dart não estão instalados no ambiente de edição desta entrega, portanto `flutter pub get`, `flutter analyze`, `flutter test` e `flutter build apk --release` ficam para o GitHub Actions/aparelho e **não são declarados como executados localmente**.
