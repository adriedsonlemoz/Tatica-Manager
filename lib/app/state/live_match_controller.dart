import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/club/club.dart';
import '../../domain/formation/formation.dart';
import '../../domain/match/match_models.dart';
import '../../domain/player/player.dart';
import '../../domain/season/career_event.dart';
import '../../domain/season/career_state.dart';
import '../../domain/tactic/tactic.dart';
import '../../game/cpu/cpu_manager_engine.dart';
import '../../game/cpu/cpu_market_news_engine.dart';
import '../../game/competition/competition_simulation_engine.dart';
import '../../game/competition/competition_state_engine.dart';
import '../../game/finance/finance_engine.dart';
import '../../game/league/live_round_simulator.dart';
import '../../game/lineup/lineup_engine.dart';
import '../../game/match/engine/match_engine.dart';
import '../../game/match/live_substitution_rules.dart';
import '../../game/match/match_career_impact_engine.dart';
import '../../game/season/inbox_engine.dart';
import 'game_controller.dart';

final liveMatchControllerProvider =
    NotifierProvider<LiveMatchController, LiveMatchSession?>(
  LiveMatchController.new,
);

class LiveMatchSession {
  const LiveMatchSession({
    required this.fixture,
    required this.result,
    required this.userStarterIds,
    required this.homeStarterIds,
    required this.awayStarterIds,
    required this.userTactic,
    required this.userFormation,
    this.otherMatches = const [],
  });

  final MatchFixture fixture;
  final MatchResult result;
  final List<String> userStarterIds;
  final List<String> homeStarterIds;
  final List<String> awayStarterIds;
  final Tactic userTactic;
  final FormationType userFormation;
  final List<PreparedRoundMatch> otherMatches;

  LiveMatchSession copyWith({
    MatchResult? result,
    List<String>? userStarterIds,
    List<String>? homeStarterIds,
    List<String>? awayStarterIds,
    Tactic? userTactic,
    FormationType? userFormation,
    List<PreparedRoundMatch>? otherMatches,
  }) =>
      LiveMatchSession(
        fixture: fixture,
        result: result ?? this.result,
        userStarterIds: userStarterIds ?? this.userStarterIds,
        homeStarterIds: homeStarterIds ?? this.homeStarterIds,
        awayStarterIds: awayStarterIds ?? this.awayStarterIds,
        userTactic: userTactic ?? this.userTactic,
        userFormation: userFormation ?? this.userFormation,
        otherMatches: otherMatches ?? this.otherMatches,
      );
}

class LiveMatchController extends Notifier<LiveMatchSession?> {
  static const int maxSubstitutions = LiveSubstitutionRules.maxSubstitutions;
  static const int maxSubstitutionWindows = LiveSubstitutionRules.maxWindows;

  @override
  LiveMatchSession? build() => null;

  CareerState? get _career => ref.read(gameControllerProvider).career;

  GameController get _game => ref.read(gameControllerProvider.notifier);

  void reset() {
    state = null;
  }

  LiveMatchSession? prepareMatch() {
    final career = _career;
    if (career == null || career.seasonComplete) return null;
    final fixture = career.nextUserFixture;
    if (fixture == null) return null;
    if (!career.isMatchDay) {
      _game.showMessage('A partida ainda não chegou. Avance o calendário até ${fixture.date.day.toString().padLeft(2, '0')}/${fixture.date.month.toString().padLeft(2, '0')}.');
      return null;
    }

    final suspended = career.suspendedPlayerIdsForCompetition(
      fixture.competitionId,
    );
    final validation = LineupEngine.validate(
      career.userClub.squad,
      career.starterIds,
      career.formation,
      competitionSuspendedPlayerIds: suspended,
    );
    if (!validation.valid) {
      _game.showMessage(validation.message);
      return null;
    }

    final home = _club(career, fixture.homeClubId);
    final away = _club(career, fixture.awayClubId);
    final userAtHome = home.id == career.userClubId;
    final homeFormation = userAtHome
        ? career.formation
        : LiveRoundSimulator.formationFor(home);
    final awayFormation = userAtHome
        ? LiveRoundSimulator.formationFor(away)
        : career.formation;
    final homeTactic =
        userAtHome ? career.tactic : LiveRoundSimulator.tacticFor(home);
    final awayTactic =
        userAtHome ? LiveRoundSimulator.tacticFor(away) : career.tactic;
    final homeStarters = userAtHome
        ? career.starterIds
        : LineupEngine.autoSelect(
            home.squad,
            homeFormation,
            competitionSuspendedPlayerIds: suspended,
          );
    final awayStarters = userAtHome
        ? LineupEngine.autoSelect(
            away.squad,
            awayFormation,
            competitionSuspendedPlayerIds: suspended,
          )
        : career.starterIds;

    final result = MatchEngine.simulate(
      fixture: fixture,
      home: home,
      away: away,
      homeFormation: homeFormation,
      awayFormation: awayFormation,
      homeTactic: homeTactic,
      awayTactic: awayTactic,
      homeStarterIds: homeStarters,
      awayStarterIds: awayStarters,
    );

    final live = LiveMatchSession(
      fixture: fixture,
      result: result,
      userStarterIds: [...career.starterIds],
      homeStarterIds: homeStarters,
      awayStarterIds: awayStarters,
      userTactic: career.tactic,
      userFormation: career.formation,
      otherMatches: LiveRoundSimulator.prepareOtherMatches(
        career: career,
        round: fixture.round,
        competitionId: fixture.competitionId,
        userFixtureId: fixture.id,
      ),
    );
    state = live;
    return live;
  }

