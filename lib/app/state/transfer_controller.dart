import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/formatters.dart';
import '../../domain/club/club.dart';
import '../../domain/finance/finance.dart';
import '../../domain/player/player.dart';
import '../../domain/season/career_event.dart';
import '../../domain/transfer/market_career.dart';
import '../../domain/transfer/transfer.dart';
import '../../game/contract/contract_engine.dart';
import '../../game/cpu/cpu_recruitment_engine.dart';
import '../../game/cpu/cpu_user_offer_engine.dart';
import '../../game/lineup/lineup_engine.dart';
import '../../game/transfer/market_career_engine.dart';
import '../../game/transfer/transfer_engine.dart';
import '../../game/transfer/transfer_window_engine.dart';
import 'game_controller.dart';

final transferControllerProvider = Provider<TransferController>(
  TransferController.new,
);

class TransferController {
  TransferController(this.ref);

  final Ref ref;

  GameController get _game => ref.read(gameControllerProvider.notifier);


  Future<TransferOperationResult> startScouting(String playerId) async {
    final career = ref.read(gameControllerProvider).career;
    if (career == null) {
      return const TransferOperationResult(
        accepted: false,
        message: 'Nenhuma carreira ativa.',
      );
    }
    try {
      final next = MarketCareerEngine.startScouting(career, playerId);
      if (identical(next, career)) {
        return const TransferOperationResult(
          accepted: true,
          message: 'O jogador já está sendo observado.',
        );
      }
      await _game.commitCareer(
        next,
        message: 'Observação iniciada. Novas informações chegarão nos próximos dias.',
      );
      return const TransferOperationResult(
        accepted: true,
        message: 'Observação iniciada.',
      );
    } on StateError catch (error) {
      return TransferOperationResult(
        accepted: false,
        message: error.message.toString(),
      );
    }
  }

  Future<TransferOperationResult> startMarketNegotiation({
    required String playerId,
    required int fee,
    required int salary,
    required int years,
    required int signingBonus,
    required int installments,
  }) async {
    final career = ref.read(gameControllerProvider).career;
    if (career == null) {
      return const TransferOperationResult(
        accepted: false,
        message: 'Nenhuma carreira ativa.',
      );
    }
    if (!TransferWindowEngine.isOpen(career.currentDate)) {
      return TransferOperationResult(
        accepted: false,
        message: 'A janela de transferências está fechada. Períodos: ${TransferWindowEngine.rulesLabel}.',
      );
    }
    try {
      final negotiation = MarketCareerEngine.createNegotiation(
        state: career,
        playerId: playerId,
        fee: fee,
        salary: salary,
        years: years,
        signingBonus: signingBonus,
        installments: installments,
      );
      await _game.commitCareer(
        career.copyWith(
          transferNegotiations: [...career.transferNegotiations, negotiation],
        ),
        message: 'Proposta enviada. A resposta chegará ao avançar o dia.',
      );
      return const TransferOperationResult(
        accepted: true,
        message: 'Proposta enviada.',
      );
    } on StateError catch (error) {
      return TransferOperationResult(
        accepted: false,
        message: error.message.toString(),
      );
    }
  }

  Future<TransferOperationResult> reviseMarketNegotiation({
    required String negotiationId,
    required int fee,
    required int salary,
    required int years,
    required int signingBonus,
    required int installments,
  }) async {
    final career = ref.read(gameControllerProvider).career;
    if (career == null) {
      return const TransferOperationResult(
        accepted: false,
        message: 'Nenhuma carreira ativa.',
      );
    }
    try {
      final next = MarketCareerEngine.reviseNegotiation(
        state: career,
        negotiationId: negotiationId,
        fee: fee,
        salary: salary,
        years: years,
        signingBonus: signingBonus,
        installments: installments,
      );
      await _game.commitCareer(
        next,
        message: 'Contraproposta enviada. Aguarde a próxima resposta.',
      );
      return const TransferOperationResult(
        accepted: true,
        message: 'Contraproposta enviada.',
      );
    } on StateError catch (error) {
      return TransferOperationResult(
        accepted: false,
        message: error.message.toString(),
      );
    }
  }

