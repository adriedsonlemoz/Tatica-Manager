import '../../domain/club/club.dart';
import '../../domain/player/player.dart';
import '../contract/contract_engine.dart';
import '../contract/contract_lifecycle_engine.dart';
import '../transfer/transfer_engine.dart';
import '../transfer/transfer_window_engine.dart';
import 'cpu_financial_engine.dart';
import 'cpu_market_strategy_engine.dart';
import 'cpu_recruitment_engine.dart';
import 'cpu_selling_engine.dart';
import 'cpu_squad_needs_engine.dart';

enum CpuMarketMoveType { freeAgentSigning, transfer }

class CpuMarketMove {
  const CpuMarketMove({
    required this.type,
    required this.playerId,
    required this.playerName,
    required this.toClubId,
    required this.fee,
    this.fromClubId,
  });

  final CpuMarketMoveType type;
  final String playerId;
  final String playerName;
  final String? fromClubId;
  final String toClubId;
  final int fee;
}

class CpuMarketInterest {
  const CpuMarketInterest({
    required this.type,
    required this.playerId,
    required this.clubId,
    required this.position,
    this.fromClubId,
  });

  final CpuMarketMoveType type;
  final String playerId;
  final String clubId;
  final PlayerPosition position;
  final String? fromClubId;
}

class CpuMarketResult {
  const CpuMarketResult({
    required this.clubs,
    required this.freeAgents,
    this.moves = const [],
    this.interests = const [],
  });

  final List<Club> clubs;
  final List<Player> freeAgents;
  final List<CpuMarketMove> moves;
  final List<CpuMarketInterest> interests;
}

class _CpuMarketPlan {
  const _CpuMarketPlan({
    required this.buyerId,
    required this.need,
    required this.targets,
    required this.emergency,
    required this.competitionScore,
  });

  final String buyerId;
  final CpuSquadNeed need;
  final List<CpuRecruitmentTarget> targets;
  final bool emergency;
  final int competitionScore;
}

abstract final class CpuManagerEngine {
  static const int maxMarketMovesPerRound = 2;
  static const int maxTargetsPerClub = 3;

