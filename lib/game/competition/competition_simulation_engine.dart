import '../../domain/match/match_models.dart';
import '../../domain/season/career_state.dart';
import '../../domain/season/competition_state.dart';
import '../../domain/season/league_loading.dart';
import '../league/cpu_fixture_resolver.dart';
import '../league/live_round_simulator.dart';
import '../lineup/lineup_engine.dart';
import '../match/match_career_impact_engine.dart';
import 'competition_state_engine.dart';

/// Resolve jogos exclusivamente CPU no calendário global da carreira.
///
/// Competições `full` continuam delegando o resultado ao MatchEngine por meio
/// de [CpuFixtureResolver]. Apenas `background` usa o resolvedor estatístico já
/// previsto pela configuração do save. Nenhuma apresentação Flame é criada.
abstract final class CompetitionSimulationEngine {
  static CareerState resolveCpuFixturesThroughDate(
    CareerState state, {
    required DateTime throughDate,
    bool protectUserFixtures = true,
  }) {
    final cutoff = _dateOnly(throughDate);
    final pending = state.fixtures
        .where(
          (fixture) =>
              !fixture.played &&
              !_dateOnly(fixture.date).isAfter(cutoff) &&
              state.leagueSetup.levelFor(fixture.competitionId) !=
                  LeagueLoadLevel.unloaded &&
              (!protectUserFixtures ||
                  (fixture.homeClubId != state.userClubId &&
                      fixture.awayClubId != state.userClubId)),
        )
        .toList(growable: false)
      ..sort(_compareFixtures);
    if (pending.isEmpty) return state;

    var clubs = [...state.clubs];
    var fixtures = [...state.fixtures];
    var competitionStates = [...state.competitionStates];

    for (final fixture in pending) {
      final homeIndex = clubs.indexWhere((club) => club.id == fixture.homeClubId);
      final awayIndex = clubs.indexWhere((club) => club.id == fixture.awayClubId);
      if (homeIndex < 0 || awayIndex < 0) continue;
      final home = clubs[homeIndex];
      final away = clubs[awayIndex];
      final competitionState = _stateFor(
        competitionStates,
        state,
        fixture.competitionId,
      );
      final suspended = competitionState.suspendedPlayerIds;
      final homeManager = LiveRoundSimulator.managerFor(state, home.id);
      final awayManager = LiveRoundSimulator.managerFor(state, away.id);
      final homeFormation = LiveRoundSimulator.formationFor(
        home,
        manager: homeManager,
      );
      final awayFormation = LiveRoundSimulator.formationFor(
        away,
        manager: awayManager,
      );
      final homeStarters = LineupEngine.autoSelect(
        home.squad,
        homeFormation,
        competitionSuspendedPlayerIds: suspended,
      );
      final awayStarters = LineupEngine.autoSelect(
        away.squad,
        awayFormation,
        competitionSuspendedPlayerIds: suspended,
      );
      final result = CpuFixtureResolver.resolve(
        level: state.leagueSetup.levelFor(fixture.competitionId),
        fixture: fixture,
        home: home,
        away: away,
        homeFormation: homeFormation,
        awayFormation: awayFormation,
        homeTactic: LiveRoundSimulator.tacticFor(home, manager: homeManager),
        awayTactic: LiveRoundSimulator.tacticFor(away, manager: awayManager),
        homeStarterIds: homeStarters,
        awayStarterIds: awayStarters,
        homeManagerOverall: homeManager?.overall ?? 70,
        awayManagerOverall: awayManager?.overall ?? 70,
      );

      fixtures = fixtures
          .map(
            (item) => item.id == fixture.id
                ? item.copyWith(played: true, score: result.score)
                : item,
          )
          .toList(growable: false);
      final impact = MatchCareerImpactEngine.apply(
        clubs: clubs,
        result: result,
        participantsByClub: {
          fixture.homeClubId: homeStarters.toSet(),
          fixture.awayClubId: awayStarters.toSet(),
        },
        startersByClub: {
          fixture.homeClubId: homeStarters.toSet(),
          fixture.awayClubId: awayStarters.toSet(),
        },
        competitionPlayerStats: competitionState.playerStats,
        competitionPlayerDiscipline: competitionState.playerDiscipline,
        mirrorCompetitionDisciplineToPlayer:
            fixture.competitionId == state.primaryCompetitionId,
      );
      clubs = impact.clubs;
      competitionStates = _replaceState(
        competitionStates,
        competitionState.copyWith(
          playerStats: impact.competitionPlayerStats,
          playerDiscipline: impact.competitionPlayerDiscipline,
        ),
      );
    }

    competitionStates = CompetitionStateEngine.rebuildAll(
      states: competitionStates,
      clubs: clubs,
      fixtures: fixtures,
    );
    return state.copyWith(
      clubs: clubs,
      fixtures: fixtures,
      competitionStates: competitionStates,
    );
  }

  static CompetitionSeasonState _stateFor(
    List<CompetitionSeasonState> states,
    CareerState career,
    String competitionId,
  ) =>
      states
          .where((item) => item.competitionId == competitionId)
          .firstOrNull ??
      career.competitionStateFor(competitionId);

  static List<CompetitionSeasonState> _replaceState(
    List<CompetitionSeasonState> states,
    CompetitionSeasonState updated,
  ) =>
      [
        for (final item in states)
          if (item.competitionId != updated.competitionId) item,
        updated,
      ];

  static int _compareFixtures(MatchFixture a, MatchFixture b) {
    final date = a.date.compareTo(b.date);
    if (date != 0) return date;
    final competition = a.competitionId.compareTo(b.competitionId);
    if (competition != 0) return competition;
    final round = a.round.compareTo(b.round);
    if (round != 0) return round;
    return a.id.compareTo(b.id);
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