  Future<TransferOperationResult> closeMarketNegotiation(
    String negotiationId,
  ) async {
    final career = ref.read(gameControllerProvider).career;
    if (career == null) {
      return const TransferOperationResult(
        accepted: false,
        message: 'Nenhuma carreira ativa.',
      );
    }
    await _game.commitCareer(
      MarketCareerEngine.closeNegotiation(career, negotiationId),
      message: 'Negociação encerrada.',
    );
    return const TransferOperationResult(
      accepted: true,
      message: 'Negociação encerrada.',
    );
  }

  Future<TransferOperationResult> completeMarketNegotiation(
    String negotiationId,
  ) async {
    final career = ref.read(gameControllerProvider).career;
    if (career == null) {
      return const TransferOperationResult(
        accepted: false,
        message: 'Nenhuma carreira ativa.',
      );
    }
    final negotiation = career.transferNegotiations
        .where((item) => item.id == negotiationId)
        .firstOrNull;
    if (negotiation == null ||
        negotiation.status != TransferNegotiationStatus.accepted) {
      return const TransferOperationResult(
        accepted: false,
        message: 'A negociação ainda não está pronta para conclusão.',
      );
    }
    final upfront = MarketCareerEngine.upfrontAmount(
      negotiation.fee,
      negotiation.installments,
    );
    final signingCash = upfront + negotiation.signingBonus;
    if (career.userClub.money < signingCash) {
      return TransferOperationResult(
        accepted: false,
        message:
            'Caixa insuficiente para entrada e bônus de assinatura (${formatMoney(signingCash)}).',
      );
    }
    final result = await buyPlayer(
      playerId: negotiation.playerId,
      fee: negotiation.fee,
      salary: negotiation.salary,
      years: negotiation.contractYears,
      upfrontFee: upfront,
    );
    if (!result.accepted) return result;

    final latest = ref.read(gameControllerProvider).career;
    if (latest != null) {
      var next = MarketCareerEngine.markCompleted(latest, negotiationId);
      final futureInstallments = MarketCareerEngine.buildFutureInstallments(
        negotiation,
        latest.currentDate,
      );
      if (futureInstallments.isNotEmpty) {
        next = next.copyWith(
          transferInstallments: [
            ...next.transferInstallments,
            ...futureInstallments,
          ],
        );
      }
      if (negotiation.signingBonus > 0) {
        final club = next.userClub;
        final bonus = negotiation.signingBonus;
        final updatedClub = club.copyWith(
          money: club.money - bonus,
        );
        next = next.copyWith(
          clubs: next.clubs
              .map((item) => item.id == club.id ? updatedClub : item)
              .toList(growable: false),
          finances: [
            ...next.finances,
            FinanceTransaction(
              id: '${next.season}_${next.roundIndex}_signing_${negotiation.playerId}',
              season: next.season,
              round: next.currentRound,
              kind: FinanceKind.operations,
              description: 'Bônus de assinatura',
              amount: -bonus,
              createdAt: DateTime.now(),
            ),
          ],
        );
      }
      await _game.commitCareer(next);
    }
    return result;
  }

