import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/data/club_seed.dart';
import 'package:tatica_manager/domain/career/manager_profile.dart';
import 'package:tatica_manager/domain/formation/formation.dart';
import 'package:tatica_manager/domain/match/match_models.dart';
import 'package:tatica_manager/domain/season/career_state.dart';
import 'package:tatica_manager/domain/tactic/tactic.dart';
import 'package:tatica_manager/game/career/career_factory.dart';
import 'package:tatica_manager/game/lineup/lineup_engine.dart';
import 'package:tatica_manager/game/match/engine/match_engine.dart';
import 'package:tatica_manager/game/match/engine/match_strength_calculator.dart';

void main() {
  test('MatchEngine continua determinístico quando a seed é fixa', () {
    final career = _career();
    final fixture = career.fixtures.first;
    final home = career.clubs.firstWhere(
      (club) => club.id == fixture.homeClubId,
    );
    final away = career.clubs.firstWhere(
      (club) => club.id == fixture.awayClubId,
    );

    final first = MatchEngine.simulate(
      fixture: fixture,
      home: home,
      away: away,
      seed: 20260824,
    );
    final second = MatchEngine.simulate(
      fixture: fixture,
      home: home,
      away: away,
      seed: 20260824,
    );

    expect(second.toJson(), equals(first.toJson()));
    expect(
      first.events.any(
        (event) => event.type == MatchEventType.halftime && event.minute == 45,
      ),
      isTrue,
    );
    expect(first.events.last.type, MatchEventType.fulltime);
    expect(first.events.last.minute, 90);
    expect(
      first.statistics.homePossession + first.statistics.awayPossession,
      100,
    );
  });

  test('cálculo de força reage à mentalidade sem depender do Flutter', () {
    final career = _career();
    final club = career.userClub;
    final starters = LineupEngine.autoSelect(
      club.squad,
      FormationType.f433,
    );
    final assignments = LineupEngine.assign(
      club.squad,
      starters,
      FormationType.f433,
    );

    final balanced = MatchStrengthCalculator.calculate(
      assignments,
      const Tactic(),
    );
    final attacking = MatchStrengthCalculator.calculate(
      assignments,
      const Tactic(mentality: Mentality.attacking),
    );

    expect(attacking.attack, greaterThan(balanced.attack));
    expect(attacking.defense, lessThan(balanced.defense));
  });
}

CareerState _career() => CareerFactory.create(
      careerId: 'match-engine-refactor',
      careerName: 'Engine Test',
      manager: const ManagerProfile(displayName: 'Técnico Teste'),
      userClubId: clubSeeds.first.id,
      seed: 20260824,
    );
