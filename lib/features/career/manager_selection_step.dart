import 'package:flutter/material.dart';

import '../../app/widgets/common.dart';
import '../../app/widgets/manager_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../data/country_catalog.dart';
import '../../domain/career/manager_profile.dart';
import '../../domain/club/club_identity.dart';

class ManagerChoiceStep extends StatelessWidget {
  const ManagerChoiceStep({
    super.key,
    required this.onExisting,
    required this.onCreate,
  });

  final VoidCallback onExisting;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          Text(
            'Escolha seu técnico',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
           Text(
            'Você pode assumir a carreira com um técnico existente ou criar seu próprio treinador.',
            style: TextStyle(color: AppColors.muted, height: 1.4),
          ),
          const SizedBox(height: 18),
          _ChoiceCard(
            icon: Icons.badge_rounded,
            title: 'Usar técnico existente',
            subtitle: 'Escolha um treinador do banco do jogo ou de uma base importada.',
            onTap: onExisting,
          ),
          const SizedBox(height: 12),
          _ChoiceCard(
            icon: Icons.person_add_alt_1_rounded,
            title: 'Criar meu técnico',
            subtitle: 'Defina nome, idade, país, aparência e comece com um perfil próprio.',
            onTap: onCreate,
          ),
        ],
      );
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
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
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: SectionCard(
          borderColor: AppColors.green.withValues(alpha: .32),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: AppColors.green, size: 32),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 5),
                    Text(subtitle,
                        style:  TextStyle(
                            color: AppColors.muted, height: 1.35)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      );
}

class ExistingManagerSelectionStep extends StatelessWidget {
  const ExistingManagerSelectionStep({
    super.key,
    required this.pack,
    required this.selected,
    required this.onSelected,
  });

  final ClubIdentityPack pack;
  final ManagerProfile? selected;
  final ValueChanged<ManagerProfile> onSelected;

  @override
  Widget build(BuildContext context) {
    final clubs = {for (final club in pack.clubs) club.clubId: club.name};
    final managers = [...?pack.managers]
      ..sort((a, b) => b.reputation.compareTo(a.reputation));

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selecionar técnico',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 3),
                   Text(
                    'Escolha diretamente no banco de técnicos disponível para esta carreira.',
                    style: TextStyle(color: AppColors.muted, height: 1.35),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                '${managers.length}',
                style: const TextStyle(
                  color: AppColors.green,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (managers.isEmpty)
          const EmptyState(
            icon: Icons.sports_rounded,
            title: 'Nenhum técnico disponível',
            text: 'Importe uma base com técnicos na Central de Edição.',
          )
        else
          ...managers.map((manager) {
            final isSelected = selected?.id.isNotEmpty == true
                ? selected!.id == manager.id
                : identical(selected, manager);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onSelected(manager),
                child: SectionCard(
                  padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
                  borderColor: isSelected ? AppColors.green : null,
                  child: Row(
                    children: [
                      ManagerAvatar(manager: manager, size: 56),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    manager.preferredName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.green.withValues(alpha: .10),
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: Text(
                                    'REP ${manager.reputation}',
                                    style: const TextStyle(
                                      color: AppColors.green,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 9,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${CountryCatalog.flagOf(manager.nationality)} ${manager.nationality} • ${manager.ageAtStart} anos',
                              style:  TextStyle(
                                color: AppColors.muted,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${clubs[manager.currentClubId] ?? 'Livre'} • ${manager.style}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        isSelected
                            ? Icons.check_circle_rounded
                            : Icons.chevron_right_rounded,
                        color: isSelected ? AppColors.green : AppColors.muted,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}
