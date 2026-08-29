import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/player/player.dart';

class PlayerStatusStrip extends StatelessWidget {
  const PlayerStatusStrip({
    super.key,
    required this.player,
    this.compact = true,
    this.showNationality = false,
    this.lineupLabel,
  });

  final Player player;
  final bool compact;
  final bool showNationality;
  final String? lineupLabel;

  @override
  Widget build(BuildContext context) {
    final form = player.recentFormAverage;
    final items = <Widget>[
      if (lineupLabel != null) _chip(Icons.groups_2_rounded, lineupLabel!),
      if (showNationality && player.nationality.trim().isNotEmpty)
        _chip(Icons.flag_outlined, player.nationality),
      _chip(
        Icons.favorite_rounded,
        '${player.condition}%',
        player.condition < 60 ? AppColors.warning : AppColors.green,
      ),
      _chip(
        Icons.battery_3_bar_rounded,
        'Fad. ${player.fatigue}%',
        player.fatigue > 65 ? AppColors.warning : AppColors.muted,
      ),
      _chip(
        Icons.show_chart_rounded,
        form == null ? 'Forma —' : 'Forma ${form.toStringAsFixed(1)}',
      ),
      if (player.discipline.yellowCards > 0)
        _chip(
          Icons.style_rounded,
          '🟨 ${player.discipline.yellowCards}/3',
          player.discipline.yellowCards >= 2 ? AppColors.warning : AppColors.muted,
        ),
      if (player.discipline.yellowCards == 2)
        _chip(Icons.warning_amber_rounded, '1 da suspensão', AppColors.warning),
      if (player.discipline.redCards > 0)
        _chip(Icons.style_rounded, '🟥 ${player.discipline.redCards}', AppColors.danger),
      if (player.injury != null)
        _chip(Icons.medical_information_outlined, player.injury!.name, AppColors.danger),
      if (player.discipline.suspendedRounds > 0)
        _chip(Icons.block_rounded, 'Suspenso', AppColors.warning),
    ];
    return Wrap(
      spacing: compact ? 5 : 7,
      runSpacing: compact ? 4 : 6,
      children: items,
    );
  }

  Widget _chip(IconData icon, String label, [Color? color]) =>
      Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 8,
          vertical: compact ? 3 : 4,
        ),
        decoration: BoxDecoration(
          color: (color ?? AppColors.muted).withValues(alpha: .10),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: (color ?? AppColors.muted).withValues(alpha: .22)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: compact ? 10 : 12, color: color),
            const SizedBox(width: 3),
            Text(
              label,
              style: TextStyle(
                color: color ?? AppColors.muted,
                fontSize: compact ? 8.5 : 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
}
