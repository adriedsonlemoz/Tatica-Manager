import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/match_ball_styles.dart';

class MatchBallPicker extends StatelessWidget {
  const MatchBallPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          for (var index = 0; index < MatchBallStyleSpec.values.length; index++) ...[
            if (index > 0) const SizedBox(width: 7),
            Expanded(
              child: _BallOption(
                spec: MatchBallStyleSpec.values[index],
                selected: value == MatchBallStyleSpec.values[index].id,
                onTap: () => onChanged(MatchBallStyleSpec.values[index].id),
              ),
            ),
          ],
        ],
      );
}

class _BallOption extends StatelessWidget {
  const _BallOption({
    required this.spec,
    required this.selected,
    required this.onTap,
  });

  final MatchBallStyleSpec spec;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: selected,
        label: 'Bola ${spec.label}',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            height: 90,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? AppColors.green.withValues(alpha: .08) : AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: selected ? AppColors.green : AppColors.border,
                width: selected ? 1.6 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox.square(
                  dimension: 42,
                  child: CustomPaint(painter: _BallPreviewPainter(style: spec.id)),
                ),
                const SizedBox(height: 5),
                Text(
                  spec.shortLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: selected ? AppColors.green : AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _BallPreviewPainter extends CustomPainter {
  const _BallPreviewPainter({required this.style});

  final int style;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * .38;
    canvas.drawCircle(
      center.translate(1.5, 2.5),
      radius * 1.05,
      Paint()..color = const Color(0x44000000),
    );
    drawMatchBallGraphic(canvas, center: center, radius: radius, style: style);
  }

  @override
  bool shouldRepaint(covariant _BallPreviewPainter oldDelegate) => oldDelegate.style != style;
}
