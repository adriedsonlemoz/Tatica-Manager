import 'dart:math' as math;
import 'dart:ui';

abstract final class MatchStadiumVisuals {
  static void draw(
    Canvas canvas,
    double width,
    double height, {
    required Rect fieldRect,
    required Color homeColor,
    required Color awayColor,
    required double elapsed,
    required double crowdIntensity,
  }) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, height),
      Paint()
        ..shader = Gradient.linear(
          const Offset(0, 0),
          Offset(0, height),
          const [Color(0xFF050A08), Color(0xFF111A15)],
        ),
    );

    _stand(canvas, width, fieldRect.top, top: true);
    _stand(canvas, width, height - fieldRect.bottom, top: false, y: fieldRect.bottom);
    _sideStand(canvas, fieldRect, left: true);
    _sideStand(canvas, fieldRect, left: false);
    _crowd(
      canvas,
      width,
      fieldRect,
      homeColor,
      awayColor,
      elapsed,
      crowdIntensity,
    );
    _ledBoards(canvas, fieldRect, homeColor, awayColor, elapsed);
    _dugouts(canvas, fieldRect);
    _floodlights(canvas, width, height, crowdIntensity);
  }

  static void _stand(
    Canvas canvas,
    double width,
    double depth, {
    required bool top,
    double y = 0,
  }) {
    if (depth <= 2) return;
    final rect = Rect.fromLTWH(8, top ? 2 : y, width - 16, math.max(4.0, depth - 3).toDouble());
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(5)),
      Paint()..color = const Color(0xFF171D1A),
    );
    for (var row = 1; row < 3; row++) {
      final yy = top
          ? rect.top + rect.height * row / 3
          : rect.bottom - rect.height * row / 3;
      canvas.drawLine(
        Offset(rect.left + 4, yy),
        Offset(rect.right - 4, yy),
        Paint()
          ..color = const Color(0xFF2A322E)
          ..strokeWidth = 1,
      );
    }
  }

  static void _sideStand(Canvas canvas, Rect fieldRect, {required bool left}) {
    final x = left ? 2.0 : fieldRect.right + 2;
    final width = math.max(4.0, left ? fieldRect.left - 4 : 12.0).toDouble();
    final rect = Rect.fromLTWH(x, fieldRect.top + 14, width, fieldRect.height - 28);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      Paint()..color = const Color(0xFF141A17),
    );
  }

  static void _crowd(
    Canvas canvas,
    double width,
    Rect fieldRect,
    Color homeColor,
    Color awayColor,
    double elapsed,
    double crowdIntensity,
  ) {
    final pulse = .55 + math.sin(elapsed * 7) * .10 * crowdIntensity;
    for (var index = 0; index < 44; index++) {
      final x = 10 + (width - 20) * index / 43;
      final teamColor = index.isEven ? homeColor : awayColor;
      final paint = Paint()
        ..color = Color.lerp(
          const Color(0xAAFFFFFF),
          teamColor,
          .55,
        )!.withValues(
          alpha: (.30 + pulse * .32).clamp(.25, .82).toDouble(),
        );
      final wave = math.sin(elapsed * (4 + (index % 4)) + index * .7);
      final radius = 1.0 + crowdIntensity * .45 + wave.abs() * .18;
      canvas.drawCircle(Offset(x, fieldRect.top * .48 + wave * .7), radius, paint);
      canvas.drawCircle(
        Offset(x, fieldRect.bottom + (fieldRect.top * .50) - wave * .65),
        radius,
        paint,
      );
    }
  }

  static void _ledBoards(
    Canvas canvas,
    Rect fieldRect,
    Color homeColor,
    Color awayColor,
    double elapsed,
  ) {
    final progress = (elapsed * 42) % fieldRect.width;
    final y = fieldRect.top - 3;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(fieldRect.left + 8, y, fieldRect.width - 16, 2.5),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF202824),
    );
    final color = Color.lerp(homeColor, awayColor, .5 + math.sin(elapsed) * .25)!;
    canvas.drawRect(
      Rect.fromLTWH(fieldRect.left + progress, y, 26, 2.5),
      Paint()..color = color.withValues(alpha: .72),
    );
  }

  static void _dugouts(Canvas canvas, Rect fieldRect) {
    final benchPaint = Paint()..color = const Color(0xCC9DB3A8);
    for (final centerX in [fieldRect.center.dx - 38, fieldRect.center.dx + 38]) {
      final rect = Rect.fromCenter(
        center: Offset(centerX, fieldRect.bottom + 7),
        width: 42,
        height: 7,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3)),
        Paint()..color = const Color(0x9927352F),
      );
      canvas.drawLine(rect.bottomLeft, rect.bottomRight, benchPaint..strokeWidth = .8);
    }
  }

  static void _floodlights(
    Canvas canvas,
    double width,
    double height,
    double crowdIntensity,
  ) {
    final glow = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: .08 + crowdIntensity * .05)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    for (final point in [
      const Offset(7, 7),
      Offset(width - 7, 7),
      Offset(7, height - 7),
      Offset(width - 7, height - 7),
    ]) {
      canvas.drawCircle(point, 8, glow);
      canvas.drawCircle(point, 1.8, Paint()..color = const Color(0xCCFFFFFF));
    }
  }
}
