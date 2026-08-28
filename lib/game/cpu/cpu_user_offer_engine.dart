import 'dart:math';

import '../../domain/club/club.dart';
import '../../domain/player/player.dart';
import '../../domain/season/career_event.dart';
import '../../domain/season/career_state.dart';
import '../transfer/transfer_engine.dart';
import '../transfer/transfer_window_engine.dart';
import 'cpu_financial_engine.dart';
import 'cpu_market_strategy_engine.dart';
import 'cpu_recruitment_engine.dart';
import 'cpu_squad_needs_engine.dart';

class CpuIncomingOffer {
  const CpuIncomingOffer({
    required this.player,
    required this.buyer,
    required this.need,
    required this.fee,
    required this.salary,
    required this.years,
    required this.maxFee,
    required this.score,
  });

  final Player player;
  final Club buyer;
  final CpuSquadNeed need;
  final int fee;
  final int salary;
  final int years;
  final int maxFee;
  final int score;
}

class CpuOfferCounterDecision {
  const CpuOfferCounterDecision({
    required this.accepted,
    required this.message,
    this.counterOffer,
  });

  final bool accepted;
  final String message;
  final int? counterOffer;
}

/// Planeja propostas de clubes CPU por atletas do clube controlado pelo usuário.
///
/// O engine não executa transferências. Ele usa as mesmas necessidades de elenco,
/// critérios de recrutamento e proteções financeiras já usadas no mercado CPU.
/// Os clubes são tratados apenas pelos objetos presentes na carreira: não existe
/// dependência de país, série, prefixo de ID ou quantidade fixa de participantes.
abstract final class CpuUserOfferEngine {
  static const int offerValidityDays = 5;
  static const int recentOfferCooldownDays = 21;
  static const int dailyOfferChancePercent = 12;
  static const String incomingOfferTitle = 'Proposta recebida';
  static const String finalCounterOfferTitle = 'Contraproposta recebida';

  static CareerEvent? generateForDay(CareerState state) {
    if (!TransferWindowEngine.isOpen(state.currentDate) ||
        state.userClub.squad.length <= TransferEngine.minimumSquadSize ||
        hasActiveOffer(state)) {
      return null;
    }

    final seed = _stableSeed(
      '${state.careerId}|${state.season}|${_dayKey(state.currentDate)}|incoming-offer',
    );
    if (Random(seed).nextInt(100) >= dailyOfferChancePercent) return null;

    final offer = chooseOffer(state: state, randomSeed: seed + 41);
    if (offer == null) return null;
    return CareerEvent(
      id: 'offer-${_dayKey(state.currentDate)}-${offer.player.id}-${offer.buyer.id}',
      date: state.currentDate,
      type: CareerEventType.transferOffer,
      title: incomingOfferTitle,
      message:
          '${offer.buyer.name} enviou uma proposta de ${_money(offer.fee)} por ${offer.player.displayName}.',
      playerId: offer.player.id,
      clubId: offer.buyer.id,
      amount: offer.fee,
    );
  }

