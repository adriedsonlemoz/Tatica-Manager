import '../../data/competition_catalog.dart';
import '../../domain/club/club.dart';
import '../../domain/match/match_models.dart';
import '../league/league_engine.dart';

/// Ponto único para geração automática de calendários por formato.
///
/// Não substitui o Match Engine. Apenas escolhe o gerador de fixtures. A base
/// atual suporta formatos de liga; mata-matas/grupos ficam explicitamente
/// bloqueados até suas regras reais serem implementadas, evitando calendários
/// genéricos incorretos para Copa do Brasil/Libertadores/etc.
abstract final class CompetitionScheduleEngine {
  static List<MatchFixture> generate({
    required CompetitionSeries competition,
    required List<Club> clubs,
    required int season,
  }) {
    switch (competition.format) {
      case CompetitionFormat.leagueDoubleRoundRobin:
        return LeagueEngine.generateDoubleRoundRobin(
          clubs,
          season: season,
          competitionId: competition.id,
          startDate: DateTime(
            season,
            competition.calendarStartMonth,
            competition.calendarStartDay,
          ),
        );
      case CompetitionFormat.leagueSingleRoundRobin:
        final complete = LeagueEngine.generateDoubleRoundRobin(
          clubs,
          season: season,
          competitionId: competition.id,
          startDate: DateTime(
            season,
            competition.calendarStartMonth,
            competition.calendarStartDay,
          ),
        );
        final firstLegRounds = clubs.length - 1;
        return complete
            .where((fixture) => fixture.round <= firstLegRounds)
            .toList(growable: false);
      case CompetitionFormat.knockout:
      case CompetitionFormat.groupAndKnockout:
      case CompetitionFormat.singleMatch:
        throw UnsupportedError(
          'A competição ${competition.id} exige regras de calendário próprias antes de ser ativada.',
        );
    }
  }
}
