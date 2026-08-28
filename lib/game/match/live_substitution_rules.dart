import '../../domain/match/match_models.dart';

class LiveSubstitutionChange {
  const LiveSubstitutionChange({
    required this.outgoingId,
    required this.incomingId,
  });

  final String outgoingId;
  final String incomingId;
}

/// Regras de substituição da partida ao vivo.
///
/// A partida permite até cinco jogadores substituídos em no máximo três
/// oportunidades durante o tempo regulamentar. Várias trocas feitas no mesmo
/// minuto contam como uma única oportunidade. O intervalo não consome uma
/// oportunidade, mas as trocas realizadas nele continuam contando no limite de
/// cinco jogadores.
abstract final class LiveSubstitutionRules {
  static const int maxSubstitutions = 5;
  static const int maxWindows = 3;
  static const int halftimeMinute = 45;

  static List<MatchEvent> substitutionsForTeam(
    Iterable<MatchEvent> events,
    String teamId,
  ) =>
      events
          .where(
            (event) =>
                event.type == MatchEventType.substitution &&
                event.teamId == teamId,
          )
          .toList(growable: false);

  static int substitutionsUsed(
    Iterable<MatchEvent> events,
    String teamId,
  ) =>
      substitutionsForTeam(events, teamId).length;

  static Set<int> windowsUsed(
    Iterable<MatchEvent> events,
    String teamId,
  ) =>
      substitutionsForTeam(events, teamId)
          .where((event) => event.minute != halftimeMinute)
          .map((event) => event.minute)
          .toSet();

  static int substitutionWindowsUsed(
    Iterable<MatchEvent> events,
    String teamId,
  ) =>
      windowsUsed(events, teamId).length;

  static bool wouldConsumeNewWindow({
    required Iterable<MatchEvent> events,
    required String teamId,
    required int minute,
  }) {
    if (minute == halftimeMinute) return false;
    return !windowsUsed(events, teamId).contains(minute);
  }

  static String? violationMessage({
    required Iterable<MatchEvent> events,
    required String teamId,
    required int minute,
    int requestedSubstitutions = 1,
  }) {
    if (requestedSubstitutions <= 0) return null;

    final usedSubstitutions = substitutionsUsed(events, teamId);
    if (usedSubstitutions + requestedSubstitutions > maxSubstitutions) {
      final remaining = (maxSubstitutions - usedSubstitutions).clamp(0, maxSubstitutions);
      if (remaining == 0) {
        return 'Limite de $maxSubstitutions substituições atingido nesta partida.';
      }
      return 'Você ainda pode fazer apenas $remaining substituição(ões) nesta partida.';
    }

    final usedWindows = substitutionWindowsUsed(events, teamId);
    if (wouldConsumeNewWindow(
          events: events,
          teamId: teamId,
          minute: minute,
        ) &&
        usedWindows >= maxWindows) {
      return 'As $maxWindows janelas de substituição já foram utilizadas. '
          'Novas trocas só podem ocorrer no intervalo, se ainda houver substituições disponíveis.';
    }
    return null;
  }
}
