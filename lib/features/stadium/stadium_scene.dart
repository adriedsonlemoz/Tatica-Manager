import 'package:flutter/material.dart';

import '../../app/widgets/common.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/club/club.dart';
import '../../game/stadium/stadium_engine.dart';

class StadiumOverviewCard extends StatelessWidget {
  const StadiumOverviewCard({
    super.key,
    required this.club,
    required this.projectedAttendance,
    this.onEdit,
  });

  final Club club;
  final int projectedAttendance;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final stadium = club.stadium;
    final condition = StadiumEngine.maintenanceScore(stadium);
    return SectionCard(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 2, 4, 10),
            child: Text(
              'VISÃO GERAL DO ESTÁDIO',
              style: TextStyle(
                color: AppColors.green,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 21 / 7.2,
              child: Image.asset(
                'assets/images/stadium/stadium_night.webp',
                width: double.infinity,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      stadium.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _OverviewMetric(
                        icon: Icons.chair_alt_rounded,
                        label: 'CAPACIDADE',
                        value: _formatCount(stadium.capacity),
                      ),
                    ),
                    const _MetricDivider(),
                    Expanded(
                      child: _OverviewMetric(
                        icon: Icons.groups_rounded,
                        label: 'PÚBLICO PROJ.',
                        value: _formatCount(projectedAttendance),
                      ),
                    ),
                    const _MetricDivider(),
                    Expanded(
                      child: _OverviewMetric(
                        icon: Icons.local_activity_rounded,
                        label: 'PREÇO DO INGRESSO',
                        value: formatMoney(stadium.ticketPrice),
                      ),
                    ),
                    const _MetricDivider(),
                    Expanded(
                      child: _ConditionMetric(
                        condition: condition,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider();

  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 52,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        color: AppColors.border.withValues(alpha: .75),
      );
}

class _OverviewMetric extends StatelessWidget {
  const _OverviewMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.green, size: 21),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 7.5,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 5),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: const TextStyle(
                      color: AppColors.green,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}

class _ConditionMetric extends StatelessWidget {
  const _ConditionMetric({required this.condition});

  final int condition;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.monitor_heart_rounded, color: AppColors.green, size: 20),
              SizedBox(width: 5),
              Expanded(
                child: Text(
                  'CONDIÇÃO',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 7.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            StadiumEngine.conditionLabel(condition),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.green,
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: condition / 100,
              minHeight: 6,
              backgroundColor: AppColors.surfaceSoft,
              valueColor: const AlwaysStoppedAnimation(AppColors.green),
            ),
          ),
        ],
      );
}

String _formatCount(int value) {
  if (value >= 1000000) {
    final number = value / 1000000;
    return '${number.toStringAsFixed(number >= 10 ? 0 : 1)}M';
  }
  if (value >= 1000) {
    final number = value / 1000;
    return '${number.toStringAsFixed(1)}K';
  }
  return '$value';
}
