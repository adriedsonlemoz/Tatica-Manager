import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/club/club.dart';
import '../../domain/match/match_models.dart';
import 'home_dashboard_status.dart';
import 'home_visual_components.dart';

class HomeMainOverview extends StatelessWidget {
  const HomeMainOverview({
    super.key,
    required this.club,
    required this.opponent,
    required this.fixture,
    required this.competitionName,
    required this.boardConfidence,
    required this.position,
    required this.totalRounds,
    required this.currentRound,
    required this.isMatchDay,
    required this.daysUntilMatch,
    this.onMatchTap,
    this.onStadiumTap,
    this.onSeasonTap,
  });

  final Club club;
  final Club? opponent;
  final MatchFixture? fixture;
  final String competitionName;
  final int boardConfidence;
  final int position;
  final int totalRounds;
  final int currentRound;
  final bool isMatchDay;
  final int daysUntilMatch;
  final VoidCallback? onMatchTap;
  final VoidCallback? onStadiumTap;
  final VoidCallback? onSeasonTap;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          HomeNextMatchCard(
            club: club,
            opponent: opponent,
            fixture: fixture,
            competitionName: competitionName,
            isMatchDay: isMatchDay,
            daysUntilMatch: daysUntilMatch,
            onTap: onMatchTap,
          ),
          const SizedBox(height: 8),
          HomeBoardConfidenceCard(
            confidence: boardConfidence,
            club: club,
            onStadiumTap: onStadiumTap,
          ),
          const SizedBox(height: 8),
          HomeSeasonCard(
            position: position,
            currentRound: currentRound,
            totalRounds: totalRounds,
            onTap: onSeasonTap,
          ),
        ],
      );
}

class HomeNextMatchCard extends StatelessWidget {
  const HomeNextMatchCard({
    super.key,
    required this.club,
    required this.opponent,
    required this.fixture,
    required this.competitionName,
    required this.isMatchDay,
    required this.daysUntilMatch,
    this.onTap,
  });

  final Club club;
  final Club? opponent;
  final MatchFixture? fixture;
  final String competitionName;
  final bool isMatchDay;
  final int daysUntilMatch;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final opponentClub = opponent;
    final nextFixture = fixture;
    if (nextFixture == null || opponentClub == null) {
      return _HomeDashboardCard(
        child: SizedBox(
          height: 180,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.emoji_events_outlined,
                  color: AppColors.green,
                  size: 36,
                ),
                const SizedBox(height: 8),
                const Text(
                  'TEMPORADA CONCLUÍDA',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Não há próxima partida agendada.',
                  style: TextStyle(color: AppColors.muted, fontSize: 10),
                ),
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
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(13, 10, 13, 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'PRÓXIMA PARTIDA',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .2,
                        ),
                      ),
                    ),
                    Text(
                      '${shortDate(nextFixture.date)} • ${nextFixture.kickoffLabel}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 94,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const HomeImageShade(
                      asset: HomeVisualAssets.matchStadium,
                      overlayStrength: .38,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.symmetric(
                          horizontal: BorderSide(
                            color: AppColors.border.withValues(alpha: .62),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(child: _MatchClub(club: homeClub)),
                        const _VersusBadge(),
                        Expanded(child: _MatchClub(club: awayClub)),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 45,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: _MatchInfo(
                          icon: Icons.stadium_outlined,
                          value: stadium,
                          caption: 'Estádio',
                        ),
                      ),
                      const _MiniDivider(),
                      Expanded(
                        child: _MatchInfo(
                          icon: Icons.schedule_rounded,
                          value: nextFixture.kickoffLabel,
                          caption: 'Horário da partida',
                        ),
                      ),
                      const _MiniDivider(),
                      Expanded(
                        child: _MatchInfo(
                          icon: Icons.emoji_events_outlined,
                          value: competitionName,
                          caption: 'Rodada ${nextFixture.round}',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 44,
                margin: const EdgeInsets.fromLTRB(9, 0, 9, 9),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.green.withValues(alpha: .19),
                      const Color(0xFF1A2A20),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: AppColors.green.withValues(alpha: .34)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 31,
                      height: 31,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.green.withValues(alpha: .10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isMatchDay
                            ? Icons.sports_soccer_rounded
                            : Icons.fitness_center_rounded,
                        color: AppColors.green,
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isMatchDay ? 'DIA DE JOGO' : 'PREPARAÇÃO EM ANDAMENTO',
                            style: const TextStyle(
                              color: AppColors.green,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            _preparationText(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onTap != null)
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.green,
                        size: 20,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _preparationText() {
    if (isMatchDay) return 'A preparação está pronta para a partida.';
    if (daysUntilMatch <= 1) return 'Últimos ajustes antes da partida.';
    return 'Faltam $daysUntilMatch dias para o jogo.';
  }
}

class _HomeDashboardCard extends StatelessWidget {
  const _HomeDashboardCard({
    required this.child,
    this.padding = const EdgeInsets.all(12),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border.withValues(alpha: .85)),
          boxShadow: const [
            BoxShadow(color: Color(0x30000000), blurRadius: 14, offset: Offset(0, 6)),
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
          HomeClubCrest(club: club, size: 67),
          const SizedBox(height: 2),
          Text(
            club.shortName.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              shadows: [Shadow(color: Colors.black, blurRadius: 5)],
            ),
          ),
        ],
      );
}

class _VersusBadge extends StatelessWidget {
  const _VersusBadge();

  @override
  Widget build(BuildContext context) => Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xC9162027),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.green.withValues(alpha: .42), width: 1.2),
          boxShadow: const [
            BoxShadow(color: Color(0x66000000), blurRadius: 12),
          ],
        ),
        child: const Text(
          'VS',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      );
}

class _MatchInfo extends StatelessWidget {
  const _MatchInfo({
    required this.icon,
    required this.value,
    required this.caption,
  });

  final IconData icon;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 5),
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 7.8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 6.7,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}

class _MiniDivider extends StatelessWidget {
  const _MiniDivider();

  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 27,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        color: AppColors.border.withValues(alpha: .78),
      );
}
