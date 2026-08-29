import 'dart:math' as math;
import 'dart:ui';

import '../../../domain/club/club.dart';

enum MatchPlayerPose {
  normal,
  goalkeeperDive,
  celebration,
  penaltyReady,
}

/// Renders each player as a single flat "chip" — one solid disc carrying
/// the kit color/pattern, with no separate head shape floating above the
/// body. Earlier iterations used a two-part body+head silhouette; at the
/// tiny scale used during a live match that either turned into a blurry
/// mess (fine limb strokes) or, once simplified, into an oversized head
/// sitting on a tiny torso ("bobblehead" look). A single disc has no way
/// to misjudge proportions between two parts, so it stays legible and
/// clean at any render scale.
abstract final class MatchPlayerVisuals {
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
    final s = scale * 1.15;

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

    // Ground shadow, slightly offset down so the chip reads as sitting on
    // the grass rather than floating on top of it.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(translated.dx, translated.dy + 7.2 * s),
        width: (dive ? 17 : 13.5) * s,
        height: 3.8 * s,
      ),
      Paint()
        ..color = const Color(0x55000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0),
    );

    if (active) {
      final ringColor = replay ? const Color(0xFFFFFFFF) : const Color(0xFF9AF12A);
      canvas.drawCircle(
        translated,
        (13.5 + pulse * 4) * s,
        Paint()..color = ringColor.withValues(alpha: .10 + .12 * pulse),
      );
      canvas.drawCircle(
        translated,
        (11 + pulse * 3) * s,
        Paint()
          ..color = ringColor.withValues(alpha: .34 + .2 * pulse)
          ..style = PaintingStyle.stroke
          ..strokeWidth = replay ? 1.9 : 1.5,
      );
    }

    final radius = 7.4 * s;

    // Base disc: solid kit color.
    canvas.drawCircle(translated, radius, Paint()..color = primary);

    // Pattern lives inside a clip of the same disc so it never spills out
    // into a separate silhouette.
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: translated, radius: radius)));
    _drawKitPattern(canvas, translated, radius, secondary, kit.pattern);

    // Faint darker cap near the top third suggests "facing forward"
    // without ever detaching from the disc as its own shape.
    canvas.drawCircle(
      Offset(translated.dx, translated.dy - radius * .42),
      radius * .5,
      Paint()..color = const Color(0x24000000),
    );

    // Soft top-down sheen for a bit of dimensionality.
    canvas.drawRect(
      Rect.fromCircle(center: translated, radius: radius),
      Paint()
        ..shader = Gradient.radial(
          Offset(translated.dx, translated.dy - radius * .5),
          radius * 1.5,
          const [Color(0x3AFFFFFF), Color(0x00FFFFFF)],
        ),
    );
    canvas.restore();

    // Crisp rim so the chip separates cleanly from the grass and from
    // neighbouring players.
    canvas.drawCircle(
      translated,
      radius,
      Paint()
        ..color = const Color(0xD8FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.15 * s,
    );

    canvas.restore();
  }

  static void _drawKitPattern(
    Canvas canvas,
    Offset center,
    double radius,
    Color secondary,
    ClubKitPattern pattern,
  ) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    final accent = Paint()..color = secondary;
    switch (pattern) {
      case ClubKitPattern.solid:
        canvas.drawRect(
          Rect.fromLTWH(rect.left, rect.top, rect.width, rect.height * .3),
          accent..color = secondary.withValues(alpha: .6),
        );
        break;
      case ClubKitPattern.verticalStripes:
        canvas.drawRect(
          Rect.fromLTWH(rect.left + rect.width * .36, rect.top, rect.width * .28, rect.height),
          accent,
        );
        break;
      case ClubKitPattern.horizontalStripes:
        canvas.drawRect(
          Rect.fromLTWH(rect.left, rect.top + rect.height * .36, rect.width, rect.height * .28),
          accent,
        );
        break;
      case ClubKitPattern.sash:
        final path = Path()
          ..moveTo(rect.left, rect.top + rect.height * .2)
          ..lineTo(rect.left + rect.width * .35, rect.top)
          ..lineTo(rect.right, rect.bottom - rect.height * .2)
          ..lineTo(rect.right - rect.width * .35, rect.bottom)
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
              [secondary.withValues(alpha: 0), secondary],
            ),
        );
        break;
    }
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
