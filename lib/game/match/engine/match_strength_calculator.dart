import 'dart:math';

import '../../../domain/player/player.dart';
import '../../../domain/tactic/tactic.dart';
import '../../lineup/lineup_engine.dart';

class TeamMatchStrength {
  const TeamMatchStrength({
    required this.attack,
    required this.midfield,
    required this.defense,
    required this.goalkeeper,
  });

  final double attack;
  final double midfield;
  final double defense;
  final double goalkeeper;

  TeamMatchStrength copyWith({
    double? attack,
    double? midfield,
    double? defense,
    double? goalkeeper,
  }) =>
      TeamMatchStrength(
        attack: attack ?? this.attack,
        midfield: midfield ?? this.midfield,
        defense: defense ?? this.defense,
        goalkeeper: goalkeeper ?? this.goalkeeper,
      );
}

abstract final class MatchStrengthCalculator {
  static TeamMatchStrength calculate(
    List<AssignedPlayer> assignments,
    Tactic tactic,
  ) {
    if (assignments.isEmpty) {
      return const TeamMatchStrength(
        attack: 55,
        midfield: 55,
        defense: 55,
        goalkeeper: 55,
      );
    }

    double average(
      Iterable<AssignedPlayer> source,
      double Function(AssignedPlayer assignment) specialistScore,
    ) {
      final list = source.toList();
      final selected = list.isEmpty ? assignments : list;
      return selected
              .map(
                (assignment) {
                  final effective = LineupEngine.effectiveOverall(
                    assignment.player,
                    assignment.slot.role,
                  );
                  // O overall continua importante, mas cada setor agora usa
                  // os atributos que realmente explicam sua atuação em campo.
                  // O ajuste é moderado para não tornar o overall irrelevante.
                  return effective + (specialistScore(assignment) - effective) * .22;
                },
              )
              .reduce((a, b) => a + b) /
          selected.length;
    }

    const attackRoles = {
      PlayerPosition.ca,
      PlayerPosition.sa,
      PlayerPosition.pe,
      PlayerPosition.pd,
      PlayerPosition.mei,
    };
    const midfieldRoles = {
      PlayerPosition.vol,
      PlayerPosition.mc,
      PlayerPosition.mei,
      PlayerPosition.pe,
      PlayerPosition.pd,
    };
    const defenseRoles = {
      PlayerPosition.zag,
      PlayerPosition.ld,
      PlayerPosition.le,
      PlayerPosition.vol,
    };

    double attackSkill(AssignedPlayer item) {
      final player = item.player;
      return player.technical.finishing * .36 +
          player.technical.control * .16 +
          player.technical.dribbling * .12 +
          player.mental.positioning * .20 +
          player.mental.decision * .08 +
          player.physical.acceleration * .08;
    }

    double midfieldSkill(AssignedPlayer item) {
      final player = item.player;
      return player.technical.passing * .30 +
          player.technical.control * .20 +
          player.mental.vision * .20 +
          player.mental.decision * .15 +
          player.physical.stamina * .15;
    }

    double defenseSkill(AssignedPlayer item) {
      final player = item.player;
      return player.technical.tackling * .32 +
          player.mental.positioning * .25 +
          player.mental.concentration * .16 +
          player.physical.strength * .15 +
          player.physical.speed * .12;
    }

    double goalkeeperSkill(AssignedPlayer item) {
      final keeper = item.player.goalkeeper;
      return keeper.reflexes * .30 +
          keeper.saving * .28 +
          keeper.positioning * .20 +
          keeper.aerial * .12 +
          keeper.rushingOut * .10;
    }

    var attack = average(
      assignments.where((assignment) => attackRoles.contains(assignment.slot.role)),
      attackSkill,
    );
    var midfield = average(
      assignments.where((assignment) => midfieldRoles.contains(assignment.slot.role)),
      midfieldSkill,
    );
    var defense = average(
      assignments.where((assignment) => defenseRoles.contains(assignment.slot.role)),
      defenseSkill,
    );
    final goalkeeper = average(
      assignments.where((assignment) => assignment.slot.role == PlayerPosition.gol),
      goalkeeperSkill,
    );

    switch (tactic.mentality) {
      case Mentality.attacking:
        attack *= 1.08;
        defense *= .95;
        break;
      case Mentality.defensive:
        attack *= .95;
        defense *= 1.08;
        break;
      case Mentality.balanced:
        break;
    }

    switch (tactic.pressing) {
      case Pressing.high:
        midfield *= 1.05;
        attack *= 1.02;
        break;
      case Pressing.low:
        defense *= 1.04;
        midfield *= .97;
        break;
      case Pressing.medium:
        break;
    }

    switch (tactic.defensiveLine) {
      case DefensiveLine.high:
        midfield *= 1.02;
        defense *= .99;
        break;
      case DefensiveLine.low:
        defense *= 1.04;
        attack *= .98;
        break;
      case DefensiveLine.medium:
        break;
    }

    return TeamMatchStrength(
      attack: attack.clamp(35, 105).toDouble(),
      midfield: midfield.clamp(35, 105).toDouble(),
      defense: defense.clamp(35, 105).toDouble(),
      goalkeeper: goalkeeper.clamp(35, 105).toDouble(),
    );
  }

  static double tempoGoalFactor(Tactic tactic) {
    var value = 1.0;
    if (tactic.tempo == MatchTempo.fast) value += .08;
    if (tactic.tempo == MatchTempo.slow) value -= .06;
    if (tactic.mentality == Mentality.attacking) value += .06;
    if (tactic.mentality == Mentality.defensive) value -= .04;
    if (tactic.buildUp == BuildUp.direct) value += .04;
    return value;
  }

  static TeamMatchStrength applyManagerBonus(
    TeamMatchStrength strength,
    int managerOverall,
  ) {
    // Técnico melhor organiza mais o conjunto, mas não apaga a diferença
    // entre os elencos. A faixa máxima é deliberadamente pequena.
    final factor = (1 + (managerOverall.clamp(45, 95) - 70) * .0012)
        .clamp(.97, 1.03)
        .toDouble();
    return strength.copyWith(
      attack: strength.attack * factor,
      midfield: strength.midfield * factor,
      defense: strength.defense * factor,
      goalkeeper: strength.goalkeeper * factor,
    );
  }

  static double possessionShare({
    required TeamMatchStrength home,
    required TeamMatchStrength away,
    required Tactic homeTactic,
    required Tactic awayTactic,
    required double homeAdvantage,
  }) {
    var homeControl = home.midfield * homeAdvantage;
    var awayControl = away.midfield;
    if (homeTactic.buildUp == BuildUp.short) homeControl *= 1.05;
    if (awayTactic.buildUp == BuildUp.short) awayControl *= 1.05;
    if (homeTactic.buildUp == BuildUp.direct) homeControl *= .96;
    if (awayTactic.buildUp == BuildUp.direct) awayControl *= .96;
    final total = homeControl + awayControl;
    return (homeControl / max(1, total)).clamp(.30, .70).toDouble();
  }
}
