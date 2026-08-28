import 'package:flutter/material.dart';

import '../../app/widgets/common.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/formation/formation.dart';
import 'formation_preview.dart';

class CareerSetupStep extends StatelessWidget {
  const CareerSetupStep({
    super.key,
    required this.formation,
    required this.onFormation,
  });

  final FormationType formation;
  final ValueChanged<FormationType> onFormation;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      children: [
        Text(
          'Escolha a formação inicial',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(
          'Nesta etapa, escolha apenas o desenho da equipe em campo. Mentalidade, pressão e ritmo ficam na próxima tela.',
          style: TextStyle(color: AppColors.muted, height: 1.4),
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: FormationType.values.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            mainAxisExtent: 132,
          ),
          itemBuilder: (context, index) {
            final value = FormationType.values[index];
            final selected = value == formation;
            return InkWell(
              onTap: () => onFormation(value),
              borderRadius: BorderRadius.circular(18),
              child: SectionCard(
                borderColor: selected ? AppColors.green : null,
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Expanded(child: FormationMiniPitch(formation: value, height: 78)),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (selected) ...[
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 16,
                            color: AppColors.green,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          value.label,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
