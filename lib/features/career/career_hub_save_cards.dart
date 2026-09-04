import 'package:flutter/material.dart';

import '../../app/widgets/common.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/career/career_save_summary.dart';

class CareerSaveCard extends StatelessWidget {
  const CareerSaveCard({
    super.key,
    required this.save,
    required this.loading,
    required this.onOpen,
    required this.onDelete,
  });

  final CareerSaveSummary save;
  final bool loading;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final nextMatch = save.nextOpponentName == null
        ? (save.seasonComplete ? 'Temporada concluída' : 'Próximo jogo indisponível')
        : '${save.nextMatchAtHome == true ? 'Casa' : 'Fora'} • ${save.nextOpponentName} • ${_shortDate(save.nextMatchDate)}';
    final position = save.leaguePosition == null
        ? 'Classificação indisponível'
        : '${save.leaguePosition}º lugar';

    return SectionCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: loading ? null : onOpen,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
          child: Row(
            children: [
              if (save.userClub != null)
                ClubBadge(club: save.userClub!, size: 56)
              else
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.shield_outlined, color: AppColors.green),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      save.careerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${save.userClubName} • ${save.managerName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.muted, fontSize: 12.5),
                    ),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 10,
                      runSpacing: 5,
                      children: [
                        _CareerMeta(icon: Icons.leaderboard_rounded, text: position),
                        _CareerMeta(
                          icon: Icons.calendar_month_rounded,
                          text: 'T${save.season} • R${save.currentRound}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    _CareerMeta(icon: Icons.sports_soccer_rounded, text: nextMatch),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              SizedBox.square(
                dimension: 44,
                child: IconButton(
                  tooltip: 'Excluir carreira',
                  onPressed: loading ? null : onDelete,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.danger.withValues(alpha: .10),
                    foregroundColor: AppColors.danger,
                  ),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyCareerState extends StatelessWidget {
  const EmptyCareerState({super.key, required this.onNewCareer});

  final VoidCallback onNewCareer;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          const SizedBox(height: 20),
          SectionCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  const Icon(Icons.sports_soccer_rounded, color: AppColors.green, size: 50),
                  const SizedBox(height: 12),
                  Text(
                    'Sua história começa aqui',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'Crie seu técnico, escolha um dos 20 clubes e defina a identidade tática inicial.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.muted, height: 1.4),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: onNewCareer,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Criar primeira carreira'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
}

class CareerDeleteDialog extends StatelessWidget {
  const CareerDeleteDialog({super.key, required this.save});

  final CareerSaveSummary save;

  @override
  Widget build(BuildContext context) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        icon: Container(
          width: 58,
          height: 58,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.danger.withValues(alpha: .12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.delete_forever_outlined, color: AppColors.danger, size: 30),
        ),
        title: const Text('Excluir esta carreira?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              save.careerName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
            ),
            const SizedBox(height: 5),
            Text(
              '${save.userClubName} • ${save.managerName}\nTemporada ${save.season} • Rodada ${save.currentRound}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, height: 1.4),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.danger.withValues(alpha: .22)),
              ),
              child: const Text(
                'O save será removido definitivamente deste aparelho. O saldo global de PM será preservado. Esta ação não pode ser desfeita.',
                textAlign: TextAlign.center,
                style: TextStyle(height: 1.35),
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Manter carreira'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Excluir'),
          ),
        ],
      );
}

class _CareerMeta extends StatelessWidget {
  const _CareerMeta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.green),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 170),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      );
}

String _shortDate(DateTime? date) {
  if (date == null) return '--/--';
  String two(int value) => value.toString().padLeft(2, '0');
  return '${two(date.day)}/${two(date.month)}';
}