  void changeTactic(Tactic tactic, int minute) {
    final career = _career;
    final live = state;
    if (career == null || live == null) return;
    state = _resimulateFromMinute(
      career,
      live.copyWith(userTactic: tactic),
      minute,
    );
  }

  void substitute(String outgoingId, String incomingId, int minute) {
    substituteMany(
      [
        LiveSubstitutionChange(
          outgoingId: outgoingId,
          incomingId: incomingId,
        ),
      ],
      minute,
    );
  }

  bool substituteMany(
    List<LiveSubstitutionChange> changes,
    int minute,
  ) {
    final career = _career;
    final live = state;
    if (career == null || live == null || changes.isEmpty) return false;

    final previousSubstitutions = LiveSubstitutionRules.substitutionsForTeam(
      live.result.events,
      career.userClubId,
    );
    final violation = LiveSubstitutionRules.violationMessage(
      events: live.result.events,
      teamId: career.userClubId,
      minute: minute,
      requestedSubstitutions: changes.length,
    );
    if (violation != null) {
      _game.showMessage(violation);
      return false;
    }

    final alreadySubstitutedOut = previousSubstitutions
        .map((event) => event.secondaryPlayerId)
        .whereType<String>()
        .toSet();
    final dismissedPlayerIds = live.result.events
        .where(
          (event) =>
              event.type == MatchEventType.red &&
              event.teamId == career.userClubId &&
              event.minute <= minute,
        )
        .map((event) => event.playerId)
        .whereType<String>()
        .toSet();
    final squadById = {
      for (final player in career.userClub.squad) player.id: player,
    };
    final originalStarters = live.userStarterIds.toSet();
    var nextIds = [...live.userStarterIds];
    final plannedOutgoing = <String>{};
    final plannedIncoming = <String>{};

    for (final change in changes) {
      final outgoingId = change.outgoingId;
      final incomingId = change.incomingId;
      if (!originalStarters.contains(outgoingId) ||
          !nextIds.contains(outgoingId)) {
        _game.showMessage('Jogador escolhido para sair não está mais em campo.');
        return false;
      }
      if (!plannedOutgoing.add(outgoingId)) {
        _game.showMessage('O mesmo jogador não pode sair duas vezes na mesma janela.');
        return false;
      }
      if (outgoingId == incomingId || nextIds.contains(incomingId)) {
        _game.showMessage('Escolha um reserva que ainda não esteja em campo.');
        return false;
      }
      if (!plannedIncoming.add(incomingId)) {
        _game.showMessage('O mesmo reserva não pode entrar duas vezes na mesma janela.');
        return false;
      }
      if (alreadySubstitutedOut.contains(incomingId)) {
        _game.showMessage('Jogador substituído não pode retornar à partida.');
        return false;
      }
      if (dismissedPlayerIds.contains(outgoingId)) {
        _game.showMessage('Jogador expulso não pode ser substituído.');
        return false;
      }
      if (dismissedPlayerIds.contains(incomingId)) {
        _game.showMessage('Jogador expulso não pode entrar na partida.');
        return false;
      }
      if (!squadById.containsKey(incomingId)) {
        _game.showMessage('Reserva selecionado não pertence ao elenco da partida.');
        return false;
      }
      nextIds = LineupEngine.replaceStarter(
        nextIds,
        outgoingId,
        incomingId,
      );
    }

    final validation = LineupEngine.validate(
      career.userClub.squad,
      nextIds,
      live.userFormation,
      competitionSuspendedPlayerIds: career.suspendedPlayerIdsForCompetition(
        live.fixture.competitionId,
      ),
    );
    if (!validation.valid) {
      _game.showMessage(validation.message);
      return false;
    }

    final prefix = live.result.events
        .where(
          (event) =>
              event.minute <= minute &&
              event.type != MatchEventType.fulltime,
        )
        .toList();
    var nextSequence = prefix.isEmpty
        ? 0
        : prefix.map((event) => event.sequence).reduce(max) + 1;
    final substitutionEvents = <MatchEvent>[];
    for (final change in changes) {
      final incoming = squadById[change.incomingId]!;
      final outgoing = squadById[change.outgoingId]!;
      substitutionEvents.add(
        MatchEvent(
          minute: minute,
          sequence: nextSequence++,
          type: MatchEventType.substitution,
          teamId: career.userClubId,
          playerId: incoming.id,
          secondaryPlayerId: outgoing.id,
          text:
              'Substituição em ${career.userClub.name}: entra ${incoming.displayName}, sai ${outgoing.displayName}.',
        ),
      );
    }

    state = _resimulateFromMinute(
      career,
      live.copyWith(userStarterIds: nextIds),
      minute,
      extraPrefix: substitutionEvents,
    );
    return true;
  }

