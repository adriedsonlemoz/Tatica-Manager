import 'dart:math';

import 'package:flutter/material.dart';

import '../../../app/widgets/player_avatar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/formation/formation.dart';
import '../../../domain/player/player.dart';
import '../../../game/lineup/lineup_engine.dart';
import '../../../game/match/live_substitution_rules.dart';

class LiveSubstitutionSheet extends StatefulWidget {
  const LiveSubstitutionSheet({
    super.key,
    required this.squad,
    required this.starterIds,
    required this.formation,
    required this.accentColor,
    this.excludedIncomingIds = const {},
    this.dismissedPlayerIds = const {},
    this.substitutionsUsed = 0,
    this.substitutionLimit = 5,
    this.substitutionWindowsUsed = 0,
    this.substitutionWindowLimit = 3,
    this.halftime = false,
    this.willUseNewWindow = true,
  });

  final List<Player> squad;
  final List<String> starterIds;
  final FormationType formation;
  final Color accentColor;
  final Set<String> excludedIncomingIds;
  final Set<String> dismissedPlayerIds;
  final int substitutionsUsed;
  final int substitutionLimit;
  final int substitutionWindowsUsed;
  final int substitutionWindowLimit;
  final bool halftime;
  final bool willUseNewWindow;

  @override
  State<LiveSubstitutionSheet> createState() => _LiveSubstitutionSheetState();
}

class _LiveSubstitutionSheetState extends State<LiveSubstitutionSheet> {
  String? outgoingId;
  String? incomingId;
  final List<LiveSubstitutionChange> plannedChanges = [];

  Set<String> get plannedOutgoingIds =>
      plannedChanges.map((change) => change.outgoingId).toSet();

  Set<String> get plannedIncomingIds =>
      plannedChanges.map((change) => change.incomingId).toSet();

  List<String> get provisionalStarterIds {
    var ids = [...widget.starterIds];
    for (final change in plannedChanges) {
      ids = LineupEngine.replaceStarter(
        ids,
        change.outgoingId,
        change.incomingId,
      );
    }
    return ids;
  }

  int get remainingSlots =>
      (widget.substitutionLimit - widget.substitutionsUsed - plannedChanges.length)
          .clamp(0, widget.substitutionLimit)
          .toInt();

  List<Player> get starters {
    final byId = {for (final player in widget.squad) player.id: player};
    return provisionalStarterIds
        .where((id) => !widget.dismissedPlayerIds.contains(id))
        .where((id) => !plannedIncomingIds.contains(id))
        .map((id) => byId[id])
        .whereType<Player>()
        .toList();
  }

  Player? _findPlayer(String? id) {
    if (id == null) return null;
    for (final player in widget.squad) {
      if (player.id == id) return player;
    }
    return null;
  }

  PlayerPosition? get selectedRole {
    final id = outgoingId;
    if (id == null) return null;
    return LineupEngine.slotForStarter(
      provisionalStarterIds,
      widget.formation,
      id,
    )?.role;
  }

  List<Player> get bench {
    final role = selectedRole;
    final excluded = {
      ...provisionalStarterIds,
      ...widget.excludedIncomingIds,
      ...plannedOutgoingIds,
      ...widget.dismissedPlayerIds,
    };
    if (role == null) {
      final players = widget.squad
          .where(
            (player) =>
                !excluded.contains(player.id) &&
                player.isAvailable,
          )
          .toList()
        ..sort((a, b) => b.overall.compareTo(a.overall));
      return players;
    }
    return LineupEngine.candidatesForRole(
      widget.squad,
      role,
      excludedIds: excluded,
    ).map((candidate) => candidate.player).toList();
  }

  void _prepareCurrentChange() {
    final outgoing = outgoingId;
    final incoming = incomingId;
    if (outgoing == null || incoming == null || remainingSlots <= 0) return;
    setState(() {
      plannedChanges.add(
        LiveSubstitutionChange(
          outgoingId: outgoing,
          incomingId: incoming,
        ),
      );
      outgoingId = null;
      incomingId = null;
    });
  }

