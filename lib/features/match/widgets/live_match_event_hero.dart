import 'package:flutter/material.dart';

import '../../../app/widgets/player_avatar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/match/match_models.dart';
import '../../../domain/player/player.dart';
import '../match_event_presentation.dart';
import 'live_match_event_widgets.dart';

class LiveMatchEventHero extends StatelessWidget {
  const LiveMatchEventHero({
    super.key,
    required this.event,
    required this.teamName,
    this.player,
    this.secondaryPlayer,
    this.assistPlayer,
  });

  final MatchEvent event;
  final String teamName;
  final Player? player;
  final Player? secondaryPlayer;
  final Player? assistPlayer;

  @override
  Widget build(BuildContext context) {
    if (event.type == MatchEventType.substitution) {
      return _SubstitutionHero(
        event: event,
        teamName: teamName,
        incoming: player,
        outgoing: secondaryPlayer,
      );
    }
    if (event.type == MatchEventType.yellow ||
        event.type == MatchEventType.red) {
      return _CardHero(event: event, teamName: teamName, player: player);
    }
    return _StandardHero(
      event: event,
      teamName: teamName,
      player: player,
      assistPlayer: assistPlayer,
    );
  }
}

class _StandardHero extends StatelessWidget {
  const _StandardHero({
    required this.event,
    required this.teamName,
    this.player,
    this.assistPlayer,
  });

  final MatchEvent event;
  final String teamName;
  final Player? player;
  final Player? assistPlayer;

  @override
  Widget build(BuildContext context) {
    final color = matchEventColor(event.type);
    final goal = event.type == MatchEventType.goal ||
        event.type == MatchEventType.ownGoal;
    final woodwork = event.type == MatchEventType.woodwork;
    final penaltySaved = event.type == MatchEventType.penaltySaved;
    return _HeroShell(
      borderColor: color,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (player != null)
            PlayerAvatar(
              player: player!,
              size: goal ? 46 : 38,
              accentColor: color,
            )
          else
            _EventIconBox(type: event.type, color: color, large: goal),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal
                      ? 'GOOOL!  ${event.minute}\''
                      : woodwork
                          ? 'NA TRAVE!  ${event.minute}\''
                          : penaltySaved
                              ? 'DEFESAÇA!  ${event.minute}\''
                              : '${MatchEventPresentation.headline(event.type, teamName)}  •  ${event.minute}\'',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: goal || woodwork || penaltySaved ? color : Colors.white,
                    fontSize: goal ? 16.5 : 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: goal ? .6 : .25,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _detail(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _detail() {
    if ((event.type == MatchEventType.goal ||
            event.type == MatchEventType.ownGoal) &&
        player != null) {
      final assist = assistPlayer == null
          ? ''
          : ' • assistência ${assistPlayer!.displayName}';
      return '${player!.displayName} • $teamName$assist';
    }
    if (event.type == MatchEventType.penaltySaved && player != null) {
      return '${player!.displayName} segura o pênalti • $teamName';
    }
    if (event.type == MatchEventType.woodwork && player != null) {
      return '${player!.displayName} acerta a trave • $teamName';
    }
    if (player != null) return '${player!.displayName} • $teamName';
    return teamName;
  }
}

class _CardHero extends StatelessWidget {
  const _CardHero({
    required this.event,
    required this.teamName,
    this.player,
  });

  final MatchEvent event;
  final String teamName;
  final Player? player;

  @override
  Widget build(BuildContext context) {
    final red = event.type == MatchEventType.red;
    final color = red ? AppColors.danger : AppColors.warning;
    return _HeroShell(
      borderColor: color,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.rotate(
            angle: -.08,
            child: Container(
              width: 24,
              height: 34,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: .35),
                    blurRadius: 9,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          if (player != null) ...[
            PlayerAvatar(player: player!, size: 36, accentColor: color),
            const SizedBox(width: 9),
          ],
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${red ? 'EXPULSO' : 'CARTÃO AMARELO'}  •  ${event.minute}\'',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${player?.displayName ?? teamName} • $teamName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubstitutionHero extends StatelessWidget {
  const _SubstitutionHero({
    required this.event,
    required this.teamName,
    this.incoming,
    this.outgoing,
  });

  final MatchEvent event;
  final String teamName;
  final Player? incoming;
  final Player? outgoing;

  @override
  Widget build(BuildContext context) => _HeroShell(
        borderColor: AppColors.info,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SUBSTITUIÇÃO  •  ${event.minute}\'  •  $teamName',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.info,
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SubPlayer(
                  player: outgoing,
                  fallback: 'Sai',
                  icon: Icons.arrow_downward_rounded,
                  color: AppColors.danger,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward_rounded, color: Colors.white54, size: 18),
                ),
                _SubPlayer(
                  player: incoming,
                  fallback: 'Entra',
                  icon: Icons.arrow_upward_rounded,
                  color: AppColors.green,
                ),
              ],
            ),
          ],
        ),
      );
}

class _SubPlayer extends StatelessWidget {
  const _SubPlayer({
    required this.player,
    required this.fallback,
    required this.icon,
    required this.color,
  });

  final Player? player;
  final String fallback;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (player != null) PlayerAvatar(player: player!, size: 31, accentColor: color),
          const SizedBox(width: 6),
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 3),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 84),
            child: Text(
              player?.displayName ?? fallback,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      );
}

class _EventIconBox extends StatelessWidget {
  const _EventIconBox({
    required this.type,
    required this.color,
    required this.large,
  });

  final MatchEventType type;
  final Color color;
  final bool large;

  @override
  Widget build(BuildContext context) => Container(
        width: large ? 44 : 36,
        height: large ? 44 : 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: .16),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(matchEventIcon(type), color: color, size: large ? 22 : 19),
      );
}

class _HeroShell extends StatelessWidget {
  const _HeroShell({required this.child, required this.borderColor});

  final Widget child;
  final Color borderColor;

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(maxWidth: 440),
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: .82),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor.withValues(alpha: .70)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: child,
      );
}
