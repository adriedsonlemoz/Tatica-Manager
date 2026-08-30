import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/club/club.dart';
import '../../domain/match/match_models.dart';
import 'home_visual_components.dart';

class HomeNextMatchCard extends StatelessWidget {
  const HomeNextMatchCard({
    super.key,
    required this.club,
    required this.opponent,
    required this.fixture,
    required this.competitionName,
    this.onTap,
  });

  final Club club;
  final Club? opponent;
  final MatchFixture? fixture;
  final String competitionName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final opponentClub = opponent;
    final nextFixture = fixture;
    if (nextFixture == null || opponentClub == null) {
      return const _HomeDashboardCard(
        child: SizedBox(
          height: 96,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.emoji_events_outlined, color: AppColors.green, size: 28),
                SizedBox(height: 5),
                Text('TEMPORADA CONCLUÍDA', style: TextStyle(fontWeight: FontWeight.w900)),
                SizedBox(height: 2),
                Text('Não há próxima partida agendada.', style: TextStyle(color: AppColors.muted, fontSize: 11)),
              ],
            ),
          ),
        ),
      );
    }

    final homeClub = nextFixture.homeClubId == club.id ? club : opponentClub;
    final awayClub = nextFixture.homeClubId == club.id ? opponentClub : club;
    final stadium = homeClub.stadium.name;

    return _HomeDashboardCard(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PRÓXIMA PARTIDA',
                  style: TextStyle(
                    color: AppColors.green,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .3,
                  ),
                ),
                const SizedBox(height: 10),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(flex: 5, child: _MatchClub(club: homeClub)),
                      const SizedBox(
                        width: 26,
                        child: Text(
                          'X',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Expanded(flex: 5, child: _MatchClub(club: awayClub)),
                      Container(
                        width: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        color: AppColors.border,
                      ),
                      Expanded(
                        flex: 6,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _MatchInfoRow(
                              icon: Icons.emoji_events_rounded,
                              text: competitionName,
                            ),
                            const SizedBox(height: 8),
                            _MatchInfoRow(
                              icon: Icons.calendar_today_rounded,
                              text: '${fullDate(nextFixture.date)} • ${nextFixture.kickoffLabel}',
                            ),
                            const SizedBox(height: 8),
                            _MatchInfoRow(
                              icon: Icons.stadium_rounded,
                              text: stadium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeDashboardCard extends StatelessWidget {
  const _HomeDashboardCard({
    required this.child,
    this.padding = const EdgeInsets.all(10),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF12202A), Color(0xFF162229), Color(0xFF111A20)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border.withValues(alpha: .82)),
          boxShadow: const [
            BoxShadow(color: Color(0x26000000), blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: child,
      );
}

class _MatchClub extends StatelessWidget {
  const _MatchClub({required this.club});

  final Club club;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HomeClubCrest(club: club, size: 46),
          const SizedBox(height: 5),
          Text(
            club.shortName.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      );
}

class _MatchInfoRow extends StatelessWidget {
  const _MatchInfoRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, color: AppColors.green, size: 13),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 11.3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      );
}
