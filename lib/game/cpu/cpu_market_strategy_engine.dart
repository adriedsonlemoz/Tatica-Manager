import 'dart:math';

import '../../domain/club/club.dart';
import '../transfer/transfer_window_engine.dart';
import 'cpu_financial_engine.dart';
import 'cpu_squad_needs_engine.dart';

enum CpuMarketApproach { opportunistic, balanced, ambitious }

class CpuMarketStrategy {
  const CpuMarketStrategy({
    required this.need,
    required this.approach,
    required this.targetSeed,
    required this.competitionScore,
  });

  final CpuSquadNeed need;
  final CpuMarketApproach approach;
  final int targetSeed;
  final int competitionScore;

  bool get preferFreeAgents => approach == CpuMarketApproach.opportunistic;
}

/// Mantém uma prioridade coerente por clube durante a mesma janela de mercado.
///
/// Não persiste estado novo no save: a prioridade é derivada de dados da carreira,
/// temporada, janela e clube. Se o elenco muda e a necessidade desaparece, uma nova
/// prioridade é naturalmente escolhida na avaliação seguinte.
abstract final class CpuMarketStrategyEngine {
  static CpuMarketStrategy? build({
    required Club buyer,
    required List<CpuSquadNeed> needs,
    required String careerId,
    required int season,
    required int round,
    required DateTime currentDate,
  }) {
    if (needs.isEmpty) return null;

    final period = TransferWindowEngine.periodKey(currentDate);
    final needSeed = stableSeed('$careerId|$season|$period|${buyer.id}|need');
    final need = _chooseNeed(needs, needSeed);
    if (need.priority <= 0) return null;

    final approach = _approachFor(buyer);
    final competitionSeed = stableSeed(
      '$careerId|$season|$period|$round|${buyer.id}|competition',
    );

    return CpuMarketStrategy(
      need: need,
      approach: approach,
      targetSeed: stableSeed(
        '$careerId|$season|$period|${buyer.id}|${need.position.name}|targets',
      ),
      competitionScore: need.priority +
          (switch (approach) {
            CpuMarketApproach.opportunistic => 4,
            CpuMarketApproach.balanced => 10,
            CpuMarketApproach.ambitious => 16,
          }) +
          Random(competitionSeed).nextInt(31),
    );
  }

  static CpuMarketApproach _approachFor(Club club) {
    if (CpuFinancialEngine.hasFinancialPressure(club)) {
      return CpuMarketApproach.opportunistic;
    }
    final strongRunway = club.money >= max(40_000_000, club.payroll * 10);
    final strongBudget = club.transferBudget >= max(25_000_000, club.payroll * 5);
    if (club.reputation >= 76 && strongRunway && strongBudget) {
      return CpuMarketApproach.ambitious;
    }
    return CpuMarketApproach.balanced;
  }

  static CpuSquadNeed _chooseNeed(List<CpuSquadNeed> needs, int seed) {
    if (needs.length == 1) return needs.first;

    final top = needs.first;
    if (top.currentDepth < top.minimumDepth) return top;

    final close = needs
        .where((need) => need.priority >= top.priority - 16)
        .take(3)
        .toList(growable: false);
    if (close.length == 1) return close.first;

    final roll = Random(seed).nextDouble();
    if (roll < .68) return close.first;
    if (roll < .90 || close.length == 2) return close[1];
    return close[2];
  }

  static int stableSeed(String value) {
    var hash = 17;
    for (final codeUnit in value.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x7fffffff;
    }
    return hash;
  }
}
