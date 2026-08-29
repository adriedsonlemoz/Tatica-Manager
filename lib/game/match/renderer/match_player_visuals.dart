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
    Color(0xFFF0C8A4),
    Color(0xFFE1AD83),
    Color(0xFFC88B62),
    Color(0xFFA86A48),
    Color(0xFF7C4933),
    Color(0xFF583426),
  ];

  static void draw(
    Canvas canvas, {
    required Offset center,
    required ClubKit kit,
    required String playerId,
    required bool active,
    required bool pulseReplay,
    required double pulse,
    required bool goalkeeper,
    required double scale,
    required double movementAmount,
    required double movementDirection,
    MatchPlayerPose pose = MatchPlayerPose.normal,
    double animationPhase = 0,
    double diveDirection = 0,
  }) {
    final seed = _stableSeed(playerId);
    final skin = _skinTones[seed % _skinTones.length];
    final hair = _hairColor(seed);
    final primary = goalkeeper
        ? _goalkeeperColor(kit.primaryHex, seed)
        : Color(kit.primaryHex);
    final secondary = goalkeeper
        ? Color.lerp(primary, const Color(0xFFFFFFFF), .22)!
        : Color(kit.secondaryHex);
    final shorts = goalkeeper
        ? Color.lerp(primary, const Color(0xFF000000), .24)!
        : Color(kit.shortsHex);
    final socks = goalkeeper ? primary : Color(kit.socksHex);

    final run = movementAmount.clamp(0.0, 1.0);
    final gait = math.sin(animationPhase * (8.2 + run * 5.0) + seed * .017) * run;
    final bob = math.sin(animationPhase * (8.2 + run * 4.4) + seed * .011).abs() * .8 * run;
    final celebrationBounce = pose == MatchPlayerPose.celebration
        ? math.sin(animationPhase * math.pi * 4).abs() * 2.6
        : 0.0;
    final crouch = pose == MatchPlayerPose.penaltyReady
        ? math.sin(animationPhase * math.pi * 2).abs() * .85
        : 0.0;
    final dive = pose == MatchPlayerPose.goalkeeperDive;
    final lean = (dive
        ? diveDirection.sign * .88
        : movementDirection.clamp(-1.0, 1.0) * .10 * run).toDouble();
    final bodyCenter = center.translate(0, (-bob - celebrationBounce + crouch) * scale);

    _drawShadow(
      canvas,
      center: center,
      scale: scale,
      dive: dive,
      movementAmount: run,
      direction: dive ? diveDirection : movementDirection,
    );

    canvas.save();
    if (lean.abs() > .001) {
      canvas.translate(bodyCenter.dx, bodyCenter.dy);
      canvas.rotate(lean);
      canvas.translate(-bodyCenter.dx, -bodyCenter.dy);
    }

    final legSwing = gait * 2.8;
    final armSwing = -gait * 2.4;
    _drawLeg(
      canvas,
      hip: bodyCenter.translate(-2.2 * scale, 4.0 * scale),
      swing: legSwing,
      scale: scale,
      shorts: shorts,
      socks: socks,
      mirror: false,
    );
    _drawLeg(
      canvas,
      hip: bodyCenter.translate(2.2 * scale, 4.0 * scale),
      swing: -legSwing,
      scale: scale,
      shorts: shorts,
      socks: socks,
      mirror: true,
    );

    final armLift = pose == MatchPlayerPose.celebration ? 6.8 : 2.1;
    _drawArm(
      canvas,
      shoulder: bodyCenter.translate(-5.2 * scale, -1.6 * scale),
      swing: armSwing,
      lift: armLift,
      skin: skin,
      sleeve: primary,
      scale: scale,
      mirror: false,
    );
    _drawArm(
      canvas,
      shoulder: bodyCenter.translate(5.2 * scale, -1.6 * scale),
      swing: -armSwing,
      lift: armLift,
      skin: skin,
      sleeve: primary,
      scale: scale,
      mirror: true,
    );

    final torsoRect = Rect.fromCenter(
      center: bodyCenter.translate(0, -.5 * scale),
      width: 12.6 * scale,
      height: 12.8 * scale,
    );
    final torso = RRect.fromRectAndRadius(
      torsoRect,
      Radius.circular(3.5 * scale),
    );
    _drawTorso(
      canvas,
      torso: torso,
      primary: primary,
      secondary: secondary,
      pattern: kit.pattern,
      scale: scale,
    );

    final neck = Rect.fromCenter(
      center: bodyCenter.translate(0, -7.4 * scale),
      width: 3.0 * scale,
      height: 3.3 * scale,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(neck, Radius.circular(1.2 * scale)),
      Paint()..color = skin,
    );

    final headCenter = bodyCenter.translate(0, -10.6 * scale);
    canvas.drawCircle(
      headCenter.translate(.5 * scale, .7 * scale),
      4.25 * scale,
      Paint()..color = const Color(0x28000000),
    );
    canvas.drawCircle(headCenter, 4.15 * scale, Paint()..color = skin);
    canvas.drawArc(
      Rect.fromCircle(center: headCenter.translate(0, -.5 * scale), radius: 4.2 * scale),
      math.pi,
      math.pi,
      true,
      Paint()..color = hair,
    );
    if (seed % 4 == 0) {
      canvas.drawLine(
        headCenter.translate(-2.0 * scale, 2.7 * scale),
        headCenter.translate(2.0 * scale, 2.7 * scale),
        Paint()
          ..color = hair.withValues(alpha: .72)
          ..strokeWidth = .9 * scale
          ..strokeCap = StrokeCap.round,
      );
    }

    if (active) {
      final ringColor = pulseReplay
          ? const Color(0xFFFFFFFF)
          : const Color(0xFF78D620);
      canvas.drawOval(
        Rect.fromCenter(
          center: center.translate(0, 4.8 * scale),
          width: (24 + pulse * 7) * scale,
          height: (11 + pulse * 3) * scale,
        ),
        Paint()..color = ringColor.withValues(alpha: .07 + .09 * pulse),
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: center.translate(0, 4.8 * scale),
          width: (20 + pulse * 5) * scale,
          height: (9 + pulse * 2) * scale,
        ),
        Paint()
          ..color = ringColor.withValues(alpha: .28 + .18 * pulse)
          ..style = PaintingStyle.stroke
          ..strokeWidth = pulseReplay ? 1.7 : 1.35,
      );
    }
    canvas.restore();
  }

  static void _drawShadow(
    Canvas canvas, {
    required Offset center,
    required double scale,
    required bool dive,
    required double movementAmount,
    required double direction,
  }) {
    final stretch = dive ? 1.65 : 1 + movementAmount * .14;
    final shift = Offset(direction * 1.6 * scale, 7.9 * scale);
    canvas.drawOval(
      Rect.fromCenter(
        center: center + shift,
        width: 16.5 * scale * stretch,
        height: 5.5 * scale,
      ),
      Paint()
        ..color = const Color(0x56000000)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1.5 * scale),
    );
  }

  static void _drawLeg(
    Canvas canvas, {
    required Offset hip,
    required double swing,
    required double scale,
    required Color shorts,
    required Color socks,
    required bool mirror,
  }) {
    final knee = hip.translate((mirror ? 1 : -1) * swing * .20 * scale, 3.6 * scale);
    final foot = knee.translate(swing * .46 * scale, 4.2 * scale);
    canvas.drawLine(
      hip,
      knee,
      Paint()
        ..color = shorts
        ..strokeWidth = 3.2 * scale
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      knee,
      foot,
      Paint()
        ..color = socks
        ..strokeWidth = 2.25 * scale
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      foot,
      foot.translate((mirror ? 1.8 : -1.8) * scale, .3 * scale),
      Paint()
        ..color = const Color(0xFF171B1D)
        ..strokeWidth = 1.7 * scale
        ..strokeCap = StrokeCap.round,
    );
  }

  static void _drawArm(
    Canvas canvas, {
    required Offset shoulder,
    required double swing,
    required double lift,
    required Color skin,
    required Color sleeve,
    required double scale,
    required bool mirror,
  }) {
    final sign = mirror ? 1.0 : -1.0;
    final elbow = shoulder.translate(
      sign * 2.5 * scale,
      (-lift + swing * .25) * scale,
    );
    final hand = elbow.translate(
      sign * 2.0 * scale,
      (1.8 + swing * .32) * scale,
    );
    canvas.drawLine(
      shoulder,
      elbow,
      Paint()
        ..color = sleeve
        ..strokeWidth = 3.0 * scale
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      elbow,
      hand,
      Paint()
        ..color = skin
        ..strokeWidth = 2.0 * scale
        ..strokeCap = StrokeCap.round,
    );
  }

  static void _drawTorso(
    Canvas canvas, {
    required RRect torso,
    required Color primary,
    required Color secondary,
    required ClubKitPattern pattern,
    required double scale,
  }) {
    final rect = torso.outerRect;
    canvas.save();
    canvas.clipRRect(torso);
    canvas.drawRRect(
      torso,
      Paint()
        ..shader = Gradient.linear(
          rect.topLeft,
          rect.bottomRight,
          [
            Color.lerp(primary, const Color(0xFFFFFFFF), .16)!,
            primary,
            Color.lerp(primary, const Color(0xFF000000), .24)!,
          ],
          const [0, .46, 1],
        ),
    );
    final accent = Paint()..color = secondary.withValues(alpha: .92);
    switch (pattern) {
      case ClubKitPattern.solid:
        canvas.drawRect(
          Rect.fromLTWH(rect.left, rect.top, rect.width, 1.8 * scale),
          Paint()..color = secondary.withValues(alpha: .35),
        );
        break;
      case ClubKitPattern.verticalStripes:
        final stripeWidth = rect.width / 5;
        for (var index = 0; index < 5; index += 2) {
          canvas.drawRect(
            Rect.fromLTWH(rect.left + stripeWidth * index, rect.top, stripeWidth, rect.height),
            accent,
          );
        }
        break;
      case ClubKitPattern.horizontalStripes:
        final stripeHeight = rect.height / 5;
        for (var index = 0; index < 5; index += 2) {
          canvas.drawRect(
            Rect.fromLTWH(rect.left, rect.top + stripeHeight * index, rect.width, stripeHeight),
            accent,
          );
        }
        break;
      case ClubKitPattern.sash:
        canvas.drawPath(
          Path()
            ..moveTo(rect.left - 2 * scale, rect.top)
            ..lineTo(rect.left + 2 * scale, rect.top)
            ..lineTo(rect.right + 2 * scale, rect.bottom)
            ..lineTo(rect.right - 2 * scale, rect.bottom)
            ..close(),
          accent,
        );
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
    canvas.drawRect(
      Rect.fromLTWH(rect.left, rect.top, rect.width * .22, rect.height),
      Paint()..color = const Color(0x10FFFFFF),
    );
    canvas.restore();

    canvas.drawRRect(
      torso,
      Paint()
        ..color = const Color(0x7FFFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = .72 * scale,
    );
  }

  static Color _goalkeeperColor(int primaryHex, int seed) {
    final primary = Color(primaryHex);
    const options = <Color>[
      Color(0xFFE0BC28),
      Color(0xFF3AB96E),
      Color(0xFFEF7B32),
      Color(0xFF7D69E7),
      Color(0xFF49A6D8),
    ];
    var selected = options[seed % options.length];
    if ((selected.computeLuminance() - primary.computeLuminance()).abs() < .18) {
      selected = options[(seed + 1) % options.length];
    }
    return selected;
  }

  static Color _hairColor(int seed) {
    const hairs = <Color>[
      Color(0xFF171311),
      Color(0xFF2C1B14),
      Color(0xFF513224),
      Color(0xFF8A653A),
      Color(0xFFC9AC72),
    ];
    return hairs[(seed ~/ 7) % hairs.length];
  }

  static int _stableSeed(String value) {
    var hash = 17;
    for (final code in value.codeUnits) {
      hash = (hash * 31 + code) & 0x7FFFFFFF;
    }
    return hash;
  }
}
