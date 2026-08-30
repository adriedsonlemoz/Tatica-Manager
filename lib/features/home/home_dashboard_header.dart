import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/club/club.dart';
import 'home_visual_components.dart';

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({
    super.key,
    required this.unreadMessages,
    required this.onMenuTap,
    required this.onNotificationsTap,
    required this.onInboxTap,
  });

  final int unreadMessages;
  final VoidCallback onMenuTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onInboxTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(14, 7, 14, 4),
        child: SizedBox(
          height: 42,
          child: Row(
            children: [
              IconButton(
                tooltip: 'Menu',
                onPressed: onMenuTap,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.menu_rounded,
                  color: AppColors.white,
                  size: 27,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Tática Manager',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Notícias',
                onPressed: onNotificationsTap,
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.white,
                  size: 25,
                ),
              ),
              const SizedBox(width: 2),
              _InboxButton(
                unreadMessages: unreadMessages,
                onTap: onInboxTap,
              ),
            ],
          ),
        ),
      );
}

class HomeClubHeader extends StatelessWidget {
  const HomeClubHeader({
    super.key,
    required this.club,
    required this.season,
    required this.balance,
    required this.transferBudget,
  });

  final Club club;
  final int season;
  final int balance;
  final int transferBudget;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(10, 3, 10, 3),
        child: Container(
          constraints: const BoxConstraints(minHeight: 104),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF102536), Color(0xFF0D2130), Color(0xFF0B1C29)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF203A49)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x32000000),
                blurRadius: 14,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              HomeClubCrest(club: club, size: 72),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      club.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Temporada $season',
                      maxLines: 1,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Row(
                      children: [
                        Icon(
                          Icons.public_rounded,
                          color: AppColors.textSecondary,
                          size: 17,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Nível Mundial',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderValueLine(
                    icon: Icons.account_balance_wallet_rounded,
                    color: Color(0xFF4FC43F),
                    value: compactMoney(balance),
                  ),
                  const SizedBox(height: 12),
                  _HeaderValueLine(
                    icon: Icons.monetization_on_rounded,
                    color: Color(0xFFF0B323),
                    value: compactMoney(transferBudget),
                  ),
                ],
              ),
            ],
          ),
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

class _InboxButton extends StatelessWidget {
  const _InboxButton({required this.unreadMessages, required this.onTap});

  final int unreadMessages;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: 'Caixa de entrada',
        onPressed: onTap,
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(
              Icons.mail_outline_rounded,
              color: AppColors.white,
              size: 25,
            ),
            if (unreadMessages > 0)
              Positioned(
                top: -7,
                right: -8,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.green,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: const Color(0xFF0A151D), width: 1.2),
                  ),
                  child: Text(
                    unreadMessages > 9 ? '9+' : '$unreadMessages',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
}

class _HeaderValueLine extends StatelessWidget {
  const _HeaderValueLine({
    required this.icon,
    required this.color,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
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
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        label,
                        maxLines: 1,
                        style: TextStyle(
                          color: accent,
                          fontSize: 9.8,
                          height: 1,
                          fontWeight: FontWeight.w900,
                        ),
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
                    fontSize: 14.5,
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
