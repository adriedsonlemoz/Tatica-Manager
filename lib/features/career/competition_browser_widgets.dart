import 'package:flutter/material.dart';

import '../../app/widgets/common.dart';
import '../../core/theme/app_colors.dart';

enum CompetitionBrowserLevel { country, championship, series, clubs }

class CompetitionBreadcrumb extends StatelessWidget {
  const CompetitionBreadcrumb({
    super.key,
    required this.level,
    required this.onNavigate,
    this.country = 'Brasil',
    this.championship = 'Liga Nacional',
    this.series = 'Série A',
  });

  final CompetitionBrowserLevel level;
  final ValueChanged<CompetitionBrowserLevel> onNavigate;
  final String country;
  final String championship;
  final String series;

  @override
  Widget build(BuildContext context) => SectionCard(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _Crumb(
                label: 'País',
                active: level == CompetitionBrowserLevel.country,
                onTap: () => onNavigate(CompetitionBrowserLevel.country),
              ),
              if (level.index >= CompetitionBrowserLevel.championship.index) ...[
                const _Arrow(),
                _Crumb(
                  label: country,
                  active: level == CompetitionBrowserLevel.championship,
                  onTap: () => onNavigate(CompetitionBrowserLevel.championship),
                ),
              ],
              if (level.index >= CompetitionBrowserLevel.series.index) ...[
                const _Arrow(),
                _Crumb(
                  label: championship,
                  active: level == CompetitionBrowserLevel.series,
                  onTap: () => onNavigate(CompetitionBrowserLevel.series),
                ),
              ],
              if (level.index >= CompetitionBrowserLevel.clubs.index) ...[
                const _Arrow(),
                _Crumb(
                  label: series,
                  active: false,
                  onTap: () => onNavigate(CompetitionBrowserLevel.series),
                ),
                const _Arrow(),
                _Crumb(
                  label: 'Clubes',
                  active: true,
                  onTap: () => onNavigate(CompetitionBrowserLevel.clubs),
                ),
              ],
            ],
          ),
        ),
      );
}

class CompetitionStageTile extends StatelessWidget {
  const CompetitionStageTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SectionCard(
        padding: EdgeInsets.zero,
        child: ListTile(
          onTap: onTap,
          minTileHeight: 70,
          leading: Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: AppColors.green),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
      );
}

class _Crumb extends StatelessWidget {
  const _Crumb({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          child: Text(
            label,
            style: TextStyle(
              color: active ? AppColors.green : AppColors.muted,
              fontSize: 12,
              fontWeight: active ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
      );
}

class _Arrow extends StatelessWidget {
  const _Arrow();

  @override
  Widget build(BuildContext context) =>  Padding(
        padding: EdgeInsets.symmetric(horizontal: 2),
        child: Icon(Icons.chevron_right_rounded, size: 15, color: AppColors.muted),
      );
}
