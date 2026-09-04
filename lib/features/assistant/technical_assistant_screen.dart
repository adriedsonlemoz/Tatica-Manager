import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/widgets/common.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/training/training_plan.dart';
import '../../game/assistant/technical_assistant_engine.dart';
import '../player/player_profile_screen.dart';

class TechnicalAssistantScreen extends ConsumerWidget {
  const TechnicalAssistantScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final career = ref.watch(gameControllerProvider).career!;
    final report = TechnicalAssistantEngine.analyze(career);
    final accent = AppColors.readableAccent(
      Color(career.userClub.colors.primaryHex),
    );
    return PremiumScaffold(
      appBar: const GameTopBar(
        title: 'Auxiliar técnico',
        subtitle: 'IA local • treino, escalação e tática',
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: constraints.maxWidth - 24,
              height: 690,
              child: Column(
                children: [
                  _AssistantHero(
                    clubName: career.userClub.name,
                    opponentName: report.opponentName,
                    readiness: report.readiness,
                    summary: report.summary,
                    accent: accent,
                  ),
                  const SizedBox(height: 8),
                  _ReadinessStrip(report: report),
                  const SizedBox(height: 8),
                  _TrainingRecommendation(
                    recommendedPlan: report.recommendedTraining,
                    activePlan: career.trainingPlan,
                    reason: report.trainingReason,
                    automatic: career.trainingPlan.managedByAssistant,
                    onAutomationChanged: (enabled) => ref
                        .read(gameControllerProvider.notifier)
                        .setAssistantTrainingAutomation(enabled),
                  ),
                  const SizedBox(height: 8),
                  _MatchRecommendation(report: report),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _PrioritiesCard(
                      priorities: report.priorities,
                      onPriorityTap: (priority) {
                        final playerId = priority.playerId;
                        if (playerId == null) return;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PlayerProfileScreen(
                              playerId: playerId,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showManualTrainingPlan(
                            context,
                            ref,
                            career.trainingPlan,
                          ),
                          icon: const Icon(Icons.tune_rounded),
                          label: const Text('Plano manual'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          onPressed: () => ref
                              .read(gameControllerProvider.notifier)
                              .applyAssistantRecommendations(),
                          icon: const Icon(Icons.auto_awesome_rounded),
                          label: const Text('Aplicar recomendações'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showManualTrainingPlan(
    BuildContext context,
    WidgetRef ref,
    TrainingPlan current,
  ) async {
    var focus = current.focus;
    var intensity = current.intensity;
    final plan = await showModalBottomSheet<TrainingPlan>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: AppColors.background,
      barrierColor: Colors.black.withValues(alpha: .72),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PLANO MANUAL DE TREINO',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 5),
              const Text(
                'Ao salvar, a gestão automática será desativada.',
                style: TextStyle(color: AppColors.muted, fontSize: 11),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final value in TrainingFocus.values)
                    ChoiceChip(
                      selected: value == focus,
                      label: Text(value.label),
                      onSelected: (_) =>
                          setSheetState(() => focus = value),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'INTENSIDADE',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              SegmentedButton<TrainingIntensity>(
                segments: [
                  for (final value in TrainingIntensity.values)
                    ButtonSegment(
                      value: value,
                      label: Text(value.label),
                    ),
                ],
                selected: {intensity},
                onSelectionChanged: (selection) => setSheetState(
                  () => intensity = selection.first,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(sheetContext).pop(
                    TrainingPlan(
                      focus: focus,
                      intensity: intensity,
                      managedByAssistant: false,
                    ),
                  ),
                  child: const Text('Salvar plano manual'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (plan != null) {
      await ref.read(gameControllerProvider.notifier).setTrainingPlan(plan);
    }
  }
}

class _AssistantHero extends StatelessWidget {
  const _AssistantHero({
    required this.clubName,
    required this.opponentName,
    required this.readiness,
    required this.summary,
    required this.accent,
  });

  final String clubName;
  final String? opponentName;
  final int readiness;
  final String summary;
  final Color accent;

  @override
  Widget build(BuildContext context) => SectionCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: .13),
                shape: BoxShape.circle,
                border: Border.all(color: accent.withValues(alpha: .50)),
              ),
              child: Icon(Icons.psychology_alt_rounded, color: accent, size: 30),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    opponentName == null
                        ? 'ANÁLISE DO $clubName'
                        : 'PREPARAÇÃO PARA $opponentName',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    summary,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _ReadinessRing(value: readiness),
          ],
        ),
      );
}

class _ReadinessRing extends StatelessWidget {
  const _ReadinessRing({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    final color = value >= 82
        ? AppColors.green
        : value >= 68
            ? AppColors.warning
            : AppColors.danger;
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: value / 100,
            strokeWidth: 5,
            backgroundColor: AppColors.border,
            color: color,
          ),
          Center(
            child: Text(
              '$value',
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadinessStrip extends StatelessWidget {
  const _ReadinessStrip({required this.report});

  final TechnicalAssistantReport report;

  @override
  Widget build(BuildContext context) => SectionCard(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
        child: Row(
          children: [
            _MetricItem(
              icon: Icons.favorite_rounded,
              label: 'Condição',
              value: '${report.averageCondition}%',
              color: AppColors.green,
            ),
            _MetricItem(
              icon: Icons.battery_alert_rounded,
              label: 'Fadiga',
              value: '${report.averageFatigue}%',
              color: report.averageFatigue >= 45
                  ? AppColors.danger
                  : AppColors.info,
            ),
            _MetricItem(
              icon: Icons.person_off_rounded,
              label: 'Desfalques',
              value: '${report.unavailableCount}',
              color: report.unavailableCount > 0
                  ? AppColors.warning
                  : AppColors.green,
            ),
            _MetricItem(
              icon: Icons.style_rounded,
              label: 'Pendurados',
              value: '${report.atRiskCount}',
              color: report.atRiskCount > 0
                  ? AppColors.warning
                  : AppColors.green,
            ),
          ],
        ),
      );
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Icon(icon, size: 17, color: color),
            const SizedBox(height: 3),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.muted, fontSize: 8),
            ),
          ],
        ),
      );
}

class _TrainingRecommendation extends StatelessWidget {
  const _TrainingRecommendation({
    required this.recommendedPlan,
    required this.activePlan,
    required this.reason,
    required this.automatic,
    required this.onAutomationChanged,
  });

  final TrainingPlan recommendedPlan;
  final TrainingPlan activePlan;
  final String reason;
  final bool automatic;
  final ValueChanged<bool> onAutomationChanged;

  @override
  Widget build(BuildContext context) {
    final displayedPlan = automatic ? recommendedPlan : activePlan;
    final displayedReason = automatic
        ? reason
        : 'Plano manual ativo. A IA recomenda ${recommendedPlan.focus.label.toLowerCase()}.';
    return SectionCard(
        padding: const EdgeInsets.fromLTRB(12, 9, 8, 9),
        child: Row(
          children: [
            _IconBox(
              icon: _trainingIcon(displayedPlan.focus),
              color: AppColors.green,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    automatic ? 'TREINO RECOMENDADO' : 'TREINO ATUAL • MANUAL',
                    style: const TextStyle(
                      color: AppColors.green,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${displayedPlan.focus.label} • ${displayedPlan.intensity.label}',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  Text(
                    displayedReason,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.muted, fontSize: 9),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Switch(
                  value: automatic,
                  onChanged: onAutomationChanged,
                ),
                Text(
                  automatic ? 'AUTO' : 'MANUAL',
                  style: TextStyle(
                    color: automatic ? AppColors.green : AppColors.muted,
                    fontSize: 7.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
  }
}

class _MatchRecommendation extends StatelessWidget {
  const _MatchRecommendation({required this.report});

  final TechnicalAssistantReport report;

  @override
  Widget build(BuildContext context) => SectionCard(
        padding: const EdgeInsets.all(11),
        child: Row(
          children: [
            const _IconBox(
              icon: Icons.tune_rounded,
              color: AppColors.info,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PLANO PARA A PRÓXIMA PARTIDA',
                    style: TextStyle(
                      color: AppColors.info,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${report.recommendedFormation.label} • ${report.recommendedTactic.mentality.label}',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  Text(
                    '${report.recommendedTactic.pressing.label} pressão • ritmo ${report.recommendedTactic.tempo.label.toLowerCase()} • ${report.lineupChanges} troca${report.lineupChanges == 1 ? '' : 's'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.muted, fontSize: 9),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
          ],
        ),
      );
}

class _PrioritiesCard extends StatelessWidget {
  const _PrioritiesCard({
    required this.priorities,
    required this.onPriorityTap,
  });

  final List<AssistantPriority> priorities;
  final ValueChanged<AssistantPriority> onPriorityTap;

  @override
  Widget build(BuildContext context) => SectionCard(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PRIORIDADES DA COMISSÃO',
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: Column(
                children: [
                  for (final priority in priorities)
                    Expanded(
                      child: InkWell(
                        onTap: priority.playerId == null
                            ? null
                            : () => onPriorityTap(priority),
                        borderRadius: BorderRadius.circular(8),
                        child: Row(
                          children: [
                            Container(
                              width: 5,
                              height: 25,
                              decoration: BoxDecoration(
                                color: _priorityColor(priority.level),
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    priority.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    priority.message,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.muted,
                                      fontSize: 8.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (priority.playerId != null)
                              const Icon(
                                Icons.chevron_right_rounded,
                                size: 16,
                                color: AppColors.muted,
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: 39,
        height: 39,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: .11),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, color: color, size: 21),
      );
}

IconData _trainingIcon(TrainingFocus focus) => switch (focus) {
      TrainingFocus.recovery => Icons.bedtime_rounded,
      TrainingFocus.balanced => Icons.balance_rounded,
      TrainingFocus.tactical => Icons.account_tree_rounded,
      TrainingFocus.physical => Icons.fitness_center_rounded,
      TrainingFocus.technical => Icons.sports_soccer_rounded,
    };

Color _priorityColor(AssistantPriorityLevel level) => switch (level) {
      AssistantPriorityLevel.information => AppColors.info,
      AssistantPriorityLevel.attention => AppColors.warning,
      AssistantPriorityLevel.critical => AppColors.danger,
    };
