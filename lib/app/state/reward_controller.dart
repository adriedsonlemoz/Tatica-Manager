import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/diagnostics/diagnostic_service.dart';
import '../../domain/reward/reward_models.dart';
import '../../domain/season/career_state.dart';
import 'providers.dart';

final rewardControllerProvider =
    NotifierProvider<RewardController, RewardState>(RewardController.new);

class RewardNotice {
  const RewardNotice({
    required this.eventKey,
    required this.title,
    required this.message,
  });

  final String eventKey;
  final String title;
  final String message;
}

class RewardState {
  const RewardState({
    this.snapshot = const RewardSnapshot(),
    this.loading = false,
    this.loaded = false,
    this.lastReceipt,
    this.notice,
  });

  final RewardSnapshot snapshot;
  final bool loading;
  final bool loaded;
  final RewardReceipt? lastReceipt;
  final RewardNotice? notice;

  RewardState copyWith({
    RewardSnapshot? snapshot,
    bool? loading,
    bool? loaded,
    RewardReceipt? lastReceipt,
    RewardNotice? notice,
    bool clearNotice = false,
  }) =>
      RewardState(
        snapshot: snapshot ?? this.snapshot,
        loading: loading ?? this.loading,
        loaded: loaded ?? this.loaded,
        lastReceipt: lastReceipt ?? this.lastReceipt,
        notice: clearNotice ? null : (notice ?? this.notice),
      );
}

class RewardController extends Notifier<RewardState> {
  @override
  RewardState build() => const RewardState();

  Future<void> bootstrap() async {
    if (state.loading || state.loaded) return;
    state = state.copyWith(loading: true);
    try {
      final snapshot = await ref.read(rewardRepositoryProvider).loadRewards();
      state = state.copyWith(
        snapshot: snapshot,
        loading: false,
        loaded: true,
      );
    } catch (error, stack) {
      await DiagnosticService.instance.record(
        'REWARD_LOAD_ERROR',
        error,
        stack,
        'Falha ao carregar a carteira global de PM.',
      );
      state = state.copyWith(loading: false, loaded: true);
    }
  }

  Future<RewardCommitResult> finalizeMatch({
    required CareerState nextCareer,
    required MatchRewardRequest request,
  }) async {
    try {
      final result = await ref.read(rewardRepositoryProvider).finalizeMatch(
            nextCareer: nextCareer,
            request: request,
          );
      final notice = _noticeFor(result.receipt);
      state = state.copyWith(
        snapshot: result.snapshot,
        loaded: true,
        lastReceipt: result.receipt,
        notice: notice,
        clearNotice: notice == null,
      );
      return result;
    } catch (error, stack) {
      await DiagnosticService.instance.record(
        'REWARD_MATCH_COMMIT_ERROR',
        error,
        stack,
        'A partida e a recompensa não foram gravadas.',
      );
      rethrow;
    }
  }

  Future<RewardCommitResult> finalizeSeason({
    required CareerState nextCareer,
    required SeasonRewardRequest request,
  }) async {
    try {
      final result = await ref.read(rewardRepositoryProvider).finalizeSeason(
            nextCareer: nextCareer,
            request: request,
          );
      final notice = _noticeFor(result.receipt);
      state = state.copyWith(
        snapshot: result.snapshot,
        loaded: true,
        lastReceipt: result.receipt,
        notice: notice,
        clearNotice: notice == null,
      );
      return result;
    } catch (error, stack) {
      await DiagnosticService.instance.record(
        'REWARD_SEASON_COMMIT_ERROR',
        error,
        stack,
        'A nova temporada e suas recompensas não foram gravadas.',
      );
      rethrow;
    }
  }

  Future<void> refresh() async {
    final snapshot = await ref.read(rewardRepositoryProvider).loadRewards();
    state = state.copyWith(snapshot: snapshot, loaded: true);
  }

  void consumeNotice(String eventKey) {
    if (state.notice?.eventKey != eventKey) return;
    state = state.copyWith(clearNotice: true);
  }

  static RewardNotice? _noticeFor(RewardReceipt receipt) {
    if (!receipt.earned) return null;
    final objective = receipt.transactions
        .where((item) => item.origin == RewardOrigin.boardObjective)
        .firstOrNull;
    if (objective != null) {
      return RewardNotice(
        eventKey: receipt.eventKey,
        title: 'Objetivo concluído',
        message:
            'Meta da diretoria cumprida: +${objective.amount} PM. Total recebido: +${receipt.total} PM.',
      );
    }
    final main = receipt.transactions.length == 1
        ? receipt.transactions.single.description
        : '${receipt.transactions.length} recompensas recebidas';
    return RewardNotice(
      eventKey: receipt.eventKey,
      title: 'Recompensa concluída',
      message: '$main • +${receipt.total} PM',
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
