import '../../domain/reward/reward_models.dart';
import '../../domain/season/career_state.dart';
import '../../game/reward/reward_calculator.dart';
import 'career_repository.dart';

abstract interface class RewardRepository {
  Future<RewardSnapshot> loadRewards({int transactionLimit = 100});

  Future<RewardCommitResult> finalizeMatch({
    required CareerState nextCareer,
    required MatchRewardRequest request,
  });

  Future<RewardCommitResult> finalizeSeason({
    required CareerState nextCareer,
    required SeasonRewardRequest request,
  });
}

/// Used by controller tests that replace only [CareerRepository]. Production
/// uses the SQLite implementation, where career and rewards share a transaction.
class MemoryRewardRepository implements RewardRepository {
  MemoryRewardRepository(this._careers);

  final CareerRepository _careers;
  RewardSnapshot _snapshot = const RewardSnapshot();
  final Set<String> _events = {};

  @override
  Future<RewardSnapshot> loadRewards({int transactionLimit = 100}) async =>
      _snapshot.copyWith(
        transactions:
            _snapshot.transactions.take(transactionLimit).toList(growable: false),
      );

  @override
  Future<RewardCommitResult> finalizeMatch({
    required CareerState nextCareer,
    required MatchRewardRequest request,
  }) async {
    if (_events.contains(request.eventKey)) {
      return _duplicate(request.eventKey);
    }
    final transactionIds = _snapshot.transactions.map((item) => item.id).toSet();
    final mutation = RewardCalculator.forMatch(
      request: request,
      globalProgress: _snapshot.progress,
      careerProgress: _snapshot.progressForCareer(request.careerId),
      existingTransactionIds: transactionIds,
    );
    await _careers.save(nextCareer);
    _events.add(request.eventKey);
    return _apply(request.eventKey, mutation);
  }

  @override
  Future<RewardCommitResult> finalizeSeason({
    required CareerState nextCareer,
    required SeasonRewardRequest request,
  }) async {
    if (_events.contains(request.eventKey)) {
      return _duplicate(request.eventKey);
    }
    final mutation = RewardCalculator.forSeason(
      request: request,
      globalProgress: _snapshot.progress,
      existingTransactionIds:
          _snapshot.transactions.map((item) => item.id).toSet(),
    );
    await _careers.save(nextCareer);
    _events.add(request.eventKey);
    return _apply(request.eventKey, mutation);
  }

  RewardCommitResult _apply(String eventKey, RewardMutation mutation) {
    var balance = _snapshot.wallet.balance;
    var earned = _snapshot.wallet.lifetimeEarned;
    var spent = _snapshot.wallet.lifetimeSpent;
    final now = DateTime.now();
    final created = <PmTransaction>[];
    for (final grant in mutation.grants) {
      final nextBalance = balance + grant.amount;
      if (nextBalance < 0) {
        throw StateError('Saldo de PM insuficiente.');
      }
      balance = nextBalance;
      if (grant.amount >= 0) {
        earned += grant.amount;
      } else {
        spent += grant.amount.abs();
      }
      created.add(
        PmTransaction(
          id: grant.id,
          origin: grant.origin,
          amount: grant.amount,
          createdAt: now,
          relatedId: grant.relatedId,
          balanceAfter: balance,
          description: grant.description,
          careerId: grant.careerId,
        ),
      );
    }
    final careerProgress = {..._snapshot.careerProgress};
    final nextCareerProgress = mutation.careerProgress;
    if (nextCareerProgress != null) {
      careerProgress[nextCareerProgress.careerId] = nextCareerProgress;
    }
    _snapshot = RewardSnapshot(
      wallet: RewardWallet(
        balance: balance,
        lifetimeEarned: earned,
        lifetimeSpent: spent,
      ),
      progress: mutation.globalProgress,
      transactions: [...created.reversed, ..._snapshot.transactions],
      careerProgress: careerProgress,
    );
    return RewardCommitResult(
      snapshot: _snapshot,
      receipt: RewardReceipt(
        eventKey: eventKey,
        transactions: created,
        balanceAfter: balance,
      ),
    );
  }

  RewardCommitResult _duplicate(String eventKey) => RewardCommitResult(
        snapshot: _snapshot,
        receipt: RewardReceipt(
          eventKey: eventKey,
          transactions: const [],
          balanceAfter: _snapshot.wallet.balance,
          duplicate: true,
        ),
      );
}
