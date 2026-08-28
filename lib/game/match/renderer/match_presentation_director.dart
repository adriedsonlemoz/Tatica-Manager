import '../../../domain/match/match_models.dart';

enum MatchPresentationCueKind { event, pause }

class MatchPresentationCue {
  const MatchPresentationCue.event({
    required this.event,
    required this.duration,
    this.replay = false,
    this.startsReplay = false,
    this.endsReplay = false,
  }) : kind = MatchPresentationCueKind.event;

  const MatchPresentationCue.pause({
    required this.duration,
    this.replay = false,
    this.startsReplay = false,
    this.endsReplay = false,
  })  : kind = MatchPresentationCueKind.pause,
        event = null;

  final MatchPresentationCueKind kind;
  final MatchEvent? event;
  final double duration;
  final bool replay;
  final bool startsReplay;
  final bool endsReplay;
}

abstract final class MatchPresentationDirector {
  static List<MatchPresentationCue> buildCues(List<MatchEvent> events) {
    if (events.isEmpty) return const [];
    final ordered = [...events]
      ..sort((a, b) => a.sequence.compareTo(b.sequence));
    final cues = <MatchPresentationCue>[
      for (final event in ordered)
        MatchPresentationCue.event(
          event: event,
          duration: liveDuration(event.type),
        ),
    ];

    final replayAnchorIndex = ordered.lastIndexWhere(
      (event) => shouldReplay(event.type),
    );
    if (replayAnchorIndex < 0) return cues;

    final anchor = ordered[replayAnchorIndex];
    final relevant = ordered
        .take(replayAnchorIndex + 1)
        .where((event) => _replayRelevant(anchor, event))
        .toList();
    final compactReplay = relevant.length <= 4
        ? relevant
        : relevant.sublist(relevant.length - 4);

    cues.add(
      const MatchPresentationCue.pause(
        duration: .46,
        replay: true,
        startsReplay: true,
      ),
    );
    for (final event in compactReplay) {
      cues.add(
        MatchPresentationCue.event(
          event: event,
          duration: replayDuration(event.type),
          replay: true,
        ),
      );
    }
    cues.add(
      const MatchPresentationCue.pause(
        duration: .36,
        replay: true,
        endsReplay: true,
      ),
    );
    return cues;
  }

  static bool shouldReplay(MatchEventType type) =>
      type == MatchEventType.goal ||
      type == MatchEventType.ownGoal ||
      type == MatchEventType.woodwork ||
      type == MatchEventType.penaltySaved;

  static bool _replayRelevant(
    MatchEvent anchor,
    MatchEvent candidate,
  ) {
    if (anchor.type == MatchEventType.penaltySaved) {
      return candidate.type == MatchEventType.penalty ||
          candidate.type == MatchEventType.penaltySaved;
    }
    if (candidate.teamId != anchor.teamId) return false;
    if (anchor.type == MatchEventType.woodwork) {
      return candidate.type == MatchEventType.pass ||
          candidate.type == MatchEventType.shot ||
          candidate.type == MatchEventType.woodwork;
    }
    return candidate.type == MatchEventType.pass ||
        candidate.type == MatchEventType.shot ||
        candidate.type == MatchEventType.penalty ||
        candidate.type == MatchEventType.goal ||
        candidate.type == MatchEventType.ownGoal;
  }

  static double liveDuration(MatchEventType type) => switch (type) {
        MatchEventType.pass || MatchEventType.possession => .28,
        MatchEventType.shot => .42,
        MatchEventType.save => .54,
        MatchEventType.woodwork => .64,
        MatchEventType.goal || MatchEventType.ownGoal => .72,
        MatchEventType.penalty => 1.12,
        MatchEventType.penaltySaved => .76,
        MatchEventType.yellow || MatchEventType.red => .52,
        MatchEventType.substitution => .58,
        MatchEventType.injury => .48,
        _ => .30,
      };

  static double replayDuration(MatchEventType type) => switch (type) {
        MatchEventType.pass => .72,
        MatchEventType.shot => .84,
        MatchEventType.woodwork => .78,
        MatchEventType.penalty => 1.02,
        MatchEventType.penaltySaved => .88,
        MatchEventType.goal || MatchEventType.ownGoal => .78,
        _ => .64,
      };
}
