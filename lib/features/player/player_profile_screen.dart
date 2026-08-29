import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/widgets/common.dart';
import '../../app/widgets/player_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/player/player.dart';
import '../../game/contract/contract_engine.dart';
import 'player_market_dialogs.dart';

class PlayerProfileScreen extends ConsumerWidget {
  const PlayerProfileScreen({super.key, required this.playerId, this.clubId});
  final String playerId;
  final String? clubId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final career = ref.watch(gameControllerProvider).career!;
    final ownerClub = clubId == null
        ? career.userClub
        : career.clubs.firstWhere((club) => club.id == clubId);
    final matches = ownerClub.squad.where((p) => p.id == playerId);
    final academyMatches = ownerClub.id == career.userClubId
        ? career.youthAcademy.where((p) => p.id == playerId)
        : const <Player>[];
    if (matches.isEmpty && academyMatches.isEmpty) {
      return const PremiumScaffold(
        safeBottom: true,
        appBar: GameTopBar(title: 'Jogador transferido'),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Este jogador não faz mais parte do elenco.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final isAcademy = matches.isEmpty && academyMatches.isNotEmpty;
    final player = isAcademy ? academyMatches.first : matches.first;
    final expected = ContractEngine.expectedSalary(player);
    return PremiumScaffold(
      safeBottom: true,
      appBar: GameTopBar(
        title: player.displayName,
        subtitle: '${player.primaryPosition.label} • ${player.age} anos',
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
        children: [
          SectionCard(
            padding: const EdgeInsets.all(14),
            child: Stack(
              children: [
                Positioned(
                  right: -4,
                  bottom: -12,
                  child: Text(
                    player.primaryPosition.label,
                    style: TextStyle(
                      fontSize: 58,
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withValues(alpha: .035),
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PlayerAvatar(
                      player: player,
                      size: 116,
                      accentColor: Color(ownerClub.colors.primaryHex),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            player.displayName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              ClubBadge(club: ownerClub, size: 26),
                              const SizedBox(width: 7),
                              Expanded(
                                child: Text(
                                  ownerClub.shortName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 7),
                          Text(
                            '${player.primaryPosition.label} • ${player.age} anos • ${player.nationality}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 9),
                          Row(
                            children: [
                              _RatingPill(label: 'OVR', value: player.overall),
                              const SizedBox(width: 7),
                              _RatingPill(label: 'POT', value: player.potential),
                            ],
                          ),
                          const SizedBox(height: 7),
                          Text(
                            '${player.heightCm} cm • ${player.weightKg} kg • ${_footLabel(player.preferredFoot)}',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CONDIÇÃO',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                _Bar(label: 'Condição física', value: player.condition),
                _Bar(label: 'Moral', value: player.morale),
                _Bar(label: 'Fadiga', value: 100 - player.fatigue),
                if (player.injury != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${player.injury!.name} • ${player.injury!.roundsRemaining} rodada(s)',
                      style: const TextStyle(color: AppColors.warning),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ATRIBUTOS',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                _AttrGrid(player: player),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TEMPORADA ${career.season}',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Metric(label: 'Jogos', value: '${player.stats.appearances}'),
                    Metric(label: 'Gols', value: '${player.stats.goals}'),
                    Metric(label: 'Assist.', value: '${player.stats.assists}'),
                    Metric(
                      label: 'Nota',
                      value: player.stats.averageRating == 0
                          ? '—'
                          : player.stats.averageRating.toStringAsFixed(1),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAcademy ? 'CATEGORIA DE BASE' : 'CONTRATO E MERCADO',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Metric(label: 'Valor', value: formatMoney(player.marketValue)),
                    Metric(
                      label: 'Salário/mês',
                      value: formatMoney(player.salary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Contrato até ${player.contract.endSeason} • expectativa atual: ${formatMoney(expected)}/mês',
                  style: TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 14),
                if (ownerClub.id == career.userClubId && !isAcademy)
                  Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonal(
                        onPressed: () => showRenewPlayerDialog(
                          context,
                          ref,
                          player,
                          expected,
                        ),
                        child: const Text('Renovar'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final sold = await showPlayerSaleDialog(context, ref, player);
                          if (sold == true && context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                        icon: const Icon(Icons.sell_outlined),
                        label: const Text('Vender'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

String _footLabel(PreferredFoot foot) => switch (foot) {
      PreferredFoot.right => 'Destro',
      PreferredFoot.left => 'Canhoto',
      PreferredFoot.both => 'Ambidestro',
    };

class _RatingPill extends StatelessWidget {
  const _RatingPill({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.green.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.green.withValues(alpha: .30)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              '$value',
              style: const TextStyle(
                color: AppColors.green,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      );
}

class _Bar extends StatelessWidget {
  const _Bar({required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            SizedBox(
              width: 105,
              child: Text(label, style: TextStyle(color: AppColors.muted)),
            ),
            Expanded(
              child: LinearProgressIndicator(
                value: value / 100,
                minHeight: 7,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 28,
              child: Text(
                '$value',
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      );
}

class _AttrGrid extends StatelessWidget {
  const _AttrGrid({required this.player});
  final Player player;

  @override
  Widget build(BuildContext context) {
    final values = <String, int>{
      'Finalização': player.technical.finishing,
      'Passe': player.technical.passing,
      'Drible': player.technical.dribbling,
      'Desarme': player.technical.tackling,
      'Velocidade': player.physical.speed,
      'Força': player.physical.strength,
      'Resistência': player.physical.stamina,
      'Visão': player.mental.vision,
      'Decisão': player.mental.decision,
      'Posicionamento': player.mental.positioning,
    };
    if (player.primaryPosition == PlayerPosition.gol) {
      values
        ..clear()
        ..addAll({
          'Reflexo': player.goalkeeper.reflexes,
          'Posicionamento': player.goalkeeper.positioning,
          'Defesa': player.goalkeeper.saving,
          'Saída': player.goalkeeper.rushingOut,
          'Jogo aéreo': player.goalkeeper.aerial,
        });
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 8) / 2;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: values.entries
              .map(
                (entry) => Container(
                  width: itemWidth,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          entry.key,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        '${entry.value}',
                        style: TextStyle(
                          color: entry.value >= 80
                              ? AppColors.green
                              : Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
