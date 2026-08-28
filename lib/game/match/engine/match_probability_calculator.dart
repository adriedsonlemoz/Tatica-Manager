import 'dart:math';

import '../../../domain/tactic/tactic.dart';
import 'match_strength_calculator.dart';

class MatchMinuteProbabilities {
  const MatchMinuteProbabilities({
    required this.goalTotal,
    required this.homeScoringShare,
    required this.homePossessionShare,
  });

  final double goalTotal;
  final double homeScoringShare;
  final double homePossessionShare;
}

abstract final class MatchProbabilityCalculator {
  static const double goalPerMinuteTotal = .029;
  static const double yellowPerTeamPerMinute = .0194;
  static const double directRedPerMinuteTotal = .00156;
  static const double penaltyPerMinuteTotal = .003;

  static MatchMinuteProbabilities forMinute({
    required int minute,
    required TeamMatchStrength homeStrength,
    required TeamMatchStrength awayStrength,
    required Tactic homeTactic,
    required Tactic awayTactic,
    required double homeAdvantage,
    required int homeRed,
    required int awayRed,
  }) {
    final fatiguePhase = minute <= 60 ? 1.0 : 1 - (minute - 60) * .0018;
    var homeThreat =
        (homeStrength.attack * .54 + homeStrength.midfield * .28 + 18) /
            max(
              35,
              awayStrength.defense * .62 + awayStrength.goalkeeper * .38,
            );
    var awayThreat =
        (awayStrength.attack * .54 + awayStrength.midfield * .28 + 18) /
            max(
              35,
              homeStrength.defense * .62 + homeStrength.goalkeeper * .38,
            );
    homeThreat *= homeAdvantage *
        fatiguePhase *
        pow(.88, homeRed).toDouble() *
        pow(1.08, awayRed).toDouble();
    awayThreat *= fatiguePhase *
        pow(.88, awayRed).toDouble() *
        pow(1.08, homeRed).toDouble();

    final attackingTempo =
        (MatchStrengthCalculator.tempoGoalFactor(homeTactic) +
                MatchStrengthCalculator.tempoGoalFactor(awayTactic)) /
            2;
    final goalTotal = (goalPerMinuteTotal * attackingTempo)
        .clamp(.021, .040)
        .toDouble();
    final threatTotal = homeThreat + awayThreat;
    final homeScoringShare = threatTotal <= 0
        ? .5
        : (homeThreat / threatTotal).clamp(.20, .80).toDouble();
    final homePossessionShare = MatchStrengthCalculator.possessionShare(
      home: homeStrength,
      away: awayStrength,
      homeTactic: homeTactic,
      awayTactic: awayTactic,
      homeAdvantage: homeAdvantage,
    );

    return MatchMinuteProbabilities(
      goalTotal: goalTotal,
      homeScoringShare: homeScoringShare,
      homePossessionShare: homePossessionShare,
    );
  }

  static double penaltyConversion(double attackStrength) =>
      (.75 + (attackStrength - 70) / 100).clamp(.60, .92).toDouble();
}
