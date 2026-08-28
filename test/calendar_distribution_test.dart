import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/data/club_seed.dart';
import 'package:tatica_manager/domain/career/manager_profile.dart';
import 'package:tatica_manager/game/career/career_factory.dart';
import 'package:tatica_manager/game/league/league_engine.dart';

void main() {
  test('calendário distribui rodadas em diferentes dias com descanso mínimo', () {
    final career = CareerFactory.create(
      careerId: 'calendar-distribution',
      careerName: 'Calendário',
      manager: const ManagerProfile(displayName: 'Técnico'),
      userClubId: clubSeeds.first.id,
    );

    final userFixtures = career.fixtures
        .where(
          (fixture) =>
              fixture.homeClubId == career.userClubId ||
              fixture.awayClubId == career.userClubId,
        )
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    expect(userFixtures, hasLength(38));
    expect(
      userFixtures.map((fixture) => fixture.date.weekday).toSet().length,
      greaterThanOrEqualTo(4),
    );
    expect(userFixtures.every((fixture) => fixture.competitionId == 'br-series-a'), isTrue);
    expect(userFixtures.every((fixture) => fixture.kickoffHour >= 0 && fixture.kickoffHour <= 23), isTrue);

    for (var index = 1; index < userFixtures.length; index++) {
      final gap = userFixtures[index].date.difference(userFixtures[index - 1].date).inDays;
      expect(gap, greaterThan(LeagueEngine.minimumRestDays));
    }
  });

  test('gerador aceita identidade e cadência de competição futura', () {
    final clubs = clubSeeds.take(8).map((seed) => seed.toClub()).toList();
    final fixtures = LeagueEngine.generateDoubleRoundRobin(
      clubs,
      season: 2026,
      competitionId: 'future-cup',
      roundGapDays: const [4, 5, 6],
    );

    expect(fixtures, isNotEmpty);
    expect(fixtures.every((fixture) => fixture.competitionId == 'future-cup'), isTrue);
    final rounds = fixtures.map((fixture) => fixture.round).toSet().toList()..sort();
    for (var index = 1; index < rounds.length; index++) {
      final previous = fixtures.firstWhere((fixture) => fixture.round == rounds[index - 1]).date;
      final current = fixtures.firstWhere((fixture) => fixture.round == rounds[index]).date;
      expect(current.difference(previous).inDays, greaterThan(LeagueEngine.minimumRestDays));
    }
  });
}
