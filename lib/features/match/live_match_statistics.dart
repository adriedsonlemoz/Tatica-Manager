import '../../domain/match/match_models.dart';

abstract final class LiveMatchStatistics {
  static (int, int) possession({
    required List<MatchEvent> events,
    required int minute,
    required String homeId,
    required String awayId,
    required int targetHomePossession,
    int? throughSequence,
  }) {
    final target = targetHomePossession.clamp(30, 70).toInt();
    final homeTouches = _touches(
      events,
      minute: minute,
      throughSequence: throughSequence,
      teamId: homeId,
    );
    final awayTouches = _touches(
      events,
      minute: minute,
      throughSequence: throughSequence,
      teamId: awayId,
    );
    final total = homeTouches + awayTouches;
    if (total == 0) return (target, 100 - target);

    final progress = (minute / 90).clamp(0.0, 1.0).toDouble();
    final priorWeight = 8.0 + (1 - progress) * 4.0;
    final observed =
        (target * priorWeight + homeTouches * 100) / (priorWeight + total);
    final convergence = progress * progress;
    final smoothed = observed + (target - observed) * convergence;
    final home = smoothed.round().clamp(30, 70).toInt();
    return (home, 100 - home);
  }

  static int _touches(
    List<MatchEvent> events, {
    required int minute,
    required int? throughSequence,
    required String teamId,
  }) =>
      events
          .where(
            (event) =>
                _isVisible(
                  event,
                  minute: minute,
                  throughSequence: throughSequence,
                ) &&
                event.teamId == teamId &&
                (event.type == MatchEventType.pass ||
                    event.type == MatchEventType.possession),
          )
          .length;

  static bool _isVisible(
    MatchEvent event, {
    required int minute,
    required int? throughSequence,
  }) =>
      event.minute < minute ||
      (event.minute == minute &&
          (throughSequence == null || event.sequence <= throughSequence));
}
