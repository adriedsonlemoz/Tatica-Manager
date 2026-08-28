import 'dart:math';

import '../../domain/club/club.dart';
import '../../domain/player/player.dart';
import '../contract/contract_engine.dart';
import 'cpu_financial_engine.dart';
import 'cpu_selling_engine.dart';
import 'cpu_squad_needs_engine.dart';

class CpuRecruitmentTarget {
  const CpuRecruitmentTarget({
    required this.player,
    required this.fee,
    required this.salary,
    required this.years,
    this.seller,
  });

  final Player player;
  final Club? seller;
  final int fee;
  final int salary;
  final int years;
}

abstract final class CpuRecruitmentEngine {
  static CpuRecruitmentTarget? chooseFreeAgent({
    required Club buyer,
    required CpuSquadNeed need,
    required List<Player> freeAgents,
    Set<String> excludedPlayerIds = const {},
    int? randomSeed,
  }) {
    final targets = _freeAgentTargets(
      buyer: buyer,
      need: need,
      freeAgents: freeAgents,
      excludedPlayerIds: excludedPlayerIds,
    );
    if (targets.isEmpty) return null;
    return _pickFromTop(targets, randomSeed);
  }

  static CpuRecruitmentTarget? chooseTransfer({
    required Club buyer,
    required CpuSquadNeed need,
    required List<Club> clubs,
    required String userClubId,
    required int season,
    Set<String> excludedPlayerIds = const {},
    int? randomSeed,
  }) {
    final targets = _transferTargets(
      buyer: buyer,
      need: need,
      clubs: clubs,
      userClubId: userClubId,
      season: season,
      excludedPlayerIds: excludedPlayerIds,
    );
    if (targets.isEmpty) return null;
    return _pickFromTop(targets, randomSeed);
  }

  /// Cria uma pequena lista de alvos para a prioridade atual do clube.
  ///
  /// A lista permite que a CPU tente uma alternativa quando o alvo principal é
  /// contratado por outro clube ou deixa de ser financeiramente viável antes da
  /// execução, sem inventar uma segunda lógica de transferências.
  static List<CpuRecruitmentTarget> shortlist({
    required Club buyer,
    required CpuSquadNeed need,
    required List<Player> freeAgents,
    required List<Club> clubs,
    required String userClubId,
    required int season,
    bool preferFreeAgents = false,
    bool ambitious = false,
    Set<String> excludedPlayerIds = const {},
    int? randomSeed,
    int limit = 3,
  }) {
    final freeTargets = _freeAgentTargets(
      buyer: buyer,
      need: need,
      freeAgents: freeAgents,
      excludedPlayerIds: excludedPlayerIds,
    );
    final transferTargets = _transferTargets(
      buyer: buyer,
      need: need,
      clubs: clubs,
      userClubId: userClubId,
      season: season,
      excludedPlayerIds: excludedPlayerIds,
    );
    final combined = [...freeTargets, ...transferTargets];
    if (combined.isEmpty) return const [];

    combined.sort((a, b) {
      final byScore = _strategyScore(
        b,
        need,
        buyer,
        preferFreeAgents: preferFreeAgents,
        ambitious: ambitious,
        randomSeed: randomSeed,
      ).compareTo(
        _strategyScore(
          a,
          need,
          buyer,
          preferFreeAgents: preferFreeAgents,
          ambitious: ambitious,
          randomSeed: randomSeed,
        ),
      );
      if (byScore != 0) return byScore;
      final byFee = a.fee.compareTo(b.fee);
      if (byFee != 0) return byFee;
      return a.player.id.compareTo(b.player.id);
    });
    final effectiveLimit = limit < 1 ? 1 : limit;
    return combined.take(effectiveLimit).toList(growable: false);
  }

  static List<CpuRecruitmentTarget> _freeAgentTargets({
    required Club buyer,
    required CpuSquadNeed need,
    required List<Player> freeAgents,
    required Set<String> excludedPlayerIds,
  }) {
    final candidates = freeAgents.where((player) {
      if (excludedPlayerIds.contains(player.id) || !need.matches(player)) {
        return false;
      }
      final salary = salaryOffer(player, buyer);
      return isUsefulUpgrade(player, need) &&
          CpuFinancialEngine.canAfford(
            buyer: buyer,
            need: need,
            player: player,
            fee: 0,
            salary: salary,
          );
    }).toList();

    candidates.sort(
      (a, b) => candidateScore(b, need).compareTo(candidateScore(a, need)),
    );
    return candidates
        .map(
          (player) => CpuRecruitmentTarget(
            player: player,
            fee: 0,
            salary: salaryOffer(player, buyer),
            years: contractYears(player),
          ),
        )
        .toList(growable: false);
  }

