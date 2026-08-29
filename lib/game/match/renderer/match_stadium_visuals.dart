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
    final background = Rect.fromLTWH(0, 0, width, height);
    canvas.drawRect(
      background,
      Paint()
        ..shader = Gradient.linear(
          const Offset(0, 0),
          Offset(0, height),
          const [
            Color(0xFF081015),
            Color(0xFF0C141B),
            Color(0xFF0E181D),
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
    }

    _drawPitchSurround(canvas, fieldRect);
    _drawLedBoards(canvas, width, fieldRect, homeColor, awayColor, elapsed);
    _drawFloodlights(canvas, width, fieldRect, crowdIntensity);
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
      Paint()..filterQuality = FilterQuality.high,
    );
    canvas.drawRect(
      destination,
      Paint()
        ..shader = Gradient.linear(
          const Offset(0, 0),
          Offset(0, height),
          const [
            Color(0x08000000),
            Color(0x20010608),
            Color(0x70010608),
          ],
          const [0, .45, 1],
        ),
    );
  }

  static void _drawPitchSurround(Canvas canvas, Rect fieldRect) {
    final surround = fieldRect.inflate(12);
    canvas.drawRRect(
      RRect.fromRectAndRadius(surround, const Radius.circular(20)),
      Paint()..color = const Color(0x26000000),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(surround, const Radius.circular(20)),
      Paint()
        ..color = const Color(0x8CFFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = .7,
    );

    final edge = Paint()
      ..shader = Gradient.linear(
        surround.topLeft,
        surround.bottomLeft,
        const [Color(0xFF1B2227), Color(0xFF090E12)],
      );
    canvas.drawRect(
      Rect.fromLTWH(surround.left, surround.top, surround.width, 9),
      edge,
    );
    canvas.drawRect(
      Rect.fromLTWH(surround.left, surround.bottom - 12, surround.width, 12),
      Paint()..color = const Color(0xD10C1014),
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
      ..lineTo(width, fieldRect.top - 8)
      ..quadraticBezierTo(width * .5, fieldRect.top - 32, 0, fieldRect.top - 8)
      ..close();
    canvas.drawPath(
      topStand,
      Paint()
        ..shader = Gradient.linear(
          const Offset(0, 0),
          Offset(0, fieldRect.top),
          const [Color(0xFF05090D), Color(0xFF1E262A)],
        ),
    );

    final bottomStand = Path()
      ..moveTo(0, fieldRect.bottom + 2)
      ..quadraticBezierTo(width * .5, fieldRect.bottom + 30, width, fieldRect.bottom + 2)
      ..lineTo(width, height)
      ..lineTo(0, height)
      ..close();
    canvas.drawPath(
      bottomStand,
      Paint()
        ..shader = Gradient.linear(
          Offset(0, fieldRect.bottom),
          Offset(0, height),
          const [Color(0xFF1E2626), Color(0xFF070B0E)],
        ),
    );

    final sideLeft = Path()
      ..moveTo(0, fieldRect.top - 8)
      ..lineTo(fieldRect.left + 18, fieldRect.top + 10)
      ..lineTo(fieldRect.left - 4, fieldRect.bottom - 10)
      ..lineTo(0, fieldRect.bottom + 4)
      ..close();
    canvas.drawPath(
      sideLeft,
      Paint()
        ..shader = Gradient.linear(
          Offset(fieldRect.left, fieldRect.top),
          const Offset(0, 0),
          const [Color(0xFF1B252A), Color(0xFF070A0E)],
        ),
    );

    final sideRight = Path()
      ..moveTo(width, fieldRect.top - 8)
      ..lineTo(fieldRect.right - 18, fieldRect.top + 10)
      ..lineTo(fieldRect.right + 4, fieldRect.bottom - 10)
      ..lineTo(width, fieldRect.bottom + 4)
      ..close();
    canvas.drawPath(
      sideRight,
      Paint()
        ..shader = Gradient.linear(
          Offset(fieldRect.right, fieldRect.top),
          Offset(width, 0),
          const [Color(0xFF1B252A), Color(0xFF070A0E)],
        ),
    );
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
    final energy = (.5 + crowdIntensity * .38).clamp(.42, .9).toDouble();
    final topRows = 7;
    for (var row = 0; row < topRows; row++) {
      final y = 10 + row * ((fieldRect.top - 18) / topRows);
      final count = 62 + row * 8;
      for (var index = 0; index < count; index++) {
        final x = 6 + (width - 12) * index / math.max(1, count - 1);
        _drawFanDot(
          canvas,
          x,
          y + math.sin(elapsed * 4.1 + index * .62 + row) * .7 * crowdIntensity,
          index + row,
          homeColor,
          awayColor,
          energy,
          radius: .85 + row * .08,
        );
      }
    }

    final bottomDepth = math.max(0.0, height - fieldRect.bottom).toDouble();
    for (var row = 0; row < 3; row++) {
      final y = fieldRect.bottom + 6 + row * (bottomDepth / 3);
      final count = 66 + row * 6;
      for (var index = 0; index < count; index++) {
        final x = 5 + (width - 10) * index / math.max(1, count - 1);
        _drawFanDot(
          canvas,
          x,
          y + math.sin(elapsed * 4.5 + index * .58 + row) * .55 * crowdIntensity,
          index + row * 4,
          homeColor,
          awayColor,
          energy,
          radius: .9 + row * .08,
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
    final color = Color.lerp(const Color(0xFF4A5755), base, .6)!;
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
    final boardY = fieldRect.top - 4.5;
    final board = Rect.fromLTWH(22, boardY, width - 44, 4.0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(board, const Radius.circular(2.5)),
      Paint()..color = const Color(0xFF1A2326),
    );
    final color = Color.lerp(homeColor, awayColor, .5 + math.sin(elapsed * .7) * .28)!;
    final segmentWidth = math.max(36.0, width * .085);
    final progress = (elapsed * 38) % (width + segmentWidth);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(progress - segmentWidth, boardY, segmentWidth, 4.0),
        const Radius.circular(2.5),
      ),
      Paint()..color = color.withValues(alpha: .88),
    );
  }

  static void _drawFloodlights(
    Canvas canvas,
    double width,
    Rect fieldRect,
    double crowdIntensity,
  ) {
    final anchors = <Offset>[
      Offset(width * .08, 8),
      Offset(width * .25, 5),
      Offset(width * .75, 5),
      Offset(width * .92, 8),
    ];
    for (final point in anchors) {
      canvas.drawCircle(
        point,
        12,
        Paint()
          ..color = const Color(0xFFFFFFFF).withValues(alpha: .06 + crowdIntensity * .05)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
      );
      for (var lamp = -3; lamp <= 3; lamp++) {
        canvas.drawCircle(
          point.translate(lamp * 3.4, 0),
          1.2,
          Paint()..color = const Color(0xF2FFFFFF),
        );
      }
      canvas.drawPath(
        Path()
          ..moveTo(point.dx - 10, fieldRect.top - 8)
          ..quadraticBezierTo(point.dx, fieldRect.top + 10, point.dx + 10, fieldRect.top - 8),
        Paint()
          ..shader = Gradient.linear(
            point,
            Offset(point.dx, fieldRect.top + fieldRect.height * .32),
            const [Color(0x26FFFFFF), Color(0x00FFFFFF)],
          ),
      );
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
        Offset(width * .5, height * .34),
        width * .62,
        [
          const Color(0xFFFFFFFF).withValues(alpha: .028 + crowdIntensity * .018),
          const Color(0x00000000),
        ],
      );
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), haze);
  }
}
