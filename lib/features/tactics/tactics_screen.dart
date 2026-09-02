import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/widgets/common.dart';
import '../../app/widgets/player_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/formation/formation.dart';
import '../../domain/player/player.dart';
import '../../domain/tactic/tactic.dart';
import '../../game/lineup/lineup_engine.dart';
import '../player/player_profile_screen.dart';
import '../shared/club_context_header.dart';
import '../shared/compact_formation_pitch.dart';

class TacticsScreen extends ConsumerWidget {
  const TacticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final career = ref.watch(gameControllerProvider).career!;
    if (career.managerUnemployed) {
      return const PremiumScaffold(
        appBar: GameTopBar(title: 'Táticas'),
        body: Center(
          child: Text(
            'Assuma um clube para definir formação e tática.',
            style: TextStyle(color: AppColors.muted),
          ),
        ),
      );
    }

    final fixture = career.nextUserFixture;
    final suspended = fixture == null
        ? null
        : career.suspendedPlayerIdsForCompetition(fixture.competitionId);
    final validation = LineupEngine.validate(
      career.userClub.squad,
      career.starterIds,
      career.formation,
      competitionSuspendedPlayerIds: suspended,
    );
    final assignments = validation.assignments;
    final reserves = career.userClub.squad
        .where((player) => !career.starterIds.contains(player.id))
        .where(
          (player) => fixture == null
              ? player.isAvailable
              : career.isPlayerAvailableForCompetition(
                  player,
                  fixture.competitionId,
                ),
        )
        .toList()
      ..sort((a, b) => b.overall.compareTo(a.overall));
    final tactic = career.tactic;

