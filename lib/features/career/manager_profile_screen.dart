import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/widgets/common.dart';
import '../../app/widgets/manager_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../data/country_catalog.dart';
import '../../domain/formation/formation.dart';
import '../../domain/tactic/tactic.dart';

class ManagerProfileScreen extends ConsumerWidget {
  const ManagerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final career = ref.watch(gameControllerProvider).career!;
    final manager = career.manager;
    final clubNames = {for (final club in career.clubs) club.id: club.name};
    final history = career.managerHistory.reversed.toList(growable: false);

    return PremiumScaffold(
      appBar: const GameTopBar(
        title: 'Perfil do técnico',
        subtitle: 'Carreira',
      ),
      safeBottom: true,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
        children: [
          SectionCard(
            borderColor: AppColors.green.withValues(alpha: .35),
            child: Row(
              children: [
                ManagerAvatar(manager: manager, size: 88),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        manager.preferredName,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${CountryCatalog.flagOf(manager.nationality)} ${manager.nationality} • ${manager.ageInSeason(career.season)} anos',
                        style: const TextStyle(color: AppColors.muted),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        career.managerCareer.isEmployed
                            ? career.userClub.name
                            : 'Sem clube',
                        style: const TextStyle(
                          color: AppColors.green,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SectionCard(
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.0,
              children: [
                _ProfileData('Reputação', '${manager.reputation}'),
                _ProfileData('Nível geral', '${manager.overall}'),
                _ProfileData('Estilo', manager.style),
                _ProfileData('Experiência', '${manager.experienceYears} anos'),
                _ProfileData('Formação', manager.preferredFormation.label),
                _ProfileData('Mentalidade', manager.preferredMentality.label),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'HISTÓRICO',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                if (history.isEmpty)
                  const Text(
                    'O histórico da carreira aparecerá aqui conforme as temporadas avançarem.',
                    style: TextStyle(color: AppColors.muted),
                  )
                else
                  ...history.map(
                    (entry) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.workspace_premium_outlined,
                        color: AppColors.green,
                      ),
                      title: Text(
                        clubNames[entry.clubId] ?? 'Clube anterior',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text('Temporada ${entry.season} • ${entry.age} anos'),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const SectionCard(
            child: Row(
              children: [
                Icon(Icons.emoji_events_outlined, color: AppColors.green),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Títulos e estatísticas adicionais serão exibidos aqui quando esses dados existirem na carreira.',
                    style: TextStyle(color: AppColors.muted, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileData extends StatelessWidget {
  const _ProfileData(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(color: AppColors.muted, fontSize: 10)),
            const SizedBox(height: 3),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      );
}
