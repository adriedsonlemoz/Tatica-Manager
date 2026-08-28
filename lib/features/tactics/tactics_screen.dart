import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/widgets/common.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/tactic/tactic.dart';

class TacticsScreen extends ConsumerWidget {
  const TacticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tactic = ref.watch(gameControllerProvider).career!.tactic;
    return PremiumScaffold(
      appBar: const GameTopBar(title: 'Táticas', subtitle: 'Cada escolha altera o Match Engine'),
      body: ListView(padding: const EdgeInsets.all(14), children: [
        _Option<Mentality>(label: 'Mentalidade', icon: Icons.psychology_alt_outlined, value: tactic.mentality, values: Mentality.values, text: (v) => v.label, onChanged: (v) => ref.read(gameControllerProvider.notifier).setTactic(tactic.copyWith(mentality: v))),
        _Option<Pressing>(label: 'Pressão', icon: Icons.compress_rounded, value: tactic.pressing, values: Pressing.values, text: (v) => v.label, onChanged: (v) => ref.read(gameControllerProvider.notifier).setTactic(tactic.copyWith(pressing: v))),
        _Option<MatchTempo>(label: 'Ritmo', icon: Icons.speed_rounded, value: tactic.tempo, values: MatchTempo.values, text: (v) => v.label, onChanged: (v) => ref.read(gameControllerProvider.notifier).setTactic(tactic.copyWith(tempo: v))),
        _Option<DefensiveLine>(label: 'Linha defensiva', icon: Icons.horizontal_rule_rounded, value: tactic.defensiveLine, values: DefensiveLine.values, text: (v) => v.label, onChanged: (v) => ref.read(gameControllerProvider.notifier).setTactic(tactic.copyWith(defensiveLine: v))),
        _Option<BuildUp>(label: 'Construção', icon: Icons.route_rounded, value: tactic.buildUp, values: BuildUp.values, text: (v) => v.label, onChanged: (v) => ref.read(gameControllerProvider.notifier).setTactic(tactic.copyWith(buildUp: v))),
        const SizedBox(height: 4),
        SectionCard(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.green),
          const SizedBox(width: 10),
          Expanded(child: Text('Mentalidade muda risco ofensivo/defensivo; pressão interfere no meio-campo; ritmo altera volume de eventos; linha defensiva redistribui força; construção influencia posse e verticalidade.', style: TextStyle(color: AppColors.muted, height: 1.45))),
        ])),
      ]),
    );
  }
}

class _Option<T> extends StatelessWidget {
  const _Option({required this.label, required this.icon, required this.value, required this.values, required this.text, required this.onChanged});
  final String label;
  final IconData icon;
  final T value;
  final List<T> values;
  final String Function(T) text;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: SectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(icon, color: AppColors.green), const SizedBox(width: 9), Text(label.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900))]),
          const SizedBox(height: 12),
          Wrap(spacing: 7, runSpacing: 7, children: values.map((item) => ChoiceChip(label: Text(text(item)), selected: item == value, onSelected: (_) => onChanged(item))).toList()),
        ])),
      );
}
