import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class CareerHubInfoLinks extends StatelessWidget {
  const CareerHubInfoLinks({
    super.key,
    required this.onAbout,
    required this.onHowItWorks,
    required this.onTerms,
    required this.onPrivacy,
    required this.onEditor,
    required this.onSettings,
  });

  final VoidCallback onAbout;
  final VoidCallback onHowItWorks;
  final VoidCallback onTerms;
  final VoidCallback onPrivacy;
  final VoidCallback? onEditor;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final items = <({IconData icon, String label, VoidCallback? onTap})>[
      (icon: Icons.info_outline_rounded, label: 'Sobre o jogo', onTap: onAbout),
      (icon: Icons.route_rounded, label: 'Como funciona', onTap: onHowItWorks),
      (icon: Icons.gavel_rounded, label: 'Termos de Uso', onTap: onTerms),
      (icon: Icons.privacy_tip_outlined, label: 'Privacidade', onTap: onPrivacy),
      (icon: Icons.edit_note_rounded, label: 'Editar dados do jogo', onTap: onEditor),
      (icon: Icons.settings_outlined, label: 'Configurações', onTap: onSettings),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 8) / 2;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final item in items)
              SizedBox(
                width: width,
                child: _InfoLinkTile(
                  icon: item.icon,
                  label: item.label,
                  onTap: item.onTap,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _InfoLinkTile extends StatelessWidget {
  const _InfoLinkTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 11),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.green, size: 19),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