  static List<CpuRecruitmentTarget> _transferTargets({
    required Club buyer,
    required CpuSquadNeed need,
    required List<Club> clubs,
    required String userClubId,
    required int season,
    required Set<String> excludedPlayerIds,
  }) {
    final options = <CpuRecruitmentTarget>[];
    for (final seller in clubs) {
      if (seller.id == buyer.id || seller.id == userClubId) continue;
      for (final player in seller.squad) {
        if (excludedPlayerIds.contains(player.id) || !need.matches(player)) {
          continue;
        }
        final sale = CpuSellingEngine.assess(
          club: seller,
          player: player,
          season: season,
        );
        if (!sale.sellable || !isUsefulUpgrade(player, need)) continue;

        final fee = CpuSellingEngine.askingFee(
          seller: seller,
          buyer: buyer,
          player: player,
          season: season,
        );
        final salary = salaryOffer(player, buyer);
        if (!CpuFinancialEngine.canAfford(
          buyer: buyer,
          need: need,
          player: player,
          fee: fee,
          salary: salary,
        )) {
          continue;
        }
        options.add(
          CpuRecruitmentTarget(
            player: player,
            seller: seller,
            fee: fee,
            salary: salary,
            years: contractYears(player),
          ),
        );
      }
    }

    options.sort((a, b) {
      final byScore =
          _targetScore(b, need, buyer).compareTo(_targetScore(a, need, buyer));
      if (byScore != 0) return byScore;
      final byFee = a.fee.compareTo(b.fee);
      if (byFee != 0) return byFee;
      return a.player.id.compareTo(b.player.id);
    });
    return options;
  }

  static bool isUsefulUpgrade(Player player, CpuSquadNeed need) {
    final shortage = need.currentDepth < need.minimumDepth;
    if (shortage) return player.overall >= need.targetOverall - 8;
    if (player.overall >= max(need.targetOverall - 4, need.bestOverall + 2)) {
      return true;
    }
    return player.age <= 23 &&
        player.overall >= need.targetOverall - 7 &&
        player.potential >= need.bestOverall + 6;
  }

  static int candidateScore(Player player, CpuSquadNeed need) {
    final primaryBonus = player.primaryPosition == need.position ? 180 : 90;
    final potentialBonus = max(0, player.potential - player.overall) * 5;
    final ageBonus = player.age <= 23
        ? 35
        : player.age >= 32
            ? -25
            : 0;
    return player.overall * 20 + primaryBonus + potentialBonus + ageBonus;
  }

  static int _targetScore(
    CpuRecruitmentTarget target,
    CpuSquadNeed need,
    Club buyer,
  ) =>
      candidateScore(target.player, need) +
      CpuFinancialEngine.affordabilityScore(
        buyer: buyer,
        need: need,
        fee: target.fee,
      );

  static int _strategyScore(
    CpuRecruitmentTarget target,
    CpuSquadNeed need,
    Club buyer, {
    required bool preferFreeAgents,
    required bool ambitious,
    required int? randomSeed,
  }) {
    var score = _targetScore(target, need, buyer);
    if (target.seller == null) {
      score += preferFreeAgents
          ? 320
          : ambitious
              ? 10
              : 160;
    }
    if (ambitious) {
      score += max(0, target.player.overall - need.targetOverall) * 16;
      score += max(0, target.player.potential - target.player.overall) * 3;
    }
    if (randomSeed != null) {
      score += Random(randomSeed ^ _stableSeed(target.player.id)).nextInt(41);
    }
    return score;
  }

  static T _pickFromTop<T>(List<T> sorted, int? randomSeed) {
    if (sorted.length == 1 || randomSeed == null) return sorted.first;
    final poolSize = min(3, sorted.length);
    final roll = Random(randomSeed).nextDouble();
    final index = roll < .62
        ? 0
        : roll < .88
            ? min(1, poolSize - 1)
            : min(2, poolSize - 1);
    return sorted[index];
  }

  static int _stableSeed(String value) {
    var hash = 17;
    for (final codeUnit in value.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x7fffffff;
    }
    return hash;
  }

  static int salaryOffer(Player player, Club buyer) {
    final expected = ContractEngine.expectedSalary(player);
    final reputationPremium = max(0, buyer.reputation - 75) * .002;
    return max(
      player.salary,
      (expected * (1.02 + reputationPremium)).round(),
    );
  }

  static int contractYears(Player player) {
    if (player.age <= 24) return 4;
    if (player.age >= 32) return 2;
    return 3;
  }
}
