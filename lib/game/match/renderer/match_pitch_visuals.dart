import 'dart:math' as math;
import 'dart:ui';

import '../../../core/theme/match_ball_styles.dart';
import '../../../domain/match/match_models.dart';

abstract final class MatchPitchVisuals {
  static Rect fieldRect(double width, double height) => Rect.fromLTRB(
        8,
        height * .115,
        width - 8,
        height * .955,
      );

  static Path pitchPath(double width, double height) {
    final field = fieldRect(width, height);
    final topInset = _perspectiveInset(field, 0);
    final bottomInset = _perspectiveInset(field, 1);
    final radius = math.min(10.0, field.width * .028);
    return Path()
      ..moveTo(field.left + topInset + radius, field.top)
      ..lineTo(field.right - topInset - radius, field.top)
      ..quadraticBezierTo(
        field.right - topInset,
        field.top,
        field.right - topInset + 2,
        field.top + radius,
      )
      ..lineTo(field.right - bottomInset, field.bottom - radius)
      ..quadraticBezierTo(
        field.right - bottomInset,
        field.bottom,
        field.right - bottomInset - radius,
        field.bottom,
      )
      ..lineTo(field.left + bottomInset + radius, field.bottom)
      ..quadraticBezierTo(
        field.left + bottomInset,
        field.bottom,
        field.left + bottomInset,
        field.bottom - radius,
      )
      ..lineTo(field.left + topInset - 2, field.top + radius)
      ..quadraticBezierTo(
        field.left + topInset,
        field.top,
        field.left + topInset + radius,
        field.top,
      )
      ..close();
  }

  static Offset projectDisplayPoint(
    Offset point,
    double width,
    double height,
  ) {
    final field = fieldRect(width, height);
    final normalizedY = point.dy.clamp(0.0, 1.0);
    final perspectiveY = math.pow(normalizedY, .94).toDouble();
    final leftInset = _perspectiveInset(field, perspectiveY);
    final rightInset = leftInset;
    final left = field.left + leftInset;
    final right = field.right - rightInset;
    return Offset(
      _lerp(left, right, point.dx.clamp(0.0, 1.0)),
      _lerp(field.top, field.bottom, perspectiveY),
    );
  }

  static double perspectiveScale(double displayY) =>
      _lerp(.84, 1.03, displayY.clamp(0.0, 1.0));

  static void drawPitch(Canvas canvas, double width, double height) {
    final field = fieldRect(width, height);
    final pitch = pitchPath(width, height);
    final basePaint = Paint()
      ..shader = Gradient.linear(
        field.topCenter,
        field.bottomCenter,
        const [
          Color(0xFF4CAE3F),
          Color(0xFF3B9A38),
          Color(0xFF267229),
        ],
        const [0, .48, 1],
      );
    canvas.drawPath(pitch, basePaint);

    for (var index = 0; index < 10; index++) {
      final start = index / 10;
      final end = (index + 1) / 10;
      final stripe = _quad(width, height, start, 0, end, 1);
      canvas.drawPath(
        stripe,
        Paint()
          ..color = index.isEven
              ? const Color(0x22FFFFFF)
              : const Color(0x1D000000),
      );
    }

    for (var row = 0; row < 14; row++) {
      final top = row / 14;
      final bottom = (row + 1) / 14;
      if (row.isOdd) continue;
      canvas.drawPath(
        _quad(width, height, 0, top, 1, bottom),
        Paint()..color = const Color(0x05000000),
      );
    }

    _drawPitchShading(canvas, field);
    _drawPitchMarkings(canvas, width, height);
  }

