import 'package:flutter/material.dart';

import '../../app/widgets/manager_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/career/manager_profile.dart';
import '../../domain/club/club.dart';
import 'home_visual_components.dart';

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
  Widget build(BuildContext context) {
    final rawPrimary = Color(club.colors.primaryHex);
    final rawSecondary = Color(club.colors.secondaryHex);
    final accent = HSLColor.fromColor(rawSecondary).saturation >
            HSLColor.fromColor(rawPrimary).saturation + .12
        ? rawSecondary
        : rawPrimary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 3),
      child: Container(
        height: 70,
        padding: const EdgeInsets.fromLTRB(9, 7, 8, 7),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(AppColors.surfaceRaised, accent, .11)!,
              AppColors.surface.withValues(alpha: .98),
              AppColors.background,
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border.withValues(alpha: .82)),
          boxShadow: const [
            BoxShadow(color: Color(0x36000000), blurRadius: 16, offset: Offset(0, 6)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            HomeClubCrest(club: club, size: 54, framed: true),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    club.name.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .18,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Temporada $season • $competitionName',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 8.8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded, color: AppColors.green, size: 11),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          nextMatchLabel.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.green,
                            fontSize: 10.0,
                            fontWeight: FontWeight.w900,
                            letterSpacing: .10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 5),
            _HeaderIconButton(
              icon: Icons.mail_outline_rounded,
              showDot: unreadMessages > 0,
              badgeText: unreadMessages > 9
                  ? '9+'
                  : unreadMessages > 0
                      ? '$unreadMessages'
                      : null,
              onTap: onInboxTap,
            ),
            const SizedBox(width: 5),
            _ManagerCard(manager: manager, onTap: onManagerTap),
          ],
        ),
      ),
    );
  }
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
          const SizedBox(width: 5),
          Expanded(
            child: _FinanceStatusCard(
              icon: Icons.swap_horiz_rounded,
              label: 'TRANSFERÊNCIAS',
              value: compactMoney(transferBudget),
              accent: const Color(0xFF64C9FF),
              onTap: onTap,
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: _FinanceStatusCard(
              icon: Icons.trending_up_rounded,
              label: 'RECEITAS / MÊS',
              value: compactMoney(monthIncome),
              accent: const Color(0xFF8BE735),
              onTap: onTap,
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: _FinanceStatusCard(
              icon: Icons.trending_down_rounded,
              label: 'DESPESAS / MÊS',
              value: compactMoney(monthExpenses),
              accent: AppColors.danger,
              onTap: onTap,
            ),
          ),
        ],
      );
}

class _ManagerCard extends StatelessWidget {
  const _ManagerCard({required this.manager, required this.onTap});

  final ManagerProfile manager;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 49,
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 3),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.green.withValues(alpha: .10),
                AppColors.surfaceRaised,
                AppColors.background,
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.green.withValues(alpha: .55), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ManagerAvatar(manager: manager, size: 34),
              const SizedBox(height: 2),
              const Text(
                'TÉCNICO',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 5.8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .16,
                ),
              ),
            ],
          ),
        ),
      );
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.showDot,
    required this.onTap,
    this.badgeText,
  });

  final IconData icon;
  final bool showDot;
  final String? badgeText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Container(
          width: 34,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: .54),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: AppColors.border.withValues(alpha: .75)),
          ),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Icon(icon, size: 21, color: AppColors.white),
              if (showDot)
                Positioned(
                  top: -5,
                  right: -4,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.background, width: 1.2),
                    ),
                    child: Text(
                      badgeText ?? '',
                      style: const TextStyle(color: Colors.black, fontSize: 6.6, fontWeight: FontWeight.w900),
                    ),
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
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(7, 6, 7, 5),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accent.withValues(alpha: .16),
                AppColors.surfaceRaised.withValues(alpha: .96),
                AppColors.background.withValues(alpha: .95),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: accent.withValues(alpha: .28)),
            boxShadow: const [
              BoxShadow(color: Color(0x22000000), blurRadius: 8, offset: Offset(0, 3)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: accent, size: 13),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: accent,
                        fontSize: 6.8,
                        height: 1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .1,
                  ),
                ),
              ),
              const SizedBox(height: 1),
              HomeAccentLine(color: accent),
            ],
          ),
        ),
      );
}
