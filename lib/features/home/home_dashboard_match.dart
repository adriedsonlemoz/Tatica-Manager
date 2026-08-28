import 'package:flutter/material.dart';

import '../../app/widgets/common.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/club/club.dart';
import '../../domain/match/match_models.dart';

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

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final canSplit = constraints.maxWidth >= 380;
          final match = HomeNextMatchCard(
            club: club,
            opponent: opponent,
            fixture: fixture,
            competitionName: competitionName,
            isMatchDay: isMatchDay,
            daysUntilMatch: daysUntilMatch,
            onTap: onMatchTap,
          );
          final side = Column(
            children: [
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
              ),
            ],
          );
          if (!canSplit) {
            return Column(children: [match, const SizedBox(height: 8), side]);
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 19, child: match),
              const SizedBox(width: 8),
              Expanded(flex: 11, child: side),
            ],
          );
        },
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
    if (fixture == null || opponentClub == null) {
      return _DashboardCard(
        child: SizedBox(
          height: 185,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events_outlined, color: AppColors.green, size: 38),
                const SizedBox(height: 8),
                const Text('TEMPORADA CONCLUÍDA', style: TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text('Não há próxima partida agendada.', style: TextStyle(color: AppColors.muted, fontSize: 11)),
              ],
            ),
          ),
        ),
      );
    }
    final stadium = fixture!.homeClubId == club.id ? club.stadium.name : opponentClub.stadium.name;
    return _DashboardCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('PRÓXIMA PARTIDA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                  ),
                  Text(
                    '${shortDate(fixture!.date)} • ${fixture!.kickoffLabel}',
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.surfaceRaised,
                    Color(club.colors.primaryHex).withValues(alpha: .20),
                    AppColors.background,
                  ],
                ),
                border: const Border.symmetric(horizontal: BorderSide(color: AppColors.border)),
              ),
              child: Stack(
                children: [
                  const Positioned.fill(child: IgnorePointer(child: _PitchLines())),
                  Row(
                    children: [
                      Expanded(child: _MatchClub(club: club)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('VS', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                      ),
                      Expanded(child: _MatchClub(club: opponentClub)),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 9, 12, 8),
              child: Row(
                children: [
                  Expanded(child: _MatchInfo(icon: Icons.stadium_outlined, value: stadium)),
                  const _MiniDivider(),
                  Expanded(child: _MatchInfo(icon: Icons.schedule_rounded, value: fixture!.kickoffLabel)),
                  const _MiniDivider(),
                  Expanded(child: _MatchInfo(icon: Icons.emoji_events_outlined, value: '$competitionName • R${fixture!.round}')),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.green.withValues(alpha: .17),
                    AppColors.surfaceRaised,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.green.withValues(alpha: .25)),
              ),
              child: Row(
                children: [
                  Icon(
                    isMatchDay ? Icons.sports_soccer_rounded : Icons.fitness_center_rounded,
                    color: AppColors.green,
                    size: 17,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isMatchDay ? 'DIA DE JOGO' : 'PREPARAÇÃO EM ANDAMENTO',
                          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.green),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          isMatchDay
                              ? 'A preparação está pronta para a partida.'
                              : daysUntilMatch <= 1
                                  ? 'Últimos ajustes antes da partida.'
                                  : 'Faltam $daysUntilMatch dias para o jogo.',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 8, color: AppColors.muted, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.green, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeBoardConfidenceCard extends StatelessWidget {
  const HomeBoardConfidenceCard({
    super.key,
    required this.confidence,
    required this.club,
    this.onStadiumTap,
  });

  final int confidence;
  final Club club;
  final VoidCallback? onStadiumTap;

  @override
  Widget build(BuildContext context) => _DashboardCard(
        accent: const Color(0xFF41C8B4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('CONFIANÇA DA DIRETORIA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            InkWell(
              onTap: onStadiumTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF41C8B4).withValues(alpha: .22)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.stadium_rounded, color: Color(0xFF62DCC9), size: 15),
                        SizedBox(width: 5),
                        Text('ESTÁDIO', style: TextStyle(fontSize: 7, color: AppColors.muted, fontWeight: FontWeight.w900)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      club.stadium.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${_compactCount(club.stadium.capacity)} lugares • Ingresso ${compactMoney(club.stadium.ticketPrice)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 7, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 9),
            Divider(height: 1, color: AppColors.border.withValues(alpha: .9)),
            const SizedBox(height: 9),
            Center(
              child: SizedBox(
                width: 82,
                height: 82,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: confidence / 100,
                      strokeWidth: 8,
                      backgroundColor: const Color(0xFF313B3A),
                      color: AppColors.green,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$confidence%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                        const Text('CONFIANÇA', style: TextStyle(fontSize: 7, color: AppColors.muted, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  static String _compactCount(int value) {
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)} mil';
    return '$value';
  }
}

class HomeSeasonCard extends StatelessWidget {
  const HomeSeasonCard({
    super.key,
    required this.position,
    required this.currentRound,
    required this.totalRounds,
  });

  final int position;
  final int currentRound;
  final int totalRounds;

  @override
  Widget build(BuildContext context) {
    final remaining = (totalRounds - currentRound).clamp(0, totalRounds);
    return _DashboardCard(
      accent: AppColors.danger,
      child: Row(
        children: [
          const Icon(Icons.track_changes_rounded, color: AppColors.danger, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('PANORAMA DA TEMPORADA', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text(
                  position > 0 ? '$positionº NA LIGA' : 'SEM POSIÇÃO',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                ),
                Text('$remaining rodadas restantes', style: const TextStyle(fontSize: 8, color: AppColors.muted)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
        ],
      ),
    );
  }
}

class HomeAdvanceStrip extends StatelessWidget {
  const HomeAdvanceStrip({
    super.key,
    required this.isMatchDay,
    required this.onAdvance,
    required this.onMatchDay,
  });

  final bool isMatchDay;
  final VoidCallback onAdvance;
  final VoidCallback onMatchDay;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isMatchDay ? onMatchDay : onAdvance,
          borderRadius: BorderRadius.circular(15),
          child: Ink(
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF84E91D), Color(0xFF63C90B)]),
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [BoxShadow(color: Color(0x335ECC00), blurRadius: 16, offset: Offset(0, 7))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isMatchDay ? Icons.sports_soccer_rounded : Icons.play_arrow_rounded, color: Colors.black, size: 24),
                const SizedBox(width: 7),
                Text(
                  isMatchDay ? 'ABRIR PARTIDA' : 'AVANÇAR',
                  style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: .3),
                ),
                const SizedBox(width: 7),
                const Icon(Icons.arrow_forward_rounded, color: Colors.black, size: 19),
              ],
            ),
          ),
        ),
      );
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.accent,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final accentColor = accent;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: accentColor == null
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [accentColor.withValues(alpha: .08), AppColors.surface],
              ),
        color: accentColor == null ? AppColors.surface : null,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor?.withValues(alpha: .20) ?? AppColors.border),
        boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 12, offset: Offset(0, 5))],
      ),
      child: child,
    );
  }
}

