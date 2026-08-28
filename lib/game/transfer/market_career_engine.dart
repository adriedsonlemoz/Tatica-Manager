import 'dart:math';

import '../../domain/club/club.dart';
import '../../domain/finance/finance.dart';
import '../../domain/player/player.dart';
import '../../domain/season/career_event.dart';
import '../../domain/season/career_state.dart';
import '../../domain/transfer/market_career.dart';
import 'transfer_engine.dart';

class MarketCareerAdvance {
  const MarketCareerAdvance({
    required this.state,
    required this.events,
  });

  final CareerState state;
  final List<CareerEvent> events;
}

abstract final class MarketCareerEngine {
  static CareerState startScouting(CareerState state, String playerId) {
    if (state.scoutingReports.any((item) => item.playerId == playerId)) {
      return state;
    }
    if (_findPlayer(state, playerId) == null) {
      throw StateError('Jogador não encontrado no mercado.');
    }
    final report = PlayerScoutingReport(
      playerId: playerId,
      level: ScoutingLevel.initial,
      startedAt: state.currentDate,
      updatedAt: state.currentDate,
      daysObserved: 0,
    );
    return state.copyWith(
      scoutingReports: [...state.scoutingReports, report],
    );
  }

  static PlayerScoutingReport? reportFor(CareerState state, String playerId) =>
      state.scoutingReports.where((item) => item.playerId == playerId).firstOrNull;

  static TransferNegotiation createNegotiation({
    required CareerState state,
    required String playerId,
    required int fee,
    required int salary,
    required int years,
    required int signingBonus,
    required int installments,
  }) {
    final located = _locatePlayer(state, playerId);
    if (located == null) {
      throw StateError('Jogador não encontrado no mercado.');
    }
    if (located.$2?.id == state.userClubId) {
      throw StateError('O jogador já pertence ao seu clube.');
    }
    final active = state.transferNegotiations.any(
      (item) => item.playerId == playerId && item.status.isOpen,
    );
    if (active) {
      throw StateError('Já existe uma negociação ativa por esse jogador.');
    }
    final interestSeed = _stableSeed(
      '${state.careerId}|${state.season}|${state.currentDate.toIso8601String()}|$playerId',
    );
    final otherInterest = Random(interestSeed).nextInt(4);
    return TransferNegotiation(
      id: 'neg-${state.season}-${state.currentDate.millisecondsSinceEpoch}-$playerId',
      playerId: playerId,
      fromClubId: located.$2?.id,
      toClubId: state.userClubId,
      fee: located.$2 == null ? 0 : max(0, fee),
      salary: max(1, salary),
      contractYears: years.clamp(1, 5).toInt(),
      signingBonus: max(0, signingBonus),
      installments: located.$2 == null ? 1 : installments.clamp(1, 4).toInt(),
      startedAt: state.currentDate,
      nextActionDate: state.currentDate.add(const Duration(days: 1)),
      status: TransferNegotiationStatus.waiting,
      message: 'Proposta enviada. O clube e o jogador vão analisar as condições.',
      otherClubsInterested: otherInterest,
    );
  }

  static CareerState reviseNegotiation({
    required CareerState state,
    required String negotiationId,
    required int fee,
    required int salary,
    required int years,
    required int signingBonus,
    required int installments,
  }) {
    final negotiation = state.transferNegotiations
        .where((item) => item.id == negotiationId)
        .firstOrNull;
    if (negotiation == null || !negotiation.status.isOpen) {
      throw StateError('Negociação indisponível.');
    }
    final revised = negotiation.copyWith(
      fee: negotiation.fromClubId == null ? 0 : max(0, fee),
      salary: max(1, salary),
      contractYears: years.clamp(1, 5).toInt(),
      signingBonus: max(0, signingBonus),
      installments: negotiation.fromClubId == null ? 1 : installments.clamp(1, 4).toInt(),
      status: TransferNegotiationStatus.waiting,
      nextActionDate: state.currentDate.add(const Duration(days: 1)),
      message: 'Nova proposta enviada. Aguarde a resposta.',
      clearCounterFee: true,
      clearCounterSalary: true,
    );
    return state.copyWith(
      transferNegotiations: state.transferNegotiations
          .map((item) => item.id == negotiationId ? revised : item)
          .toList(growable: false),
    );
  }

  static CareerState closeNegotiation(CareerState state, String negotiationId) {
    return state.copyWith(
      transferNegotiations: state.transferNegotiations
          .map(
            (item) => item.id == negotiationId && item.status.isOpen
                ? item.copyWith(
                    status: TransferNegotiationStatus.withdrawn,
                    message: 'Negociação encerrada pelo clube.',
                  )
                : item,
          )
          .toList(growable: false),
    );
  }

