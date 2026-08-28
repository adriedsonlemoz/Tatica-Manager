import '../../domain/season/career_state.dart';
import 'cpu_fixture_resolver.dart';
import 'league_engine.dart';

/// Keeps the competition calendar moving while the user is temporarily
/// without a club. It resolves only fixtures that are already in the past;
/// the match on the current date remains available if the manager accepts a
/// job that day.
abstract final class LeagueCatchUpEngine {
  static CareerState resolvePastFixtures(CareerState state) {
    if (state.fixtures.every((fixture) => fixture.played || !fixture.date.isBefore(state.currentDate))) {
      return state;
    }

    var fixtures = [...state.fixtures];
    final pendingPast = fixtures
        .where(
          (fixture) => !fixture.played && fixture.date.isBefore(state.currentDate),
        )
        .toList()
      ..sort((a, b) {
        final byDate = a.date.compareTo(b.date);
        return byDate != 0 ? byDate : a.round.compareTo(b.round);
      });

    for (final fixture in pendingPast) {
      final home = state.clubs.firstWhere((club) => club.id == fixture.homeClubId);
      final away = state.clubs.firstWhere((club) => club.id == fixture.awayClubId);
      final result = CpuFixtureResolver.resolve(
        level: state.leagueSetup.levelFor(fixture.competitionId),
        fixture: fixture,
        home: home,
        away: away,
      );
      fixtures = fixtures
          .map(
            (item) => item.id == fixture.id
                ? item.copyWith(played: true, score: result.score)
                : item,
          )
          .toList(growable: false);
    }

    var completedRounds = state.roundIndex;
    final primaryCompetitionId = state.primaryCompetitionId;
    final rounds = fixtures
        .where((fixture) => fixture.competitionId == primaryCompetitionId)
        .map((fixture) => fixture.round)
        .toSet()
        .toList()
      ..sort();
    for (final round in rounds) {
      final roundFixtures = fixtures.where(
        (fixture) =>
            fixture.competitionId == primaryCompetitionId &&
            fixture.round == round,
      );
      if (roundFixtures.isNotEmpty && roundFixtures.every((fixture) => fixture.played)) {
        if (round > completedRounds) completedRounds = round;
      }
    }

    return state.copyWith(
      roundIndex: completedRounds,
      fixtures: fixtures,
      standings: LeagueEngine.rebuildStandings(
        state.clubsForPrimaryCompetition(),
        fixtures
            .where(
              (fixture) => fixture.competitionId == primaryCompetitionId,
            )
            .toList(growable: false),
      ),
    );
  }
}
