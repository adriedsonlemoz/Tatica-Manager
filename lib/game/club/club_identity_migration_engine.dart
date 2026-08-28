import '../../data/club_seed.dart';
import '../../domain/career/manager_career.dart';
import '../../domain/career/manager_profile.dart';
import '../../domain/finance/finance.dart';
import '../../domain/league/standing.dart';
import '../../domain/match/match_models.dart';
import '../../domain/player/player.dart';
import '../../domain/season/career_event.dart';
import '../../domain/season/career_state.dart';

class ClubIdentityMigrationResult {
  const ClubIdentityMigrationResult({required this.state, required this.changed});

  final CareerState state;
  final bool changed;
}

abstract final class ClubIdentityMigrationEngine {
  static const Map<String, String> legacyIdMap = {
    'br-flamengo': 'br-club-001',
    'br-palmeiras': 'br-club-002',
    'br-cruzeiro': 'br-club-003',
    'br-mirassol': 'br-club-004',
    'br-fluminense': 'br-club-005',
    'br-bahia': 'br-club-006',
    'br-botafogo': 'br-club-007',
    'br-sao-paulo': 'br-club-008',
    'br-red-bull-bragantino': 'br-club-009',
    'br-corinthians': 'br-club-010',
    'br-gremio': 'br-club-011',
    'br-vasco-da-gama': 'br-club-012',
    'br-atletico-mg': 'br-club-013',
    'br-santos': 'br-club-014',
    'br-vitoria': 'br-club-015',
    'br-internacional': 'br-club-016',
    'br-coritiba': 'br-club-017',
    'br-athletico-pr': 'br-club-018',
    'br-chapecoense': 'br-club-019',
    'br-remo': 'br-club-020',
  };
  static ClubIdentityMigrationResult migrateLegacyIds(CareerState state) {
    final legacyClubs = state.clubs.where((club) => legacyIdMap.containsKey(club.id)).toList();
    if (legacyClubs.isEmpty) {
      return ClubIdentityMigrationResult(state: state, changed: false);
    }

    final seedById = {for (final seed in clubSeeds) seed.id: seed};
    final oldNamesByLegacyId = {for (final club in legacyClubs) club.id: club.name};
    final renameHistory = <String, String>{};
    for (final club in legacyClubs) {
      final newId = legacyIdMap[club.id]!;
      final seed = seedById[newId]!;
      renameHistory[club.name] = seed.name;
    }

    String mapId(String id) => legacyIdMap[id] ?? id;
    String? mapNullableId(String? id) => id == null ? null : mapId(id);

    final clubs = state.clubs.map((club) {
      final newId = legacyIdMap[club.id];
      if (newId == null) {
        return club.copyWith(
          squad: club.squad
              .map((player) => _migratePlayer(player, mapNullableId, renameHistory))
              .toList(growable: false),
        );
      }
      final seed = seedById[newId]!;
      return club.copyWith(
        id: newId,
        name: seed.name,
        nickname: seed.nickname,
        shortName: seed.shortName,
        stadium: club.stadium.copyWith(name: seed.stadium),
        squad: club.squad
            .map((player) => _migratePlayer(player, mapNullableId, renameHistory))
            .toList(growable: false),
      );
    }).toList(growable: false);
    final namesById = {for (final club in clubs) club.id: club.name};

    final newNamesByLegacyId = <String, String>{
      for (final entry in legacyIdMap.entries)
        if (oldNamesByLegacyId.containsKey(entry.key) &&
            namesById.containsKey(entry.value))
          entry.key: namesById[entry.value]!,
    };
    final migratedNews = state.news
        .map(
          (event) => CareerEvent(
            id: event.id,
            date: event.date,
            type: event.type,
            title: _replaceClubNames(
              event.title,
              oldNamesById: oldNamesByLegacyId,
              newNamesById: newNamesByLegacyId,
            ),
            message: _replaceClubNames(
              event.message,
              oldNamesById: oldNamesByLegacyId,
              newNamesById: newNamesByLegacyId,
            ),
            playerId: event.playerId,
            clubId: mapNullableId(event.clubId),
            amount: event.amount,
          ),
        )
        .toList(growable: false);

    return ClubIdentityMigrationResult(
      changed: true,
      state: state.copyWith(
        userClubId: mapId(state.userClubId),
        clubs: clubs,
        freeAgents: state.freeAgents
            .map((player) => _migratePlayer(player, mapNullableId, renameHistory))
            .toList(growable: false),
        fixtures: state.fixtures
            .map(
              (fixture) => MatchFixture(
                id: fixture.id,
                round: fixture.round,
                homeClubId: mapId(fixture.homeClubId),
                awayClubId: mapId(fixture.awayClubId),
                date: fixture.date,
                competitionId: fixture.competitionId,
                stageId: fixture.stageId,
                groupId: fixture.groupId,
                tieId: fixture.tieId,
                leg: fixture.leg,
                kickoffHour: fixture.kickoffHour,
                kickoffMinute: fixture.kickoffMinute,
                played: fixture.played,
                score: fixture.score,
              ),
            )
            .toList(growable: false),
        standings: state.standings
            .map(
              (standing) {
                final clubId = mapId(standing.clubId);
                return Standing(
                  clubId: clubId,
                  clubName: namesById[clubId] ?? standing.clubName,
                  played: standing.played,
                  wins: standing.wins,
                  draws: standing.draws,
                  losses: standing.losses,
                  goalsFor: standing.goalsFor,
                  goalsAgainst: standing.goalsAgainst,
                  points: standing.points,
                );
              },
            )
            .toList(growable: false),
        competitionStates: state.competitionStates
            .map(
              (competition) => competition.copyWith(
                participantClubIds: competition.participantClubIds
                    .map(mapId)
                    .toList(growable: false),
                standings: competition.standings
                    .map(
                      (standing) => _mapStanding(
                        standing,
                        mapId: mapId,
                        namesById: namesById,
                      ),
                    )
                    .toList(growable: false),
                stages: competition.stages
                    .map(
                      (stage) => stage.copyWith(
                        participantClubIds: stage.participantClubIds
                            .map(mapId)
                            .toList(growable: false),
                        standingsByGroup: {
                          for (final entry in stage.standingsByGroup.entries)
                            entry.key: entry.value
                                .map(
                                  (standing) => _mapStanding(
                                    standing,
                                    mapId: mapId,
                                    namesById: namesById,
                                  ),
                                )
                                .toList(growable: false),
                        },
                      ),
                    )
                    .toList(growable: false),
              ),
            )
            .toList(growable: false),
        seasonHistory: state.seasonHistory
            .map(
              (summary) => SeasonSummary(
                season: summary.season,
                clubId: mapId(summary.clubId),
                position: summary.position,
                points: summary.points,
                wins: summary.wins,
                draws: summary.draws,
                losses: summary.losses,
              ),
            )
            .toList(growable: false),
        managerHistory: state.managerHistory
            .map(
              (entry) => ManagerCareerHistoryEntry(
                season: entry.season,
                clubId: mapId(entry.clubId),
                displayName: entry.displayName,
                nickname: entry.nickname,
                age: entry.age,
                nationality: entry.nationality,
                birthPlace: entry.birthPlace,
              ),
            )
            .toList(growable: false),
        managerCareer: ManagerCareerState(
          status: state.managerCareer.status,
          tenures: state.managerCareer.tenures
              .map(
                (tenure) => ManagerClubTenure(
                  clubId: mapId(tenure.clubId),
                  startedAt: tenure.startedAt,
                  startSeason: tenure.startSeason,
                  endedAt: tenure.endedAt,
                  endSeason: tenure.endSeason,
                  endReason: tenure.endReason,
                ),
              )
              .toList(growable: false),
          offers: state.managerCareer.offers
              .map(
                (offer) => ManagerJobOffer(
                  id: offer.id,
                  clubId: mapId(offer.clubId),
                  createdAt: offer.createdAt,
                  expiresAt: offer.expiresAt,
                  interestScore: offer.interestScore,
                  reason: offer.reason,
                ),
              )
              .toList(growable: false),
        ),
        finances: state.finances
            .map(
              (transaction) => renameFinanceTransaction(
                transaction,
                oldNamesById: oldNamesByLegacyId,
                newNamesById: newNamesByLegacyId,
              ),
            )
            .toList(growable: false),
        news: migratedNews,
        matchHistory: state.matchHistory
            .map(
              (result) => _migrateMatchResult(
                result,
                mapId,
                oldNamesByLegacyId: oldNamesByLegacyId,
                newNamesById: namesById,
              ),
            )
            .toList(growable: false),
        lastMatch: state.lastMatch == null
            ? null
            : _migrateMatchResult(
                state.lastMatch!,
                mapId,
                oldNamesByLegacyId: oldNamesByLegacyId,
                newNamesById: namesById,
              ),
      ),
    );
  }

