import 'package:flutter/material.dart';

import '../../../app/state/live_match_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/season/career_state.dart';
import '../live_round_feed.dart';

class LiveRoundTicker extends StatelessWidget {
  const LiveRoundTicker({
    super.key,
    required this.round,
    required this.alert,
    required this.venue,
    required this.onOpenRound,
  });

  final int round;
  final String? alert;
  final String venue;
  final VoidCallback onOpenRound;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        height: 43,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF111D23), Color(0xFF17252B), Color(0xFF111D23)],
          ),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 104,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.volume_up_rounded, size: 18, color: AppColors.green),
                  const SizedBox(width: 7),
                  Text(
                    'Rodada $round',
                    style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
            Container(width: 1, height: 24, color: AppColors.border),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: Row(
                    key: ValueKey(alert ?? venue),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (alert == null) ...[
                        const Icon(Icons.stadium_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 5),
                      ],
                      Flexible(
                        child: Text(
                          alert ?? venue,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: alert == null ? AppColors.textSecondary : AppColors.white,
                            fontSize: 10.5,
                            fontWeight: alert == null ? FontWeight.w700 : FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(width: 1, height: 24, color: AppColors.border),
            InkWell(
              onTap: onOpenRound,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 98,
                height: 34,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.grid_view_rounded, size: 16, color: AppColors.green),
                    SizedBox(width: 6),
                    Text(
                      'Rodada',
                      style: TextStyle(
                        color: AppColors.green,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}

class LiveRoundScoreRow extends StatelessWidget {
  const LiveRoundScoreRow({
    super.key,
    required this.homeName,
    required this.awayName,
    required this.score,
    required this.minute,
  });

  final String homeName;
  final String awayName;
  final String score;
  final int minute;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            SizedBox(
              width: 34,
              child: Text(
                "$minute'",
                style: const TextStyle(
                  color: AppColors.green,
                  fontWeight: FontWeight.w900,
                  fontSize: 10.5,
                ),
              ),
            ),
            Expanded(
              child: Text(
                homeName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                score,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            Expanded(
              child: Text(
                awayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      );
}

class LiveRoundSheet extends StatelessWidget {
  const LiveRoundSheet({
    super.key,
    required this.career,
    required this.live,
    required this.minute,
  });

  final CareerState career;
  final LiveMatchSession live;
  final int minute;

  @override
  Widget build(BuildContext context) {
    final userHome = career.clubs.firstWhere(
      (club) => club.id == live.fixture.homeClubId,
    );
    final userAway = career.clubs.firstWhere(
      (club) => club.id == live.fixture.awayClubId,
    );
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .72,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 4, 14, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RODADA ${live.fixture.round} • AO VIVO',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 5),
              const Text(
                'Todos os placares acompanham o mesmo minuto da sua partida.',
                style: TextStyle(color: AppColors.muted, fontSize: 11),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: [
                    LiveRoundScoreRow(
                      homeName: userHome.name,
                      awayName: userAway.name,
                      score: LiveRoundFeed.scoreUntil(
                        live.result,
                        minute,
                      ).display,
                      minute: minute,
                    ),
                    const Divider(height: 1),
                    for (final other in live.otherMatches) ...[
                      LiveRoundScoreRow(
                        homeName: _clubName(other.fixture.homeClubId),
                        awayName: _clubName(other.fixture.awayClubId),
                        score: LiveRoundFeed.scoreUntil(
                          other.result,
                          minute,
                        ).display,
                        minute: minute,
                      ),
                      const Divider(height: 1),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _clubName(String clubId) =>
      career.clubs.firstWhere((club) => club.id == clubId).name;
}