class _MatchClub extends StatelessWidget {
  const _MatchClub({required this.club});

  final Club club;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          ClubBadge(club: club, size: 62),
          const SizedBox(height: 7),
          Text(
            club.shortName.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
          ),
        ],
      );
}

class _MatchInfo extends StatelessWidget {
  const _MatchInfo({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: AppColors.muted),
          const SizedBox(width: 4),
          Flexible(
            child: Text(value, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontSize: 8, color: AppColors.muted, fontWeight: FontWeight.w700)),
          ),
        ],
      );
}

class _MiniDivider extends StatelessWidget {
  const _MiniDivider();

  @override
  Widget build(BuildContext context) => Container(width: 1, height: 26, margin: const EdgeInsets.symmetric(horizontal: 5), color: AppColors.border);
}

class _PitchLines extends StatelessWidget {
  const _PitchLines();

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _PitchLinesPainter());
}

class _PitchLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: .05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final rect = Rect.fromLTWH(8, 6, size.width - 16, size.height - 12);
    canvas.drawRect(rect, paint);
    canvas.drawLine(Offset(size.width / 2, 6), Offset(size.width / 2, size.height - 6), paint);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 24, paint);
  }

  @override
  bool shouldRepaint(covariant _PitchLinesPainter oldDelegate) => false;
}
