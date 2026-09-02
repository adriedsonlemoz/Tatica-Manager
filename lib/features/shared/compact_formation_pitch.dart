import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../game/lineup/lineup_engine.dart';

class CompactFormationPitch extends StatelessWidget {
  const CompactFormationPitch({
    super.key,
    required this.assignments,
    required this.accent,
    required this.onPlayerTap,
    this.onPlayerLongPress,
  });

  final List<AssignedPlayer> assignments;
  final Color accent;
  final ValueChanged<AssignedPlayer> onPlayerTap;
  final ValueChanged<AssignedPlayer>? onPlayerLongPress;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.pitch,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.green.withValues(alpha: .45)),
          boxShadow: const [
            BoxShadow(color: Color(0x33000000), blurRadius: 12),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const markerWidth = 67.0;
            const markerHeight = 43.0;
            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                const Positioned.fill(
                  child: CustomPaint(painter: _CompactPitchPainter()),
                ),
                for (final assignment in assignments)
                  Positioned(
                    left: (assignment.slot.x * constraints.maxWidth -
                            markerWidth / 2)
                        .clamp(
                          2.0,
                          constraints.maxWidth - markerWidth - 2,
                        )
                        .toDouble(),
                    top: (assignment.slot.y * constraints.maxHeight -
                            markerHeight / 2)
                        .clamp(
                          2.0,
                          constraints.maxHeight - markerHeight - 2,
                        )
                        .toDouble(),
                    child: _CompactPitchPlayer(
                      assignment: assignment,
                      accent: accent,
                      onTap: () => onPlayerTap(assignment),
                      onLongPress: onPlayerLongPress == null
                          ? null
                          : () => onPlayerLongPress!(assignment),
                    ),
                  ),
              ],
            );
          },
        ),
      );
}

class _CompactPitchPlayer extends StatelessWidget {
  const _CompactPitchPlayer({
    required this.assignment,
    required this.accent,
    required this.onTap,
    this.onLongPress,
  });

  final AssignedPlayer assignment;
  final Color accent;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: SizedBox(
          width: 67,
          height: 43,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                top: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.greenDark,
                    shape: BoxShape.circle,
                    border: Border.all(color: accent, width: 1.2),
                  ),
                  child: Text(
                    '${assignment.player.shirtNumber}',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 24,
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xE8112029),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        assignment.player.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 7.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${assignment.slot.role.label} • ${assignment.effectiveOverall}',
                        style: TextStyle(
                          color: assignment.outOfPosition
                              ? AppColors.warning
                              : AppColors.green,
                          fontSize: 6.5,
                          fontWeight: FontWeight.w800,
                        ),
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

class _CompactPitchPainter extends CustomPainter {
  const _CompactPitchPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stripe = Paint()..color = const Color(0x102EDB4A);
    for (var index = 0; index < 8; index += 2) {
      canvas.drawRect(
        Rect.fromLTWH(
          0,
          size.height * index / 8,
          size.width,
          size.height / 8,
        ),
        stripe,
      );
    }
    final line = Paint()
      ..color = Colors.white.withValues(alpha: .28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final field = Rect.fromLTWH(12, 10, size.width - 24, size.height - 20);
    canvas.drawRect(field, line);
    canvas.drawLine(
      Offset(12, size.height / 2),
      Offset(size.width - 12, size.height / 2),
      line,
    );
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 30, line);
    final boxWidth = size.width * .48;
    final boxHeight = size.height * .15;
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
