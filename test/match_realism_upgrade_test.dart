import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/data/club_seed.dart';
import 'package:tatica_manager/domain/career/manager_profile.dart';
import 'package:tatica_manager/domain/season/league_loading.dart';
import 'package:tatica_manager/domain/tactic/tactic.dart';
import 'package:tatica_manager/game/career/career_factory.dart';
import 'package:tatica_manager/game/league/cpu_fixture_resolver.dart';
import 'package:tatica_manager/game/match/engine/match_probability_calculator.dart';
import 'package:tatica_manager/game/match/engine/match_strength_calculator.dart';

void main() {
  const even = TeamMatchStrength(
    attack: 70,
    midfield: 70,
    defense: 70,
    goalkeeper: 70,
  );

  test('força altera o volume de gols, não apenas o lado favorecido', () {
    final modest = MatchProbabilityCalculator.forMinute(
      minute: 30,
      homeStrength: const TeamMatchStrength(
        attack: 58,
        midfield: 58,
        defense: 75,
        goalkeeper: 75,
      ),
      awayStrength: const TeamMatchStrength(
        attack: 58,
        midfield: 58,
        defense: 75,
        goalkeeper: 75,
      ),
      homeTactic: const Tactic(),
      awayTactic: const Tactic(),
      homeAdvantage: 1.08,
      homeRed: 0,
      awayRed: 0,
      homeGoals: 0,
      awayGoals: 0,
    );
    final open = MatchProbabilityCalculator.forMinute(
      minute: 30,
      homeStrength: const TeamMatchStrength(
        attack: 88,
        midfield: 82,
        defense: 58,
        goalkeeper: 58,
      ),
      awayStrength: const TeamMatchStrength(
        attack: 88,
        midfield: 82,
        defense: 58,
        goalkeeper: 58,
      ),
      homeTactic: const Tactic(mentality: Mentality.attacking),
      awayTactic: const Tactic(mentality: Mentality.attacking),
      homeAdvantage: 1.08,
      homeRed: 0,
      awayRed: 0,
      homeGoals: 0,
      awayGoals: 0,
    );

    expect(open.goalTotal, greaterThan(modest.goalTotal));
    expect(open.shotTotal, greaterThan(modest.shotTotal));
  });

  test('placar desfavorável aumenta a iniciativa de quem perde', () {
    final tied = MatchProbabilityCalculator.forMinute(
      minute: 70,
      homeStrength: even,
      awayStrength: even,
      homeTactic: const Tactic(),
      awayTactic: const Tactic(),
      homeAdvantage: 1.08,
      homeRed: 0,
      awayRed: 0,
      homeGoals: 1,
      awayGoals: 1,
    );
    final chasing = MatchProbabilityCalculator.forMinute(
      minute: 70,
      homeStrength: even,
      awayStrength: even,
      homeTactic: const Tactic(),
      awayTactic: const Tactic(),
      homeAdvantage: 1.08,
      homeRed: 0,
      awayRed: 0,
      homeGoals: 0,
      awayGoals: 1,
    );

    expect(chasing.homeScoringShare, greaterThan(tied.homeScoringShare));
  });

  test('jogo de segundo plano usa eventos para preservar impactos individuais', () {
    final career = CareerFactory.create(
      careerId: 'background-realism',
      careerName: 'Segundo plano',
      manager: const ManagerProfile(displayName: 'Teste'),
      userClubId: clubSeeds.first.id,
      seed: 20260903,
    );
    final fixture = career.fixtures.first;
    final home = career.clubs.firstWhere((club) => club.id == fixture.homeClubId);
    final away = career.clubs.firstWhere((club) => club.id == fixture.awayClubId);

    final result = CpuFixtureResolver.resolve(
      level: LeagueLoadLevel.background,
      fixture: fixture,
      home: home,
      away: away,
    );

    expect(result.events, isNotEmpty);
    expect(result.events.last.type.name, 'fulltime');
  });
}
