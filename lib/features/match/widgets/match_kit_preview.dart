import 'package:flutter/material.dart';

import '../../../domain/club/club.dart';

class MatchKitPreview extends StatelessWidget {
  const MatchKitPreview({super.key, required this.kit, required this.size});

  final ClubKit kit;
  final double size;

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size.square(size),
        painter: _MatchKitPreviewPainter(kit),
      );
}

class _MatchKitPreviewPainter extends CustomPainter {
  const _MatchKitPreviewPainter(this.kit);

  final ClubKit kit;

  @override
  void paint(Canvas canvas, Size size) {
    final shirt = Path()
      ..moveTo(size.width * .33, size.height * .16)
      ..quadraticBezierTo(
        size.width * .50,
        size.height * .27,
        size.width * .67,
        size.height * .16,
      )
      ..lineTo(size.width * .89, size.height * .31)
      ..lineTo(size.width * .76, size.height * .48)
      ..lineTo(size.width * .69, size.height * .43)
      ..lineTo(size.width * .69, size.height * .84)
      ..lineTo(size.width * .31, size.height * .84)
      ..lineTo(size.width * .31, size.height * .43)
      ..lineTo(size.width * .24, size.height * .48)
      ..lineTo(size.width * .11, size.height * .31)
      ..close();
    canvas.save();
    canvas.clipPath(shirt);
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = Color(kit.primaryHex),
    );
    _drawPattern(canvas, size, Color(kit.secondaryHex));
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width * .22, size.height),
      Paint()..color = Colors.white.withValues(alpha: .10),
    );
    canvas.restore();
    canvas.drawPath(
      shirt,
      Paint()
        ..color = Colors.white.withValues(alpha: .52)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * .50, size.height * .19),
        width: size.width * .18,
        height: size.height * .14,
      ),
      0,
      3.14,
      false,
      Paint()
        ..color = Color(kit.accentHex)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  void _drawPattern(Canvas canvas, Size size, Color secondary) {
    final paint = Paint()..color = secondary.withValues(alpha: .94);
    switch (kit.pattern) {
      case ClubKitPattern.solid:
        canvas.drawRect(
          Rect.fromLTWH(0, size.height * .36, size.width, size.height * .08),
          paint..color = secondary.withValues(alpha: .28),
        );
        break;
      case ClubKitPattern.verticalStripes:
        for (var index = 0; index < 5; index += 2) {
          canvas.drawRect(
            Rect.fromLTWH(
              size.width * index / 5,
              0,
              size.width / 5,
              size.height,
            ),
            paint,
          );
        }
        break;
      case ClubKitPattern.horizontalStripes:
        for (var index = 0; index < 5; index += 2) {
          canvas.drawRect(
            Rect.fromLTWH(
              0,
              size.height * index / 5,
              size.width,
              size.height / 5,
            ),
            paint,
          );
        }
        break;
      case ClubKitPattern.sash:
        canvas.drawPath(
          Path()
            ..moveTo(-size.width * .08, 0)
            ..lineTo(size.width * .10, 0)
            ..lineTo(size.width * 1.08, size.height)
            ..lineTo(size.width * .90, size.height)
            ..close(),
          paint,
        );
        break;
      case ClubKitPattern.halves:
        canvas.drawRect(
          Rect.fromLTWH(size.width / 2, 0, size.width / 2, size.height),
          paint,
        );
        break;
      case ClubKitPattern.gradient:
        canvas.drawRect(
          Offset.zero & size,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(kit.primaryHex), secondary],
            ).createShader(Offset.zero & size),
        );
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _MatchKitPreviewPainter oldDelegate) =>
      oldDelegate.kit.toJson().toString() != kit.toJson().toString();
}
