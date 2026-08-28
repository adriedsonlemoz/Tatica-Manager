import '../career/manager_career.dart';
import '../career/manager_profile.dart';
import '../club/club.dart';
import '../finance/club_administration.dart';
import '../finance/finance.dart';
import '../formation/formation.dart';
import '../league/standing.dart';
import '../match/match_models.dart';
import '../player/player.dart';
import '../settings/audio_settings.dart';
import '../settings/match_presentation_settings.dart';
import '../tactic/tactic.dart';
import '../transfer/market_career.dart';
import 'career_event.dart';
import 'competition_state.dart';
import 'inbox_message.dart';
import 'league_loading.dart';

class SeasonSummary {
  const SeasonSummary({
    required this.season,
    required this.clubId,
    required this.position,
    required this.points,
    required this.wins,
    required this.draws,
    required this.losses,
  });

  final int season;
  final String clubId;
  final int position;
  final int points;
  final int wins;
  final int draws;
  final int losses;

  Map<String, dynamic> toJson() => {
        'season': season,
        'clubId': clubId,
        'position': position,
        'points': points,
        'wins': wins,
        'draws': draws,
        'losses': losses,
      };

  factory SeasonSummary.fromJson(Map<String, dynamic> json) => SeasonSummary(
        season: json['season'] as int? ?? 2026,
        clubId: json['clubId'] as String? ?? '',
        position: json['position'] as int? ?? 20,
        points: json['points'] as int? ?? 0,
        wins: json['wins'] as int? ?? 0,
        draws: json['draws'] as int? ?? 0,
        losses: json['losses'] as int? ?? 0,
      );
}

class GameSettings {
  const GameSettings({
    this.haptics = true,
    this.sound = true,
    this.matchSpeed = 1,
    this.matchBallStyle = 0,
    this.matchDurationMinutes = 2,
    this.audio = const AudioSettings(),
  });

  final bool haptics;

  /// Legacy master switch kept for save compatibility.
  final bool sound;
  final int matchSpeed;
  final int matchBallStyle;
  final int matchDurationMinutes;
  final AudioSettings audio;

  GameSettings copyWith({
    bool? haptics,
    bool? sound,
    int? matchSpeed,
    int? matchBallStyle,
    int? matchDurationMinutes,
    AudioSettings? audio,
  }) =>
      GameSettings(
        haptics: haptics ?? this.haptics,
        sound: sound ?? this.sound,
        matchSpeed: matchSpeed ?? this.matchSpeed,
        matchBallStyle: matchBallStyle ?? this.matchBallStyle,
        matchDurationMinutes:
            matchDurationMinutes ?? this.matchDurationMinutes,
        audio: audio ?? this.audio,
      );

  Map<String, dynamic> toJson() => {
        'haptics': haptics,
        'sound': sound,
        'matchSpeed': matchSpeed,
        'matchBallStyle': matchBallStyle,
        'matchDurationMinutes': matchDurationMinutes,
        'audio': audio.toJson(),
      };

  factory GameSettings.fromJson(Map<String, dynamic> json) => GameSettings(
        haptics: json['haptics'] as bool? ?? true,
        sound: json['sound'] as bool? ?? true,
        matchSpeed: _matchSpeed(json['matchSpeed']),
        matchBallStyle:
            (json['matchBallStyle'] as num?)?.toInt().clamp(0, 3).toInt() ?? 0,
        matchDurationMinutes: MatchDurationPreset.fromMinutes(
          json['matchDurationMinutes'],
        ).minutes,
        audio: AudioSettings.fromJson(
          json['audio'] == null
              ? null
              : Map<String, dynamic>.from(json['audio'] as Map),
        ),
      );

  static int _matchSpeed(Object? value) {
    final speed = value is num ? value.toInt() : 1;
    return const {1, 2, 4}.contains(speed) ? speed : 1;
  }
}

