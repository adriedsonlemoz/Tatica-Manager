import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/widgets/common.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/formation/formation.dart';
import '../../domain/player/player.dart';
import '../../game/lineup/lineup_engine.dart';
import '../player/player_profile_screen.dart';
import '../tactics/tactics_screen.dart';
import 'widgets/lineup_candidate_sheet.dart';
import 'widgets/lineup_pitch.dart';

class LineupScreen extends ConsumerWidget {
  const LineupScreen({super.key, this.showBackButton = false});

  final bool showBackButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final career = ref.watch(gameControllerProvider).career!;
    final validation = LineupEngine.validate(
      career.userClub.squad,
      career.starterIds,
      career.formation,
    );
    final assignments = validation.assignments;
    final reserves = career.userClub.squad
        .where((player) => !career.starterIds.contains(player.id))
        .toList();
    final availableBench = reserves.where((player) => player.isAvailable).toList()
      ..sort((a, b) => b.overall.compareTo(a.overall));
    final unavailable = reserves.where((player) => !player.isAvailable).toList()
      ..sort((a, b) => b.overall.compareTo(a.overall));
    final accent = Color(career.userClub.colors.primaryHex);
    final improvised = assignments.where((assignment) => assignment.outOfPosition).length;

    return PremiumScaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
              child: Row(
                children: [
                  if (showBackButton) ...[
                    IconButton.filledTonal(
                      tooltip: 'Voltar para o pré-jogo',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ESCALAÇÃO',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        Text(
                          'Força ${validation.averageStrength} • ${validation.isValid ? 'Pronta para jogar' : validation.message}',
                          style: TextStyle(
                            color: validation.isValid ? AppColors.green : AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'Tática',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TacticsScreen()),
                    ),
                    icon: const Icon(Icons.tune_rounded),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 110),
            sliver: SliverList.list(
              children: [
                SectionCard(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<FormationType>(
                              initialValue: career.formation,
                              decoration: const InputDecoration(labelText: 'Formação'),
                              items: FormationType.values
                                  .map(
                                    (formation) => DropdownMenuItem(
                                      value: formation,
                                      child: Text(formation.label),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  ref.read(gameControllerProvider.notifier).setFormation(value);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton.tonalIcon(
                            onPressed: () => ref
                                .read(gameControllerProvider.notifier)
                                .autoSelectLineup(),
                            icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                            label: const Text('Autoescalação', style: TextStyle(fontSize: 10)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      Row(
                        children: [
                          _SummaryPill(
                            icon: Icons.groups_2_rounded,
                            label: '${assignments.length}/11',
                          ),
                          const SizedBox(width: 6),
                          _SummaryPill(
                            icon: Icons.swap_horiz_rounded,
                            label: improvised == 0
                                ? 'Posições naturais'
                                : '$improvised improvisado${improvised == 1 ? '' : 's'}',
                            warning: improvised > 0,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                LineupPitch(
                  assignments: assignments,
                  formationLabel: career.formation.label,
                  accentColor: accent,
                  onPlayerTap: (assignment) => _chooseReplacement(
                    context,
                    ref,
                    career.userClub.squad,
                    career.starterIds,
                    assignment,
                    accent,
                  ),
                  onPlayerLongPress: (assignment) => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PlayerProfileScreen(playerId: assignment.player.id),
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    'Toque para trocar • segure para abrir o perfil. O número no campo é o OVR efetivo naquela posição.',
                    style: TextStyle(color: AppColors.muted, fontSize: 9.5),
                  ),
                ),
                const SizedBox(height: 12),
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'BANCO E ELENCO',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          Text(
                            '${availableBench.length} disponíveis',
                            style: const TextStyle(color: AppColors.muted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ..._benchGroups(availableBench).expand(
                        (group) => [
                          _GroupHeading(label: group.$1, count: group.$2.length),
                          ...group.$2.map(
                            (player) => _PlayerBenchRow(
                              player: player,
                              accent: accent,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PlayerProfileScreen(playerId: player.id),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 7),
                        ],
                      ),
                      if (unavailable.isNotEmpty) ...[
                        const Divider(height: 18),
                        Row(
                          children: [
                            const Icon(Icons.block_rounded, color: AppColors.warning, size: 18),
                            const SizedBox(width: 7),
                            Text(
                              'INELEGÍVEIS / INDISPONÍVEIS',
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: AppColors.warning,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const Spacer(),
                            Text(
                              '${unavailable.length}',
                              style: const TextStyle(color: AppColors.muted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        ...unavailable.map(
                          (player) => _PlayerBenchRow(
                            player: player,
                            accent: accent,
                            unavailable: true,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PlayerProfileScreen(playerId: player.id),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> _chooseReplacement(
    BuildContext context,
    WidgetRef ref,
    List<Player> squad,
    List<String> starters,
    AssignedPlayer outgoing,
    Color accent,
  ) async {
    final candidates = LineupEngine.candidatesForRole(
      squad,
      outgoing.slot.role,
      excludedIds: starters.toSet(),
    );
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => LineupCandidateSheet(
        outgoing: outgoing.player,
        role: outgoing.slot.role,
        candidates: candidates,
        accentColor: accent,
        onSelected: (incoming) async {
          await ref
              .read(gameControllerProvider.notifier)
              .replaceStarter(outgoing.player.id, incoming.id);
          if (sheetContext.mounted) Navigator.of(sheetContext).pop();
        },
      ),
    );
  }
}

List<(String, List<Player>)> _benchGroups(List<Player> players) {
  const groups = <String, Set<PlayerPosition>>{
    'GOLEIROS': {PlayerPosition.gol},
    'DEFENSORES': {PlayerPosition.zag, PlayerPosition.ld, PlayerPosition.le},
    'MEIO-CAMPISTAS': {PlayerPosition.vol, PlayerPosition.mc, PlayerPosition.mei},
    'ATACANTES': {PlayerPosition.pe, PlayerPosition.pd, PlayerPosition.sa, PlayerPosition.ca},
  };
  return [
    for (final entry in groups.entries)
      if (players.any((player) => entry.value.contains(player.primaryPosition)))
        (
          entry.key,
          players.where((player) => entry.value.contains(player.primaryPosition)).toList(),
        ),
  ];
}

class _GroupHeading extends StatelessWidget {
  const _GroupHeading({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(2, 6, 2, 4),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: .6,
              ),
            ),
            const Spacer(),
            Text('$count', style: const TextStyle(color: AppColors.muted, fontSize: 10)),
          ],
        ),
      );
}

class _PlayerBenchRow extends StatelessWidget {
  const _PlayerBenchRow({
    required this.player,
    required this.accent,
    required this.onTap,
    this.unavailable = false,
  });

  final Player player;
  final Color accent;
  final VoidCallback onTap;
  final bool unavailable;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: PlayerRow(
          player: player,
          showAvatar: true,
          showCondition: true,
          avatarAccentColor: accent,
          onTap: onTap,
          trailing: unavailable
              ? Tooltip(
                  message: _unavailableReason(player),
                  child: const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                )
              : const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
        ),
      );
}

String _unavailableReason(Player player) => switch (player.availabilityStatus) {
      PlayerAvailabilityStatus.injured => player.injury?.name ?? 'Lesionado',
      PlayerAvailabilityStatus.suspended =>
        'Suspenso por ${player.discipline.suspendedRounds} rodada(s)',
      PlayerAvailabilityStatus.lowCondition => 'Condição física abaixo de 35%',
      PlayerAvailabilityStatus.available => 'Disponível',
    };

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.icon,
    required this.label,
    this.warning = false,
  });

  final IconData icon;
  final String label;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final color = warning ? AppColors.warning : AppColors.green;
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: .24)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
