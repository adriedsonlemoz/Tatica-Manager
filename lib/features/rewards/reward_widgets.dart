import 'package:flutter/material.dart';

import '../../app/widgets/common.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/reward/reward_models.dart';

class RewardBalanceChip extends StatelessWidget {
  const RewardBalanceChip({
    super.key,
    required this.balance,
    required this.onTap,
  });

  final int balance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.green.withValues(alpha: .35),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.workspace_premium_rounded,
                  size: 15,
                  color: AppColors.green,
                ),
                const SizedBox(width: 4),
                Text(
                  '$balance PM',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class RewardReceiptCard extends StatelessWidget {
  const RewardReceiptCard({super.key, required this.receipt});

  final RewardReceipt receipt;

  @override
  Widget build(BuildContext context) {
    if (!receipt.earned) return const SizedBox.shrink();
    return SectionCard(
      borderColor: AppColors.green.withValues(alpha: .55),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.redeem_rounded,
                  color: AppColors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RECOMPENSA CONCLUÍDA',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      'Pontos de Manager adicionados à carteira global',
                      style: TextStyle(color: AppColors.muted, fontSize: 10),
                    ),
                  ],
                ),
              ),
              Text(
                '+${receipt.total} PM',
                style: const TextStyle(
                  color: AppColors.green,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 8),
          for (final item in receipt.transactions)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.description,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  Text(
                    '+${item.amount} PM',
                    style: const TextStyle(
                      color: AppColors.green,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 5),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Saldo: ${receipt.balanceAfter} PM',
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
