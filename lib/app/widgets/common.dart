import 'dart:convert';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/club/club.dart';
import '../../domain/player/player.dart';
import 'player_avatar.dart';

class PremiumScaffold extends StatelessWidget {
  const PremiumScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.safeBottom = false,
    this.extendBody = false,
  });
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool safeBottom;
  final bool extendBody;

  @override
  Widget build(BuildContext context) => Scaffold(
        extendBody: extendBody,
        appBar: appBar,
        body: SafeArea(top: appBar == null, bottom: safeBottom, child: body),
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
      );
}

class GameTopBar extends StatelessWidget implements PreferredSizeWidget {
  const GameTopBar({super.key, required this.title, this.subtitle, this.actions = const []});
  final String title;
  final String? subtitle;
  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) => AppBar(
        titleSpacing: 16,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          if (subtitle != null) Text(subtitle!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted)),
        ]),
        actions: actions,
      );
}

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderColor,
  });
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets? margin;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) => Container(
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor ?? AppColors.border),
          boxShadow: const [BoxShadow(color: Color(0x30000000), blurRadius: 18, offset: Offset(0, 8))],
        ),
        child: child,
      );
}

class ClubBadge extends StatelessWidget {
  const ClubBadge({super.key, required this.club, this.size = 48});
  final Club club;
  final double size;

  @override
  Widget build(BuildContext context) {
    Widget fallback() => Text(
          club.shortName.length <= 3
              ? club.shortName
              : club.shortName.substring(0, 3),
          style: TextStyle(
            color: Colors.white,
            fontSize: size * .24,
            fontWeight: FontWeight.w900,
            shadows: const [Shadow(blurRadius: 3)],
          ),
        );

    final icon = club.iconBase64;
    final hasCustomIcon = icon?.isNotEmpty == true;
    Widget child = fallback();
    if (hasCustomIcon) {
      try {
        child = Padding(
          padding: EdgeInsets.all(size * .08),
          child: Image.memory(
            base64Decode(icon!),
            width: size * .84,
            height: size * .84,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, _, _) => Center(child: fallback()),
          ),
        );
      } catch (_) {
        child = fallback();
      }
    }

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: hasCustomIcon ? const Color(0xFFF4F4F4) : null,
        gradient: hasCustomIcon
            ? null
            : LinearGradient(
                colors: [
                  Color(club.colors.primaryHex),
                  Color(club.colors.secondaryHex),
                ],
              ),
        borderRadius: BorderRadius.circular(size * .28),
        border: Border.all(
          color: hasCustomIcon
              ? Colors.white.withValues(alpha: .55)
              : Colors.white.withValues(alpha: .22),
          width: 1.2,
        ),
      ),
      child: child,
    );
  }
}

class OverallShield extends StatelessWidget {
  const OverallShield({super.key, required this.value, this.compact = false});
  final int value;
  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
        width: compact ? 38 : 48,
        height: compact ? 38 : 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.green.withValues(alpha: .10),
          border: Border.all(color: AppColors.green, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text('$value', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w900, fontSize: compact ? 14 : 17)),
      );
}

class Metric extends StatelessWidget {
  const Metric({super.key, required this.label, required this.value, this.icon});
  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [if (icon != null) ...[Icon(icon, size: 15, color: AppColors.green), const SizedBox(width: 5)], Flexible(child: Text(label, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted)))]),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        ]),
      );
}

class PlayerRow extends StatelessWidget {
  const PlayerRow({
    super.key,
    required this.player,
    this.onTap,
    this.trailing,
    this.showAvatar = false,
    this.showCondition = false,
    this.avatarAccentColor = AppColors.green,
  });

  final Player player;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showAvatar;
  final bool showCondition;
  final Color avatarAccentColor;

  @override
  Widget build(BuildContext context) {
    final secondary = showCondition
        ? '${player.shirtNumber > 0 ? '#${player.shirtNumber} • ' : ''}${player.primaryPosition.label} • ${player.age} anos • Cond. ${player.condition}%'
        : '${player.shirtNumber > 0 ? '#${player.shirtNumber} • ' : ''}${player.primaryPosition.label} • ${player.age} anos • ${formatMoney(player.marketValue)}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            if (showAvatar) ...[
              PlayerAvatar(
                player: player,
                size: 42,
                accentColor: avatarAccentColor,
              ),
              const SizedBox(width: 9),
            ],
            OverallShield(value: player.overall, compact: true),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    secondary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: showCondition && player.condition < 60
                              ? AppColors.warning
                              : AppColors.muted,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            trailing ??
                Icon(
                  player.isAvailable
                      ? Icons.chevron_right_rounded
                      : Icons.healing_rounded,
                  color: player.isAvailable
                      ? AppColors.muted
                      : AppColors.warning,
                ),
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.text});
  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 54, color: AppColors.green),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(text, style: TextStyle(color: AppColors.muted), textAlign: TextAlign.center),
        ]),
      );
}
