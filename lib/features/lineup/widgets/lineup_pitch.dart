import 'package:flutter/material.dart';

import '../../../app/widgets/player_avatar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/player/player.dart';
import '../../../game/lineup/lineup_engine.dart';

class LineupPitch extends StatelessWidget {
  const LineupPitch({
    super.key,
    required this.assignments,
    required this.accentColor,
    required this.onPlayerTap,
    required this.onPlayerLongPress,
    this.formationLabel,
  });

  final List<AssignedPlayer> assignments;
  final Color accentColor;
  final ValueChanged<AssignedPlayer> onPlayerTap;
  final ValueChanged<AssignedPlayer> onPlayerLongPress;
  final String? formationLabel;

  @override
  Widget build(BuildContext context) => AspectRatio(
        aspectRatio: 1.28,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.pitch,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: .18)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const markerWidth = 62.0;
              const markerHeight = 76.0;
              return Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  const Positioned.fill(child: CustomPaint(painter: _HorizontalPitchPainter())),
                  if (formationLabel?.isNotEmpty == true)
                    Positioned(
                      left: 10,
                      top: 9,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xCC0B120E),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Text(
                          'FORMAÇÃO $formationLabel',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: .4,
                          ),
                        ),
                      ),
                    ),
                  for (final assignment in assignments)
                    Positioned(
                      left: ((1 - assignment.slot.y) * constraints.maxWidth - markerWidth / 2)
                          .clamp(4.0, constraints.maxWidth - markerWidth - 4)
                          .toDouble(),
                      top: (assignment.slot.x * constraints.maxHeight - markerHeight / 2)
                          .clamp(4.0, constraints.maxHeight - markerHeight - 4)
                          .toDouble(),
                      child: _PlayerMarker(
                        assignment: assignment,
                        accentColor: accentColor,
                        onTap: () => onPlayerTap(assignment),
                        onLongPress: () => onPlayerLongPress(assignment),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      );
}

class _PlayerMarker extends StatelessWidget {
  const _PlayerMarker({
    required this.assignment,
    required this.accentColor,
    required this.onTap,
    required this.onLongPress,
  });

  final AssignedPlayer assignment;
  final Color accentColor;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final effective = assignment.effectiveOverall;
    final warning = assignment.outOfPosition;
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: SizedBox(
        width: 62,
        height: 76,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xEE0B120E),
                  border: Border.all(
                    color: warning ? AppColors.warning : accentColor,
                    width: 1.5,
                  ),
                ),
                child: PlayerAvatar(
                  player: assignment.player,
                  size: 36,
                  accentColor: accentColor,
                ),
              ),
            ),
            Positioned(
              top: 33,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
                decoration: BoxDecoration(
                  color: const Color(0xEE0B120E),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: warning
                        ? AppColors.warning.withValues(alpha: .8)
                        : Colors.white.withValues(alpha: .14),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          assignment.slot.role.label,
                          style:  TextStyle(
                            color: AppColors.muted,
                            fontSize: 7.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '$effective',
                          style: TextStyle(
                            color: warning ? AppColors.warning : AppColors.green,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      assignment.player.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 7.5, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HorizontalPitchPainter extends CustomPainter {
  const _HorizontalPitchPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: .32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final rect = Rect.fromLTWH(12, 12, size.width - 24, size.height - 24);
    canvas.drawRect(rect, paint);
    canvas.drawLine(
      Offset(size.width / 2, 12),
      Offset(size.width / 2, size.height - 12),
      paint,
    );
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.height * .14,
      paint,
    );
    final boxW = size.width * .16;
    final boxH = size.height * .52;
    canvas.drawRect(
      Rect.fromLTWH(12, (size.height - boxH) / 2, boxW, boxH),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width - 12 - boxW, (size.height - boxH) / 2, boxW, boxH),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
