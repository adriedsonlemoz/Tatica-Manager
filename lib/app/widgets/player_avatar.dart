import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/player/player.dart';
import '../../game/player/player_avatar_identity.dart';

class PlayerAvatar extends StatelessWidget {
  const PlayerAvatar({
    super.key,
    required this.player,
    this.size = 48,
    this.accentColor = AppColors.green,
    this.showBorder = true,
  })  : identity = null,
        customImagePath = null;

  const PlayerAvatar.identity({
    super.key,
    required this.identity,
    this.size = 48,
    this.accentColor = AppColors.green,
    this.showBorder = true,
    this.customImagePath,
  }) : player = null;

  final Player? player;
  final PlayerAvatarIdentity? identity;
  final double size;
  final Color accentColor;
  final bool showBorder;
  final String? customImagePath;

  @override
  Widget build(BuildContext context) {
    final customPath = (player?.customAvatarPath ?? customImagePath)?.trim();
    if (customPath != null && customPath.isNotEmpty) {
      final file = File(customPath);
      if (file.existsSync()) {
        final radius = BorderRadius.circular(size * .26);
        return RepaintBoundary(
          child: Container(
            width: size,
            height: size,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(borderRadius: radius),
            foregroundDecoration: showBorder
                ? BoxDecoration(
                    borderRadius: radius,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: .13),
                      width: math.max(1, size * .025),
                    ),
                  )
                : null,
            child: Image.file(
              file,
              width: size,
              height: size,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
              errorBuilder: (context, error, stackTrace) => _proceduralAvatar(),
            ),
          ),
        );
      }
    }
    return _proceduralAvatar();
  }

  Widget _proceduralAvatar() {
    final resolvedIdentity = identity ?? PlayerAvatarIdentity.fromPlayer(player!);
    return RepaintBoundary(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          isComplex: true,
          willChange: false,
          painter: _PlayerAvatarPainter(
            identity: resolvedIdentity,
            accentColor: accentColor,
            showBorder: showBorder,
          ),
        ),
      ),
    );
  }
}

class _PlayerAvatarPainter extends CustomPainter {
  const _PlayerAvatarPainter({
    required this.identity,
    required this.accentColor,
    required this.showBorder,
  });

  final PlayerAvatarIdentity identity;
  final Color accentColor;
  final bool showBorder;

  static const _skinTones = <Color>[
    Color(0xFFF4D2B8),
    Color(0xFFE9B98F),
    Color(0xFFD99568),
    Color(0xFFB96F45),
    Color(0xFF8D4E31),
    Color(0xFF5F3224),
  ];

  static const _hairColors = <Color>[
    Color(0xFF171412),
    Color(0xFF3B291F),
    Color(0xFF70472D),
    Color(0xFFB07A42),
    Color(0xFF8B8B86),
  ];

