import '../../domain/match/match_models.dart';

enum MatchNarrationFilter { all, important, userClub }

extension MatchNarrationFilterX on MatchNarrationFilter {
  String get label => switch (this) {
        MatchNarrationFilter.all => 'Todos',
        MatchNarrationFilter.important => 'Importantes',
        MatchNarrationFilter.userClub => 'Meu time',
      };
}

abstract final class MatchEventPresentation {
  static const Set<MatchEventType> majorTypes = {
    MatchEventType.kickoff,
    MatchEventType.goal,
    MatchEventType.ownGoal,
    MatchEventType.shot,
    MatchEventType.save,
    MatchEventType.woodwork,
    MatchEventType.yellow,
    MatchEventType.red,
    MatchEventType.penalty,
    MatchEventType.penaltySaved,
    MatchEventType.substitution,
    MatchEventType.injury,
    MatchEventType.halftime,
    MatchEventType.fulltime,
  };

  static bool isMajor(MatchEventType type) => majorTypes.contains(type);

  static List<MatchEvent> visible(
    List<MatchEvent> events,
    int minute, {
    int limit = 10,
    int? throughSequence,
    MatchNarrationFilter filter = MatchNarrationFilter.all,
    String? userClubId,
  }) {
    final ordered = events
        .where(
          (event) =>
              event.minute < minute ||
              (event.minute == minute &&
                  (throughSequence == null ||
                      event.sequence <= throughSequence)),
        )
        .where(
          (event) => switch (filter) {
            MatchNarrationFilter.all => true,
            MatchNarrationFilter.important => isMajor(event.type),
            MatchNarrationFilter.userClub => event.teamId == userClubId,
          },
        )
        .toList()
      ..sort((a, b) {
        final minuteCompare = b.minute.compareTo(a.minute);
        if (minuteCompare != 0) return minuteCompare;
        return b.sequence.compareTo(a.sequence);
      });
    return _compactCommonEvents(ordered).take(limit).toList();
  }

  static MatchEvent? latest(List<MatchEvent> events, int minute) {
    final current = visible(events, minute, limit: 1);
    return current.isEmpty ? null : current.first;
  }

  static List<MatchEvent> _compactCommonEvents(List<MatchEvent> ordered) {
    final compact = <MatchEvent>[];
    final lastCommonMinute = <String, int>{};
    for (final event in ordered) {
      final common = event.type == MatchEventType.pass ||
          event.type == MatchEventType.possession;
      if (common) {
        final key = '${event.teamId}:${event.type.name}';
        final previous = lastCommonMinute[key];
        if (previous != null && (previous - event.minute).abs() <= 2) continue;
        lastCommonMinute[key] = event.minute;
      }
      compact.add(event);
    }
    return compact;
  }


  static String narration(MatchEvent event, String teamName) {
    if (event.type == MatchEventType.kickoff) {
      return 'Apita o árbitro. A bola está rolando.';
    }
    if (event.type == MatchEventType.halftime) {
      return 'Fim do primeiro tempo. Hora de reorganizar a equipe.';
    }
    if (event.type == MatchEventType.pass &&
        event.playerId == null &&
        event.secondaryPlayerId == null) {
      const templates = [
        'circula a bola e procura espaço entre as linhas.',
        'troca passes e tenta acelerar pelo campo adversário.',
        'mantém a bola no chão e constrói a jogada com paciência.',
      ];
      return '$teamName ${templates[event.sequence % templates.length]}';
    }
    if (event.type == MatchEventType.possession) {
      const templates = [
        'controla a posse e empurra o adversário para trás.',
        'trabalha a bola de um lado ao outro do campo.',
        'tem a iniciativa e tenta encontrar uma brecha.',
      ];
      return '$teamName ${templates[event.sequence % templates.length]}';
    }
    return event.text;
  }

  static String headline(MatchEventType type, String teamName) => switch (type) {
        MatchEventType.kickoff => 'BOLA ROLANDO',
        MatchEventType.possession => 'POSSE • $teamName',
        MatchEventType.pass => 'CONSTRUÇÃO • $teamName',
        MatchEventType.shot => 'CHANCE DE GOL • $teamName',
        MatchEventType.save => 'DEFESA • $teamName',
        MatchEventType.woodwork => 'NA TRAVE! • $teamName',
        MatchEventType.goal => 'GOOOL! • $teamName',
        MatchEventType.ownGoal => 'GOL CONTRA • $teamName',
        MatchEventType.foul => 'FALTA • $teamName',
        MatchEventType.yellow => 'CARTÃO AMARELO • $teamName',
        MatchEventType.red => 'CARTÃO VERMELHO • $teamName',
        MatchEventType.penalty => 'PÊNALTI • $teamName',
        MatchEventType.penaltySaved => 'PÊNALTI DEFENDIDO • $teamName',
        MatchEventType.substitution => 'SUBSTITUIÇÃO • $teamName',
        MatchEventType.injury => 'ATENDIMENTO • $teamName',
        MatchEventType.halftime => 'INTERVALO',
        MatchEventType.fulltime => 'FIM DE JOGO',
      };
}