  static CpuMarketResult runRound({
    required List<Club> clubs,
    required List<Player> freeAgents,
    required String userClubId,
    required int season,
    required int round,
    required DateTime currentDate,
    String careerId = '',
  }) {
    var workingClubs = _renewCpuContracts(
      clubs: clubs,
      userClubId: userClubId,
      season: season,
    );
    var workingFree = [...freeAgents];

    if (!TransferWindowEngine.isOpen(currentDate)) {
      return CpuMarketResult(clubs: workingClubs, freeAgents: workingFree);
    }

    final allowRegularMarket = round.isEven;
    final plans = <_CpuMarketPlan>[];
    final interests = <CpuMarketInterest>[];

    for (final buyer in workingClubs.where((club) => club.id != userClubId)) {
      final emergency =
          buyer.squad.length < TransferEngine.minimumSquadSize + 2;
      if (!emergency && !allowRegularMarket) continue;
      if (buyer.squad.length >= TransferEngine.maximumSquadSize) continue;

      final needs = CpuSquadNeedsEngine.assess(buyer);
      final strategy = CpuMarketStrategyEngine.build(
        buyer: buyer,
        needs: needs,
        careerId: careerId,
        season: season,
        round: round,
        currentDate: currentDate,
      );
      if (strategy == null) continue;

      final targets = CpuRecruitmentEngine.shortlist(
        buyer: buyer,
        need: strategy.need,
        freeAgents: workingFree,
        clubs: workingClubs,
        userClubId: userClubId,
        season: season,
        preferFreeAgents: strategy.preferFreeAgents,
        ambitious: strategy.approach == CpuMarketApproach.ambitious,
        randomSeed: strategy.targetSeed,
        limit: maxTargetsPerClub,
      );
      if (targets.isEmpty) continue;

      plans.add(
        _CpuMarketPlan(
          buyerId: buyer.id,
          need: strategy.need,
          targets: targets,
          emergency: emergency,
          competitionScore: strategy.competitionScore,
        ),
      );
      final primary = targets.first;
      interests.add(
        CpuMarketInterest(
          type: primary.seller == null
              ? CpuMarketMoveType.freeAgentSigning
              : CpuMarketMoveType.transfer,
          playerId: primary.player.id,
          clubId: buyer.id,
          position: strategy.need.position,
          fromClubId: primary.seller?.id,
        ),
      );
    }

    plans.sort((a, b) {
      if (a.emergency != b.emergency) return a.emergency ? -1 : 1;
      final byCompetition = b.competitionScore.compareTo(a.competitionScore);
      if (byCompetition != 0) return byCompetition;
      return a.buyerId.compareTo(b.buyerId);
    });

    final movedPlayerIds = <String>{};
    final moves = <CpuMarketMove>[];
    for (final plan in plans) {
      if (moves.length >= maxMarketMovesPerRound) break;

      final buyerIndex = workingClubs.indexWhere(
        (club) => club.id == plan.buyerId,
      );
      if (buyerIndex < 0) continue;
      if (workingClubs[buyerIndex].squad.length >=
          TransferEngine.maximumSquadSize) {
        continue;
      }

      for (final target in plan.targets) {
        if (movedPlayerIds.contains(target.player.id)) continue;
        final buyer = workingClubs[buyerIndex];

        if (target.seller == null) {
          final currentPlayer = workingFree
              .where((player) => player.id == target.player.id)
              .firstOrNull;
          if (currentPlayer == null ||
              !CpuFinancialEngine.canAfford(
                buyer: buyer,
                need: plan.need,
                player: currentPlayer,
                fee: 0,
                salary: target.salary,
              )) {
            continue;
          }
          final execution = TransferEngine.execute(
            player: currentPlayer,
            buyer: buyer,
            fee: 0,
            salary: target.salary,
            years: target.years,
            season: season,
          );
          if (!execution.decision.accepted) continue;

          workingClubs[buyerIndex] = execution.buyer;
          workingFree.removeWhere((player) => player.id == currentPlayer.id);
          movedPlayerIds.add(currentPlayer.id);
          moves.add(
            CpuMarketMove(
              type: CpuMarketMoveType.freeAgentSigning,
              playerId: currentPlayer.id,
              playerName: currentPlayer.displayName,
              toClubId: buyer.id,
              fee: 0,
            ),
          );
          break;
        }

        final sellerId = target.seller?.id;
        if (sellerId == null || sellerId == userClubId) continue;
        final sellerIndex = workingClubs.indexWhere(
          (club) => club.id == sellerId,
        );
        if (sellerIndex < 0) continue;
        final seller = workingClubs[sellerIndex];
        final currentPlayer = seller.squad
            .where((player) => player.id == target.player.id)
            .firstOrNull;
        if (currentPlayer == null) continue;

        final sale = CpuSellingEngine.assess(
          club: seller,
          player: currentPlayer,
          season: season,
        );
        if (!sale.sellable) continue;
        final currentFee = CpuSellingEngine.askingFee(
          seller: seller,
          buyer: buyer,
          player: currentPlayer,
          season: season,
        );
        if (!CpuFinancialEngine.canAfford(
          buyer: buyer,
          need: plan.need,
          player: currentPlayer,
          fee: currentFee,
          salary: target.salary,
        )) {
          continue;
        }

        final execution = TransferEngine.execute(
          player: currentPlayer,
          buyer: buyer,
          seller: seller,
          fee: currentFee,
          salary: target.salary,
          years: target.years,
          season: season,
        );
        if (!execution.decision.accepted) continue;

        workingClubs[buyerIndex] = execution.buyer;
        workingClubs[sellerIndex] = execution.seller!;
        movedPlayerIds.add(currentPlayer.id);
        moves.add(
          CpuMarketMove(
            type: CpuMarketMoveType.transfer,
            playerId: currentPlayer.id,
            playerName: currentPlayer.displayName,
            fromClubId: seller.id,
            toClubId: buyer.id,
            fee: currentFee,
          ),
        );
        break;
      }
    }

    return CpuMarketResult(
      clubs: workingClubs,
      freeAgents: workingFree,
      moves: moves,
      interests: interests,
    );
  }

  static List<Club> _renewCpuContracts({
    required List<Club> clubs,
    required String userClubId,
    required int season,
  }) {
    return clubs.map((club) {
      if (club.id == userClubId) return club;

      var money = club.money;
      var squad = [...club.squad];
      for (var index = 0; index < squad.length; index++) {
        final player = squad[index];
        if (!ContractLifecycleEngine.expiresThisSeason(player, season) ||
            player.overall < club.reputation - 12) {
          continue;
        }

        final years = player.age >= 32 ? 2 : 3;
        var negotiation = ContractEngine.negotiate(
          player: player,
          proposal: ContractProposal(
            salary: ContractEngine.expectedSalary(player),
            years: years,
          ),
          season: season,
          clubMoney: money,
        );
        final counterSalary = negotiation.requiredSalary;
        if (!negotiation.accepted && counterSalary != null) {
          negotiation = ContractEngine.negotiate(
            player: player,
            proposal: ContractProposal(
              salary: counterSalary,
              years: years,
            ),
            season: season,
            clubMoney: money,
          );
        }
        if (!negotiation.accepted || money < negotiation.signingCost * 4) {
          continue;
        }
        money -= negotiation.signingCost;
        squad[index] = negotiation.player;
      }
      return club.copyWith(money: money, squad: squad);
    }).toList();
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
