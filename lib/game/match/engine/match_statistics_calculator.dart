import 'dart:math';

import '../../../domain/club/club.dart';
import '../../../domain/match/match_models.dart';
import '../../../domain/tactic/tactic.dart';
import 'match_strength_calculator.dart';

abstract final class MatchStatisticsCalculator {
  static MatchStatistics calculate({
    required List<MatchEvent> events,
    required Club home,
    required Club away,
    required TeamMatchStrength homeStrength,
    required TeamMatchStrength awayStrength,
    required Tactic homeTactic,
    required Tactic awayTactic,
    required double homeAdvantage,
    required Random random,
  }) {
    final possession = (MatchStrengthCalculator.possessionShare(
              home: homeStrength,
              away: awayStrength,
              homeTactic: homeTactic,
              awayTactic: awayTactic,
              homeAdvantage: homeAdvantage,
            ) *
            100)
        .round()
        .clamp(30, 70)
        .toInt();

    int count(MatchEventType type, String teamId) => events
        .where((event) => event.type == type && event.teamId == teamId)
        .length;

    final homeGoals = count(MatchEventType.goal, home.id) +
        count(MatchEventType.ownGoal, home.id);
    final awayGoals = count(MatchEventType.goal, away.id) +
        count(MatchEventType.ownGoal, away.id);
    final homeShots = max(homeGoals, count(MatchEventType.shot, home.id));
    final awayShots = max(awayGoals, count(MatchEventType.shot, away.id));
    final homeOnTarget = min(
      homeShots,
      homeGoals + count(MatchEventType.save, away.id),
    );
    final awayOnTarget = min(
      awayShots,
      awayGoals + count(MatchEventType.save, home.id),
    );
    int directRedFouls(String teamId) => events
        .where(
          (event) =>
              event.teamId == teamId &&
              event.type == MatchEventType.red &&
              event.cardReason != MatchCardReason.secondYellow,
        )
        .length;
    final homeFouls =
        count(MatchEventType.foul, home.id) + directRedFouls(home.id);
    final awayFouls =
        count(MatchEventType.foul, away.id) + directRedFouls(away.id);

    return MatchStatistics(
      homePossession: possession,
      awayPossession: 100 - possession,
      homeShots: homeShots,
      awayShots: awayShots,
      homeShotsOnTarget: homeOnTarget,
      awayShotsOnTarget: awayOnTarget,
      homeCorners: max(0, (homeShots * .30 + random.nextDouble() * 2).round()),
      awayCorners: max(0, (awayShots * .30 + random.nextDouble() * 2).round()),
      homeFouls: homeFouls,
      awayFouls: awayFouls,
      homeYellow: count(MatchEventType.yellow, home.id),
      awayYellow: count(MatchEventType.yellow, away.id),
      homeRed: count(MatchEventType.red, home.id),
      awayRed: count(MatchEventType.red, away.id),
    );
  }
}