  static CareerState markCompleted(CareerState state, String negotiationId) =>
      state.copyWith(
        transferNegotiations: state.transferNegotiations
            .map(
              (item) => item.id == negotiationId
                  ? item.copyWith(
                      status: TransferNegotiationStatus.completed,
                      message: 'Transferência concluída.',
                    )
                  : item,
            )
            .toList(growable: false),
      );

  static int upfrontAmount(int totalFee, int installments) {
    if (totalFee <= 0) return 0;
    final count = installments.clamp(1, 4).toInt();
    final base = totalFee ~/ count;
    final remainder = totalFee % count;
    return base + (remainder > 0 ? 1 : 0);
  }

  static List<TransferInstallmentPayment> buildFutureInstallments(
    TransferNegotiation negotiation,
    DateTime signedAt,
  ) {
    if (negotiation.fromClubId == null ||
        negotiation.fee <= 0 ||
        negotiation.installments <= 1) {
      return const [];
    }
    final count = negotiation.installments.clamp(1, 4).toInt();
    final base = negotiation.fee ~/ count;
    final remainder = negotiation.fee % count;
    final payments = <TransferInstallmentPayment>[];
    for (var index = 1; index < count; index++) {
      final amount = base + (index < remainder ? 1 : 0);
      payments.add(
        TransferInstallmentPayment(
          id: 'installment-${negotiation.id}-$index',
          negotiationId: negotiation.id,
          playerId: negotiation.playerId,
          fromClubId: negotiation.toClubId,
          toClubId: negotiation.fromClubId,
          amount: amount,
          dueDate: signedAt.add(Duration(days: 30 * index)),
        ),
      );
    }
    return payments;
  }

  static MarketCareerAdvance advanceDay(CareerState state) {
    final events = <CareerEvent>[];
    final reports = state.scoutingReports.map((report) {
      if (!_isBefore(report.updatedAt, state.currentDate)) return report;
      final days = report.daysObserved + 1;
      final level = days >= 4
          ? ScoutingLevel.complete
          : days >= 2
              ? ScoutingLevel.observed
              : ScoutingLevel.initial;
      if (level != report.level) {
        final player = _findPlayer(state, report.playerId);
        if (player != null) {
          events.add(
            CareerEvent(
              id: 'scout-${state.currentDate.year}-${state.currentDate.month}-${state.currentDate.day}-${player.id}-${level.name}',
              date: state.currentDate,
              type: CareerEventType.info,
              title: level == ScoutingLevel.complete
                  ? 'Relatório completo disponível'
                  : 'Observação atualizada',
              message:
                  '${player.displayName}: ${level.label.toLowerCase()} disponível na Central de Mercado.',
              playerId: player.id,
              clubId: player.clubId,
            ),
          );
        }
      }
      return report.copyWith(
        level: level,
        daysObserved: days,
        updatedAt: state.currentDate,
      );
    }).toList(growable: false);

    final negotiations = state.transferNegotiations.map((negotiation) {
      if (negotiation.status != TransferNegotiationStatus.waiting ||
          negotiation.nextActionDate.isAfter(state.currentDate)) {
        return negotiation;
      }
      final located = _locatePlayer(state, negotiation.playerId);
      if (located == null) {
        return negotiation.copyWith(
          status: TransferNegotiationStatus.withdrawn,
          message: 'O jogador não está mais disponível.',
        );
      }
      final player = located.$1;
      final seller = located.$2;
      final buyer = state.userClub;
      final decision = TransferEngine.evaluate(
        player: player,
        buyer: buyer,
        seller: seller,
        fee: negotiation.fee,
        salary: negotiation.salary,
        years: negotiation.contractYears,
        upfrontFee: upfrontAmount(
          negotiation.fee,
          negotiation.installments,
        ),
      );
      TransferNegotiation updated;
      if (decision.accepted) {
        updated = negotiation.copyWith(
          status: TransferNegotiationStatus.accepted,
          message:
              'Clube e jogador aceitaram as bases. Você pode concluir a contratação.',
          nextActionDate: state.currentDate,
          clearCounterFee: true,
          clearCounterSalary: true,
        );
      } else if (decision.counterOffer != null) {
        final expectedSalary = max(player.salary, (player.salary * 1.05).round());
        updated = negotiation.copyWith(
          status: TransferNegotiationStatus.countered,
          counterFee: decision.counterOffer,
          counterSalary: expectedSalary,
          message:
              'O vendedor enviou uma contraproposta. Revise valor, salário e estrutura do acordo.',
          nextActionDate: state.currentDate,
        );
      } else {
        updated = negotiation.copyWith(
          status: TransferNegotiationStatus.rejected,
          message: decision.reason,
          nextActionDate: state.currentDate,
        );
      }
      events.add(
        CareerEvent(
          id: 'neg-response-${updated.id}-${state.currentDate.year}-${state.currentDate.month}-${state.currentDate.day}',
          date: state.currentDate,
          type: CareerEventType.info,
          title: updated.status == TransferNegotiationStatus.accepted
              ? 'Acordo encaminhado'
              : updated.status == TransferNegotiationStatus.countered
                  ? 'Contraproposta recebida'
                  : 'Negociação recusada',
          message: '${player.displayName}: ${updated.message}',
          playerId: player.id,
          clubId: seller?.id,
          negotiationId: updated.id,
        ),
      );
      return updated;
    }).toList(growable: false);

    final updated = state.copyWith(
      scoutingReports: reports,
      transferNegotiations: negotiations,
    );
    final settlement = _settleDueInstallments(updated);
    events.addAll(settlement.events);
    return MarketCareerAdvance(
      state: settlement.state,
      events: events,
    );
  }

