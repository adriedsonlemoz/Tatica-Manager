import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/settings/match_presentation_settings.dart';
import '../../game/lineup/lineup_engine.dart';

class PreMatchDurationCard extends StatelessWidget {
  const PreMatchDurationCard({
    super.key,
    required this.selectedMinutes,
    required this.onChanged,
  });

  final int selectedMinutes;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => _PremiumPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _PanelHeading(
              icon: Icons.timer_outlined,
              title: 'DURAÇÃO DA TRANSMISSÃO',
              subtitle:
                  'Cada opção indica minutos reais por tempo. O Match Engine continua simulando os mesmos 90 minutos.',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                for (var index = 0; index < MatchDurationPreset.values.length; index++) ...[
                  Expanded(
                    child: _DurationOption(
                      preset: MatchDurationPreset.values[index],
                      selected: MatchDurationPreset.values[index].minutes == selectedMinutes,
                      onTap: () => onChanged(MatchDurationPreset.values[index].minutes),
                    ),
                  ),
                  if (index != MatchDurationPreset.values.length - 1)
                    const SizedBox(width: 6),
                ],
              ],
            ),
          ],
        ),
      );
}

class PreMatchPlanCard extends StatelessWidget {
  const PreMatchPlanCard({
    super.key,
    required this.validation,
    required this.formationLabel,
    required this.suggestedDiffers,
    required this.onLineupTap,
    required this.onTacticsTap,
    required this.onAutoSelect,
  });

  final LineupValidation validation;
  final String formationLabel;
  final bool suggestedDiffers;
  final VoidCallback onLineupTap;
  final VoidCallback onTacticsTap;
  final VoidCallback onAutoSelect;

  @override
  Widget build(BuildContext context) {
    final canAutoSelect = suggestedDiffers || !validation.valid;
    return _PremiumPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _RoundIcon(icon: Icons.assignment_turned_in_outlined),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'PLANO DE JOGO',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .25,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                decoration: BoxDecoration(
                  color: (validation.valid ? AppColors.green : AppColors.warning)
                      .withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: (validation.valid ? AppColors.green : AppColors.warning)
                        .withValues(alpha: .28),
                  ),
                ),
                child: Text(
                  validation.valid ? 'PRONTA' : 'REVISAR',
                  style: TextStyle(
                    color: validation.valid ? AppColors.green : AppColors.warning,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(child: _PlanMetric(label: 'Formação', value: formationLabel)),
              const _MetricDivider(),
              Expanded(
                child: _PlanMetric(
                  label: 'Titulares',
                  value: '${validation.assignments.length}/11',
                ),
              ),
              const _MetricDivider(),
              Expanded(
                child: _PlanMetric(
                  label: 'Força',
                  value: '${validation.averageStrength}',
                ),
              ),
            ],
          ),
          if (!validation.valid) ...[
            const SizedBox(height: 10),
            Text(
              validation.message,
              style: const TextStyle(color: AppColors.warning, fontSize: 9.5),
            ),
          ],
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: _PlanAction(
                  icon: Icons.groups_2_rounded,
                  label: 'Escalação',
                  onTap: onLineupTap,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PlanAction(
                  icon: Icons.tune_rounded,
                  label: 'Tática',
                  onTap: onTacticsTap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: canAutoSelect ? onAutoSelect : null,
              borderRadius: BorderRadius.circular(13),
              child: Ink(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                decoration: BoxDecoration(
                  color: canAutoSelect
                      ? AppColors.green.withValues(alpha: .08)
                      : AppColors.surfaceSoft.withValues(alpha: .58),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: canAutoSelect
                        ? AppColors.green.withValues(alpha: .26)
                        : AppColors.border.withValues(alpha: .46),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      canAutoSelect
                          ? Icons.auto_fix_high_rounded
                          : Icons.check_circle_rounded,
                      size: 18,
                      color: canAutoSelect ? AppColors.green : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        canAutoSelect
                            ? 'Aplicar melhor escalação disponível'
                            : 'Melhor escalação disponível já selecionada',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: canAutoSelect ? AppColors.green : AppColors.textSecondary,
                          fontSize: 9.6,
                          fontWeight: FontWeight.w800,
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
    );
  }
}


class _PremiumPanel extends StatelessWidget {
  const _PremiumPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.panelGradient,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border.withValues(alpha: .82)),
          boxShadow: const [
            BoxShadow(color: Color(0x26000000), blurRadius: 14, offset: Offset(0, 6)),
          ],
        ),
        child: child,
      );
}

class _PanelHeading extends StatelessWidget {
  const _PanelHeading({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RoundIcon(icon: icon),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style:  TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 8.6,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.green.withValues(alpha: .32),
              AppColors.green.withValues(alpha: .08),
            ],
          ),
          border: Border.all(color: AppColors.green.withValues(alpha: .35)),
        ),
        child: Icon(icon, color: AppColors.green, size: 20),
      );
}

class _DurationOption extends StatelessWidget {
  const _DurationOption({
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  final MatchDurationPreset preset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13),
          child: Ink(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
            decoration: BoxDecoration(
              gradient: selected
                  ? LinearGradient(
                      colors: [
                        AppColors.green.withValues(alpha: .22),
                        AppColors.green.withValues(alpha: .10),
                      ],
                    )
                  : null,
              color: selected ? null : AppColors.surfaceRaised.withValues(alpha: .56),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: selected
                    ? AppColors.green.withValues(alpha: .75)
                    : AppColors.border.withValues(alpha: .62),
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.green.withValues(alpha: .10),
                        blurRadius: 12,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (selected) ...[
                  const Icon(Icons.check_rounded, size: 15, color: AppColors.green),
                  const SizedBox(width: 4),
                ],
                Flexible(
                  child: Text(
                    preset.shortLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? AppColors.green : AppColors.white,
                      fontSize: 9.3,
                      fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _PlanMetric extends StatelessWidget {
  const _PlanMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(
            label,
            style:  TextStyle(
              color: AppColors.textSecondary,
              fontSize: 9.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      );
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider();

  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 44,
        margin: const EdgeInsets.symmetric(horizontal: 7),
        color: AppColors.border.withValues(alpha: .68),
      );
}

class _PlanAction extends StatelessWidget {
  const _PlanAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised.withValues(alpha: .64),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border.withValues(alpha: .72)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppColors.green, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

