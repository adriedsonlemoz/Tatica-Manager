import 'dart:math' as math;
import 'dart:ui';

class MatchBallStyleSpec {
  const MatchBallStyleSpec({
    required this.id,
    required this.label,
    required this.shortLabel,
    required this.baseColor,
    required this.detailColor,
  });

  final int id;
  final String label;
  final String shortLabel;
  final Color baseColor;
  final Color detailColor;

  static const values = <MatchBallStyleSpec>[
    MatchBallStyleSpec(
      id: 0,
      label: 'Clássica',
      shortLabel: 'Clássica',
      baseColor: Color(0xFFFFFFFF),
      detailColor: Color(0xFF101010),
    ),
    MatchBallStyleSpec(
      id: 1,
      label: 'Branca e verde',
      shortLabel: 'Verde',
      baseColor: Color(0xFFF5FFF6),
      detailColor: Color(0xFF6CD91B),
    ),
    MatchBallStyleSpec(
      id: 2,
      label: 'Amarela',
      shortLabel: 'Amarela',
      baseColor: Color(0xFFFFD83D),
      detailColor: Color(0xFF342A14),
    ),
    MatchBallStyleSpec(
      id: 3,
      label: 'Retrô',
      shortLabel: 'Retrô',
      baseColor: Color(0xFFF2E2BE),
      detailColor: Color(0xFF7B4E2F),
    ),
  ];

  static MatchBallStyleSpec resolve(int id) =>
      values.firstWhere((item) => item.id == id, orElse: () => values.first);
}

void drawMatchBallGraphic(
  Canvas canvas, {
  required Offset center,
  required double radius,
  required int style,
}) {
  final spec = MatchBallStyleSpec.resolve(style);
  final base = Paint()..color = spec.baseColor;
  final detail = Paint()
    ..color = spec.detailColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = math.max(.7, radius * .16)
    ..strokeCap = StrokeCap.round;

  canvas.drawCircle(center, radius, base);
  canvas.drawCircle(center, radius, detail);

  switch (style) {
    case 1:
      canvas.drawCircle(center, radius * .28, Paint()..color = spec.detailColor);
      for (var i = 0; i < 4; i++) {
        final angle = i * math.pi / 2 + math.pi / 4;
        final start = center + Offset(math.cos(angle), math.sin(angle)) * radius * .36;
        final end = center + Offset(math.cos(angle), math.sin(angle)) * radius * .82;
        canvas.drawLine(start, end, detail);
      }
      break;
    case 2:
      for (var i = 0; i < 5; i++) {
        final angle = i * math.pi * 2 / 5 - math.pi / 2;
        final point = center + Offset(math.cos(angle), math.sin(angle)) * radius * .55;
        canvas.drawLine(center, point, detail);
      }
      canvas.drawCircle(center, radius * .16, Paint()..color = spec.detailColor);
      break;
    case 3:
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * .72),
        -.9,
        1.8,
        false,
        detail,
      );
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * .72),
        math.pi - .9,
        1.8,
        false,
        detail,
      );
      canvas.drawLine(
        center.translate(-radius * .72, 0),
        center.translate(radius * .72, 0),
        detail,
      );
      break;
    default:
      final patch = Path();
      for (var i = 0; i < 5; i++) {
        final angle = -math.pi / 2 + i * math.pi * 2 / 5;
        final point = center + Offset(math.cos(angle), math.sin(angle)) * radius * .28;
        if (i == 0) {
          patch.moveTo(point.dx, point.dy);
        } else {
          patch.lineTo(point.dx, point.dy);
        }
      }
      patch.close();
      canvas.drawPath(patch, Paint()..color = spec.detailColor);
      for (var i = 0; i < 5; i++) {
        final angle = -math.pi / 2 + i * math.pi * 2 / 5;
        final start = center + Offset(math.cos(angle), math.sin(angle)) * radius * .35;
        final end = center + Offset(math.cos(angle), math.sin(angle)) * radius * .78;
        canvas.drawLine(start, end, detail);
      }
  }

  canvas.drawCircle(
    center.translate(-radius * .28, -radius * .30),
    radius * .12,
    Paint()..color = const Color(0x55FFFFFF),
  );
}