class CareerState {
  const CareerState({
    required this.schemaVersion,
    required this.careerId,
    required this.careerName,
    required this.manager,
    required this.managerCareer,
    this.managers = const [],
    required this.createdAt,
    required this.season,
    required this.primaryCompetitionId,
    required this.roundIndex,
    required this.currentDate,
    required this.userClubId,
    required this.clubs,
    required this.freeAgents,
    required this.fixtures,
    required this.standings,
    required this.formation,
    required this.tactic,
    required this.starterIds,
    required this.finances,
    required this.seasonHistory,
    required this.news,
    required this.matchHistory,
    required this.settings,
    this.managerHistory = const [],
    this.scoutingReports = const [],
    this.transferNegotiations = const [],
    this.transferInstallments = const [],
    this.inbox = const [],
    this.youthAcademy = const [],
    this.clubAdministration = const ClubAdministrationState(),
    this.leagueSetup = const CareerLeagueSetup(),
    this.competitionStates = const [],
    this.lastMatch,
  });

  static const int currentSchemaVersion = 13;
  static const int maxStoredNews = 80;

  final int schemaVersion;
  final String careerId;
  final String careerName;
  final ManagerProfile manager;
  final ManagerCareerState managerCareer;
  final List<ManagerProfile> managers;
  final DateTime createdAt;
  final int season;
  final String primaryCompetitionId;

  /// Espelho legado da competição principal. Continua persistido por uma
  /// versão para manter compatibilidade com saves e telas antigas. O estado
  /// autoritativo multi-competição fica em [competitionStates].
  final int roundIndex;
  final DateTime currentDate;
  final String userClubId;
  final List<Club> clubs;
  final List<Player> freeAgents;
  final List<MatchFixture> fixtures;
  final List<Standing> standings;
  final FormationType formation;
  final Tactic tactic;
  final List<String> starterIds;
  final List<FinanceTransaction> finances;
  final List<SeasonSummary> seasonHistory;
  final List<CareerEvent> news;
  final List<MatchResult> matchHistory;
  final GameSettings settings;
  final List<ManagerCareerHistoryEntry> managerHistory;
  final List<PlayerScoutingReport> scoutingReports;
  final List<TransferNegotiation> transferNegotiations;
  final List<TransferInstallmentPayment> transferInstallments;
  final List<InboxMessage> inbox;
  final List<Player> youthAcademy;
  final ClubAdministrationState clubAdministration;
  final CareerLeagueSetup leagueSetup;
  final List<CompetitionSeasonState> competitionStates;
  final MatchResult? lastMatch;

  Club get userClub => clubs.firstWhere((club) => club.id == userClubId);
  bool get managerEmployed => managerCareer.isEmployed;
  bool get managerUnemployed => managerCareer.isUnemployed;

  CompetitionSeasonState? competitionStateOrNull(String competitionId) =>
      competitionStates
          .where((state) => state.competitionId == competitionId)
          .firstOrNull;

  CompetitionSeasonState competitionStateFor(String competitionId) {
    final stored = competitionStateOrNull(competitionId);
    if (stored != null) return stored;
    final participants = <String>{};
    for (final fixture in fixtures) {
      if (fixture.competitionId != competitionId) continue;
      participants.add(fixture.homeClubId);
      participants.add(fixture.awayClubId);
    }
    return CompetitionSeasonState(
      competitionId: competitionId,
      participantClubIds: participants.toList(growable: false),
      roundIndex: competitionId == primaryCompetitionId ? roundIndex : 0,
      standings: competitionId == primaryCompetitionId ? standings : const [],
      completed: fixtures
              .where((fixture) => fixture.competitionId == competitionId)
              .isNotEmpty &&
          fixtures
              .where((fixture) => fixture.competitionId == competitionId)
              .every((fixture) => fixture.played),
    );
  }

  List<Standing> standingsFor(String competitionId) =>
      competitionStateFor(competitionId).standings;

  PlayerSeasonStats playerStatsForCompetition(
    String competitionId,
    String playerId,
  ) =>
      competitionStateFor(competitionId).statsForPlayer(playerId);

  PlayerDiscipline playerDisciplineForCompetition(
    String competitionId,
    String playerId,
  ) =>
      competitionStateFor(competitionId).disciplineForPlayer(playerId);

  Set<String> suspendedPlayerIdsForCompetition(String competitionId) =>
      competitionStateFor(competitionId).suspendedPlayerIds;

  bool isPlayerAvailableForCompetition(
    Player player,
    String competitionId,
  ) {
    if (player.injury != null || player.condition < 35) return false;
    return !suspendedPlayerIdsForCompetition(competitionId).contains(player.id);
  }

  List<Player> unavailableUserPlayersForCompetition(String competitionId) =>
      userClub.squad
          .where((player) => !isPlayerAvailableForCompetition(player, competitionId))
          .toList(growable: false);

