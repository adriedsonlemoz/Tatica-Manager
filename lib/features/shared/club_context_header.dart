import 'package:flutter/material.dart';

import '../../app/widgets/common.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/club/club.dart';

class ClubContextHeader extends StatelessWidget {
  const ClubContextHeader({
    super.key,
    required this.club,
    required this.season,
  });

  final Club? club;
  final int season;

  @override
  Widget build(BuildContext context) {
    final currentClub = club;
    return Container(
      height: 88,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: .7)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x28000000),
            blurRadius: 14,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          if (currentClub != null)
            ClubBadge(club: currentClub, size: 64)
          else
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.shield_outlined,
                size: 34,
                color: AppColors.muted,
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentClub?.name ?? 'Sem clube',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Temporada $season',
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.public_rounded,
                      size: 14,
                      color: AppColors.muted,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      currentClub == null
                          ? 'Mercado de trabalho'
                          : 'Reputação ${currentClub.reputation}',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (currentClub != null) ...[
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _MoneyLine(
                  icon: Icons.account_balance_wallet_rounded,
                  value: compactMoney(currentClub.money),
                  color: AppColors.green,
                ),
                const SizedBox(height: 8),
                _MoneyLine(
                  icon: Icons.swap_horiz_rounded,
                  value: compactMoney(currentClub.transferBudget),
                  color: AppColors.warning,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MoneyLine extends StatelessWidget {
  const _MoneyLine({
    required this.icon,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          ),
        ],
      );
}
