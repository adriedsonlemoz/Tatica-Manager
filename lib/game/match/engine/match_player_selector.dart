import 'dart:math';

import '../../../domain/player/player.dart';
import '../../lineup/lineup_engine.dart';

abstract final class MatchPlayerSelector {
  static Player pickScorer(
    List<AssignedPlayer> assignments,
    Random random,
  ) {
    if (assignments.isEmpty) {
      throw StateError('Não é possível simular uma partida sem escalação.');
    }

    final weights = <(Player, double)>[];
    for (final assignment in assignments) {
      final roleWeight = switch (assignment.slot.role) {
        PlayerPosition.ca => 8,
        PlayerPosition.sa => 7,
        PlayerPosition.pe || PlayerPosition.pd => 5,
        PlayerPosition.mei => 4,
        PlayerPosition.mc => 2,
        PlayerPosition.vol => 1,
        PlayerPosition.ld || PlayerPosition.le || PlayerPosition.zag => 1,
        PlayerPosition.gol => 0,
      };
      final player = assignment.player;
      final finishing = player.technical.finishing * .48 +
          player.mental.positioning * .26 +
          player.mental.decision * .14 +
          player.physical.acceleration * .12;
      weights.add((player, roleWeight * (.55 + finishing / 100)));
    }

    return _weightedPlayer(weights, random) ?? assignments.first.player;
  }

  static Player? pickAssister(
    List<AssignedPlayer> assignments,
    Player scorer,
    Random random,
  ) {
    final candidates = assignments
        .where(
          (assignment) =>
              assignment.player.id != scorer.id &&
              assignment.slot.role != PlayerPosition.gol,
        )
        .toList();
    if (candidates.isEmpty || random.nextDouble() < .22) return null;

    candidates.sort((a, b) {
      final av = a.player.mental.vision +
          a.player.technical.passing +
          a.player.technical.crossing;
      final bv = b.player.mental.vision +
          b.player.technical.passing +
          b.player.technical.crossing;
      return bv.compareTo(av);
    });
    final pool = candidates.take(min(5, candidates.length)).toList();
    return pool[random.nextInt(pool.length)].player;
  }

  static Player? pickAny(
    List<AssignedPlayer> assignments,
    Random random,
  ) =>
      assignments.isEmpty
          ? null
          : assignments[random.nextInt(assignments.length)].player;

  static Player? pickFouler(
    List<AssignedPlayer> assignments,
    Random random,
  ) {
    final weights = assignments.map((assignment) {
      final player = assignment.player;
      final roleWeight = switch (assignment.slot.role) {
        PlayerPosition.zag || PlayerPosition.vol => 1.30,
        PlayerPosition.ld || PlayerPosition.le => 1.15,
        PlayerPosition.mc => 1.05,
        PlayerPosition.mei || PlayerPosition.pe || PlayerPosition.pd => .78,
        PlayerPosition.ca || PlayerPosition.sa => .68,
        PlayerPosition.gol => .35,
      };
      final tendency = (100 - player.technical.tackling) * .30 +
          (100 - player.mental.concentration) * .22 +
          player.physical.strength * .08 +
          45;
      return (player, roleWeight * tendency);
    }).toList(growable: false);
    return _weightedPlayer(weights, random);
  }

  static double yellowRisk(Player player, {required int minute}) {
    final discipline = (100 - player.technical.tackling) * .18 +
        (100 - player.mental.concentration) * .16 +
        (minute > 70 ? .06 * (minute - 70) : 0);
    return (.13 + discipline / 100).clamp(.14, .30).toDouble();
  }

  static Player? goalkeeper(List<AssignedPlayer> assignments) => assignments
      .where((assignment) => assignment.player.primaryPosition == PlayerPosition.gol)
      .map((assignment) => assignment.player)
      .firstOrNull;

  static Player? _weightedPlayer(
    List<(Player, double)> entries,
    Random random,
  ) {
    final total = entries.fold<double>(0, (sum, entry) => sum + entry.$2);
    if (total <= 0) return null;
    var roll = random.nextDouble() * total;
    for (final entry in entries) {
      roll -= entry.$2;
      if (roll <= 0) return entry.$1;
    }
    return entries.last.$1;
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