  List<MatchFixture> fixturesForCompetition(String competitionId) => fixtures
      .where((fixture) => fixture.competitionId == competitionId)
      .toList(growable: false);

  List<MatchFixture> get primaryCompetitionFixtures =>
      fixturesForCompetition(primaryCompetitionId);

  Set<String> clubIdsForCompetition(String competitionId) {
    final stored = competitionStateOrNull(competitionId);
    if (stored != null && stored.participantClubIds.isNotEmpty) {
      return stored.participantClubIds.toSet();
    }
    final ids = <String>{};
    for (final fixture in fixtures) {
      if (fixture.competitionId != competitionId) continue;
      ids.add(fixture.homeClubId);
      ids.add(fixture.awayClubId);
    }
    return ids;
  }

  Set<String> get primaryCompetitionClubIds {
    final ids = clubIdsForCompetition(primaryCompetitionId);
    if (ids.isEmpty) ids.addAll(clubs.map((club) => club.id));
    return ids;
  }

  List<Club> clubsForCompetition(
    String competitionId, [
    List<Club>? source,
  ]) {
    final values = source ?? clubs;
    final allowed = clubIdsForCompetition(competitionId);
    return values
        .where((club) => allowed.contains(club.id))
        .toList(growable: false);
  }

  List<Club> clubsForPrimaryCompetition([List<Club>? source]) =>
      clubsForCompetition(primaryCompetitionId, source);

  int totalRoundsForCompetition(String competitionId) {
    var total = 0;
    for (final fixture in fixtures) {
      if (fixture.competitionId == competitionId && fixture.round > total) {
        total = fixture.round;
      }
    }
    return total;
  }

  int get totalUserRounds {
    final total = totalRoundsForCompetition(primaryCompetitionId);
    return total > 0 ? total : 38;
  }

  bool get seasonComplete {
    final loadedCompetitionIds = leagueSetup.loadedCompetitionIds.toSet();
    if (loadedCompetitionIds.isEmpty) {
      return fixtures.isNotEmpty && fixtures.every((fixture) => fixture.played);
    }

    var foundLoadedCompetition = false;
    for (final competitionId in loadedCompetitionIds) {
      final competitionFixtures = fixtures
          .where((fixture) => fixture.competitionId == competitionId)
          .toList(growable: false);
      if (competitionFixtures.isNotEmpty) {
        foundLoadedCompetition = true;
        if (competitionFixtures.any((fixture) => !fixture.played)) {
          return false;
        }
        continue;
      }

      final storedState = competitionStateOrNull(competitionId);
      if (storedState == null || !storedState.completed) {
        return false;
      }
      foundLoadedCompetition = true;
    }
    return foundLoadedCompetition;
  }

  int get currentRound =>
      (roundIndex + 1).clamp(1, totalUserRounds).toInt();

  CareerState withCompetitionState(CompetitionSeasonState updated) {
    final values = <CompetitionSeasonState>[
      for (final state in competitionStates)
        if (state.competitionId != updated.competitionId) state,
      updated,
    ];
    return copyWith(competitionStates: values);
  }

  MatchFixture? get nextUserFixture {
    if (seasonComplete || managerUnemployed) return null;
    final pending = fixtures
        .where(
          (fixture) =>
              !fixture.played &&
              (fixture.homeClubId == userClubId || fixture.awayClubId == userClubId),
        )
        .toList()
      ..sort((a, b) {
        final date = a.date.compareTo(b.date);
        return date != 0 ? date : a.round.compareTo(b.round);
      });
    return pending.isEmpty ? null : pending.first;
  }

  bool get isMatchDay {
    final fixture = nextUserFixture;
    return fixture != null && _sameDate(currentDate, fixture.date);
  }

  int? get daysUntilNextMatch {
    final fixture = nextUserFixture;
    if (fixture == null) return null;
    return _dateOnly(fixture.date).difference(_dateOnly(currentDate)).inDays;
  }

  List<Player> get unavailableUserPlayers =>
      userClub.squad.where((player) => !player.isAvailable).toList();

