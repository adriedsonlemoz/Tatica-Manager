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
import '../../game/finance/finance_engine.dart';
import '../../game/league/league_engine.dart';
import '../../game/league/live_round_simulator.dart';
import '../../game/lineup/lineup_engine.dart';
import '../../game/match/engine/match_engine.dart';
import '../../game/morale/morale_engine.dart';
import '../../game/player/player_development_engine.dart';
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

    final validation = LineupEngine.validate(
      career.userClub.squad,
      career.starterIds,
      career.formation,
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
        : LineupEngine.autoSelect(home.squad, homeFormation);
    final awayStarters = userAtHome
        ? LineupEngine.autoSelect(away.squad, awayFormation)
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
    final career = _career;
    final live = state;
    if (career == null || live == null) return;
    if (live.userStarterIds.contains(incomingId)) return;

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
    if (dismissedPlayerIds.contains(outgoingId)) {
      _game.showMessage('Jogador expulso não pode ser substituído.');
      return;
    }
    if (dismissedPlayerIds.contains(incomingId)) return;

    final nextIds = LineupEngine.replaceStarter(
      live.userStarterIds,
      outgoingId,
      incomingId,
    );
    final validation = LineupEngine.validate(
      career.userClub.squad,
      nextIds,
      live.userFormation,
    );
    if (!validation.valid) {
      _game.showMessage(validation.message);
      return;
    }

    final prefix = live.result.events
        .where(
          (event) =>
              event.minute <= minute &&
              event.type != MatchEventType.fulltime,
        )
        .toList();
    final incoming = career.userClub.squad.firstWhere(
      (player) => player.id == incomingId,
    );
    final outgoing = career.userClub.squad.firstWhere(
      (player) => player.id == outgoingId,
    );
    final subEvent = MatchEvent(
      minute: minute,
      sequence: prefix.isEmpty
          ? 0
          : prefix.map((event) => event.sequence).reduce(max) + 1,
      type: MatchEventType.substitution,
      teamId: career.userClubId,
      playerId: incomingId,
      secondaryPlayerId: outgoingId,
      text:
          'Substituição em ${career.userClub.name}: entra ${incoming.displayName}, sai ${outgoing.displayName}.',
    );
    state = _resimulateFromMinute(
      career,
      live.copyWith(userStarterIds: nextIds),
      minute,
      extraPrefix: [subEvent],
    );
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
    final homeIds = userAtHome
        ? live.userStarterIds
        : LineupEngine.autoSelect(home.squad, homeFormation);
    final awayIds = userAtHome
        ? LineupEngine.autoSelect(away.squad, awayFormation)
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
    final results = <MatchResult>[live.result];
    final participantsByClub = <String, Set<String>>{};
    final startersByClub = <String, Set<String>>{};

    // Garante que o desgaste e as estatísticas alcancem todos que realmente
    // participaram, mesmo quando um titular não gerou evento individual.
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

    // Todos os clubes disputam a rodada ainda respeitando lesões e
    // suspensões que já estavam ativas. Só depois das simulações consumimos
    // uma rodada dessas indisponibilidades; as novas ocorrências são aplicadas
    // em seguida e, assim, permanecem válidas para a próxima partida.
    final userAvailabilityBefore = career.userClub.squad;
    clubs = clubs
        .map(
          (club) => club.copyWith(
            squad: PlayerDevelopmentEngine.advanceRoundAvailability(club.squad),
          ),
        )
        .toList();
    final userAvailabilityAfter = clubs
        .firstWhere((club) => club.id == career.userClubId)
        .squad;
    final availabilityEvents = _availabilityRecoveryEvents(
      before: userAvailabilityBefore,
      after: userAvailabilityAfter,
      date: career.currentDate,
      clubId: career.userClubId,
    );

    for (final result in results) {
      fixtures = fixtures
          .map(
            (fixture) => fixture.id == result.fixtureId
                ? fixture.copyWith(played: true, score: result.score)
                : fixture,
          )
          .toList();
      clubs = _applyResultToClubs(
        clubs,
        result,
        participantsByClub: participantsByClub,
        startersByClub: startersByClub,
      );
    }

    var standings = LeagueEngine.rebuildStandings(clubs, fixtures);
    final userHome = live.fixture.homeClubId == career.userClubId;
    final tablePosition =
        standings.indexWhere((standing) => standing.clubId == career.userClubId) +
            1;
    final userClub = clubs.firstWhere((club) => club.id == career.userClubId);
    final finance = FinanceEngine.settleUserRound(
      club: userClub,
      fixture: live.fixture,
      season: career.season,
      round: round,
      home: userHome,
      tablePosition: max(1, tablePosition),
    );
    clubs = clubs
        .map((club) => club.id == userClub.id ? finance.club : club)
        .toList();

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
    standings = LeagueEngine.rebuildStandings(clubs, fixtures);

    final marketEvents = CpuMarketNewsEngine.build(
      result: cpu,
      date: career.currentDate,
      season: career.season,
      round: round,
    );
    final mergedNews = [
      ...career.news,
      ...availabilityEvents,
      ...marketEvents,
    ];
    final news = mergedNews.length <= CareerState.maxStoredNews
        ? mergedNews
        : mergedNews.sublist(mergedNews.length - CareerState.maxStoredNews);
    final nextBase = career.copyWith(
      roundIndex: career.roundIndex + 1,
      clubs: clubs,
      freeAgents: cpu.freeAgents,
      fixtures: fixtures,
      standings: standings,
      starterIds: live.userStarterIds,
      tactic: live.userTactic,
      finances: [...career.finances, ...finance.transactions],
      news: news,
      matchHistory: [...career.matchHistory, live.result],
      lastMatch: live.result,
    );
    final next = InboxEngine.appendEvents(
      nextBase,
      [...availabilityEvents, ...marketEvents],
    );
    await _game.commitCareer(next, message: 'Rodada $round concluída.');
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

  static List<Club> _applyResultToClubs(
    List<Club> clubs,
    MatchResult result, {
    required Map<String, Set<String>> participantsByClub,
    required Map<String, Set<String>> startersByClub,
  }) {
    return clubs.map((club) {
      if (club.id != result.homeClubId && club.id != result.awayClubId) {
        return club;
      }
      final home = club.id == result.homeClubId;
      final goalsFor = home ? result.score.home : result.score.away;
      final goalsAgainst = home ? result.score.away : result.score.home;
      final form = [
        ...club.recentForm,
        goalsFor > goalsAgainst
            ? 'V'
            : goalsFor == goalsAgainst
                ? 'E'
                : 'D',
      ];
      while (form.length > 5) {
        form.removeAt(0);
      }

      final eventByPlayer = <String, List<MatchEvent>>{};
      for (final event in result.events.where(
        (event) => event.teamId == club.id && event.playerId != null,
      )) {
        eventByPlayer.putIfAbsent(event.playerId!, () => []).add(event);
      }

      final squad = club.squad.map((player) {
        final events = eventByPlayer[player.id] ?? const <MatchEvent>[];
        final isStarter = startersByClub[club.id]?.contains(player.id) == true;
        final participated =
            participantsByClub[club.id]?.contains(player.id) == true ||
                events.isNotEmpty ||
                result.events.any(
                  (event) =>
                      event.playerId == player.id ||
                      event.assistPlayerId == player.id ||
                      event.secondaryPlayerId == player.id,
                );
        if (!participated) return player;

        final substitutionIn = result.events
            .where(
              (event) =>
                  event.type == MatchEventType.substitution &&
                  event.teamId == club.id &&
                  event.playerId == player.id,
            )
            .toList();
        final substitutionOut = result.events
            .where(
              (event) =>
                  event.type == MatchEventType.substitution &&
                  event.teamId == club.id &&
                  event.secondaryPlayerId == player.id,
            )
            .toList();
        final dismissal = events
            .where((event) => event.type == MatchEventType.red)
            .toList();
        final enteredAt = substitutionIn.isNotEmpty
            ? substitutionIn.first.minute
            : 0;
        var leftAt = substitutionOut.isNotEmpty
            ? substitutionOut.first.minute
            : 90;
        if (dismissal.isNotEmpty) {
          leftAt = min(leftAt, dismissal.first.minute);
        }
        final minutesPlayed = max(1, leftAt - enteredAt);

        final goals =
            events.where((event) => event.type == MatchEventType.goal).length;
        final assists = result.events
            .where((event) => event.assistPlayerId == player.id)
            .length;
        final yellows = events
            .where((event) => event.type == MatchEventType.yellow)
            .length;
        final reds =
            events.where((event) => event.type == MatchEventType.red).length;
        final injury = events.any(
          (event) => event.type == MatchEventType.injury,
        )
            ? const PlayerInjury(
                name: 'Desconforto muscular',
                roundsRemaining: 1,
              )
            : player.injury;
        final rating = (6.3 + goals * .8 + assists * .45 - reds * 1.2)
            .clamp(1.0, 10.0)
            .toDouble();
        final recentRatings = [...player.recentRatings, rating];
        while (recentRatings.length > 5) {
          recentRatings.removeAt(0);
        }
        final stats = player.stats.copyWith(
          appearances: player.stats.appearances + 1,
          starts: player.stats.starts + (isStarter ? 1 : 0),
          minutes: player.stats.minutes + minutesPlayed,
          goals: player.stats.goals + goals,
          assists: player.stats.assists + assists,
          yellowCards: player.stats.yellowCards + yellows,
          redCards: player.stats.redCards + reds,
          ratingTotal: player.stats.ratingTotal + rating,
        );
        var yellowTotal = player.discipline.yellowCards + yellows;
        var suspension =
            player.discipline.suspendedRounds + (reds > 0 ? 1 : 0);
        if (yellowTotal >= 3) {
          yellowTotal -= 3;
          suspension++;
        }
        return player.copyWith(
          stats: stats,
          recentRatings: recentRatings,
          injury: injury,
          discipline: player.discipline.copyWith(
            yellowCards: yellowTotal,
            redCards: player.discipline.redCards + reds,
            suspendedRounds: suspension,
          ),
          fatigue: min(
            100,
            player.fatigue + max(6, (16 * minutesPlayed / 90).round()),
          ),
          condition: max(
            35,
            player.condition - max(3, (7 * minutesPlayed / 90).round()),
          ),
        );
      }).toList();
      final morale = MoraleEngine.moraleFromRecentForm(form);
      return club.copyWith(
        squad: squad
            .map(
              (player) => player.copyWith(
                morale: ((player.morale + morale) / 2).round(),
              ),
            )
            .toList(),
        recentForm: form,
      );
    }).toList();
  }
}