  LiveMatchSession _resimulateFromMinute(
    CareerState career,
    LiveMatchSession live,
    int minute, {
    List<MatchEvent> extraPrefix = const [],
  }) {
    final fixture = live.fixture;
    final home = _club(career, fixture.homeClubId);
    final away = _club(career, fixture.awayClubId);
    final userAtHome = home.id == career.userClubId;
    final prefix = [
      ...live.result.events.where(
        (event) =>
            event.minute <= minute &&
            event.type != MatchEventType.fulltime,
      ),
      ...extraPrefix,
    ];
    final score = _scoreFromEvents(prefix, home.id, away.id);
    final homeFormation = userAtHome
        ? live.userFormation
        : LiveRoundSimulator.formationFor(home);
    final awayFormation = userAtHome
        ? LiveRoundSimulator.formationFor(away)
        : live.userFormation;
    final homeTactic =
        userAtHome ? live.userTactic : LiveRoundSimulator.tacticFor(home);
    final awayTactic =
        userAtHome ? LiveRoundSimulator.tacticFor(away) : live.userTactic;
    final suspended = career.suspendedPlayerIdsForCompetition(
      fixture.competitionId,
    );
    final homeIds = userAtHome
        ? live.userStarterIds
        : LineupEngine.autoSelect(
            home.squad,
            homeFormation,
            competitionSuspendedPlayerIds: suspended,
          );
    final awayIds = userAtHome
        ? LineupEngine.autoSelect(
            away.squad,
            awayFormation,
            competitionSuspendedPlayerIds: suspended,
          )
        : live.userStarterIds;

    final result = MatchEngine.simulate(
      fixture: fixture,
      home: home,
      away: away,
      homeFormation: homeFormation,
      awayFormation: awayFormation,
      homeTactic: homeTactic,
      awayTactic: awayTactic,
      homeStarterIds: homeIds,
      awayStarterIds: awayIds,
      seed: live.result.seed,
      startMinute: min(90, minute + 1),
      initialScore: score,
      prefixEvents: prefix,
    );
    return live.copyWith(
      result: result,
      homeStarterIds: homeIds,
      awayStarterIds: awayIds,
    );
  }

