import 'dart:math' as math;
import 'dart:ui';

import '../../../core/theme/match_ball_styles.dart';
import '../../../domain/match/match_models.dart';

abstract final class MatchPitchVisuals {
  static Rect fieldRect(double width, double height) => Rect.fromLTRB(
        9,
        height * .13,
        width - 9,
        height * .965,
      );

  static Path pitchPath(double width, double height) {
    final field = fieldRect(width, height);
    final topInset = math.min(field.width * .018, 12.0);
    return Path()
      ..moveTo(field.left + topInset, field.top)
      ..lineTo(field.right - topInset, field.top)
      ..lineTo(field.right, field.bottom)
      ..lineTo(field.left, field.bottom)
      ..close();
  }

  static Offset projectDisplayPoint(
    Offset point,
    double width,
    double height,
  ) {
    final field = fieldRect(width, height);
    final y = point.dy.clamp(0.0, 1.0);
    final perspectiveY = math.pow(y, .985).toDouble();
    final topInset = math.min(field.width * .018, 12.0);
    final left = _lerp(field.left + topInset, field.left, perspectiveY);
    final right = _lerp(field.right - topInset, field.right, perspectiveY);
    return Offset(
      _lerp(left, right, point.dx.clamp(0.0, 1.0)),
      _lerp(field.top, field.bottom, perspectiveY),
    );
  }

  static double perspectiveScale(double displayY) =>
      _lerp(.92, 1.04, displayY.clamp(0.0, 1.0));

  static void drawPitch(Canvas canvas, double width, double height) {
    final field = fieldRect(width, height);
    final pitch = pitchPath(width, height);
    canvas.drawPath(
      pitch,
      Paint()
        ..shader = Gradient.linear(
          field.topCenter,
          field.bottomCenter,
          const [
            Color(0xFF397B2D),
            Color(0xFF2A6B27),
            Color(0xFF245B22),
          ],
          const [0, .52, 1],
        ),
    );

    for (var index = 0; index < 12; index++) {
      if (index.isOdd) continue;
      final left = index / 12;
      final right = (index + 1) / 12;
      canvas.drawPath(
        _quad(width, height, left, 0, right, 1),
        Paint()..color = const Color(0x0DFFFFFF),
      );
    }
    for (var row = 0; row < 8; row++) {
      if (row.isEven) continue;
      final top = row / 8;
      final bottom = (row + 1) / 8;
      canvas.drawPath(
        _quad(width, height, 0, top, 1, bottom),
        Paint()..color = const Color(0x07000000),
      );
    }

    _drawPitchMarkings(canvas, width, height);
    _drawPerspectiveWash(canvas, field);
  }

