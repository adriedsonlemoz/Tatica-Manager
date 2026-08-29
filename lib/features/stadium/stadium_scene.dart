import 'package:flutter/material.dart';

import '../../app/widgets/common.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/club/club.dart';

class StadiumSceneCard extends StatefulWidget {
  const StadiumSceneCard({
    super.key,
    required this.club,
    required this.occupancy,
    this.namingSponsor,
  });

  final Club club;
  final int occupancy;
  final String? namingSponsor;

  @override
  State<StadiumSceneCard> createState() => _StadiumSceneCardState();
}

class _StadiumSceneCardState extends State<StadiumSceneCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final club = widget.club;
    final primary = AppColors.readableAccent(Color(club.colors.primaryHex));
    final secondary = AppColors.readableAccent(Color(club.colors.secondaryHex));
    return SectionCard(
      padding: EdgeInsets.zero,
      borderColor: primary.withValues(alpha: .50),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            SizedBox(
              height: 220,
              width: double.infinity,
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, _) => CustomPaint(
                  painter: StadiumNightPainter(
                    primary: primary,
                    secondary: secondary,
                    glow: controller.value,
                    standsLevel: club.stadium.standsLevel,
                    commercialLevel: club.stadium.commercialLevel,
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 14,
                        top: 14,
                        right: 14,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    club.stadium.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      shadows: [Shadow(color: Colors.black, blurRadius: 8)],
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: primary.withValues(alpha: .88),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(color: Colors.white.withValues(alpha: .12)),
                                    ),
                                    child: Text(
                                      widget.namingSponsor == null
                                          ? 'Casa de ${club.name}'
                                          : 'Naming rights • ${widget.namingSponsor}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: AppColors.foregroundOn(primary),
                                        fontSize: 10.2,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 14,
                        right: 14,
                        bottom: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: .62),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white.withValues(alpha: .10)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _SceneMetric(
                                  icon: Icons.groups_rounded,
                                  value: '${club.stadium.capacity}',
                                  label: 'capacidade',
                                ),
                              ),
                              Expanded(
                                child: _SceneMetric(
                                  icon: Icons.confirmation_number_outlined,
                                  value: formatMoney(club.stadium.ticketPrice),
                                  label: 'ingresso',
                                ),
                              ),
                              Expanded(
                                child: _SceneMetric(
                                  icon: Icons.stadium_outlined,
                                  value: '${widget.occupancy}%',
                                  label: 'ocupação proj.',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StadiumNightPainter extends CustomPainter {
  const StadiumNightPainter({
    required this.primary,
    required this.secondary,
    required this.glow,
    required this.standsLevel,
    required this.commercialLevel,
  });

  final Color primary;
  final Color secondary;
  final double glow;
  final int standsLevel;
  final int commercialLevel;

  @override
  void paint(Canvas canvas, Size size) {
    final sky = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF020606), Color(0xFF07110F), Color(0xFF0E1815)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, sky);

    final halo = Paint()
      ..shader = RadialGradient(
        colors: [
          primary.withValues(alpha: .18 + glow * .10),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(size.width * .5, size.height * .55), radius: size.width * .55));
    canvas.drawRect(Offset.zero & size, halo);

    _drawFloodlights(canvas, size);
    _drawStands(canvas, size);
    _drawPitch(canvas, size);
    _drawCrowd(canvas, size);
  }

  void _drawFloodlights(Canvas canvas, Size size) {
    final lightOpacity = (.55 + glow * .35).clamp(0.0, 1.0);
    final beam = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white.withValues(alpha: .16 * lightOpacity), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * .7));
    final leftBeam = Path()
      ..moveTo(size.width * .05, 0)
      ..lineTo(size.width * .18, 0)
      ..lineTo(size.width * .44, size.height * .72)
      ..lineTo(size.width * .28, size.height * .72)
      ..close();
    final rightBeam = Path()
      ..moveTo(size.width * .82, 0)
      ..lineTo(size.width * .95, 0)
      ..lineTo(size.width * .72, size.height * .72)
      ..lineTo(size.width * .56, size.height * .72)
      ..close();
    canvas.drawPath(leftBeam, beam);
    canvas.drawPath(rightBeam, beam);

    final lamp = Paint()..color = Colors.white.withValues(alpha: lightOpacity);
    for (final x in [size.width * .08, size.width * .12, size.width * .88, size.width * .92]) {
      canvas.drawCircle(Offset(x, size.height * .035), 2.2 + glow, lamp);
    }
  }

  void _drawStands(Canvas canvas, Size size) {
    final standPaint = Paint()..color = const Color(0xFF111A18);
    final upper = Path()
      ..moveTo(size.width * .04, size.height * .30)
      ..lineTo(size.width * .96, size.height * .30)
      ..lineTo(size.width * .86, size.height * .66)
      ..lineTo(size.width * .14, size.height * .66)
      ..close();
    canvas.drawPath(upper, standPaint);

    final band = Paint()..color = primary.withValues(alpha: .62);
    canvas.drawRect(
      Rect.fromLTWH(size.width * .08, size.height * .44, size.width * .84, 5 + standsLevel.toDouble()),
      band,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * .10, size.height * .52, size.width * .80, 2.5),
      Paint()..color = secondary.withValues(alpha: .55),
    );
  }

  void _drawPitch(Canvas canvas, Size size) {
    final pitch = Path()
      ..moveTo(size.width * .25, size.height * .56)
      ..lineTo(size.width * .75, size.height * .56)
      ..lineTo(size.width * .91, size.height * .95)
      ..lineTo(size.width * .09, size.height * .95)
      ..close();
    canvas.drawPath(pitch, Paint()..color = const Color(0xFF1B641E));

    final stripe = Paint()..color = const Color(0xFF26752A);
    for (var index = 0; index < 6; index++) {
      final topLeft = .25 + index * .083;
      final topRight = topLeft + .042;
      final bottomLeft = .09 + index * .137;
      final bottomRight = bottomLeft + .068;
      final path = Path()
        ..moveTo(size.width * topLeft, size.height * .56)
        ..lineTo(size.width * topRight, size.height * .56)
        ..lineTo(size.width * bottomRight, size.height * .95)
        ..lineTo(size.width * bottomLeft, size.height * .95)
        ..close();
      canvas.drawPath(path, stripe);
    }

    final line = Paint()
      ..color = Colors.white.withValues(alpha: .78)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    canvas.drawPath(pitch, line);
    canvas.drawLine(
      Offset(size.width * .5, size.height * .56),
      Offset(size.width * .5, size.height * .95),
      line,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * .5, size.height * .755),
        width: size.width * .13,
        height: size.height * .10,
      ),
      line,
    );
  }

  void _drawCrowd(Canvas canvas, Size size) {
    final density = (46 + standsLevel * 8 + commercialLevel).clamp(45, 95).toInt();
    for (var i = 0; i < density; i++) {
      final fx = ((i * 37) % 97) / 97;
      final fy = ((i * 53) % 31) / 31;
      final x = size.width * (.10 + fx * .80);
      final y = size.height * (.33 + fy * .23);
      final color = i % 5 == 0
          ? secondary
          : i % 3 == 0
              ? primary
              : Colors.white;
      canvas.drawCircle(
        Offset(x, y),
        1.1 + (i % 4 == 0 ? glow * .7 : 0),
        Paint()..color = color.withValues(alpha: .28 + glow * .14),
      );
    }
  }

  @override
  bool shouldRepaint(covariant StadiumNightPainter oldDelegate) =>
      oldDelegate.glow != glow ||
      oldDelegate.primary != primary ||
      oldDelegate.secondary != secondary ||
      oldDelegate.standsLevel != standsLevel ||
      oldDelegate.commercialLevel != commercialLevel;
}

class _SceneMetric extends StatelessWidget {
  const _SceneMetric({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Icon(icon, size: 16, color: AppColors.green),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10.5),
          ),
          Text(label, style:  TextStyle(color: AppColors.muted, fontSize: 8)),
        ],
      );
}
