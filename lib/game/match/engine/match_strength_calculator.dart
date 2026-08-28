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

    double average(Iterable<AssignedPlayer> source) {
      final list = source.toList();
      final selected = list.isEmpty ? assignments : list;
      return selected
              .map(
                (assignment) => LineupEngine.effectiveOverall(
                  assignment.player,
                  assignment.slot.role,
                ),
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

    var attack = average(
      assignments.where((assignment) => attackRoles.contains(assignment.slot.role)),
    );
    var midfield = average(
      assignments.where((assignment) => midfieldRoles.contains(assignment.slot.role)),
    );
    var defense = average(
      assignments.where((assignment) => defenseRoles.contains(assignment.slot.role)),
    );
    final goalkeeper = average(
      assignments.where((assignment) => assignment.slot.role == PlayerPosition.gol),
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
