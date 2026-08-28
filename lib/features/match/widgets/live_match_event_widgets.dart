import 'package:flutter/material.dart';

import '../../../app/widgets/player_avatar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/match/match_models.dart';
import '../../../domain/player/player.dart';
import '../match_event_presentation.dart';

class LiveMatchMomentCard extends StatelessWidget {
  const LiveMatchMomentCard({
    super.key,
    required this.event,
    required this.teamName,
    this.player,
    this.secondaryPlayer,
  });

  final MatchEvent event;
  final String teamName;
  final Player? player;
  final Player? secondaryPlayer;

  @override
  Widget build(BuildContext context) {
    final color = matchEventColor(event.type);
    final major = MatchEventPresentation.isMajor(event.type);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.fromLTRB(11, 9, 11, 9),
      decoration: BoxDecoration(
        color: major ? color.withValues(alpha: .09) : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: major ? color.withValues(alpha: .52) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          if (player != null)
            PlayerAvatar(
              player: player!,
              size: 42,
              accentColor: color,
            )
          else
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(matchEventIcon(event.type), color: color, size: 22),
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        MatchEventPresentation.headline(event.type, teamName),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: major ? color : AppColors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "${event.minute}'",
                      style: const TextStyle(
                        color: AppColors.green,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  MatchEventPresentation.narration(event, teamName),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                    height: 1.25,
                  ),
                ),
                if (event.type == MatchEventType.substitution &&
                    secondaryPlayer != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Sai ${secondaryPlayer!.displayName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MatchNarrationTile extends StatelessWidget {
  const MatchNarrationTile({
    super.key,
    required this.event,
    required this.teamName,
    this.player,
  });

  final MatchEvent event;
  final String teamName;
  final Player? player;

  @override
  Widget build(BuildContext context) {
    final color = matchEventColor(event.type);
    final major = MatchEventPresentation.isMajor(event.type);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 34,
            child: Text(
              "${event.minute}'",
              style: TextStyle(
                color: major ? color : AppColors.green,
                fontWeight: FontWeight.w900,
                fontSize: 11.5,
              ),
            ),
          ),
          Container(
            width: 27,
            height: 27,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(matchEventIcon(event.type), size: 15, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  MatchEventPresentation.headline(event.type, teamName),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 10.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  MatchEventPresentation.narration(event, teamName),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.25,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (player != null) ...[
            const SizedBox(width: 7),
            PlayerAvatar(
              player: player!,
              size: 31,
              accentColor: color,
            ),
          ],
        ],
      ),
    );
  }
}

IconData matchEventIcon(MatchEventType type) => switch (type) {
      MatchEventType.kickoff => Icons.play_arrow_rounded,
      MatchEventType.possession => Icons.sync_alt_rounded,
      MatchEventType.pass => Icons.arrow_forward_rounded,
      MatchEventType.shot => Icons.sports_soccer_rounded,
      MatchEventType.save => Icons.back_hand_outlined,
      MatchEventType.woodwork => Icons.vertical_align_center_rounded,
      MatchEventType.goal || MatchEventType.ownGoal => Icons.sports_soccer_rounded,
      MatchEventType.foul => Icons.sports_rounded,
      MatchEventType.yellow || MatchEventType.red => Icons.crop_portrait_rounded,
      MatchEventType.penalty => Icons.adjust_rounded,
      MatchEventType.penaltySaved => Icons.pan_tool_alt_rounded,
      MatchEventType.substitution => Icons.swap_vert_rounded,
      MatchEventType.injury => Icons.healing_rounded,
      MatchEventType.halftime => Icons.pause_circle_outline_rounded,
      MatchEventType.fulltime => Icons.sports_score_rounded,
    };

Color matchEventColor(MatchEventType type) => switch (type) {
      MatchEventType.goal || MatchEventType.ownGoal => AppColors.green,
      MatchEventType.woodwork => AppColors.warning,
      MatchEventType.yellow => AppColors.warning,
      MatchEventType.red => AppColors.danger,
      MatchEventType.penalty => AppColors.warning,
      MatchEventType.penaltySaved => AppColors.green,
      MatchEventType.injury => AppColors.warning,
      MatchEventType.substitution => const Color(0xFF63B7FF),
      MatchEventType.halftime || MatchEventType.fulltime => AppColors.green,
      _ => AppColors.muted,
    };

class MatchPhasePanel extends StatelessWidget {
  const MatchPhasePanel({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.buttonIcon,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String buttonLabel;
  final IconData buttonIcon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.green),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: AppColors.green, size: 23),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: onPressed,
                icon: Icon(buttonIcon, size: 17),
                label: Text(buttonLabel),
              ),
            ),
          ],
        ),
      );
}

class MatchStartingCard extends StatelessWidget {
  const MatchStartingCard({super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: const Row(
          children: [
            Icon(Icons.sports_soccer_rounded, color: AppColors.green),
            SizedBox(width: 9),
            Text(
              'A partida está começando...',
              style: TextStyle(
                color: AppColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
}