  Future<TransferOperationResult> buyPlayer({
    required String playerId,
    required int fee,
    required int salary,
    required int years,
    int? upfrontFee,
  }) async {
    final career = ref.read(gameControllerProvider).career;
    if (career == null) {
      return const TransferOperationResult(
        accepted: false,
        message: 'Nenhuma carreira ativa.',
      );
    }
    if (!TransferWindowEngine.isOpen(career.currentDate)) {
      return TransferOperationResult(
        accepted: false,
        message: 'A janela de transferências está fechada. Períodos: ${TransferWindowEngine.rulesLabel}.',
      );
    }

    Player? player;
    Club? seller;
    for (final club in career.clubs) {
      for (final item in club.squad) {
        if (item.id == playerId) {
          player = item;
          seller = club;
          break;
        }
      }
      if (player != null) break;
    }
    player ??= career.freeAgents.where((item) => item.id == playerId).firstOrNull;
    if (player == null) {
      return const TransferOperationResult(
        accepted: false,
        message: 'Jogador não encontrado.',
      );
    }
    if (seller?.id == career.userClubId) {
      return const TransferOperationResult(
        accepted: false,
        message: 'O jogador já pertence ao seu clube.',
      );
    }

    final buyer = career.userClub;
    final execution = TransferEngine.execute(
      player: player,
      buyer: buyer,
      seller: seller,
      fee: fee,
      salary: salary,
      years: years,
      season: career.season,
      upfrontFee: upfrontFee,
    );
    if (!execution.decision.accepted) {
      final counter = execution.decision.counterOffer;
      final message = counter == null
          ? execution.decision.reason
          : 'O clube pede pelo menos ${formatMoney(counter)}.';
      return TransferOperationResult(
        accepted: false,
        message: message,
        counterOffer: counter,
      );
    }

    final clubs = career.clubs.map((club) {
      if (club.id == buyer.id) return execution.buyer;
      if (seller != null && club.id == seller.id) return execution.seller!;
      return club;
    }).toList();
    final freeAgents =
        career.freeAgents.where((item) => item.id != player!.id).toList();
    final paidNow = upfrontFee ?? fee;
    final transaction = FinanceTransaction(
      id: '${career.season}_${career.roundIndex}_buy_${player.id}',
      season: career.season,
      round: career.currentRound,
      kind: FinanceKind.playerPurchase,
      description: upfrontFee != null && upfrontFee < fee
          ? 'Entrada da contratação de ${player.displayName}'
          : 'Contratação de ${player.displayName}',
      amount: -paidNow,
      createdAt: DateTime.now(),
    );
    var starters = career.starterIds;
    if (starters.length < 11) {
      starters = LineupEngine.autoSelect(
        execution.buyer.squad,
        career.formation,
      );
    }

    final next = career.copyWith(
      clubs: clubs,
      freeAgents: freeAgents,
      finances: [...career.finances, transaction],
      starterIds: starters,
    );
    await _game.commitCareer(next);
    return TransferOperationResult(
      accepted: true,
      message: upfrontFee != null && upfrontFee < fee
          ? '${player.displayName} foi contratado por ${formatMoney(fee)} (${formatMoney(paidNow)} pagos na assinatura).'
          : '${player.displayName} foi contratado por ${formatMoney(fee)}.',
    );
  }

  Future<TransferOperationResult> renewPlayer({
    required String playerId,
    required int salary,
    required int years,
  }) async {
    final career = ref.read(gameControllerProvider).career;
    if (career == null) {
      return const TransferOperationResult(
        accepted: false,
        message: 'Nenhuma carreira ativa.',
      );
    }

    final club = career.userClub;
    final player = club.squad.firstWhere((item) => item.id == playerId);
    final negotiation = ContractEngine.negotiate(
      player: player,
      proposal: ContractProposal(salary: salary, years: years),
      season: career.season,
      clubMoney: club.money,
    );
    if (!negotiation.accepted) {
      final counter = negotiation.requiredSalary;
      final message = counter == null
          ? negotiation.message
          : 'O jogador pede pelo menos ${formatMoney(counter)} por mês.';
      return TransferOperationResult(
        accepted: false,
        message: message,
        counterOffer: counter,
      );
    }

    final updatedClub = club.copyWith(
      money: club.money - negotiation.signingCost,
      squad: club.squad
          .map((item) => item.id == playerId ? negotiation.player : item)
          .toList(),
    );
    final transaction = FinanceTransaction(
      id: '${career.season}_${career.roundIndex}_renew_$playerId',
      season: career.season,
      round: career.currentRound,
      kind: FinanceKind.contractRenewal,
      description: 'Renovação de ${player.displayName}',
      amount: -negotiation.signingCost,
      createdAt: DateTime.now(),
    );
    final next = career.copyWith(
      clubs: career.clubs
          .map((item) => item.id == club.id ? updatedClub : item)
          .toList(),
      finances: [...career.finances, transaction],
    );
    await _game.commitCareer(next);
    return TransferOperationResult(
      accepted: true,
      message:
          '${negotiation.message} Luvas: ${formatMoney(negotiation.signingCost)}.',
    );
  }

