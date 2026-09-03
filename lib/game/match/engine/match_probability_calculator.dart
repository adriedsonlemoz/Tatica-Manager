import 'dart:math';

import '../../../domain/tactic/tactic.dart';
import 'match_strength_calculator.dart';

class MatchMinuteProbabilities {
  const MatchMinuteProbabilities({
    required this.goalTotal,
    required this.shotTotal,
    required this.foulTotal,
    required this.homeScoringShare,
    required this.homeFoulShare,
    required this.homePossessionShare,
  });

  final double goalTotal;
  final double shotTotal;
  final double foulTotal;
  final double homeScoringShare;
  final double homeFoulShare;
  final double homePossessionShare;
}

abstract final class MatchProbabilityCalculator {
  static const double directRedPerMinuteTotal = .0010;
  static const double penaltyPerMinuteTotal = .0022;

  static MatchMinuteProbabilities forMinute({
    required int minute,
    required TeamMatchStrength homeStrength,
    required TeamMatchStrength awayStrength,
    required Tactic homeTactic,
    required Tactic awayTactic,
    required double homeAdvantage,
    required int homeRed,
    required int awayRed,
    required int homeGoals,
    required int awayGoals,
  }) {
    final fatiguePhase = minute <= 60 ? 1.0 : 1 - (minute - 60) * .0015;
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

    // Depois dos 55 minutos, quem está atrás se expõe mais. Isso muda o
    // volume e a divisão das chances sem forçar uma virada artificial.
    if (minute >= 55 && homeGoals != awayGoals) {
      final difference = (homeGoals - awayGoals).abs().clamp(1, 3);
      final chase = 1 + difference * .055;
      final protect = 1 - difference * .025;
      if (homeGoals < awayGoals) {
        homeThreat *= chase;
        awayThreat *= protect;
      } else {
        awayThreat *= chase;
        homeThreat *= protect;
      }
    }

    final attackingTempo =
        (MatchStrengthCalculator.tempoGoalFactor(homeTactic) +
                MatchStrengthCalculator.tempoGoalFactor(awayTactic)) /
            2;
    final averageThreat = (homeThreat + awayThreat) / 2;
    // Times com ataque/defesa melhores produzem partidas com mais ou menos
    // gols; antes a força só decidia qual lado receberia um gol já sorteado.
    final goalTotal = (.020 + (averageThreat - 1) * .011) * attackingTempo;
    final shotTotal = (.115 + (averageThreat - 1) * .040) * attackingTempo;
    final pressingLoad = _pressingLoad(homeTactic) + _pressingLoad(awayTactic);
    final foulTotal = (.175 + pressingLoad * .014 + (minute > 70 ? .012 : 0))
        .clamp(.150, .235)
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
      goalTotal: goalTotal.clamp(.016, .032).toDouble(),
      shotTotal: shotTotal.clamp(.095, .175).toDouble(),
      foulTotal: foulTotal,
      homeScoringShare: homeScoringShare,
      // Mais posse do adversário normalmente cria mais situações de pressão
      // defensiva e, portanto, mais faltas para aquele lado.
      homeFoulShare: (1 - homePossessionShare).clamp(.34, .66).toDouble(),
      homePossessionShare: homePossessionShare,
    );
  }

  static double _pressingLoad(Tactic tactic) => switch (tactic.pressing) {
        Pressing.high => 1.0,
        Pressing.medium => .5,
        Pressing.low => 0,
      };

  static double penaltyConversion(double attackStrength) =>
      (.75 + (attackStrength - 70) / 100).clamp(.60, .92).toDouble();
}