  Future<MatchResult?> finishMatch() async {
    final career = _career;
    final live = state;
    if (career == null || live == null) return null;

    final round = live.fixture.round;
    var clubs = [...career.clubs];
    var fixtures = [...career.fixtures];
    var competitionStates = [...career.competitionStates];
    final results = <MatchResult>[live.result];
    final participantsByClub = <String, Set<String>>{};
    final startersByClub = <String, Set<String>>{};

    final userParticipants = <String>{
      ...career.starterIds,
      ...live.userStarterIds,
    };
    for (final event in live.result.events.where(
      (event) => event.type == MatchEventType.substitution,
    )) {
      if (event.playerId != null) userParticipants.add(event.playerId!);
      if (event.secondaryPlayerId != null) {
        userParticipants.add(event.secondaryPlayerId!);
      }
    }
    participantsByClub[career.userClubId] = userParticipants;
    startersByClub[career.userClubId] = career.starterIds.toSet();

    final liveHome = clubs.firstWhere(
      (club) => club.id == live.fixture.homeClubId,
    );
    final liveAway = clubs.firstWhere(
      (club) => club.id == live.fixture.awayClubId,
    );
    final opponent = liveHome.id == career.userClubId ? liveAway : liveHome;
    final opponentFormation = LiveRoundSimulator.formationFor(opponent);
    final opponentStarters = LineupEngine.autoSelect(
      opponent.squad,
      opponentFormation,
      competitionSuspendedPlayerIds: career.suspendedPlayerIdsForCompetition(
        live.fixture.competitionId,
      ),
    );
    participantsByClub[opponent.id] = opponentStarters.toSet();
    startersByClub[opponent.id] = opponentStarters.toSet();

    for (final prepared in live.otherMatches) {
      participantsByClub[prepared.fixture.homeClubId] =
          prepared.homeStarterIds.toSet();
      participantsByClub[prepared.fixture.awayClubId] =
          prepared.awayStarterIds.toSet();
      startersByClub[prepared.fixture.homeClubId] =
          prepared.homeStarterIds.toSet();
      startersByClub[prepared.fixture.awayClubId] =
          prepared.awayStarterIds.toSet();
      results.add(prepared.result);
    }

    final userAvailabilityBefore = career.userClub.squad;
    for (final result in results) {
      final resultFixture = fixtures.firstWhere(
        (fixture) => fixture.id == result.fixtureId,
      );
      fixtures = fixtures
          .map(
            (fixture) => fixture.id == result.fixtureId
                ? fixture.copyWith(played: true, score: result.score)
                : fixture,
          )
          .toList(growable: false);
      final competitionState = competitionStates
          .where(
            (item) => item.competitionId == resultFixture.competitionId,
          )
          .firstOrNull ??
          career.competitionStateFor(resultFixture.competitionId);
      final impact = MatchCareerImpactEngine.apply(
        clubs: clubs,
        result: result,
        participantsByClub: participantsByClub,
        startersByClub: startersByClub,
        competitionPlayerStats: competitionState.playerStats,
        competitionPlayerDiscipline: competitionState.playerDiscipline,
        mirrorCompetitionDisciplineToPlayer:
            resultFixture.competitionId == career.primaryCompetitionId,
      );
      clubs = impact.clubs;
      final updatedState = competitionState.copyWith(
        playerStats: impact.competitionPlayerStats,
        playerDiscipline: impact.competitionPlayerDiscipline,
      );
      competitionStates = [
        for (final item in competitionStates)
          if (item.competitionId != updatedState.competitionId) item,
        updatedState,
      ];
    }

    competitionStates = CompetitionStateEngine.rebuildAll(
      states: competitionStates,
      clubs: clubs,
      fixtures: fixtures,
    );
    final liveCompetitionState = competitionStates.firstWhere(
      (item) => item.competitionId == live.fixture.competitionId,
    );
    final primaryState = competitionStates.firstWhere(
      (item) => item.competitionId == career.primaryCompetitionId,
    );
    final livePosition = liveCompetitionState.standings.indexWhere(
          (standing) => standing.clubId == career.userClubId,
        ) +
        1;
    final primaryPosition = primaryState.standings.indexWhere(
          (standing) => standing.clubId == career.userClubId,
        ) +
        1;
    final tablePosition = livePosition > 0
        ? livePosition
        : primaryPosition > 0
            ? primaryPosition
            : 1;

    final userAvailabilityAfter = clubs
        .firstWhere((club) => club.id == career.userClubId)
        .squad;
    final availabilityEvents = _availabilityRecoveryEvents(
      before: userAvailabilityBefore,
      after: userAvailabilityAfter,
      date: career.currentDate,
      clubId: career.userClubId,
    );

    final userHome = live.fixture.homeClubId == career.userClubId;
    final userClub = clubs.firstWhere((club) => club.id == career.userClubId);
    final primaryMatch = live.fixture.competitionId == career.primaryCompetitionId;
    final finance = primaryMatch
        ? FinanceEngine.settleUserRound(
            club: userClub,
            fixture: live.fixture,
            season: career.season,
            round: round,
            home: userHome,
            tablePosition: max(1, tablePosition),
            roundsPerSeason: career.totalUserRounds,
          )
        : FinanceEngine.settleAdditionalCompetitionMatch(
            club: userClub,
            fixture: live.fixture,
            season: career.season,
            home: userHome,
            tablePosition: max(1, tablePosition),
          );
    clubs = clubs
        .map((club) => club.id == userClub.id ? finance.club : club)
        .toList(growable: false);

    var freeAgents = career.freeAgents;
    var marketEvents = <CareerEvent>[];
    if (primaryMatch) {
      final cpu = CpuManagerEngine.runRound(
        clubs: clubs,
        freeAgents: career.freeAgents,
        userClubId: career.userClubId,
        season: career.season,
        round: round,
        currentDate: career.currentDate,
        careerId: career.careerId,
      );
      clubs = cpu.clubs;
      freeAgents = cpu.freeAgents;
      marketEvents = CpuMarketNewsEngine.build(
        result: cpu,
        date: career.currentDate,
        season: career.season,
        round: round,
      );
    }

    final mergedNews = [
      ...career.news,
      ...availabilityEvents,
      ...marketEvents,
    ];
    final news = mergedNews.length <= CareerState.maxStoredNews
        ? mergedNews
        : mergedNews.sublist(mergedNews.length - CareerState.maxStoredNews);
    final nextBase = career.copyWith(
      clubs: clubs,
      freeAgents: freeAgents,
      fixtures: fixtures,
      competitionStates: competitionStates,
      starterIds: live.userStarterIds,
      tactic: live.userTactic,
      finances: [...career.finances, ...finance.transactions],
      news: news,
      matchHistory: [...career.matchHistory, live.result],
      lastMatch: live.result,
    );
    final sameDayResolved =
        CompetitionSimulationEngine.resolveCpuFixturesThroughDate(
      nextBase,
      throughDate: career.currentDate,
      protectUserFixtures: true,
    );
    final next = InboxEngine.appendEvents(
      sameDayResolved,
      [...availabilityEvents, ...marketEvents],
    );
    await _game.commitCareer(next, message: 'Partida concluída.');
    state = null;
    return live.result;
  }

