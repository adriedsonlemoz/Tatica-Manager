import 'dart:math';

import '../../domain/club/club.dart';
import '../../domain/match/match_models.dart';

/// Resolução estatística barata para partidas de competições explicitamente
/// configuradas como segundo plano. Não substitui o Match Engine e não produz
/// timeline visual; retorna apenas placar e estatísticas agregadas.
abstract final class BackgroundFixtureResolver {
  static MatchResult resolve({
    required MatchFixture fixture,
    required Club home,
    required Club away,
  }) {
    final seed = _seedFromFixture(fixture.id);
    final random = Random(seed);
    final homeStrength = _clubStrength(home) + 3.5;
    final awayStrength = _clubStrength(away);
    final total = max(1.0, homeStrength + awayStrength);
    final homeShare = (homeStrength / total).clamp(.30, .70).toDouble();
    final awayShare = 1 - homeShare;

    final homeGoals = _goals(random, homeShare, homeAdvantage: true);
    final awayGoals = _goals(random, awayShare, homeAdvantage: false);
    final homePossession =
        (50 + (homeShare - .5) * 52).round().clamp(36, 64).toInt();
    final awayPossession = 100 - homePossession;
    final homeShots = max(
      homeGoals + 2,
      7 + random.nextInt(8) + (homeShare * 4).round(),
    ).toInt();
    final awayShots = max(
      awayGoals + 2,
      6 + random.nextInt(8) + (awayShare * 4).round(),
    ).toInt();
    final homeOnTarget = min(
      homeShots,
      max(homeGoals, 2 + random.nextInt(max(1, homeShots ~/ 2).toInt())),
    ).toInt();
    final awayOnTarget = min(
      awayShots,
      max(awayGoals, 2 + random.nextInt(max(1, awayShots ~/ 2).toInt())),
    ).toInt();

    return MatchResult(
      fixtureId: fixture.id,
      homeClubId: home.id,
      awayClubId: away.id,
      score: MatchScore(homeGoals, awayGoals),
      events: const [],
      statistics: MatchStatistics(
        homePossession: homePossession,
        awayPossession: awayPossession,
        homeShots: homeShots,
        awayShots: awayShots,
        homeShotsOnTarget: homeOnTarget,
        awayShotsOnTarget: awayOnTarget,
        homeCorners: 2 + random.nextInt(7),
        awayCorners: 2 + random.nextInt(7),
        homeFouls: 7 + random.nextInt(10),
        awayFouls: 7 + random.nextInt(10),
        homeYellow: random.nextInt(4),
        awayYellow: random.nextInt(4),
        homeRed: random.nextInt(100) < 5 ? 1 : 0,
        awayRed: random.nextInt(100) < 5 ? 1 : 0,
      ),
      seed: seed,
    );
  }

  static double _clubStrength(Club club) {
    final squad = club.squad;
    final squadOverall = squad.isEmpty
        ? club.reputation.toDouble()
        : squad.fold<int>(0, (sum, player) => sum + player.overall) /
            squad.length;
    return club.reputation * .45 + squadOverall * .55;
  }

  static int _goals(Random random, double share, {required bool homeAdvantage}) {
    final expectation = .75 + share * 1.65 + (homeAdvantage ? .16 : 0);
    var goals = 0;
    var threshold = expectation;
    while (goals < 6 && random.nextDouble() < threshold / (goals + 2.2)) {
      goals++;
      threshold *= .86;
    }
    return goals;
  }

  static int _seedFromFixture(String id) {
    var hash = 23;
    for (final code in id.codeUnits) {
      hash = 0x7fffffff & (hash * 41 + code);
    }
    return hash;
  }
}