  static void drawPitchBorder(Canvas canvas, Path pitch) {
    canvas.drawPath(
      pitch,
      Paint()
        ..color = const Color(0xE4F3FFF4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.35,
    );
    canvas.drawPath(
      pitch,
      Paint()
        ..color = const Color(0x33000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }

  static void drawVignette(Canvas canvas, Rect field) {
    final vignette = Paint()
      ..shader = Gradient.radial(
        field.center,
        field.longestSide * .7,
        const [Color(0x00000000), Color(0x70000000)],
        const [.42, 1],
      );
    canvas.drawRect(field.inflate(22), vignette);
  }

  static void _drawPitchShading(Canvas canvas, Rect field) {
    final wash = Paint()
      ..shader = Gradient.linear(
        field.topCenter,
        field.bottomCenter,
        const [
          Color(0x26000000),
          Color(0x00FFFFFF),
          Color(0x11000000),
          Color(0x22000000),
        ],
        const [0, .28, .7, 1],
      );
    canvas.drawRect(field, wash);

    final spotlight = Paint()
      ..shader = Gradient.radial(
        Offset(field.center.dx, field.top + field.height * .32),
        field.width * .58,
        const [Color(0x2EFFFFFF), Color(0x00000000)],
      );
    canvas.drawRect(field, spotlight);
  }

  static void _drawPitchMarkings(
    Canvas canvas,
    double width,
    double height,
  ) {
    final line = Paint()
      ..color = const Color(0xFAFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    _drawPolygon(
      canvas,
      width,
      height,
      const [
        Offset(.026, .032),
        Offset(.974, .032),
        Offset(.974, .968),
        Offset(.026, .968),
      ],
      line,
      close: true,
    );

    _drawLine(canvas, width, height, const Offset(.5, .032), const Offset(.5, .968), line);
    _drawEllipse(canvas, width, height, const Offset(.5, .5), .1, .17, line);
    canvas.drawCircle(
      projectDisplayPoint(const Offset(.5, .5), width, height),
      2.0,
      Paint()..color = const Color(0xF8FFFFFF),
    );

    _drawBox(canvas, width, height, .026, .185, .205, .795, line);
    _drawBox(canvas, width, height, .815, .974, .205, .795, line);
    _drawBox(canvas, width, height, .026, .084, .35, .65, line);
    _drawBox(canvas, width, height, .916, .974, .35, .65, line);

    for (final spot in [const Offset(.13, .5), const Offset(.87, .5)]) {
      canvas.drawCircle(
        projectDisplayPoint(spot, width, height),
        1.75,
        Paint()..color = const Color(0xEFFFFFFF),
      );
    }

    _drawArc(
      canvas,
      width,
      height,
      center: const Offset(.13, .5),
      radiusX: .068,
      radiusY: .112,
      start: -1.16,
      end: 1.16,
      paint: line,
    );
    _drawArc(
      canvas,
      width,
      height,
      center: const Offset(.87, .5),
      radiusX: .068,
      radiusY: .112,
      start: math.pi - 1.16,
      end: math.pi + 1.16,
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
    final frontTop = projectDisplayPoint(
      Offset(left ? .026 : .974, .39),
      width,
      height,
    );
    final frontBottom = projectDisplayPoint(
      Offset(left ? .026 : .974, .61),
      width,
      height,
    );
    final depth = math.min(16.0, width * .026);
    final direction = left ? -1.0 : 1.0;
    final backTop = frontTop.translate(direction * depth, -5);
    final backBottom = frontBottom.translate(direction * depth, 5);
    final framePaint = Paint()
      ..color = const Color(0xEFFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final netPaint = Paint()
      ..color = const Color(0x8CFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .7;

    final frame = Path()
      ..moveTo(frontTop.dx, frontTop.dy)
      ..lineTo(frontBottom.dx, frontBottom.dy)
      ..lineTo(backBottom.dx, backBottom.dy)
      ..lineTo(backTop.dx, backTop.dy)
      ..close();
    canvas.drawPath(frame, framePaint);

    for (var index = 1; index <= 5; index++) {
      final t = index / 6;
      canvas.drawLine(
        Offset.lerp(frontTop, frontBottom, t)!,
        Offset.lerp(backTop, backBottom, t)!,
        netPaint,
      );
    }
    for (var index = 1; index <= 3; index++) {
      final t = index / 4;
      canvas.drawLine(
        Offset.lerp(frontTop, backTop, t)!,
        Offset.lerp(frontBottom, backBottom, t)!,
        netPaint,
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
          trailStart,
          ball,
          Paint()
            ..color = replay
                ? const Color(0xAAFFFFFF)
                : const Color(0x7DFFFFFF)
            ..style = PaintingStyle.stroke
            ..strokeWidth = replay ? 1.3 : 1.05,
        );
      }
    }

    if (woodwork) {
      canvas.drawCircle(
        ball,
        10.5,
        Paint()..color = const Color(0x20FFEE88),
      );
    }

    drawMatchBallGraphic(
      canvas,
      center: ball,
      radius: replay ? 5.1 : 4.5,
      style: style,
    );
  }

  static void _drawTrajectoryArrow(
    Canvas canvas,
    Offset from,
    Offset to,
    Paint paint,
  ) {
    final vector = to - from;
    final length = vector.distance;
    if (length < 8) return;
    final unit = Offset(vector.dx / length, vector.dy / length);
    final tipBase = to - unit * 6;
    canvas.drawLine(from, tipBase, paint);
    final left = Offset(-unit.dy, unit.dx);
    canvas.drawLine(to, tipBase + left * 3, paint);
    canvas.drawLine(to, tipBase - left * 3, paint);
  }

  static Path _quad(
    double width,
    double height,
    double left,
    double top,
    double right,
    double bottom,
  ) => Path()
    ..moveTo(projectDisplayPoint(Offset(left, top), width, height).dx,
        projectDisplayPoint(Offset(left, top), width, height).dy)
    ..lineTo(projectDisplayPoint(Offset(right, top), width, height).dx,
        projectDisplayPoint(Offset(right, top), width, height).dy)
    ..lineTo(projectDisplayPoint(Offset(right, bottom), width, height).dx,
        projectDisplayPoint(Offset(right, bottom), width, height).dy)
    ..lineTo(projectDisplayPoint(Offset(left, bottom), width, height).dx,
        projectDisplayPoint(Offset(left, bottom), width, height).dy)
    ..close();

  static void _drawPolygon(
    Canvas canvas,
    double width,
    double height,
    List<Offset> points,
    Paint paint, {
    bool close = false,
  }) {
    if (points.isEmpty) return;
    final path = Path()
      ..moveTo(
        projectDisplayPoint(points.first, width, height).dx,
        projectDisplayPoint(points.first, width, height).dy,
      );
    for (final point in points.skip(1)) {
      final projected = projectDisplayPoint(point, width, height);
      path.lineTo(projected.dx, projected.dy);
    }
    if (close) path.close();
    canvas.drawPath(path, paint);
  }

  static void _drawLine(
    Canvas canvas,
    double width,
    double height,
    Offset from,
    Offset to,
    Paint paint,
  ) => canvas.drawLine(
        projectDisplayPoint(from, width, height),
        projectDisplayPoint(to, width, height),
        paint,
      );

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
    for (var step = 0; step <= 36; step++) {
      final angle = step / 36 * math.pi * 2;
      points.add(
        Offset(
          center.dx + math.cos(angle) * radiusX,
          center.dy + math.sin(angle) * radiusY,
        ),
      );
    }
    _drawPolygon(canvas, width, height, points, paint, close: true);
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
  ) => _drawPolygon(
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
    for (var step = 0; step <= 20; step++) {
      final t = step / 20;
      final angle = start + (end - start) * t;
      points.add(
        Offset(
          center.dx + math.cos(angle) * radiusX,
          center.dy + math.sin(angle) * radiusY,
        ),
      );
    }
    _drawPolygon(canvas, width, height, points, paint);
  }

  static double _perspectiveInset(Rect field, double y) =>
      _lerp(field.width * .085, field.width * .01, y.clamp(0.0, 1.0));

  static double _lerp(double start, double end, double t) =>
      start + (end - start) * t;
}
