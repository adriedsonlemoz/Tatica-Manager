import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/data/club_seed.dart';
import 'package:tatica_manager/domain/career/manager_profile.dart';
import 'package:tatica_manager/domain/match/match_models.dart';
import 'package:tatica_manager/game/career/career_factory.dart';
import 'package:tatica_manager/game/league/league_engine.dart';
import 'package:tatica_manager/game/season/season_engine.dart';

void main() {
  test('resumo final é preservado no histórico ao virar temporada', () {
    var career = CareerFactory.create(
      careerId: 'history-test',
      careerName: 'Histórico',
      manager: const ManagerProfile(displayName: 'Teste'),
      userClubId: clubSeeds.first.id,
      season: 2026,
    );

    final completedFixtures = career.fixtures
        .map(
          (fixture) => fixture.copyWith(
            played: true,
            score: const MatchScore(0, 0),
          ),
        )
        .toList();
    final standings = LeagueEngine.rebuildStandings(
      career.clubs,
      completedFixtures,
    );
    final finalDate = completedFixtures
        .where(
          (fixture) =>
              fixture.homeClubId == career.userClubId ||
              fixture.awayClubId == career.userClubId,
        )
        .last
        .date;
    career = career.copyWith(
      roundIndex: 38,
      currentDate: finalDate,
      fixtures: completedFixtures,
      standings: standings,
    );

    final summary = SeasonEngine.summaryFor(career);
    final next = SeasonEngine.advance(career);

    expect(summary.season, 2026);
    expect(summary.clubId, career.userClubId);
    expect(summary.wins + summary.draws + summary.losses, 38);
    expect(next.season, 2027);
    expect(next.seasonHistory, hasLength(1));
    expect(next.seasonHistory.single.season, summary.season);
    expect(next.seasonHistory.single.position, summary.position);
    expect(next.seasonHistory.single.points, summary.points);
    expect(next.managerHistory, hasLength(2));
    expect(next.managerHistory.first.season, 2026);
    expect(next.managerHistory.last.season, 2027);
    expect(next.managerHistory.last.age, next.manager.ageInSeason(2027));
  });
}