  static void drawPitchBorder(Canvas canvas, Path pitch) {
    canvas.drawPath(
      pitch,
      Paint()
        ..color = const Color(0xC4E8F2DF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.25,
    );
  }

  static void drawVignette(Canvas canvas, Rect field) {
    final vignette = Paint()
      ..shader = Gradient.radial(
        field.center,
        field.longestSide * .62,
        const [Color(0x00000000), Color(0x66000000)],
        const [.45, 1],
      );
    canvas.drawRect(field.inflate(24), vignette);
  }

  static void _drawPerspectiveWash(Canvas canvas, Rect field) {
    final wash = Paint()
      ..shader = Gradient.linear(
        field.topCenter,
        field.bottomCenter,
        const [Color(0x24000000), Color(0x00FFFFFF), Color(0x16000000)],
        const [0, .44, 1],
      );
    canvas.drawRect(field, wash);
  }

  static void _drawPitchMarkings(
    Canvas canvas,
    double width,
    double height,
  ) {
    final line = Paint()
      ..color = const Color(0xD8FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15;

    _drawPolygon(
      canvas,
      width,
      height,
      const [
        Offset(.018, .025),
        Offset(.982, .025),
        Offset(.982, .975),
        Offset(.018, .975),
      ],
      line,
      close: true,
    );
    _drawLine(canvas, width, height, const Offset(.5, .025), const Offset(.5, .975), line);
    _drawEllipse(canvas, width, height, const Offset(.5, .5), .095, .175, line);
    final center = projectDisplayPoint(const Offset(.5, .5), width, height);
    canvas.drawCircle(center, 1.8, Paint()..color = const Color(0xEFFFFFFF));

    _drawBox(canvas, width, height, .018, .18, .215, .785, line);
    _drawBox(canvas, width, height, .82, .982, .215, .785, line);
    _drawBox(canvas, width, height, .018, .075, .355, .645, line);
    _drawBox(canvas, width, height, .925, .982, .355, .645, line);

    for (final spot in [const Offset(.12, .5), const Offset(.88, .5)]) {
      canvas.drawCircle(
        projectDisplayPoint(spot, width, height),
        1.7,
        Paint()..color = const Color(0xEFFFFFFF),
      );
    }

    _drawArc(
      canvas,
      width,
      height,
      center: const Offset(.12, .5),
      radiusX: .075,
      radiusY: .13,
      start: -1.12,
      end: 1.12,
      paint: line,
    );
    _drawArc(
      canvas,
      width,
      height,
      center: const Offset(.88, .5),
      radiusX: .075,
      radiusY: .13,
      start: math.pi - 1.12,
      end: math.pi + 1.12,
      paint: line,
    );
  }

  static void drawGoals(Canvas canvas, double width, double height) {
    drawGoal(canvas, width, height, left: true);
    drawGoal(canvas, width, height, left: false);
  }

  static void drawGoal(
    Canvas canvas,
    double width,
    double height, {
    required bool left,
  }) {
    final top = projectDisplayPoint(Offset(left ? .018 : .982, .39), width, height);
    final bottom = projectDisplayPoint(Offset(left ? .018 : .982, .61), width, height);
    final depth = math.min(13.0, width * .022);
    final direction = left ? -1.0 : 1.0;
    final farTop = top.translate(direction * depth, 3.5);
    final farBottom = bottom.translate(direction * depth, -3.5);
    final net = Paint()
      ..color = const Color(0xD9FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15;
    final softNet = Paint()
      ..color = const Color(0x72FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .65;

    final frame = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(bottom.dx, bottom.dy)
      ..lineTo(farBottom.dx, farBottom.dy)
      ..lineTo(farTop.dx, farTop.dy)
      ..close();
    canvas.drawPath(frame, net);
    for (var index = 1; index < 6; index++) {
      final t = index / 6;
      canvas.drawLine(
        Offset.lerp(top, bottom, t)!,
        Offset.lerp(farTop, farBottom, t)!,
        softNet,
      );
    }
    for (var index = 1; index < 4; index++) {
      final t = index / 4;
      canvas.drawLine(
        Offset.lerp(top, farTop, t)!,
        Offset.lerp(bottom, farBottom, t)!,
        softNet,
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
    drawMatchBallGraphic(
      canvas,
      center: ball,
      radius: 4.3,
      style: style,
    );
  }

  static Path _quad(
    double width,
    double height,
    double left,
    double top,
    double right,
    double bottom,
  ) {
    final p1 = projectDisplayPoint(Offset(left, top), width, height);
    final p2 = projectDisplayPoint(Offset(right, top), width, height);
    final p3 = projectDisplayPoint(Offset(right, bottom), width, height);
    final p4 = projectDisplayPoint(Offset(left, bottom), width, height);
    return Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..lineTo(p4.dx, p4.dy)
      ..close();
  }

  static void _drawBox(
    Canvas canvas,
    double width,
    double height,
    double left,
    double right,
    double top,
    double bottom,
    Paint paint,
  ) {
    _drawPolygon(
      canvas,
      width,
      height,
      [
        Offset(left, top),
        Offset(right, top),
        Offset(right, bottom),
        Offset(left, bottom),
      ],
      paint,
      close: true,
    );
  }

  static void _drawLine(
    Canvas canvas,
    double width,
    double height,
    Offset from,
    Offset to,
    Paint paint,
  ) {
    canvas.drawLine(
      projectDisplayPoint(from, width, height),
      projectDisplayPoint(to, width, height),
      paint,
    );
  }

  static void _drawPolygon(
    Canvas canvas,
    double width,
    double height,
    List<Offset> points,
    Paint paint, {
    bool close = false,
  }) {
    if (points.isEmpty) return;
    final first = projectDisplayPoint(points.first, width, height);
    final path = Path()..moveTo(first.dx, first.dy);
    for (final point in points.skip(1)) {
      final projected = projectDisplayPoint(point, width, height);
      path.lineTo(projected.dx, projected.dy);
    }
    if (close) path.close();
    canvas.drawPath(path, paint);
  }

  static void _drawEllipse(
    Canvas canvas,
    double width,
    double height,
    Offset center,
    double radiusX,
    double radiusY,
    Paint paint,
  ) {
    final points = <Offset>[];
    for (var index = 0; index <= 44; index++) {
      final angle = math.pi * 2 * index / 44;
      points.add(
        Offset(
          center.dx + math.cos(angle) * radiusX,
          center.dy + math.sin(angle) * radiusY,
        ),
      );
    }
    _drawPolygon(canvas, width, height, points, paint, close: true);
  }

  static void _drawArc(
    Canvas canvas,
    double width,
    double height, {
    required Offset center,
    required double radiusX,
    required double radiusY,
    required double start,
    required double end,
    required Paint paint,
  }) {
    final points = <Offset>[];
    for (var index = 0; index <= 22; index++) {
      final angle = _lerp(start, end, index / 22);
      points.add(
        Offset(
          center.dx + math.cos(angle) * radiusX,
          center.dy + math.sin(angle) * radiusY,
        ),
      );
    }
    _drawPolygon(canvas, width, height, points, paint);
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

  static double _lerp(double a, double b, double t) => a + (b - a) * t;
}
