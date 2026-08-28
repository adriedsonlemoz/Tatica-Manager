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
  });

  final List<CareerEvent> events;
  final Player? Function(String?) playerForEvent;
  final Color Function(Player) playerAccent;
  final ValueChanged<CareerEvent> onEventTap;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) => _DashboardCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DashboardSectionHeader(
              icon: Icons.newspaper_rounded,
              title: 'NOTÍCIAS & DESTAQUES',
              action: 'VER TODAS',
              onAction: onViewAll,
            ),
            const SizedBox(height: 8),
            if (events.isEmpty)
              SizedBox(
                height: 92,
                child: Center(
                  child: Text(
                    'Avance os dias para receber notícias, treinos, contratos e eventos do clube.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted, fontSize: 10.5),
                  ),
                ),
              )
            else
              Column(
                children: [
                  for (var index = 0; index < events.length; index++) ...[
                    _NewsListTile(
                      event: events[index],
                      player: playerForEvent(events[index].playerId),
                      playerAccent: playerForEvent(events[index].playerId) == null
                          ? AppColors.green
                          : playerAccent(playerForEvent(events[index].playerId)!),
                      onTap: () => onEventTap(events[index]),
                    ),
                    if (index != events.length - 1)
                      Divider(
                        height: 1,
                        color: AppColors.border.withValues(alpha: .65),
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
          final useRow = items.length <= 5 && constraints.maxWidth >= 290;
          if (!useRow) {
            return SizedBox(
              height: 76,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(width: 7),
                itemBuilder: (context, index) => SizedBox(
                  width: 88,
                  child: _QuickAccessTile(item: items[index]),
                ),
              ),
            );
          }
          return Row(
            children: [
              for (var index = 0; index < items.length; index++) ...[
                Expanded(child: _QuickAccessTile(item: items[index])),
                if (index != items.length - 1) const SizedBox(width: 7),
              ],
            ],
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
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color accent;
}

class _QuickAccessTile extends StatelessWidget {
  const _QuickAccessTile({required this.item});

  final HomeQuickAccessItem item;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            height: 76,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  item.accent.withValues(alpha: .16),
                  AppColors.surfaceRaised,
                  AppColors.background,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: item.accent.withValues(alpha: .24)),
              boxShadow: const [
                BoxShadow(color: Color(0x22000000), blurRadius: 10, offset: Offset(0, 4)),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        item.accent.withValues(alpha: .85),
                        item.accent.withValues(alpha: .42),
                      ],
                    ),
                  ),
                  child: Icon(item.icon, color: AppColors.white, size: 18),
                ),
                const SizedBox(height: 6),
                Text(
                  item.label,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 8.8, fontWeight: FontWeight.w800, height: 1.1),
                ),
              ],
            ),
          ),
        ),
      );
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF132231), Color(0xFF10202A), Color(0xFF0E181F)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border.withValues(alpha: .92)),
          boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 12, offset: Offset(0, 5))],
        ),
        child: child,
      );
}

class _DashboardSectionHeader extends StatelessWidget {
  const _DashboardSectionHeader({required this.title, this.icon, this.action, this.onAction});

  final String title;
  final IconData? icon;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.green, size: 17),
            const SizedBox(width: 5),
          ],
          Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9.3, fontWeight: FontWeight.w900))),
          if (action != null)
            InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                child: Row(
                  children: [
                    Text(action!, style: const TextStyle(color: AppColors.green, fontSize: 7.4, fontWeight: FontWeight.w900)),
                    const SizedBox(width: 1),
                    const Icon(Icons.arrow_forward_rounded, size: 12, color: AppColors.green),
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
    required this.onTap,
  });

  final CareerEvent event;
  final Player? player;
  final Color playerAccent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: player != null
                    ? PlayerAvatar(player: player!, size: 38, accentColor: playerAccent)
                    : Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: playerAccent.withValues(alpha: .16),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(_newsIcon(event.type), color: playerAccent, size: 19),
                      ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(color: playerAccent, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            event.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 9.2, fontWeight: FontWeight.w900),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          shortDate(event.date),
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 7.5, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      event.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 8.3, color: AppColors.muted, height: 1.2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  static IconData _newsIcon(CareerEventType type) => switch (type) {
        CareerEventType.playerRecovered || CareerEventType.injuryEnded => Icons.healing_rounded,
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
