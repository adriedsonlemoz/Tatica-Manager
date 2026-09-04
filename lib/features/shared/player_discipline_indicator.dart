import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/player/player.dart';

class PlayerDisciplineIndicator extends StatelessWidget {
  const PlayerDisciplineIndicator({
    super.key,
    required this.discipline,
    this.compact = false,
    this.showClear = true,
  });

  final PlayerDiscipline discipline;
  final bool compact;
  final bool showClear;

  @override
  Widget build(BuildContext context) {
    if (discipline.isSuspended) {
      return _StatusChip(
        icon: Icons.gavel_rounded,
        label: compact ? '${discipline.suspendedRounds}J' : 'Suspenso ${discipline.suspendedRounds}J',
        color: AppColors.danger,
        compact: compact,
      );
    }
    if (discipline.yellowCards > 0 || discipline.redCards > 0) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (discipline.yellowCards > 0)
            _CardValue(
              value: discipline.yellowCards,
              color: AppColors.warning,
              emphasized: discipline.isAtRisk,
              compact: compact,
            ),
          if (discipline.yellowCards > 0 && discipline.redCards > 0)
            SizedBox(width: compact ? 3 : 5),
          if (discipline.redCards > 0)
            _CardValue(
              value: discipline.redCards,
              color: AppColors.danger,
              compact: compact,
            ),
        ],
      );
    }
    if (!showClear) return const SizedBox.shrink();
    return Text(
      '—',
      style: TextStyle(
        color: AppColors.muted.withValues(alpha: .65),
        fontSize: compact ? 8 : 11,
      ),
    );
  }
}

class _CardValue extends StatelessWidget {
  const _CardValue({
    required this.value,
    required this.color,
    required this.compact,
    this.emphasized = false,
  });

  final int value;
  final Color color;
  final bool compact;
  final bool emphasized;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 3 : 5,
          vertical: compact ? 2 : 3,
        ),
        decoration: BoxDecoration(
          color: emphasized ? color.withValues(alpha: .16) : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
          border: emphasized
              ? Border.all(color: color.withValues(alpha: .55))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.rotate(
              angle: -.06,
              child: Container(
                width: compact ? 6 : 8,
                height: compact ? 9 : 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(1.2),
                ),
              ),
            ),
            SizedBox(width: compact ? 2 : 4),
            Text(
              '$value',
              style: TextStyle(
                color: emphasized ? color : AppColors.white,
                fontSize: compact ? 7.5 : 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      );
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.compact,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 4 : 7,
          vertical: compact ? 2 : 4,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .13),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: .50)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: compact ? 8 : 12, color: color),
            SizedBox(width: compact ? 2 : 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: compact ? 7 : 9.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      );
}

String playerAvailabilityReason(
  Player player,
  PlayerDiscipline discipline,
) {
  if (player.injury != null) {
    return '${player.injury!.name} • ${player.injury!.roundsRemaining} rod.';
  }
  if (discipline.isSuspended) {
    return 'Suspenso • ${discipline.suspendedRounds} jogo(s)';
  }
  if (player.condition < 35) return 'Condição física ${player.condition}%';
  return 'Disponível';
}