  CareerState copyWith({
    int? schemaVersion,
    String? careerId,
    String? careerName,
    ManagerProfile? manager,
    ManagerCareerState? managerCareer,
    List<ManagerProfile>? managers,
    DateTime? createdAt,
    int? season,
    String? primaryCompetitionId,
    int? roundIndex,
    DateTime? currentDate,
    String? userClubId,
    List<Club>? clubs,
    List<Player>? freeAgents,
    List<MatchFixture>? fixtures,
    List<Standing>? standings,
    FormationType? formation,
    Tactic? tactic,
    List<String>? starterIds,
    List<FinanceTransaction>? finances,
    List<SeasonSummary>? seasonHistory,
    List<CareerEvent>? news,
    List<MatchResult>? matchHistory,
    GameSettings? settings,
    List<ManagerCareerHistoryEntry>? managerHistory,
    List<PlayerScoutingReport>? scoutingReports,
    List<TransferNegotiation>? transferNegotiations,
    List<TransferInstallmentPayment>? transferInstallments,
    List<InboxMessage>? inbox,
    List<Player>? youthAcademy,
    ClubAdministrationState? clubAdministration,
    CareerLeagueSetup? leagueSetup,
    List<CompetitionSeasonState>? competitionStates,
    MatchResult? lastMatch,
    bool clearLastMatch = false,
  }) {
    final nextPrimaryId = primaryCompetitionId ?? this.primaryCompetitionId;
    var nextStates = competitionStates ?? this.competitionStates;
    var nextRoundIndex = roundIndex ?? this.roundIndex;
    var nextStandings = standings ?? this.standings;

    if (competitionStates != null || primaryCompetitionId != null) {
      final primary = nextStates
          .where((state) => state.competitionId == nextPrimaryId)
          .firstOrNull;
      if (primary != null) {
        if (roundIndex == null) nextRoundIndex = primary.roundIndex;
        if (standings == null) nextStandings = primary.standings;
      }
    }

    if (roundIndex != null || standings != null) {
      final existing = nextStates
          .where((state) => state.competitionId == nextPrimaryId)
          .firstOrNull;
      if (existing != null) {
        final updated = existing.copyWith(
          roundIndex: nextRoundIndex,
          standings: nextStandings,
        );
        nextStates = [
          for (final state in nextStates)
            if (state.competitionId != nextPrimaryId) state,
          updated,
        ];
      }
    }

    return CareerState(
      schemaVersion: schemaVersion ?? this.schemaVersion,
      careerId: careerId ?? this.careerId,
      careerName: careerName ?? this.careerName,
      manager: manager ?? this.manager,
      managerCareer: managerCareer ?? this.managerCareer,
      managers: managers ?? this.managers,
      createdAt: createdAt ?? this.createdAt,
      season: season ?? this.season,
      primaryCompetitionId: nextPrimaryId,
      roundIndex: nextRoundIndex,
      currentDate: currentDate ?? this.currentDate,
      userClubId: userClubId ?? this.userClubId,
      clubs: clubs ?? this.clubs,
      freeAgents: freeAgents ?? this.freeAgents,
      fixtures: fixtures ?? this.fixtures,
      standings: nextStandings,
      formation: formation ?? this.formation,
      tactic: tactic ?? this.tactic,
      starterIds: starterIds ?? this.starterIds,
      finances: finances ?? this.finances,
      seasonHistory: seasonHistory ?? this.seasonHistory,
      news: news ?? this.news,
      matchHistory: matchHistory ?? this.matchHistory,
      settings: settings ?? this.settings,
      managerHistory: managerHistory ?? this.managerHistory,
      scoutingReports: scoutingReports ?? this.scoutingReports,
      transferNegotiations: transferNegotiations ?? this.transferNegotiations,
      transferInstallments: transferInstallments ?? this.transferInstallments,
      inbox: inbox ?? this.inbox,
      youthAcademy: youthAcademy ?? this.youthAcademy,
      clubAdministration: clubAdministration ?? this.clubAdministration,
      leagueSetup: leagueSetup ?? this.leagueSetup,
      competitionStates: nextStates,
      lastMatch: clearLastMatch ? null : (lastMatch ?? this.lastMatch),
    );
  }

  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'careerId': careerId,
        'careerName': careerName,
        'manager': manager.toJson(),
        'managerCareer': managerCareer.toJson(),
        'managers': managers.map((e) => e.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'season': season,
        'primaryCompetitionId': primaryCompetitionId,
        'roundIndex': roundIndex,
        'currentDate': currentDate.toIso8601String(),
        'userClubId': userClubId,
        'clubs': clubs.map((e) => e.toJson()).toList(),
        'freeAgents': freeAgents.map((e) => e.toJson()).toList(),
        'fixtures': fixtures.map((e) => e.toJson()).toList(),
        'standings': standings.map((e) => e.toJson()).toList(),
        'formation': formation.name,
        'tactic': tactic.toJson(),
        'starterIds': starterIds,
        'finances': finances.map((e) => e.toJson()).toList(),
        'seasonHistory': seasonHistory.map((e) => e.toJson()).toList(),
        'news': news.map((e) => e.toJson()).toList(),
        'matchHistory': matchHistory.map((e) => e.toJson()).toList(),
        'settings': settings.toJson(),
        'managerHistory': managerHistory.map((e) => e.toJson()).toList(),
        'scoutingReports': scoutingReports.map((e) => e.toJson()).toList(),
        'transferNegotiations': transferNegotiations.map((e) => e.toJson()).toList(),
        'transferInstallments': transferInstallments.map((e) => e.toJson()).toList(),
        'inbox': inbox.map((e) => e.toJson()).toList(),
        'youthAcademy': youthAcademy.map((e) => e.toJson()).toList(),
        'clubAdministration': clubAdministration.toJson(),
        'leagueSetup': leagueSetup.toJson(),
        'competitionStates': competitionStates.map((e) => e.toJson()).toList(),
        'lastMatch': lastMatch?.toJson(),
      };

