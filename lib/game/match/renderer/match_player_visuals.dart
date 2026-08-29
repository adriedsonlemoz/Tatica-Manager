import 'dart:math' as math;
import 'dart:ui';

import '../../../domain/club/club.dart';

enum MatchPlayerPose {
  normal,
  goalkeeperDive,
  celebration,
  penaltyReady,
}

abstract final class MatchPlayerVisuals {
  static const _skinTones = <Color>[
    Color(0xFFF1C7A2),
    Color(0xFFDFA77A),
    Color(0xFFC98A5D),
    Color(0xFFA86643),
    Color(0xFF7E452D),
    Color(0xFF5C3226),
  ];

  static void draw(
    Canvas canvas, {
    required Offset center,
    required ClubKit kit,
    required String playerId,
    required bool active,
    required double pulse,
    required bool replay,
    required bool goalkeeper,
    required double scale,
    MatchPlayerPose pose = MatchPlayerPose.normal,
    double animationPhase = 0,
    double diveDirection = 0,
  }) {
    final bounce = pose == MatchPlayerPose.celebration
        ? math.sin(animationPhase * math.pi * 4).abs() * 2.4 * scale
        : 0.0;
    final crouch = pose == MatchPlayerPose.penaltyReady
        ? math.sin(animationPhase * math.pi * 2).abs() * 1.1 * scale
        : 0.0;
    final translated = center.translate(0, -bounce + crouch);
    final dive = pose == MatchPlayerPose.goalkeeperDive;
    final angle = dive ? diveDirection.sign * .82 : 0.0;
    final hash = playerId.hashCode.abs();
    final skin = _skinTones[hash % _skinTones.length];
    final hair = _hairColor(hash);
    final primary = goalkeeper ? _goalkeeperColor(kit.primaryHex, hash) : Color(kit.primaryHex);
    final secondary = goalkeeper
        ? Color.lerp(primary, const Color(0xFFFFFFFF), .18)!
        : Color(kit.secondaryHex);
    final shorts = goalkeeper ? Color.lerp(primary, const Color(0xFF000000), .18)! : Color(kit.shortsHex);
    final socks = goalkeeper ? primary : Color(kit.socksHex);

    canvas.save();
    if (dive) {
      canvas.translate(translated.dx, translated.dy);
      canvas.rotate(angle);
      canvas.translate(-translated.dx, -translated.dy);
    }

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(translated.dx + 1.3 * scale, translated.dy + 8.8 * scale),
        width: (dive ? 20 : 17) * scale,
        height: 5.3 * scale,
      ),
      Paint()..color = const Color(0x5C000000),
    );

    final limbPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.15 * scale;
    final armLift = pose == MatchPlayerPose.celebration ? 6.3 : 2.4;
    limbPaint.color = skin;
    canvas.drawLine(
      Offset(translated.dx - 5.2 * scale, translated.dy - 1.2 * scale),
      Offset(translated.dx - 8.3 * scale, translated.dy - armLift * scale),
      limbPaint,
    );
    canvas.drawLine(
      Offset(translated.dx + 5.2 * scale, translated.dy - 1.2 * scale),
      Offset(translated.dx + 8.3 * scale, translated.dy - armLift * scale),
      limbPaint,
    );

    final legPaint = Paint()
      ..color = socks
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.55 * scale;
    canvas.drawLine(
      Offset(translated.dx - 2.2 * scale, translated.dy + 5.5 * scale),
      Offset(translated.dx - 4.1 * scale, translated.dy + 10.8 * scale),
      legPaint,
    );
    canvas.drawLine(
      Offset(translated.dx + 2.2 * scale, translated.dy + 5.5 * scale),
      Offset(translated.dx + 4.1 * scale, translated.dy + 10.8 * scale),
      legPaint,
    );

    final shortsRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(translated.dx, translated.dy + 4.2 * scale),
        width: 11.6 * scale,
        height: 5.8 * scale,
      ),
      Radius.circular(2.2 * scale),
    );
    canvas.drawRRect(shortsRect, Paint()..color = shorts);

    final torso = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(translated.dx, translated.dy - .8 * scale),
        width: 13.8 * scale,
        height: 13.0 * scale,
      ),
      Radius.circular(3.6 * scale),
    );
    _drawKit(canvas, torso, primary, secondary, kit.pattern, scale);
    canvas.drawRRect(
      torso,
      Paint()
        ..color = const Color(0xB8FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = .85 * scale,
    );

    final neck = Rect.fromCenter(
      center: Offset(translated.dx, translated.dy - 7.1 * scale),
      width: 3.1 * scale,
      height: 3.4 * scale,
    );
    canvas.drawRect(neck, Paint()..color = skin);
    final headCenter = Offset(translated.dx, translated.dy - 10.4 * scale);
    canvas.drawCircle(headCenter, 4.35 * scale, Paint()..color = skin);
    canvas.drawArc(
      Rect.fromCircle(center: headCenter.translate(0, -.6 * scale), radius: 4.35 * scale),
      math.pi,
      math.pi,
      true,
      Paint()..color = hair,
    );
    if (hash % 4 == 0) {
      canvas.drawLine(
        headCenter.translate(-2.2 * scale, 3.0 * scale),
        headCenter.translate(2.2 * scale, 3.0 * scale),
        Paint()
          ..color = hair.withValues(alpha: .82)
          ..strokeWidth = 1.05 * scale
          ..strokeCap = StrokeCap.round,
      );
    }

    if (active) {
      final ringColor = replay ? const Color(0xFFFFFFFF) : const Color(0xFF9AF12A);
      canvas.drawCircle(
        translated,
        (16 + pulse * 4) * scale,
        Paint()..color = ringColor.withValues(alpha: .08 + .10 * pulse),
      );
      canvas.drawCircle(
        translated,
        (13 + pulse * 3) * scale,
        Paint()
          ..color = ringColor.withValues(alpha: .26 + .18 * pulse)
          ..style = PaintingStyle.stroke
          ..strokeWidth = replay ? 1.8 : 1.45,
      );
    }
    canvas.restore();
  }

  static void _drawKit(
    Canvas canvas,
    RRect torso,
    Color primary,
    Color secondary,
    ClubKitPattern pattern,
    double scale,
  ) {
    canvas.save();
    canvas.clipRRect(torso);
    canvas.drawRRect(torso, Paint()..color = primary);
    final rect = torso.outerRect;
    final accent = Paint()..color = secondary.withValues(alpha: .94);
    switch (pattern) {
      case ClubKitPattern.solid:
        canvas.drawRect(
          Rect.fromLTWH(rect.left, rect.top, rect.width, 2.0 * scale),
          accent..color = secondary.withValues(alpha: .36),
        );
        break;
      case ClubKitPattern.verticalStripes:
        final stripe = rect.width / 5;
        for (var index = 0; index < 5; index += 2) {
          canvas.drawRect(
            Rect.fromLTWH(rect.left + stripe * index, rect.top, stripe, rect.height),
            accent,
          );
        }
        break;
      case ClubKitPattern.horizontalStripes:
        final stripe = rect.height / 5;
        for (var index = 0; index < 5; index += 2) {
          canvas.drawRect(
            Rect.fromLTWH(rect.left, rect.top + stripe * index, rect.width, stripe),
            accent,
          );
        }
        break;
      case ClubKitPattern.sash:
        final path = Path()
          ..moveTo(rect.left - 2 * scale, rect.top)
          ..lineTo(rect.left + 2 * scale, rect.top)
          ..lineTo(rect.right + 2 * scale, rect.bottom)
          ..lineTo(rect.right - 2 * scale, rect.bottom)
          ..close();
        canvas.drawPath(path, accent);
        break;
      case ClubKitPattern.halves:
        canvas.drawRect(
          Rect.fromLTWH(rect.center.dx, rect.top, rect.width / 2, rect.height),
          accent,
        );
        break;
      case ClubKitPattern.gradient:
        canvas.drawRect(
          rect,
          Paint()
            ..shader = Gradient.linear(
              rect.topCenter,
              rect.bottomCenter,
              [primary, secondary],
            ),
        );
        break;
    }
    canvas.restore();
  }

  static Color _goalkeeperColor(int primaryHex, int hash) {
    final primary = Color(primaryHex);
    const options = [
      Color(0xFFE5C72D),
      Color(0xFF36B66D),
      Color(0xFFE96F32),
      Color(0xFF7E67E8),
    ];
    var selected = options[hash % options.length];
    if ((selected.computeLuminance() - primary.computeLuminance()).abs() < .18) {
      selected = options[(hash + 1) % options.length];
    }
    return selected;
  }

  static Color _hairColor(int hash) {
    const hairs = [
      Color(0xFF171311),
      Color(0xFF2B1B13),
      Color(0xFF4A3022),
      Color(0xFF8B673C),
      Color(0xFFD0B47A),
    ];
    return hairs[(hash ~/ 7) % hairs.length];
  }
}
