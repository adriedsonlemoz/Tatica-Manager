import 'package:flutter/material.dart';

import '../../app/widgets/common.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/club/club.dart';
import '../../domain/match/match_models.dart';

class PreMatchHeroCard extends StatelessWidget {
  const PreMatchHeroCard({
    super.key,
    required this.home,
    required this.away,
    required this.fixture,
    required this.competitionName,
    required this.userClubId,
    required this.isMatchDay,
    required this.ready,
  });

  final Club home;
  final Club away;
  final MatchFixture fixture;
  final String competitionName;
  final String userClubId;
  final bool isMatchDay;
  final bool ready;

  @override
  Widget build(BuildContext context) {
    final homeAccent = AppColors.readableAccent(Color(home.colors.primaryHex));
    final awayAccent = AppColors.readableAccent(Color(away.colors.primaryHex));
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: .9)),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), blurRadius: 20, offset: Offset(0, 8)),
        ],
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: _StadiumBackdrop(),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    homeAccent.withValues(alpha: .16),
                    Colors.transparent,
                    awayAccent.withValues(alpha: .16),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
            child: Column(
              children: [
                Row(
                  children: [
                    _StatusPill(
                      icon: isMatchDay
                          ? Icons.sports_soccer_rounded
                          : Icons.event_available_rounded,
                      label: isMatchDay ? 'HOJE É DIA DE JOGO' : 'PREPARE SUA EQUIPE',
                      active: isMatchDay,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: ready ? AppColors.green : AppColors.warning,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (ready ? AppColors.green : AppColors.warning)
                                    .withValues(alpha: .5),
                                blurRadius: 7,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          ready ? 'PRONTO PARA ENTRAR EM CAMPO' : 'AJUSTES PENDENTES',
                          style: TextStyle(
                            color: ready ? AppColors.green : AppColors.warning,
                            fontSize: 8.6,
                            fontWeight: FontWeight.w900,
                            letterSpacing: .2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: _HeroClub(club: home, accent: homeAccent)),
                    const SizedBox(width: 8),
                    const _HeroVersus(),
                    const SizedBox(width: 8),
                    Expanded(child: _HeroClub(club: away, accent: awayAccent)),
                  ],
                ),
                const SizedBox(height: 12),
                _WideInfoPill(
                  icon: Icons.emoji_events_outlined,
                  label: competitionName,
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Expanded(
                      child: _WideInfoPill(
                        icon: Icons.calendar_month_rounded,
                        label: '${weekdayLabel(fixture.date)} • ${fullDate(fixture.date)}',
                      ),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: _WideInfoPill(
                        icon: Icons.schedule_rounded,
                        label: fixture.kickoffLabel,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Expanded(
                      child: _WideInfoPill(
                        icon: Icons.stadium_rounded,
                        label: home.stadium.name,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: _WideInfoPill(
                        icon: Icons.home_work_rounded,
                        label: fixture.homeClubId == userClubId
                            ? 'Mando de campo'
                            : 'Visitante',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _HeroClub extends StatelessWidget {
  const _HeroClub({required this.club, required this.accent});

  final Club club;
  final Color accent;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: .15),
                  blurRadius: 18,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: ClubBadge(club: club, size: 88),
          ),
          const SizedBox(height: 7),
          Text(
            club.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              shadows: [Shadow(color: Colors.black, blurRadius: 5)],
            ),
          ),
        ],
      );
}

class _HeroVersus extends StatelessWidget {
  const _HeroVersus();

  @override
  Widget build(BuildContext context) => Container(
        width: 68,
        height: 68,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.green.withValues(alpha: .18),
              Colors.black.withValues(alpha: .12),
            ],
          ),
          border: Border.all(color: AppColors.green.withValues(alpha: .36)),
        ),
        child: const Text(
          'VS',
          style: TextStyle(
            color: AppColors.green,
            fontSize: 25,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            shadows: [
              Shadow(color: Color(0x9976D91B), blurRadius: 14),
              Shadow(color: Colors.black, blurRadius: 4),
            ],
          ),
        ),
      );
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.icon,
    required this.label,
    required this.active,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: active
                ? [Color(0xFF547B16), Color(0xFF33510D)]
                : [AppColors.surfaceRaised, AppColors.surface],
          ),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: (active ? AppColors.green : AppColors.border).withValues(alpha: .55),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: active ? AppColors.green : AppColors.textSecondary, size: 15),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: active ? AppColors.green : AppColors.textSecondary,
                fontSize: 8.3,
                fontWeight: FontWeight.w900,
                letterSpacing: .25,
              ),
            ),
          ],
        ),
      );
}

class _WideInfoPill extends StatelessWidget {
  const _WideInfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minHeight: 36),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xD5142026),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withValues(alpha: .58)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: AppColors.green),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
}

class _StadiumBackdrop extends StatelessWidget {
  const _StadiumBackdrop();

  @override
  Widget build(BuildContext context) => Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/home/match_stadium.webp',
            fit: BoxFit.cover,
            alignment: Alignment.center,
            filterQuality: FilterQuality.medium,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xC8081118), Color(0x67101A20), Color(0xE70B1419)],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                radius: 1.05,
                colors: [Colors.transparent, Colors.black.withValues(alpha: .42)],
              ),
            ),
          ),
        ],
      );
}
