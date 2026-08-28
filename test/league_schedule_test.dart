import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/data/club_seed.dart';
import 'package:tatica_manager/domain/career/manager_profile.dart';
import 'package:tatica_manager/game/career/career_factory.dart';
import 'package:tatica_manager/game/league/league_engine.dart';

void main() {
  test('liga inicial possui 20 clubes, 38 rodadas e 380 partidas', () {
    final career = CareerFactory.create(
      careerId: 'test-career',
      careerName: 'Teste',
      manager: const ManagerProfile(displayName: 'Técnico Teste'),
      userClubId: clubSeeds.first.id,
    );

    expect(career.clubs, hasLength(20));
    expect(career.fixtures, hasLength(380));
    expect(career.fixtures.map((fixture) => fixture.round).toSet(), hasLength(38));

    final report = LeagueEngine.validateSchedule(career.clubs, career.fixtures);
    expect(report.isValid, isTrue, reason: report.errors.join('\n'));
    expect(report.rounds, 38);
    expect(report.matches, 380);

    for (var round = 1; round <= 38; round++) {
      final fixtures = career.fixtures.where((fixture) => fixture.round == round).toList();
      expect(fixtures, hasLength(10));
      final clubIds = <String>[];
      for (final fixture in fixtures) {
        clubIds
          ..add(fixture.homeClubId)
          ..add(fixture.awayClubId);
      }
      expect(clubIds.toSet(), hasLength(20));
    }

    final userFixtures = career.fixtures
        .where((fixture) =>
            fixture.homeClubId == career.userClubId ||
            fixture.awayClubId == career.userClubId)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    expect(
      userFixtures.map((fixture) => fixture.date.weekday).toSet().length,
      greaterThanOrEqualTo(4),
    );
    for (var index = 1; index < userFixtures.length; index++) {
      final gap = userFixtures[index].date
          .difference(userFixtures[index - 1].date)
          .inDays;
      expect(gap, greaterThan(LeagueEngine.minimumRestDays));
    }
  });
}
