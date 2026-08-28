import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/club/club.dart';
import 'home_visual_components.dart';

class HomeBoardConfidenceCard extends StatelessWidget {
  const HomeBoardConfidenceCard({
    super.key,
    required this.confidence,
    required this.club,
    this.onStadiumTap,
  });

  final int confidence;
  final Club club;
  final VoidCallback? onStadiumTap;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(11, 10, 11, 11),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF143B3A), Color(0xFF142B2D), AppColors.surface],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF41C8B4).withValues(alpha: .28)),
          boxShadow: const [
            BoxShadow(color: Color(0x2A000000), blurRadius: 14, offset: Offset(0, 6)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CONFIANÇA DA DIRETORIA',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                letterSpacing: .25,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 112,
              child: Row(
                children: [
                  Expanded(
                    flex: 19,
                    child: _StadiumSummary(
                      club: club,
                      onTap: onStadiumTap,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    flex: 10,
                    child: _ConfidenceGauge(confidence: confidence),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _StadiumSummary extends StatelessWidget {
  const _StadiumSummary({required this.club, this.onTap});

  final Club club;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFF41C8B4).withValues(alpha: .22)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const HomeImageShade(
                    asset: HomeVisualAssets.stadiumAerial,
                    alignment: Alignment.center,
                    overlayStrength: .68,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: .12),
                          AppColors.background.withValues(alpha: .20),
                          AppColors.background.withValues(alpha: .93),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.stadium_rounded, color: AppColors.green, size: 14),
                            SizedBox(width: 5),
                            Text(
                              'ESTÁDIO',
                              style: TextStyle(
                                color: AppColors.green,
                                fontSize: 7.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          club.stadium.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Expanded(
                              child: _StadiumMetric(
                                icon: Icons.groups_2_outlined,
                                label: 'CAPACIDADE',
                                value: _compactCount(club.stadium.capacity),
                              ),
                            ),
                            Expanded(
                              child: _StadiumMetric(
                                icon: Icons.local_activity_outlined,
                                label: 'INGRESSO',
                                value: compactMoney(club.stadium.ticketPrice),
                              ),
                            ),
                            Expanded(
                              child: _StadiumMetric(
                                icon: Icons.apartment_rounded,
                                label: 'ARQUIB.',
                                value: 'Nv. ${club.stadium.standsLevel}',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  static String _compactCount(int value) {
    if (value >= 1000) {
      final thousands = value / 1000;
      return '${thousands.toStringAsFixed(value % 1000 == 0 ? 0 : 1)} mil';
    }
    return '$value';
  }
}

class _StadiumMetric extends StatelessWidget {
  const _StadiumMetric({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 11),
          const SizedBox(width: 3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 5.8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 7.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}

class _ConfidenceGauge extends StatelessWidget {
  const _ConfidenceGauge({required this.confidence});

  final int confidence;

  @override
  Widget build(BuildContext context) {
    final value = confidence.clamp(0, 100).toInt();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 84,
          height: 84,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: value / 100,
                  strokeWidth: 8,
                  strokeCap: StrokeCap.round,
                  backgroundColor: const Color(0xFF30433D),
                  color: AppColors.green,
                ),
              ),
              Container(
                width: 66,
                height: 66,
                decoration: const BoxDecoration(
                  color: Color(0xDD101820),
                  shape: BoxShape.circle,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$value%',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 22,
                      height: 1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'CONFIANÇA',
                    style: TextStyle(
                      color: AppColors.green,
                      fontSize: 6.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Text(
          _confidenceText(value),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 6.8,
            height: 1.15,
          ),
        ),
      ],
    );
  }

  static String _confidenceText(int value) {
    if (value >= 80) return 'Diretoria muito satisfeita.';
    if (value >= 65) return 'Diretoria satisfeita.';
    if (value >= 50) return 'Diretoria acompanha de perto.';
    return 'Diretoria espera uma reação.';
  }
}
