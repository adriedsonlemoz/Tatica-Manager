import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class HomeSeasonCard extends StatelessWidget {
  const HomeSeasonCard({
    super.key,
    required this.position,
    required this.currentRound,
    required this.totalRounds,
    this.onTap,
    this.height = 64,
  });

  final int position;
  final int currentRound;
  final int totalRounds;
  final VoidCallback? onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    final remaining = (totalRounds - currentRound).clamp(0, totalRounds);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF571B24), Color(0xFF3B171D), Color(0xFF24171B)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.danger.withValues(alpha: .34)),
            boxShadow: const [
              BoxShadow(color: Color(0x26000000), blurRadius: 14, offset: Offset(0, 5)),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(19),
                    child: CustomPaint(painter: _SeasonTrendPainter()),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: height >= 110 ? 44 : 40,
                    height: height >= 110 ? 44 : 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: .16),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: AppColors.danger.withValues(alpha: .26)),
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: Color(0xFFFFC857),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'PANORAMA DA TEMPORADA',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: .2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          position > 0 ? '$positionº NA LIGA' : 'SEM POSIÇÃO',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: height >= 110 ? 18 : 14,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$remaining rodadas restantes',
                          style: const TextStyle(
                            fontSize: 8.5,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (height >= 110) ...[
                          const SizedBox(height: 8),
                          Text(
                            currentRound > 0
                                ? 'Rodada atual: $currentRound'
                                : 'Competição em preparação',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (onTap != null)
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.white,
                      size: 26,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeAdvanceStrip extends StatelessWidget {
  const HomeAdvanceStrip({
    super.key,
    required this.isMatchDay,
    required this.onAdvance,
    required this.onMatchDay,
  });

  final bool isMatchDay;
  final VoidCallback onAdvance;
  final VoidCallback onMatchDay;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isMatchDay ? onMatchDay : onAdvance,
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFB8FB21), Color(0xFF95E413), Color(0xFF7BD20F)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFA9FF3C).withValues(alpha: .55)),
              boxShadow: const [
                BoxShadow(color: Color(0x3456CE11), blurRadius: 16, offset: Offset(0, 6)),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  child: IgnorePointer(child: _AdvanceTexture()),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isMatchDay ? Icons.sports_soccer_rounded : Icons.play_arrow_rounded,
                      color: Colors.black,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isMatchDay ? 'ABRIR PARTIDA' : 'AVANÇAR',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .35,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, color: Colors.black, size: 22),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}

class _AdvanceTexture extends StatelessWidget {
  const _AdvanceTexture();

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _AdvanceTexturePainter());
}

class _AdvanceTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: .05)
      ..strokeWidth = 12;
    for (double x = -size.height; x < size.width + size.height; x += 34) {
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SeasonTrendPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          AppColors.danger.withValues(alpha: .18),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final linePaint = Paint()
      ..color = AppColors.danger.withValues(alpha: .55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.1
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * .50, size.height * .88)
      ..quadraticBezierTo(size.width * .58, size.height * .78, size.width * .64, size.height * .72)
      ..quadraticBezierTo(size.width * .70, size.height * .66, size.width * .75, size.height * .52)
      ..quadraticBezierTo(size.width * .81, size.height * .44, size.width * .86, size.height * .32)
      ..quadraticBezierTo(size.width * .92, size.height * .20, size.width * .98, size.height * .12);

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width * .50, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()..color = AppColors.danger.withValues(alpha: .78);
    final points = [
      Offset(size.width * .64, size.height * .72),
      Offset(size.width * .75, size.height * .52),
      Offset(size.width * .86, size.height * .32),
      Offset(size.width * .98, size.height * .12),
    ];
    for (final point in points) {
      canvas.drawCircle(point, 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