  static Player renamePlayerHistory(
    Player player,
    Map<String, String> renameHistory,
  ) {
    if (renameHistory.isEmpty || player.history.isEmpty) return player;
    var changed = false;
    final history = player.history.map((entry) {
      final nextName = renameHistory[entry.clubName];
      if (nextName == null || nextName == entry.clubName) return entry;
      changed = true;
      return PlayerHistoryEntry(
        season: entry.season,
        clubName: nextName,
        overall: entry.overall,
      );
    }).toList(growable: false);
    return changed ? player.copyWith(history: history) : player;
  }

  static Player _migratePlayer(
    Player player,
    String? Function(String?) mapClubId,
    Map<String, String> renameHistory,
  ) {
    final migratedHistory = renamePlayerHistory(player, renameHistory);
    final currentClubId = migratedHistory.clubId;
    final newClubId = mapClubId(currentClubId);
    if (newClubId == currentClubId) return migratedHistory;
    return newClubId == null
        ? migratedHistory.copyWith(clearClubId: true)
        : migratedHistory.copyWith(clubId: newClubId);
  }

  static Standing _mapStanding(
    Standing standing, {
    required String Function(String) mapId,
    required Map<String, String> namesById,
  }) {
    final clubId = mapId(standing.clubId);
    return Standing(
      clubId: clubId,
      clubName: namesById[clubId] ?? standing.clubName,
      played: standing.played,
      wins: standing.wins,
      draws: standing.draws,
      losses: standing.losses,
      goalsFor: standing.goalsFor,
      goalsAgainst: standing.goalsAgainst,
      points: standing.points,
    );
  }

