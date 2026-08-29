import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/club/club.dart';

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
        height: 96,
        padding: const EdgeInsets.fromLTRB(9, 8, 9, 8),
        decoration: BoxDecoration(
          gradient:  LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF123735), Color(0xFF142B2D), AppColors.surface],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF41C8B4).withValues(alpha: .25)),
          boxShadow: const [
            BoxShadow(color: Color(0x24000000), blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            _ConfidenceGauge(confidence: confidence),
            const SizedBox(width: 8),
            Expanded(
              child: _StadiumSummary(
                club: club,
                onTap: onStadiumTap,
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
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            padding: const EdgeInsets.fromLTRB(8, 7, 8, 6),
            decoration: BoxDecoration(
              color: AppColors.background.withValues(alpha: .62),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF41C8B4).withValues(alpha: .18)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Row(
                  children: [
                    Icon(Icons.stadium_rounded, color: AppColors.green, size: 11),
                    SizedBox(width: 4),
                    Text(
                      'ESTÁDIO',
                      style: TextStyle(
                        color: AppColors.green,
                        fontSize: 10,
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
                    fontSize: 13.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: _StadiumMetric(
                        icon: Icons.groups_2_outlined,
                        label: 'CAP.',
                        value: _compactCount(club.stadium.capacity),
                      ),
                    ),
                    Expanded(
                      child: _StadiumMetric(
                        icon: Icons.local_activity_outlined,
                        label: 'ING.',
                        value: compactMoney(club.stadium.ticketPrice),
                      ),
                    ),
                    Expanded(
                      child: _StadiumMetric(
                        icon: Icons.apartment_rounded,
                        label: 'ARQ.',
                        value: 'Nv. ${club.stadium.standsLevel}',
                      ),
                    ),
                  ],
                ),
              ],
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 9),
          const SizedBox(width: 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:  TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 8.1,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    height: 1,
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
    return SizedBox(
      width: 68,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'CONFIANÇA',
            maxLines: 1,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 9.4,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 54,
            height: 54,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: value / 100,
                    strokeWidth: 5.5,
                    strokeCap: StrokeCap.round,
                    backgroundColor: const Color(0xFF30433D),
                    color: AppColors.green,
                  ),
                ),
                Container(
                  width: 43,
                  height: 43,
                  decoration: const BoxDecoration(
                    color: Color(0xDD101820),
                    shape: BoxShape.circle,
                  ),
                ),
                Text(
                  '$value%',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 17.5,
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
