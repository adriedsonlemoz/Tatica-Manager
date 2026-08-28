import '../../data/competition_catalog.dart';
import '../../domain/club/club.dart';
import '../../domain/match/match_models.dart';
import '../../domain/season/competition_state.dart';
import '../league/league_engine.dart';

/// Mantém progresso/classificação independentes por competição.
abstract final class CompetitionStateEngine {
  static CompetitionSeasonState rebuild({
    required CompetitionSeasonState state,
    required List<Club> clubs,
    required List<MatchFixture> fixtures,
  }) {
    final competitionFixtures = fixtures
        .where((fixture) => fixture.competitionId == state.competitionId)
        .toList(growable: false);
    final participants = state.participantClubIds.isNotEmpty
        ? state.participantClubIds.toSet()
        : <String>{
            for (final fixture in competitionFixtures) ...[
              fixture.homeClubId,
              fixture.awayClubId,
            ],
          };
    final competitionClubs = clubs
        .where((club) => participants.contains(club.id))
        .toList(growable: false);
    final definition = CompetitionCatalog.competitionByIdOrNull(
      state.competitionId,
    );
    final hasLeagueTable = definition?.format.hasLeagueTable ??
        state.standings.isNotEmpty;

    var completedRound = 0;
    final rounds = competitionFixtures.map((fixture) => fixture.round).toSet()
      ..removeWhere((round) => round <= 0);
    final orderedRounds = rounds.toList()..sort();
    for (final round in orderedRounds) {
      final roundFixtures = competitionFixtures.where(
        (fixture) => fixture.round == round,
      );
      if (roundFixtures.isNotEmpty &&
          roundFixtures.every((fixture) => fixture.played)) {
        completedRound = round;
      } else {
        break;
      }
    }

    final completed = competitionFixtures.isNotEmpty &&
        competitionFixtures.every((fixture) => fixture.played);
    final standings = hasLeagueTable
        ? LeagueEngine.rebuildStandings(competitionClubs, competitionFixtures)
        : const [];

    final participantClubIds = participants.toList(growable: false);
    var stages = state.stages;
    if (hasLeagueTable) {
      final mainStage = CompetitionStageState(
        id: 'main',
        kind: CompetitionStageKind.league,
        participantClubIds: participantClubIds,
        roundIndex: completedRound,
        standingsByGroup: {'main': standings},
        completed: completed,
      );
      stages = [
        for (final stage in state.stages)
          if (stage.id != 'main') stage,
        mainStage,
      ];
    }

    return state.copyWith(
      participantClubIds: participantClubIds,
      roundIndex: completedRound,
      standings: standings,
      stages: stages,
      completed: completed,
    );
  }

  static List<CompetitionSeasonState> rebuildAll({
    required List<CompetitionSeasonState> states,
    required List<Club> clubs,
    required List<MatchFixture> fixtures,
  }) =>
      states
          .map(
            (state) => rebuild(
              state: state,
              clubs: clubs,
              fixtures: fixtures,
            ),
          )
          .toList(growable: false);
}