  static FinanceTransaction renameFinanceTransaction(
    FinanceTransaction transaction, {
    required Map<String, String> oldNamesById,
    required Map<String, String> newNamesById,
  }) =>
      FinanceTransaction(
        id: transaction.id,
        season: transaction.season,
        round: transaction.round,
        kind: transaction.kind,
        description: _replaceClubNames(
          transaction.description,
          oldNamesById: oldNamesById,
          newNamesById: newNamesById,
        ),
        amount: transaction.amount,
        createdAt: transaction.createdAt,
      );

  static CareerEvent renameEvent(
    CareerEvent event, {
    required Map<String, String> oldNamesById,
    required Map<String, String> newNamesById,
  }) =>
      CareerEvent(
        id: event.id,
        date: event.date,
        type: event.type,
        title: _replaceClubNames(
          event.title,
          oldNamesById: oldNamesById,
          newNamesById: newNamesById,
        ),
        message: _replaceClubNames(
          event.message,
          oldNamesById: oldNamesById,
          newNamesById: newNamesById,
        ),
        playerId: event.playerId,
        clubId: event.clubId,
        amount: event.amount,
      );

  static MatchResult renameMatchResult(
    MatchResult result, {
    required Map<String, String> oldNamesById,
    required Map<String, String> newNamesById,
  }) =>
      MatchResult(
        fixtureId: result.fixtureId,
        homeClubId: result.homeClubId,
        awayClubId: result.awayClubId,
        score: result.score,
        events: result.events
            .map((event) {
              return MatchEvent(
                minute: event.minute,
                sequence: event.sequence,
                type: event.type,
                teamId: event.teamId,
                text: _replaceClubNames(
                  event.text,
                  oldNamesById: oldNamesById,
                  newNamesById: newNamesById,
                ),
                playerId: event.playerId,
                assistPlayerId: event.assistPlayerId,
                secondaryPlayerId: event.secondaryPlayerId,
                start: event.start,
                end: event.end,
              );
            })
            .toList(growable: false),
        statistics: result.statistics,
        seed: result.seed,
      );