  factory CareerState.fromJson(Map<String, dynamic> json) {
    final season = json['season'] as int? ?? 2026;
    final userClubId = json['userClubId'] as String? ?? '';
    final clubs = ((json['clubs'] as List?) ?? const [])
        .map((e) => Club.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    final fixtures = ((json['fixtures'] as List?) ?? const [])
        .map((e) => MatchFixture.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    final derivedUserCompetitionId = fixtures
        .where(
          (fixture) =>
              fixture.homeClubId == userClubId ||
              fixture.awayClubId == userClubId,
        )
        .map((fixture) => fixture.competitionId)
        .firstOrNull ??
        (fixtures.isNotEmpty ? fixtures.first.competitionId : 'br-series-a');
    final storedPrimaryCompetitionId =
        (json['primaryCompetitionId'] as String?)?.trim();
    final primaryCompetitionId = storedPrimaryCompetitionId?.isNotEmpty == true
        ? storedPrimaryCompetitionId!
        : derivedUserCompetitionId;
    final leagueSetup = json['leagueSetup'] is Map
        ? CareerLeagueSetup.fromJson(
            Map<String, dynamic>.from(json['leagueSetup'] as Map),
          ).ensureFull(primaryCompetitionId)
        : CareerLeagueSetup.legacy(
            competitionIds: fixtures.map((fixture) => fixture.competitionId),
            userCompetitionId: primaryCompetitionId,
          );
    final legacyRoundIndex = (json['roundIndex'] as num?)?.toInt() ?? 0;
    final legacyStandings = ((json['standings'] as List?) ?? const [])
        .whereType<Map>()
        .map((item) => Standing.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
    final storedCompetitionStates =
        ((json['competitionStates'] as List?) ?? const [])
            .whereType<Map>()
            .map(
              (item) => CompetitionSeasonState.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .where((state) => state.competitionId.isNotEmpty)
            .toList(growable: false);
    final competitionStates = storedCompetitionStates.isNotEmpty
        ? storedCompetitionStates
        : _legacyCompetitionStates(
            clubs: clubs,
            fixtures: fixtures,
            primaryCompetitionId: primaryCompetitionId,
            primaryRoundIndex: legacyRoundIndex,
            primaryStandings: legacyStandings,
          );
    final primaryState = competitionStates
        .where((state) => state.competitionId == primaryCompetitionId)
        .firstOrNull;
    final legacyManagerName = clubs
        .where((club) => club.id == userClubId)
        .map((club) => club.managerName)
        .firstOrNull;
    final careerId = (json['careerId'] as String?)?.trim();
    final careerName = (json['careerName'] as String?)?.trim();
    final createdAtValue = json['createdAt'] as String?;
    final currentDateValue = json['currentDate'] as String?;
    final lastMatch = json['lastMatch'] == null
        ? null
        : MatchResult.fromJson(
            Map<String, dynamic>.from(json['lastMatch'] as Map),
          );
    final storedMatchHistory = ((json['matchHistory'] as List?) ?? const [])
        .map((e) => MatchResult.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    final matchHistory = storedMatchHistory.isEmpty && lastMatch != null
        ? <MatchResult>[lastMatch]
        : storedMatchHistory;
    final manager = json['manager'] is Map
        ? ManagerProfile.fromJson(Map<String, dynamic>.from(json['manager'] as Map))
        : ManagerProfile(
            displayName: legacyManagerName?.isNotEmpty == true
                ? legacyManagerName!
                : 'Técnico',
            careerStartSeason: season,
          );
    final resolvedCareerId =
        careerId?.isNotEmpty == true ? careerId! : 'legacy-$userClubId-$season';
    final normalizedManager = manager.copyWith(
      id: manager.id.trim().isNotEmpty
          ? manager.id.trim()
          : 'manager-user-$resolvedCareerId',
      currentClubId: userClubId,
      careerStartSeason: season,
    );
    final storedManagerHistory = ((json['managerHistory'] as List?) ?? const [])
        .whereType<Map>()
        .map((item) => ManagerCareerHistoryEntry.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .toList(growable: false);
    final managerHistory = storedManagerHistory.isNotEmpty
        ? storedManagerHistory
        : <ManagerCareerHistoryEntry>[
            ManagerCareerHistoryEntry.fromProfile(
              normalizedManager,
              season: season,
              clubId: userClubId,
            ),
          ];
    final fallbackManagerDate = DateTime.tryParse(currentDateValue ?? '') ??
        _legacyCurrentDate(fixtures, userClubId, season);
    final managerCareer = json['managerCareer'] is Map
        ? ManagerCareerState.fromJson(
            Map<String, dynamic>.from(json['managerCareer'] as Map),
            fallbackClubId: userClubId,
            fallbackSeason: season,
            fallbackDate: fallbackManagerDate,
          )
        : ManagerCareerState.initial(
            clubId: userClubId,
            season: season,
            startedAt: fallbackManagerDate,
          );

    final storedManagers = ((json['managers'] as List?) ?? const [])
        .whereType<Map>()
        .map((item) => ManagerProfile.fromJson(Map<String, dynamic>.from(item)))
        .where((item) => item.displayName.trim().isNotEmpty)
        .toList(growable: false);
    final managers = storedManagers.isNotEmpty
        ? _normalizeManagerDatabase(
            storedManagers,
            clubs: clubs,
            userClubId: userClubId,
            userManager: normalizedManager,
            careerId: resolvedCareerId,
            season: season,
          )
        : _legacyManagerDatabase(
            clubs: clubs,
            userClubId: userClubId,
            userManager: normalizedManager,
            careerId: resolvedCareerId,
            season: season,
          );

    return CareerState(
      schemaVersion: currentSchemaVersion,
      careerId: resolvedCareerId,
      careerName: careerName?.isNotEmpty == true ? careerName! : 'Carreira $season',
      manager: normalizedManager,
      managerCareer: managerCareer,
      managers: managers,
      createdAt: DateTime.tryParse(createdAtValue ?? '') ?? DateTime(season),
      season: season,
      primaryCompetitionId: primaryCompetitionId,
      roundIndex: primaryState?.roundIndex ?? legacyRoundIndex,
      currentDate: DateTime.tryParse(currentDateValue ?? '') ??
          _legacyCurrentDate(fixtures, userClubId, season),
      userClubId: userClubId,
      clubs: clubs,
      freeAgents: ((json['freeAgents'] as List?) ?? const [])
          .map((e) => Player.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      fixtures: fixtures,
      standings: primaryState?.standings ?? legacyStandings,
      formation: FormationType.values.firstWhere(
        (e) => e.name == json['formation'],
        orElse: () => FormationType.f433,
      ),
      tactic: Tactic.fromJson(Map<String, dynamic>.from(json['tactic'] as Map? ?? const {})),
      starterIds: ((json['starterIds'] as List?) ?? const []).map((e) => e.toString()).toList(),
      finances: ((json['finances'] as List?) ?? const [])
          .map((e) => FinanceTransaction.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      seasonHistory: ((json['seasonHistory'] as List?) ?? const [])
          .map((e) => SeasonSummary.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      news: ((json['news'] as List?) ?? const [])
          .map((e) => CareerEvent.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      matchHistory: matchHistory,
      settings: GameSettings.fromJson(
        Map<String, dynamic>.from(json['settings'] as Map? ?? const {}),
      ),
      managerHistory: managerHistory,
      scoutingReports: ((json['scoutingReports'] as List?) ?? const [])
          .whereType<Map>()
          .map((item) => PlayerScoutingReport.fromJson(Map<String, dynamic>.from(item)))
          .where((item) => item.playerId.isNotEmpty)
          .toList(growable: false),
      transferNegotiations: ((json['transferNegotiations'] as List?) ?? const [])
          .whereType<Map>()
          .map((item) => TransferNegotiation.fromJson(Map<String, dynamic>.from(item)))
          .where((item) => item.id.isNotEmpty && item.playerId.isNotEmpty)
          .toList(growable: false),
      transferInstallments: ((json['transferInstallments'] as List?) ?? const [])
          .whereType<Map>()
          .map((item) => TransferInstallmentPayment.fromJson(Map<String, dynamic>.from(item)))
          .where((item) => item.id.isNotEmpty && item.amount > 0)
          .toList(growable: false),
      inbox: ((json['inbox'] as List?) ?? const [])
          .whereType<Map>()
          .map((item) => InboxMessage.fromJson(Map<String, dynamic>.from(item)))
          .where((item) => item.id.isNotEmpty)
          .toList(growable: false),
      youthAcademy: ((json['youthAcademy'] as List?) ?? const [])
          .whereType<Map>()
          .map((item) => Player.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false),
      clubAdministration: ClubAdministrationState.fromJson(
        Map<String, dynamic>.from(
          json['clubAdministration'] as Map? ?? const {},
        ),
      ),
      leagueSetup: leagueSetup,
      competitionStates: competitionStates,
      lastMatch: lastMatch,
    );
  }

  static List<CompetitionSeasonState> _legacyCompetitionStates({
    required List<Club> clubs,
    required List<MatchFixture> fixtures,
    required String primaryCompetitionId,
    required int primaryRoundIndex,
    required List<Standing> primaryStandings,
  }) {
    final ids = fixtures.map((fixture) => fixture.competitionId).toSet();
    if (ids.isEmpty) ids.add(primaryCompetitionId);
    final legacyPlayerStats = <String, PlayerSeasonStats>{
      for (final club in clubs)
        for (final player in club.squad)
          if (player.stats.appearances > 0 ||
              player.stats.goals > 0 ||
              player.stats.assists > 0 ||
              player.stats.yellowCards > 0 ||
              player.stats.redCards > 0)
            player.id: player.stats,
    };
    final legacyPlayerDiscipline = <String, PlayerDiscipline>{
      for (final club in clubs)
        for (final player in club.squad)
          if (player.discipline.yellowCards > 0 ||
              player.discipline.redCards > 0 ||
              player.discipline.suspendedRounds > 0)
            player.id: player.discipline,
    };

    return ids.map((competitionId) {
      final competitionFixtures = fixtures
          .where((fixture) => fixture.competitionId == competitionId)
          .toList(growable: false);
      final participants = <String>{
        for (final fixture in competitionFixtures) ...[
          fixture.homeClubId,
          fixture.awayClubId,
        ],
      };
      var completedRound = 0;
      final rounds = competitionFixtures.map((fixture) => fixture.round).toSet()
        ..removeWhere((round) => round <= 0);
      final orderedRounds = rounds.toList()..sort();
      for (final round in orderedRounds) {
        final roundFixtures = competitionFixtures.where(
          (fixture) => fixture.round == round,
        );
        if (roundFixtures.isNotEmpty &&
            roundFixtures.every((fixture) => fixture.played)) {
          completedRound = round;
        } else {
          break;
        }
      }
      final isPrimary = competitionId == primaryCompetitionId;
      final participantClubIds = participants.toList(growable: false);
      final standings = isPrimary ? primaryStandings : const <Standing>[];
      final completed = competitionFixtures.isNotEmpty &&
          competitionFixtures.every((fixture) => fixture.played);
      return CompetitionSeasonState(
        competitionId: competitionId,
        participantClubIds: participantClubIds,
        roundIndex: isPrimary ? primaryRoundIndex : completedRound,
        standings: standings,
        playerStats: isPrimary ? legacyPlayerStats : const {},
        playerDiscipline: isPrimary ? legacyPlayerDiscipline : const {},
        stages: standings.isEmpty
            ? const []
            : [
                CompetitionStageState(
                  id: 'main',
                  kind: CompetitionStageKind.league,
                  participantClubIds: participantClubIds,
                  roundIndex: isPrimary ? primaryRoundIndex : completedRound,
                  standingsByGroup: {'main': standings},
                  completed: completed,
                ),
              ],
        completed: completed,
      );
    }).toList(growable: false);
  }

  static List<ManagerProfile> _legacyManagerDatabase({
    required List<Club> clubs,
    required String userClubId,
    required ManagerProfile userManager,
    required String careerId,
    required int season,
  }) {
    return clubs.map((club) {
      if (club.id == userClubId) {
        final id = userManager.id.trim().isNotEmpty
            ? userManager.id
            : 'manager-user-$careerId';
        return userManager.copyWith(
          id: id,
          currentClubId: userClubId,
          careerStartSeason: season,
        );
      }
      return ManagerProfile(
        id: 'manager-${club.id}',
        displayName: club.managerName.trim().isEmpty
            ? 'Técnico ${club.shortName}'
            : club.managerName,
        nationality: 'Brasil',
        ageAtStart: 42,
        careerStartSeason: season,
        currentClubId: club.id,
        reputation: club.reputation.clamp(1, 100).toInt(),
        overall: club.reputation.clamp(1, 100).toInt(),
      );
    }).toList(growable: false);
  }

  static List<ManagerProfile> _normalizeManagerDatabase(
    List<ManagerProfile> source, {
    required List<Club> clubs,
    required String userClubId,
    required ManagerProfile userManager,
    required String careerId,
    required int season,
  }) {
    final clubIds = clubs.map((club) => club.id).toSet();
    final seenIds = <String>{};
    final normalized = <ManagerProfile>[];
    for (var i = 0; i < source.length; i++) {
      final item = source[i];
      final fallbackId = item.currentClubId?.trim().isNotEmpty == true
          ? 'manager-${item.currentClubId}'
          : 'manager-imported-$i';
      final id = item.id.trim().isEmpty ? fallbackId : item.id.trim();
      if (!seenIds.add(id)) continue;
      final currentClubId = item.currentClubId;
      normalized.add(
        item.copyWith(
          id: id,
          currentClubId:
              currentClubId != null && clubIds.contains(currentClubId)
                  ? currentClubId
                  : null,
          clearCurrentClub:
              currentClubId == null || !clubIds.contains(currentClubId),
          careerStartSeason: item.careerStartSeason <= 0
              ? season
              : item.careerStartSeason,
        ),
      );
    }

    final userId = userManager.id.trim().isNotEmpty
        ? userManager.id.trim()
        : 'manager-user-$careerId';
    final userEntry = userManager.copyWith(
      id: userId,
      currentClubId: userClubId,
      careerStartSeason: season,
    );
    final userIndex = normalized.indexWhere(
      (item) => item.id == userId || item.currentClubId == userClubId,
    );
    if (userIndex >= 0) {
      normalized[userIndex] = userEntry;
    } else {
      normalized.add(userEntry);
    }

    for (final club in clubs) {
      if (club.id == userClubId ||
          normalized.any((item) => item.currentClubId == club.id)) {
        continue;
      }
      normalized.add(
        ManagerProfile(
          id: 'manager-${club.id}',
          displayName: club.managerName.trim().isEmpty
              ? 'Técnico ${club.shortName}'
              : club.managerName,
          nationality: 'Brasil',
          ageAtStart: 42,
          careerStartSeason: season,
          currentClubId: club.id,
          reputation: club.reputation.clamp(1, 100).toInt(),
          overall: club.reputation.clamp(1, 100).toInt(),
        ),
      );
    }
    return List.unmodifiable(normalized);
  }

  static DateTime _legacyCurrentDate(
    List<MatchFixture> fixtures,
    String userClubId,
    int season,
  ) {
    final userFixtures = fixtures
        .where(
          (fixture) =>
              fixture.homeClubId == userClubId || fixture.awayClubId == userClubId,
        )
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    if (userFixtures.isEmpty) return DateTime(season, 1, 1);

    final played = userFixtures.where((fixture) => fixture.played).toList();
    if (played.isNotEmpty) return _dateOnly(played.last.date);

    return _dateOnly(userFixtures.first.date).subtract(const Duration(days: 3));
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static bool _sameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
