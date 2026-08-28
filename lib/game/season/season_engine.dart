import 'dart:math';

import '../../domain/career/manager_profile.dart';
import '../../domain/club/club.dart';
import '../../domain/player/player.dart';
import '../../domain/season/career_event.dart';
import '../../domain/season/career_state.dart';
import '../contract/contract_engine.dart';
import '../contract/contract_lifecycle_engine.dart';
import '../finance/club_administration_engine.dart';
import '../league/league_engine.dart';
import '../lineup/lineup_engine.dart';
import '../player/player_development_engine.dart';
import '../player/player_factory.dart';
import 'calendar_engine.dart';

abstract final class SeasonEngine {
  static SeasonSummary summaryFor(CareerState state) {
    final userStanding =
        state.standings.firstWhere((row) => row.clubId == state.userClubId);
    final position =
        state.standings.indexWhere((row) => row.clubId == state.userClubId) + 1;
    return SeasonSummary(
      season: state.season,
      clubId: state.userClubId,
      position: position,
      points: userStanding.points,
      wins: userStanding.wins,
      draws: userStanding.draws,
      losses: userStanding.losses,
    );
  }

  static CareerState advance(CareerState state) {
    if (!state.seasonComplete) {
      throw StateError('A temporada ainda não terminou.');
    }

    final summary = summaryFor(state);
    final nextSeason = state.season + 1;
    final random = Random(nextSeason * 997);
    final evolvedClubs = <Club>[];

    for (final club in state.clubs) {
      final squad = club.squad
          .map(
            (player) => PlayerDevelopmentEngine.advanceSeason(
              player,
              nextSeason,
              random,
              club.name,
            ),
          )
          .toList();
      evolvedClubs.add(club.copyWith(squad: squad, recentForm: const []));
    }

    // A temporada muda primeiro e o mesmo reconciliador usado no avanço diário
    // aplica a única regra de vencimento: endSeason < temporada atual.
    final lifecycle = ContractLifecycleEngine.reconcile(
      state.copyWith(
        season: nextSeason,
        clubs: evolvedClubs,
        freeAgents: [...state.freeAgents],
      ),
    );
    final protectedReleasedIds = lifecycle.releasedPlayerIds;
    final freeAgents = <Player>[...lifecycle.state.freeAgents];
    var clubs = <Club>[...lifecycle.state.clubs];

    final factory = PlayerFactory(random: random);
    for (var i = 0; i < clubs.length; i++) {
      var club = clubs[i];
      while (club.squad.length < 22) {
        late final Player signing;
        final eligibleFreeAgents = freeAgents
            .where((player) => !protectedReleasedIds.contains(player.id))
            .toList()
          ..sort((a, b) => b.overall.compareTo(a.overall));

        if (eligibleFreeAgents.isNotEmpty) {
          final selected = eligibleFreeAgents.first;
          freeAgents.removeWhere((player) => player.id == selected.id);
          signing = ContractEngine.signFreeAgent(
            player: selected,
            clubId: club.id,
            season: nextSeason,
          );
        } else {
          signing = factory.generatePlayer(
            clubId: club.id,
            position: PlayerPosition
                .values[random.nextInt(PlayerPosition.values.length)],
            baseOverall: max(58, club.reputation - 10),
            season: nextSeason,
          );
        }
        club = club.copyWith(squad: [...club.squad, signing]);
      }
      clubs[i] = club;
    }

    while (freeAgents.length < 24) {
      freeAgents.addAll(
        factory.generateFreeAgents(
          count: 1,
          season: nextSeason,
          baseOverall: 68,
        ),
      );
    }

    final userClub = clubs.firstWhere((club) => club.id == state.userClubId);
    final starters = LineupEngine.autoSelect(userClub.squad, state.formation);
    final primaryClubIds = state.primaryCompetitionClubIds;
    final primaryClubs = clubs
        .where((club) => primaryClubIds.contains(club.id))
        .toList(growable: false);
    final fixtures = LeagueEngine.generateDoubleRoundRobin(
      primaryClubs,
      season: nextSeason,
      competitionId: state.primaryCompetitionId,
    );
    final initialDate = CareerCalendarEngine.initialDateFor(
      fixtures: fixtures,
      userClubId: state.userClubId,
      season: nextSeason,
    );
    final seasonStarted = CareerEvent(
      id: 'season-started-$nextSeason',
      date: initialDate,
      type: CareerEventType.seasonStarted,
      title: 'Nova temporada',
      message:
          'A temporada $nextSeason começou. A equipe já iniciou a preparação para a primeira rodada.',
      clubId: state.userClubId,
    );
    final mergedNews = [...state.news, seasonStarted];
    final news = mergedNews.length <= CareerState.maxStoredNews
        ? mergedNews
        : mergedNews.sublist(mergedNews.length - CareerState.maxStoredNews);
    final managerHistoryBase = state.managerHistory.isEmpty
        ? [
            ManagerCareerHistoryEntry.fromProfile(
              state.manager,
              season: state.season,
              clubId: state.userClubId,
            ),
          ]
        : state.managerHistory;
    final managerHistory = managerHistoryBase.any((entry) => entry.season == nextSeason)
        ? managerHistoryBase
        : [
            ...managerHistoryBase,
            ManagerCareerHistoryEntry.fromProfile(
              state.manager,
              season: nextSeason,
              clubId: state.userClubId,
            ),
          ];

    final next = lifecycle.state.copyWith(
      season: nextSeason,
      roundIndex: 0,
      currentDate: initialDate,
      clubs: clubs,
      freeAgents: freeAgents,
      fixtures: fixtures,
      standings: LeagueEngine.initialStandings(primaryClubs),
      starterIds: starters,
      seasonHistory: [...state.seasonHistory, summary],
      managerHistory: managerHistory,
      news: news,
      matchHistory: const [],
      clearLastMatch: true,
    );
    return ClubAdministrationEngine.ensureInitialized(next);
  }
}