  static CpuIncomingOffer? chooseOffer({
    required CareerState state,
    int? randomSeed,
  }) {
    final userClub = state.userClub;
    if (userClub.squad.length <= TransferEngine.minimumSquadSize) return null;

    final recentPlayerIds = state.news.where((event) {
      if (event.type != CareerEventType.transferOffer || event.playerId == null) {
        return false;
      }
      final age = _dateOnly(state.currentDate)
          .difference(_dateOnly(event.date))
          .inDays;
      return age >= 0 && age <= recentOfferCooldownDays;
    }).map((event) => event.playerId!).toSet();

    final options = <CpuIncomingOffer>[];
    for (final buyer in state.clubs) {
      if (buyer.id == state.userClubId ||
          buyer.squad.length >= TransferEngine.maximumSquadSize) {
        continue;
      }

      final strategy = CpuMarketStrategyEngine.build(
        buyer: buyer,
        needs: CpuSquadNeedsEngine.assess(buyer),
        careerId: state.careerId,
        season: state.season,
        round: state.currentRound,
        currentDate: state.currentDate,
      );
      if (strategy == null) continue;

      final need = strategy.need;
      for (final player in userClub.squad) {
        if (recentPlayerIds.contains(player.id) ||
            !need.matches(player) ||
            !CpuRecruitmentEngine.isUsefulUpgrade(player, need)) {
          continue;
        }

        final fee = TransferEngine.saleOfferFee(player: player, buyer: buyer);
        final salary = CpuRecruitmentEngine.salaryOffer(player, buyer);
        if (!CpuFinancialEngine.canAfford(
          buyer: buyer,
          need: need,
          player: player,
          fee: fee,
          salary: salary,
        )) {
          continue;
        }

        final maxFee = maximumOfferFee(
          buyer: buyer,
          need: need,
          player: player,
          salary: salary,
          baseFee: fee,
        );
        if (maxFee < fee) continue;

        final needFit = need.priority * 8;
        final upgradeScore = CpuRecruitmentEngine.candidateScore(player, need);
        final affordability = CpuFinancialEngine.affordabilityScore(
          buyer: buyer,
          need: need,
          fee: fee,
        );
        final jitter = randomSeed == null
            ? 0
            : Random(
                _stableSeed('$randomSeed|${buyer.id}|${player.id}'),
              ).nextInt(91);
        options.add(
          CpuIncomingOffer(
            player: player,
            buyer: buyer,
            need: need,
            fee: fee,
            salary: salary,
            years: CpuRecruitmentEngine.contractYears(player),
            maxFee: maxFee,
            score: needFit + upgradeScore + affordability + jitter,
          ),
        );
      }
    }
    if (options.isEmpty) return null;

    options.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      final byFee = b.fee.compareTo(a.fee);
      if (byFee != 0) return byFee;
      final byBuyer = a.buyer.id.compareTo(b.buyer.id);
      if (byBuyer != 0) return byBuyer;
      return a.player.id.compareTo(b.player.id);
    });

    if (options.length == 1 || randomSeed == null) return options.first;
    final poolSize = min(3, options.length);
    final roll = Random(randomSeed).nextDouble();
    final index = roll < .70
        ? 0
        : roll < .92
            ? min(1, poolSize - 1)
            : min(2, poolSize - 1);
    return options[index];
  }

  static CpuSquadNeed? needForPlayer({
    required Club buyer,
    required Player player,
  }) {
    final matches = CpuSquadNeedsEngine.assess(buyer)
        .where((need) => need.matches(player))
        .toList();
    return matches.isEmpty ? null : matches.first;
  }

  static int maximumOfferFee({
    required Club buyer,
    required CpuSquadNeed need,
    required Player player,
    required int salary,
    required int baseFee,
  }) {
    final shortage = need.currentDepth < need.minimumDepth;
    final multiplier = shortage
        ? 1.28
        : need.priority >= 80
            ? 1.20
            : 1.12;
    final strategicCeiling = (baseFee * multiplier).round();
    final financialCeiling = CpuFinancialEngine.maxTransferFee(
      buyer: buyer,
      need: need,
    );
    var ceiling = min(strategicCeiling, financialCeiling);
    if (ceiling < baseFee) return ceiling;

    while (ceiling > baseFee &&
        !CpuFinancialEngine.canAfford(
          buyer: buyer,
          need: need,
          player: player,
          fee: ceiling,
          salary: salary,
        )) {
      final step = max(1, ((ceiling - baseFee) * .25).round());
      ceiling = max(baseFee, ceiling - step);
    }
    return CpuFinancialEngine.canAfford(
      buyer: buyer,
      need: need,
      player: player,
      fee: ceiling,
      salary: salary,
    )
        ? ceiling
        : baseFee - 1;
  }

  static CpuOfferCounterDecision evaluateCounter({
    required Club buyer,
    required Player player,
    required int currentFee,
    required int proposedFee,
  }) {
    if (proposedFee <= currentFee) {
      return const CpuOfferCounterDecision(
        accepted: true,
        message: 'O clube aceitou o valor proposto.',
      );
    }

    final need = needForPlayer(buyer: buyer, player: player);
    if (need == null || !CpuRecruitmentEngine.isUsefulUpgrade(player, need)) {
      return const CpuOfferCounterDecision(
        accepted: false,
        message: 'O clube desistiu da negociação após reavaliar o elenco.',
      );
    }
    final salary = CpuRecruitmentEngine.salaryOffer(player, buyer);
    final maxFee = maximumOfferFee(
      buyer: buyer,
      need: need,
      player: player,
      salary: salary,
      baseFee: currentFee,
    );
    if (proposedFee <= maxFee &&
        CpuFinancialEngine.canAfford(
          buyer: buyer,
          need: need,
          player: player,
          fee: proposedFee,
          salary: salary,
        )) {
      return const CpuOfferCounterDecision(
        accepted: true,
        message: 'O clube aceitou a contraproposta.',
      );
    }
    if (maxFee > currentFee) {
      return CpuOfferCounterDecision(
        accepted: false,
        counterOffer: maxFee,
        message: 'O clube não chegou ao valor pedido e apresentou seu limite.',
      );
    }
    return const CpuOfferCounterDecision(
      accepted: false,
      message: 'O clube recusou a contraproposta e encerrou a negociação.',
    );
  }

  static bool isFinalCounterOffer(CareerEvent event) =>
      event.type == CareerEventType.transferOffer &&
      event.title == finalCounterOfferTitle;

  static bool hasActiveOffer(CareerState state) => state.news.any(
        (event) => isOfferActive(state: state, event: event),
      );

  static bool isOfferActive({
    required CareerState state,
    required CareerEvent event,
  }) {
    if (event.type != CareerEventType.transferOffer ||
        event.playerId == null ||
        event.clubId == null ||
        event.amount == null ||
        event.amount! <= 0 ||
        state.userClub.squad.length <= TransferEngine.minimumSquadSize ||
        !TransferWindowEngine.isOpen(state.currentDate)) {
      return false;
    }
    final age = _dateOnly(state.currentDate)
        .difference(_dateOnly(event.date))
        .inDays;
    if (age < 0 || age > offerValidityDays) return false;
    final players = state.userClub.squad.where(
      (player) => player.id == event.playerId,
    );
    final buyers = state.clubs.where(
      (club) => club.id == event.clubId && club.id != state.userClubId,
    );
    if (players.isEmpty || buyers.isEmpty) return false;

    final player = players.first;
    final buyer = buyers.first;
    if (buyer.squad.length >= TransferEngine.maximumSquadSize) return false;
    final need = needForPlayer(buyer: buyer, player: player);
    if (need == null || !CpuRecruitmentEngine.isUsefulUpgrade(player, need)) {
      return false;
    }

    final salary = CpuRecruitmentEngine.salaryOffer(player, buyer);
    final baseFee = TransferEngine.saleOfferFee(player: player, buyer: buyer);
    final maxFee = maximumOfferFee(
      buyer: buyer,
      need: need,
      player: player,
      salary: salary,
      baseFee: baseFee,
    );
    return event.amount! <= maxFee &&
        CpuFinancialEngine.canAfford(
          buyer: buyer,
          need: need,
          player: player,
          fee: event.amount!,
          salary: salary,
        );
  }

  static List<CareerEvent> expireInvalidOffers({
    required CareerState state,
    required List<CareerEvent> news,
  }) =>
      news.map((event) {
        if (event.type != CareerEventType.transferOffer ||
            isOfferActive(state: state, event: event)) {
          return event;
        }
        return CareerEvent(
          id: event.id,
          date: event.date,
          type: CareerEventType.info,
          title: 'Proposta expirada',
          message: 'A proposta anterior não está mais disponível.',
          playerId: event.playerId,
          clubId: event.clubId,
          amount: event.amount,
        );
      }).toList(growable: false);

  static int _stableSeed(String value) {
    var hash = 17;
    for (final codeUnit in value.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x7fffffff;
    }
    return hash;
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static String _dayKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static String _money(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return 'R\$ $buffer';
  }
}
