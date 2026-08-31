import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/formatters.dart';
import '../../domain/finance/finance.dart';
import '../../domain/season/career_event.dart';
import '../../domain/season/career_state.dart';
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

  Future<TransferOperationResult> startRenewalNegotiation({
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
    try {
      final negotiation = MarketCareerEngine.createRenewalNegotiation(
        state: career,
        playerId: playerId,
        salary: salary,
        years: years,
      );
      await _game.commitCareer(
        career.copyWith(
          transferNegotiations: [...career.transferNegotiations, negotiation],
        ),
        message: 'Proposta de renovação enviada. A resposta chegará ao avançar o dia.',
      );
      return const TransferOperationResult(
        accepted: true,
        message: 'Proposta de renovação enviada.',
      );
    } on StateError catch (error) {
      return TransferOperationResult(
        accepted: false,
        message: error.message.toString(),
      );
    }
  }

  Future<TransferOperationResult> acceptReceivedNegotiation(
    String negotiationId,
  ) async {
    final career = ref.read(gameControllerProvider).career;
    if (career == null) {
      return const TransferOperationResult(
        accepted: false,
        message: 'Nenhuma carreira ativa.',
      );
    }
    try {
      await _game.commitCareer(
        MarketCareerEngine.acceptReceivedNegotiation(career, negotiationId),
        message: 'Bases aceitas. Confirme a conclusão na Central de Negociações.',
      );
      return const TransferOperationResult(
        accepted: true,
        message: 'Bases aceitas. Falta concluir a negociação.',
      );
    } on StateError catch (error) {
      return TransferOperationResult(
        accepted: false,
        message: error.message.toString(),
      );
    }
  }

  Future<TransferOperationResult> rejectReceivedNegotiation(
    String negotiationId,
  ) async {
    final career = ref.read(gameControllerProvider).career;
    if (career == null) {
      return const TransferOperationResult(
        accepted: false,
        message: 'Nenhuma carreira ativa.',
      );
    }
    try {
      await _game.commitCareer(
        MarketCareerEngine.rejectReceivedNegotiation(career, negotiationId),
        message: 'Proposta recusada.',
      );
      return const TransferOperationResult(
        accepted: true,
        message: 'Proposta recusada.',
      );
    } on StateError catch (error) {
      return TransferOperationResult(
        accepted: false,
        message: error.message.toString(),
      );
    }
  }

  Future<TransferOperationResult> setPlayerForSale({
    required String playerId,
    required bool listed,
  }) async {
    final career = ref.read(gameControllerProvider).career;
    if (career == null) {
      return const TransferOperationResult(
        accepted: false,
        message: 'Nenhuma carreira ativa.',
      );
    }
    final player = career.userClub.squad
        .where((item) => item.id == playerId)
        .firstOrNull;
    if (player == null) {
      return const TransferOperationResult(
        accepted: false,
        message: 'Jogador não encontrado no elenco.',
      );
    }
    if (player.loan != null) {
      return const TransferOperationResult(
        accepted: false,
        message: 'Um jogador emprestado não pode ser colocado à venda.',
      );
    }
    final updatedClub = career.userClub.copyWith(
      squad: career.userClub.squad
          .map(
            (item) => item.id == playerId
                ? item.copyWith(
                    listed: listed,
                    availableForLoan: listed ? false : item.availableForLoan,
                  )
                : item,
          )
          .toList(growable: false),
    );
    await _game.commitCareer(
      career.copyWith(
        clubs: career.clubs
            .map((club) => club.id == updatedClub.id ? updatedClub : club)
            .toList(growable: false),
      ),
      message: listed
          ? '${player.displayName} foi colocado à venda.'
          : '${player.displayName} saiu da lista de transferências.',
    );
    return TransferOperationResult(
      accepted: true,
      message: listed
          ? 'Jogador colocado à venda.'
          : 'Jogador removido da lista de transferências.',
    );
  }

  Future<TransferOperationResult> setPlayerAvailableForLoan({
    required String playerId,
    required bool available,
  }) async {
    final career = ref.read(gameControllerProvider).career;
    if (career == null) {
      return const TransferOperationResult(
        accepted: false,
        message: 'Nenhuma carreira ativa.',
      );
    }
    final player = career.userClub.squad
        .where((item) => item.id == playerId)
        .firstOrNull;
    if (player == null) {
      return const TransferOperationResult(
        accepted: false,
        message: 'Jogador não encontrado no elenco.',
      );
    }
    if (player.loan != null) {
      return const TransferOperationResult(
        accepted: false,
        message: 'Um jogador emprestado não pode receber nova proposta.',
      );
    }
    final updatedClub = career.userClub.copyWith(
      squad: career.userClub.squad
          .map(
            (item) => item.id == playerId
                ? item.copyWith(
                    availableForLoan: available,
                    listed: available ? false : item.listed,
                  )
                : item,
          )
          .toList(growable: false),
    );
    await _game.commitCareer(
      career.copyWith(
        clubs: career.clubs
            .map((club) => club.id == updatedClub.id ? updatedClub : club)
            .toList(growable: false),
      ),
      message: available
          ? '${player.displayName} foi disponibilizado para empréstimo.'
          : '${player.displayName} saiu da lista de empréstimos.',
    );
    return TransferOperationResult(
      accepted: true,
      message: available
          ? 'Jogador disponibilizado para empréstimo.'
          : 'Jogador removido da lista de empréstimos.',
    );
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
    if (negotiation.kind == TransferNegotiationKind.permanentTransfer) {
      return _completePermanentNegotiation(career, negotiation);
    }
    if (negotiation.kind == TransferNegotiationKind.contractRenewal) {
      return _completeRenewalNegotiation(career, negotiation);
    }
    return _completeLoanNegotiation(career, negotiation);
  }

  Future<TransferOperationResult> buyPlayer({
    required String playerId,
    required int fee,
    required int salary,
    required int years,
    int? upfrontFee,
  }) =>
      startMarketNegotiation(
        playerId: playerId,
        fee: fee,
        salary: salary,
        years: years,
        signingBonus: 0,
        installments: upfrontFee != null && upfrontFee < fee ? 2 : 1,
      );

  Future<TransferOperationResult> renewPlayer({
    required String playerId,
    required int salary,
    required int years,
  }) => startRenewalNegotiation(
        playerId: playerId,
        salary: salary,
        years: years,
      );

  Future<TransferOperationResult> _completePermanentNegotiation(
    CareerState career,
    TransferNegotiation negotiation,
  ) async {
    if (!TransferWindowEngine.isOpen(career.currentDate)) {
      return TransferOperationResult(
        accepted: false,
        message: 'A janela de transferências está fechada. Períodos: ${TransferWindowEngine.rulesLabel}.',
      );
    }
    final buyer = career.clubs
        .where((club) => club.id == negotiation.toClubId)
        .firstOrNull;
    final seller = negotiation.fromClubId == null
        ? null
        : career.clubs
            .where((club) => club.id == negotiation.fromClubId)
            .firstOrNull;
    final player = seller == null
        ? career.freeAgents
            .where((item) => item.id == negotiation.playerId)
            .firstOrNull
        : seller.squad
            .where((item) => item.id == negotiation.playerId)
            .firstOrNull;
    if (buyer == null || player == null ||
        (negotiation.fromClubId != null && seller == null)) {
      return _finalizationUnavailable(career, negotiation);
    }
    final upfront = MarketCareerEngine.upfrontAmount(
      negotiation.fee,
      negotiation.installments,
    );
    final userIsBuyer = buyer.id == career.userClubId;
    final signingCash = userIsBuyer ? negotiation.signingBonus : 0;
    if (userIsBuyer && buyer.money < upfront + signingCash) {
      return TransferOperationResult(
        accepted: false,
        message:
            'Caixa insuficiente para entrada e bônus de assinatura (${formatMoney(upfront + signingCash)}).',
      );
    }
    final execution = TransferEngine.execute(
      player: player,
      buyer: buyer,
      seller: seller,
      fee: negotiation.fee,
      salary: negotiation.salary,
      years: negotiation.contractYears,
      season: career.season,
      requireSellerMinimum: seller?.id != career.userClubId,
      upfrontFee: upfront,
    );
    if (!execution.decision.accepted) {
      final counter = execution.decision.counterOffer;
      final updated = negotiation.copyWith(
        status: counter == null
            ? TransferNegotiationStatus.rejected
            : TransferNegotiationStatus.countered,
        counterFee: counter,
        clearCounterFee: counter == null,
        message: execution.decision.reason,
      );
      await _game.commitCareer(
        _replaceNegotiation(career, updated),
        message: execution.decision.reason,
      );
      return TransferOperationResult(
        accepted: false,
        message: execution.decision.reason,
        counterOffer: counter,
      );
    }

    var clubs = career.clubs.map((club) {
      if (club.id == buyer.id) return execution.buyer;
      if (seller != null && club.id == seller.id) return execution.seller!;
      return club;
    }).toList(growable: false);
    final finances = [...career.finances];
    if (userIsBuyer && negotiation.signingBonus > 0) {
      final signedBuyer = execution.buyer.copyWith(
        money: execution.buyer.money - negotiation.signingBonus,
      );
      clubs = clubs
          .map((club) => club.id == buyer.id ? signedBuyer : club)
          .toList(growable: false);
      finances.add(
        FinanceTransaction(
          id: '${negotiation.id}-signing',
          season: career.season,
          round: career.currentRound,
          kind: FinanceKind.signingBonus,
          description: 'Bônus de assinatura de ${player.displayName}',
          amount: -negotiation.signingBonus,
          createdAt: career.currentDate,
        ),
      );
    }
    if (buyer.id == career.userClubId && upfront > 0) {
      finances.add(
        FinanceTransaction(
          id: '${negotiation.id}-purchase',
          season: career.season,
          round: career.currentRound,
          kind: FinanceKind.playerPurchase,
          description: negotiation.installments > 1
              ? 'Entrada da contratação de ${player.displayName}'
              : 'Contratação de ${player.displayName}',
          amount: -upfront,
          createdAt: career.currentDate,
        ),
      );
    } else if (seller?.id == career.userClubId && upfront > 0) {
      finances.add(
        FinanceTransaction(
          id: '${negotiation.id}-sale',
          season: career.season,
          round: career.currentRound,
          kind: FinanceKind.playerSale,
          description: 'Venda de ${player.displayName} para ${buyer.name}',
          amount: upfront,
          createdAt: career.currentDate,
        ),
      );
    }
    var starters = career.starterIds;
    final updatedUserClub =
        clubs.where((club) => club.id == career.userClubId).firstOrNull;
    if (updatedUserClub != null &&
        ((seller?.id == career.userClubId && starters.contains(player.id)) ||
            (buyer.id == career.userClubId && starters.length < 11))) {
      starters = LineupEngine.autoSelect(updatedUserClub.squad, career.formation);
    }
    var next = career.copyWith(
      clubs: clubs,
      freeAgents:
          career.freeAgents.where((item) => item.id != player.id).toList(),
      finances: finances,
      starterIds: starters,
    );
    next = MarketCareerEngine.markCompleted(next, negotiation.id);
    final installments = MarketCareerEngine.buildFutureInstallments(
      negotiation,
      career.currentDate,
    );
    if (installments.isNotEmpty) {
      next = next.copyWith(
        transferInstallments: [...next.transferInstallments, ...installments],
      );
    }
    await _game.commitCareer(
      next,
      message: seller?.id == career.userClubId
          ? 'Venda concluída: ${player.displayName} → ${buyer.name} por ${formatMoney(negotiation.fee)}.'
          : '${player.displayName} foi contratado por ${formatMoney(negotiation.fee)}.',
    );
    return const TransferOperationResult(
      accepted: true,
      message: 'Negociação concluída.',
    );
  }

  Future<TransferOperationResult> _completeRenewalNegotiation(
    CareerState career,
    TransferNegotiation negotiation,
  ) async {
    final club = career.userClub;
    final location = MarketCareerEngine.userContractPlayerLocation(
      career,
      negotiation.playerId,
    );
    if (location == null) return _finalizationUnavailable(career, negotiation);
    final player = location.player;
    final holder = location.holder;
    final result = ContractEngine.negotiate(
      player: player,
      proposal: ContractProposal(
        salary: negotiation.salary,
        years: negotiation.contractYears,
      ),
      season: career.season,
      clubMoney: club.money,
    );
    if (!result.accepted) {
      final counter = result.requiredSalary;
      final updated = negotiation.copyWith(
        status: counter == null
            ? TransferNegotiationStatus.rejected
            : TransferNegotiationStatus.countered,
        counterSalary: counter,
        clearCounterSalary: counter == null,
        message: result.message,
      );
      await _game.commitCareer(
        _replaceNegotiation(career, updated),
        message: result.message,
      );
      return TransferOperationResult(
        accepted: false,
        message: result.message,
        counterOffer: counter,
      );
    }
    final clubs = career.clubs.map((item) {
      var updated = item;
      if (item.id == holder.id) {
        updated = updated.copyWith(
          squad: item.squad
              .map((candidate) =>
                  candidate.id == player.id ? result.player : candidate)
              .toList(growable: false),
        );
      }
      if (item.id == club.id) {
        updated = updated.copyWith(money: updated.money - result.signingCost);
      }
      return updated;
    }).toList(growable: false);
    var next = career.copyWith(
      clubs: clubs,
      finances: [
        ...career.finances,
        FinanceTransaction(
          id: '${negotiation.id}-renewal',
          season: career.season,
          round: career.currentRound,
          kind: FinanceKind.contractRenewal,
          description: 'Renovação de ${player.displayName}',
          amount: -result.signingCost,
          createdAt: career.currentDate,
        ),
      ],
    );
    next = MarketCareerEngine.markCompleted(next, negotiation.id);
    await _game.commitCareer(
      next,
      message: '${result.message} Luvas: ${formatMoney(result.signingCost)}.',
    );
    return const TransferOperationResult(
      accepted: true,
      message: 'Renovação concluída.',
    );
  }

  Future<TransferOperationResult> _completeLoanNegotiation(
    CareerState career,
    TransferNegotiation negotiation,
  ) async {
    if (!TransferWindowEngine.isOpen(career.currentDate)) {
      return TransferOperationResult(
        accepted: false,
        message: 'A janela de transferências está fechada. Períodos: ${TransferWindowEngine.rulesLabel}.',
      );
    }
    try {
      var next = MarketCareerEngine.completeLoan(career, negotiation.id);
      next = MarketCareerEngine.markCompleted(next, negotiation.id);
      await _game.commitCareer(
        next,
        message: 'Empréstimo concluído. A folha salarial foi atualizada pelo elenco atual.',
      );
      return const TransferOperationResult(
        accepted: true,
        message: 'Empréstimo concluído.',
      );
    } on StateError catch (error) {
      return TransferOperationResult(
        accepted: false,
        message: error.message.toString(),
      );
    }
  }

  Future<TransferOperationResult> _finalizationUnavailable(
    CareerState career,
    TransferNegotiation negotiation,
  ) async {
    const message = 'Os dados da negociação não estão mais disponíveis.';
    await _game.commitCareer(
      _replaceNegotiation(
        career,
        negotiation.copyWith(
          status: TransferNegotiationStatus.withdrawn,
          message: message,
        ),
      ),
      message: message,
    );
    return const TransferOperationResult(accepted: false, message: message);
  }

  static CareerState _replaceNegotiation(
    CareerState career,
    TransferNegotiation updated,
  ) =>
      career.copyWith(
        transferNegotiations: career.transferNegotiations
            .map((item) => item.id == updated.id ? updated : item)
            .toList(growable: false),
      );

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
    final career = ref.read(gameControllerProvider).career;
    if (career == null) {
      return const TransferOperationResult(
        accepted: false,
        message: 'Nenhuma carreira ativa.',
      );
    }
    try {
      final staged = _ensureLegacyIncomingNegotiation(career, eventId);
      final next = MarketCareerEngine.acceptReceivedNegotiation(
        staged.$1,
        staged.$2.id,
      ).copyWith(
        news: _resolveOfferEvent(
          staged.$1.news,
          eventId: eventId,
          title: 'Bases aceitas',
          message:
              'A proposta por ${staged.$2.playerId} foi aceita nas bases e aguarda conclusão na Central de Negociações.',
        ),
      );
      await _game.commitCareer(
        next,
        message: 'Bases aceitas. A transferência ainda precisa ser concluída.',
      );
      return const TransferOperationResult(
        accepted: true,
        message: 'Bases aceitas. Falta concluir a negociação.',
      );
    } on StateError catch (error) {
      return TransferOperationResult(
        accepted: false,
        message: error.message.toString(),
      );
    }
  }

  Future<TransferOperationResult> rejectIncomingOffer(String eventId) async {
    final career = ref.read(gameControllerProvider).career;
    if (career == null) {
      return const TransferOperationResult(
        accepted: false,
        message: 'Nenhuma carreira ativa.',
      );
    }
    try {
      final staged = _ensureLegacyIncomingNegotiation(career, eventId);
      final next = MarketCareerEngine.rejectReceivedNegotiation(
        staged.$1,
        staged.$2.id,
      ).copyWith(
        news: _resolveOfferEvent(
          staged.$1.news,
          eventId: eventId,
          title: 'Proposta recusada',
          message: 'A proposta foi recusada pelo clube.',
        ),
      );
      await _game.commitCareer(next, message: 'Proposta recusada.');
      return const TransferOperationResult(
        accepted: true,
        message: 'Proposta recusada.',
      );
    } on StateError catch (error) {
      return TransferOperationResult(
        accepted: false,
        message: error.message.toString(),
      );
    }
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
    try {
      final staged = _ensureLegacyIncomingNegotiation(career, eventId);
      final negotiation = staged.$2;
      if (fee <= negotiation.fee) {
        return const TransferOperationResult(
          accepted: false,
          message: 'A contraproposta deve ser maior que a oferta atual.',
        );
      }
      final revised = MarketCareerEngine.reviseNegotiation(
        state: staged.$1,
        negotiationId: negotiation.id,
        fee: fee,
        salary: negotiation.salary,
        years: negotiation.contractYears,
        signingBonus: 0,
        installments: 1,
      ).copyWith(
        news: _resolveOfferEvent(
          staged.$1.news,
          eventId: eventId,
          title: 'Contraproposta enviada',
          message: 'A contraproposta foi enviada e aguarda resposta do clube.',
        ),
      );
      await _game.commitCareer(
        revised,
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

  Future<TransferOperationResult> acceptSaleOffer(PlayerSaleOffer offer) =>
      startSaleNegotiation(offer);

  Future<TransferOperationResult> startSaleNegotiation(
    PlayerSaleOffer offer,
  ) async {
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

    final player = career.userClub.squad
        .where((item) => item.id == offer.playerId)
        .firstOrNull;
    final buyer = career.clubs
        .where((club) => club.id == offer.buyerClubId)
        .firstOrNull;
    if (player == null || buyer == null || buyer.id == career.userClubId) {
      return const TransferOperationResult(
        accepted: false,
        message: 'Os dados da proposta não estão mais disponíveis.',
      );
    }
    try {
      final negotiation = MarketCareerEngine.createIncomingOffer(
        state: career,
        playerId: player.id,
        buyerClubId: buyer.id,
        fee: offer.fee,
        salary: CpuRecruitmentEngine.salaryOffer(player, buyer),
        years: CpuRecruitmentEngine.contractYears(player),
      );
      await _game.commitCareer(
        career.copyWith(
          transferNegotiations: [...career.transferNegotiations, negotiation],
        ),
        message: 'Proposta de ${buyer.name} incluída na Central de Negociações.',
      );
      return const TransferOperationResult(
        accepted: true,
        message: 'Proposta incluída em Negociações. Ela não foi concluída ainda.',
      );
    } on StateError catch (error) {
      return TransferOperationResult(
        accepted: false,
        message: error.message.toString(),
      );
    }
  }

  static (CareerState, TransferNegotiation) _ensureLegacyIncomingNegotiation(
    CareerState career,
    String eventId,
  ) {
    final event = career.news.where((item) => item.id == eventId).firstOrNull;
    if (event == null) {
      throw StateError('A proposta não foi encontrada.');
    }
    if (event.negotiationId != null) {
      final linked = career.transferNegotiations
          .where((item) => item.id == event.negotiationId)
          .firstOrNull;
      if (linked != null) return (career, linked);
    }
    if (!CpuUserOfferEngine.isOfferActive(state: career, event: event)) {
      throw StateError('Esta proposta expirou ou não está mais disponível.');
    }
    final player = career.userClub.squad
        .where((item) => item.id == event.playerId)
        .firstOrNull;
    final buyer = career.clubs
        .where((club) => club.id == event.clubId)
        .firstOrNull;
    if (player == null || buyer == null || event.amount == null) {
      throw StateError('Os dados da proposta não estão mais disponíveis.');
    }
    final negotiation = MarketCareerEngine.createIncomingOffer(
      state: career,
      playerId: player.id,
      buyerClubId: buyer.id,
      fee: event.amount!,
      salary: CpuRecruitmentEngine.salaryOffer(player, buyer),
      years: CpuRecruitmentEngine.contractYears(player),
    );
    final news = career.news.map((item) {
      if (item.id != event.id) return item;
      return CareerEvent(
        id: item.id,
        date: item.date,
        type: item.type,
        title: item.title,
        message: item.message,
        playerId: item.playerId,
        clubId: item.clubId,
        fixtureId: item.fixtureId,
        negotiationId: negotiation.id,
        amount: item.amount,
      );
    }).toList(growable: false);
    return (
      career.copyWith(
        transferNegotiations: [...career.transferNegotiations, negotiation],
        news: news,
      ),
      negotiation,
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
