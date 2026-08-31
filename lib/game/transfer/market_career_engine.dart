import 'dart:math';

import '../../domain/club/club.dart';
import '../../domain/finance/finance.dart';
import '../../domain/player/player.dart';
import '../../domain/season/career_event.dart';
import '../../domain/season/career_state.dart';
import '../../domain/transfer/market_career.dart';
import '../contract/contract_engine.dart';
import '../lineup/lineup_engine.dart';
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

  /// Localiza um atleta cujo contrato pertence ao clube do usuário.
  ///
  /// Um jogador emprestado continua no elenco do clube que o recebeu, porém o
  /// vínculo contratual segue pertencendo ao clube de origem. Este método evita
  /// que a tela de contratos e a Central de Negociações tratem esse atleta como
  /// se ele pertencesse ao clube receptor.
  static ({Player player, Club holder})? userContractPlayerLocation(
    CareerState state,
    String playerId,
  ) {
    for (final club in state.clubs) {
      final player = club.squad.where((item) => item.id == playerId).firstOrNull;
      if (player == null) continue;
      final belongsToUser =
          (club.id == state.userClubId && player.loan == null) ||
              player.loan?.parentClubId == state.userClubId;
      if (belongsToUser) return (player: player, holder: club);
    }
    return null;
  }

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
    if (located.$1.loan != null) {
      throw StateError('O jogador está emprestado e não pode ser contratado agora.');
    }
    if (_hasOpenNegotiation(state, playerId)) {
      throw StateError('Já existe uma negociação ativa por esse jogador.');
    }
    final interestSeed = _stableSeed(
      '${state.careerId}|${state.season}|${state.currentDate.toIso8601String()}|$playerId',
    );
    final otherInterest = Random(interestSeed).nextInt(4);
    final proposedFee = located.$2 == null ? 0 : max(0, fee);
    final proposedSalary = max(1, salary);
    final proposedBonus = max(0, signingBonus);
    final proposedInstallments =
        located.$2 == null ? 1 : installments.clamp(1, 4).toInt();
    _ensureUserCanAffordTransferProposal(
      state: state,
      toClubId: state.userClubId,
      fee: proposedFee,
      signingBonus: proposedBonus,
      installments: proposedInstallments,
    );
    return TransferNegotiation(
      id: 'neg-${state.season}-${state.currentDate.millisecondsSinceEpoch}-$playerId',
      playerId: playerId,
      fromClubId: located.$2?.id,
      toClubId: state.userClubId,
      fee: proposedFee,
      salary: proposedSalary,
      contractYears: years.clamp(1, 5).toInt(),
      signingBonus: proposedBonus,
      installments: proposedInstallments,
      startedAt: state.currentDate,
      nextActionDate: state.currentDate.add(const Duration(days: 1)),
      status: TransferNegotiationStatus.waiting,
      message: 'Proposta enviada. O clube e o jogador vão analisar as condições.',
      otherClubsInterested: otherInterest,
    );
  }

  static TransferNegotiation createRenewalNegotiation({
    required CareerState state,
    required String playerId,
    required int salary,
    required int years,
  }) {
    final location = userContractPlayerLocation(state, playerId);
    if (location == null) {
      throw StateError('O contrato deste jogador não pertence ao seu clube.');
    }
    if (_hasOpenNegotiation(state, playerId)) {
      throw StateError('Já existe uma negociação ativa por esse jogador.');
    }
    final proposedSalary = salary.clamp(1, 100000000).toInt();
    final signingBonus = proposedSalary * 2;
    _ensureUserCanAffordRenewalBonus(
      state: state,
      signingBonus: signingBonus,
    );
    return TransferNegotiation(
      id: 'renew-${state.season}-${state.currentDate.millisecondsSinceEpoch}-$playerId',
      playerId: playerId,
      kind: TransferNegotiationKind.contractRenewal,
      fromClubId: state.userClubId,
      toClubId: state.userClubId,
      fee: 0,
      salary: proposedSalary,
      contractYears: years.clamp(1, 5).toInt(),
      signingBonus: signingBonus,
      installments: 1,
      startedAt: state.currentDate,
      nextActionDate: state.currentDate.add(const Duration(days: 1)),
      status: TransferNegotiationStatus.waiting,
      message: 'Proposta de renovação enviada ao jogador e ao seu representante.',
    );
  }

  static TransferNegotiation createIncomingOffer({
    required CareerState state,
    required String playerId,
    required String buyerClubId,
    required int fee,
    required int salary,
    required int years,
    TransferNegotiationKind kind = TransferNegotiationKind.permanentTransfer,
    DateTime? loanEndDate,
  }) {
    final seller = state.userClub;
    final player = seller.squad.where((item) => item.id == playerId).firstOrNull;
    final buyer = state.clubs.where((item) => item.id == buyerClubId).firstOrNull;
    if (player == null || buyer == null || buyer.id == seller.id) {
      throw StateError('Os dados da proposta não estão mais disponíveis.');
    }
    if (player.loan != null) {
      throw StateError('O jogador está emprestado e não pode receber propostas.');
    }
    if (_hasOpenNegotiation(state, playerId)) {
      throw StateError('Já existe uma negociação ativa por esse jogador.');
    }
    if (kind == TransferNegotiationKind.loan && !player.availableForLoan) {
      throw StateError('O jogador não está disponível para empréstimo.');
    }
    return TransferNegotiation(
      id: 'incoming-${kind.name}-${state.season}-${state.currentDate.millisecondsSinceEpoch}-$playerId-$buyerClubId',
      playerId: playerId,
      kind: kind,
      fromClubId: seller.id,
      toClubId: buyer.id,
      fee: kind == TransferNegotiationKind.loan ? 0 : fee.clamp(0, 1000000000).toInt(),
      salary: salary.clamp(1, 100000000).toInt(),
      contractYears: kind == TransferNegotiationKind.loan
          ? 1
          : years.clamp(1, 5).toInt(),
      signingBonus: 0,
      installments: 1,
      startedAt: state.currentDate,
      nextActionDate: state.currentDate.add(const Duration(days: 5)),
      status: TransferNegotiationStatus.received,
      message: kind == TransferNegotiationKind.loan
          ? '${buyer.name} quer receber ${player.displayName} por empréstimo até ${_dateLabel(loanEndDate ?? _defaultLoanEndDate(state.currentDate))}.'
          : '${buyer.name} enviou uma proposta por ${player.displayName}.',
      loanEndDate: kind == TransferNegotiationKind.loan
          ? (loanEndDate ?? _defaultLoanEndDate(state.currentDate))
          : null,
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
    if (negotiation.kind == TransferNegotiationKind.loan) {
      throw StateError('A proposta de empréstimo não possui valores para revisar.');
    }
    final proposedSalary = max(1, salary);
    final revised = negotiation.copyWith(
      fee: negotiation.kind == TransferNegotiationKind.contractRenewal ||
              negotiation.fromClubId == null
          ? 0
          : max(0, fee),
      salary: proposedSalary,
      contractYears: years.clamp(1, 5).toInt(),
      signingBonus: negotiation.kind == TransferNegotiationKind.contractRenewal
          ? proposedSalary * 2
          : max(0, signingBonus),
      installments: negotiation.kind == TransferNegotiationKind.contractRenewal ||
              negotiation.fromClubId == null
          ? 1
          : installments.clamp(1, 4).toInt(),
      status: TransferNegotiationStatus.waiting,
      nextActionDate: state.currentDate.add(const Duration(days: 1)),
      message: 'Nova proposta enviada. Aguarde a resposta.',
      clearCounterFee: true,
      clearCounterSalary: true,
    );
    if (revised.kind == TransferNegotiationKind.contractRenewal) {
      _ensureUserCanAffordRenewalBonus(
        state: state,
        signingBonus: revised.signingBonus,
        excludingNegotiationId: negotiation.id,
      );
    } else {
      _ensureUserCanAffordTransferProposal(
        state: state,
        toClubId: revised.toClubId,
        fee: revised.fee,
        signingBonus: revised.signingBonus,
        installments: revised.installments,
        excludingNegotiationId: negotiation.id,
      );
    }
    return state.copyWith(
      transferNegotiations: state.transferNegotiations
          .map((item) => item.id == negotiationId ? revised : item)
          .toList(growable: false),
    );
  }

  static CareerState acceptReceivedNegotiation(
    CareerState state,
    String negotiationId,
  ) {
    return _updateNegotiation(
      state,
      negotiationId,
      (negotiation) {
        if (negotiation.status != TransferNegotiationStatus.received) {
          throw StateError('Esta proposta não está aguardando sua resposta.');
        }
        return negotiation.copyWith(
          status: TransferNegotiationStatus.accepted,
          nextActionDate: state.currentDate,
          message: negotiation.kind == TransferNegotiationKind.loan
              ? 'Você aceitou as bases do empréstimo. Confirme a conclusão para liberar o atleta.'
              : 'Você aceitou as bases da proposta. Confirme a conclusão para efetivar o acordo.',
        );
      },
    );
  }

  static CareerState rejectReceivedNegotiation(
    CareerState state,
    String negotiationId,
  ) {
    return _updateNegotiation(
      state,
      negotiationId,
      (negotiation) {
        if (!negotiation.status.isOpen) {
          throw StateError('Esta negociação já foi encerrada.');
        }
        return negotiation.copyWith(
          status: TransferNegotiationStatus.rejected,
          nextActionDate: state.currentDate,
          message: 'Proposta recusada pelo clube.',
        );
      },
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
                      message: switch (item.kind) {
                        TransferNegotiationKind.permanentTransfer =>
                          'Transferência concluída.',
                        TransferNegotiationKind.contractRenewal =>
                          'Renovação contratual concluída.',
                        TransferNegotiationKind.loan =>
                          'Empréstimo concluído.',
                      },
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

  static CareerState completeLoan(CareerState state, String negotiationId) {
    final negotiation = state.transferNegotiations
        .where((item) => item.id == negotiationId)
        .firstOrNull;
    if (negotiation == null ||
        negotiation.kind != TransferNegotiationKind.loan ||
        negotiation.status != TransferNegotiationStatus.accepted) {
      throw StateError('O empréstimo ainda não está pronto para conclusão.');
    }
    final seller = state.clubs
        .where((club) => club.id == negotiation.fromClubId)
        .firstOrNull;
    final buyer = state.clubs
        .where((club) => club.id == negotiation.toClubId)
        .firstOrNull;
    final player = seller?.squad
        .where((item) => item.id == negotiation.playerId)
        .firstOrNull;
    final endDate = negotiation.loanEndDate;
    if (seller == null || buyer == null || player == null || endDate == null) {
      throw StateError('Os dados do empréstimo não estão mais disponíveis.');
    }
    if (player.loan != null || !player.availableForLoan) {
      throw StateError('O jogador não está mais disponível para empréstimo.');
    }
    if (seller.squad.length <= TransferEngine.minimumSquadSize) {
      throw StateError(
        'Mantenha pelo menos ${TransferEngine.minimumSquadSize} jogadores no elenco.',
      );
    }
    if (buyer.squad.length >= TransferEngine.maximumSquadSize) {
      throw StateError('O clube de destino já atingiu o limite de elenco.');
    }

    final moved = player.copyWith(
      clubId: buyer.id,
      listed: false,
      availableForLoan: false,
      loan: PlayerLoan(parentClubId: seller.id, endsAt: endDate),
    );
    final updatedSeller = seller.copyWith(
      squad: seller.squad.where((item) => item.id != player.id).toList(),
    );
    final updatedBuyer = buyer.copyWith(
      squad: [...buyer.squad.where((item) => item.id != player.id), moved],
    );
    final clubs = state.clubs
        .map((club) {
          if (club.id == seller.id) return updatedSeller;
          if (club.id == buyer.id) return updatedBuyer;
          return club;
        })
        .toList(growable: false);
    var starters = state.starterIds;
    if (seller.id == state.userClubId && starters.contains(player.id)) {
      starters = LineupEngine.autoSelect(updatedSeller.squad, state.formation);
    } else if (buyer.id == state.userClubId && starters.length < 11) {
      starters = LineupEngine.autoSelect(updatedBuyer.squad, state.formation);
    }
    return state.copyWith(clubs: clubs, starterIds: starters);
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

    final negotiations = <TransferNegotiation>[];
    for (final negotiation in state.transferNegotiations) {
      var updated = negotiation;
      var changed = false;
      if (negotiation.status == TransferNegotiationStatus.received &&
          negotiation.nextActionDate.isBefore(state.currentDate)) {
        updated = negotiation.copyWith(
          status: TransferNegotiationStatus.withdrawn,
          message: 'A proposta expirou sem uma resposta do clube.',
          nextActionDate: state.currentDate,
        );
        changed = true;
      } else if (negotiation.status == TransferNegotiationStatus.waiting &&
          !negotiation.nextActionDate.isAfter(state.currentDate)) {
        updated = _evaluateWaitingNegotiation(state, negotiation);
        changed = updated.status != negotiation.status ||
            updated.message != negotiation.message;
      }
      negotiations.add(updated);
      if (changed) {
        final player = _findPlayer(state, negotiation.playerId);
        events.add(
          CareerEvent(
            id: 'neg-response-${updated.id}-${state.currentDate.year}-${state.currentDate.month}-${state.currentDate.day}',
            date: state.currentDate,
            type: CareerEventType.info,
            title: _eventTitleFor(updated.status),
            message: '${player?.displayName ?? 'Negociação'}: ${updated.message}',
            playerId: updated.playerId,
            clubId: updated.fromClubId ?? updated.toClubId,
            negotiationId: updated.id,
          ),
        );
      }
    }

    final updated = state.copyWith(
      scoutingReports: reports,
      transferNegotiations: negotiations,
    );
    final settlement = _settleDueInstallments(updated);
    events.addAll(settlement.events);
    final loanReturns = _returnDueLoans(settlement.state);
    events.addAll(loanReturns.events);
    return MarketCareerAdvance(
      state: loanReturns.state,
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
      final sellerIndex = payment.toClubId == null
          ? -1
          : clubs.indexWhere((club) => club.id == payment.toClubId);
      if (buyerIndex < 0 || (payment.toClubId != null && sellerIndex < 0)) {
        _addInstallmentPendingEvent(
          events,
          state: state,
          payment: payment,
          reason: 'um dos clubes envolvidos não está mais disponível',
        );
        continue;
      }
      final buyer = clubs[buyerIndex];
      if (buyer.money < payment.amount) {
        _addInstallmentPendingEvent(
          events,
          state: state,
          payment: payment,
          reason: '${buyer.name} não possui caixa suficiente',
        );
        continue;
      }
      final nextBuyer = buyer.copyWith(money: buyer.money - payment.amount);
      final buyerUpdated = [...clubs];
      buyerUpdated[buyerIndex] = nextBuyer;
      clubs = buyerUpdated;

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
      } else if (payment.toClubId == state.userClubId) {
        finances.add(
          FinanceTransaction(
            id: '${payment.id}-${state.currentDate.millisecondsSinceEpoch}',
            season: state.season,
            round: state.currentRound,
            kind: FinanceKind.playerSale,
            description: 'Parcela da venda de jogador',
            amount: payment.amount,
            createdAt: state.currentDate,
          ),
        );
      }
      final player = _findPlayer(state, payment.playerId);
      if (payment.fromClubId == state.userClubId ||
          payment.toClubId == state.userClubId) {
        final userSold = payment.toClubId == state.userClubId;
        events.add(
          CareerEvent(
            id: 'paid-${payment.id}',
            date: state.currentDate,
            type: CareerEventType.info,
            title: userSold
                ? 'Parcela de venda recebida'
                : 'Parcela de transferência paga',
            message:
                '${player?.displayName ?? 'Contratação'}: ${userSold ? 'recebimento' : 'pagamento'} de R\$ ${payment.amount} liquidado conforme o acordo.',
            playerId: payment.playerId,
            clubId: payment.toClubId,
            amount: payment.amount,
            negotiationId: payment.negotiationId,
          ),
        );
      }
    }
    if (paidIds.isEmpty) {
      return MarketCareerAdvance(state: state, events: events);
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

  static bool _hasOpenNegotiation(CareerState state, String playerId) =>
      state.transferNegotiations.any(
        (item) => item.playerId == playerId && item.status.isOpen,
      );

  static void _ensureUserCanAffordTransferProposal({
    required CareerState state,
    required String toClubId,
    required int fee,
    required int signingBonus,
    required int installments,
    String? excludingNegotiationId,
  }) {
    if (toClubId != state.userClubId) return;
    final club = state.userClub;
    final commitments = state.transferNegotiations.where(
      (item) =>
          item.id != excludingNegotiationId &&
          item.status.isOpen &&
          item.kind == TransferNegotiationKind.permanentTransfer &&
          item.toClubId == state.userClubId,
    );
    final committedBudget = commitments.fold<int>(
      0,
      (total, item) => total + item.fee,
    );
    if (club.transferBudget < committedBudget + fee) {
      throw StateError(
        'Orçamento de transferências insuficiente considerando as propostas já em andamento.',
      );
    }
    final upfront = upfrontAmount(fee, installments);
    final committedCash = _pendingUserCashCommitments(
      state,
      excludingNegotiationId: excludingNegotiationId,
    );
    if (club.money < committedCash + upfront + signingBonus) {
      throw StateError(
        'Caixa insuficiente considerando a entrada e os bônus das propostas em andamento.',
      );
    }
  }

  static void _ensureUserCanAffordRenewalBonus({
    required CareerState state,
    required int signingBonus,
    String? excludingNegotiationId,
  }) {
    final committed = _pendingUserCashCommitments(
      state,
      excludingNegotiationId: excludingNegotiationId,
    );
    if (state.userClub.money < committed + signingBonus) {
      throw StateError(
        'Caixa insuficiente para as luvas desta renovação considerando negociações em andamento.',
      );
    }
  }

  static int _pendingUserCashCommitments(
    CareerState state, {
    String? excludingNegotiationId,
  }) =>
      state.transferNegotiations
          .where(
            (item) =>
                item.id != excludingNegotiationId &&
                item.status.isOpen &&
                item.toClubId == state.userClubId,
          )
          .fold<int>(0, (total, item) => total + _cashCommitmentFor(item));

  static int _cashCommitmentFor(TransferNegotiation negotiation) =>
      switch (negotiation.kind) {
        TransferNegotiationKind.permanentTransfer =>
          upfrontAmount(negotiation.fee, negotiation.installments) +
              negotiation.signingBonus,
        TransferNegotiationKind.contractRenewal => negotiation.signingBonus,
        TransferNegotiationKind.loan => 0,
      };

  static void _addInstallmentPendingEvent(
    List<CareerEvent> events, {
    required CareerState state,
    required TransferInstallmentPayment payment,
    required String reason,
  }) {
    if (payment.fromClubId != state.userClubId &&
        payment.toClubId != state.userClubId) {
      return;
    }
    final id = 'installment-pending-${payment.id}';
    if (state.news.any((event) => event.id == id) ||
        events.any((event) => event.id == id)) {
      return;
    }
    final player = _findPlayer(state, payment.playerId);
    events.add(
      CareerEvent(
        id: id,
        date: state.currentDate,
        type: CareerEventType.info,
        title: 'Parcela de transferência pendente',
        message:
            '${player?.displayName ?? 'A transferência'}: parcela de R\$ ${payment.amount} permanece pendente porque $reason.',
        playerId: payment.playerId,
        clubId: payment.toClubId ?? payment.fromClubId,
        amount: payment.amount,
        negotiationId: payment.negotiationId,
      ),
    );
  }

  static CareerState _updateNegotiation(
    CareerState state,
    String negotiationId,
    TransferNegotiation Function(TransferNegotiation negotiation) update,
  ) {
    var found = false;
    final negotiations = state.transferNegotiations.map((item) {
      if (item.id != negotiationId) return item;
      found = true;
      return update(item);
    }).toList(growable: false);
    if (!found) {
      throw StateError('Negociação não encontrada.');
    }
    return state.copyWith(transferNegotiations: negotiations);
  }

  static TransferNegotiation _evaluateWaitingNegotiation(
    CareerState state,
    TransferNegotiation negotiation,
  ) {
    switch (negotiation.kind) {
      case TransferNegotiationKind.contractRenewal:
        final location = userContractPlayerLocation(state, negotiation.playerId);
        if (location == null) {
          return negotiation.copyWith(
            status: TransferNegotiationStatus.withdrawn,
            message: 'O contrato não pertence mais ao seu clube.',
          );
        }
        final player = location.player;
        final result = ContractEngine.negotiate(
          player: player,
          proposal: ContractProposal(
            salary: negotiation.salary,
            years: negotiation.contractYears,
          ),
          season: state.season,
          clubMoney: state.userClub.money,
        );
        if (result.accepted) {
          return negotiation.copyWith(
            status: TransferNegotiationStatus.accepted,
            message:
                'O jogador aceitou as bases. Confirme a conclusão para registrar o novo contrato.',
            clearCounterFee: true,
            clearCounterSalary: true,
          );
        }
        if (result.requiredSalary != null) {
          return negotiation.copyWith(
            status: TransferNegotiationStatus.countered,
            counterSalary: result.requiredSalary,
            message:
                'O jogador pediu ${result.requiredSalary} por mês para aceitar a renovação.',
            clearCounterFee: true,
          );
        }
        return negotiation.copyWith(
          status: TransferNegotiationStatus.rejected,
          message: result.message,
          clearCounterFee: true,
          clearCounterSalary: true,
        );

      case TransferNegotiationKind.loan:
        final seller = state.clubs
            .where((club) => club.id == negotiation.fromClubId)
            .firstOrNull;
        final buyer = state.clubs
            .where((club) => club.id == negotiation.toClubId)
            .firstOrNull;
        final player = seller?.squad
            .where((item) => item.id == negotiation.playerId)
            .firstOrNull;
        if (seller == null || buyer == null || player == null) {
          return negotiation.copyWith(
            status: TransferNegotiationStatus.withdrawn,
            message: 'Os dados do empréstimo não estão mais disponíveis.',
          );
        }
        if (player.loan != null || !player.availableForLoan) {
          return negotiation.copyWith(
            status: TransferNegotiationStatus.rejected,
            message: 'O jogador não está mais disponível para empréstimo.',
          );
        }
        if (seller.squad.length <= TransferEngine.minimumSquadSize) {
          return negotiation.copyWith(
            status: TransferNegotiationStatus.rejected,
            message:
                'O clube não pode liberar o jogador sem ficar abaixo do elenco mínimo.',
          );
        }
        if (buyer.squad.length >= TransferEngine.maximumSquadSize) {
          return negotiation.copyWith(
            status: TransferNegotiationStatus.rejected,
            message: 'O clube interessado já atingiu o limite de elenco.',
          );
        }
        if (negotiation.loanEndDate == null ||
            !negotiation.loanEndDate!.isAfter(state.currentDate)) {
          return negotiation.copyWith(
            status: TransferNegotiationStatus.rejected,
            message: 'O prazo do empréstimo não é mais válido.',
          );
        }
        return negotiation.copyWith(
          status: TransferNegotiationStatus.accepted,
          message:
              'O clube aceitou o empréstimo. Confirme a conclusão para liberar o atleta até ${_dateLabel(negotiation.loanEndDate!)}.',
        );

      case TransferNegotiationKind.permanentTransfer:
        final located = _locatePlayer(state, negotiation.playerId);
        final player = located?.$1;
        final seller = negotiation.fromClubId == null
            ? null
            : state.clubs
                .where((club) => club.id == negotiation.fromClubId)
                .firstOrNull;
        final buyer = state.clubs
            .where((club) => club.id == negotiation.toClubId)
            .firstOrNull;
        if (player == null ||
            buyer == null ||
            (negotiation.fromClubId != null && seller == null) ||
            (seller != null && located?.$2?.id != seller.id)) {
          return negotiation.copyWith(
            status: TransferNegotiationStatus.withdrawn,
            message: 'Os dados da transferência não estão mais disponíveis.',
          );
        }
        final upfront = upfrontAmount(negotiation.fee, negotiation.installments);
        if (buyer.id == state.userClubId &&
            buyer.money < upfront + negotiation.signingBonus) {
          return negotiation.copyWith(
            status: TransferNegotiationStatus.rejected,
            message:
                'Caixa insuficiente para a entrada e o bônus de assinatura desta proposta.',
            clearCounterFee: true,
            clearCounterSalary: true,
          );
        }
        final decision = TransferEngine.evaluate(
          player: player,
          buyer: buyer,
          seller: seller,
          fee: negotiation.fee,
          salary: negotiation.salary,
          years: negotiation.contractYears,
          requireSellerMinimum: seller?.id != state.userClubId,
          upfrontFee: upfront,
        );
        if (decision.accepted) {
          final sentByUser = negotiation.toClubId == state.userClubId;
          return negotiation.copyWith(
            status: TransferNegotiationStatus.accepted,
            message: sentByUser
                ? 'As bases foram aceitas. Confirme a conclusão para registrar a contratação.'
                : 'As bases foram aceitas. Confirme a conclusão para registrar a venda.',
            clearCounterFee: true,
            clearCounterSalary: true,
          );
        }
        if (decision.counterOffer != null) {
          return negotiation.copyWith(
            status: TransferNegotiationStatus.countered,
            counterFee: decision.counterOffer,
            message:
                'O clube pediu uma contraproposta de pelo menos ${decision.counterOffer}.',
            clearCounterSalary: true,
          );
        }
        return negotiation.copyWith(
          status: TransferNegotiationStatus.rejected,
          message: decision.reason,
          clearCounterFee: true,
          clearCounterSalary: true,
        );
    }
  }

  static MarketCareerAdvance _returnDueLoans(CareerState state) {
    var clubs = state.clubs;
    final events = <CareerEvent>[];
    var starters = state.starterIds;
    var userLostStarter = false;
    var userReceivedPlayer = false;

    for (final borrowerSnapshot in state.clubs) {
      for (final playerSnapshot in borrowerSnapshot.squad) {
        final loan = playerSnapshot.loan;
        if (loan == null || !loan.isDueOn(state.currentDate)) continue;
        final borrowerIndex = clubs.indexWhere(
          (club) => club.id == borrowerSnapshot.id,
        );
        final parentIndex = clubs.indexWhere(
          (club) => club.id == loan.parentClubId,
        );
        if (borrowerIndex < 0 || parentIndex < 0 || borrowerIndex == parentIndex) {
          continue;
        }
        final borrower = clubs[borrowerIndex];
        final player = borrower.squad
            .where((item) => item.id == playerSnapshot.id)
            .firstOrNull;
        if (player == null || player.loan == null) continue;
        final parent = clubs[parentIndex];
        final returned = player.copyWith(
          clubId: parent.id,
          listed: false,
          availableForLoan: false,
          clearLoan: true,
        );
        final updatedBorrower = borrower.copyWith(
          squad: borrower.squad.where((item) => item.id != player.id).toList(),
        );
        final updatedParent = parent.copyWith(
          squad: [
            ...parent.squad.where((item) => item.id != player.id),
            returned,
          ],
        );
        final nextClubs = [...clubs];
        nextClubs[borrowerIndex] = updatedBorrower;
        nextClubs[parentIndex] = updatedParent;
        clubs = nextClubs;
        if (borrower.id == state.userClubId && starters.contains(player.id)) {
          userLostStarter = true;
        }
        if (parent.id == state.userClubId) userReceivedPlayer = true;
        if (borrower.id == state.userClubId || parent.id == state.userClubId) {
          events.add(
            CareerEvent(
              id: 'loan-return-${player.id}-${state.currentDate.year}-${state.currentDate.month}-${state.currentDate.day}',
              date: state.currentDate,
              type: CareerEventType.info,
              title: 'Empréstimo encerrado',
              message:
                  '${player.displayName} retornou ao ${parent.name} após o fim do empréstimo.',
              playerId: player.id,
              clubId: parent.id,
            ),
          );
        }
      }
    }

    if (events.isEmpty) {
      return MarketCareerAdvance(state: state, events: const []);
    }
    final userClub =
        clubs.where((club) => club.id == state.userClubId).firstOrNull;
    if (userClub != null &&
        (userLostStarter || (userReceivedPlayer && starters.length < 11))) {
      starters = LineupEngine.autoSelect(userClub.squad, state.formation);
    }
    return MarketCareerAdvance(
      state: state.copyWith(clubs: clubs, starterIds: starters),
      events: events,
    );
  }

  static DateTime _defaultLoanEndDate(DateTime currentDate) {
    final end = DateTime(currentDate.year, 12, 31);
    return end.isAfter(currentDate)
        ? end
        : DateTime(currentDate.year + 1, 6, 30);
  }

  static String _dateLabel(DateTime value) {
    const months = [
      'jan',
      'fev',
      'mar',
      'abr',
      'mai',
      'jun',
      'jul',
      'ago',
      'set',
      'out',
      'nov',
      'dez',
    ];
    return '${value.day.toString().padLeft(2, '0')}/${months[value.month - 1]}/${value.year}';
  }

  static String _eventTitleFor(TransferNegotiationStatus status) =>
      switch (status) {
        TransferNegotiationStatus.received => 'Nova proposta recebida',
        TransferNegotiationStatus.waiting => 'Negociação atualizada',
        TransferNegotiationStatus.countered => 'Contraproposta recebida',
        TransferNegotiationStatus.accepted => 'Acordo alcançado',
        TransferNegotiationStatus.rejected => 'Negociação recusada',
        TransferNegotiationStatus.completed => 'Negociação concluída',
        TransferNegotiationStatus.withdrawn => 'Negociação encerrada',
      };

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
