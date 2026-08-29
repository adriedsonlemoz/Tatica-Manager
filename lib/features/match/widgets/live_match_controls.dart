import 'dart:math';

import 'package:flutter/material.dart';

import '../../../app/widgets/common.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/match/match_models.dart';

class LiveMatchControlBar extends StatelessWidget {
  const LiveMatchControlBar({
    super.key,
    required this.paused,
    required this.enabled,
    required this.onPauseToggle,
    required this.onSimulate,
    required this.soundEnabled,
    required this.onSoundToggle,
    required this.onTactic,
    required this.onSubstitution,
  });

  final bool paused;
  final bool enabled;
  final VoidCallback onPauseToggle;
  final VoidCallback onSimulate;
  final bool soundEnabled;
  final VoidCallback onSoundToggle;
  final VoidCallback onTactic;
  final VoidCallback onSubstitution;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            _MatchActionButton(
              icon: paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
              label: paused ? 'CONTINUAR' : 'PAUSAR',
              selected: paused,
              onTap: enabled ? onPauseToggle : null,
            ),
            _MatchActionButton(
              icon: Icons.fast_forward_rounded,
              label: 'SIMULAR',
              onTap: enabled ? onSimulate : null,
            ),
            _MatchActionButton(
              icon: Icons.tune_rounded,
              label: 'TÁTICA',
              onTap: enabled ? onTactic : null,
            ),
            _MatchActionButton(
              icon: Icons.swap_vert_rounded,
              label: 'TROCAR',
              onTap: enabled ? onSubstitution : null,
            ),
            _MatchActionButton(
              icon: soundEnabled
                  ? Icons.volume_up_rounded
                  : Icons.volume_off_rounded,
              label: soundEnabled ? 'ÁUDIO' : 'MUDO',
              selected: !soundEnabled,
              onTap: onSoundToggle,
            ),
          ],
        ),
      );
}

class LiveMatchStatsCard extends StatelessWidget {
  const LiveMatchStatsCard({
    super.key,
    required this.events,
    required this.minute,
    required this.homeId,
    required this.awayId,
    this.throughSequence,
  });

  final List<MatchEvent> events;
  final int minute;
  final String homeId;
  final String awayId;
  final int? throughSequence;

  @override
  Widget build(BuildContext context) {
    final homeShots = _count(MatchEventType.shot, homeId);
    final awayShots = _count(MatchEventType.shot, awayId);
    final homeGoals = _goals(homeId);
    final awayGoals = _goals(awayId);
    final homeOnTarget = min(
      homeShots,
      homeGoals + _count(MatchEventType.save, awayId),
    );
    final awayOnTarget = min(
      awayShots,
      awayGoals + _count(MatchEventType.save, homeId),
    );
    final possession = _visiblePossession();
    final homeCards = _count(MatchEventType.yellow, homeId) +
        _count(MatchEventType.red, homeId);
    final awayCards = _count(MatchEventType.yellow, awayId) +
        _count(MatchEventType.red, awayId);

    return SectionCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      child: Row(
        children: [
          _MiniStat(
            label: 'POSSE DE BOLA',
            home: '${possession.$1}%',
            away: '${possession.$2}%',
          ),
          const _MiniDivider(),
          _MiniStat(label: 'CHUTES', home: '$homeShots', away: '$awayShots'),
          const _MiniDivider(),
          _MiniStat(
            label: 'CHUTES NO GOL',
            home: '$homeOnTarget',
            away: '$awayOnTarget',
          ),
          const _MiniDivider(),
          _MiniStat(label: 'CARTÕES', home: '$homeCards', away: '$awayCards'),
        ],
      ),
    );
  }

  int _count(MatchEventType type, String teamId) => events
      .where(
        (event) =>
            _isVisible(event) &&
            event.teamId == teamId &&
            event.type == type,
      )
      .length;

  int _goals(String teamId) => events
      .where(
        (event) =>
            _isVisible(event) &&
            event.teamId == teamId &&
            (event.type == MatchEventType.goal ||
                event.type == MatchEventType.ownGoal),
      )
      .length;

  bool _isVisible(MatchEvent event) =>
      event.minute < minute ||
      (event.minute == minute &&
          (throughSequence == null || event.sequence <= throughSequence!));

  (int, int) _visiblePossession() {
    final homeTouches = events
        .where(
          (event) =>
              _isVisible(event) &&
              event.teamId == homeId &&
              (event.type == MatchEventType.pass ||
                  event.type == MatchEventType.possession),
        )
        .length;
    final awayTouches = events
        .where(
          (event) =>
              _isVisible(event) &&
              event.teamId == awayId &&
              (event.type == MatchEventType.pass ||
                  event.type == MatchEventType.possession),
        )
        .length;
    final total = homeTouches + awayTouches;
    if (total == 0) return (50, 50);
    final homeShare = (homeTouches * 100 / total).round();
    return (homeShare, 100 - homeShare);
  }
}

class _MatchActionButton extends StatelessWidget {
  const _MatchActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              minimumSize: const Size(0, 56),
              foregroundColor: selected ? AppColors.green : null,
              backgroundColor:
                  selected ? AppColors.green.withValues(alpha: .10) : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20),
                const SizedBox(height: 1),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 8.8, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ),
      );
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.home,
    required this.away,
  });

  final String label;
  final String home;
  final String away;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: .3,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '$home  •  $away',
              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      );
}

class _MiniDivider extends StatelessWidget {
  const _MiniDivider();

  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 24,
        color: AppColors.border,
      );
}
