import '../league/standing.dart';
import '../player/player.dart';


enum CompetitionStageKind { league, group, knockout, singleMatch }

/// Estado genérico de uma fase. A liga atual usa uma única fase `main`; copas
/// futuras podem persistir grupos/chaves sem mudar novamente o schema do save.
class CompetitionStageState {
  const CompetitionStageState({
    required this.id,
    required this.kind,
    required this.participantClubIds,
    this.index = 0,
    this.roundIndex = 0,
    this.standingsByGroup = const {},
    this.completed = false,
  });

  final String id;
  final CompetitionStageKind kind;
  final List<String> participantClubIds;
  final int index;
  final int roundIndex;
  final Map<String, List<Standing>> standingsByGroup;
  final bool completed;

  CompetitionStageState copyWith({
    List<String>? participantClubIds,
    int? index,
    int? roundIndex,
    Map<String, List<Standing>>? standingsByGroup,
    bool? completed,
  }) =>
      CompetitionStageState(
        id: id,
        kind: kind,
        participantClubIds: participantClubIds ?? this.participantClubIds,
        index: index ?? this.index,
        roundIndex: roundIndex ?? this.roundIndex,
        standingsByGroup: standingsByGroup ?? this.standingsByGroup,
        completed: completed ?? this.completed,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'participantClubIds': participantClubIds,
        'index': index,
        'roundIndex': roundIndex,
        'standingsByGroup': {
          for (final entry in standingsByGroup.entries)
            entry.key: entry.value.map((standing) => standing.toJson()).toList(),
        },
        'completed': completed,
      };

  factory CompetitionStageState.fromJson(Map<String, dynamic> json) {
    final groups = <String, List<Standing>>{};
    final rawGroups = json['standingsByGroup'];
    if (rawGroups is Map) {
      for (final entry in rawGroups.entries) {
        final raw = entry.value;
        if (raw is! List) continue;
        groups[entry.key.toString()] = raw
            .whereType<Map>()
            .map((item) => Standing.fromJson(Map<String, dynamic>.from(item)))
            .toList(growable: false);
      }
    }
    return CompetitionStageState(
      id: json['id'] as String? ?? 'main',
      kind: CompetitionStageKind.values.firstWhere(
        (value) => value.name == json['kind'],
        orElse: () => CompetitionStageKind.league,
      ),
      participantClubIds: ((json['participantClubIds'] as List?) ?? const [])
          .map((item) => item.toString())
          .where((item) => item.isNotEmpty)
          .toList(growable: false),
      index: (json['index'] as num?)?.toInt() ?? 0,
      roundIndex: (json['roundIndex'] as num?)?.toInt() ?? 0,
      standingsByGroup: groups,
      completed: json['completed'] as bool? ?? false,
    );
  }
}

/// Estado persistido de uma competição dentro de uma temporada da carreira.
///
/// O calendário continua global em [CareerState.fixtures]; aqui ficam apenas
/// os dados que não podem ser compartilhados entre torneios: participantes,
/// progresso, classificação e estatísticas individuais da competição.
class CompetitionSeasonState {
  const CompetitionSeasonState({
    required this.competitionId,
    required this.participantClubIds,
    this.roundIndex = 0,
    this.standings = const [],
    this.playerStats = const {},
    this.playerDiscipline = const {},
    this.stages = const [],
    this.stageId = 'main',
    this.stageIndex = 0,
    this.completed = false,
  });

  final String competitionId;
  final List<String> participantClubIds;
  final int roundIndex;
  final List<Standing> standings;
  final Map<String, PlayerSeasonStats> playerStats;
  final Map<String, PlayerDiscipline> playerDiscipline;
  final List<CompetitionStageState> stages;

  /// Identificador genérico da fase. A liga atual usa `main`; futuros grupos
  /// e mata-matas podem trocar a fase sem alterar o formato do save.
  final String stageId;
  final int stageIndex;
  final bool completed;

