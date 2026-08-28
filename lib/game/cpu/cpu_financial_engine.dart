import 'dart:math';

import '../../domain/club/club.dart';
import '../../domain/player/player.dart';
import 'cpu_squad_needs_engine.dart';

/// Regras financeiras usadas apenas para orientar decisões da CPU.
///
/// A execução financeira continua centralizada no TransferEngine. Este engine
/// evita que a CPU comprometa caixa/orçamento demais em um único reforço e
/// considera o impacto da nova folha salarial antes de tentar a operação.
abstract final class CpuFinancialEngine {
  static bool hasFinancialPressure(Club club) =>
      club.money <= max(8_000_000, club.payroll * 4);

  static int cashReserve(Club club) =>
      max((club.money * .12).round(), club.payroll * 4);

  static int maxTransferFee({
    required Club buyer,
    required CpuSquadNeed need,
  }) {
    final shortage = need.currentDepth < need.minimumDepth;
    final budgetShare = shortage
        ? .58
        : need.priority >= 80
            ? .42
            : .30;
    final reserve = cashReserve(buyer);
    final spendableCash = max(0, buyer.money - reserve);
    return min(
      spendableCash,
      (buyer.transferBudget * budgetShare).round(),
    );
  }

  static bool canAfford({
    required Club buyer,
    required CpuSquadNeed need,
    required Player player,
    required int fee,
    required int salary,
  }) {
    if (fee < 0 || salary <= 0) return false;
    if (fee > buyer.money || fee > buyer.transferBudget) return false;
    if (fee > maxTransferFee(buyer: buyer, need: need)) return false;

    final shortage = need.currentDepth < need.minimumDepth;
    final afterFee = buyer.money - fee;
    final projectedPayroll = buyer.payroll + salary;
    final payrollRunway = projectedPayroll * (shortage ? 3 : 4);
    final reserveFloor = shortage
        ? (cashReserve(buyer) * .72).round()
        : cashReserve(buyer);
    if (afterFee < max(payrollRunway, reserveFloor)) return false;

    final averageSalary = buyer.squad.isEmpty
        ? salary
        : (buyer.payroll / buyer.squad.length).round();
    final starUpgrade = player.overall >= need.bestOverall + 4;
    final salaryCeiling = max(
      20_000,
      (averageSalary * (starUpgrade ? 2.5 : shortage ? 2.2 : 1.9)).round(),
    );
    return salary <= salaryCeiling;
  }

  static int affordabilityScore({
    required Club buyer,
    required CpuSquadNeed need,
    required int fee,
  }) {
    if (fee == 0) return 140;
    final maxFee = max(1, maxTransferFee(buyer: buyer, need: need));
    if (fee > maxFee) return -200;
    return max(0, 140 - (fee * 140 ~/ maxFee));
  }
}
