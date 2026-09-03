import 'dart:math' as math;
import 'dart:ui';

abstract final class MatchGoalVisuals {
  static void drawNet(Canvas canvas, Rect field, {required bool left}) {
    final geometry = _GoalGeometry(field, left: left);
    final netPath = Path()
      ..moveTo(geometry.frontTop.dx, geometry.frontTop.dy)
      ..lineTo(geometry.backTop.dx, geometry.backTop.dy)
      ..lineTo(geometry.backBottom.dx, geometry.backBottom.dy)
      ..lineTo(geometry.frontBottom.dx, geometry.frontBottom.dy)
      ..close();
    canvas.drawPath(
      netPath,
      Paint()
        ..shader = Gradient.linear(
          geometry.frontCenter,
          geometry.backCenter,
          const [Color(0x12FFFFFF), Color(0x46FFFFFF)],
        ),
    );

    final net = Paint()
      ..color = const Color(0xB8FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .68;
    for (var row = 1; row < 8; row++) {
      final progress = row / 8;
      canvas.drawLine(
        Offset.lerp(geometry.frontTop, geometry.frontBottom, progress)!,
        Offset.lerp(geometry.backTop, geometry.backBottom, progress)!,
        net,
      );
    }
    for (var column = 1; column < 5; column++) {
      final progress = column / 5;
      canvas.drawLine(
        Offset.lerp(geometry.frontTop, geometry.backTop, progress)!,
        Offset.lerp(geometry.frontBottom, geometry.backBottom, progress)!,
        net,
      );
    }

    final rear = Paint()
      ..color = const Color(0xB8FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(geometry.backTop, geometry.backBottom, rear);
    canvas.drawLine(geometry.frontTop, geometry.backTop, rear);
    canvas.drawLine(geometry.frontBottom, geometry.backBottom, rear);
  }

  static void drawForegroundFrame(
    Canvas canvas,
    Rect field, {
    required bool left,
  }) {
    final geometry = _GoalGeometry(field, left: left);
    final shadow = Paint()
      ..color = const Color(0x65000000)
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);
    final shadowOffset = const Offset(1.1, 1.4);
    canvas.drawLine(
      geometry.frontTop + shadowOffset,
      geometry.frontBottom + shadowOffset,
      shadow,
    );
    canvas.drawLine(
      geometry.frontTop + shadowOffset,
      geometry.backTop + shadowOffset,
      shadow,
    );
    canvas.drawLine(
      geometry.frontBottom + shadowOffset,
      geometry.backBottom + shadowOffset,
      shadow,
    );

    final frame = Paint()
      ..shader = Gradient.linear(
        geometry.frontTop,
        geometry.frontBottom,
        const [Color(0xFFFFFFFF), Color(0xFFD7E1DD), Color(0xFFFFFFFF)],
      )
      ..strokeWidth = 2.05
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(geometry.frontTop, geometry.frontBottom, frame);
    canvas.drawLine(geometry.frontTop, geometry.backTop, frame);
    canvas.drawLine(geometry.frontBottom, geometry.backBottom, frame);
    canvas.drawCircle(geometry.frontTop, 1.15, Paint()..color = const Color(0xFFFFFFFF));
    canvas.drawCircle(
      geometry.frontBottom,
      1.15,
      Paint()..color = const Color(0xFFFFFFFF),
    );
  }

  static void drawReaction(
    Canvas canvas,
    Rect field, {
    required bool left,
    required double intensity,
    required double phase,
  }) {
    if (intensity <= 0) return;
    final geometry = _GoalGeometry(field, left: left);
    final direction = left ? 1.0 : -1.0;
    final oscillation = math.sin(phase * 18) * 2.5 * intensity;
    final bulge = direction * (2.2 + oscillation);
    final glowRect = Rect.fromPoints(
      geometry.frontTop,
      geometry.backBottom,
    ).inflate(4 * intensity);
    canvas.drawRect(
      glowRect,
      Paint()
        ..color = const Color(0xFFB8FF68)
            .withValues(alpha: .08 + .16 * intensity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    final reactiveNet = Paint()
      ..color = const Color(0xFFFFFFFF)
          .withValues(alpha: .34 + .48 * intensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .85;
    for (var row = 1; row < 8; row++) {
      final progress = row / 8;
      final start = Offset.lerp(
        geometry.frontTop,
        geometry.frontBottom,
        progress,
      )!;
      final end = Offset.lerp(
        geometry.backTop,
        geometry.backBottom,
        progress,
      )!.translate(bulge * math.sin(progress * math.pi), oscillation * .12);
      canvas.drawLine(start, end, reactiveNet);
    }
  }
}

class _GoalGeometry {
  _GoalGeometry(Rect field, {required bool left}) {
    final goalHeight = field.height * .29;
    final depth = math.min(15.0, field.height * .072).toDouble();
    final centerY = field.center.dy;
    final frontX = left ? field.left + 1.5 : field.right - 1.5;
    final top = centerY - goalHeight / 2;
    final backX = left ? frontX + depth : frontX - depth;
    frontTop = Offset(frontX, top);
    frontBottom = Offset(frontX, top + goalHeight);
    backTop = Offset(backX, top + 3.8);
    backBottom = Offset(backX, top + goalHeight - 3.8);
  }

  late final Offset frontTop;
  late final Offset frontBottom;
  late final Offset backTop;
  late final Offset backBottom;

  Offset get frontCenter => Offset.lerp(frontTop, frontBottom, .5)!;
  Offset get backCenter => Offset.lerp(backTop, backBottom, .5)!;
}
