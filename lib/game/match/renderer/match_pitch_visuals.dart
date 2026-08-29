import 'dart:math' as math;
import 'dart:ui';

import '../../../core/theme/match_ball_styles.dart';
import '../../../domain/match/match_models.dart';

abstract final class MatchPitchVisuals {
  static Rect fieldRect(double width, double height) => Rect.fromLTWH(
        14,
        18,
        width - 28,
        height - 36,
      );

  static RRect pitchClip(double width, double height) => RRect.fromRectAndRadius(
        fieldRect(width, height),
        const Radius.circular(14),
      );

  static double depthScale(double displayY) =>
      (.82 + displayY.clamp(0.0, 1.0) * .28).toDouble();

  static double depthShadowScale(double displayY) =>
      (.76 + displayY.clamp(0.0, 1.0) * .30).toDouble();

  static void drawPitch(Canvas canvas, double width, double height) {
    final field = fieldRect(width, height);
    canvas.drawRect(
      field,
      Paint()
        ..shader = Gradient.linear(
          field.topLeft,
          field.bottomRight,
          const [Color(0xFF286326), Color(0xFF1D511D)],
        ),
    );

    final stripe = Paint()..color = const Color(0x0CFFFFFF);
    for (var index = 0; index < 12; index++) {
      if (index.isEven) {
        canvas.drawRect(
          Rect.fromLTWH(
            field.left + field.width / 12 * index,
            field.top,
            field.width / 12,
            field.height,
          ),
          stripe,
        );
      }
    }
    drawPitchMarkings(canvas, field);
    drawGoal(canvas, field, left: true);
    drawGoal(canvas, field, left: false);
    _drawPerspectiveWash(canvas, field);
  }