  static MatchResult _migrateMatchResult(
    MatchResult result,
    String Function(String) mapId, {
    required Map<String, String> oldNamesByLegacyId,
    required Map<String, String> newNamesById,
  }) {
    final replacementNames = <String, String>{
      for (final entry in oldNamesByLegacyId.entries)
        if (newNamesById[mapId(entry.key)] != null)
          entry.key: newNamesById[mapId(entry.key)]!,
    };
    return MatchResult(
      fixtureId: result.fixtureId,
      homeClubId: mapId(result.homeClubId),
      awayClubId: mapId(result.awayClubId),
      score: result.score,
      events: result.events
          .map(
            (event) => MatchEvent(
              minute: event.minute,
              sequence: event.sequence,
              type: event.type,
              teamId: mapId(event.teamId),
              text: _replaceClubNames(
                event.text,
                oldNamesById: oldNamesByLegacyId,
                newNamesById: replacementNames,
              ),
              playerId: event.playerId,
              assistPlayerId: event.assistPlayerId,
              secondaryPlayerId: event.secondaryPlayerId,
              start: event.start,
              end: event.end,
            ),
          )
          .toList(growable: false),
      statistics: result.statistics,
      seed: result.seed,
    );
  }

  static String _replaceClubNames(
    String text, {
    required Map<String, String> oldNamesById,
    required Map<String, String> newNamesById,
  }) {
    var output = text;
    final entries = oldNamesById.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));
    for (final entry in entries) {
      final oldName = entry.value;
      final newName = newNamesById[entry.key];
      if (oldName.isEmpty || newName == null || oldName == newName) continue;
      output = _replaceClubNameInNarrative(output, oldName, newName);
    }
    return output;
  }

  static String _replaceClubNameInNarrative(
    String text,
    String oldName,
    String newName,
  ) {
    var output = text;
    for (final prefix in const [
      ' do ',
      ' para ',
      ' em ',
      ' por ',
      ' enfrenta ',
      'Fim de jogo: ',
    ]) {
      output = output.replaceAll('$prefix$oldName', '$prefix$newName');
    }
    output = output.replaceAll('($oldName)', '($newName)');
    output = output.replaceAll(
      '. $oldName comemora',
      '. $newName comemora',
    );

    final startRemainder = output.startsWith('$oldName ')
        ? output.substring(oldName.length + 1)
        : null;
    if (startRemainder != null &&
        const ['acelera ', 'comete ', 'trabalha ', 'sinalizou ']
            .any(startRemainder.startsWith)) {
      output = '$newName ${output.substring(oldName.length + 1)}';
    }

    final scoreSuffix = RegExp(
      '(\\d+\\s+x\\s+\\d+\\s+)${RegExp.escape(oldName)}(?=[.\\s]|\$)',
    );
    output = output.replaceAllMapped(
      scoreSuffix,
      (match) => '${match.group(1)}$newName',
    );
    return output;
  }
}
