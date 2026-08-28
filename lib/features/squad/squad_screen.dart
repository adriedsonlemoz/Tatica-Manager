import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/widgets/common.dart';
import '../../app/widgets/player_card.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/player/player.dart';
import '../player/player_profile_screen.dart';

class SquadScreen extends ConsumerStatefulWidget {
  const SquadScreen({super.key, this.showBackButton = false});

  final bool showBackButton;

  @override
  ConsumerState<SquadScreen> createState() => _SquadScreenState();
}

class _SquadScreenState extends ConsumerState<SquadScreen> {
  String query = '';
  _SquadFilter filter = _SquadFilter.all;

  @override
  Widget build(BuildContext context) {
    final career = ref.watch(gameControllerProvider).career!;
    final club = career.userClub;
    final normalizedQuery = query.trim().toLowerCase();
    final players = club.squad.where((player) {
      final matchesQuery = normalizedQuery.isEmpty ||
          '${player.displayName} ${player.primaryPosition.label} ${player.nationality}'
              .toLowerCase()
              .contains(normalizedQuery);
      if (!matchesQuery) return false;
      return switch (filter) {
        _SquadFilter.all => true,
        _SquadFilter.available => player.isAvailable,
        _SquadFilter.attention => !player.isAvailable ||
            player.condition < 70 ||
            player.fatigue > 55 ||
            player.discipline.yellowCards >= 2,
      };
    }).toList();

    final groups = _buildGroups(players);
    return PremiumScaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (widget.showBackButton) ...[
                        IconButton.filledTonal(
                          tooltip: 'Voltar',
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
                              'ELENCO',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${club.squad.length} jogadores • OVR médio ${club.averageOverall.toStringAsFixed(1)} • ${career.starterIds.length}/11 titulares',
                              style: const TextStyle(color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    onChanged: (value) => setState(() => query = value),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search_rounded),
                      hintText: 'Buscar jogador, posição ou país',
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _SquadFilter.values
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ChoiceChip(
                                label: Text(item.label),
                                selected: filter == item,
                                onSelected: (_) => setState(() => filter = item),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 110),
            sliver: SliverList.list(
              children: [
                if (groups.every((group) => group.players.isEmpty))
                  const SectionCard(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 22),
                      child: Center(
                        child: Text(
                          'Nenhum jogador encontrado.',
                          style: TextStyle(color: AppColors.muted),
                        ),
                      ),
                    ),
                  ),
                for (final group in groups)
                  if (group.players.isNotEmpty) ...[
                    _PositionHeader(title: group.title, count: group.players.length),
                    const SizedBox(height: 7),
                    for (final player in group.players) ...[
                      PlayerCard(
                        player: player,
                        club: club,
                        size: PlayerCardSize.compact,
                        lineupLabel: _lineupLabel(player, career.starterIds),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PlayerProfileScreen(playerId: player.id),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    const SizedBox(height: 6),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<_SquadGroup> _buildGroups(List<Player> players) {
    List<Player> select(Set<PlayerPosition> positions) => players
        .where((player) => positions.contains(player.primaryPosition))
        .toList()
      ..sort((a, b) {
        if (a.isAvailable != b.isAvailable) return a.isAvailable ? -1 : 1;
        final overall = b.overall.compareTo(a.overall);
        if (overall != 0) return overall;
        return a.displayName.compareTo(b.displayName);
      });

    return [
      _SquadGroup('GOLEIROS', select({PlayerPosition.gol})),
      _SquadGroup('ZAGUEIROS', select({PlayerPosition.zag})),
      _SquadGroup('LATERAIS', select({PlayerPosition.ld, PlayerPosition.le})),
      _SquadGroup(
        'MEIO-CAMPISTAS',
        select({PlayerPosition.vol, PlayerPosition.mc, PlayerPosition.mei}),
      ),
      _SquadGroup(
        'ATACANTES',
        select({PlayerPosition.pe, PlayerPosition.pd, PlayerPosition.sa, PlayerPosition.ca}),
      ),
    ];
  }

  String _lineupLabel(Player player, List<String> starterIds) {
    if (!player.isAvailable) return 'Fora';
    return starterIds.contains(player.id) ? 'Titular' : 'Banco';
  }
}

enum _SquadFilter { all, available, attention }

extension on _SquadFilter {
  String get label => switch (this) {
        _SquadFilter.all => 'Todos',
        _SquadFilter.available => 'Disponíveis',
        _SquadFilter.attention => 'Atenção',
      };
}

class _SquadGroup {
  const _SquadGroup(this.title, this.players);

  final String title;
  final List<Player> players;
}

class _PositionHeader extends StatelessWidget {
  const _PositionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: .7,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: Container(height: 1, color: AppColors.border)),
            const SizedBox(width: 8),
            Text(
              '$count',
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
}