  static const _eyeColors = <Color>[
    Color(0xFF3C291E),
    Color(0xFF6A4A2F),
    Color(0xFF47704C),
    Color(0xFF3E6278),
    Color(0xFF77705C),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final radius = Radius.circular(w * .26);
    final bounds = Offset.zero & size;
    final clip = RRect.fromRectAndRadius(bounds, radius);
    canvas.save();
    canvas.clipRRect(clip);

    final backgroundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(AppColors.surfaceRaised, accentColor, .20)!,
          AppColors.background,
        ],
      ).createShader(bounds);
    canvas.drawRect(bounds, backgroundPaint);

    final glow = Paint()
      ..color = accentColor.withValues(alpha: .14)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * .12);
    canvas.drawCircle(Offset(w * .50, h * .54), w * .46, glow);

    _drawShirt(canvas, size);
    _drawHead(canvas, size);

    canvas.restore();
    if (showBorder) {
      canvas.drawRRect(
        clip,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1, w * .025)
          ..color = Colors.white.withValues(alpha: .13),
      );
    }
  }

  void _drawShirt(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final shirt = Paint()..color = accentColor.withValues(alpha: .82);
    final shadow = Paint()..color = Colors.black.withValues(alpha: .24);
    final shirtPath = Path()
      ..moveTo(w * .12, h)
      ..quadraticBezierTo(w * .16, h * .77, w * .37, h * .73)
      ..lineTo(w * .63, h * .73)
      ..quadraticBezierTo(w * .84, h * .77, w * .88, h)
      ..close();
    canvas.drawPath(shirtPath, shadow);
    canvas.drawPath(shirtPath.shift(Offset(0, -h * .015)), shirt);
    canvas.drawPath(
      Path()
        ..moveTo(w * .38, h * .735)
        ..quadraticBezierTo(w * .50, h * .84, w * .62, h * .735),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * .045
        ..strokeCap = StrokeCap.round
        ..color = AppColors.background.withValues(alpha: .85),
    );
  }

  void _drawHead(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final skin = _skinTones[identity.skinTone];
    final hair = _hairColors[identity.hairColor];
    final skinShadow = Color.lerp(skin, Colors.black, .15)!;
    final center = Offset(w * .50, h * .43);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * .50, h * .70), width: w * .19, height: h * .20),
        Radius.circular(w * .07),
      ),
      Paint()..color = skinShadow,
    );

    final faceRect = switch (identity.faceShape) {
      0 => Rect.fromCenter(center: center, width: w * .55, height: h * .62),
      1 => Rect.fromCenter(center: center, width: w * .58, height: h * .58),
      2 => Rect.fromCenter(center: Offset(center.dx, center.dy + h * .01), width: w * .51, height: h * .66),
      _ => Rect.fromCenter(center: center, width: w * .60, height: h * .61),
    };

    final earPaint = Paint()..color = skinShadow;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(faceRect.left, h * .45), width: w * .11, height: h * .18),
      earPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(faceRect.right, h * .45), width: w * .11, height: h * .18),
      earPaint,
    );

    final facePath = _facePath(faceRect, identity.faceShape);
    canvas.drawShadow(facePath, Colors.black, w * .025, true);
    canvas.drawPath(facePath, Paint()..color = skin);

    _drawHair(canvas, faceRect, hair, w, h);
    _drawBrowsAndEyes(canvas, faceRect, hair, w, h);
    _drawNose(canvas, w, h, skinShadow);
    _drawFacialHair(canvas, faceRect, hair, w, h);
    _drawMouth(canvas, w, h, skinShadow);
    _drawDetails(canvas, faceRect, w, h, skinShadow);
  }

  Path _facePath(Rect rect, int shape) {
    final path = Path();
    switch (shape) {
      case 1:
        path
          ..moveTo(rect.left + rect.width * .18, rect.top)
          ..quadraticBezierTo(rect.center.dx, rect.top - rect.height * .04, rect.right - rect.width * .18, rect.top)
          ..quadraticBezierTo(rect.right + rect.width * .02, rect.top + rect.height * .22, rect.right - rect.width * .04, rect.bottom - rect.height * .24)
          ..quadraticBezierTo(rect.right - rect.width * .12, rect.bottom, rect.center.dx, rect.bottom + rect.height * .03)
          ..quadraticBezierTo(rect.left + rect.width * .12, rect.bottom, rect.left + rect.width * .04, rect.bottom - rect.height * .24)
          ..quadraticBezierTo(rect.left - rect.width * .02, rect.top + rect.height * .22, rect.left + rect.width * .18, rect.top)
          ..close();
        break;
      case 2:
        path
          ..moveTo(rect.left + rect.width * .23, rect.top)
          ..quadraticBezierTo(rect.center.dx, rect.top - rect.height * .03, rect.right - rect.width * .23, rect.top)
          ..quadraticBezierTo(rect.right, rect.top + rect.height * .22, rect.right - rect.width * .09, rect.bottom - rect.height * .18)
          ..quadraticBezierTo(rect.center.dx, rect.bottom + rect.height * .04, rect.left + rect.width * .09, rect.bottom - rect.height * .18)
          ..quadraticBezierTo(rect.left, rect.top + rect.height * .22, rect.left + rect.width * .23, rect.top)
          ..close();
        break;
      case 3:
        path
          ..moveTo(rect.left + rect.width * .15, rect.top + rect.height * .02)
          ..quadraticBezierTo(rect.center.dx, rect.top - rect.height * .02, rect.right - rect.width * .15, rect.top + rect.height * .02)
          ..quadraticBezierTo(rect.right + rect.width * .02, rect.center.dy, rect.right - rect.width * .08, rect.bottom - rect.height * .10)
          ..quadraticBezierTo(rect.center.dx, rect.bottom + rect.height * .01, rect.left + rect.width * .08, rect.bottom - rect.height * .10)
          ..quadraticBezierTo(rect.left - rect.width * .02, rect.center.dy, rect.left + rect.width * .15, rect.top + rect.height * .02)
          ..close();
        break;
      default:
        path.addOval(rect);
        break;
    }
    return path;
  }

  void _drawHair(Canvas canvas, Rect face, Color hair, double w, double h) {
    if (identity.hairStyle == 6) return;
    final paint = Paint()..color = hair;
    final top = face.top - h * .02;
    final left = face.left - w * .01;
    final right = face.right + w * .01;

    Path cap(double depth) => Path()
      ..moveTo(left, face.top + h * .16)
      ..quadraticBezierTo(left + w * .01, top, face.center.dx, top - h * .03)
      ..quadraticBezierTo(right - w * .01, top, right, face.top + h * .16)
      ..lineTo(right - w * .04, face.top + depth)
      ..quadraticBezierTo(face.center.dx, face.top + h * .04, left + w * .04, face.top + depth)
      ..close();

    switch (identity.hairStyle) {
      case 0:
        canvas.drawPath(cap(h * .10), paint);
        break;
      case 1:
        canvas.drawPath(cap(h * .15), paint);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(face.left - w * .01, face.top + h * .10, w * .08, h * .24),
            Radius.circular(w * .03),
          ),
          paint,
        );
        break;
      case 2:
        canvas.drawPath(cap(h * .11), paint);
        final sweep = Path()
          ..moveTo(face.left + w * .10, face.top + h * .03)
          ..quadraticBezierTo(face.center.dx, face.top - h * .12, face.right - w * .03, face.top + h * .08)
          ..quadraticBezierTo(face.center.dx, face.top + h * .03, face.left + w * .10, face.top + h * .03)
          ..close();
        canvas.drawPath(sweep, paint);
        break;
      case 3:
        for (var i = 0; i < 6; i++) {
          final x = face.left + face.width * (.12 + i * .15);
          canvas.drawCircle(Offset(x, face.top + h * (.02 + (i.isEven ? .01 : .04))), w * .10, paint);
        }
        break;
      case 4:
        canvas.drawPath(cap(h * .09), paint);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(face.left + w * .10, face.top - h * .08, face.width * .65, h * .12),
            Radius.circular(w * .05),
          ),
          paint,
        );
        break;
      case 5:
        final spikes = Path()..moveTo(face.left, face.top + h * .14);
        for (var i = 0; i <= 8; i++) {
          final x = face.left + face.width * (i / 8);
          final y = face.top - h * (i.isEven ? .08 : .01);
          spikes.lineTo(x, y);
        }
        spikes
          ..lineTo(face.right, face.top + h * .14)
          ..quadraticBezierTo(face.center.dx, face.top + h * .05, face.left, face.top + h * .14)
          ..close();
        canvas.drawPath(spikes, paint);
        break;
      case 7:
        canvas.drawPath(cap(h * .17), paint);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(face.left - w * .01, face.top + h * .08, w * .07, h * .30),
            Radius.circular(w * .025),
          ),
          paint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(face.right - w * .06, face.top + h * .08, w * .07, h * .30),
            Radius.circular(w * .025),
          ),
          paint,
        );
        break;
    }

    final highlight = Paint()..color = Colors.white.withValues(alpha: .08);
    canvas.drawArc(
      Rect.fromLTWH(face.left + w * .08, face.top, face.width * .58, h * .14),
      math.pi * 1.08,
      math.pi * .55,
      false,
      highlight..strokeWidth = w * .025..style = PaintingStyle.stroke,
    );
  }

  void _drawBrowsAndEyes(Canvas canvas, Rect face, Color hair, double w, double h) {
    final eyeY = face.top + face.height * .43;
    final dx = face.width * .21;
    final eyeWidth = w * (identity.eyeStyle == 2 ? .105 : .12);
    final eyeHeight = h * (identity.eyeStyle == 1 ? .035 : .045);
    final browPaint = Paint()
      ..color = hair.withValues(alpha: .90)
      ..strokeWidth = w * (identity.eyebrowStyle == 2 ? .045 : .035)
      ..strokeCap = StrokeCap.round;

    for (final side in [-1.0, 1.0]) {
      final center = Offset(face.center.dx + side * dx, eyeY);
      final eyeRect = Rect.fromCenter(center: center, width: eyeWidth, height: eyeHeight);
      canvas.drawOval(eyeRect, Paint()..color = const Color(0xFFF6F1E7));
      final iris = _eyeColors[identity.eyeColor];
      canvas.drawCircle(center, eyeHeight * .42, Paint()..color = iris);
      canvas.drawCircle(center, eyeHeight * .19, Paint()..color = const Color(0xFF151515));
      canvas.drawCircle(center.translate(-eyeHeight * .10, -eyeHeight * .10), eyeHeight * .07, Paint()..color = Colors.white.withValues(alpha: .8));

      final tilt = identity.eyebrowStyle == 1 ? side * h * .012 : identity.eyebrowStyle == 3 ? -side * h * .012 : 0.0;
      canvas.drawLine(
        Offset(center.dx - eyeWidth * .50, eyeY - h * .075 - tilt),
        Offset(center.dx + eyeWidth * .48, eyeY - h * .075 + tilt),
        browPaint,
      );
    }
  }

  void _drawNose(Canvas canvas, double w, double h, Color shadow) {
    final paint = Paint()
      ..color = shadow.withValues(alpha: .58)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * .026
      ..strokeCap = StrokeCap.round;
    final x = w * .50;
    final top = h * .43;
    final bottom = h * .57;
    final offset = switch (identity.noseStyle) { 1 => w * .025, 2 => -w * .02, _ => 0.0 };
    final path = Path()
      ..moveTo(x + offset, top)
      ..quadraticBezierTo(x + w * .025, h * .51, x + offset * .2, bottom)
      ..quadraticBezierTo(x + w * .045, bottom + h * .018, x + w * .065, bottom - h * .005);
    canvas.drawPath(path, paint);
  }

  void _drawMouth(Canvas canvas, double w, double h, Color shadow) {
    final y = h * .64;
    final half = w * (identity.mouthStyle == 2 ? .09 : .075);
    final curve = identity.mouthStyle == 1 ? h * .015 : identity.mouthStyle == 3 ? -h * .012 : 0.0;
    final path = Path()
      ..moveTo(w * .50 - half, y)
      ..quadraticBezierTo(w * .50, y + curve, w * .50 + half, y);
    canvas.drawPath(
      path,
      Paint()
        ..color = shadow.withValues(alpha: .78)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * .025
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawFacialHair(Canvas canvas, Rect face, Color hair, double w, double h) {
    if (identity.beardStyle == 0 && identity.moustacheStyle == 0) return;
    final beard = Paint()..color = hair.withValues(alpha: identity.beardStyle == 1 ? .30 : .78);

    if (identity.beardStyle > 0) {
      switch (identity.beardStyle) {
        case 1:
          for (var i = 0; i < 16; i++) {
            final angle = math.pi * (.10 + i / 20);
            final x = face.center.dx + math.cos(angle) * face.width * .34;
            final y = h * .61 + math.sin(angle) * h * .09;
            canvas.drawCircle(Offset(x, y), w * .008, beard);
          }
          break;
        case 2:
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(center: Offset(w * .50, h * .68), width: w * .15, height: h * .12),
              Radius.circular(w * .06),
            ),
            beard,
          );
          break;
        case 3:
          final jaw = Path()
            ..moveTo(face.left + w * .04, h * .57)
            ..quadraticBezierTo(face.left + w * .08, face.bottom, w * .50, face.bottom + h * .01)
            ..quadraticBezierTo(face.right - w * .08, face.bottom, face.right - w * .04, h * .57)
            ..lineTo(face.right - w * .10, h * .61)
            ..quadraticBezierTo(w * .50, h * .78, face.left + w * .10, h * .61)
            ..close();
          canvas.drawPath(jaw, beard);
          break;
        case 4:
          final full = Path()
            ..moveTo(face.left + w * .02, h * .53)
            ..quadraticBezierTo(face.left + w * .05, face.bottom + h * .01, w * .50, face.bottom + h * .05)
            ..quadraticBezierTo(face.right - w * .05, face.bottom + h * .01, face.right - w * .02, h * .53)
            ..lineTo(face.right - w * .08, h * .60)
            ..quadraticBezierTo(w * .50, h * .80, face.left + w * .08, h * .60)
            ..close();
          canvas.drawPath(full, beard);
          break;
      }
    }

    if (identity.moustacheStyle > 0) {
      final y = h * .595;
      final thickness = identity.moustacheStyle == 2 ? h * .026 : h * .018;
      final moustache = Paint()
        ..color = hair.withValues(alpha: .86)
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(w * .435, y), Offset(w * .495, y + h * .006), moustache);
      canvas.drawLine(Offset(w * .505, y + h * .006), Offset(w * .565, y), moustache);
    }
  }

  void _drawDetails(Canvas canvas, Rect face, double w, double h, Color shadow) {
    final paint = Paint()..color = shadow.withValues(alpha: .34);
    if (identity.ageStyle > 0) {
      final agePaint = Paint()
        ..color = shadow.withValues(alpha: identity.ageStyle == 2 ? .22 : .13)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * .009;
      canvas.drawArc(Rect.fromLTWH(face.left + face.width * .16, h * .43, face.width * .22, h * .08), .15, 2.7, false, agePaint);
      canvas.drawArc(Rect.fromLTWH(face.right - face.width * .38, h * .43, face.width * .22, h * .08), .30, 2.7, false, agePaint);
      if (identity.ageStyle == 2) {
        canvas.drawLine(Offset(w * .40, h * .62), Offset(w * .46, h * .63), agePaint);
        canvas.drawLine(Offset(w * .54, h * .63), Offset(w * .60, h * .62), agePaint);
      }
    }
    switch (identity.detailStyle) {
      case 1:
        canvas.drawCircle(Offset(face.left + face.width * .28, h * .54), w * .012, paint);
        break;
      case 2:
        canvas.drawCircle(Offset(face.right - face.width * .24, h * .57), w * .010, paint);
        canvas.drawCircle(Offset(face.right - face.width * .29, h * .60), w * .007, paint);
        break;
      case 3:
        canvas.drawLine(
          Offset(face.left + face.width * .20, h * .50),
          Offset(face.left + face.width * .30, h * .515),
          Paint()
            ..color = shadow.withValues(alpha: .30)
            ..strokeWidth = w * .012,
        );
        break;
      case 4:
        canvas.drawCircle(Offset(face.left + face.width * .25, h * .47), w * .008, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _PlayerAvatarPainter oldDelegate) =>
      identity != oldDelegate.identity ||
      accentColor != oldDelegate.accentColor ||
      showBorder != oldDelegate.showBorder;
}
