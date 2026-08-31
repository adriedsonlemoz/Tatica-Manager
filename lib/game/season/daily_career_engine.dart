import 'dart:math';

import '../../domain/player/player.dart';
import '../../domain/season/career_event.dart';
import '../../domain/season/career_state.dart';
import '../career/manager_career_engine.dart';
import '../competition/competition_simulation_engine.dart';
import '../contract/contract_lifecycle_engine.dart';
import '../cpu/cpu_user_offer_engine.dart';
import '../finance/club_administration_engine.dart';
import '../transfer/market_career_engine.dart';
import '../youth/youth_academy_engine.dart';
import 'inbox_engine.dart';
import 'calendar_engine.dart';

class DailyCareerAdvance {
  const DailyCareerAdvance({required this.state, required this.events});

  final CareerState state;
  final List<CareerEvent> events;
}

abstract final class DailyCareerEngine {
  static DailyCareerAdvance advance(CareerState state) {
    final prepared = YouthAcademyEngine.ensureAcademy(
      ContractLifecycleEngine.reconcile(state).state,
    );
    final simulated = CompetitionSimulationEngine.resolveCpuFixturesThroughDate(
      prepared,
      throughDate: prepared.currentDate,
      protectUserFixtures: prepared.managerEmployed,
    );
    final advanced = CareerCalendarEngine.advanceDay(simulated);
    var next = advanced.copyWith(
      news: prepared.managerEmployed
          ? CpuUserOfferEngine.expireInvalidOffers(
              state: advanced,
              news: prepared.news,
            )
          : prepared.news,
    );
    final events = <CareerEvent>[];

    if (next.managerEmployed) {
      _addRecoveryEvents(events, before: simulated, after: next);
      _addContractAlerts(events, next);
      _addNextMatchAlert(events, next);
      next = _addTransferOffer(events, next);
      _addTrainingSummary(events, simulated, next);
    }
    final marketAdvance = MarketCareerEngine.advanceDay(next);
    next = marketAdvance.state;
    events.addAll(marketAdvance.events);

    final managerAdvance = ManagerCareerEngine.advanceDay(next);
    next = managerAdvance.state;
    if (managerAdvance.event != null) events.add(managerAdvance.event!);

    next = ClubAdministrationEngine.advanceDay(next);

    final merged = [...next.news, ...events];
    final trimmed = merged.length <= CareerState.maxStoredNews
        ? merged
        : merged.sublist(merged.length - CareerState.maxStoredNews);
    next = next.copyWith(news: trimmed);
    next = InboxEngine.appendEvents(next, events);
    return DailyCareerAdvance(
      state: next,
      events: events,
    );
  }

  static void _addRecoveryEvents(
    List<CareerEvent> events, {
    required CareerState before,
    required CareerState after,
  }) {
    final beforeById = {for (final player in before.userClub.squad) player.id: player};
    for (final player in after.userClub.squad) {
      final previous = beforeById[player.id];
      if (previous == null) continue;
      if (previous.availabilityStatus == PlayerAvailabilityStatus.lowCondition &&
          player.availabilityStatus == PlayerAvailabilityStatus.available) {
        events.add(
          CareerEvent(
            id: 'recovered-${_dayKey(after.currentDate)}-${player.id}',
            date: after.currentDate,
            type: CareerEventType.playerRecovered,
            title: 'Jogador recuperado',
            message:
                '${player.displayName} voltou a ter condição física suficiente para ficar disponível.',
            playerId: player.id,
            clubId: after.userClubId,
          ),
        );
      }
    }
  }

  static void _addContractAlerts(List<CareerEvent> events, CareerState state) {
    final date = state.currentDate;
    if (!((date.month == 7 && date.day == 1) ||
        (date.month == 11 && date.day == 1))) {
      return;
    }
    final phase = date.month == 7 ? 'atenção' : 'final';
    final expiring = ContractLifecycleEngine.expiringThisSeason(state)
      ..sort((a, b) => b.overall.compareTo(a.overall));
    for (final player in expiring.take(5)) {
      final id = 'contract-$phase-${state.season}-${player.id}';
      if (state.news.any((item) => item.id == id)) continue;
      events.add(
        CareerEvent(
          id: id,
          date: date,
          type: CareerEventType.contractExpiring,
          title: 'Contrato próximo do fim',
          message: phase == 'final'
              ? '${player.displayName} pode deixar o clube ao fim da temporada se não renovar.'
              : 'O contrato de ${player.displayName} termina nesta temporada. Planeje a renovação.',
          playerId: player.id,
          clubId: state.userClubId,
        ),
      );
    }
  }

  static void _addNextMatchAlert(List<CareerEvent> events, CareerState state) {
    if (state.daysUntilNextMatch != 1) return;
    final fixture = state.nextUserFixture;
    if (fixture == null) return;
    final opponentId = fixture.homeClubId == state.userClubId
        ? fixture.awayClubId
        : fixture.homeClubId;
    final opponent = state.clubs.firstWhere((club) => club.id == opponentId);
    events.add(
      CareerEvent(
        id: 'next-match-${fixture.id}',
        date: state.currentDate,
        type: CareerEventType.nextMatch,
        title: 'Próxima partida amanhã',
        message:
            'A equipe enfrenta ${opponent.name} amanhã pela rodada ${fixture.round}.',
        clubId: opponent.id,
        fixtureId: fixture.id,
      ),
    );
  }

  static CareerState _addTransferOffer(
    List<CareerEvent> events,
    CareerState state,
  ) {
    final generated = CpuUserOfferEngine.generateNegotiationForDay(state);
    if (generated == null) return state;
    events.add(generated.event);
    return state.copyWith(
      transferNegotiations: [
        ...state.transferNegotiations,
        generated.negotiation,
      ],
    );
  }

  static void _addTrainingSummary(
    List<CareerEvent> events,
    CareerState before,
    CareerState after,
  ) {
    final beforePlayers = before.userClub.squad;
    final afterPlayers = after.userClub.squad;
    if (afterPlayers.isEmpty) return;
    final beforeCondition =
        beforePlayers.fold<int>(0, (sum, player) => sum + player.condition) /
            max(1, beforePlayers.length);
    final afterCondition =
        afterPlayers.fold<int>(0, (sum, player) => sum + player.condition) /
            afterPlayers.length;
    final afterFatigue =
        afterPlayers.fold<int>(0, (sum, player) => sum + player.fatigue) /
            afterPlayers.length;
    events.add(
      CareerEvent(
        id: 'training-${_dayKey(after.currentDate)}',
        date: after.currentDate,
        type: CareerEventType.training,
        title: 'Treino e recuperação',
        message:
            'Condição média ${afterCondition.round()}% (${afterCondition >= beforeCondition ? '+' : ''}${(afterCondition - beforeCondition).round()}), fadiga média ${afterFatigue.round()}%.',
        clubId: after.userClubId,
      ),
    );
  }

  static String _dayKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
