import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/data/club_seed.dart';
import 'package:tatica_manager/domain/career/manager_profile.dart';
import 'package:tatica_manager/domain/match/match_models.dart';
import 'package:tatica_manager/domain/season/career_state.dart';
import 'package:tatica_manager/game/career/career_factory.dart';
import 'package:tatica_manager/game/league/league_engine.dart';
import 'package:tatica_manager/game/season/season_engine.dart';

void main() {
  test('calendário e virada de temporada permanecem válidos até 2040', () {
    var career = CareerFactory.create(
      careerId: 'multi-season-calendar',
      careerName: 'Até 2040',
      manager: const ManagerProfile(displayName: 'Técnico Teste'),
      userClubId: clubSeeds.first.id,
      season: 2026,
      seed: 20260824,
    );

    while (career.season < 2040) {
      final completedBefore = career.seasonHistory.length;
      final report = LeagueEngine.validateSchedule(career.clubs, career.fixtures);
      expect(report.isValid, isTrue, reason: report.errors.join('\n'));
      expect(career.daysUntilNextMatch, 3);

      final completedFixtures = career.fixtures
          .map(
            (fixture) => fixture.copyWith(
              played: true,
              score: const MatchScore(0, 0),
            ),
          )
          .toList();
      final standings =
          LeagueEngine.rebuildStandings(career.clubs, completedFixtures);
      final lastUserFixture = completedFixtures
          .where(
            (fixture) =>
                fixture.homeClubId == career.userClubId ||
                fixture.awayClubId == career.userClubId,
          )
          .last;

      career = career.copyWith(
        roundIndex: 38,
        currentDate: lastUserFixture.date,
        fixtures: completedFixtures,
        standings: standings,
      );
      final completedSeason = career.season;
      career = SeasonEngine.advance(career);

      expect(career.roundIndex, 0);
      expect(career.seasonHistory, hasLength(completedBefore + 1));
      expect(career.seasonHistory.last.season, completedSeason);
      expect(career.managerHistory.last.season, career.season);
      expect(career.managerHistory.last.age, career.manager.ageInSeason(career.season));
      expect(career.currentDate.year, career.season);
      expect(career.daysUntilNextMatch, 3);
      expect(career.fixtures, hasLength(380));
      expect(career.matchHistory, isEmpty);
      expect(
        career.news.any((event) => event.id == 'season-started-${career.season}'),
        isTrue,
      );
      final squadIds = career.clubs
          .expand((club) => club.squad)
          .map((player) => player.id)
          .toSet();
      final freeAgentIds = career.freeAgents.map((player) => player.id).toSet();
      expect(squadIds.intersection(freeAgentIds), isEmpty);
      expect(
        career.clubs
            .expand((club) => club.squad)
            .every((player) => player.contract.endSeason >= career.season),
        isTrue,
      );
    }

    expect(career.season, 2040);
    expect(career.managerHistory, hasLength(15));
    expect(career.schemaVersion, CareerState.currentSchemaVersion);
  });
}
