class MatchScore {
  const MatchScore(this.home, this.away);
  final int home;
  final int away;

  String get display => '$home - $away';

  Map<String, dynamic> toJson() => {'home': home, 'away': away};
  factory MatchScore.fromJson(Map<String, dynamic> json) => MatchScore(
        json['home'] as int? ?? 0,
        json['away'] as int? ?? 0,
      );
}

class MatchFixture {
  const MatchFixture({
    required this.id,
    required this.round,
    required this.homeClubId,
    required this.awayClubId,
    required this.date,
    this.competitionId = 'br-series-a',
    this.stageId = 'main',
    this.groupId,
    this.tieId,
    this.leg = 1,
    this.kickoffHour = 16,
    this.kickoffMinute = 0,
    this.played = false,
    this.score,
  });

  final String id;
  final int round;
  final String homeClubId;
  final String awayClubId;
  final DateTime date;
  final String competitionId;
  final String stageId;
  final String? groupId;
  final String? tieId;
  final int leg;
  final int kickoffHour;
  final int kickoffMinute;
  final bool played;
  final MatchScore? score;

  String get kickoffLabel =>
      '${kickoffHour.toString().padLeft(2, '0')}:${kickoffMinute.toString().padLeft(2, '0')}';

  MatchFixture copyWith({
    bool? played,
    MatchScore? score,
    DateTime? date,
    String? competitionId,
    String? stageId,
    String? groupId,
    bool clearGroupId = false,
    String? tieId,
    bool clearTieId = false,
    int? leg,
    int? kickoffHour,
    int? kickoffMinute,
  }) =>
      MatchFixture(
        id: id,
        round: round,
        homeClubId: homeClubId,
        awayClubId: awayClubId,
        date: date ?? this.date,
        competitionId: competitionId ?? this.competitionId,
        stageId: stageId ?? this.stageId,
        groupId: clearGroupId ? null : (groupId ?? this.groupId),
        tieId: clearTieId ? null : (tieId ?? this.tieId),
        leg: leg ?? this.leg,
        kickoffHour: kickoffHour ?? this.kickoffHour,
        kickoffMinute: kickoffMinute ?? this.kickoffMinute,
        played: played ?? this.played,
        score: score ?? this.score,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'round': round,
        'homeClubId': homeClubId,
        'awayClubId': awayClubId,
        'date': date.toIso8601String(),
        'competitionId': competitionId,
        'stageId': stageId,
        'groupId': groupId,
        'tieId': tieId,
        'leg': leg,
        'kickoffHour': kickoffHour,
        'kickoffMinute': kickoffMinute,
        'played': played,
        'score': score?.toJson(),
      };

  factory MatchFixture.fromJson(Map<String, dynamic> json) => MatchFixture(
        id: json['id'] as String,
        round: json['round'] as int,
        homeClubId: json['homeClubId'] as String,
        awayClubId: json['awayClubId'] as String,
        date: DateTime.parse(json['date'] as String),
        competitionId: json['competitionId'] as String? ?? 'br-series-a',
        stageId: json['stageId'] as String? ?? 'main',
        groupId: json['groupId'] as String?,
        tieId: json['tieId'] as String?,
        leg: (json['leg'] as num?)?.toInt().clamp(1, 4).toInt() ?? 1,
        kickoffHour: (json['kickoffHour'] as int? ?? 16).clamp(0, 23).toInt(),
        kickoffMinute: (json['kickoffMinute'] as int? ?? 0).clamp(0, 59).toInt(),
        played: json['played'] as bool? ?? false,
        score: json['score'] == null
            ? null
            : MatchScore.fromJson(
                Map<String, dynamic>.from(json['score'] as Map),
              ),
      );
}

class FieldPoint {
  const FieldPoint(this.x, this.y);
  final double x;
  final double y;

  Map<String, dynamic> toJson() => {'x': x, 'y': y};
  factory FieldPoint.fromJson(Map<String, dynamic> json) => FieldPoint(
        (json['x'] as num?)?.toDouble() ?? .5,
        (json['y'] as num?)?.toDouble() ?? .5,
      );
}

enum MatchEventType {
  kickoff,
  possession,
  pass,
  shot,
  save,
  woodwork,
  goal,
  ownGoal,
  foul,
  yellow,
  red,
  penalty,
  penaltySaved,
  substitution,
  injury,
  halftime,
  fulltime,
}

extension MatchEventTypeX on MatchEventType {
  String get label => switch (this) {
        MatchEventType.kickoff => 'Início',
        MatchEventType.possession => 'Posse',
        MatchEventType.pass => 'Passe',
        MatchEventType.shot => 'Finalização',
        MatchEventType.save => 'Defesa',
        MatchEventType.woodwork => 'Na trave',
        MatchEventType.goal => 'Gol',
        MatchEventType.ownGoal => 'Gol contra',
        MatchEventType.foul => 'Falta',
        MatchEventType.yellow => 'Cartão amarelo',
        MatchEventType.red => 'Cartão vermelho',
        MatchEventType.penalty => 'Pênalti',
        MatchEventType.penaltySaved => 'Pênalti defendido',
        MatchEventType.substitution => 'Substituição',
        MatchEventType.injury => 'Lesão',
        MatchEventType.halftime => 'Intervalo',
        MatchEventType.fulltime => 'Fim de jogo',
      };
}

enum MatchCardReason { direct, secondYellow }

class MatchEvent {
  const MatchEvent({
    required this.minute,
    required this.sequence,
    required this.type,
    required this.teamId,
    required this.text,
    this.playerId,
    this.assistPlayerId,
    this.secondaryPlayerId,
    this.cardReason,
    this.start,
    this.end,
  });

