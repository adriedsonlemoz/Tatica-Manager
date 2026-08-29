import 'package:flutter/material.dart';

import '../../app/widgets/common.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/tactic/tactic.dart';
import '../../domain/settings/match_presentation_settings.dart';

class CareerStyleStep extends StatelessWidget {
  const CareerStyleStep({
    super.key,
    required this.mentality,
    required this.pressing,
    required this.tempo,
    required this.onMentality,
    required this.onPressing,
    required this.onTempo,
    required this.matchDuration,
    required this.onMatchDuration,
  });

  final Mentality mentality;
  final Pressing pressing;
  final MatchTempo tempo;
  final ValueChanged<Mentality> onMentality;
  final ValueChanged<Pressing> onPressing;
  final ValueChanged<MatchTempo> onTempo;
  final MatchDurationPreset matchDuration;
  final ValueChanged<MatchDurationPreset> onMatchDuration;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        children: [
          Text(
            'Defina o estilo inicial',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            'Mentalidade, pressão e ritmo ficam reunidos aqui para deixar a identidade tática mais clara antes de começar a carreira.',
            style: TextStyle(color: AppColors.muted, height: 1.4),
          ),
          const SizedBox(height: 16),
          _VisualChoiceGroup<Mentality>(
            title: 'MENTALIDADE',
            subtitle: 'Postura geral da equipe com e sem a bola.',
            value: mentality,
            values: Mentality.values,
            icon: (value) => switch (value) {
              Mentality.defensive => Icons.shield_rounded,
              Mentality.balanced => Icons.balance_rounded,
              Mentality.attacking => Icons.sports_soccer_rounded,
            },
            label: (value) => value.label,
            description: (value) => switch (value) {
              Mentality.defensive => 'Mais proteção',
              Mentality.balanced => 'Equilíbrio geral',
              Mentality.attacking => 'Mais presença ofensiva',
            },
            onChanged: onMentality,
          ),
          const SizedBox(height: 14),
          _VisualChoiceGroup<Pressing>(
            title: 'PRESSÃO',
            subtitle: 'Quanto o time tenta recuperar a bola sem posse.',
            value: pressing,
            values: Pressing.values,
            icon: (value) => switch (value) {
              Pressing.low => Icons.shield_outlined,
              Pressing.medium => Icons.sync_alt_rounded,
              Pressing.high => Icons.bolt_rounded,
            },
            label: (value) => value.label,
            description: (value) => switch (value) {
              Pressing.low => 'Conserva energia',
              Pressing.medium => 'Equilíbrio',
              Pressing.high => 'Recuperação agressiva',
            },
            onChanged: onPressing,
          ),
          const SizedBox(height: 14),
          _VisualChoiceGroup<MatchTempo>(
            title: 'RITMO',
            subtitle: 'Velocidade das decisões e circulação da bola.',
            value: tempo,
            values: MatchTempo.values,
            icon: (value) => switch (value) {
              MatchTempo.slow => Icons.hourglass_bottom_rounded,
              MatchTempo.normal => Icons.speed_rounded,
              MatchTempo.fast => Icons.fast_forward_rounded,
            },
            label: (value) => value.label,
            description: (value) => switch (value) {
              MatchTempo.slow => 'Mais controle',
              MatchTempo.normal => 'Balanceado',
              MatchTempo.fast => 'Mais vertical',
            },
            onChanged: onTempo,
          ),
          const SizedBox(height: 14),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.timer_outlined, color: AppColors.green, size: 19),
                    SizedBox(width: 8),
                    Text(
                      'DURAÇÃO DA PARTIDA',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                 Text(
                  'Escolha quantos minutos reais cada tempo será apresentado. O Match Engine continua simulando os mesmos 90 minutos.',
                  style: TextStyle(color: AppColors.muted, fontSize: 11, height: 1.35),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    for (var index = 0;
                        index < MatchDurationPreset.values.length;
                        index++) ...[
                      if (index > 0) const SizedBox(width: 7),
                      Expanded(
                        child: _DurationChoiceCard(
                          preset: MatchDurationPreset.values[index],
                          selected:
                              MatchDurationPreset.values[index] == matchDuration,
                          onTap: () => onMatchDuration(
                            MatchDurationPreset.values[index],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SectionCard(
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.green),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Essas opções apenas configuram a tática inicial. Depois da assinatura, podem ser alteradas normalmente na área tática.',
                    style: TextStyle(color: AppColors.muted, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}

class _DurationChoiceCard extends StatelessWidget {
  const _DurationChoiceCard({
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  final MatchDurationPreset preset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.green.withValues(alpha: .13)
                : AppColors.surfaceRaised,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: selected ? AppColors.green : AppColors.border,
            ),
          ),
          child: Column(
            children: [
              Text(
                '${preset.minutes}',
                style: TextStyle(
                  color: selected ? AppColors.green : AppColors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 1),
               Text(
                'min/tempo',
                style: TextStyle(color: AppColors.muted, fontSize: 9),
              ),
            ],
          ),
        ),
      );
}

class _VisualChoiceGroup<T> extends StatelessWidget {
  const _VisualChoiceGroup({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.values,
    required this.icon,
    required this.label,
    required this.description,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final T value;
  final List<T> values;
  final IconData Function(T value) icon;
  final String Function(T value) label;
  final String Function(T value) description;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                for (var index = 0; index < values.length; index++) ...[
                  if (index > 0) const SizedBox(width: 7),
                  Expanded(
                    child: _VisualChoiceCard<T>(
                      selected: values[index] == value,
                      icon: icon(values[index]),
                      label: label(values[index]),
                      description: description(values[index]),
                      onTap: () => onChanged(values[index]),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      );
}

class _VisualChoiceCard<T> extends StatelessWidget {
  const _VisualChoiceCard({
    required this.selected,
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.green.withValues(alpha: .15)
                : AppColors.surfaceRaised,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.green : AppColors.border,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? AppColors.green : AppColors.muted),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 9,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      );
}