  PlayerSeasonStats statsForPlayer(String playerId) =>
      playerStats[playerId] ?? const PlayerSeasonStats();

  PlayerDiscipline disciplineForPlayer(String playerId) =>
      playerDiscipline[playerId] ?? const PlayerDiscipline();

  Set<String> get suspendedPlayerIds => playerDiscipline.entries
      .where((entry) => entry.value.suspendedRounds > 0)
      .map((entry) => entry.key)
      .toSet();

  CompetitionSeasonState copyWith({
    List<String>? participantClubIds,
    int? roundIndex,
    List<Standing>? standings,
    Map<String, PlayerSeasonStats>? playerStats,
    Map<String, PlayerDiscipline>? playerDiscipline,
    List<CompetitionStageState>? stages,
    String? stageId,
    int? stageIndex,
    bool? completed,
  }) =>
      CompetitionSeasonState(
        competitionId: competitionId,
        participantClubIds: participantClubIds ?? this.participantClubIds,
        roundIndex: roundIndex ?? this.roundIndex,
        standings: standings ?? this.standings,
        playerStats: playerStats ?? this.playerStats,
        playerDiscipline: playerDiscipline ?? this.playerDiscipline,
        stages: stages ?? this.stages,
        stageId: stageId ?? this.stageId,
        stageIndex: stageIndex ?? this.stageIndex,
        completed: completed ?? this.completed,
      );

  Map<String, dynamic> toJson() => {
        'competitionId': competitionId,
        'participantClubIds': participantClubIds,
        'roundIndex': roundIndex,
        'standings': standings.map((item) => item.toJson()).toList(),
        'playerStats': {
          for (final entry in playerStats.entries)
            entry.key: entry.value.toJson(),
        },
        'playerDiscipline': {
          for (final entry in playerDiscipline.entries)
            entry.key: entry.value.toJson(),
        },
        'stages': stages.map((stage) => stage.toJson()).toList(),
        'stageId': stageId,
        'stageIndex': stageIndex,
        'completed': completed,
      };

  factory CompetitionSeasonState.fromJson(Map<String, dynamic> json) {
    final rawStats = json['playerStats'];
    final playerStats = <String, PlayerSeasonStats>{};
    if (rawStats is Map) {
      for (final entry in rawStats.entries) {
        if (entry.value is! Map) continue;
        final playerId = entry.key.toString().trim();
        if (playerId.isEmpty) continue;
        playerStats[playerId] = PlayerSeasonStats.fromJson(
          Map<String, dynamic>.from(entry.value as Map),
        );
      }
    }
    final rawDiscipline = json['playerDiscipline'];
    final playerDiscipline = <String, PlayerDiscipline>{};
    if (rawDiscipline is Map) {
      for (final entry in rawDiscipline.entries) {
        if (entry.value is! Map) continue;
        final playerId = entry.key.toString().trim();
        if (playerId.isEmpty) continue;
        playerDiscipline[playerId] = PlayerDiscipline.fromJson(
          Map<String, dynamic>.from(entry.value as Map),
        );
      }
    }
    return CompetitionSeasonState(
      competitionId: json['competitionId'] as String? ?? '',
      participantClubIds: ((json['participantClubIds'] as List?) ?? const [])
          .map((item) => item.toString())
          .where((item) => item.isNotEmpty)
          .toList(growable: false),
      roundIndex: (json['roundIndex'] as num?)?.toInt() ?? 0,
      standings: ((json['standings'] as List?) ?? const [])
          .whereType<Map>()
          .map(
            (item) => Standing.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false),
      playerStats: playerStats,
      playerDiscipline: playerDiscipline,
      stages: ((json['stages'] as List?) ?? const [])
          .whereType<Map>()
          .map((item) => CompetitionStageState.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList(growable: false),
      stageId: json['stageId'] as String? ?? 'main',
      stageIndex: (json['stageIndex'] as num?)?.toInt() ?? 0,
      completed: json['completed'] as bool? ?? false,
    );
  }
}