  static void drawPitchBorder(Canvas canvas, RRect clip) {
    canvas.drawRRect(
      clip,
      Paint()
        ..color = const Color(0x52000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawRRect(
      clip,
      Paint()
        ..color = const Color(0xA878D620)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.15,
    );
    final rect = clip.outerRect;
    canvas.drawLine(
      Offset(rect.left + 14, rect.bottom - .8),
      Offset(rect.right - 14, rect.bottom - .8),
      Paint()
        ..color = const Color(0x4078D620)
        ..strokeWidth = 2.2,
    );
  }

  static void drawVignette(Canvas canvas, Rect field) {
    final vignette = Paint()
      ..shader = Gradient.radial(
        field.center,
        field.longestSide * .62,
        const [Color(0x00000000), Color(0x66000000)],
        const [.48, 1],
      );
    canvas.drawRRect(
      RRect.fromRectAndRadius(field, const Radius.circular(14)),
      vignette,
    );
  }

  static void _drawPerspectiveWash(Canvas canvas, Rect field) {
    final wash = Paint()
      ..shader = Gradient.linear(
        field.topCenter,
        field.bottomCenter,
        const [
          Color(0x25000000),
          Color(0x04FFFFFF),
          Color(0x0AFFFFFF),
          Color(0x26000000),
        ],
        const [0, .30, .66, 1],
      );
    canvas.drawRect(field, wash);

    final centerLight = Paint()
      ..shader = Gradient.radial(
        Offset(field.center.dx, field.top + field.height * .34),
        field.width * .55,
        const [Color(0x15FFFFFF), Color(0x00000000)],
      );
    canvas.drawRect(field, centerLight);

    final nearLip = Rect.fromLTWH(
      field.left,
      field.bottom - math.max(3.0, field.height * .025).toDouble(),
      field.width,
      math.max(3.0, field.height * .025).toDouble(),
    );
    canvas.drawRect(
      nearLip,
      Paint()
        ..shader = Gradient.linear(
          nearLip.topCenter,
          nearLip.bottomCenter,
          const [Color(0x00000000), Color(0x24000000)],
        ),
    );
  }

  static void drawPitchMarkings(Canvas canvas, Rect field) {
    final line = Paint()
      ..color = const Color(0xB8FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15;
    final bounds = field.deflate(7);
    canvas.drawRect(bounds, line);
    canvas.drawLine(
      Offset(field.center.dx, bounds.top),
      Offset(field.center.dx, bounds.bottom),
      line,
    );
    canvas.drawCircle(
      field.center,
      math.min(field.width, field.height) * .12,
      line,
    );
    canvas.drawCircle(field.center, 1.8, Paint()..color = const Color(0xDFFFFFFF));

    final boxWidth = field.width * .16;
    final boxHeight = field.height * .56;
    final smallWidth = field.width * .065;
    final smallHeight = field.height * .29;
    final boxTop = field.center.dy - boxHeight / 2;
    final smallTop = field.center.dy - smallHeight / 2;

    canvas.drawRect(Rect.fromLTWH(bounds.left, boxTop, boxWidth, boxHeight), line);
    canvas.drawRect(
      Rect.fromLTWH(bounds.right - boxWidth, boxTop, boxWidth, boxHeight),
      line,
    );
    canvas.drawRect(
      Rect.fromLTWH(bounds.left, smallTop, smallWidth, smallHeight),
      line,
    );
    canvas.drawRect(
      Rect.fromLTWH(bounds.right - smallWidth, smallTop, smallWidth, smallHeight),
      line,
    );
    canvas.drawCircle(
      Offset(bounds.left + boxWidth * .70, field.center.dy),
      1.7,
      Paint()..color = const Color(0xDFFFFFFF),
    );
    canvas.drawCircle(
      Offset(bounds.right - boxWidth * .70, field.center.dy),
      1.7,
      Paint()..color = const Color(0xDFFFFFFF),
    );
  }

  static void drawGoal(Canvas canvas, Rect field, {required bool left}) {
    final goalHeight = field.height * .24;
    final depth = math.min(8.5, field.height * .045).toDouble();
    final top = field.center.dy - goalHeight / 2;
    final frontX = left ? field.left + 1.2 : field.right - 1.2;
    final backX = left ? frontX + depth : frontX - depth;
    final farShift = 2.4;
    final frame = Paint()
      ..color = const Color(0xEFFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15;
    final net = Paint()
      ..color = const Color(0x82FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .62;

    final frontTop = Offset(frontX, top);
    final frontBottom = Offset(frontX, top + goalHeight);
    final backTop = Offset(backX, top + farShift);
    final backBottom = Offset(backX, top + goalHeight - farShift);
    canvas.drawLine(frontTop, frontBottom, frame);
    canvas.drawLine(frontTop, backTop, frame);
    canvas.drawLine(frontBottom, backBottom, frame);
    canvas.drawLine(backTop, backBottom, net);

    for (var index = 1; index < 5; index++) {
      final t = index / 5;
      canvas.drawLine(
        Offset.lerp(frontTop, frontBottom, t)!,
        Offset.lerp(backTop, backBottom, t)!,
        net,
      );
    }
    for (var index = 1; index < 3; index++) {
      final t = index / 3;
      canvas.drawLine(
        Offset.lerp(frontTop, backTop, t)!,
        Offset.lerp(frontBottom, backBottom, t)!,
        net,
      );
    }
  }

  static void drawGoalReaction(
    Canvas canvas,
    Rect field, {
    required bool left,
    required double intensity,
    required double phase,
  }) {
    if (intensity <= 0) return;
    final goalHeight = field.height * .24;
    final depth = math.min(7.0, field.height * .04);
    final top = field.center.dy - goalHeight / 2;
    final x = left ? field.left + 1 : field.right - depth - 1;
    final rect = Rect.fromLTWH(x, top, depth, goalHeight);
    final direction = left ? 1.0 : -1.0;
    final ripple = math.sin(phase * 17) * 2.2 * intensity;
    final glow = Paint()
      ..color = const Color(0xFFB8FF68).withValues(alpha: .10 + .18 * intensity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawRect(rect.inflate(4 * intensity), glow);

    final net = Paint()
      ..color = const Color(0xDFFFFFFF).withValues(alpha: .35 + .45 * intensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .8;
    for (var index = 1; index < 5; index++) {
      final y = top + goalHeight * index / 5;
      canvas.drawLine(
        Offset(rect.left, y),
        Offset(rect.right + direction * ripple, y + ripple * .18),
        net,
      );
    }
  }

  static void drawBall(
    Canvas canvas, {
    required Offset ball,
    required Offset trailStart,
    required bool moving,
    required bool replay,
    required bool woodwork,
    required int style,
    required MatchEventType? eventType,
    required double heightLift,
    required double scale,
  }) {
    final lift = math.max(0.0, heightLift).toDouble();
    final raisedBall = ball.translate(0, -lift);
    final raisedTrail = trailStart.translate(0, -lift * .42);

    if (moving) {
      canvas.drawLine(
        raisedTrail,
        raisedBall,
        Paint()
          ..color = (replay ? const Color(0xCCFFFFFF) : const Color(0x5AFFFFFF))
          ..strokeWidth = (replay ? 1.6 : 1.1) * scale
          ..strokeCap = StrokeCap.round,
      );
      if (eventType == MatchEventType.pass ||
          eventType == MatchEventType.shot ||
          eventType == MatchEventType.goal ||
          eventType == MatchEventType.ownGoal ||
          eventType == MatchEventType.woodwork) {
        _drawTrajectoryArrow(
          canvas,
          from: raisedTrail,
          to: raisedBall,
          emphasized: eventType != MatchEventType.pass,
        );
      }
    }

    final shadowWidth = (8.4 + lift * .32) * scale;
    final shadowHeight = (3.2 - math.min(1.2, lift * .055)) * scale;
    canvas.drawOval(
      Rect.fromCenter(
        center: ball.translate(1.2 * scale, 2.3 * scale),
        width: shadowWidth,
        height: math.max(1.5, shadowHeight).toDouble(),
      ),
      Paint()
        ..color = Color.fromARGB((100 - math.min(55, lift * 5)).round(), 0, 0, 0)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1.2 * scale),
    );

    if (woodwork) {
      canvas.drawCircle(
        raisedBall,
        (8.5 + lift * .18) * scale,
        Paint()
          ..color = const Color(0x55E7C14D)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 * scale,
      );
    }

    drawMatchBallGraphic(
      canvas,
      center: raisedBall,
      radius: 4.3 * scale,
      style: style,
    );

    if (lift > 1.5) {
      canvas.drawCircle(
        raisedBall.translate(-1.1 * scale, -1.2 * scale),
        .75 * scale,
        Paint()..color = const Color(0xBFFFFFFF),
      );
    }
  }

  static void _drawTrajectoryArrow(
    Canvas canvas, {
    required Offset from,
    required Offset to,
    required bool emphasized,
  }) {
    final delta = to - from;
    final distance = delta.distance;
    if (distance < 8) return;
    final direction = delta / distance;
    final normal = Offset(-direction.dy, direction.dx);
    final tip = to - direction * 6;
    final size = emphasized ? 4.2 : 3.2;
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(
        tip.dx - direction.dx * size + normal.dx * size,
        tip.dy - direction.dy * size + normal.dy * size,
      )
      ..lineTo(
        tip.dx - direction.dx * size - normal.dx * size,
        tip.dy - direction.dy * size - normal.dy * size,
      )
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = emphasized
            ? const Color(0xCCF4D35E)
            : const Color(0x88FFFFFF),
    );
  }
}
