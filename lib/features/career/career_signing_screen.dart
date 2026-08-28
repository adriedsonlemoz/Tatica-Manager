import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/widgets/common.dart';
import '../../core/theme/app_colors.dart';
import '../../data/club_seed.dart';

class CareerSigningScreen extends ConsumerStatefulWidget {
  const CareerSigningScreen({
    super.key,
    required this.managerName,
    required this.clubId,
  });

  final String managerName;
  final String clubId;

  @override
  ConsumerState<CareerSigningScreen> createState() => _CareerSigningScreenState();
}

class _CareerSigningScreenState extends ConsumerState<CareerSigningScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _finishTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..forward();
    _controller.addStatusListener((status) {
      if (status != AnimationStatus.completed) return;
      _finishTimer = Timer(const Duration(milliseconds: 850), () {
        if (!mounted) return;
        Navigator.of(context).popUntil((route) => route.isFirst);
      });
    });
  }

  @override
  void dispose() {
    _finishTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final career = ref.watch(gameControllerProvider).career;
    final activeClub =
        career?.clubs.where((club) => club.id == widget.clubId).firstOrNull;
    final club = activeClub ?? clubSeeds.firstWhere((seed) => seed.id == widget.clubId).toClub();
    return PremiumScaffold(
      safeBottom: true,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
        child: Column(
          children: [
            const Spacer(),
            ClubBadge(club: club, size: 76),
            const SizedBox(height: 18),
            Text(
              'NOVO DESAFIO',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.green,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.8,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Assinando contrato',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.managerName} • ${club.name}',
              style: TextStyle(color: AppColors.muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => _ContractPaper(
                managerName: widget.managerName,
                clubName: club.name,
                progress: Curves.easeInOutCubic.transform(_controller.value),
              ),
            ),
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final done = _controller.value >= .98;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      done ? Icons.verified_rounded : Icons.edit_rounded,
                      color: AppColors.green,
                      size: 19,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      done ? 'Contrato assinado. Bem-vindo ao clube.' : 'Formalizando sua chegada...',
                      style: TextStyle(
                        color: done ? AppColors.green : AppColors.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                );
              },
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}

class _ContractPaper extends StatelessWidget {
  const _ContractPaper({
    required this.managerName,
    required this.clubName,
    required this.progress,
  });

  final String managerName;
  final String clubName;
  final double progress;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 430),
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F1E8),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 28,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CONTRATO DE TREINADOR',
              style: TextStyle(
                color: Color(0xFF111713),
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 18),
            _PaperLine(widthFactor: .92),
            const SizedBox(height: 8),
            _PaperLine(widthFactor: .74),
            const SizedBox(height: 8),
            _PaperLine(widthFactor: .84),
            const SizedBox(height: 22),
            Text(
              clubName,
              style: const TextStyle(
                color: Color(0xFF253029),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 76,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _SignaturePainter(progress: progress, managerName: managerName),
                    ),
                  ),
                  Positioned(
                    left: 8 + (190 * progress),
                    top: 2 + (20 * (1 - progress)),
                    child: Transform.rotate(
                      angle: -.65,
                      child: const Icon(
                        Icons.edit_rounded,
                        color: Color(0xFF253029),
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: const Color(0xFFB4B8AE)),
            const SizedBox(height: 6),
            Text(
              managerName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF5F665F),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
}

class _PaperLine extends StatelessWidget {
  const _PaperLine({required this.widthFactor});

  final double widthFactor;

  @override
  Widget build(BuildContext context) => FractionallySizedBox(
        widthFactor: widthFactor,
        child: Container(
          height: 5,
          decoration: BoxDecoration(
            color: const Color(0xFFD1D3CC),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
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
          color: Color(0xFF132D1B),
          fontSize: 30,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w600,
          letterSpacing: .3,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 18);

    final textOffset = Offset(8, 18);
    canvas.save();
    final revealWidth = (painter.width + 22) * localProgress;
    canvas.clipRect(Rect.fromLTWH(0, 0, revealWidth, size.height));
    painter.paint(canvas, textOffset);
    canvas.restore();

    final underline = Path()
      ..moveTo(16, 58)
      ..quadraticBezierTo(size.width * .55, 66, size.width * .88, 55);
    final paint = Paint()
      ..color = const Color(0xFF132D1B)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final metric = underline.computeMetrics().first;
    final underlineProgress = ((localProgress - .38) / .62).clamp(0.0, 1.0).toDouble();
    canvas.drawPath(metric.extractPath(0, metric.length * underlineProgress), paint);
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) =>
      oldDelegate.progress != progress;
}


extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
