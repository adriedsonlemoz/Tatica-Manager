import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/tactic/tactic.dart';

class LiveTacticSheet extends StatefulWidget {
  const LiveTacticSheet({
    super.key,
    required this.current,
    required this.onApply,
  });

  final Tactic current;
  final ValueChanged<Tactic> onApply;

  @override
  State<LiveTacticSheet> createState() => _LiveTacticSheetState();
}

class _LiveTacticSheetState extends State<LiveTacticSheet> {
  late Tactic local;

  @override
  void initState() {
    super.initState();
    local = widget.current;
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ajustes ao vivo',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              const Text(
                'As mudanças recalculam somente o restante da partida; os acontecimentos anteriores permanecem preservados.',
                style: TextStyle(color: AppColors.muted, fontSize: 10.5, height: 1.35),
              ),
              const SizedBox(height: 12),
              _CompactTacticChoice<Mentality>(
                title: 'Mentalidade',
                icon: Icons.track_changes_rounded,
                values: Mentality.values,
                selected: local.mentality,
                label: (value) => value.label,
                helper: (value) => switch (value) {
                  Mentality.defensive => 'Fecha espaços e reduz riscos.',
                  Mentality.balanced => 'Mantém equilíbrio entre os setores.',
                  Mentality.attacking => 'Força o ataque e aceita mais riscos.',
                },
                onSelected: (value) => setState(
                  () => local = local.copyWith(mentality: value),
                ),
              ),
              _CompactTacticChoice<Pressing>(
                title: 'Pressão',
                icon: Icons.flash_on_rounded,
                values: Pressing.values,
                selected: local.pressing,
                label: (value) => value.label,
                helper: (value) => switch (value) {
                  Pressing.low => 'Bloco mais baixo e menor desgaste.',
                  Pressing.medium => 'Pressão equilibrada no campo.',
                  Pressing.high => 'Marcação agressiva e adiantada.',
                },
                onSelected: (value) => setState(
                  () => local = local.copyWith(pressing: value),
                ),
              ),
              _CompactTacticChoice<MatchTempo>(
                title: 'Ritmo',
                icon: Icons.speed_rounded,
                values: MatchTempo.values,
                selected: local.tempo,
                label: (value) => value.label,
                helper: (value) => switch (value) {
                  MatchTempo.slow => 'Cadencia a posse e controla o jogo.',
                  MatchTempo.normal => 'Mantém o ritmo natural da equipe.',
                  MatchTempo.fast => 'Acelera transições e verticalidade.',
                },
                onSelected: (value) => setState(
                  () => local = local.copyWith(tempo: value),
                ),
              ),
              _CompactTacticChoice<DefensiveLine>(
                title: 'Linha defensiva',
                icon: Icons.view_stream_rounded,
                values: DefensiveLine.values,
                selected: local.defensiveLine,
                label: (value) => value.label,
                helper: (value) => switch (value) {
                  DefensiveLine.low => 'Protege a área e atrai o adversário.',
                  DefensiveLine.medium => 'Mantém altura intermediária.',
                  DefensiveLine.high => 'Adianta e compacta o campo.',
                },
                onSelected: (value) => setState(
                  () => local = local.copyWith(defensiveLine: value),
                ),
              ),
              _CompactTacticChoice<BuildUp>(
                title: 'Construção',
                icon: Icons.alt_route_rounded,
                values: BuildUp.values,
                selected: local.buildUp,
                label: (value) => value.label,
                helper: (value) => switch (value) {
                  BuildUp.short => 'Prioriza posse, apoio e triangulações.',
                  BuildUp.balanced => 'Alterna saída curta e direta.',
                  BuildUp.direct => 'Procura o ataque com menos passes.',
                },
                onSelected: (value) => setState(
                  () => local = local.copyWith(buildUp: value),
                ),
              ),
              const SizedBox(height: 2),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    widget.onApply(local);
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.tune_rounded),
                  label: const Text('Aplicar agora'),
                ),
              ),
            ],
          ),
        ),
      );
}

class _CompactTacticChoice<T> extends StatelessWidget {
  const _CompactTacticChoice({
    required this.title,
    required this.icon,
    required this.values,
    required this.selected,
    required this.label,
    required this.helper,
    required this.onSelected,
  });

  final String title;
  final IconData icon;
  final List<T> values;
  final T selected;
  final String Function(T value) label;
  final String Function(T value) helper;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
          decoration: BoxDecoration(
            color: AppColors.surfaceRaised,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: AppColors.green, size: 17),
                  const SizedBox(width: 7),
                  Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 10.5,
                      letterSpacing: .3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (var index = 0; index < values.length; index++) ...[
                    if (index > 0) const SizedBox(width: 5),
                    Expanded(
                      child: _TacticOption(
                        selected: selected == values[index],
                        label: label(values[index]),
                        onTap: () => onSelected(values[index]),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 12, color: AppColors.muted),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      helper(selected),
                      style: const TextStyle(color: AppColors.muted, fontSize: 9.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}

class _TacticOption extends StatelessWidget {
  const _TacticOption({
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 38,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.green.withValues(alpha: .16)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: selected
                  ? AppColors.green.withValues(alpha: .7)
                  : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (selected) ...[
                const Icon(Icons.check_rounded, size: 13, color: AppColors.green),
                const SizedBox(width: 2),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? AppColors.green : null,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
