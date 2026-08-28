import 'dart:convert';

import 'package:flutter/material.dart';

import '../../app/widgets/common.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/club/club.dart';

abstract final class HomeVisualAssets {
  static const matchStadium = 'assets/images/home/match_stadium.webp';
  static const stadiumAerial = 'assets/images/home/stadium_aerial.webp';
}

class HomeClubCrest extends StatelessWidget {
  const HomeClubCrest({
    super.key,
    required this.club,
    required this.size,
    this.framed = false,
  });

  final Club club;
  final double size;
  final bool framed;

  @override
  Widget build(BuildContext context) {
    final primary = Color(club.colors.primaryHex);
    final secondary = Color(club.colors.secondaryHex);
    final primaryHsl = HSLColor.fromColor(primary);
    final secondaryHsl = HSLColor.fromColor(secondary);
    final rawAccent = secondaryHsl.saturation > primaryHsl.saturation + .12
        ? secondary
        : primary;
    final accent = rawAccent.computeLuminance() < .035
        ? Color.lerp(rawAccent, AppColors.white, .24)!
        : rawAccent;
    final customIcon = _customIcon();
    final crest = customIcon ?? ClubBadge(club: club, size: size * .82);

    if (!framed) {
      return SizedBox(
        width: size,
        height: size,
        child: Center(child: crest),
      );
    }

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * .08),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: .56),
            Color.lerp(AppColors.surfaceRaised, accent, .22)!,
            AppColors.background.withValues(alpha: .97),
          ],
        ),
        borderRadius: BorderRadius.circular(size * .24),
        border: Border.all(color: accent.withValues(alpha: .78), width: 1.15),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: .20),
            blurRadius: 14,
            spreadRadius: .5,
          ),
        ],
      ),
      child: Center(child: customIcon ?? ClubBadge(club: club, size: size * .76)),
    );
  }

  Widget? _customIcon() {
    final encoded = club.iconBase64;
    if (encoded == null || encoded.isEmpty) return null;
    try {
      return Image.memory(
        base64Decode(encoded),
        width: size * .78,
        height: size * .78,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, _, _) => ClubBadge(club: club, size: size * .78),
      );
    } catch (_) {
      return null;
    }
  }
}

class HomeImageShade extends StatelessWidget {
  const HomeImageShade({
    super.key,
    required this.asset,
    this.alignment = Alignment.center,
    this.fit = BoxFit.cover,
    this.overlayStrength = .48,
  });

  final String asset;
  final Alignment alignment;
  final BoxFit fit;
  final double overlayStrength;

  @override
  Widget build(BuildContext context) => Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            asset,
            fit: fit,
            alignment: alignment,
            filterQuality: FilterQuality.medium,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: overlayStrength * .42),
                  Colors.black.withValues(alpha: overlayStrength * .10),
                  AppColors.background.withValues(alpha: overlayStrength),
                ],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                radius: 1.1,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: .34),
                ],
              ),
            ),
          ),
        ],
      );
}

class HomeAccentLine extends StatelessWidget {
  const HomeAccentLine({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 8,
        width: double.infinity,
        child: CustomPaint(painter: _HomeAccentLinePainter(color)),
      );
}

class _HomeAccentLinePainter extends CustomPainter {
  const _HomeAccentLinePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: .85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.35
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(0, size.height * .58)
      ..lineTo(size.width * .76, size.height * .58)
      ..quadraticBezierTo(
        size.width * .88,
        size.height * .58,
        size.width,
        size.height * .44,
      );
    canvas.drawPath(path, paint);
    canvas.drawCircle(
      Offset(size.width - 1.5, size.height * .44),
      2.1,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _HomeAccentLinePainter oldDelegate) =>
      oldDelegate.color != color;
}