  PlayerSalePreview previewSale(String playerId) {
    final career = ref.read(gameControllerProvider).career;
    if (career == null) {
      return const PlayerSalePreview(
        available: false,
        message: 'Nenhuma carreira ativa.',
      );
    }

    if (!TransferWindowEngine.isOpen(career.currentDate)) {
      return PlayerSalePreview(
        available: false,
        message: 'A janela de transferências está fechada. Períodos: ${TransferWindowEngine.rulesLabel}.',
      );
    }

    final userClub = career.userClub;
    if (userClub.squad.length <= TransferEngine.minimumSquadSize) {
      return PlayerSalePreview(
        available: false,
        message: 'Mantenha pelo menos ${TransferEngine.minimumSquadSize} jogadores no elenco.',
      );
    }

    final matches = userClub.squad.where((item) => item.id == playerId);
    if (matches.isEmpty) {
      return const PlayerSalePreview(
        available: false,
        message: 'Jogador não encontrado no elenco.',
      );
    }
    final player = matches.first;

    final candidates = <PlayerSaleOffer>[];
    for (final buyer in career.clubs.where((club) => club.id != userClub.id)) {
      if (buyer.squad.length >= TransferEngine.maximumSquadSize) continue;
      final fee = TransferEngine.saleOfferFee(player: player, buyer: buyer);
      if (buyer.money < fee || buyer.transferBudget < fee) continue;
      candidates.add(
        PlayerSaleOffer(
          playerId: player.id,
          buyerClubId: buyer.id,
          buyerClubName: buyer.name,
          fee: fee,
        ),
      );
    }
    candidates.sort((a, b) => b.fee.compareTo(a.fee));

    if (candidates.isEmpty) {
      return const PlayerSalePreview(
        available: false,
        message: 'Nenhum clube consegue fazer uma proposta viável agora.',
      );
    }

    final offer = candidates.first;
    return PlayerSalePreview(
      available: true,
      offer: offer,
      message:
          '${offer.buyerClubName} oferece ${formatMoney(offer.fee)} pelo jogador.',
    );
  }

  PlayerSalePreview previewIncomingOffer(String eventId) {
    final career = ref.read(gameControllerProvider).career;
    if (career == null) {
      return const PlayerSalePreview(
        available: false,
        message: 'Nenhuma carreira ativa.',
      );
    }
    final events = career.news.where((event) => event.id == eventId);
    if (events.isEmpty) {
      return const PlayerSalePreview(
        available: false,
        message: 'A proposta não foi encontrada.',
      );
    }
    final event = events.first;
    if (!CpuUserOfferEngine.isOfferActive(state: career, event: event)) {
      return const PlayerSalePreview(
        available: false,
        message: 'Esta proposta expirou ou não está mais disponível.',
      );
    }

    final player = career.userClub.squad
        .where((item) => item.id == event.playerId)
        .firstOrNull;
    final buyer = career.clubs
        .where((club) => club.id == event.clubId)
        .firstOrNull;
    if (player == null || buyer == null || event.amount == null) {
      return const PlayerSalePreview(
        available: false,
        message: 'Os dados da proposta não estão mais disponíveis.',
      );
    }

    final offer = PlayerSaleOffer(
      playerId: player.id,
      buyerClubId: buyer.id,
      buyerClubName: buyer.name,
      fee: event.amount!,
    );
    return PlayerSalePreview(
      available: true,
      offer: offer,
      message: '${buyer.name} oferece ${formatMoney(offer.fee)} por ${player.displayName}.',
    );
  }

  Future<TransferOperationResult> acceptIncomingOffer(String eventId) async {
    final preview = previewIncomingOffer(eventId);
    final offer = preview.offer;
    if (!preview.available || offer == null) {
      return TransferOperationResult(
        accepted: false,
        message: preview.message,
      );
    }
    return _acceptSaleOffer(offer, sourceEventId: eventId);
  }

