import '../../domain/match/match_models.dart';
import '../../game/league/live_round_simulator.dart';

class LiveRoundGoalAlert {
  const LiveRoundGoalAlert({
    required this.match,
    required this.event,
    required this.score,
  });

  final PreparedRoundMatch match;
  final MatchEvent event;
  final MatchScore score;

  String get key =>
      '${match.fixture.id}:${event.minute}:${event.sequence}:${score.display}';
}

abstract final class LiveRoundFeed {
  static MatchScore scoreUntil(
    MatchResult result,
    int minute, {
    int? throughSequence,
  }) {
    var home = 0;
    var away = 0;
    for (final event in result.events) {
      final visible = event.minute < minute ||
          (event.minute == minute &&
              (throughSequence == null || event.sequence <= throughSequence));
      if (!visible || !_isGoal(event.type)) continue;
      if (event.teamId == result.homeClubId) home++;
      if (event.teamId == result.awayClubId) away++;
    }
    return MatchScore(home, away);
  }

  static List<LiveRoundGoalAlert> alertsAtMinute(
    List<PreparedRoundMatch> matches,
    int minute,
  ) {
    final alerts = <LiveRoundGoalAlert>[];
    for (final match in matches) {
      for (final event in match.result.events.where(
        (event) => event.minute == minute && _isGoal(event.type),
      )) {
        alerts.add(
          LiveRoundGoalAlert(
            match: match,
            event: event,
            score: scoreUntil(
              match.result,
              minute,
              throughSequence: event.sequence,
            ),
          ),
        );
      }
    }
    return alerts;
  }

  static bool _isGoal(MatchEventType type) =>
      type == MatchEventType.goal || type == MatchEventType.ownGoal;
}
