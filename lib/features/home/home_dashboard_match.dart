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
    required this.recentForm,
    required this.position,
    required this.totalRounds,
    required this.currentRound,
    this.onMatchTap,
  });

  final Club club;
  final Club? opponent;
  final MatchFixture? fixture;
  final String competitionName;
  final int boardConfidence;
  final List<String> recentForm;
  final int position;
  final int totalRounds;
  final int currentRound;
  final VoidCallback? onMatchTap;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final canSplit = constraints.maxWidth >= 380;
          final match = HomeNextMatchCard(
            club: club,
            opponent: opponent,
            fixture: fixture,
            competitionName: competitionName,
            onTap: onMatchTap,
          );
          final side = Column(
            children: [
              HomeBoardConfidenceCard(
                confidence: boardConfidence,
                recentForm: recentForm,
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
                    const Color(0xFF0F1D1A),
                    Color(club.colors.primaryHex).withValues(alpha: .16),
                    const Color(0xFF07100E),
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
              padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
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
          ],
        ),
      ),
    );
  }
}

class HomeBoardConfidenceCard extends StatelessWidget {
  const HomeBoardConfidenceCard({super.key, required this.confidence, required this.recentForm});

  final int confidence;
  final List<String> recentForm;

  @override
  Widget build(BuildContext context) => _DashboardCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('CONFIANÇA DA DIRETORIA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
            const SizedBox(height: 9),
            const Text('ÚLTIMAS 5 PARTIDAS', style: TextStyle(fontSize: 8, color: AppColors.muted, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Row(
              children: List.generate(5, (index) {
                final value = index < recentForm.length ? recentForm[index] : '—';
                final color = switch (value) {
                  'V' => AppColors.green,
                  'E' => AppColors.warning,
                  'D' => AppColors.danger,
                  _ => AppColors.surfaceSoft,
                };
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: index == 4 ? 0 : 3),
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    child: Text(value, style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w900)),
                  ),
                );
              }),
            ),
            const SizedBox(height: 10),
            Divider(height: 1, color: AppColors.border.withValues(alpha: .9)),
            const SizedBox(height: 9),
            Center(
              child: SizedBox(
                width: 86,
                height: 86,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: confidence / 100,
                      strokeWidth: 9,
                      backgroundColor: const Color(0xFFB6BEC0),
                      color: AppColors.green,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$confidence%', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
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
    required this.currentDate,
    required this.daysUntilMatch,
    required this.onAdvance,
    required this.onMatchDay,
  });

  final bool isMatchDay;
  final DateTime currentDate;
  final int daysUntilMatch;
  final VoidCallback onAdvance;
  final VoidCallback onMatchDay;

  @override
  Widget build(BuildContext context) {
    final nextDate = currentDate.add(const Duration(days: 1));
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isMatchDay ? onMatchDay : onAdvance,
        borderRadius: BorderRadius.circular(17),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(14, 11, 12, 11),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF84E91D), Color(0xFF63C90B)]),
            borderRadius: BorderRadius.circular(17),
            boxShadow: const [BoxShadow(color: Color(0x335ECC00), blurRadius: 18, offset: Offset(0, 8))],
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: .10), shape: BoxShape.circle),
                child: Icon(isMatchDay ? Icons.sports_soccer_rounded : Icons.play_arrow_rounded, color: Colors.black, size: 28),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMatchDay ? 'DIA DE JOGO' : 'PREPARAÇÃO EM ANDAMENTO',
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isMatchDay
                          ? 'Entre na preparação e avance para a partida.'
                          : 'Avance para ${shortDate(nextDate)} • ${daysUntilMatch <= 1 ? 'a próxima partida está próxima' : 'faltam $daysUntilMatch dias para o jogo'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.black.withValues(alpha: .72), fontSize: 9, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              Text(isMatchDay ? 'ABRIR' : 'AVANÇAR', style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w900)),
              const SizedBox(width: 5),
              const Icon(Icons.arrow_forward_rounded, color: Colors.black, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}


class _DashboardCard extends StatelessWidget {
  const _DashboardCard({required this.child, this.padding = const EdgeInsets.all(12)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: const Color(0xFF091110),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF25302F)),
          boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 12, offset: Offset(0, 5))],
        ),
        child: child,
      );
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