  static MarketCareerAdvance _settleDueInstallments(CareerState state) {
    final due = state.transferInstallments
        .where((item) => !item.paid && !item.dueDate.isAfter(state.currentDate))
        .toList(growable: false);
    if (due.isEmpty) {
      return MarketCareerAdvance(state: state, events: const []);
    }

    var clubs = state.clubs;
    final finances = [...state.finances];
    final events = <CareerEvent>[];
    final paidIds = <String>{};
    for (final payment in due) {
      final buyerIndex = clubs.indexWhere((club) => club.id == payment.fromClubId);
      if (buyerIndex < 0) continue;
      final buyer = clubs[buyerIndex];
      final nextBuyer = buyer.copyWith(money: buyer.money - payment.amount);
      final buyerUpdated = [...clubs];
      buyerUpdated[buyerIndex] = nextBuyer;
      clubs = buyerUpdated;

      if (payment.toClubId != null) {
        final sellerIndex = clubs.indexWhere((club) => club.id == payment.toClubId);
        if (sellerIndex >= 0) {
          final seller = clubs[sellerIndex];
          final nextSeller = seller.copyWith(
            money: seller.money + payment.amount,
            transferBudget: seller.transferBudget + payment.amount,
          );
          final sellerUpdated = [...clubs];
          sellerUpdated[sellerIndex] = nextSeller;
          clubs = sellerUpdated;
        }
      }
      paidIds.add(payment.id);
      if (payment.fromClubId == state.userClubId) {
        finances.add(
          FinanceTransaction(
            id: '${payment.id}-${state.currentDate.millisecondsSinceEpoch}',
            season: state.season,
            round: state.currentRound,
            kind: FinanceKind.playerPurchase,
            description: 'Parcela de transferência',
            amount: -payment.amount,
            createdAt: state.currentDate,
          ),
        );
      }
      final player = _findPlayer(state, payment.playerId);
      events.add(
        CareerEvent(
          id: 'paid-${payment.id}',
          date: state.currentDate,
          type: CareerEventType.info,
          title: 'Parcela de transferência paga',
          message: '${player?.displayName ?? 'Contratação'}: pagamento de R\$ ${payment.amount} liquidado conforme o acordo.',
          playerId: payment.playerId,
          clubId: payment.toClubId,
          amount: payment.amount,
          negotiationId: payment.negotiationId,
        ),
      );
    }
    if (paidIds.isEmpty) {
      return MarketCareerAdvance(state: state, events: const []);
    }
    final payments = state.transferInstallments
        .map((item) => paidIds.contains(item.id)
            ? item.copyWith(paid: true, paidAt: state.currentDate)
            : item)
        .toList(growable: false);
    return MarketCareerAdvance(
      state: state.copyWith(
        clubs: clubs,
        finances: finances,
        transferInstallments: payments,
      ),
      events: events,
    );
  }

  static Player? _findPlayer(CareerState state, String playerId) =>
      _locatePlayer(state, playerId)?.$1;

  static (Player, Club?)? _locatePlayer(CareerState state, String playerId) {
    for (final club in state.clubs) {
      final player = club.squad.where((item) => item.id == playerId).firstOrNull;
      if (player != null) return (player, club);
    }
    final free = state.freeAgents.where((item) => item.id == playerId).firstOrNull;
    if (free != null) return (free, null);
    return null;
  }

  static bool _isBefore(DateTime a, DateTime b) =>
      DateTime(a.year, a.month, a.day)
          .compareTo(DateTime(b.year, b.month, b.day)) <
      0;

  static int _stableSeed(String value) {
    var hash = 17;
    for (final code in value.codeUnits) {
      hash = 0x7fffffff & (hash * 31 + code);
    }
    return hash;
  }
}
