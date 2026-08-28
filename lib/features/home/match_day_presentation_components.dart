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

  @override
  Widget build(BuildContext context) => GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 7,
        mainAxisSpacing: 7,
        childAspectRatio: .98,
        children: [
          _QuickInfo(
            icon: Icons.leaderboard_outlined,
            label: 'Posição na liga',
            value: position <= 0 ? '—' : '$positionº',
            caption: 'Abrir classificação',
            onTap: onPosition,
          ),
          _QuickInfo(
            icon: Icons.timeline_rounded,
            label: 'Últimos jogos',
            valueWidget: _FormDots(form: form),
            caption: form.isEmpty ? 'Abrir calendário' : 'Ver calendário',
            onTap: onForm,
          ),
          _QuickInfo(
            icon: Icons.sentiment_satisfied_alt_rounded,
            label: 'Moral do elenco',
            value: '$morale%',
            caption: morale >= 70 ? 'Elenco em alta' : morale >= 50 ? 'Elenco estável' : 'Exige atenção',
            onTap: onMorale,
          ),
          _QuickInfo(
            icon: Icons.favorite_outline_rounded,
            label: 'Condição média',
            value: '$condition%',
            caption: 'Abrir departamento médico',
            onTap: onCondition,
          ),
          _QuickInfo(
            icon: Icons.track_changes_rounded,
            label: 'Pressão',
            value: pressure,
            caption: 'Ajustar tática',
            onTap: onPressure,
          ),
          _QuickInfo(
            icon: Icons.grid_view_rounded,
            label: 'Formação',
            value: formation,
            caption: 'Abrir escalação',
            onTap: onFormation,
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
  });

  final int unavailable;
  final int startersReady;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) => SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DashboardSectionHeader(
              title: 'Preparação da partida',
              subtitle: 'Condição da equipe antes do jogo',
            ),
            const SizedBox(height: 12),
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
  });

  final IconData icon;
  final String label;
  final String? value;
  final Widget? valueWidget;
  final String caption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(17),
          child: Ink(
            padding: const EdgeInsets.all(9),
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
                      Icon(icon, color: AppColors.green, size: 22),
                      const SizedBox(height: 6),
                      Text(
                        label,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.muted, fontSize: 8.5, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 5),
                      valueWidget ??
                          Text(
                            value ?? '—',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: AppColors.green, fontSize: 12, fontWeight: FontWeight.w900),
                          ),
                      const SizedBox(height: 3),
                      Text(
                        caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.muted, fontSize: 7.5),
                      ),
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
  const _PrepMetric({required this.icon, required this.title, required this.value, required this.color});

  final IconData icon;
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
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
                  Text(title, style: const TextStyle(color: AppColors.muted, fontSize: 8.8)),
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
                  style: TextStyle(color: color, fontSize: 7, fontWeight: FontWeight.w900),
                ),
              );
            },
          )
          .toList(growable: false),
    );
  }
}
