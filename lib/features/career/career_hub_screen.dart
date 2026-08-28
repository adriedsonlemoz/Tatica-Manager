import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/career_controller.dart';
import '../../app/widgets/common.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/career/career_save_summary.dart';
import 'club_editor_screen.dart';
import 'new_career_flow_screen.dart';

class CareerHubScreen extends ConsumerWidget {
  const CareerHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(careerControllerProvider);
    final last = state.lastActiveSave;

    return PremiumScaffold(
      safeBottom: true,
      body: RefreshIndicator(
        onRefresh: () => ref.read(careerControllerProvider.notifier).refresh(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
          children: [
            Row(
              children: [
                Image.asset('assets/brand/tatica-manager-icon.png', width: 64, height: 64),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TÁTICA MANAGER',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      Text('Suas carreiras', style: TextStyle(color: AppColors.muted)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            if (state.message != null) ...[
              _MessageBanner(message: state.message!),
              const SizedBox(height: 12),
            ],
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.edit_note_rounded, color: AppColors.green, size: 30),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Editor do banco',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Edite clubes, estádios, uniformes, ícones e jogadores ou importe um banco da comunidade.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: state.loading ? null : () => _openClubEditor(context),
                      icon: const Icon(Icons.shield_outlined),
                      label: const Text('Abrir editor'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (state.loading && state.saves.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.saves.isEmpty)
              _EmptyCareerState(onNewCareer: () => _openNewCareer(context))
            else ...[
              if (last != null) ...[
                Text(
                  'CONTINUAR',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.green,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                ),
                const SizedBox(height: 8),
                _ContinueCard(
                  save: last,
                  loading: state.loading,
                  onTap: () => ref.read(careerControllerProvider.notifier).openCareer(last.careerId),
                ),
                const SizedBox(height: 22),
              ],
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'MINHAS CARREIRAS',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                  Text('${state.saves.length}', style: TextStyle(color: AppColors.muted)),
                ],
              ),
              const SizedBox(height: 10),
              ...state.saves.map(
                (save) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _CareerCard(
                    save: save,
                    loading: state.loading,
                    onOpen: () => ref.read(careerControllerProvider.notifier).openCareer(save.careerId),
                    onEdit: () => _openClubEditor(
                      context,
                      careerId: save.careerId,
                      careerName: save.careerName,
                    ),
                    onDelete: () => _confirmDelete(context, ref, save),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: state.loading ? null : () => _openNewCareer(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Nova carreira'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Future<void> _openNewCareer(BuildContext context) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NewCareerFlowScreen()));
  }

  static Future<void> _openClubEditor(
    BuildContext context, {
    String? careerId,
    String? careerName,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ClubEditorScreen(
          careerId: careerId,
          careerName: careerName,
        ),
      ),
    );
  }

  static Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    CareerSaveSummary save,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apagar carreira?'),
        content: Text('“${save.careerName}” será removida deste aparelho. Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(careerControllerProvider.notifier).deleteCareer(save.careerId);
    }
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.save, required this.loading, required this.onTap});

  final CareerSaveSummary save;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(22),
        child: SectionCard(
          borderColor: AppColors.green.withValues(alpha: .65),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.play_arrow_rounded, color: AppColors.green, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(save.careerName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
                    const SizedBox(height: 3),
                    Text('${save.userClubName} • ${save.managerName}', style: TextStyle(color: AppColors.muted)),
                    const SizedBox(height: 3),
                    Text(
                      save.seasonComplete
                          ? 'Temporada ${save.season} concluída'
                          : 'Temporada ${save.season} • Rodada ${save.currentRound}',
                      style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      );
}

class _CareerCard extends StatelessWidget {
  const _CareerCard({
    required this.save,
    required this.loading,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final CareerSaveSummary save;
  final bool loading;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => SectionCard(
        padding: EdgeInsets.zero,
        child: ListTile(
          enabled: !loading,
          contentPadding: const EdgeInsets.fromLTRB(14, 8, 6, 8),
          onTap: onOpen,
          leading: Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.shield_outlined, color: AppColors.green),
          ),
          title: Text(save.careerName, style: const TextStyle(fontWeight: FontWeight.w900)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${save.userClubName} • ${save.managerName}\nTemporada ${save.season} • Rodada ${save.currentRound} • ${_date(save.updatedAt)}',
            ),
          ),
          isThreeLine: true,
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit-clubs') onEdit();
              if (value == 'delete') onDelete();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit-clubs', child: Text('Editar banco da carreira')),
              PopupMenuItem(value: 'delete', child: Text('Apagar carreira')),
            ],
          ),
        ),
      );
}

class _EmptyCareerState extends StatelessWidget {
  const _EmptyCareerState({required this.onNewCareer});

  final VoidCallback onNewCareer;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          const SizedBox(height: 28),
          SectionCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  const Icon(Icons.sports_soccer_rounded, color: AppColors.green, size: 54),
                  const SizedBox(height: 14),
                  Text(
                    'Sua história começa aqui',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crie seu técnico, escolha um dos 20 clubes e defina a identidade tática inicial.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted, height: 1.45),
                  ),
                  const SizedBox(height: 20),
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

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.danger.withValues(alpha: .35)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.danger),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      );
}

String _date(DateTime date) {
  String two(int value) => value.toString().padLeft(2, '0');
  return '${two(date.day)}/${two(date.month)}/${date.year}';
}
