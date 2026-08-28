import 'dart:math';

import '../../domain/club/club.dart';
import '../../domain/contract/contract.dart';
import '../../domain/player/player.dart';
import '../../domain/transfer/transfer.dart';

class TransferExecution {
  const TransferExecution({
    required this.decision,
    required this.buyer,
    required this.seller,
    required this.player,
  });
  final TransferDecision decision;
  final Club buyer;
  final Club? seller;
  final Player player;
}

abstract final class TransferEngine {
  static const int minimumSquadSize = 20;
  static const int maximumSquadSize = 30;

  static int minimumFee({
    required Player player,
    required Club buyer,
    Club? seller,
  }) {
    if (seller == null) return 0;
    final sellerPremium =
        .06 + max(0, seller.reputation - buyer.reputation) * .006;
    return (player.marketValue * (1 + sellerPremium)).round();
  }

  /// Oferta que um clube controlado pela CPU está disposto a fazer ao usuário.
  /// O valor é deliberadamente separado do [minimumFee], pois nesse fluxo quem
  /// decide aceitar a proposta do comprador é o próprio jogador/manager.
  static int saleOfferFee({
    required Player player,
    required Club buyer,
  }) {
    final reputationFactor =
        ((buyer.reputation - 70) * .003).clamp(-.06, .08).toDouble();
    final ageFactor = player.age <= 24
        ? .04
        : player.age >= 32
            ? -.08
            : 0.0;
    final qualityFactor = player.overall >= 80 ? .04 : 0.0;
    final multiplier = (1.0 + reputationFactor + ageFactor + qualityFactor)
        .clamp(.82, 1.16)
        .toDouble();
    return max(1, (player.marketValue * multiplier).round());
  }

  static TransferDecision evaluate({
    required Player player,
    required Club buyer,
    Club? seller,
    required int fee,
    required int salary,
    required int years,
    bool requireSellerMinimum = true,
    int? upfrontFee,
  }) {
    if (buyer.squad.length >= maximumSquadSize) {
      return TransferDecision(
        false,
        'O elenco já chegou ao limite de $maximumSquadSize jogadores.',
      );
    }
    final cashNow = upfrontFee ?? fee;
    if (fee < 0 || cashNow < 0 || cashNow > fee || salary <= 0 || years < 1 || years > 5) {
      return const TransferDecision(false, 'Proposta inválida.');
    }
    if (buyer.money < cashNow || buyer.transferBudget < fee) {
      return const TransferDecision(
        false,
        'Orçamento insuficiente para a operação.',
      );
    }
    if (seller != null && seller.squad.length <= minimumSquadSize) {
      return TransferDecision(
        false,
        'O clube vendedor não quer reduzir o elenco abaixo de $minimumSquadSize jogadores.',
      );
    }

    if (requireSellerMinimum) {
      final minFee = minimumFee(player: player, buyer: buyer, seller: seller);
      if (fee < minFee) {
        return TransferDecision(
          false,
          'O clube pede uma contraproposta.',
          counterOffer: minFee,
        );
      }
    }

    final expectedSalary = max(
      player.salary,
      (player.salary * (1 + max(0, buyer.reputation - 70) * .002)).round(),
    );
    if (salary < (expectedSalary * .90).round()) {
      return const TransferDecision(
        false,
        'O jogador rejeitou o salário oferecido.',
      );
    }
    return const TransferDecision(true, 'Proposta aceita.');
  }

  static TransferExecution execute({
    required Player player,
    required Club buyer,
    Club? seller,
    required int fee,
    required int salary,
    required int years,
    required int season,
    bool requireSellerMinimum = true,
    int? upfrontFee,
  }) {
    final cashNow = upfrontFee ?? fee;
    final decision = evaluate(
      player: player,
      buyer: buyer,
      seller: seller,
      fee: fee,
      salary: salary,
      years: years,
      requireSellerMinimum: requireSellerMinimum,
      upfrontFee: cashNow,
    );
    if (!decision.accepted) {
      return TransferExecution(
        decision: decision,
        buyer: buyer,
        seller: seller,
        player: player,
      );
    }

    final moved = player.copyWith(
      clubId: buyer.id,
      listed: false,
      contract: PlayerContract(salary: salary, endSeason: season + years),
      morale: min(100, player.morale + 7),
    );
    final buyerSquad = [...buyer.squad.where((p) => p.id != player.id), moved];
    final updatedBuyer = buyer.copyWith(
      squad: buyerSquad,
      money: buyer.money - cashNow,
      transferBudget: max(0, buyer.transferBudget - fee),
    );
    Club? updatedSeller;
    if (seller != null) {
      updatedSeller = seller.copyWith(
        squad: seller.squad.where((p) => p.id != player.id).toList(),
        money: seller.money + cashNow,
        transferBudget: seller.transferBudget + cashNow,
      );
    }
    return TransferExecution(
      decision: decision,
      buyer: updatedBuyer,
      seller: updatedSeller,
      player: moved,
    );
  }
}