  Future<TransferOperationResult> rejectIncomingOffer(String eventId) async {
    final career = ref.read(gameControllerProvider).career;
    if (career == null) {
      return const TransferOperationResult(
        accepted: false,
        message: 'Nenhuma carreira ativa.',
      );
    }
    final preview = previewIncomingOffer(eventId);
    final offer = preview.offer;
    if (!preview.available || offer == null) {
      return TransferOperationResult(
        accepted: false,
        message: preview.message,
      );
    }
    final player = career.userClub.squad
        .where((item) => item.id == offer.playerId)
        .firstOrNull;
    if (player == null) {
      return const TransferOperationResult(
        accepted: false,
        message: 'O jogador não está mais no elenco.',
      );
    }
    final next = career.copyWith(
      news: _resolveOfferEvent(
        career.news,
        eventId: eventId,
        title: 'Proposta recusada',
        message:
            'A proposta de ${offer.buyerClubName} por ${player.displayName} foi recusada.',
      ),
    );
    await _game.commitCareer(next);
    return const TransferOperationResult(
      accepted: true,
      message: 'Proposta recusada.',
    );
  }

  Future<TransferOperationResult> counterIncomingOffer({
    required String eventId,
    required int fee,
  }) async {
    final career = ref.read(gameControllerProvider).career;
    if (career == null) {
      return const TransferOperationResult(
        accepted: false,
        message: 'Nenhuma carreira ativa.',
      );
    }
    final preview = previewIncomingOffer(eventId);
    final offer = preview.offer;
    if (!preview.available || offer == null) {
      return TransferOperationResult(
        accepted: false,
        message: preview.message,
      );
    }
    if (fee <= offer.fee) {
      return const TransferOperationResult(
        accepted: false,
        message: 'A contraproposta deve ser maior que a oferta atual.',
      );
    }
    final sourceEvent = career.news
        .where((event) => event.id == eventId)
        .firstOrNull;

    final player = career.userClub.squad
        .where((item) => item.id == offer.playerId)
        .firstOrNull;
    final buyer = career.clubs
        .where((club) => club.id == offer.buyerClubId)
        .firstOrNull;
    if (player == null || buyer == null) {
      return const TransferOperationResult(
        accepted: false,
        message: 'A negociação não está mais disponível.',
      );
    }
    if (sourceEvent != null &&
        CpuUserOfferEngine.isFinalCounterOffer(sourceEvent)) {
      final next = career.copyWith(
        news: _resolveOfferEvent(
          career.news,
          eventId: eventId,
          title: 'Negociação encerrada',
          message:
              '${buyer.name} manteve o limite de ${formatMoney(offer.fee)} por ${player.displayName}.',
        ),
      );
      await _game.commitCareer(next);
      return const TransferOperationResult(
        accepted: false,
        message: 'O clube manteve sua proposta final e encerrou a negociação.',
      );
    }

    final decision = CpuUserOfferEngine.evaluateCounter(
      buyer: buyer,
      player: player,
      currentFee: offer.fee,
      proposedFee: fee,
    );
    if (decision.accepted) {
      return _acceptSaleOffer(
        PlayerSaleOffer(
          playerId: player.id,
          buyerClubId: buyer.id,
          buyerClubName: buyer.name,
          fee: fee,
        ),
        sourceEventId: eventId,
      );
    }

    final counter = decision.counterOffer;
    if (counter != null) {
      final updated = career.news.map((event) {
        if (event.id != eventId) return event;
        return CareerEvent(
          id: event.id,
          date: event.date,
          type: CareerEventType.transferOffer,
          title: CpuUserOfferEngine.finalCounterOfferTitle,
          message:
              '${buyer.name} chegou ao limite de ${formatMoney(counter)} por ${player.displayName}.',
          playerId: player.id,
          clubId: buyer.id,
          amount: counter,
        );
      }).toList(growable: false);
      await _game.commitCareer(career.copyWith(news: updated));
      return TransferOperationResult(
        accepted: false,
        message: decision.message,
        counterOffer: counter,
      );
    }

    final next = career.copyWith(
      news: _resolveOfferEvent(
        career.news,
        eventId: eventId,
        title: 'Negociação encerrada',
        message:
            '${buyer.name} recusou a contraproposta por ${player.displayName}.',
      ),
    );
    await _game.commitCareer(next);
    return TransferOperationResult(
      accepted: false,
      message: decision.message,
    );
  }

  Future<TransferOperationResult> acceptSaleOffer(PlayerSaleOffer offer) =>
      _acceptSaleOffer(offer);

