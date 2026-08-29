import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/widgets/common.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/career/manager_career.dart';
import '../../game/career/manager_career_engine.dart';

class ManagerJobMarketScreen extends ConsumerWidget {
  const ManagerJobMarketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final career = ref.watch(gameControllerProvider).career!;
    final vacancies = ManagerCareerEngine.availableJobs(career);
    final reputation = ManagerCareerEngine.reputationFor(career);
    final activeOffers = career.managerCareer.offers
        .where((offer) => offer.isActiveOn(career.currentDate))
        .toList()
      ..sort((a, b) => b.interestScore.compareTo(a.interestScore));

    return PremiumScaffold(
      safeBottom: true,
      appBar: const GameTopBar(
        title: 'Mercado de técnicos',
        subtitle: 'Vagas, propostas e próximos desafios',
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
        children: [
          SectionCard(
            borderColor: career.managerUnemployed ? AppColors.warning : AppColors.green,
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: (career.managerUnemployed ? AppColors.warning : AppColors.green)
                        .withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    career.managerUnemployed
                        ? Icons.work_off_rounded
                        : Icons.badge_rounded,
                    color: career.managerUnemployed ? AppColors.warning : AppColors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        career.managerUnemployed
                            ? 'Disponível no mercado'
                            : 'Aberto a novos projetos',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Reputação profissional $reputation/100 • ${vacancies.length} vaga(s) mapeada(s)',
                        style:  TextStyle(color: AppColors.muted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (activeOffers.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'PROPOSTAS RECEBIDAS',
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            ...activeOffers.map(
              (offer) => _OfferCard(
                offer: offer,
                onAccept: () => _accept(context, ref, offer.clubId),
                onDecline: () => ref
                    .read(gameControllerProvider.notifier)
                    .declineManagerOffer(offer.id),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.work_history_rounded, color: AppColors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'VAGAS DISPONÍVEIS',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                '${vacancies.length}',
                style:  TextStyle(color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...vacancies.map(
            (vacancy) => SectionCard(
              margin: const EdgeInsets.only(bottom: 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      ClubBadge(club: vacancy.club, size: 46),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vacancy.club.name,
                              style: const TextStyle(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              vacancy.reason,
                              style:  TextStyle(
                                color: AppColors.muted,
                                fontSize: 10.5,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      OverallShield(value: vacancy.club.reputation, compact: true),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _Info(
                          label: 'Interesse',
                          value: '${vacancy.interestScore}%',
                        ),
                      ),
                      Expanded(
                        child: _Info(
                          label: 'Orçamento',
                          value: compactMoney(vacancy.club.transferBudget),
                        ),
                      ),
                      Expanded(
                        child: _Info(
                          label: 'Exigência',
                          value: '${vacancy.requiredReputation}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      onPressed: vacancy.canApply
                          ? () => _accept(context, ref, vacancy.club.id)
                          : null,
                      icon: const Icon(Icons.send_rounded),
                      label: Text(
                        vacancy.canApply
                            ? 'Candidatar-se à vaga'
                            : 'Perfil ainda abaixo da exigência',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> _accept(
    BuildContext context,
    WidgetRef ref,
    String clubId,
  ) async {
    final career = ref.read(gameControllerProvider).career!;
    final club = career.clubs.firstWhere((item) => item.id == clubId);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Assumir ${club.name}?'),
        content: Text(
          career.managerEmployed
              ? 'Ao aceitar, você encerra seu trabalho no clube atual e assume imediatamente o novo projeto.'
              : 'Ao aceitar, você volta a comandar um clube e retoma a rotina completa da carreira.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Aceitar desafio'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final accepted = await ref
        .read(gameControllerProvider.notifier)
        .acceptManagerJob(clubId);
    if (accepted && context.mounted) Navigator.of(context).pop();
  }
}

class _OfferCard extends ConsumerWidget {
  const _OfferCard({
    required this.offer,
    required this.onAccept,
    required this.onDecline,
  });

  final ManagerJobOffer offer;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final career = ref.watch(gameControllerProvider).career!;
    final club = career.clubs.firstWhere((item) => item.id == offer.clubId);
    return SectionCard(
      margin: const EdgeInsets.only(bottom: 8),
      borderColor: AppColors.green,
      child: Column(
        children: [
          Row(
            children: [
              ClubBadge(club: club, size: 48),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(club.name, style: const TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 2),
                    Text(
                      '${offer.interestScore}% de interesse • expira ${shortDate(offer.expiresAt)}',
                      style: const TextStyle(color: AppColors.green, fontSize: 10.5),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      offer.reason,
                      style:  TextStyle(color: AppColors.muted, fontSize: 10.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDecline,
                  child: const Text('Recusar'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: onAccept,
                  child: const Text('Aceitar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style:  TextStyle(color: AppColors.muted, fontSize: 9)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
        ],
      );
}
