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
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 9),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 18,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _LiveStatus(paused: paused, phaseLabel: phaseLabel),
              const Spacer(),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -.25),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: Text(
                  "$minute'",
                  key: ValueKey(minute),
                  style: TextStyle(
                    color: minute == 45 || minute == 90
                        ? AppColors.warning
                        : AppColors.green,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: _ClubCompact(
                  club: home,
                  alignEnd: false,
                  yellow: homeYellow,
                  red: homeRed,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: Text(
                    score.display,
                    key: ValueKey(score.display),
                    style: const TextStyle(
                      fontSize: 30,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -.8,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _ClubCompact(
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
}

class _LiveStatus extends StatelessWidget {
  const _LiveStatus({required this.paused, required this.phaseLabel});

  final bool paused;
  final String phaseLabel;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: paused
              ? AppColors.surfaceRaised
              : AppColors.green.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: paused
                ? AppColors.border
                : AppColors.green.withValues(alpha: .35),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: paused ? AppColors.warning : AppColors.green,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              paused ? 'PAUSADO • $phaseLabel' : 'AO VIVO • $phaseLabel',
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
                letterSpacing: .35,
              ),
            ),
          ],
        ),
      );
}

class _ClubCompact extends StatelessWidget {
  const _ClubCompact({
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
    final badge = ClubBadge(club: club, size: 34);
    final info = Expanded(
      child: Column(
        crossAxisAlignment:
            alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            club.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: alignEnd ? TextAlign.right : TextAlign.left,
            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900),
          ),
          if (yellow > 0 || red > 0) ...[
            const SizedBox(height: 3),
            Row(
              mainAxisAlignment:
                  alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (yellow > 0) _CardCount(value: yellow, red: false),
                if (yellow > 0 && red > 0) const SizedBox(width: 5),
                if (red > 0) _CardCount(value: red, red: true),
              ],
            ),
          ],
        ],
      ),
    );

    return Row(
      children: alignEnd
          ? [info, const SizedBox(width: 6), badge]
          : [badge, const SizedBox(width: 6), info],
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
            width: 7,
            height: 10,
            decoration: BoxDecoration(
              color: red ? AppColors.danger : AppColors.warning,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
          const SizedBox(width: 3),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Text(
              '$value',
              key: ValueKey('$red-$value'),
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      );
}
