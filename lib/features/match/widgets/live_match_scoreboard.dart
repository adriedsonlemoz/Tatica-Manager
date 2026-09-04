import 'package:flutter/material.dart';

import '../../../app/widgets/common.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/club/club.dart';
import '../../../domain/match/match_models.dart';

class LiveMatchScoreboard extends StatelessWidget {
  const LiveMatchScoreboard({
    super.key,
    required this.home,
    required this.away,
    required this.score,
    required this.minute,
    required this.phaseLabel,
    required this.events,
    this.throughSequence,
    required this.paused,
  });

  final Club home;
  final Club away;
  final MatchScore score;
  final int minute;
  final String phaseLabel;
  final List<MatchEvent> events;
  final int? throughSequence;
  final bool paused;

  @override
  Widget build(BuildContext context) {
    final homeYellow = _count(MatchEventType.yellow, home.id);
    final awayYellow = _count(MatchEventType.yellow, away.id);
    final homeRed = _count(MatchEventType.red, home.id);
    final awayRed = _count(MatchEventType.red, away.id);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF101B22), Color(0xFF0A1218), Color(0xFF121D22)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: .88)),
        boxShadow: const [
          BoxShadow(color: Color(0x44000000), blurRadius: 18, offset: Offset(0, 7)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Stack(
          children: [
            Positioned(
              right: -28,
              top: -42,
              child: Transform.rotate(
                angle: -.28,
                child: Container(
                  width: 150,
                  height: 82,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withValues(alpha: .035), width: 10),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 9),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      _LiveStatus(paused: paused),
                      const Spacer(),
                      Text(
                        '$phaseLabel  •',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .3,
                        ),
                      ),
                      const SizedBox(width: 5),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: Text(
                          _clockLabel(minute),
                          key: ValueKey(minute),
                          style: TextStyle(
                            color: minute == 45 || minute == 90
                                ? AppColors.warning
                                : AppColors.green,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: _ClubSide(
                          club: home,
                          alignEnd: false,
                          yellow: homeYellow,
                          red: homeRed,
                        ),
                      ),
                      Container(
                        constraints: const BoxConstraints(minWidth: 78),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 240),
                          transitionBuilder: (child, animation) => ScaleTransition(
                            scale: animation,
                            child: FadeTransition(opacity: animation, child: child),
                          ),
                          child: Text(
                            score.display,
                            key: ValueKey(score.display),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 36,
                              height: .95,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.2,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: _ClubSide(
                          club: away,
                          alignEnd: true,
                          yellow: awayYellow,
                          red: awayRed,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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

  bool _isVisible(MatchEvent event) =>
      event.minute < minute ||
      (event.minute == minute &&
          (throughSequence == null || event.sequence <= throughSequence!));

  static String _clockLabel(int minute) {
    final padded = minute.toString().padLeft(2, '0');
    return '$padded:00';
  }
}

class _LiveStatus extends StatelessWidget {
  const _LiveStatus({required this.paused});

  final bool paused;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            paused ? Icons.pause_rounded : Icons.circle,
            color: paused ? AppColors.warning : AppColors.green,
            size: paused ? 14 : 8,
          ),
          const SizedBox(width: 6),
          Text(
            paused ? 'PAUSADO' : 'AO VIVO',
            style: TextStyle(
              color: paused ? AppColors.warning : AppColors.green,
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
              letterSpacing: .55,
            ),
          ),
        ],
      );
}

class _ClubSide extends StatelessWidget {
  const _ClubSide({
    required this.club,
    required this.alignEnd,
    required this.yellow,
    required this.red,
  });

  final Club club;
  final bool alignEnd;
  final int yellow;
  final int red;

  @override
  Widget build(BuildContext context) {
    final badge = ClubBadge(club: club, size: 44);
    final info = Expanded(
      child: Column(
        crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            club.name.toUpperCase(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: alignEnd ? TextAlign.right : TextAlign.left,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (yellow == 0 && red == 0)
                Text(
                  club.shortName.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              if (yellow > 0) _CardCount(value: yellow, red: false),
              if (yellow > 0 && red > 0) const SizedBox(width: 5),
              if (red > 0) _CardCount(value: red, red: true),
            ],
          ),
        ],
      ),
    );

    return Row(
      children: alignEnd
          ? [info, const SizedBox(width: 7), badge]
          : [badge, const SizedBox(width: 7), info],
    );
  }
}

class _CardCount extends StatelessWidget {
  const _CardCount({required this.value, required this.red});

  final int value;
  final bool red;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 11,
            decoration: BoxDecoration(
              color: red ? AppColors.danger : AppColors.warning,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
          const SizedBox(width: 3),
          Text(
            '$value',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      );
}