  void _removePlannedChange(int index) {
    setState(() {
      plannedChanges.removeAt(index);
      outgoingId = null;
      incomingId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = min(MediaQuery.sizeOf(context).height * .90, 740.0);
    final outgoing = _findPlayer(outgoingId);
    final incoming = _findPlayer(incomingId);
    final role = selectedRole;
    final projectedSubstitutions =
        widget.substitutionsUsed + plannedChanges.length;
    final projectedWindows = widget.substitutionWindowsUsed +
        (plannedChanges.isNotEmpty &&
                !widget.halftime &&
                widget.willUseNewWindow
            ? 1
            : 0);

    return SafeArea(
      child: SizedBox(
        height: height,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 10, 7),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: widget.accentColor.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.swap_vert_rounded,
                      color: widget.accentColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Preparar substituições',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.halftime
                              ? 'Substituições: $projectedSubstitutions/${widget.substitutionLimit} • intervalo não consome janela.'
                              : 'Substituições: $projectedSubstitutions/${widget.substitutionLimit} • janelas: $projectedWindows/${widget.substitutionWindowLimit}.',
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            if (plannedChanges.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 9, 16, 5),
                child: Row(
                  children: [
                    const Text(
                      'TROCAS PREPARADAS',
                      style: TextStyle(
                        color: AppColors.green,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .4,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${plannedChanges.length} nesta janela',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 9.5,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 58,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: plannedChanges.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 7),
                  itemBuilder: (context, index) {
                    final change = plannedChanges[index];
                    return _PreparedSwapChip(
                      outgoing: _findPlayer(change.outgoingId)!,
                      incoming: _findPlayer(change.incomingId)!,
                      accentColor: widget.accentColor,
                      onRemove: () => _removePlannedChange(index),
                    );
                  },
                ),
              ),
              const Divider(height: 1),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 7),
              child: Row(
                children: [
                  const Text(
                    'QUEM SAI',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .5,
                    ),
                  ),
                  const Spacer(),
                  if (outgoing != null)
                    Text(
                      '${role?.label ?? outgoing.primaryPosition.label} • Efetivo ${role == null ? outgoing.overall : LineupEngine.effectiveOverall(outgoing, role)}',
                      style: TextStyle(
                        color: widget.accentColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(
              height: 104,
              child: starters.isEmpty
                  ? const Center(
                      child: Text(
                        'Não há outra troca disponível nesta janela.',
                        style: TextStyle(color: AppColors.muted, fontSize: 11),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: starters.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final player = starters[index];
                        return _StarterChoice(
                          player: player,
                          role: LineupEngine.slotForStarter(
                                provisionalStarterIds,
                                widget.formation,
                                player.id,
                              )?.role ??
                              player.primaryPosition,
                          selected: player.id == outgoingId,
                          accentColor: widget.accentColor,
                          onTap: remainingSlots <= 0
                              ? () {}
                              : () => setState(() {
                                    outgoingId = player.id;
                                    incomingId = null;
                                  }),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 7),
              child: Row(
                children: [
                  const Text(
                    'QUEM ENTRA',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .5,
                    ),
                  ),
                  const Spacer(),
                  if (remainingSlots <= 0)
                    const Text(
                      'Limite de trocas preparado',
                      style: TextStyle(color: AppColors.warning, fontSize: 10),
                    )
                  else if (outgoing == null)
                    const Text(
                      'Selecione primeiro quem sai',
                      style: TextStyle(color: AppColors.muted, fontSize: 10),
                    ),
                ],
              ),
            ),
            Expanded(
              child: bench.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Nenhum reserva disponível.',
                          style: TextStyle(color: AppColors.muted),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                      itemCount: bench.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        final player = bench[index];
                        return _BenchChoice(
                          player: player,
                          role: role,
                          recommended: role != null &&
                              LineupEngine.positionFit(player, role) >= .8,
                          selected: player.id == incomingId,
                          accentColor: widget.accentColor,
                          onTap: outgoing == null || remainingSlots <= 0
                              ? null
                              : () => setState(() => incomingId = player.id),
                        );
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 9, 16, 12),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                children: [
                  if (outgoing != null && incoming != null) ...[
                    _SwapPreview(
                      outgoing: outgoing,
                      incoming: incoming,
                      accentColor: widget.accentColor,
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: outgoing == null ||
                                  incoming == null ||
                                  remainingSlots <= 0
                              ? null
                              : _prepareCurrentChange,
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Adicionar troca'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: plannedChanges.isEmpty
                              ? null
                              : () => Navigator.of(context).pop(
                                    List<LiveSubstitutionChange>.unmodifiable(
                                      plannedChanges,
                                    ),
                                  ),
                          icon: const Icon(Icons.check_rounded),
                          label: Text(
                            plannedChanges.length == 1
                                ? 'Confirmar 1 troca'
                                : 'Confirmar ${plannedChanges.length} trocas',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreparedSwapChip extends StatelessWidget {
  const _PreparedSwapChip({
    required this.outgoing,
    required this.incoming,
    required this.accentColor,
    required this.onRemove,
  });

  final Player outgoing;
  final Player incoming;
  final Color accentColor;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Container(
        width: 190,
        padding: const EdgeInsets.fromLTRB(8, 5, 4, 5),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accentColor.withValues(alpha: .28)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${outgoing.displayName} → ${incoming.displayName}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: 'Remover troca',
              onPressed: onRemove,
              icon: const Icon(Icons.close_rounded, size: 18),
            ),
          ],
        ),
      );
}

class _StarterChoice extends StatelessWidget {
  const _StarterChoice({
    required this.player,
    required this.role,
    required this.selected,
    required this.accentColor,
    required this.onTap,
  });

  final Player player;
  final PlayerPosition role;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final effective = LineupEngine.effectiveOverall(player, role);
    final improvised = LineupEngine.positionFit(player, role) < .9;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 88,
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: selected
              ? accentColor.withValues(alpha: .10)
              : AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? accentColor
                : improvised
                    ? AppColors.warning.withValues(alpha: .55)
                    : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            PlayerAvatar(
              player: player,
              size: 43,
              accentColor: accentColor,
            ),
            const SizedBox(height: 5),
            Text(
              player.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 2),
            Text(
              '${role.label} • $effective',
              style: TextStyle(
                color: improvised ? AppColors.warning : AppColors.muted,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BenchChoice extends StatelessWidget {
  const _BenchChoice({
    required this.player,
    required this.role,
    required this.recommended,
    required this.selected,
    required this.accentColor,
    required this.onTap,
  });

  final Player player;
  final PlayerPosition? role;
  final bool recommended;
  final bool selected;
  final Color accentColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final effective = role == null
        ? player.overall
        : LineupEngine.effectiveOverall(player, role!);
    final fitLabel = role == null ? '' : LineupEngine.fitLabel(player, role!);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? accentColor.withValues(alpha: .10)
              : AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: selected ? accentColor : AppColors.border),
        ),
        child: Row(
          children: [
            PlayerAvatar(
              player: player,
              size: 42,
              accentColor: accentColor,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          player.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                      if (recommended)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: .10),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'ADEQUADO',
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${role?.label ?? player.primaryPosition.label} • Efetivo $effective • Base ${player.overall}${fitLabel.isEmpty ? '' : ' • $fitLabel'} • Cond. ${player.condition}%',
                    style: TextStyle(
                      color: player.condition < 60
                          ? AppColors.warning
                          : AppColors.muted,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? accentColor : AppColors.muted,
            ),
          ],
        ),
      ),
    );
  }
}

class _SwapPreview extends StatelessWidget {
  const _SwapPreview({
    required this.outgoing,
    required this.incoming,
    required this.accentColor,
  });

  final Player outgoing;
  final Player incoming;
  final Color accentColor;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: _PreviewPlayer(
              player: outgoing,
              label: 'SAI',
              labelColor: AppColors.danger,
              accentColor: accentColor,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.arrow_forward_rounded, color: AppColors.muted),
          ),
          Expanded(
            child: _PreviewPlayer(
              player: incoming,
              label: 'ENTRA',
              labelColor: AppColors.green,
              accentColor: accentColor,
            ),
          ),
        ],
      );
}

class _PreviewPlayer extends StatelessWidget {
  const _PreviewPlayer({
    required this.player,
    required this.label,
    required this.labelColor,
    required this.accentColor,
  });

  final Player player;
  final String label;
  final Color labelColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          PlayerAvatar(player: player, size: 32, accentColor: accentColor),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: labelColor,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .4,
                  ),
                ),
                Text(
                  player.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      );
}
