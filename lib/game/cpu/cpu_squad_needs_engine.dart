import 'dart:math';

import '../../domain/club/club.dart';
import '../../domain/player/player.dart';
import '../transfer/transfer_engine.dart';

class CpuSquadNeed {
  const CpuSquadNeed({
    required this.position,
    required this.priority,
    required this.currentDepth,
    required this.minimumDepth,
    required this.bestOverall,
    required this.targetOverall,
  });

  final PlayerPosition position;
  final int priority;
  final int currentDepth;
  final int minimumDepth;
  final int bestOverall;
  final int targetOverall;

  bool matches(Player player) =>
      player.primaryPosition == position ||
      player.secondaryPositions.contains(position);
}

abstract final class CpuSquadNeedsEngine {
  static const Map<PlayerPosition, int> _minimumDepth = {
    PlayerPosition.gol: 2,
    PlayerPosition.ld: 1,
    PlayerPosition.le: 1,
    PlayerPosition.zag: 4,
    PlayerPosition.vol: 2,
    PlayerPosition.mc: 2,
    PlayerPosition.mei: 1,
    PlayerPosition.pe: 1,
    PlayerPosition.pd: 1,
    PlayerPosition.sa: 0,
    PlayerPosition.ca: 2,
  };

  static int minimumDepthFor(PlayerPosition position) =>
      _minimumDepth[position] ?? 1;

  static List<CpuSquadNeed> assess(Club club) {
    final targetOverall = (club.reputation - 5).clamp(55, 88).toInt();
    final needs = <CpuSquadNeed>[];

    for (final position in PlayerPosition.values) {
      final minimumDepth = minimumDepthFor(position);
      final primaryPlayers = club.squad
          .where((player) => player.primaryPosition == position)
          .toList();
      final compatiblePlayers = club.squad
          .where(
            (player) =>
                player.primaryPosition == position ||
                player.secondaryPositions.contains(position),
          )
          .toList();
      final bestOverall = compatiblePlayers.isEmpty
          ? 0
          : compatiblePlayers
              .map((player) => player.overall)
              .reduce(max);
      final shortage = max(0, minimumDepth - primaryPlayers.length);
      final qualityGap = max(0, targetOverall - bestOverall);

      if (shortage == 0 && qualityGap < 5) continue;

      final priority = shortage * 100 +
          qualityGap * 4 +
          (club.squad.length < TransferEngine.minimumSquadSize + 2
              ? 30
              : 0);
      needs.add(
        CpuSquadNeed(
          position: position,
          priority: priority,
          currentDepth: primaryPlayers.length,
          minimumDepth: minimumDepth,
          bestOverall: bestOverall,
          targetOverall: targetOverall,
        ),
      );
    }

    needs.sort((a, b) {
      final byPriority = b.priority.compareTo(a.priority);
      if (byPriority != 0) return byPriority;
      return a.position.index.compareTo(b.position.index);
    });
    return needs;
  }
}