  final int minute;
  final int sequence;
  final MatchEventType type;
  final String teamId;
  final String text;
  final String? playerId;
  final String? assistPlayerId;
  final String? secondaryPlayerId;
  final MatchCardReason? cardReason;
  final FieldPoint? start;
  final FieldPoint? end;

  Map<String, dynamic> toJson() => {
        'minute': minute,
        'sequence': sequence,
        'type': type.name,
        'teamId': teamId,
        'text': text,
        'playerId': playerId,
        'assistPlayerId': assistPlayerId,
        'secondaryPlayerId': secondaryPlayerId,
        if (cardReason != null) 'cardReason': cardReason!.name,
        'start': start?.toJson(),
        'end': end?.toJson(),
      };

  factory MatchEvent.fromJson(Map<String, dynamic> json) => MatchEvent(
        minute: json['minute'] as int? ?? 0,
        sequence: json['sequence'] as int? ?? 0,
        type: MatchEventType.values.firstWhere((e) => e.name == json['type'], orElse: () => MatchEventType.possession),
        teamId: json['teamId'] as String? ?? '',
        text: json['text'] as String? ?? '',
        playerId: json['playerId'] as String?,
        assistPlayerId: json['assistPlayerId'] as String?,
        secondaryPlayerId: json['secondaryPlayerId'] as String?,
        cardReason: json['cardReason'] == null
            ? null
            : MatchCardReason.values.firstWhere(
                (value) => value.name == json['cardReason'],
                orElse: () => MatchCardReason.direct,
              ),
        start: json['start'] == null ? null : FieldPoint.fromJson(Map<String, dynamic>.from(json['start'] as Map)),
        end: json['end'] == null ? null : FieldPoint.fromJson(Map<String, dynamic>.from(json['end'] as Map)),
      );
}

class MatchStatistics {
  const MatchStatistics({
    required this.homePossession,
    required this.awayPossession,
    required this.homeShots,
    required this.awayShots,
    required this.homeShotsOnTarget,
    required this.awayShotsOnTarget,
    required this.homeCorners,
    required this.awayCorners,
    required this.homeFouls,
    required this.awayFouls,
    required this.homeYellow,
    required this.awayYellow,
    required this.homeRed,
    required this.awayRed,
  });

  final int homePossession;
  final int awayPossession;
  final int homeShots;
  final int awayShots;
  final int homeShotsOnTarget;
  final int awayShotsOnTarget;
  final int homeCorners;
  final int awayCorners;
  final int homeFouls;
  final int awayFouls;
  final int homeYellow;
  final int awayYellow;
  final int homeRed;
  final int awayRed;

  Map<String, dynamic> toJson() => {
        'homePossession': homePossession,
        'awayPossession': awayPossession,
        'homeShots': homeShots,
        'awayShots': awayShots,
        'homeShotsOnTarget': homeShotsOnTarget,
        'awayShotsOnTarget': awayShotsOnTarget,
        'homeCorners': homeCorners,
        'awayCorners': awayCorners,
        'homeFouls': homeFouls,
        'awayFouls': awayFouls,
        'homeYellow': homeYellow,
        'awayYellow': awayYellow,
        'homeRed': homeRed,
        'awayRed': awayRed,
      };

  factory MatchStatistics.fromJson(Map<String, dynamic> json) => MatchStatistics(
        homePossession: json['homePossession'] as int? ?? 50,
        awayPossession: json['awayPossession'] as int? ?? 50,
        homeShots: json['homeShots'] as int? ?? 0,
        awayShots: json['awayShots'] as int? ?? 0,
        homeShotsOnTarget: json['homeShotsOnTarget'] as int? ?? 0,
        awayShotsOnTarget: json['awayShotsOnTarget'] as int? ?? 0,
        homeCorners: json['homeCorners'] as int? ?? 0,
        awayCorners: json['awayCorners'] as int? ?? 0,
        homeFouls: json['homeFouls'] as int? ?? 0,
        awayFouls: json['awayFouls'] as int? ?? 0,
        homeYellow: json['homeYellow'] as int? ?? 0,
        awayYellow: json['awayYellow'] as int? ?? 0,
        homeRed: json['homeRed'] as int? ?? 0,
        awayRed: json['awayRed'] as int? ?? 0,
      );
}

class MatchResult {
  const MatchResult({
    required this.fixtureId,
    required this.homeClubId,
    required this.awayClubId,
    required this.score,
    required this.events,
    required this.statistics,
    required this.seed,
  });

  final String fixtureId;
  final String homeClubId;
  final String awayClubId;
  final MatchScore score;
  final List<MatchEvent> events;
  final MatchStatistics statistics;
  final int seed;

  Map<String, dynamic> toJson() => {
        'fixtureId': fixtureId,
        'homeClubId': homeClubId,
        'awayClubId': awayClubId,
        'score': score.toJson(),
        'events': events.map((e) => e.toJson()).toList(),
        'statistics': statistics.toJson(),
        'seed': seed,
      };

  factory MatchResult.fromJson(Map<String, dynamic> json) => MatchResult(
        fixtureId: json['fixtureId'] as String,
        homeClubId: json['homeClubId'] as String,
        awayClubId: json['awayClubId'] as String,
        score: MatchScore.fromJson(Map<String, dynamic>.from(json['score'] as Map? ?? const {})),
        events: ((json['events'] as List?) ?? const [])
            .map((e) => MatchEvent.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        statistics: MatchStatistics.fromJson(Map<String, dynamic>.from(json['statistics'] as Map? ?? const {})),
        seed: json['seed'] as int? ?? 1,
      );
}