  Future<TransferOperationResult> _acceptSaleOffer(
    PlayerSaleOffer offer, {
    String? sourceEventId,
  }) async {
    final career = ref.read(gameControllerProvider).career;
    if (career == null) {
      return const TransferOperationResult(
        accepted: false,
        message: 'Nenhuma carreira ativa.',
      );
    }

    if (!TransferWindowEngine.isOpen(career.currentDate)) {
      return TransferOperationResult(
        accepted: false,
        message: 'A janela de transferências está fechada. Períodos: ${TransferWindowEngine.rulesLabel}.',
      );
    }

    final userClub = career.userClub;
    if (userClub.squad.length <= TransferEngine.minimumSquadSize) {
      return TransferOperationResult(
        accepted: false,
        message: 'Mantenha pelo menos ${TransferEngine.minimumSquadSize} jogadores no elenco.',
      );
    }
    final players = userClub.squad.where((item) => item.id == offer.playerId);
    if (players.isEmpty) {
      return const TransferOperationResult(
        accepted: false,
        message: 'O jogador não está mais disponível para venda.',
      );
    }
    final buyers = career.clubs.where((club) => club.id == offer.buyerClubId);
    if (buyers.isEmpty) {
      return const TransferOperationResult(
        accepted: false,
        message: 'O clube comprador não está mais disponível.',
      );
    }

    final player = players.first;
    final buyer = buyers.first;
    if (buyer.squad.length >= TransferEngine.maximumSquadSize ||
        buyer.money < offer.fee ||
        buyer.transferBudget < offer.fee) {
      return const TransferOperationResult(
        accepted: false,
        message: 'A proposta expirou porque a situação do comprador mudou.',
      );
    }

    final execution = TransferEngine.execute(
      player: player,
      buyer: buyer,
      seller: userClub,
      fee: offer.fee,
      salary: CpuRecruitmentEngine.salaryOffer(player, buyer),
      years: CpuRecruitmentEngine.contractYears(player),
      season: career.season,
      requireSellerMinimum: false,
    );
    if (!execution.decision.accepted) {
      return TransferOperationResult(
        accepted: false,
        message: execution.decision.reason,
      );
    }

    final clubs = career.clubs.map((club) {
      if (club.id == buyer.id) return execution.buyer;
      if (club.id == userClub.id) return execution.seller!;
      return club;
    }).toList();
    final updatedUser = clubs.firstWhere((club) => club.id == userClub.id);
    final starters = career.starterIds.contains(player.id)
        ? LineupEngine.autoSelect(updatedUser.squad, career.formation)
        : career.starterIds;
    final transaction = FinanceTransaction(
      id: '${career.season}_${career.roundIndex}_sale_${player.id}',
      season: career.season,
      round: career.currentRound,
      kind: FinanceKind.playerSale,
      description: 'Venda de ${player.displayName} para ${buyer.name}',
      amount: offer.fee,
      createdAt: DateTime.now(),
    );
    final next = career.copyWith(
      clubs: clubs,
      starterIds: starters,
      finances: [...career.finances, transaction],
      news: sourceEventId == null
          ? career.news
          : _resolveOfferEvent(
              career.news,
              eventId: sourceEventId,
              title: 'Transferência concluída',
              message:
                  '${player.displayName} foi vendido para ${buyer.name} por ${formatMoney(offer.fee)}.',
            ),
    );
    await _game.commitCareer(next);
    return TransferOperationResult(
      accepted: true,
      message:
          'Venda concluída: ${player.displayName} → ${buyer.name} por ${formatMoney(offer.fee)}.',
    );
  }

  static List<CareerEvent> _resolveOfferEvent(
    List<CareerEvent> news, {
    required String eventId,
    required String title,
    required String message,
  }) =>
      news.map((event) {
        if (event.id != eventId) return event;
        return CareerEvent(
          id: event.id,
          date: event.date,
          type: CareerEventType.info,
          title: title,
          message: message,
          playerId: event.playerId,
          clubId: event.clubId,
          fixtureId: event.fixtureId,
          negotiationId: event.negotiationId,
          amount: event.amount,
        );
      }).toList(growable: false);
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
