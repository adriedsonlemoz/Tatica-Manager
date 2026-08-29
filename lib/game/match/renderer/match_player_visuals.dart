import 'dart:math' as math;
import 'dart:ui';

import '../../../domain/club/club.dart';

enum MatchPlayerPose {
  normal,
  goalkeeperDive,
  celebration,
  penaltyReady,
}

/// Renders players as bold, high-contrast "tokens" (a broadcast-style top
/// down chip: body blob + jersey pattern + small head) rather than a
/// finely detailed stick figure. At the small on-screen scale used during
/// live match rendering, fine detail (separate limbs, hair strands, socks)
/// just turns into visual noise — a simplified, bigger-contrast shape reads
/// far better and looks closer to a real match-manager broadcast camera.
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
    // Tokens read better a bit bigger than the old anatomical figure did,
    // since there's no separate limb geometry adding perceived size.
    final s = scale * 1.28;

    final bounce = pose == MatchPlayerPose.celebration
        ? math.sin(animationPhase * math.pi * 4).abs() * 2.6 * s
        : 0.0;
    final crouch = pose == MatchPlayerPose.penaltyReady
        ? math.sin(animationPhase * math.pi * 2).abs() * 1.1 * s
        : 0.0;
    final translated = center.translate(0, -bounce + crouch);
    final dive = pose == MatchPlayerPose.goalkeeperDive;
    final angle = dive ? diveDirection.sign * .82 : 0.0;
    final hash = playerId.hashCode.abs();
    final skin = _skinTones[hash % _skinTones.length];
    final primary =
        goalkeeper ? _goalkeeperColor(kit.primaryHex, hash) : Color(kit.primaryHex);
    final secondary = goalkeeper
        ? Color.lerp(primary, const Color(0xFF10151A), .55)!
        : Color(kit.secondaryHex);

    canvas.save();
    if (dive) {
      canvas.translate(translated.dx, translated.dy);
      canvas.rotate(angle);
      canvas.translate(-translated.dx, -translated.dy);
    }

    // Ground shadow first, anchored slightly ahead of the body so the
    // token feels grounded on the pitch rather than floating.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(translated.dx, translated.dy + 8.4 * s),
        width: (dive ? 19 : 15.5) * s,
        height: 4.6 * s,
      ),
      Paint()
        ..color = const Color(0x55000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.1),
    );

    if (active) {
      final ringColor = replay ? const Color(0xFFFFFFFF) : const Color(0xFF9AF12A);
      canvas.drawCircle(
        translated,
        (15 + pulse * 4) * s,
        Paint()..color = ringColor.withValues(alpha: .10 + .12 * pulse),
      );
      canvas.drawCircle(
        translated,
        (12.2 + pulse * 3) * s,
        Paint()
          ..color = ringColor.withValues(alpha: .34 + .2 * pulse)
          ..style = PaintingStyle.stroke
          ..strokeWidth = replay ? 1.9 : 1.55,
      );
    }

    // Body: one bold rounded-capsule silhouette carries the jersey. Arms
    // are suggested with two short stub caps instead of full limb lines,
    // which keeps the token crisp instead of turning to mush at 6-9px.
    final bodyCenter = Offset(translated.dx, translated.dy + 2.6 * s);
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: bodyCenter, width: 12.6 * s, height: 12.0 * s),
      Radius.circular(5.4 * s),
    );

    final armLift = pose == MatchPlayerPose.celebration ? 5.6 : 1.6;
    final armPaint = Paint()..color = primary;
    canvas.drawCircle(
      Offset(translated.dx - 7.0 * s, translated.dy - .4 * s - armLift * s * .3),
      2.5 * s,
      armPaint,
    );
    canvas.drawCircle(
      Offset(translated.dx + 7.0 * s, translated.dy - .4 * s - armLift * s * .3),
      2.5 * s,
      armPaint,
    );

    _drawKit(canvas, body, primary, secondary, kit.pattern, s);
    canvas.drawRRect(
      body,
      Paint()
        ..color = const Color(0xC4FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = .9 * s,
    );
    // Soft top-down light sheen so the token doesn't read as flat.
    canvas.save();
    canvas.clipRRect(body);
    canvas.drawRect(
      body.outerRect,
      Paint()
        ..shader = Gradient.linear(
          body.outerRect.topCenter,
          body.outerRect.bottomCenter,
          const [Color(0x3AFFFFFF), Color(0x00FFFFFF), Color(0x22000000)],
          const [0, .5, 1],
        ),
    );
    canvas.restore();

    // Head: simple flat disc, no hair/neck strokes — reads as a clean dot
    // at this size and avoids the "bald mannequin" look from fine strokes.
    final headCenter = Offset(translated.dx, translated.dy - 6.6 * s);
    canvas.drawCircle(headCenter, 4.0 * s, Paint()..color = skin);
    canvas.drawCircle(
      headCenter,
      4.0 * s,
      Paint()
        ..color = const Color(0x2A000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = .55 * s,
    );

    canvas.restore();
  }

  static void _drawKit(
    Canvas canvas,
    RRect body,
    Color primary,
    Color secondary,
    ClubKitPattern pattern,
    double scale,
  ) {
    canvas.save();
    canvas.clipRRect(body);
    canvas.drawRRect(body, Paint()..color = primary);
    final rect = body.outerRect;
    final accent = Paint()..color = secondary;
    switch (pattern) {
      case ClubKitPattern.solid:
        canvas.drawRect(
          Rect.fromLTWH(rect.left, rect.top, rect.width, rect.height * .22),
          accent..color = secondary.withValues(alpha: .55),
        );
        break;
      case ClubKitPattern.verticalStripes:
        // Two bold stripes instead of five thin ones — legible at 8px.
        final stripe = rect.width / 3;
        canvas.drawRect(
          Rect.fromLTWH(rect.left + stripe * .5, rect.top, stripe, rect.height),
          accent,
        );
        break;
      case ClubKitPattern.horizontalStripes:
        final stripe = rect.height / 3;
        canvas.drawRect(
          Rect.fromLTWH(rect.left, rect.top + stripe, rect.width, stripe),
          accent,
        );
        break;
      case ClubKitPattern.sash:
        final path = Path()
          ..moveTo(rect.left - 2 * scale, rect.top + rect.height * .18)
          ..lineTo(rect.left + 2 * scale, rect.top - 2 * scale)
          ..lineTo(rect.right + 2 * scale, rect.bottom + 2 * scale)
          ..lineTo(rect.right - 2 * scale, rect.bottom - rect.height * .18)
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
}
