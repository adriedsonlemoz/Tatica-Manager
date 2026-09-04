import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/state/reward_controller.dart';
import '../../app/widgets/common.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/reward/reward_models.dart';

class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewards = ref.watch(rewardControllerProvider);
    final career = ref.watch(gameControllerProvider).career;
    final snapshot = rewards.snapshot;
    final careerProgress = career == null
        ? null
        : snapshot.progressForCareer(career.careerId);

    return PremiumScaffold(
      safeBottom: true,
      appBar: const GameTopBar(
        title: 'Recompensas',
        subtitle: 'Pontos de Manager globais',
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(rewardControllerProvider.notifier).refresh(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
          children: [
            _WalletCard(wallet: snapshot.wallet),
            const SizedBox(height: 10),
            if (careerProgress != null) ...[
              _CurrentStreakCard(progress: careerProgress),
              const SizedBox(height: 10),
            ],
            const _SectionTitle('DESAFIOS'),
            const SizedBox(height: 7),
            for (final entry in RewardRules.matchMilestones.entries) ...[
              _MilestoneCard(
                target: entry.key,
                reward: entry.value,
                current: snapshot.progress.competitiveMatches,
              ),
              const SizedBox(height: 7),
            ],
            const SizedBox(height: 3),
            const _SectionTitle('CONQUISTAS'),
            const SizedBox(height: 7),
            const SectionCard(
              child: Row(
                children: [
                  Icon(Icons.emoji_events_outlined, color: AppColors.muted),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'As conquistas especiais aparecerão aqui quando suas condições reais forem adicionadas ao jogo.',
                      style: TextStyle(color: AppColors.muted, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const _SectionTitle('UTILIZAR PM'),
            const SizedBox(height: 7),
            const SectionCard(
              child: Row(
                children: [
                  Icon(Icons.lock_outline_rounded, color: AppColors.green),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'A área de conteúdos e personalizações está preparada para uma atualização futura. PM não pode ser convertido em dinheiro do clube.',
                      style: TextStyle(color: AppColors.textSecondary, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const _SectionTitle('HISTÓRICO DE PM'),
            const SizedBox(height: 7),
            if (snapshot.transactions.isEmpty)
              const SectionCard(
                child: EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'Nenhuma recompensa ainda',
                  text:
                      'Conclua partidas e desafios para receber Pontos de Manager.',
                ),
              )
            else
              ...snapshot.transactions.map(
                (item) => _TransactionTile(transaction: item),
              ),
          ],
        ),
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  const _WalletCard({required this.wallet});

  final RewardWallet wallet;

  @override
  Widget build(BuildContext context) => SectionCard(
        borderColor: AppColors.green.withValues(alpha: .5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CARTEIRA GLOBAL',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: .8,
              ),
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                const Icon(
                  Icons.workspace_premium_rounded,
                  color: AppColors.green,
                  size: 34,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${wallet.balance} PM',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Recebidos ${wallet.lifetimeEarned}',
                      style: const TextStyle(
                        color: AppColors.green,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Utilizados ${wallet.lifetimeSpent}',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 7),
            const Text(
              'O saldo pertence ao jogador e continua disponível ao trocar, criar ou excluir carreiras.',
              style: TextStyle(color: AppColors.muted, fontSize: 10.5),
            ),
          ],
        ),
      );
}

class _CurrentStreakCard extends StatelessWidget {
  const _CurrentStreakCard({required this.progress});

  final RewardCareerProgress progress;

  @override
  Widget build(BuildContext context) => SectionCard(
        child: Row(
          children: [
            const Icon(
              Icons.local_fire_department_rounded,
              color: AppColors.warning,
              size: 28,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SEQUÊNCIA NA CARREIRA ATUAL',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Empate ou derrota encerra a sequência.',
                    style: TextStyle(color: AppColors.muted, fontSize: 10),
                  ),
                ],
              ),
            ),
            Text(
              '${progress.winStreak} V',
              style: const TextStyle(
                color: AppColors.warning,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      );
}

class _MilestoneCard extends StatelessWidget {
  const _MilestoneCard({
    required this.target,
    required this.reward,
    required this.current,
  });

  final int target;
  final int reward;
  final int current;

  @override
  Widget build(BuildContext context) {
    final completed = current >= target;
    final visibleCurrent = current.clamp(0, target);
    return SectionCard(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      borderColor: completed ? AppColors.green.withValues(alpha: .45) : null,
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                completed
                    ? Icons.check_circle_rounded
                    : Icons.flag_outlined,
                color: completed ? AppColors.green : AppColors.muted,
                size: 21,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Concluir $target partidas',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                '+$reward PM',
                style: TextStyle(
                  color: completed ? AppColors.green : AppColors.textSecondary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: target == 0 ? 0 : visibleCurrent / target,
            minHeight: 6,
            borderRadius: BorderRadius.circular(999),
            backgroundColor: AppColors.surfaceRaised,
          ),
          const SizedBox(height: 5),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              completed ? 'Concluído' : '$visibleCurrent/$target',
              style: TextStyle(
                color: completed ? AppColors.green : AppColors.muted,
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction});

  final PmTransaction transaction;

  @override
  Widget build(BuildContext context) => SectionCard(
        margin: const EdgeInsets.only(bottom: 7),
        padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
        child: Row(
          children: [
            Icon(
              transaction.amount >= 0
                  ? Icons.add_circle_outline_rounded
                  : Icons.remove_circle_outline_rounded,
              color:
                  transaction.amount >= 0 ? AppColors.green : AppColors.warning,
              size: 22,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_date(transaction.createdAt)} • saldo ${transaction.balanceAfter} PM',
                    style: const TextStyle(color: AppColors.muted, fontSize: 10),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'ID: ${transaction.relatedId}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${transaction.amount >= 0 ? '+' : ''}${transaction.amount} PM',
              style: TextStyle(
                color: transaction.amount >= 0
                    ? AppColors.green
                    : AppColors.warning,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      );

  static String _date(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    return '${two(value.day)}/${two(value.month)}/${value.year} ${two(value.hour)}:${two(value.minute)}';
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.muted,
              fontWeight: FontWeight.w900,
              letterSpacing: .8,
            ),
      );
}
