import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/widgets/common.dart';
import '../../app/widgets/manager_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../data/country_catalog.dart';
import '../../domain/formation/formation.dart';
import '../../domain/tactic/tactic.dart';
import '../../game/career/manager_career_engine.dart';

class ManagerProfileScreen extends ConsumerWidget {
  const ManagerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final career = ref.watch(gameControllerProvider).career!;
    final manager = career.manager;
    final clubNames = {for (final club in career.clubs) club.id: club.name};
    final history = career.managerHistory.reversed.toList(growable: false);
    final activeTenure = career.managerCareer.activeTenure;
    final standingIndex = career.standings.indexWhere(
      (item) => item.clubId == career.userClubId,
    );
    final standing = standingIndex < 0 ? null : career.standings[standingIndex];
    final currentReputation = ManagerCareerEngine.reputationFor(career);
    final birthplace = manager.birthPlaceSummary();

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
            child: Column(
              children: [
                Row(
                  children: [
                    ManagerAvatar(manager: manager, size: 88),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            manager.displayName,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          if (manager.nickname.trim().isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Conhecido como ${manager.nickname}',
                              style: const TextStyle(color: AppColors.muted),
                            ),
                          ],
                          const SizedBox(height: 5),
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
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),
                _ProfileFacts(
                  facts: [
                    _ProfileFact(
                      Icons.location_on_outlined,
                      'Natural de',
                      birthplace.isEmpty ? 'Não informado' : birthplace,
                    ),
                    _ProfileFact(
                      Icons.description_outlined,
                      'Contrato',
                      manager.contractUntilSeason == null
                          ? 'Não informado'
                          : 'Até ${manager.contractUntilSeason}',
                    ),
                    _ProfileFact(
                      Icons.calendar_today_outlined,
                      'No cargo',
                      activeTenure == null
                          ? 'Livre no mercado'
                          : '${career.currentDate.difference(activeTenure.startedAt).inDays + 1} dias',
                    ),
                  ],
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
                _ProfileData('Reputação atual', '$currentReputation'),
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
                  'SITUAÇÃO ATUAL',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 9),
                if (career.managerCareer.isEmployed && standing != null)
                  _ProfileFacts(
                    facts: [
                      _ProfileFact(
                        Icons.leaderboard_outlined,
                        'Posição',
                        '${standingIndex + 1}º lugar',
                      ),
                      _ProfileFact(
                        Icons.stars_outlined,
                        'Pontos',
                        '${standing.points} em ${standing.played} jogos',
                      ),
                      _ProfileFact(
                        Icons.sports_soccer_outlined,
                        'Clube',
                        career.userClub.name,
                      ),
                    ],
                  )
                else
                  const Text(
                    'Você está livre no mercado. As propostas recebidas aparecem na área de carreira.',
                    style: TextStyle(color: AppColors.muted, height: 1.35),
                  ),
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

class _ProfileFact {
  const _ProfileFact(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;
}

class _ProfileFacts extends StatelessWidget {
  const _ProfileFacts({required this.facts});

  final List<_ProfileFact> facts;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          for (var index = 0; index < facts.length; index++) ...[
            Row(
              children: [
                Icon(facts[index].icon, color: AppColors.green, size: 17),
                const SizedBox(width: 8),
                Text(
                  '${facts[index].label}: ',
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
                Expanded(
                  child: Text(
                    facts[index].value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            if (index != facts.length - 1) const SizedBox(height: 8),
          ],
        ],
      );
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