    return PremiumScaffold(
      appBar: const GameTopBar(title: 'Táticas'),
      body: LayoutBuilder(
        builder: (context, constraints) => Padding(
          padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: constraints.maxWidth - 20,
              height: 710,
              child: Column(
                children: [
                  ClubContextHeader(
                    club: career.userClub,
                    season: career.season,
                  ),
                  const SizedBox(height: 8),
                  const _FormationHeading(),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SectionCard(
                      padding: const EdgeInsets.fromLTRB(9, 8, 9, 9),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'FORMAÇÃO ATUAL',
                                      style: TextStyle(
                                        color: AppColors.muted,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      career.formation.label,
                                      style: const TextStyle(
                                        color: AppColors.green,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _PitchActionButton(
                                icon: Icons.auto_awesome_rounded,
                                label: 'Padrões',
                                onTap: () => ref
                                    .read(gameControllerProvider.notifier)
                                    .autoSelectLineup(),
                              ),
                              const SizedBox(width: 7),
                              _PitchActionButton(
                                icon: Icons.edit_outlined,
                                label: 'Editar',
                                onTap: () => _showFormationPicker(
                                  context,
                                  ref,
                                  career.formation,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: CompactFormationPitch(
                              assignments: assignments,
                              accent: AppColors.readableAccent(
                                Color(career.userClub.colors.primaryHex),
                              ),
                              onPlayerTap: (assignment) => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PlayerProfileScreen(
                                    playerId: assignment.player.id,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _TeamStyleBoard(
                    tactic: tactic,
                    onMentality: () => _showChoiceSheet<Mentality>(
                      context,
                      title: 'Mentalidade',
                      values: Mentality.values,
                      selected: tactic.mentality,
                      label: (value) => value.label,
                      onSelected: (value) => ref
                          .read(gameControllerProvider.notifier)
                          .setTactic(tactic.copyWith(mentality: value)),
                    ),
                    onPressing: () => _showChoiceSheet<Pressing>(
                      context,
                      title: 'Pressão',
                      values: Pressing.values,
                      selected: tactic.pressing,
                      label: (value) => value.label,
                      onSelected: (value) => ref
                          .read(gameControllerProvider.notifier)
                          .setTactic(tactic.copyWith(pressing: value)),
                    ),
                    onDefensiveLine: () => _showChoiceSheet<DefensiveLine>(
                      context,
                      title: 'Linha defensiva',
                      values: DefensiveLine.values,
                      selected: tactic.defensiveLine,
                      label: (value) => value.label,
                      onSelected: (value) => ref
                          .read(gameControllerProvider.notifier)
                          .setTactic(tactic.copyWith(defensiveLine: value)),
                    ),
                    onTempo: () => _showChoiceSheet<MatchTempo>(
                      context,
                      title: 'Ritmo',
                      values: MatchTempo.values,
                      selected: tactic.tempo,
                      label: (value) => value.label,
                      onSelected: (value) => ref
                          .read(gameControllerProvider.notifier)
                          .setTactic(tactic.copyWith(tempo: value)),
                    ),
                    onBuildUp: () => _showChoiceSheet<BuildUp>(
                      context,
                      title: 'Construção',
                      values: BuildUp.values,
                      selected: tactic.buildUp,
                      label: (value) => value.label,
                      onSelected: (value) => ref
                          .read(gameControllerProvider.notifier)
                          .setTactic(tactic.copyWith(buildUp: value)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: _BenchBoard(players: reserves.take(5).toList()),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> _showFormationPicker(
    BuildContext context,
    WidgetRef ref,
    FormationType selected,
  ) async {
    final value = await showModalBottomSheet<FormationType>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ESCOLHER FORMAÇÃO',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final formation in FormationType.values)
                    ChoiceChip(
                      selected: formation == selected,
                      label: SizedBox(
                        width: 64,
                        child: Text(
                          formation.label,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      onSelected: (_) => Navigator.pop(sheetContext, formation),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (value != null) {
      await ref.read(gameControllerProvider.notifier).setFormation(value);
    }
  }

  static Future<void> _showChoiceSheet<T>(
    BuildContext context, {
    required String title,
    required List<T> values,
    required T selected,
    required String Function(T) label,
    required ValueChanged<T> onSelected,
  }) async {
    final value = await showModalBottomSheet<T>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (var index = 0; index < values.length; index++) ...[
                    if (index > 0) const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        selected: values[index] == selected,
                        label: SizedBox(
                          width: double.infinity,
                          child: Text(
                            label(values[index]),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        onSelected: (_) =>
                            Navigator.pop(sheetContext, values[index]),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (value != null) onSelected(value);
  }
}

class _FormationHeading extends StatelessWidget {
  const _FormationHeading();

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 34,
        child: Column(
          children: [
            const Expanded(
              child: Center(
                child: Text(
                  'Formação',
                  style: TextStyle(
                    color: AppColors.green,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Container(height: 2, color: AppColors.green),
                ),
                Expanded(
                  flex: 2,
                  child: Container(height: 2, color: AppColors.border),
                ),
              ],
            ),
          ],
        ),
      );
}

class _PitchActionButton extends StatelessWidget {
  const _PitchActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(92, 39),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        ),
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontSize: 11)),
      );
}

class _TeamStyleBoard extends StatelessWidget {
  const _TeamStyleBoard({
    required this.tactic,
    required this.onMentality,
    required this.onPressing,
    required this.onDefensiveLine,
    required this.onTempo,
    required this.onBuildUp,
  });

  final Tactic tactic;
  final VoidCallback onMentality;
  final VoidCallback onPressing;
  final VoidCallback onDefensiveLine;
  final VoidCallback onTempo;
  final VoidCallback onBuildUp;

  @override
  Widget build(BuildContext context) => SectionCard(
        padding: const EdgeInsets.fromLTRB(9, 7, 9, 9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ESTILO DE EQUIPE',
              style: TextStyle(
                color: AppColors.green,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _TacticChoiceCard(
                  icon: Icons.psychology_alt_outlined,
                  label: 'MENTALIDADE',
                  value: tactic.mentality.label,
                  onTap: onMentality,
                ),
                const SizedBox(width: 6),
                _TacticChoiceCard(
                  icon: Icons.radar_rounded,
                  label: 'PRESSÃO',
                  value: tactic.pressing.label,
                  onTap: onPressing,
                ),
                const SizedBox(width: 6),
                _TacticChoiceCard(
                  icon: Icons.shield_outlined,
                  label: 'LINHA DEFENSIVA',
                  value: tactic.defensiveLine.label,
                  onTap: onDefensiveLine,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _TacticChoiceCard(
                  icon: Icons.speed_rounded,
                  label: 'RITMO',
                  value: tactic.tempo.label,
                  onTap: onTempo,
                ),
                const SizedBox(width: 6),
                _TacticChoiceCard(
                  icon: Icons.route_outlined,
                  label: 'CONSTRUÇÃO',
                  value: tactic.buildUp.label,
                  onTap: onBuildUp,
                ),
              ],
            ),
          ],
        ),
      );
}

class _TacticChoiceCard extends StatelessWidget {
  const _TacticChoiceCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border.withValues(alpha: .7)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 22, color: AppColors.muted),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 6.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _BenchBoard extends StatelessWidget {
  const _BenchBoard({required this.players});

  final List<Player> players;

  @override
  Widget build(BuildContext context) => SectionCard(
        padding: const EdgeInsets.fromLTRB(9, 7, 9, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'BANCO DE RESERVAS',
                    style: TextStyle(
                      color: AppColors.green,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  '${players.length}/5',
                  style: const TextStyle(color: AppColors.muted, fontSize: 9),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Expanded(
              child: players.isEmpty
                  ? const Center(
                      child: Text(
                        'Sem reservas disponíveis',
                        style: TextStyle(color: AppColors.muted, fontSize: 10),
                      ),
                    )
                  : Row(
                      children: [
                        for (var index = 0; index < players.length; index++) ...[
                          if (index > 0) const SizedBox(width: 5),
                          Expanded(child: _BenchPlayer(player: players[index])),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      );
}

class _BenchPlayer extends StatelessWidget {
  const _BenchPlayer({required this.player});

  final Player player;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PlayerAvatar(player: player, size: 30),
            const SizedBox(height: 2),
            Text(
              player.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 7, fontWeight: FontWeight.w700),
            ),
            Text(
              player.primaryPosition.label,
              style: const TextStyle(color: AppColors.muted, fontSize: 6.5),
            ),
          ],
        ),
      );
}
