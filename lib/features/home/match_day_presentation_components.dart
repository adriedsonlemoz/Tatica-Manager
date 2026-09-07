import 'package:flutter/material.dart';

import '../../app/widgets/common.dart';
import '../../app/widgets/management_dashboard_widgets.dart';
import '../../core/theme/app_colors.dart';

class MatchDayQuickInfoGrid extends StatelessWidget {
  const MatchDayQuickInfoGrid({
    super.key,
    required this.position,
    required this.form,
    required this.morale,
    required this.condition,
    required this.pressure,
    required this.formation,
    required this.onPosition,
    required this.onForm,
    required this.onMorale,
    required this.onCondition,
    required this.onPressure,
    required this.onFormation,
    this.compact = false,
  });

  final int position;
  final List<String> form;
  final int morale;
  final int condition;
  final String pressure;
  final String formation;
  final VoidCallback onPosition;
  final VoidCallback onForm;
  final VoidCallback onMorale;
  final VoidCallback onCondition;
  final VoidCallback onPressure;
  final VoidCallback onFormation;
  final bool compact;

  @override
  Widget build(BuildContext context) => GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: compact ? 6 : 7,
        mainAxisSpacing: compact ? 6 : 7,
        childAspectRatio: compact ? 1.38 : .98,
        children: [
          _QuickInfo(
            icon: Icons.leaderboard_outlined,
            label: 'Posição na liga',
            value: position <= 0 ? '—' : '$positionº',
            caption: 'Abrir classificação',
            onTap: onPosition,
            compact: compact,
          ),
          _QuickInfo(
            icon: Icons.timeline_rounded,
            label: 'Últimos jogos',
            valueWidget: _FormDots(form: form),
            caption: form.isEmpty ? 'Abrir calendário' : 'Ver calendário',
            onTap: onForm,
            compact: compact,
          ),
          _QuickInfo(
            icon: Icons.sentiment_satisfied_alt_rounded,
            label: 'Moral do elenco',
            value: '$morale%',
            caption: morale >= 70 ? 'Elenco em alta' : morale >= 50 ? 'Elenco estável' : 'Exige atenção',
            onTap: onMorale,
            compact: compact,
          ),
          _QuickInfo(
            icon: Icons.favorite_outline_rounded,
            label: 'Condição média',
            value: '$condition%',
            caption: 'Abrir departamento médico',
            onTap: onCondition,
            compact: compact,
          ),
          _QuickInfo(
            icon: Icons.track_changes_rounded,
            label: 'Pressão',
            value: pressure,
            caption: 'Ajustar tática',
            onTap: onPressure,
            compact: compact,
          ),
          _QuickInfo(
            icon: Icons.grid_view_rounded,
            label: 'Formação',
            value: formation,
            caption: 'Abrir escalação',
            onTap: onFormation,
            compact: compact,
          ),
        ],
      );
}

class MatchDayPreparationCard extends StatelessWidget {
  const MatchDayPreparationCard({
    super.key,
    required this.unavailable,
    required this.startersReady,
    required this.onContinue,
    this.compact = false,
  });

  final int unavailable;
  final int startersReady;
  final VoidCallback onContinue;
  final bool compact;

  @override
  Widget build(BuildContext context) => SectionCard(
        padding: EdgeInsets.all(compact ? 10 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DashboardSectionHeader(
              title: 'Preparação da partida',
              subtitle: compact ? null : 'Condição da equipe antes do jogo',
            ),
            SizedBox(height: compact ? 7 : 12),
            if (compact)
              Row(
                children: [
                  Expanded(
                    child: _PrepMetric(
                      icon: Icons.groups_2_outlined,
                      title: 'Titulares',
                      value: '$startersReady/11',
                      color: startersReady == 11 ? AppColors.green : AppColors.warning,
                      compact: true,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _PrepMetric(
                      icon: Icons.medical_information_outlined,
                      title: 'Indisponíveis',
                      value: '$unavailable',
                      color: unavailable == 0 ? AppColors.green : AppColors.warning,
                      compact: true,
                    ),
                  ),
                  const SizedBox(width: 7),
                  FilledButton.icon(
                    onPressed: onContinue,
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: const Text('Preparar'),
                  ),
                ],
              )
            else ...[
              Row(
                children: [
                  Expanded(
                    child: _PrepMetric(
                      icon: Icons.groups_2_outlined,
                      title: 'Titulares',
                      value: '$startersReady/11',
                      color: startersReady == 11 ? AppColors.green : AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _PrepMetric(
                      icon: Icons.medical_information_outlined,
                      title: 'Indisponíveis',
                      value: '$unavailable',
                      color: unavailable == 0 ? AppColors.green : AppColors.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onContinue,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Ir para preparação da equipe'),
                ),
              ),
            ],
          ],
        ),
      );
}

class _QuickInfo extends StatelessWidget {
  const _QuickInfo({
    required this.icon,
    required this.label,
    this.value,
    this.valueWidget,
    required this.caption,
    required this.onTap,
    required this.compact,
  });

  final IconData icon;
  final String label;
  final String? value;
  final Widget? valueWidget;
  final String caption;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(17),
          child: Ink(
            padding: EdgeInsets.all(compact ? 6 : 9),
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: AppColors.green.withValues(alpha: .22)),
            ),
            child: Stack(
              children: [
                const Positioned(
                  right: -2,
                  top: -2,
                  child: Icon(Icons.chevron_right_rounded, color: AppColors.muted, size: 16),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: AppColors.green, size: compact ? 18 : 22),
                      SizedBox(height: compact ? 3 : 6),
                      Text(
                        label,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.muted, fontSize: compact ? 10 : 11, fontWeight: FontWeight.w800),
                      ),
                      SizedBox(height: compact ? 2 : 5),
                      valueWidget ??
                          Text(
                            value ?? '—',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: AppColors.green, fontSize: 13, fontWeight: FontWeight.w900),
                          ),
                      if (!compact) ...[
                        const SizedBox(height: 3),
                        Text(
                          caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.muted, fontSize: 10),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _PrepMetric extends StatelessWidget {
  const _PrepMetric({required this.icon, required this.title, required this.value, required this.color, this.compact = false});

  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.all(compact ? 7 : 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppColors.muted, fontSize: 10)),
                  Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ],
        ),
      );
}

class _FormDots extends StatelessWidget {
  const _FormDots({required this.form});

  final List<String> form;

  @override
  Widget build(BuildContext context) {
    final recent = form.length > 5 ? form.sublist(form.length - 5) : form;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: recent
          .map(
            (result) {
              final win = result == 'V' || result == 'W';
              final draw = result == 'E';
              final color = win
                  ? AppColors.green
                  : draw
                      ? AppColors.warning
                      : AppColors.danger;
              return Container(
                width: 15,
                height: 15,
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: color.withValues(alpha: .14), shape: BoxShape.circle, border: Border.all(color: color)),
                child: Text(
                  win ? 'V' : draw ? 'E' : 'D',
                  style: TextStyle(color: color, fontSize: 10, height: 1, fontWeight: FontWeight.w900),
                ),
              );
            },
          )
          .toList(growable: false),
    );
  }
}
