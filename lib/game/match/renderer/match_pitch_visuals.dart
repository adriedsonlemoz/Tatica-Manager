import 'dart:math' as math;
import 'dart:ui';

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
        ..color = const Color(0x9978D620)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.15,
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
        const [Color(0x18000000), Color(0x00FFFFFF), Color(0x1A000000)],
        const [0, .48, 1],
      );
    canvas.drawRect(field, wash);
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
    final depth = math.min(7.0, field.height * .04);
    final top = field.center.dy - goalHeight / 2;
    final x = left ? field.left + 1 : field.right - depth - 1;
    final rect = Rect.fromLTWH(x, top, depth, goalHeight);
    final net = Paint()
      ..color = const Color(0x99FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .8;
    canvas.drawRect(rect, net);
    for (var index = 1; index < 5; index++) {
      final y = top + goalHeight * index / 5;
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), net);
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
  }) {
    if (moving) {
      canvas.drawLine(
        trailStart,
        ball,
        Paint()
          ..color = (replay ? const Color(0xCCFFFFFF) : const Color(0x66FFFFFF))
          ..strokeWidth = replay ? 1.6 : 1.2
          ..strokeCap = StrokeCap.round,
      );
      if (eventType == MatchEventType.pass ||
          eventType == MatchEventType.shot ||
          eventType == MatchEventType.goal ||
          eventType == MatchEventType.ownGoal ||
          eventType == MatchEventType.woodwork) {
        _drawTrajectoryArrow(
          canvas,
          from: trailStart,
          to: ball,
          emphasized: eventType != MatchEventType.pass,
        );
      }
    }
    if (woodwork) {
      canvas.drawCircle(
        ball,
        8.5,
        Paint()
          ..color = const Color(0x55E7C14D)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    canvas.drawCircle(
      Offset(ball.dx + 1.2, ball.dy + 2),
      4.4,
      Paint()..color = const Color(0x66000000),
    );
    final baseColor = switch (style) {
      1 => const Color(0xFFF5FFF6),
      2 => const Color(0xFFFFD83D),
      3 => const Color(0xFFF2E2BE),
      _ => const Color(0xFFFFFFFF),
    };
    final detailColor = switch (style) {
      1 => const Color(0xFF6CD91B),
      2 => const Color(0xFF342A14),
      3 => const Color(0xFF7B4E2F),
      _ => const Color(0xFF101010),
    };
    canvas.drawCircle(ball, 4.3, Paint()..color = baseColor);
    canvas.drawCircle(
      ball,
      4.3,
      Paint()
        ..color = detailColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.05,
    );
    canvas.drawCircle(
      Offset(ball.dx + .7, ball.dy - .6),
      1.15,
      Paint()..color = detailColor,
    );
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
