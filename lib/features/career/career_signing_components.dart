import 'package:flutter/material.dart';

import '../../app/widgets/common.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/club/club.dart';

class CareerSigningContractDocument extends StatelessWidget {
  const CareerSigningContractDocument({
    super.key,
    required this.managerName,
    required this.clubName,
    required this.season,
    required this.club,
    required this.progress,
  });

  final String managerName;
  final String clubName;
  final int season;
  final Club club;
  final double progress;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 430),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 15),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x44000000),
              blurRadius: 26,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClubBadge(club: club, size: 54),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CONTRATO DE TREINADOR',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        clubName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:  TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.description_outlined,
                  color: AppColors.green,
                  size: 22,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(height: 1, color: AppColors.border),
            const SizedBox(height: 12),
            _ContractFact(label: 'CLUBE', value: clubName),
            const SizedBox(height: 8),
            _ContractFact(label: 'TREINADOR', value: managerName),
            const SizedBox(height: 8),
            _ContractFact(label: 'TEMPORADA', value: '$season'),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 9),
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    'ASSINATURA DO TREINADOR',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .7,
                    ),
                  ),
                  SizedBox(
                    height: 66,
                    child: CustomPaint(
                      painter: _SignaturePainter(
                        progress: progress,
                        managerName: managerName,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                  Container(height: 1, color: AppColors.border),
                  const SizedBox(height: 5),
                  Text(
                    managerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:  TextStyle(
                      color: AppColors.muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class CareerSigningGlowOrb extends StatelessWidget {
  const CareerSigningGlowOrb({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.green.withValues(alpha: .13),
              AppColors.green.withValues(alpha: 0),
            ],
          ),
        ),
      );
}

class _ContractFact extends StatelessWidget {
  const _ContractFact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          SizedBox(
            width: 82,
            child: Text(
              label,
              style:  TextStyle(
                color: AppColors.muted,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
            ),
          ),
        ],
      );
}

class _SignaturePainter extends CustomPainter {
  const _SignaturePainter({required this.progress, required this.managerName});

  final double progress;
  final String managerName;

  @override
  void paint(Canvas canvas, Size size) {
    final localProgress = progress.clamp(0.0, 1.0).toDouble();
    final painter = TextPainter(
      text: TextSpan(
        text: managerName,
        style: const TextStyle(
          color: AppColors.green,
          fontSize: 27,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w600,
          letterSpacing: .2,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 14);

    canvas.save();
    final revealWidth = (painter.width + 18) * localProgress;
    canvas.clipRect(Rect.fromLTWH(0, 0, revealWidth, size.height));
    painter.paint(canvas, const Offset(4, 18));
    canvas.restore();

    final underline = Path()
      ..moveTo(10, 56)
      ..quadraticBezierTo(size.width * .52, 63, size.width * .88, 54);
    final paint = Paint()
      ..color = AppColors.greenDark
      ..strokeWidth = 2.1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final metric = underline.computeMetrics().first;
    final underlineProgress =
        ((localProgress - .38) / .62).clamp(0.0, 1.0).toDouble();
    canvas.drawPath(
      metric.extractPath(0, metric.length * underlineProgress),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
