import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/data/club_seed.dart';
import 'package:tatica_manager/domain/career/manager_profile.dart';
import 'package:tatica_manager/domain/season/career_state.dart';
import 'package:tatica_manager/game/career/career_factory.dart';
import 'package:tatica_manager/game/season/calendar_engine.dart';

void main() {
  test('nova carreira começa três dias antes da primeira partida', () {
    final career = _career();
    final fixture = career.nextUserFixture!;

    expect(fixture.date.difference(career.currentDate).inDays, 3);
    expect(career.daysUntilNextMatch, 3);
    expect(career.isMatchDay, isFalse);
  });

  test('calendário avança exatamente um dia até a data da partida', () {
    var career = _career();

    career = CareerCalendarEngine.advanceDay(career);
    expect(career.daysUntilNextMatch, 2);
    career = CareerCalendarEngine.advanceDay(career);
    expect(career.daysUntilNextMatch, 1);
    career = CareerCalendarEngine.advanceDay(career);

    expect(career.daysUntilNextMatch, 0);
    expect(career.isMatchDay, isTrue);
    expect(
      () => CareerCalendarEngine.advanceDay(career),
      throwsStateError,
    );
  });
}

CareerState _career() => CareerFactory.create(
      careerId: 'season-calendar',
      careerName: 'Calendário',
      manager: const ManagerProfile(displayName: 'Técnico Teste'),
      userClubId: clubSeeds.first.id,
      seed: 20260824,
    );
