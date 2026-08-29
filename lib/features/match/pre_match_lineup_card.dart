import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/formation/formation.dart';
import '../../domain/player/player.dart';
import '../../game/lineup/lineup_engine.dart';

class PreMatchLineupCard extends StatelessWidget {
  const PreMatchLineupCard({
    super.key,
    required this.assignments,
    required this.formation,
    required this.accentColor,
  });

  final List<AssignedPlayer> assignments;
  final FormationType formation;
  final Color accentColor;

  @override
  Widget build(BuildContext context) => _PremiumPanel(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _RoundIcon(icon: Icons.groups_2_rounded),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'QUEM VAI A CAMPO',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .2,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Titulares posicionados na formação. OVR efetivo considera posição, condição e fadiga.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 8.8,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${assignments.length}/11',
                  style: const TextStyle(
                    color: AppColors.green,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _ReadOnlyTacticalPitch(
              assignments: assignments,
              formation: formation,
              accentColor: accentColor,
            ),
          ],
        ),
      );
}

class _ReadOnlyTacticalPitch extends StatelessWidget {
  const _ReadOnlyTacticalPitch({
    required this.assignments,
    required this.formation,
    required this.accentColor,
  });

  final List<AssignedPlayer> assignments;
  final FormationType formation;
  final Color accentColor;

  @override
  Widget build(BuildContext context) => AspectRatio(
        aspectRatio: 1.12,
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF132A2B), Color(0xFF102122), Color(0xFF0D191A)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withValues(alpha: .78)),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const markerWidth = 68.0;
              const markerHeight = 48.0;
              final pitchWidth = constraints.maxWidth;
              final pitchHeight = constraints.maxHeight;
              return Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  const Positioned.fill(
                    child: CustomPaint(painter: _VerticalPitchPainter()),
                  ),
                  Positioned(
                    left: 8,
                    top: 7,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xC90B1415),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.green.withValues(alpha: .22)),
                      ),
                      child: Text(
                        formation.label,
                        style: const TextStyle(
                          color: AppColors.green,
                          fontSize: 7.2,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  for (final assignment in assignments)
                    Positioned(
                      left: (assignment.slot.x * pitchWidth - markerWidth / 2)
                          .clamp(3.0, pitchWidth - markerWidth - 3)
                          .toDouble(),
                      top: (assignment.slot.y * pitchHeight - markerHeight / 2)
                          .clamp(4.0, pitchHeight - markerHeight - 4)
                          .toDouble(),
                      child: _TacticalPlayerMarker(
                        assignment: assignment,
                        accentColor: accentColor,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      );
}

class _TacticalPlayerMarker extends StatelessWidget {
  const _TacticalPlayerMarker({
    required this.assignment,
    required this.accentColor,
  });

  final AssignedPlayer assignment;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final warning = assignment.outOfPosition;
    final shirt = assignment.player.shirtNumber > 0
        ? '${assignment.player.shirtNumber}'
        : assignment.slot.role.label.substring(0, 1);
    return SizedBox(
      width: 68,
      height: 48,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xD6112319),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: (warning ? AppColors.warning : AppColors.green)
                      .withValues(alpha: .3),
                ),
              ),
              child: Text(
                assignment.slot.role.label,
                style: TextStyle(
                  color: warning ? AppColors.warning : AppColors.green,
                  fontSize: 6.1,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          Positioned(
            top: 13,
            left: 0,
            right: 0,
            child: Container(
              height: 34,
              padding: const EdgeInsets.fromLTRB(4, 3, 5, 3),
              decoration: BoxDecoration(
                color: const Color(0xEC121D22),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: warning
                      ? AppColors.warning.withValues(alpha: .54)
                      : Colors.white.withValues(alpha: .12),
                ),
                boxShadow: const [
                  BoxShadow(color: Color(0x33000000), blurRadius: 6, offset: Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 25,
                    height: 25,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF18262D),
                      border: Border.all(
                        color: warning ? AppColors.warning : accentColor,
                        width: 1.15,
                      ),
                    ),
                    child: Text(
                      shirt,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 8.2,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignment.player.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 6.9,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'OVR ${assignment.effectiveOverall}',
                          style: TextStyle(
                            color: warning ? AppColors.warning : AppColors.textSecondary,
                            fontSize: 6.4,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                      ],
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
}

class _VerticalPitchPainter extends CustomPainter {
  const _VerticalPitchPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = Colors.white.withValues(alpha: .10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final soft = Paint()
      ..color = AppColors.green.withValues(alpha: .035)
      ..style = PaintingStyle.fill;

    for (var index = 0; index < 8; index++) {
      if (index.isEven) {
        canvas.drawRect(
          Rect.fromLTWH(0, size.height / 8 * index, size.width, size.height / 8),
          soft,
        );
      }
    }

    final rect = Rect.fromLTWH(10, 10, size.width - 20, size.height - 20);
    canvas.drawRect(rect, line);
    canvas.drawLine(
      Offset(10, size.height / 2),
      Offset(size.width - 10, size.height / 2),
      line,
    );
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width * .10, line);

    final boxWidth = size.width * .46;
    final boxHeight = size.height * .13;
    canvas.drawRect(
      Rect.fromLTWH((size.width - boxWidth) / 2, 10, boxWidth, boxHeight),
      line,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - boxWidth) / 2,
        size.height - 10 - boxHeight,
        boxWidth,
        boxHeight,
      ),
      line,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


class _PremiumPanel extends StatelessWidget {
  const _PremiumPanel({required this.child, required this.padding});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF13232B), Color(0xFF101B22), Color(0xFF0F181E)],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border.withValues(alpha: .82)),
          boxShadow: const [
            BoxShadow(color: Color(0x26000000), blurRadius: 14, offset: Offset(0, 6)),
          ],
        ),
        child: child,
      );
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.green.withValues(alpha: .32),
              AppColors.green.withValues(alpha: .08),
            ],
          ),
          border: Border.all(color: AppColors.green.withValues(alpha: .35)),
        ),
        child: Icon(icon, color: AppColors.green, size: 20),
      );
}
