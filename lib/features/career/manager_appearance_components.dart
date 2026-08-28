import 'package:flutter/material.dart';

import '../../app/widgets/common.dart';
import '../../core/theme/app_colors.dart';

class AppearanceGroupCard extends StatelessWidget {
  const AppearanceGroupCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: SectionCard(
          padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: .35,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 10.5,
                ),
              ),
              const SizedBox(height: 9),
              ...children,
            ],
          ),
        ),
      );
}

class AppearanceChoiceRow extends StatelessWidget {
  const AppearanceChoiceRow({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.compactLabels = false,
  });

  final String label;
  final List<String> options;
  final int selected;
  final ValueChanged<int> onSelected;
  final bool compactLabels;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: [
                for (var index = 0; index < options.length; index++)
                  ChoiceChip(
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 3),
                    selectedColor: AppColors.green.withValues(alpha: .17),
                    backgroundColor: AppColors.surfaceRaised,
                    side: BorderSide(
                      color: selected == index
                          ? AppColors.green
                          : AppColors.border,
                    ),
                    label: Text(
                      options[index],
                      style: TextStyle(
                        fontSize: compactLabels ? 10 : 11,
                        fontWeight: FontWeight.w800,
                        color: selected == index
                            ? AppColors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                    selected: selected == index,
                    onSelected: (_) => onSelected(index),
                  ),
              ],
            ),
          ],
        ),
      );
}
