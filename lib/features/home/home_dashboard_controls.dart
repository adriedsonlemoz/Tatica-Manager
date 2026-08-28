import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class HomeSeasonCard extends StatelessWidget {
  const HomeSeasonCard({
    super.key,
    required this.position,
    required this.currentRound,
    required this.totalRounds,
    this.onTap,
  });

  final int position;
  final int currentRound;
  final int totalRounds;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final remaining = (totalRounds - currentRound).clamp(0, totalRounds);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF351B1E), Color(0xFF2A171A), Color(0xFF1B1C21)],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.danger.withValues(alpha: .30)),
            boxShadow: const [
              BoxShadow(color: Color(0x26000000), blurRadius: 12, offset: Offset(0, 5)),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                width: 116,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.transparent,
                          AppColors.danger.withValues(alpha: .07),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: AppColors.danger.withValues(alpha: .22)),
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: AppColors.danger,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PANORAMA DA TEMPORADA',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          position > 0 ? '$positionº NA LIGA' : 'SEM POSIÇÃO',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          '$remaining rodadas restantes',
                          style: const TextStyle(fontSize: 8, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  if (onTap != null)
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
                      size: 24,
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
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF8BF020), Color(0xFF68D30E)],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFA2FF3D).withValues(alpha: .48)),
              boxShadow: const [
                BoxShadow(color: Color(0x3D65D408), blurRadius: 18, offset: Offset(0, 7)),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(18)),
                  child: IgnorePointer(child: _AdvanceTexture()),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isMatchDay ? Icons.sports_soccer_rounded : Icons.play_arrow_rounded,
                      color: Colors.black,
                      size: 26,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      isMatchDay ? 'ABRIR PARTIDA' : 'AVANÇAR',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .35,
                      ),
                    ),
                    const SizedBox(width: 7),
                    const Icon(Icons.arrow_forward_rounded, color: Colors.black, size: 20),
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
      ..color = Colors.white.withValues(alpha: .055)
      ..strokeWidth = 12;
    for (double x = -size.height; x < size.width + size.height; x += 34) {
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
