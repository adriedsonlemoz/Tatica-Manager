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
            const SizedBox(height: 10),
            if (events.isEmpty)
              SizedBox(
                height: 92,
                child: Center(
                  child: Text(
                    'Avance os dias para receber notícias, treinos, contratos e eventos do clube.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted, fontSize: 11),
                  ),
                ),
              )
            else
              SizedBox(
                height: 142,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: events.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 7),
                  itemBuilder: (context, index) {
                    final event = events[index];
                    final player = playerForEvent(event.playerId);
                    return _NewsTile(
                      event: event,
                      player: player,
                      playerAccent: player == null ? AppColors.green : playerAccent(player),
                      onTap: () => onEventTap(event),
                    );
                  },
                ),
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
  Widget build(BuildContext context) => SizedBox(
        height: 60,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: 7),
          itemBuilder: (context, index) {
            final item = items[index];
            return InkWell(
              onTap: item.onTap,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 88,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C1312),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item.icon, color: AppColors.green, size: 20),
                    const SizedBox(height: 3),
                    Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            );
          },
        ),
      );
}

class HomeQuickAccessItem {
  const HomeQuickAccessItem({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}


class _DashboardCard extends StatelessWidget {
  const _DashboardCard({required this.child, this.padding = const EdgeInsets.all(12)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: const Color(0xFF091110),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF25302F)),
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
            Icon(icon, color: AppColors.green, size: 18),
            const SizedBox(width: 6),
          ],
          Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900))),
          if (action != null)
            InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                child: Row(
                  children: [
                    Text(action!, style: const TextStyle(color: AppColors.green, fontSize: 8, fontWeight: FontWeight.w900)),
                    const SizedBox(width: 2),
                    const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.green),
                  ],
                ),
              ),
            ),
        ],
      );
}

class _NewsTile extends StatelessWidget {
  const _NewsTile({required this.event, required this.player, required this.playerAccent, required this.onTap});

  final CareerEvent event;
  final Player? player;
  final Color playerAccent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          width: 132,
          decoration: BoxDecoration(
            color: const Color(0xFF101817),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 64,
                width: double.infinity,
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [playerAccent.withValues(alpha: .38), const Color(0xFF09100F)],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (player != null)
                      PlayerAvatar(player: player!, size: 48, accentColor: playerAccent)
                    else
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: AppColors.green.withValues(alpha: .12), borderRadius: BorderRadius.circular(12)),
                        child: Icon(_newsIcon(event.type), color: AppColors.green, size: 23),
                      ),
                    const Spacer(),
                    Text(_newsCategory(event.type), style: const TextStyle(color: AppColors.green, fontSize: 7, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 7, 8, 5),
                child: Text(event.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, height: 1.2)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(event.message, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 8, color: AppColors.muted, height: 1.2)),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 7),
                child: Text(shortDate(event.date), style: const TextStyle(color: AppColors.green, fontSize: 7, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
      );

  static String _newsCategory(CareerEventType type) => switch (type) {
        CareerEventType.training => 'TREINO',
        CareerEventType.transferOffer => 'MERCADO',
        CareerEventType.contractExpiring => 'ELENCO',
        CareerEventType.managerOffer => 'CLUBE',
        CareerEventType.nextMatch => 'PARTIDA',
        CareerEventType.playerRecovered || CareerEventType.injuryEnded => 'MÉDICO',
        CareerEventType.suspensionEnded => 'ELENCO',
        CareerEventType.seasonStarted => 'CLUBE',
        CareerEventType.info => 'NOTÍCIA',
      };

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

