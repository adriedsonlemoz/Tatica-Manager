import 'dart:math' as math;
import 'dart:ui';

import '../../../core/theme/match_ball_styles.dart';
import '../../../domain/match/match_models.dart';
import 'match_goal_visuals.dart';

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

  static double interfaceScale(double fieldWidth) =>
      (fieldWidth / 360).clamp(.82, 1.35).toDouble();

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
    _drawGrassTexture(canvas, field);
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
    final lineWidth = (field.width / 360 * 1.12).clamp(.95, 1.55).toDouble();
    final line = Paint()
      ..color = const Color(0xB8FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth;
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
    final arcRadius = field.height * .105;
    final leftSpot = Offset(bounds.left + boxWidth * .70, field.center.dy);
    final rightSpot = Offset(bounds.right - boxWidth * .70, field.center.dy);
    canvas.drawArc(
      Rect.fromCircle(center: leftSpot, radius: arcRadius),
      -math.pi / 2,
      math.pi,
      false,
      line,
    );
    canvas.drawArc(
      Rect.fromCircle(center: rightSpot, radius: arcRadius),
      math.pi / 2,
      math.pi,
      false,
      line,
    );
    final cornerRadius = (field.height * .027).clamp(4.2, 7.0).toDouble();
    final cornerBounds = <(Offset, double)>[
      (bounds.topLeft, 0),
      (bounds.topRight, math.pi / 2),
      (bounds.bottomLeft, -math.pi / 2),
      (bounds.bottomRight, math.pi),
    ];
    for (final corner in cornerBounds) {
      canvas.drawArc(
        Rect.fromCircle(center: corner.$1, radius: cornerRadius),
        corner.$2,
        math.pi / 2,
        false,
        line,
      );
    }
  }

  static void _drawGrassTexture(Canvas canvas, Rect field) {
    final crossStripe = Paint()..color = const Color(0x09000000);
    for (var row = 0; row < 7; row++) {
      if (row.isOdd) {
        canvas.drawRect(
          Rect.fromLTWH(
            field.left,
            field.top + field.height * row / 7,
            field.width,
            field.height / 7,
          ),
          crossStripe,
        );
      }
    }
    final blade = Paint()
      ..color = const Color(0x14FFFFFF)
      ..strokeWidth = .45
      ..strokeCap = StrokeCap.round;
    for (var index = 0; index < 46; index++) {
      final x = field.left + 5 + ((index * 47) % 347) / 347 * (field.width - 10);
      final y = field.top + 4 + ((index * 83) % 211) / 211 * (field.height - 8);
      final length = 1.2 + (index % 4) * .38;
      canvas.drawLine(Offset(x, y), Offset(x + length, y - .35), blade);
    }
  }

  static void drawGoal(Canvas canvas, Rect field, {required bool left}) {
    MatchGoalVisuals.drawNet(canvas, field, left: left);
  }

  static void drawGoalFrames(Canvas canvas, Rect field) {
    MatchGoalVisuals.drawForegroundFrame(canvas, field, left: true);
    MatchGoalVisuals.drawForegroundFrame(canvas, field, left: false);
  }

  static void drawGoalReaction(
    Canvas canvas,
    Rect field, {
    required bool left,
    required double intensity,
    required double phase,
  }) {
    MatchGoalVisuals.drawReaction(
      canvas,
      field,
      left: left,
      intensity: intensity,
      phase: phase,
    );
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
    final trailDelta = raisedBall - raisedTrail;
    final maximumTrail = 30.0 * scale;
    final visibleTrail = trailDelta.distance > maximumTrail
        ? raisedBall - trailDelta / trailDelta.distance * maximumTrail
        : raisedTrail;

    if (moving) {
      canvas.drawLine(
        visibleTrail,
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
          from: visibleTrail,
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
