import 'dart:math' as math;
import 'dart:ui';

enum MatchPlayerPose {
  normal,
  goalkeeperDive,
  celebration,
  penaltyReady,
}

abstract final class MatchPlayerVisuals {
  static void draw(
    Canvas canvas, {
    required Offset center,
    required Color color,
    required bool active,
    required double pulse,
    required bool replay,
    MatchPlayerPose pose = MatchPlayerPose.normal,
    double animationPhase = 0,
    double diveDirection = 0,
  }) {
    final bounce = pose == MatchPlayerPose.celebration
        ? math.sin(animationPhase * math.pi * 4).abs() * 2.2
        : 0.0;
    final crouch = pose == MatchPlayerPose.penaltyReady
        ? math.sin(animationPhase * math.pi * 2).abs() * 1.2
        : 0.0;
    final translated = center.translate(0, -bounce + crouch);
    final dive = pose == MatchPlayerPose.goalkeeperDive;
    final angle = dive ? diveDirection.sign * .86 : 0.0;

    canvas.save();
    if (dive) {
      canvas.translate(translated.dx, translated.dy);
      canvas.rotate(angle);
      canvas.translate(-translated.dx, -translated.dy);
    }

    final dark = Color.lerp(color, const Color(0xFF000000), .30)!;
    final outline = Paint()
      ..color = const Color(0xEFFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .9;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(translated.dx + 1, translated.dy + 6.1),
        width: dive ? 14 : 12,
        height: 4.3,
      ),
      Paint()..color = const Color(0x50000000),
    );

    final limbs = Paint()
      ..color = dark
      ..strokeWidth = 1.65
      ..strokeCap = StrokeCap.round;
    final armLift = pose == MatchPlayerPose.celebration ? 4.4 : 1.8;
    canvas.drawLine(
      Offset(translated.dx - 4, translated.dy - 1),
      Offset(translated.dx - 6.5, translated.dy - armLift),
      limbs,
    );
    canvas.drawLine(
      Offset(translated.dx + 4, translated.dy - 1),
      Offset(translated.dx + 6.5, translated.dy - armLift),
      limbs,
    );
    canvas.drawLine(
      Offset(translated.dx - 1.4, translated.dy + 3.2),
      Offset(translated.dx - 3.6, translated.dy + 7),
      limbs,
    );
    canvas.drawLine(
      Offset(translated.dx + 1.4, translated.dy + 3.2),
      Offset(translated.dx + 3.7, translated.dy + 7),
      limbs,
    );

    final torso = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: translated,
        width: 10.8,
        height: 10.4,
      ),
      const Radius.circular(3.2),
    );
    canvas.drawRRect(torso, Paint()..color = dark);
    canvas.drawRRect(torso.shift(const Offset(0, -.8)), Paint()..color = color);
    canvas.drawRRect(torso.shift(const Offset(0, -.8)), outline);

    canvas.drawCircle(
      Offset(translated.dx, translated.dy - 7),
      3.2,
      Paint()..color = const Color(0xFFD3A77B),
    );
    canvas.drawCircle(
      Offset(translated.dx, translated.dy - 7),
      3.25,
      outline,
    );

    if (active) {
      final ringColor = replay
          ? const Color(0xFFFFFFFF)
          : const Color(0xFF78D620);
      canvas.drawCircle(
        translated,
        13 + pulse * 4,
        Paint()
          ..color = ringColor.withValues(alpha: .07 + .10 * pulse),
      );
      canvas.drawCircle(
        translated,
        10 + pulse * 3,
        Paint()
          ..color = ringColor.withValues(alpha: .20 + .18 * pulse)
          ..style = PaintingStyle.stroke
          ..strokeWidth = replay ? 1.8 : 1.4,
      );
    }
    canvas.restore();
  }
}
