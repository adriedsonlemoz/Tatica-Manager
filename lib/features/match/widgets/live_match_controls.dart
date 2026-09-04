import 'dart:math';

import 'package:flutter/material.dart';

import '../../../app/widgets/common.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/match/match_models.dart';
import '../live_match_statistics.dart';

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
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF101B22), Color(0xFF152329), Color(0xFF101B22)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(color: Color(0x28000000), blurRadius: 12, offset: Offset(0, 5)),
          ],
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
              icon: Icons.swap_horiz_rounded,
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
    required this.homeColor,
    required this.awayColor,
    required this.targetHomePossession,
    this.throughSequence,
  });

  final List<MatchEvent> events;
  final int minute;
  final String homeId;
  final String awayId;
  final Color homeColor;
  final Color awayColor;
  final int targetHomePossession;
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
    final possession = LiveMatchStatistics.possession(
      events: events,
      minute: minute,
      homeId: homeId,
      awayId: awayId,
      targetHomePossession: targetHomePossession,
      throughSequence: throughSequence,
    );
    final homeYellow = _count(MatchEventType.yellow, homeId);
    final awayYellow = _count(MatchEventType.yellow, awayId);
    final homeRed = _count(MatchEventType.red, homeId);
    final awayRed = _count(MatchEventType.red, awayId);

    return SectionCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 13,
            child: _PossessionStat(
              home: possession.$1,
              away: possession.$2,
              homeColor: homeColor,
              awayColor: awayColor,
            ),
          ),
          const _MiniDivider(),
          Expanded(
            flex: 10,
            child: _VersusStat(
              label: 'CHUTES',
              home: homeShots,
              away: awayShots,
              homeColor: homeColor,
              awayColor: awayColor,
            ),
          ),
          const _MiniDivider(),
          Expanded(
            flex: 12,
            child: _VersusStat(
              label: 'CHUTES NO GOL',
              home: homeOnTarget,
              away: awayOnTarget,
              homeColor: homeColor,
              awayColor: awayColor,
            ),
          ),
          const _MiniDivider(),
          Expanded(
            flex: 10,
            child: _CardsStat(
              homeYellow: homeYellow,
              awayYellow: awayYellow,
              homeRed: homeRed,
              awayRed: awayRed,
              homeColor: homeColor,
              awayColor: awayColor,
            ),
          ),
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
              padding: const EdgeInsets.symmetric(horizontal: 3),
              minimumSize: const Size(0, 52),
              foregroundColor: AppColors.green,
              backgroundColor: selected
                  ? AppColors.green.withValues(alpha: .10)
                  : const Color(0xFF142128),
              side: BorderSide(
                color: selected
                    ? AppColors.green.withValues(alpha: .55)
                    : AppColors.border,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _PossessionStat extends StatelessWidget {
  const _PossessionStat({
    required this.home,
    required this.away,
    required this.homeColor,
    required this.awayColor,
  });

  final int home;
  final int away;
  final Color homeColor;
  final Color awayColor;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'POSSE DE BOLA',
            maxLines: 1,
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 8.8,
              fontWeight: FontWeight.w900,
              letterSpacing: .3,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$home%',
                style: TextStyle(
                  color: AppColors.readableAccent(homeColor),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 36,
                height: 36,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: home / 100,
                        strokeWidth: 7,
                        backgroundColor: AppColors.readableAccent(awayColor),
                        color: AppColors.readableAccent(homeColor),
                      ),
                    ),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Color(0xFF101A20),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$away%',
                style: TextStyle(
                  color: AppColors.readableAccent(awayColor),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      );
}

class _VersusStat extends StatelessWidget {
  const _VersusStat({
    required this.label,
    required this.home,
    required this.away,
    required this.homeColor,
    required this.awayColor,
  });

  final String label;
  final int home;
  final int away;
  final Color homeColor;
  final Color awayColor;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 8.5,
              fontWeight: FontWeight.w900,
              letterSpacing: .25,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$home',
                style: TextStyle(
                  color: AppColors.readableAccent(homeColor),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 7),
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                '$away',
                style: TextStyle(
                  color: AppColors.readableAccent(awayColor),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      );
}

class _CardsStat extends StatelessWidget {
  const _CardsStat({
    required this.homeYellow,
    required this.awayYellow,
    required this.homeRed,
    required this.awayRed,
    required this.homeColor,
    required this.awayColor,
  });

  final int homeYellow;
  final int awayYellow;
  final int homeRed;
  final int awayRed;
  final Color homeColor;
  final Color awayColor;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'CARTÕES',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 8.8,
              fontWeight: FontWeight.w900,
              letterSpacing: .3,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _TeamCards(
                teamColor: homeColor,
                yellow: homeYellow,
                red: homeRed,
              ),
              const SizedBox(width: 7),
              _TeamCards(
                teamColor: awayColor,
                yellow: awayYellow,
                red: awayRed,
              ),
            ],
          ),
        ],
      );
}

class _TeamCards extends StatelessWidget {
  const _TeamCards({
    required this.teamColor,
    required this.yellow,
    required this.red,
  });

  final Color teamColor;
  final int yellow;
  final int red;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 3,
            decoration: BoxDecoration(
              color: AppColors.readableAccent(teamColor),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CardCount(color: AppColors.warning, value: yellow),
              if (red > 0) ...[
                const SizedBox(width: 3),
                _CardCount(color: AppColors.danger, value: red),
              ],
            ],
          ),
        ],
      );
}

class _CardCount extends StatelessWidget {
  const _CardCount({required this.color, required this.value});

  final Color color;
  final int value;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 18,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: .28), blurRadius: 5),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$value',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
          ),
        ],
      );
}

class _MiniDivider extends StatelessWidget {
  const _MiniDivider();

  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 42,
        color: AppColors.border,
      );
}
