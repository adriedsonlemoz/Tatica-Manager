import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/country_catalog.dart';
import '../../domain/club/club.dart';
import '../../domain/player/player.dart';
import 'common.dart';
import 'player_avatar.dart';
import 'player_status_strip.dart';

enum PlayerCardSize { compact, medium, detailed }

class PlayerCard extends StatelessWidget {
  const PlayerCard({
    super.key,
    required this.player,
    required this.club,
    this.size = PlayerCardSize.medium,
    this.onTap,
    this.effectiveOverall,
    this.lineupLabel,
    this.showStatus = true,
  });

  final Player player;
  final Club? club;
  final PlayerCardSize size;
  final VoidCallback? onTap;
  final int? effectiveOverall;
  final String? lineupLabel;
  final bool showStatus;

  @override
  Widget build(BuildContext context) {
    final accent = Color(club?.colors.primaryHex ?? 0xFF1E7A2B);
    final avatarSize = switch (size) {
      PlayerCardSize.compact => 58.0,
      PlayerCardSize.medium => 82.0,
      PlayerCardSize.detailed => 112.0,
    };
    final displayedOverall = effectiveOverall ?? player.overall;
    final penalized = effectiveOverall != null && effectiveOverall != player.overall;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: EdgeInsets.all(size == PlayerCardSize.compact ? 10 : 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accent.withValues(alpha: .34)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(AppColors.surfaceRaised, accent, .15)!,
                AppColors.surface,
              ],
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  PlayerAvatar(
                    player: player,
                    size: avatarSize,
                    accentColor: accent,
                  ),
                  Positioned(
                    right: -5,
                    top: -5,
                    child: _OverallBadge(
                      value: displayedOverall,
                      baseValue: penalized ? player.overall : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PlayerCardInfo(
                  player: player,
                  club: club,
                  size: size,
                  lineupLabel: lineupLabel,
                  showStatus: showStatus,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerCardInfo extends StatelessWidget {
  const _PlayerCardInfo({
    required this.player,
    required this.club,
    required this.size,
    required this.lineupLabel,
    required this.showStatus,
  });

  final Player player;
  final Club? club;
  final PlayerCardSize size;
  final String? lineupLabel;
  final bool showStatus;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  player.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: size == PlayerCardSize.compact ? 13 : 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  player.primaryPosition.label,
                  style: const TextStyle(
                    color: AppColors.green,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${CountryCatalog.flagOf(player.nationality)} ${player.nationality} • ${player.age} anos',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:  TextStyle(color: AppColors.muted, fontSize: 10),
          ),
          if (showStatus) ...[
            const SizedBox(height: 7),
            PlayerStatusStrip(
              player: player,
              lineupLabel: lineupLabel,
              compact: size != PlayerCardSize.detailed,
            ),
          ],
          if (club != null && size != PlayerCardSize.compact) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                ClubBadge(club: club!, size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    club!.shortName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ],
          if (size == PlayerCardSize.detailed) ...[
            const SizedBox(height: 9),
            Wrap(
              spacing: 6,
              runSpacing: 5,
              children: [
                _Chip('MOR ${player.morale}%'),
                _Chip(formatMoney(player.marketValue)),
                _Chip('${formatMoney(player.salary)}/mês'),
              ],
            ),
          ],
        ],
      );
}

class _OverallBadge extends StatelessWidget {
  const _OverallBadge({required this.value, this.baseValue});

  final int value;
  final int? baseValue;

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.background,
          border: Border.all(
            color: baseValue == null ? AppColors.green : AppColors.warning,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$value',
              style: TextStyle(
                color: baseValue == null ? null : AppColors.warning,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (baseValue != null)
              Text(
                '$baseValue',
                style:  TextStyle(
                  color: AppColors.muted,
                  fontSize: 7,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
          ],
        ),
      );
}

class _Chip extends StatelessWidget {
  const _Chip(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .055),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800),
        ),
      );
}
