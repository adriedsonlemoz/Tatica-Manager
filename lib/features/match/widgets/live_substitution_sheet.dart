import 'dart:math';

import 'package:flutter/material.dart';

import '../../../app/widgets/player_avatar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/formation/formation.dart';
import '../../../domain/player/player.dart';
import '../../../game/lineup/lineup_engine.dart';

class LiveSubstitutionSelection {
  const LiveSubstitutionSelection({required this.outgoingId, required this.incomingId});

  final String outgoingId;
  final String incomingId;
}

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
  });

  final List<Player> squad;
  final List<String> starterIds;
  final FormationType formation;
  final Color accentColor;
  final Set<String> excludedIncomingIds;
  final Set<String> dismissedPlayerIds;
  final int substitutionsUsed;
  final int substitutionLimit;

  @override
  State<LiveSubstitutionSheet> createState() => _LiveSubstitutionSheetState();
}

class _LiveSubstitutionSheetState extends State<LiveSubstitutionSheet> {
  String? outgoingId;
  String? incomingId;

  List<Player> get starters {
    final byId = {for (final player in widget.squad) player.id: player};
    return widget.starterIds
        .where((id) => !widget.dismissedPlayerIds.contains(id))
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
    return LineupEngine.slotForStarter(widget.starterIds, widget.formation, id)?.role;
  }

  List<Player> get bench {
    final role = selectedRole;
    if (role == null) {
      final players = widget.squad
          .where(
            (player) =>
                !widget.starterIds.contains(player.id) &&
                !widget.excludedIncomingIds.contains(player.id) &&
                player.isAvailable,
          )
          .toList()
        ..sort((a, b) => b.overall.compareTo(a.overall));
      return players;
    }
    return LineupEngine.candidatesForRole(
      widget.squad,
      role,
      excludedIds: {...widget.starterIds, ...widget.excludedIncomingIds},
    ).map((candidate) => candidate.player).toList();
  }

  @override
  Widget build(BuildContext context) {
    final height = min(MediaQuery.sizeOf(context).height * .88, 720.0);
    final outgoing = _findPlayer(outgoingId);
    final incoming = _findPlayer(incomingId);
    final role = selectedRole;

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
                          'Fazer substituição',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Substituições: ${widget.substitutionsUsed}/${widget.substitutionLimit} • escolha quem sai e quem entra.',
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 7),
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
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: starters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final player = starters[index];
                  return _StarterChoice(
                    player: player,
                    role: LineupEngine.slotForStarter(
                          widget.starterIds,
                          widget.formation,
                          player.id,
                        )?.role ??
                        player.primaryPosition,
                    selected: player.id == outgoingId,
                    accentColor: widget.accentColor,
                    onTap: () => setState(() {
                      outgoingId = player.id;
                      incomingId = null;
                    }),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 13, 16, 7),
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
                  if (outgoing == null)
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
                          onTap: outgoing == null
                              ? null
                              : () => setState(() => incomingId = player.id),
                        );
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
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
                    const SizedBox(height: 9),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: outgoing == null || incoming == null
                          ? null
                          : () => Navigator.of(context).pop(
                                LiveSubstitutionSelection(
                                  outgoingId: outgoing.id,
                                  incomingId: incoming.id,
                                ),
                              ),
                      icon: const Icon(Icons.swap_vert_rounded),
                      label: const Text('Confirmar substituição'),
                    ),
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
