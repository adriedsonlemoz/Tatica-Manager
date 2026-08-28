import 'dart:math';

import '../../domain/contract/contract.dart';
import '../../domain/player/player.dart';

class ContractProposal {
  const ContractProposal({required this.salary, required this.years});
  final int salary;
  final int years;
}

class ContractNegotiationResult {
  const ContractNegotiationResult({
    required this.accepted,
    required this.player,
    required this.signingCost,
    required this.message,
    this.requiredSalary,
  });

  final bool accepted;
  final Player player;
  final int signingCost;
  final String message;
  final int? requiredSalary;
}

abstract final class ContractEngine {
  static int expectedSalary(Player player) {
    final rolePremium =
        player.overall >= 84 ? 1.28 : player.overall >= 78 ? 1.15 : 1.02;
    final potentialPremium =
        player.age <= 23 && player.potential - player.overall >= 6 ? 1.12 : 1.0;
    return max(
      2000,
      ((player.salary * rolePremium * potentialPremium) / 500).round() * 500,
    );
  }

  static ContractNegotiationResult negotiate({
    required Player player,
    required ContractProposal proposal,
    required int season,
    required int clubMoney,
  }) {
    if (proposal.salary <= 0) {
      return ContractNegotiationResult(
        accepted: false,
        player: player,
        signingCost: 0,
        message: 'O salário proposto deve ser maior que zero.',
      );
    }
    if (proposal.years < 1 || proposal.years > 5) {
      return ContractNegotiationResult(
        accepted: false,
        player: player,
        signingCost: 0,
        message: 'A duração deve ficar entre 1 e 5 anos.',
      );
    }
    if (player.age >= 34 && proposal.years >= 4) {
      return ContractNegotiationResult(
        accepted: false,
        player: player,
        signingCost: 0,
        message: 'O jogador recusou um vínculo tão longo nesta fase da carreira.',
      );
    }

    final expected = expectedSalary(player);
    final durationFactor = player.age >= 31 && proposal.years >= 3
        ? 1.08
        : player.age <= 23 && proposal.years == 1
            ? 1.10
            : 1.0;
    final threshold = (expected * durationFactor).round();
    final signingCost = proposal.salary * 2;

    if (clubMoney < signingCost) {
      return ContractNegotiationResult(
        accepted: false,
        player: player,
        signingCost: 0,
        message: 'Saldo insuficiente para luvas e formalização.',
      );
    }
    if (proposal.salary < threshold) {
      return ContractNegotiationResult(
        accepted: false,
        player: player,
        signingCost: 0,
        message: 'O jogador fez uma contraproposta salarial para este contrato.',
        requiredSalary: threshold,
      );
    }

    return ContractNegotiationResult(
      accepted: true,
      player: player.copyWith(
        contract: PlayerContract(
          salary: proposal.salary,
          endSeason: season + proposal.years,
        ),
        morale: min(100, player.morale + 6),
      ),
      signingCost: signingCost,
      message: 'Contrato renovado por ${proposal.years} ano(s).',
    );
  }

  static Player signFreeAgent({
    required Player player,
    required String clubId,
    required int season,
    int years = 2,
  }) {
    final salary = max(player.salary, expectedSalary(player));
    return player.copyWith(
      clubId: clubId,
      listed: false,
      contract: PlayerContract(
        salary: salary,
        endSeason: season + years,
      ),
      morale: min(100, player.morale + 4),
    );
  }
}
