import 'package:flutter/material.dart';

import '../../app/widgets/common.dart';
import '../../app/widgets/manager_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/career/manager_profile.dart';
import '../../domain/club/club.dart';

class HomeClubHeader extends StatelessWidget {
  const HomeClubHeader({
    super.key,
    required this.club,
    required this.manager,
    required this.season,
    required this.competitionName,
    required this.nextMatchLabel,
    required this.unreadMessages,
    required this.onInboxTap,
    required this.onManagerTap,
  });

  final Club club;
  final ManagerProfile manager;
  final int season;
  final String competitionName;
  final String nextMatchLabel;
  final int unreadMessages;
  final VoidCallback onInboxTap;
  final VoidCallback onManagerTap;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 14, 16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.surfaceRaised, AppColors.surface, AppColors.background],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: IgnorePointer(child: _HomeStadiumGlow())),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClubBadge(club: club, size: 64),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          club.name.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: .4,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Temporada $season • $competitionName',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.muted, fontSize: 11),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          nextMatchLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.green,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _HeaderIconButton(
                  icon: Icons.mail_outline_rounded,
                  showDot: unreadMessages > 0,
                  badgeText: unreadMessages > 9 ? '9+' : unreadMessages > 0 ? '$unreadMessages' : null,
                  onTap: onInboxTap,
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: onManagerTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 58,
                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceRaised,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.green.withValues(alpha: .65)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ManagerAvatar(manager: manager, size: 42),
                        const SizedBox(height: 3),
                        const Text(
                          'TÉCNICO',
                          style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

class HomeFinanceGrid extends StatelessWidget {
  const HomeFinanceGrid({
    super.key,
    required this.balance,
    required this.transferBudget,
    required this.monthIncome,
    required this.monthExpenses,
    this.onTap,
  });

  final int balance;
  final int transferBudget;
  final int monthIncome;
  final int monthExpenses;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _FinanceStatusCard(
              icon: Icons.account_balance_wallet_outlined,
              label: 'SALDO',
              value: compactMoney(balance),
              accent: AppColors.green,
              onTap: onTap,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: _FinanceStatusCard(
              icon: Icons.swap_horiz_rounded,
              label: 'TRANSFERÊNCIAS',
              value: compactMoney(transferBudget),
              accent: const Color(0xFF5EC8FF),
              onTap: onTap,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: _FinanceStatusCard(
              icon: Icons.south_west_rounded,
              label: 'RECEITAS / MÊS',
              value: compactMoney(monthIncome),
              accent: const Color(0xFF8EEA3C),
              onTap: onTap,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: _FinanceStatusCard(
              icon: Icons.north_east_rounded,
              label: 'DESPESAS / MÊS',
              value: compactMoney(monthExpenses),
              accent: AppColors.danger,
              onTap: onTap,
            ),
          ),
        ],
      );
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.showDot, required this.onTap, this.badgeText});

  final IconData icon;
  final bool showDot;
  final String? badgeText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 38,
          height: 46,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, size: 27, color: AppColors.white),
              if (showDot)
                Positioned(
                  top: 4,
                  right: 1,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 11, minHeight: 11),
                    padding: badgeText == null ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 3),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: AppColors.green, borderRadius: BorderRadius.circular(8)),
                    child: badgeText == null
                        ? null
                        : Text(badgeText!, style: const TextStyle(color: Colors.black, fontSize: 6, fontWeight: FontWeight.w900)),
                  ),
                ),
            ],
          ),
        ),
      );
}

class _FinanceStatusCard extends StatelessWidget {
  const _FinanceStatusCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 86,
          padding: const EdgeInsets.fromLTRB(9, 9, 8, 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [accent.withValues(alpha: .13), AppColors.surface],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accent.withValues(alpha: .24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: accent, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 7, color: AppColors.muted, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(height: 3),
              Container(height: 2, width: 24, decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(2))),
            ],
          ),
        ),
      );
}

class _HomeStadiumGlow extends StatelessWidget {
  const _HomeStadiumGlow();

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _HomeStadiumGlowPainter());
}

class _HomeStadiumGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white.withValues(alpha: .09), Colors.transparent],
      ).createShader(Rect.fromCircle(center: Offset(size.width * .72, size.height * .45), radius: size.width * .45));
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _HomeStadiumGlowPainter oldDelegate) => false;
}
