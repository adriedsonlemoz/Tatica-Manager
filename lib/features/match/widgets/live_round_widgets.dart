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
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 7),
        height: 36,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF111D23), Color(0xFF17252B), Color(0xFF111D23)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const SizedBox(width: 10),
            const Icon(Icons.campaign_rounded, size: 16, color: AppColors.green),
            const SizedBox(width: 6),
            Text(
              'Rodada $round',
              style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900),
            ),
            const SizedBox(width: 8),
            Container(width: 1, height: 18, color: AppColors.border),
            const SizedBox(width: 8),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: Text(
                  alert ?? venue,
                  key: ValueKey(alert ?? venue),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: alert == null ? AppColors.textSecondary : AppColors.white,
                    fontSize: 9.5,
                    fontWeight: alert == null ? FontWeight.w700 : FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            TextButton.icon(
              onPressed: onOpenRound,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.green,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              icon: const Icon(Icons.grid_view_rounded, size: 14),
              label: const Text('Rodada', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900)),
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
