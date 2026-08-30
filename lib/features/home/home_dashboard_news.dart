import 'package:flutter/material.dart';

import '../../app/widgets/player_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/player/player.dart';
import '../../domain/season/career_event.dart';

class HomeNewsHighlights extends StatelessWidget {
  const HomeNewsHighlights({
    super.key,
    required this.events,
    required this.playerForEvent,
    required this.playerAccent,
    required this.onEventTap,
    required this.onViewAll,
    this.compact = false,
  });

  final List<CareerEvent> events;
  final Player? Function(String?) playerForEvent;
  final Color Function(Player) playerAccent;
  final ValueChanged<CareerEvent> onEventTap;
  final VoidCallback onViewAll;
  final bool compact;

  @override
  Widget build(BuildContext context) => _DashboardCard(
        compact: compact,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DashboardSectionHeader(
              icon: Icons.newspaper_rounded,
              title: 'NOTÍCIAS E DESTAQUES',
              action: 'VER TODAS',
              onAction: onViewAll,
              compact: compact,
            ),
            SizedBox(height: compact ? 4 : 8),
            if (events.isEmpty)
              SizedBox(
                height: compact ? 112 : 92,
                child: Center(
                  child: Text(
                    'Avance os dias para receber notícias, treinos, contratos e eventos do clube.',
                    textAlign: TextAlign.center,
                    maxLines: compact ? 4 : 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: compact ? 11.2 : 13.5,
                      height: 1.25,
                    ),
                  ),
                ),
              )
            else
              Column(
                children: [
                  for (var index = 0; index < events.length; index++) ...[
                    Builder(
                      builder: (context) {
                        final event = events[index];
                        final player = playerForEvent(event.playerId);
                        return _NewsListTile(
                          event: event,
                          player: player,
                          playerAccent: player == null
                              ? _newsColor(event.type)
                              : playerAccent(player),
                          compact: compact,
                          onTap: () => onEventTap(event),
                        );
                      },
                    ),
                    if (index != events.length - 1)
                      Divider(
                        height: 1,
                        color: AppColors.border.withValues(alpha: .58),
                      ),
                  ],
                ],
              ),
          ],
        ),
      );
}

class HomeQuickAccess extends StatelessWidget {
  const HomeQuickAccess({
    super.key,
    required this.items,
  });

  final List<HomeQuickAccessItem> items;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final useRow = items.length <= 6 && constraints.maxWidth >= 300;
          if (!useRow) {
            return SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(width: 6),
                itemBuilder: (context, index) => SizedBox(
                  width: 82,
                  child: _QuickAccessTile(item: items[index]),
                ),
              ),
            );
          }
          return SizedBox(
            height: 72,
            child: Row(
              children: [
                for (var index = 0; index < items.length; index++) ...[
                  Expanded(child: _QuickAccessTile(item: items[index])),
                  if (index != items.length - 1) const SizedBox(width: 6),
                ],
              ],
            ),
          );
        },
      );
}

class HomeQuickAccessItem {
  const HomeQuickAccessItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.accent = AppColors.green,
    this.showDot = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color accent;
  final bool showDot;
}

class _QuickAccessTile extends StatelessWidget {
  const _QuickAccessTile({required this.item});

  final HomeQuickAccessItem item;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.circular(12),
                child: Ink(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 7),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF142838), Color(0xFF102330)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF29414E)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.icon, color: AppColors.white, size: 28),
                      const SizedBox(height: 7),
                      SizedBox(
                        height: 15,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            item.label.toUpperCase(),
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 10.2,
                              fontWeight: FontWeight.w700,
                              letterSpacing: .05,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (item.showDot)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: item.accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF102330), width: 1),
                  ),
                ),
              ),
          ],
        ),
      );
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({required this.child, required this.compact});

  final Widget child;
  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.all(compact ? 8 : 11),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF132231), Color(0xFF10202A), Color(0xFF0E181F)],
          ),
          borderRadius: BorderRadius.circular(compact ? 14 : 18),
          border: Border.all(color: AppColors.border.withValues(alpha: .86)),
          boxShadow: const [BoxShadow(color: Color(0x1E000000), blurRadius: 9, offset: Offset(0, 4))],
        ),
        child: child,
      );
}

class _DashboardSectionHeader extends StatelessWidget {
  const _DashboardSectionHeader({
    required this.title,
    required this.compact,
    this.icon,
    this.action,
    this.onAction,
  });

  final String title;
  final IconData? icon;
  final String? action;
  final VoidCallback? onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.green, size: compact ? 13 : 17),
            SizedBox(width: compact ? 3 : 5),
          ],
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: compact ? 11.8 : 12.3, fontWeight: FontWeight.w900),
            ),
          ),
          if (action != null)
            InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                child: Row(
                  children: [
                    Text(
                      action!,
                      style: TextStyle(
                        color: AppColors.green,
                        fontSize: compact ? 9.8 : 10.4,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 1),
                    Icon(Icons.arrow_forward_rounded, size: compact ? 10 : 12, color: AppColors.green),
                  ],
                ),
              ),
            ),
        ],
      );
}

class _NewsListTile extends StatelessWidget {
  const _NewsListTile({
    required this.event,
    required this.player,
    required this.playerAccent,
    required this.compact,
    required this.onTap,
  });

  final CareerEvent event;
  final Player? player;
  final Color playerAccent;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              const Icon(
                Icons.article_outlined,
                color: AppColors.textSecondary,
                size: 18,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  event.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 10.8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                shortDate(event.date),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 1),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: player != null
                  ? PlayerAvatar(
                      player: player!,
                      size: 38,
                      accentColor: playerAccent,
                    )
                  : Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: playerAccent.withValues(alpha: .16),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _newsIcon(event.type),
                        color: playerAccent,
                        size: 19,
                      ),
                    ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.2,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        shortDate(event.date),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    event.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.3,
                      color: AppColors.muted,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static IconData _newsIcon(CareerEventType type) => switch (type) {
        CareerEventType.playerRecovered || CareerEventType.injuryEnded =>
          Icons.healing_rounded,
        CareerEventType.suspensionEnded => Icons.gavel_rounded,
        CareerEventType.contractExpiring => Icons.description_rounded,
        CareerEventType.transferOffer => Icons.swap_horiz_rounded,
        CareerEventType.managerOffer => Icons.business_center_rounded,
        CareerEventType.nextMatch => Icons.sports_soccer_rounded,
        CareerEventType.training => Icons.fitness_center_rounded,
        CareerEventType.seasonStarted => Icons.emoji_events_rounded,
        CareerEventType.info => Icons.info_outline_rounded,
      };
}

Color _newsColor(CareerEventType type) => switch (type) {
      CareerEventType.transferOffer => const Color(0xFF64C9FF),
      CareerEventType.training => const Color(0xFFE6A82C),
      CareerEventType.playerRecovered || CareerEventType.injuryEnded => const Color(0xFF41C8B4),
      CareerEventType.contractExpiring => AppColors.warning,
      _ => AppColors.green,
    };
