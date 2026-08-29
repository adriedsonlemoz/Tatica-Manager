import '../../../domain/match/match_models.dart';

abstract interface class MatchPitchController {
  bool get isReplayActive;
  bool get blocksClock;

  void playEvent(MatchEvent event);
  void playEvents(Iterable<MatchEvent> events);

  void updateLineups({
    required List<String> homePlayerIds,
    required List<String> awayPlayerIds,
  });

  void skipReplay();
  void clearPresentationQueue();
  void disposeController();
}
