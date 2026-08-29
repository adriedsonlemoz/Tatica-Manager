import 'package:flutter/material.dart';

import '../../app/widgets/common.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/club/club.dart';

class HomeCleanTopBar extends StatelessWidget {
  const HomeCleanTopBar({
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
  Widget build(BuildContext context) {
    final dark = AppColors.isDarkMode;
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: dark
              ? const [Color(0xFF123B31), Color(0xFF0E252A)]
              : const [Color(0xFF0F5B45), Color(0xFF123D39)],
        ),
      ),
      child: Row(
        children: [
          _TopIcon(icon: Icons.menu_rounded, onTap: onMenuTap),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Tática Manager',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: -.35,
              ),
            ),
          ),
          _TopIcon(icon: Icons.notifications_none_rounded, onTap: onNotificationsTap),
          const SizedBox(width: 4),
          Stack(
            clipBehavior: Clip.none,
            children: [
              _TopIcon(icon: Icons.mail_outline_rounded, onTap: onInboxTap),
              if (unreadMessages > 0)
                Positioned(
                  right: 0,
                  top: 2,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      unreadMessages > 9 ? '9+' : '$unreadMessages',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class HomeCleanClubCard extends StatelessWidget {
  const HomeCleanClubCard({
    super.key,
    required this.club,
    required this.season,
    required this.levelLabel,
  });

  final Club club;
  final int season;
  final String levelLabel;

  @override
  Widget build(BuildContext context) => _CleanCard(
        padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
        child: Row(
          children: [
            ClubBadge(club: club, size: 78),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    club.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -.55,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text('Temporada $season', style: TextStyle(color: AppColors.muted, fontSize: 13)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.public_rounded, size: 16, color: AppColors.muted),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          levelLabel,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: AppColors.muted, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _MoneyLine(
                  icon: Icons.payments_rounded,
                  value: formatMoney(club.money),
                  color: AppColors.green,
                ),
                const SizedBox(height: 7),
                _MoneyLine(
                  icon: Icons.swap_horiz_rounded,
                  value: formatMoney(club.transferBudget),
                  color: AppColors.warning,
                ),
              ],
            ),
          ],
        ),
      );
}

class HomeCleanPrimaryAction extends StatelessWidget {
  const HomeCleanPrimaryAction({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 54,
        width: double.infinity,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const SizedBox(width: 12),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .88),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppColors.greenDark,
                  size: 25,
                ),
              ),
            ],
          ),
        ),
      );
}

class HomeCleanModules extends StatelessWidget {
  const HomeCleanModules({super.key, required this.items});

  final List<HomeCleanModuleItem> items;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final columns = width >= 330 ? 6 : 3;
          final gap = 7.0;
          final itemWidth = (width - gap * (columns - 1)) / columns;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final item in items)
                SizedBox(width: itemWidth, child: _ModuleTile(item: item)),
            ],
          );
        },
      );
}

class HomeCleanModuleItem {
  const HomeCleanModuleItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.showDot = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool showDot;
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({required this.item});
  final HomeCleanModuleItem item;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: AppColors.isDarkMode ? .16 : .055),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item.icon, color: AppColors.greenDark, size: 25),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          item.label.toUpperCase(),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 8.4, fontWeight: FontWeight.w900, height: 1.05),
                        ),
                      ),
                    ],
                  ),
                ),
                if (item.showDot)
                  const Positioned(
                    right: 8,
                    top: 8,
                    child: CircleAvatar(radius: 4, backgroundColor: AppColors.danger),
                  ),
              ],
            ),
          ),
        ),
      );
}

class _MoneyLine extends StatelessWidget {
  const _MoneyLine({required this.icon, required this.value, required this.color});
  final IconData icon;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 19, color: color),
          const SizedBox(width: 7),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
        ],
      );
}

class _TopIcon extends StatelessWidget {
  const _TopIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => IconButton(
        onPressed: onTap,
        visualDensity: VisualDensity.compact,
        icon: Icon(icon, color: Colors.white, size: 27),
      );
}

class _CleanCard extends StatelessWidget {
  const _CleanCard({required this.child, this.padding = const EdgeInsets.all(14)});
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: AppColors.isDarkMode ? .18 : .06),
              blurRadius: 13,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: child,
      );
}
