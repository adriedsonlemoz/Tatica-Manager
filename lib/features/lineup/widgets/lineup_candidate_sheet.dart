import 'dart:math';

import 'package:flutter/material.dart';

import '../../../app/widgets/player_avatar.dart';
import '../../../app/widgets/player_status_strip.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/player/player.dart';
import '../../../game/lineup/lineup_engine.dart';

class LineupCandidateSheet extends StatelessWidget {
  const LineupCandidateSheet({
    super.key,
    required this.outgoing,
    required this.role,
    required this.candidates,
    required this.accentColor,
    required this.onSelected,
  });

  final Player outgoing;
  final PlayerPosition role;
  final List<LineupCandidate> candidates;
  final Color accentColor;
  final ValueChanged<Player> onSelected;

  @override
  Widget build(BuildContext context) {
    final height = min(MediaQuery.sizeOf(context).height * .75, 680.0);
    return SafeArea(
      child: SizedBox(
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 10, 8),
              child: Row(
                children: [
                  PlayerAvatar(player: outgoing, size: 46, accentColor: accentColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trocar ${outgoing.displayName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        Text(
                          'Posição do campo: ${role.label} • lista ordenada pelo rendimento efetivo',
                          style:  TextStyle(color: AppColors.muted, fontSize: 10.5),
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
            Expanded(
              child: candidates.isEmpty
                  ?  Center(
                      child: Text(
                        'Nenhum jogador disponível para esta troca.',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
                      itemCount: candidates.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 7),
                      itemBuilder: (context, index) {
                        final candidate = candidates[index];
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => onSelected(candidate.player),
                            borderRadius: BorderRadius.circular(15),
                            child: Ink(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceRaised,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: candidate.compatible
                                      ? accentColor.withValues(alpha: .25)
                                      : AppColors.warning.withValues(alpha: .4),
                                ),
                              ),
                              child: Row(
                                children: [
                                  PlayerAvatar(
                                    player: candidate.player,
                                    size: 48,
                                    accentColor: accentColor,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                candidate.player.displayName,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontWeight: FontWeight.w900),
                                              ),
                                            ),
                                            Text(
                                              '${candidate.effectiveOverall}',
                                              style: TextStyle(
                                                color: candidate.compatible
                                                    ? AppColors.green
                                                    : AppColors.warning,
                                                fontSize: 17,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${candidate.player.primaryPosition.label} • ${LineupEngine.fitLabel(candidate.player, role)} • OVR base ${candidate.player.overall}',
                                          style:  TextStyle(
                                            color: AppColors.muted,
                                            fontSize: 10,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        PlayerStatusStrip(player: candidate.player),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