  static List<CareerEvent> _availabilityRecoveryEvents({
    required List<Player> before,
    required List<Player> after,
    required DateTime date,
    required String clubId,
  }) {
    final afterById = {for (final player in after) player.id: player};
    final events = <CareerEvent>[];
    for (final previous in before) {
      final current = afterById[previous.id];
      if (current == null) continue;
      if (previous.injury != null && current.injury == null) {
        events.add(
          CareerEvent(
            id: 'injury-ended-${date.year}-${date.month}-${date.day}-${previous.id}',
            date: date,
            type: CareerEventType.injuryEnded,
            title: 'Jogador recuperado',
            message: '${previous.displayName} está recuperado da lesão e voltou a ficar disponível.',
            playerId: previous.id,
            clubId: clubId,
          ),
        );
      }
      if (previous.discipline.suspendedRounds > 0 &&
          current.discipline.suspendedRounds == 0) {
        events.add(
          CareerEvent(
            id: 'suspension-ended-${date.year}-${date.month}-${date.day}-${previous.id}',
            date: date,
            type: CareerEventType.suspensionEnded,
            title: 'Fim de suspensão',
            message: '${previous.displayName} cumpriu a suspensão e pode voltar a ser escalado.',
            playerId: previous.id,
            clubId: clubId,
          ),
        );
      }
    }
    return events;
  }

  static Club _club(CareerState career, String id) =>
      career.clubs.firstWhere((club) => club.id == id);

  static MatchScore _scoreFromEvents(
    List<MatchEvent> events,
    String homeId,
    String awayId,
  ) {
    var home = 0;
    var away = 0;
    for (final event in events) {
      if (event.type != MatchEventType.goal &&
          event.type != MatchEventType.ownGoal) {
        continue;
      }
      if (event.teamId == homeId) home++;
      if (event.teamId == awayId) away++;
    }
    return MatchScore(home, away);
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
