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

    final weighted = <Player>[];
    for (final assignment in assignments) {
      final weight = switch (assignment.slot.role) {
        PlayerPosition.ca => 8,
        PlayerPosition.sa => 7,
        PlayerPosition.pe || PlayerPosition.pd => 5,
        PlayerPosition.mei => 4,
        PlayerPosition.mc => 2,
        PlayerPosition.vol => 1,
        PlayerPosition.ld || PlayerPosition.le || PlayerPosition.zag => 1,
        PlayerPosition.gol => 0,
      };
      for (var i = 0; i < weight; i++) {
        weighted.add(assignment.player);
      }
    }

    return weighted.isEmpty
        ? assignments.first.player
        : weighted[random.nextInt(weighted.length)];
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

  static Player? goalkeeper(List<AssignedPlayer> assignments) => assignments
      .where((assignment) => assignment.player.primaryPosition == PlayerPosition.gol)
      .map((assignment) => assignment.player)
      .firstOrNull;
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
