import 'package:flutter/material.dart';

import '../../app/widgets/common.dart';
import '../../app/widgets/management_dashboard_widgets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/club/club.dart';
import '../../domain/match/match_models.dart';

class MatchDayHeader extends StatelessWidget {
  const MatchDayHeader({
    super.key,
    required this.competition,
    required this.round,
    required this.onBack,
  });

  final String competition;
  final int round;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          Container(
            height: 190,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF07100E), Color(0xFF0B1714), AppColors.background],
              ),
            ),
          ),
          const Positioned.fill(child: IgnorePointer(child: _MatchDayLights())),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton.filledTonal(
                      onPressed: onBack,
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const Spacer(),
                    DashboardStatusPill(
                      label: 'Rodada $round',
                      color: AppColors.green,
                      icon: Icons.emoji_events_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'HOJE É',
                  style: TextStyle(
                    fontSize: 28,
                    height: .95,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const Text(
                  'DIA DE JOGO',
                  style: TextStyle(
                    color: AppColors.green,
                    fontSize: 38,
                    height: 1.0,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    letterSpacing: -.6,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  competition,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.muted, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      );
}

class MatchDayVersusCard extends StatelessWidget {
  const MatchDayVersusCard({
    super.key,
    required this.home,
    required this.away,
    required this.fixture,
    required this.userClubId,
  });

  final Club home;
  final Club away;
  final MatchFixture fixture;
  final String userClubId;

  @override
  Widget build(BuildContext context) => SectionCard(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        borderColor: AppColors.green.withValues(alpha: .60),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: _ClubSide(
                    club: home,
                    label: home.id == userClubId ? 'SEU TIME • MANDANTE' : 'MANDANTE',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  child: Column(
                    children: [
                      const Icon(Icons.schedule_rounded, color: AppColors.green, size: 20),
                      const SizedBox(height: 3),
                      Text(
                        fixture.kickoffLabel,
                        style: const TextStyle(color: AppColors.green, fontSize: 20, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceRaised,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.green.withValues(alpha: .35)),
                        ),
                        child: const Text('VS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _ClubSide(
                    club: away,
                    label: away.id == userClubId ? 'SEU TIME • VISITANTE' : 'VISITANTE',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _FooterInfo(
                    icon: Icons.calendar_month_rounded,
                    text: fullDate(fixture.date),
                  ),
                ),
                Expanded(
                  child: _FooterInfo(
                    icon: Icons.stadium_rounded,
                    text: home.stadium.name,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

class _ClubSide extends StatelessWidget {
  const _ClubSide({required this.club, required this.label});

  final Club club;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted, fontSize: 8, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 7),
          ClubBadge(club: club, size: 72),
          const SizedBox(height: 7),
          Text(
            club.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
          ),
        ],
      );
}

class _FooterInfo extends StatelessWidget {
  const _FooterInfo({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.green, size: 15),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.muted, fontSize: 9.5, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      );
}

class _MatchDayLights extends StatelessWidget {
  const _MatchDayLights();

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _MatchDayLightsPainter());
}

class _MatchDayLightsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final beam = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white.withValues(alpha: .10), Colors.transparent],
      ).createShader(Offset.zero & size);
    final left = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * .18, 0)
      ..lineTo(size.width * .43, size.height)
      ..lineTo(size.width * .18, size.height)
      ..close();
    final right = Path()
      ..moveTo(size.width * .82, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width * .82, size.height)
      ..lineTo(size.width * .57, size.height)
      ..close();
    canvas.drawPath(left, beam);
    canvas.drawPath(right, beam);
    final lamp = Paint()..color = Colors.white.withValues(alpha: .82);
    for (final x in [.05, .10, .90, .95]) {
      canvas.drawCircle(Offset(size.width * x, 8), 2.2, lamp);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

