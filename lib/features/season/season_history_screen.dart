import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/widgets/common.dart';
import '../../app/widgets/manager_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/career/manager_career.dart';
import '../../domain/career/manager_profile.dart';
import '../../domain/season/career_state.dart';
import '../../game/career/manager_career_engine.dart';
import '../career/manager_job_market_screen.dart';

class SeasonHistoryScreen extends ConsumerWidget {
  const SeasonHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final career = ref.watch(gameControllerProvider).career!;
    final history = career.seasonHistory.reversed.toList();
    final managerBySeason = {
      for (final entry in career.managerHistory) entry.season: entry,
    };
    final reputation = ManagerCareerEngine.reputationFor(career);
    final clubsCommanded = career.managerCareer.tenures
        .map((tenure) => tenure.clubId)
        .toSet()
        .length;
    final offers = career.managerCareer.offers
        .where((offer) => offer.isActiveOn(career.currentDate))
        .length;

    return PremiumScaffold(
      safeBottom: true,
      appBar: const GameTopBar(
        title: 'Carreira do técnico',
        subtitle: 'Trajetória, desempenho e oportunidades',
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
        children: [
          SectionCard(
            borderColor: career.managerEmployed ? AppColors.green : AppColors.warning,
            child: Row(
              children: [
                ManagerAvatar(manager: career.manager, size: 52),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        career.manager.preferredName,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${career.manager.ageInSeason(career.season)} anos • '
                        '${career.manager.nationality} • reputação $reputation/100',
                        style:  TextStyle(color: AppColors.muted),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        career.managerEmployed
                            ? 'Comandando ${career.userClub.name}'
                            : 'Sem clube • disponível para propostas',
                        style: TextStyle(
                          color: career.managerEmployed ? AppColors.green : AppColors.warning,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (career.manager.birthPlace.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Origem: ${career.manager.birthPlaceSummary(omitCountry: career.manager.birthCountry == career.manager.nationality)}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.muted),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RESUMO PROFISSIONAL',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Metric(label: 'Clubes', value: '$clubsCommanded'),
                    Metric(
                      label: 'Temporadas',
                      value: '${career.season - career.manager.careerStartSeason + 1}',
                    ),
                    Metric(label: 'Concluídas', value: '${career.seasonHistory.length}'),
                    Metric(label: 'Propostas', value: '$offers'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.work_history_rounded, color: AppColors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'TRAJETÓRIA DE CLUBES',
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                ...career.managerCareer.tenures.reversed.map(
                  (tenure) => _TenureTile(
                    tenure: tenure,
                    clubName: _clubName(career, tenure.clubId),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SectionCard(
            borderColor: offers > 0 ? AppColors.green : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.business_center_rounded, color: AppColors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'OPORTUNIDADES PROFISSIONAIS',
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ),
                    if (offers > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.green.withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '$offers NOVA${offers == 1 ? '' : 'S'}',
                          style: const TextStyle(
                            color: AppColors.green,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  career.managerEmployed
                      ? 'Seu desempenho, reputação e situação dos clubes influenciam as vagas e propostas recebidas.'
                      : 'Você está livre no mercado. Consulte vagas ou avance os dias para receber novos contatos.',
                  style:  TextStyle(color: AppColors.muted, fontSize: 11, height: 1.35),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ManagerJobMarketScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.manage_search_rounded),
                    label: Text(
                      offers > 0 ? 'Ver vagas e propostas ($offers)' : 'Procurar vagas disponíveis',
                    ),
                  ),
                ),
                if (career.managerEmployed) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _leaveClub(context, ref, career.userClub.name),
                      icon: const Icon(Icons.logout_rounded, color: AppColors.warning),
                      label: const Text('Deixar o clube atual'),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'TEMPORADAS',
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          if (history.isEmpty)
            const SectionCard(
              child: EmptyState(
                icon: Icons.history_rounded,
                title: 'Nenhuma temporada concluída',
                text:
                    'Quando a primeira temporada terminar, o desempenho ficará registrado aqui.',
              ),
            )
          else
            ...history.map(
              (summary) => _SeasonCard(
                summary: summary,
                manager: managerBySeason[summary.season],
              ),
            ),
        ],
      ),
    );
  }

  static String _clubName(CareerState career, String clubId) {
    for (final club in career.clubs) {
      if (club.id == clubId) return club.name;
    }
    return 'Clube anterior';
  }

  static Future<void> _leaveClub(
    BuildContext context,
    WidgetRef ref,
    String clubName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Deixar o clube?'),
        content: Text(
          'Você encerrará seu trabalho no $clubName e ficará sem clube até aceitar uma nova oportunidade. O histórico da passagem será preservado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Confirmar saída'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(gameControllerProvider.notifier).leaveCurrentClub();
    if (!context.mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ManagerJobMarketScreen()),
    );
  }
}

class _TenureTile extends StatelessWidget {
  const _TenureTile({required this.tenure, required this.clubName});

  final ManagerClubTenure tenure;
  final String clubName;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 7),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: tenure.active
              ? AppColors.green.withValues(alpha: .07)
              : AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: tenure.active
                ? AppColors.green.withValues(alpha: .28)
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              tenure.active ? Icons.sports_rounded : Icons.history_rounded,
              color: tenure.active ? AppColors.green : AppColors.muted,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(clubName, style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 2),
                  Text(
                    tenure.active
                        ? 'Desde ${shortDate(tenure.startedAt)} • temporada ${tenure.startSeason}'
                        : '${shortDate(tenure.startedAt)} → ${shortDate(tenure.endedAt!)} • ${tenure.endReason}',
                    style:  TextStyle(color: AppColors.muted, fontSize: 10.5),
                  ),
                ],
              ),
            ),
            if (tenure.active)
              const Text(
                'ATUAL',
                style: TextStyle(
                  color: AppColors.green,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
          ],
        ),
      );
}

class _SeasonCard extends StatelessWidget {
  const _SeasonCard({required this.summary, this.manager});

  final SeasonSummary summary;
  final ManagerCareerHistoryEntry? manager;

  @override
  Widget build(BuildContext context) => SectionCard(
        margin: const EdgeInsets.only(bottom: 9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'TEMPORADA ${summary.season}',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: summary.position <= 4
                        ? AppColors.green.withValues(alpha: .12)
                        : AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${summary.position}º',
                    style: TextStyle(
                      color: summary.position <= 4 ? AppColors.green : Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            if (manager != null) ...[
              const SizedBox(height: 7),
              Text(
                'Técnico: ${manager!.preferredName} • ${manager!.age} anos • ${manager!.nationality}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.muted),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Metric(label: 'Pontos', value: '${summary.points}'),
                Metric(label: 'Vitórias', value: '${summary.wins}'),
                Metric(label: 'Empates', value: '${summary.draws}'),
                Metric(label: 'Derrotas', value: '${summary.losses}'),
              ],
            ),
          ],
        ),
      );
}
