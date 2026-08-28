import '../../domain/match/match_models.dart';
import 'match_event_presentation.dart';

enum LiveMatchSimulationOption {
  nextImportant,
  tenMinutes,
  halftime,
  fulltime,
}

abstract final class LiveMatchPlayback {
  static int targetFor({
    required LiveMatchSimulationOption option,
    required int currentMinute,
    required List<MatchEvent> events,
  }) {
    return switch (option) {
      LiveMatchSimulationOption.nextImportant => events
          .where(
            (event) =>
                event.minute > currentMinute &&
                MatchEventPresentation.isMajor(event.type),
          )
          .map((event) => event.minute)
          .fold<int>(90, (next, value) => value < next ? value : next),
      LiveMatchSimulationOption.tenMinutes =>
        (currentMinute + 10).clamp(0, 90).toInt(),
      LiveMatchSimulationOption.halftime => currentMinute < 45 ? 45 : 90,
      LiveMatchSimulationOption.fulltime => 90,
    };
  }
}
