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
                            child: _TacticsPitch(
                              assignments: assignments,
                              accent: AppColors.readableAccent(
                                Color(career.userClub.colors.primaryHex),
                              ),
                              onPlayerTap: (player) => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PlayerProfileScreen(
                                    playerId: player.id,
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

class _TacticsPitch extends StatelessWidget {
  const _TacticsPitch({
    required this.assignments,
    required this.accent,
    required this.onPlayerTap,
  });

  final List<AssignedPlayer> assignments;
  final Color accent;
  final ValueChanged<Player> onPlayerTap;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.pitch,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.green.withValues(alpha: .45)),
          boxShadow: const [
            BoxShadow(color: Color(0x33000000), blurRadius: 12),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const markerWidth = 67.0;
            const markerHeight = 43.0;
            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                const Positioned.fill(child: CustomPaint(painter: _PitchPainter())),
                for (final assignment in assignments)
                  Positioned(
                    left: (assignment.slot.x * constraints.maxWidth - markerWidth / 2)
                        .clamp(2.0, constraints.maxWidth - markerWidth - 2)
                        .toDouble(),
                    top: (assignment.slot.y * constraints.maxHeight - markerHeight / 2)
                        .clamp(2.0, constraints.maxHeight - markerHeight - 2)
                        .toDouble(),
                    child: _PitchPlayer(
                      assignment: assignment,
                      accent: accent,
                      onTap: () => onPlayerTap(assignment.player),
                    ),
                  ),
              ],
            );
          },
        ),
      );
}

class _PitchPlayer extends StatelessWidget {
  const _PitchPlayer({
    required this.assignment,
    required this.accent,
    required this.onTap,
  });

  final AssignedPlayer assignment;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 67,
          height: 43,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                top: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.greenDark,
                    shape: BoxShape.circle,
                    border: Border.all(color: accent, width: 1.2),
                  ),
                  child: Text(
                    '${assignment.player.shirtNumber}',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 24,
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xE8112029),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        assignment.player.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 7.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${assignment.slot.role.label} • ${assignment.effectiveOverall}',
                        style: TextStyle(
                          color: assignment.outOfPosition
                              ? AppColors.warning
                              : AppColors.green,
                          fontSize: 6.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _PitchPainter extends CustomPainter {
  const _PitchPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stripe = Paint()..color = const Color(0x102EDB4A);
    for (var index = 0; index < 8; index += 2) {
      canvas.drawRect(
        Rect.fromLTWH(0, size.height * index / 8, size.width, size.height / 8),
        stripe,
      );
    }
    final line = Paint()
      ..color = Colors.white.withValues(alpha: .28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final field = Rect.fromLTWH(12, 10, size.width - 24, size.height - 20);
    canvas.drawRect(field, line);
    canvas.drawLine(
      Offset(12, size.height / 2),
      Offset(size.width - 12, size.height / 2),
      line,
    );
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 30, line);
    final boxWidth = size.width * .48;
    final boxHeight = size.height * .15;
    canvas.drawRect(
      Rect.fromLTWH((size.width - boxWidth) / 2, 10, boxWidth, boxHeight),
      line,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - boxWidth) / 2,
        size.height - 10 - boxHeight,
        boxWidth,
        boxHeight,
      ),
      line,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
