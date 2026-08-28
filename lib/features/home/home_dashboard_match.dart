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
    required this.onAdvance,
    required this.onMatchDay,
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
  final VoidCallback onAdvance;
  final VoidCallback onMatchDay;
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
            onAdvance: onAdvance,
            onMatchDay: onMatchDay,
          ),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (context, constraints) {
              final canSplit = constraints.maxWidth >= 310;
              if (!canSplit) {
                return Column(
                  children: [
                    HomeBoardConfidenceCard(
                      confidence: boardConfidence,
                      club: club,
                      onStadiumTap: onStadiumTap,
                    ),
                    const SizedBox(height: 6),
                    HomeSeasonCard(
                      position: position,
                      currentRound: currentRound,
                      totalRounds: totalRounds,
                      onTap: onSeasonTap,
                      height: 88,
                    ),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 15,
                    child: HomeBoardConfidenceCard(
                      confidence: boardConfidence,
                      club: club,
                      onStadiumTap: onStadiumTap,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    flex: 13,
                    child: HomeSeasonCard(
                      position: position,
                      currentRound: currentRound,
                      totalRounds: totalRounds,
                      onTap: onSeasonTap,
                      height: 92,
                    ),
                  ),
                ],
              );
            },
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
    required this.onAdvance,
    required this.onMatchDay,
    this.onTap,
  });

  final Club club;
  final Club? opponent;
  final MatchFixture? fixture;
  final String competitionName;
  final bool isMatchDay;
  final int daysUntilMatch;
  final VoidCallback onAdvance;
  final VoidCallback onMatchDay;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final opponentClub = opponent;
    final nextFixture = fixture;
    if (nextFixture == null || opponentClub == null) {
      return _HomeDashboardCard(
        child: const SizedBox(
          height: 106,
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
          child: Column(
            children: [
              SizedBox(
                height: 32,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 4, 6, 4),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'PRÓXIMA PARTIDA',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 14.2,
                            fontWeight: FontWeight.w900,
                            letterSpacing: .15,
                          ),
                        ),
                      ),
                      const Icon(Icons.calendar_today_rounded, size: 10, color: AppColors.textSecondary),
                      const SizedBox(width: 3),
                      Text(
                        '${shortDate(nextFixture.date)} • ${nextFixture.kickoffLabel}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.2,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 94,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const HomeImageShade(
                      asset: HomeVisualAssets.matchStadium,
                      overlayStrength: .25,
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(homeClub.colors.primaryHex).withValues(alpha: .24),
                            Colors.transparent,
                            Color(awayClub.colors.primaryHex).withValues(alpha: .24),
                          ],
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
                height: 42,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
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
                        child: Center(
                          child: _CompactAdvanceButton(
                            isMatchDay: isMatchDay,
                            onTap: isMatchDay ? onMatchDay : onAdvance,
                          ),
                        ),
                      ),
                      const _MiniDivider(),
                      Expanded(
                        child: _MatchInfo(
                          icon: Icons.emoji_events_outlined,
                          value: competitionName,
                          caption: 'R${nextFixture.round}',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 36,
                margin: const EdgeInsets.fromLTRB(7, 0, 7, 7),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF5A1DBF).withValues(alpha: .72),
                      const Color(0xFF361275).withValues(alpha: .86),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF9754FF).withValues(alpha: .28)),
                ),
                child: Row(
                  children: [
                    Icon(
                      isMatchDay ? Icons.sports_soccer_rounded : Icons.rule_folder_rounded,
                      color: const Color(0xFFFFD85B),
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        isMatchDay
                            ? 'DIA DE JOGO • Preparação concluída'
                            : 'PREPARAÇÃO • ${_preparationText()}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 11.2,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (onTap != null)
                      const Icon(Icons.chevron_right_rounded, color: AppColors.white, size: 17),
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
    if (isMatchDay) return 'A preparação está pronta.';
    if (daysUntilMatch <= 1) return 'Últimos ajustes para o jogo.';
    return 'Faltam $daysUntilMatch dias para o jogo.';
  }
}

class _CompactAdvanceButton extends StatelessWidget {
  const _CompactAdvanceButton({required this.isMatchDay, required this.onTap});

  final bool isMatchDay;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9),
          child: Ink(
            height: 27,
            padding: const EdgeInsets.symmetric(horizontal: 9),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFB8FB21), Color(0xFF7BD20F)],
              ),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: const Color(0xFFA9FF3C).withValues(alpha: .45)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isMatchDay ? Icons.sports_soccer_rounded : Icons.play_arrow_rounded,
                  size: 13,
                  color: Colors.black,
                ),
                const SizedBox(width: 2),
                SizedBox(
                  width: 60,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      isMatchDay ? 'JOGAR PARTIDA' : 'AVANÇAR DIA',
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
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
          HomeClubCrest(club: club, size: 68),
          const SizedBox(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              club.shortName.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 11.4,
                fontWeight: FontWeight.w900,
                shadows: [Shadow(color: Colors.black, blurRadius: 4)],
              ),
            ),
          ),
        ],
      );
}

class _VersusBadge extends StatelessWidget {
  const _VersusBadge();

  @override
  Widget build(BuildContext context) => Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: .17),
          border: Border.all(color: AppColors.green.withValues(alpha: .28), width: 1),
        ),
        child: const Text(
          'VS',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 19,
            height: 1,
            fontWeight: FontWeight.w900,
            shadows: [Shadow(color: Colors.black, blurRadius: 5)],
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
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 12),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 10.6,
                    fontWeight: FontWeight.w800,
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
        height: 20,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        color: AppColors.border.withValues(alpha: .68),
      );
}
