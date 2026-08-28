import 'dart:math';

import '../../domain/club/club.dart';
import '../../domain/player/player.dart';
import '../transfer/transfer_engine.dart';
import 'cpu_financial_engine.dart';
import 'cpu_squad_needs_engine.dart';

class CpuSaleAssessment {
  const CpuSaleAssessment({
    required this.sellable,
    required this.score,
    required this.keyPlayer,
    required this.replacementOverall,
    required this.positionDepth,
    required this.minimumDepth,
  });

  final bool sellable;
  final int score;
  final bool keyPlayer;
  final int replacementOverall;
  final int positionDepth;
  final int minimumDepth;
}

/// Decide se um clube CPU aceita colocar um atleta no mercado.
///
/// Não executa transferências. A decisão efetiva continua no TransferEngine.
abstract final class CpuSellingEngine {
  static CpuSaleAssessment assess({
    required Club club,
    required Player player,
    required int season,
  }) {
    final minimumDepth =
        CpuSquadNeedsEngine.minimumDepthFor(player.primaryPosition);
    final primaryPlayers = club.squad
        .where(
          (candidate) => candidate.primaryPosition == player.primaryPosition,
        )
        .toList();
    final replacements = primaryPlayers
        .where((candidate) => candidate.id != player.id)
        .toList()
      ..sort((a, b) => b.overall.compareTo(a.overall));
    final replacementOverall =
        replacements.isEmpty ? 0 : replacements.first.overall;
    final remainingDepth = replacements.length;

    if (club.squad.length <= TransferEngine.minimumSquadSize ||
        remainingDepth < minimumDepth) {
      return CpuSaleAssessment(
        sellable: false,
        score: -500,
        keyPlayer: false,
        replacementOverall: replacementOverall,
        positionDepth: primaryPlayers.length,
        minimumDepth: minimumDepth,
      );
    }

    final squadByOverall = [...club.squad]
      ..sort((a, b) => b.overall.compareTo(a.overall));
    final overallRank = squadByOverall.indexWhere(
      (candidate) => candidate.id == player.id,
    );
    final corePlayer = overallRank >= 0 && overallRank < min(6, squadByOverall.length);
    final noEquivalentReplacement = replacementOverall < player.overall - 3;
    final highClubLevel = player.overall >= club.reputation - 2;
    final protectedProspect = player.age <= 23 &&
        player.potential >= club.reputation + 3 &&
        noEquivalentReplacement;
    final keyPlayer = !player.listed &&
        ((corePlayer && highClubLevel && noEquivalentReplacement) ||
            protectedProspect);

    if (keyPlayer) {
      return CpuSaleAssessment(
        sellable: false,
        score: -180,
        keyPlayer: true,
        replacementOverall: replacementOverall,
        positionDepth: primaryPlayers.length,
        minimumDepth: minimumDepth,
      );
    }

    final averageSalary = club.squad.isEmpty
        ? player.salary
        : (club.payroll / club.squad.length).round();
    final excessDepth = max(0, primaryPlayers.length - minimumDepth);
    final qualityGap = max(0, club.reputation - 8 - player.overall);
    final replacementAdvantage = max(0, replacementOverall - player.overall);
    final expiringNow = player.contract.endSeason <= season;
    final expiringSoon = player.contract.endSeason == season + 1;
    final financialPressure = CpuFinancialEngine.hasFinancialPressure(club);

    var score = 0;
    if (player.listed) score += 80;
    score += excessDepth * 24;
    score += qualityGap * 3;
    score += replacementAdvantage * 6;
    if (averageSalary > 0 && player.salary >= averageSalary * 1.35) score += 22;
    if (expiringNow) {
      score += 30;
    } else if (expiringSoon) {
      score += 14;
    }
    if (player.age >= 32) {
      score += 18;
    } else if (player.age >= 29) {
      score += 8;
    }
    if (player.age <= 23 && player.potential >= player.overall + 6) score -= 28;
    if (financialPressure) {
      score += 28;
      score += min(20, player.marketValue ~/ 4_000_000);
    }
    if (overallRank >= 0 && overallRank < min(10, squadByOverall.length)) {
      score -= 16;
    }

    return CpuSaleAssessment(
      sellable: player.listed || score >= 10,
      score: score,
      keyPlayer: false,
      replacementOverall: replacementOverall,
      positionDepth: primaryPlayers.length,
      minimumDepth: minimumDepth,
    );
  }

  static int askingFee({
    required Club seller,
    required Club buyer,
    required Player player,
    required int season,
  }) {
    final base = TransferEngine.minimumFee(
      player: player,
      buyer: buyer,
      seller: seller,
    );
    final assessment = assess(club: seller, player: player, season: season);
    if (!assessment.sellable) return base;

    var multiplier = assessment.score >= 60
        ? 1.00
        : assessment.score >= 30
            ? 1.05
            : 1.12;
    if (player.overall >= seller.reputation) multiplier += .08;
    if (player.contract.endSeason <= season + 1) multiplier -= .03;
    return max(base, (base * multiplier).round());
  }
}
