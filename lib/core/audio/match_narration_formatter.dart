import '../../domain/match/match_models.dart';

abstract final class MatchNarrationFormatter {
  static const Set<MatchEventType> narratedTypes = {
    MatchEventType.kickoff,
    MatchEventType.shot,
    MatchEventType.save,
    MatchEventType.woodwork,
    MatchEventType.goal,
    MatchEventType.ownGoal,
    MatchEventType.foul,
    MatchEventType.yellow,
    MatchEventType.red,
    MatchEventType.penalty,
    MatchEventType.penaltySaved,
    MatchEventType.substitution,
    MatchEventType.injury,
    MatchEventType.halftime,
    MatchEventType.fulltime,
  };

  static bool shouldNarrate(MatchEvent event) =>
      narratedTypes.contains(event.type);

  static Duration delayFor(MatchEventType type) => switch (type) {
        MatchEventType.goal || MatchEventType.ownGoal =>
          const Duration(milliseconds: 360),
        MatchEventType.woodwork || MatchEventType.penaltySaved =>
          const Duration(milliseconds: 260),
        MatchEventType.yellow || MatchEventType.red =>
          const Duration(milliseconds: 220),
        _ => const Duration(milliseconds: 120),
      };

  static String textFor(MatchEvent event, {required String teamName}) {
    final minute = event.minute > 0 ? ' Aos ${event.minute} minutos.' : '';
    final raw = event.text.trim();
    return switch (event.type) {
      MatchEventType.kickoff => 'Começa o jogo. Bola rolando.',
      MatchEventType.halftime => 'Fim do primeiro tempo. Intervalo de jogo.',
      MatchEventType.fulltime => 'Fim de jogo. O árbitro encerra a partida.',
      MatchEventType.goal || MatchEventType.ownGoal =>
        '${_clean(raw, fallback: 'Gol do $teamName!')}$minute',
      MatchEventType.woodwork =>
        '${_clean(raw, fallback: 'Na trave! Quase gol do $teamName.')}$minute',
      MatchEventType.penalty =>
        '${_clean(raw, fallback: 'Pênalti para $teamName.')}$minute',
      MatchEventType.penaltySaved =>
        '${_clean(raw, fallback: 'Pênalti defendido!')}$minute',
      MatchEventType.yellow =>
        '${_clean(raw, fallback: 'Cartão amarelo para $teamName.')}$minute',
      MatchEventType.red =>
        '${_clean(raw, fallback: 'Cartão vermelho para $teamName.')}$minute',
      MatchEventType.substitution =>
        '${_clean(raw, fallback: 'Substituição no $teamName.')}$minute',
      MatchEventType.injury =>
        '${_clean(raw, fallback: 'Jogador recebe atendimento.')}$minute',
      MatchEventType.shot || MatchEventType.save || MatchEventType.foul =>
        _clean(raw, fallback: event.type.label),
      MatchEventType.possession || MatchEventType.pass => '',
    };
  }

  static String _clean(String text, {required String fallback}) {
    if (text.isEmpty) return fallback;
    return text
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll('GOL!', 'Gol!')
        .replaceAll('NA TRAVE!', 'Na trave!')
        .trim();
  }
}
