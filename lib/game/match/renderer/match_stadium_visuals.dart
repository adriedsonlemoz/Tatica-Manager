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
    Image? crowdImage,
  }) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, height),
      Paint()
        ..shader = Gradient.linear(
          const Offset(0, 0),
          Offset(0, height),
          const [
            Color(0xFF04080B),
            Color(0xFF0B1216),
            Color(0xFF111A18),
          ],
          const [0, .42, 1],
        ),
    );

    if (crowdImage != null) {
      _drawCrowdImage(canvas, width, height, crowdImage);
    } else {
      _drawBowl(canvas, width, height, fieldRect);
      _drawCrowd(
        canvas,
        width,
        height,
        fieldRect,
        homeColor,
        awayColor,
        elapsed,
        crowdIntensity,
      );
      _drawFloodlights(canvas, width, crowdIntensity);
    }
    _drawLedBoards(canvas, width, fieldRect, homeColor, awayColor, elapsed);
    _drawAtmosphere(canvas, width, height, crowdIntensity);
  }

  static void _drawCrowdImage(
    Canvas canvas,
    double width,
    double height,
    Image image,
  ) {
    final sourceAspect = image.width / image.height;
    final targetAspect = width / height;
    Rect source;
    if (sourceAspect > targetAspect) {
      final sourceWidth = image.height * targetAspect;
      final left = (image.width - sourceWidth) / 2;
      source = Rect.fromLTWH(left, 0, sourceWidth, image.height.toDouble());
    } else {
      final sourceHeight = image.width / targetAspect;
      final top = (image.height - sourceHeight) / 2;
      source = Rect.fromLTWH(0, top, image.width.toDouble(), sourceHeight);
    }
    final destination = Rect.fromLTWH(0, 0, width, height);
    canvas.drawImageRect(
      image,
      source,
      destination,
      Paint()..filterQuality = FilterQuality.medium,
    );
    canvas.drawRect(
      destination,
      Paint()
        ..shader = Gradient.linear(
          const Offset(0, 0),
          Offset(0, height),
          const [
            Color(0x16000000),
            Color(0x22030A08),
            Color(0x70020808),
          ],
          const [0, .48, 1],
        ),
    );
  }

  static void _drawBowl(
    Canvas canvas,
    double width,
    double height,
    Rect fieldRect,
  ) {
    final topStand = Path()
      ..moveTo(0, 0)
      ..lineTo(width, 0)
      ..lineTo(width, fieldRect.top + 7)
      ..quadraticBezierTo(
        width * .5,
        fieldRect.top - 18,
        0,
        fieldRect.top + 7,
      )
      ..close();
    canvas.drawPath(
      topStand,
      Paint()
        ..shader = Gradient.linear(
          const Offset(0, 0),
          Offset(0, fieldRect.top + 8),
          const [Color(0xFF05090D), Color(0xFF202A2A)],
        ),
    );

    final bottomStand = Path()
      ..moveTo(0, fieldRect.bottom - 3)
      ..quadraticBezierTo(
        width * .5,
        fieldRect.bottom + 22,
        width,
        fieldRect.bottom - 3,
      )
      ..lineTo(width, height)
      ..lineTo(0, height)
      ..close();
    canvas.drawPath(
      bottomStand,
      Paint()
        ..shader = Gradient.linear(
          Offset(0, fieldRect.bottom),
          Offset(0, height),
          const [Color(0xFF1A2421), Color(0xFF060A0C)],
        ),
    );

    final sidePaint = Paint()
      ..shader = Gradient.linear(
        Offset(fieldRect.left, fieldRect.center.dy),
        Offset(0, fieldRect.center.dy),
        const [Color(0xFF1D2824), Color(0xFF080D0E)],
      );
    final left = Path()
      ..moveTo(0, fieldRect.top + 4)
      ..lineTo(fieldRect.left + 22, fieldRect.top)
      ..lineTo(fieldRect.left, fieldRect.bottom)
      ..lineTo(0, fieldRect.bottom - 3)
      ..close();
    canvas.drawPath(left, sidePaint);

    final rightPaint = Paint()
      ..shader = Gradient.linear(
        Offset(fieldRect.right, fieldRect.center.dy),
        Offset(width, fieldRect.center.dy),
        const [Color(0xFF1D2824), Color(0xFF080D0E)],
      );
    final right = Path()
      ..moveTo(width, fieldRect.top + 4)
      ..lineTo(fieldRect.right - 22, fieldRect.top)
      ..lineTo(fieldRect.right, fieldRect.bottom)
      ..lineTo(width, fieldRect.bottom - 3)
      ..close();
    canvas.drawPath(right, rightPaint);

    final rail = Paint()
      ..color = const Color(0xAA68756E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .75;
    for (var row = 0; row < 4; row++) {
      final y = fieldRect.top * (.32 + row * .16);
      canvas.drawLine(Offset(12, y), Offset(width - 12, y), rail);
    }
  }

  static void _drawCrowd(
    Canvas canvas,
    double width,
    double height,
    Rect fieldRect,
    Color homeColor,
    Color awayColor,
    double elapsed,
    double crowdIntensity,
  ) {
    final energy = (.48 + crowdIntensity * .42).clamp(.42, .92).toDouble();
    final topRows = 6;
    for (var row = 0; row < topRows; row++) {
      final y = 10 + row * ((fieldRect.top - 16) / topRows);
      final count = 54 + row * 7;
      for (var index = 0; index < count; index++) {
        final x = 6 + (width - 12) * index / math.max(1, count - 1);
        _drawFanDot(
          canvas,
          x,
          y + math.sin(elapsed * 4.2 + index * .71 + row) * .65 * crowdIntensity,
          index + row,
          homeColor,
          awayColor,
          energy,
          radius: .8 + row * .08,
        );
      }
    }

    final bottomDepth = math.max(0.0, height - fieldRect.bottom).toDouble();
    if (bottomDepth > 5) {
      for (var row = 0; row < 3; row++) {
        final y = fieldRect.bottom + 6 + row * (bottomDepth / 3);
        final count = 58 + row * 8;
        for (var index = 0; index < count; index++) {
          final x = 5 + (width - 10) * index / math.max(1, count - 1);
          _drawFanDot(
            canvas,
            x,
            y + math.sin(elapsed * 4.7 + index * .63 + row) * .55 * crowdIntensity,
            index + row * 3,
            homeColor,
            awayColor,
            energy,
            radius: .9 + row * .08,
          );
        }
      }
    }

    for (var side = 0; side < 2; side++) {
      final xBase = side == 0 ? 4.0 : width - 4.0;
      for (var index = 0; index < 22; index++) {
        final t = index / 21;
        final y = fieldRect.top + 12 + t * math.max(4.0, fieldRect.height - 24);
        final x = xBase + (side == 0 ? 1 : -1) * (index % 3) * 2.2;
        _drawFanDot(
          canvas,
          x,
          y,
          index + side,
          homeColor,
          awayColor,
          energy,
          radius: .85,
        );
      }
    }
  }

  static void _drawFanDot(
    Canvas canvas,
    double x,
    double y,
    int index,
    Color homeColor,
    Color awayColor,
    double energy, {
    required double radius,
  }) {
    final base = index % 5 == 0
        ? const Color(0xFFE8ECE7)
        : index.isEven
            ? homeColor
            : awayColor;
    final color = Color.lerp(const Color(0xFF53605A), base, .62)!;
    canvas.drawCircle(
      Offset(x, y),
      radius,
      Paint()..color = color.withValues(alpha: energy),
    );
  }

  static void _drawLedBoards(
    Canvas canvas,
    double width,
    Rect fieldRect,
    Color homeColor,
    Color awayColor,
    double elapsed,
  ) {
    final boardY = fieldRect.top - 3.5;
    final board = Rect.fromLTWH(18, boardY, width - 36, 3.2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(board, const Radius.circular(2)),
      Paint()..color = const Color(0xFF1B2421),
    );
    final color = Color.lerp(
      homeColor,
      awayColor,
      .5 + math.sin(elapsed * .75) * .28,
    )!;
    final segmentWidth = math.max(28.0, width * .08);
    final progress = (elapsed * 35) % (width + segmentWidth);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(progress - segmentWidth, boardY, segmentWidth, 3.2),
        const Radius.circular(2),
      ),
      Paint()..color = color.withValues(alpha: .88),
    );
  }

  static void _drawFloodlights(
    Canvas canvas,
    double width,
    double crowdIntensity,
  ) {
    final points = <Offset>[
      Offset(width * .08, 4),
      Offset(width * .24, 2),
      Offset(width * .76, 2),
      Offset(width * .92, 4),
    ];
    for (final point in points) {
      final glow = Paint()
        ..color = const Color(0xFFFFFFFF).withValues(
          alpha: .09 + crowdIntensity * .045,
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 11);
      canvas.drawCircle(point, 10, glow);
      for (var lamp = -2; lamp <= 2; lamp++) {
        canvas.drawCircle(
          point.translate(lamp * 3.2, 0),
          1.25,
          Paint()..color = const Color(0xE8FFFFFF),
        );
      }
    }
  }

  static void _drawAtmosphere(
    Canvas canvas,
    double width,
    double height,
    double crowdIntensity,
  ) {
    final haze = Paint()
      ..shader = Gradient.radial(
        Offset(width * .5, height * .38),
        width * .55,
        [
          const Color(0xFFFFFFFF).withValues(alpha: .025 + crowdIntensity * .02),
          const Color(0x00000000),
        ],
      );
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), haze);
  }
}
