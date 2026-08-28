import '../../../domain/club/club.dart';
import '../../../domain/match/match_models.dart';
import '../../lineup/lineup_engine.dart';
import 'match_event_generator.dart';

class MatchDisciplineTracker {
  MatchDisciplineTracker.fromPrefix(List<MatchEvent> prefixEvents) {
    final ordered = [...prefixEvents]
      ..sort((a, b) {
        final minute = a.minute.compareTo(b.minute);
        return minute != 0 ? minute : a.sequence.compareTo(b.sequence);
      });
    for (final event in ordered) {
      final playerId = event.playerId;
      if (playerId == null) continue;
      if (event.type == MatchEventType.yellow) {
        _yellowByPlayer[playerId] = (_yellowByPlayer[playerId] ?? 0) + 1;
      } else if (event.type == MatchEventType.red) {
        _dismissedPlayerIds.add(playerId);
      }
    }
    for (final entry in _yellowByPlayer.entries) {
      if (entry.value >= 2) _dismissedPlayerIds.add(entry.key);
    }
  }

  final Map<String, int> _yellowByPlayer = {};
  final Set<String> _dismissedPlayerIds = {};

  Set<String> get dismissedPlayerIds => Set.unmodifiable(_dismissedPlayerIds);

  int yellowCardsFor(String playerId) => _yellowByPlayer[playerId] ?? 0;

  bool isDismissed(String playerId) => _dismissedPlayerIds.contains(playerId);

  List<AssignedPlayer> activeAssignments(List<AssignedPlayer> assignments) =>
      assignments
          .where((assignment) => !_dismissedPlayerIds.contains(assignment.player.id))
          .toList(growable: false);

  MatchEventBatch applyBatch({
    required MatchEventBatch batch,
    required Club home,
    required Club away,
    required List<AssignedPlayer> homeAssignments,
    required List<AssignedPlayer> awayAssignments,
  }) {
    final events = <MatchEvent>[];
    var extraHomeReds = 0;
    var extraAwayReds = 0;

    for (final event in batch.events) {
      events.add(event);
      final playerId = event.playerId;
      if (playerId == null) continue;

      if (event.type == MatchEventType.red) {
        _dismissedPlayerIds.add(playerId);
        continue;
      }
      if (event.type != MatchEventType.yellow || isDismissed(playerId)) continue;

      final yellowCount = (_yellowByPlayer[playerId] ?? 0) + 1;
      _yellowByPlayer[playerId] = yellowCount;
      if (yellowCount < 2) continue;

      _dismissedPlayerIds.add(playerId);
      final homeSide = event.teamId == home.id;
      final club = homeSide ? home : away;
      final assignments = homeSide ? homeAssignments : awayAssignments;
      AssignedPlayer? assignment;
      for (final item in assignments) {
        if (item.player.id == playerId) {
          assignment = item;
          break;
        }
      }
      final playerName = assignment?.player.displayName ?? 'Jogador';
      events.add(
        MatchEvent(
          minute: event.minute,
          sequence: event.sequence + 1,
          type: MatchEventType.red,
          teamId: event.teamId,
          playerId: playerId,
          cardReason: MatchCardReason.secondYellow,
          text:
              'Segundo cartão amarelo! $playerName está expulso do ${club.name}.',
          start: assignment == null
              ? null
              : FieldPoint(assignment.slot.x, assignment.slot.y),
        ),
      );
      if (homeSide) {
        extraHomeReds++;
      } else {
        extraAwayReds++;
      }
    }

    return MatchEventBatch(
      events: events,
      homeGoals: batch.homeGoals,
      awayGoals: batch.awayGoals,
      homeReds: batch.homeReds + extraHomeReds,
      awayReds: batch.awayReds + extraAwayReds,
    );
  }
}
