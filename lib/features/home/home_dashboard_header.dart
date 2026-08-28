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
    final accent = AppColors.readableAccent(Color(club.colors.primaryHex));
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
      child: Container(
        padding: const EdgeInsets.fromLTRB(11, 10, 10, 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(AppColors.surfaceRaised, accent, .08)!,
              AppColors.surface.withValues(alpha: .98),
              AppColors.background,
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border.withValues(alpha: .82)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x44000000),
              blurRadius: 22,
              offset: Offset(0, 9),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: 58,
              top: -34,
              child: Container(
                width: 150,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [accent.withValues(alpha: .11), Colors.transparent],
                  ),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                HomeClubCrest(club: club, size: 74, framed: true),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        club.name.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .25,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        'Temporada $season • $competitionName',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_rounded,
                            color: AppColors.green,
                            size: 14,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              nextMatchLabel.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.green,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: .15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 7),
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
                const SizedBox(width: 7),
                _ManagerCard(manager: manager, onTap: onManagerTap),
              ],
            ),
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
          const SizedBox(width: 6),
          Expanded(
            child: _FinanceStatusCard(
              icon: Icons.swap_horiz_rounded,
              label: 'TRANSFERÊNCIAS',
              value: compactMoney(transferBudget),
              accent: const Color(0xFF64C9FF),
              onTap: onTap,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _FinanceStatusCard(
              icon: Icons.trending_up_rounded,
              label: 'RECEITAS / MÊS',
              value: compactMoney(monthIncome),
              accent: const Color(0xFF8BE735),
              onTap: onTap,
            ),
          ),
          const SizedBox(width: 6),
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
        borderRadius: BorderRadius.circular(17),
        child: Container(
          width: 64,
          padding: const EdgeInsets.fromLTRB(5, 5, 5, 4),
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
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: AppColors.green.withValues(alpha: .75),
              width: 1.1,
            ),
            boxShadow: const [
              BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 5)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ManagerAvatar(manager: manager, size: 48),
              const SizedBox(height: 3),
              const Text(
                'TÉCNICO',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 7.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .25,
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
        borderRadius: BorderRadius.circular(13),
        child: Container(
          width: 42,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: .54),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AppColors.border.withValues(alpha: .75)),
          ),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Icon(icon, size: 26, color: AppColors.white),
              if (showDot)
                Positioned(
                  top: -6,
                  right: -5,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.background, width: 1.5),
                    ),
                    child: Text(
                      badgeText ?? '',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                      ),
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
        borderRadius: BorderRadius.circular(17),
        child: Container(
          padding: const EdgeInsets.fromLTRB(9, 9, 8, 7),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accent.withValues(alpha: .17),
                AppColors.surfaceRaised.withValues(alpha: .97),
                AppColors.background.withValues(alpha: .95),
              ],
            ),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: accent.withValues(alpha: .30)),
            boxShadow: const [
              BoxShadow(color: Color(0x26000000), blurRadius: 10, offset: Offset(0, 4)),
            ],
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
                      style: TextStyle(
                        color: accent,
                        fontSize: 7,
                        height: 1.05,
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
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .15,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              HomeAccentLine(color: accent),
            ],
          ),
        ),
      );
}
