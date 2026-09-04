import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/widgets/common.dart';
import '../../app/widgets/player_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/player/player.dart';
import '../player/player_profile_screen.dart';
import '../shared/player_discipline_indicator.dart';

class SquadScreen extends ConsumerStatefulWidget {
  const SquadScreen({super.key, this.showBackButton = false});

  final bool showBackButton;

  @override
  ConsumerState<SquadScreen> createState() => _SquadScreenState();
}

class _SquadScreenState extends ConsumerState<SquadScreen> {
  String query = '';
  _SquadFilter filter = _SquadFilter.all;
  bool showSearch = false;

  @override
  Widget build(BuildContext context) {
    final career = ref.watch(gameControllerProvider).career!;
    final club = career.userClub;
    final competitionId =
        career.nextUserFixture?.competitionId ?? career.primaryCompetitionId;
    final disciplineByPlayer = <String, PlayerDiscipline>{
      for (final player in club.squad)
        player.id: career.playerDisciplineForCompetition(
          competitionId,
          player.id,
        ),
    };
    bool available(Player player) =>
        career.isPlayerAvailableForCompetition(player, competitionId);
    final normalizedQuery = query.trim().toLowerCase();
    final players = club.squad.where((player) {
      final matchesQuery = normalizedQuery.isEmpty ||
          '${player.displayName} ${player.primaryPosition.label} ${player.nationality}'
              .toLowerCase()
              .contains(normalizedQuery);
      if (!matchesQuery) return false;
      return switch (filter) {
        _SquadFilter.all => true,
        _SquadFilter.available => available(player),
        _SquadFilter.attention => !available(player) ||
            player.condition < 70 ||
            player.fatigue > 55 ||
            disciplineByPlayer[player.id]?.isAtRisk == true,
      };
    }).toList()
      ..sort(_comparePlayers);

    final brazilianCount = club.squad
        .where((player) => player.nationality.trim().toLowerCase() == 'brasil')
        .length;
    final foreignCount = club.squad.length - brazilianCount;
    return PremiumScaffold(
      appBar: AppBar(
        leading: widget.showBackButton
            ? IconButton(
                tooltip: 'Voltar',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              )
            : null,
        automaticallyImplyLeading: false,
        titleSpacing: widget.showBackButton ? 0 : 16,
        title: const Text(
          'Elenco',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Buscar',
            onPressed: () => setState(() {
              showSearch = !showSearch;
              if (!showSearch) query = '';
            }),
            icon: Icon(showSearch ? Icons.close_rounded : Icons.search_rounded),
          ),
          PopupMenuButton<_SquadFilter>(
            tooltip: 'Filtrar elenco',
            initialValue: filter,
            onSelected: (value) => setState(() => filter = value),
            itemBuilder: (context) => _SquadFilter.values
                .map(
                  (item) => PopupMenuItem<_SquadFilter>(
                    value: item,
                    child: Text(item.label),
                  ),
                )
                .toList(),
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.filter_alt_outlined),
                if (filter != _SquadFilter.all)
                  const Positioned(
                    right: -1,
                    top: -2,
                    child: CircleAvatar(
                      radius: 4,
                      backgroundColor: AppColors.green,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
        children: [
          if (showSearch) ...[
            TextField(
              autofocus: true,
              onChanged: (value) => setState(() => query = value),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                hintText: 'Buscar jogador, posição ou país',
              ),
            ),
            const SizedBox(height: 10),
          ],
          _ClubSummaryCard(
            clubName: club.name,
            season: career.season,
            reputation: club.reputation,
            balance: club.money,
            transferBudget: club.transferBudget,
            badge: ClubBadge(club: club, size: 64),
          ),
          const SizedBox(height: 10),
          _SquadTable(
            players: players,
            clubAccent: AppColors.readableAccent(Color(club.colors.primaryHex)),
            total: club.squad.length,
            brazilians: brazilianCount,
            foreigners: foreignCount,
            disciplines: disciplineByPlayer,
            availableIds: club.squad
                .where(available)
                .map((player) => player.id)
                .toSet(),
            onPlayerTap: (player) => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PlayerProfileScreen(playerId: player.id),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static int _comparePlayers(Player a, Player b) {
    final position = _positionOrder(a.primaryPosition)
        .compareTo(_positionOrder(b.primaryPosition));
    if (position != 0) return position;
    if (a.shirtNumber > 0 && b.shirtNumber > 0) {
      final number = a.shirtNumber.compareTo(b.shirtNumber);
      if (number != 0) return number;
    } else if (a.shirtNumber > 0) {
      return -1;
    } else if (b.shirtNumber > 0) {
      return 1;
    }
    final overall = b.overall.compareTo(a.overall);
    if (overall != 0) return overall;
    return a.displayName.compareTo(b.displayName);
  }

  static int _positionOrder(PlayerPosition position) => switch (position) {
        PlayerPosition.gol => 0,
        PlayerPosition.ld => 1,
        PlayerPosition.zag => 2,
        PlayerPosition.le => 3,
        PlayerPosition.vol => 4,
        PlayerPosition.mc => 5,
        PlayerPosition.mei => 6,
        PlayerPosition.pd => 7,
        PlayerPosition.pe => 8,
        PlayerPosition.sa => 9,
        PlayerPosition.ca => 10,
      };
}

enum _SquadFilter { all, available, attention }

extension on _SquadFilter {
  String get label => switch (this) {
        _SquadFilter.all => 'Todos',
        _SquadFilter.available => 'Disponíveis',
        _SquadFilter.attention => 'Atenção',
      };
}

class _ClubSummaryCard extends StatelessWidget {
  const _ClubSummaryCard({
    required this.clubName,
    required this.season,
    required this.reputation,
    required this.balance,
    required this.transferBudget,
    required this.badge,
  });

  final String clubName;
  final int season;
  final int reputation;
  final int balance;
  final int transferBudget;
  final Widget badge;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withValues(alpha: .55)),
        ),
        child: Row(
          children: [
            badge,
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    clubName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Temporada $season',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.public_rounded,
                        size: 16,
                        color: AppColors.muted,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Reputação $reputation',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MoneyLine(
                  icon: Icons.account_balance_wallet_rounded,
                  value: compactMoney(balance),
                  color: AppColors.green,
                ),
                const SizedBox(height: 12),
                _MoneyLine(
                  icon: Icons.paid_rounded,
                  value: compactMoney(transferBudget),
                  color: AppColors.warning,
                ),
              ],
            ),
          ],
        ),
      );
}

class _MoneyLine extends StatelessWidget {
  const _MoneyLine({
    required this.icon,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 7),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
}

class _SquadTable extends StatelessWidget {
  const _SquadTable({
    required this.players,
    required this.clubAccent,
    required this.total,
    required this.brazilians,
    required this.foreigners,
    required this.disciplines,
    required this.availableIds,
    required this.onPlayerTap,
  });

  final List<Player> players;
  final Color clubAccent;
  final int total;
  final int brazilians;
  final int foreigners;
  final Map<String, PlayerDiscipline> disciplines;
  final Set<String> availableIds;
  final ValueChanged<Player> onPlayerTap;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withValues(alpha: .55)),
        ),
        child: Column(
          children: [
            const _SquadTableHeader(),
            Divider(height: 1, color: AppColors.border.withValues(alpha: .7)),
            if (players.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Text(
                  'Nenhum jogador encontrado.',
                  style: TextStyle(color: AppColors.muted),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 7, 8, 8),
                child: Column(
                  children: [
                    for (var index = 0; index < players.length; index++) ...[
                      _SquadPlayerRow(
                        player: players[index],
                        discipline: disciplines[players[index].id] ??
                            const PlayerDiscipline(),
                        available: availableIds.contains(players[index].id),
                        clubAccent: clubAccent,
                        onTap: () => onPlayerTap(players[index]),
                      ),
                      if (index != players.length - 1)
                        const SizedBox(height: 5),
                    ],
                  ],
                ),
              ),
            Divider(height: 1, color: AppColors.border.withValues(alpha: .7)),
            _SquadTotalsContent(
              total: total,
              brazilians: brazilians,
              foreigners: foreigners,
            ),
          ],
        ),
      );
}

class _SquadTableHeader extends StatelessWidget {
  const _SquadTableHeader();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.fromLTRB(10, 12, 10, 10),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              child: Text('#', style: _headerStyle),
            ),
            SizedBox(width: 44),
            Expanded(
              child: Text('JOGADOR', style: _headerStyle),
            ),
            SizedBox(
              width: 38,
              child: Center(child: Text('POS', style: _headerStyle)),
            ),
            SizedBox(
              width: 36,
              child: Center(child: Text('GER', style: _headerStyle)),
            ),
            SizedBox(
              width: 68,
              child: Center(child: Text('CARTÕES', style: _headerStyle)),
            ),
          ],
        ),
      );

  static const _headerStyle = TextStyle(
    color: AppColors.muted,
    fontSize: 9,
    fontWeight: FontWeight.w800,
    letterSpacing: .35,
  );
}

class _SquadPlayerRow extends StatelessWidget {
  const _SquadPlayerRow({
    required this.player,
    required this.discipline,
    required this.available,
    required this.clubAccent,
    required this.onTap,
  });

  final Player player;
  final PlayerDiscipline discipline;
  final bool available;
  final Color clubAccent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final morale = _MoraleVisual.fromValue(player.morale);
    return Material(
      color: AppColors.surfaceRaised,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: Text(
                  player.shirtNumber > 0 ? '${player.shirtNumber}' : '—',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              PlayerAvatar(
                player: player,
                size: 38,
                accentColor: clubAccent,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      player.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: morale.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${_positionName(player.primaryPosition)} • ${morale.label}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 9.5,
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 38,
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 34),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      player.primaryPosition.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 36,
                child: Center(
                  child: Text(
                    '${player.overall}',
                    style: const TextStyle(
                      color: AppColors.green,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 68,
                child: Center(
                  child: available
                      ? PlayerDisciplineIndicator(
                          discipline: discipline,
                          compact: true,
                        )
                      : Tooltip(
                          message: playerAvailabilityReason(player, discipline),
                          child: PlayerDisciplineIndicator(
                            discipline: discipline,
                            compact: true,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _positionName(PlayerPosition position) => switch (position) {
        PlayerPosition.gol => 'Goleiro',
        PlayerPosition.ld => 'Lateral Direito',
        PlayerPosition.le => 'Lateral Esquerdo',
        PlayerPosition.zag => 'Zagueiro',
        PlayerPosition.vol => 'Volante',
        PlayerPosition.mc => 'Meia Central',
        PlayerPosition.mei => 'Meia Ofensivo',
        PlayerPosition.pe => 'Ponta Esquerda',
        PlayerPosition.pd => 'Ponta Direita',
        PlayerPosition.sa => 'Segundo Atacante',
        PlayerPosition.ca => 'Centroavante',
      };
}

class _MoraleVisual {
  const _MoraleVisual({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  factory _MoraleVisual.fromValue(int morale) {
    if (morale >= 85) {
      return const _MoraleVisual(
        label: 'Excelente',
        color: AppColors.greenDark,
      );
    }
    if (morale >= 70) {
      return const _MoraleVisual(
        label: 'Muito Bom',
        color: AppColors.greenDark,
      );
    }
    return const _MoraleVisual(
      label: 'Regular',
      color: AppColors.warning,
    );
  }
}

class _SquadTotalsContent extends StatelessWidget {
  const _SquadTotalsContent({
    required this.total,
    required this.brazilians,
    required this.foreigners,
  });

  final int total;
  final int brazilians;
  final int foreigners;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        child: Row(
          children: [
            Expanded(
              child: _TotalItem(
                icon: Icons.groups_rounded,
                iconColor: AppColors.green,
                label: 'Total de Jogadores',
                value: '$total',
              ),
            ),
            _divider(),
            Expanded(
              child: _TotalItem(
                leadingText: '🇧🇷',
                label: 'Brasileiros',
                value: '$brazilians',
              ),
            ),
            _divider(),
            Expanded(
              child: _TotalItem(
                icon: Icons.public_rounded,
                iconColor: AppColors.info,
                label: 'Estrangeiros',
                value: '$foreigners',
              ),
            ),
          ],
        ),
      );

  static Widget _divider() => Container(
        width: 1,
        height: 42,
        margin: const EdgeInsets.symmetric(horizontal: 7),
        color: AppColors.border.withValues(alpha: .6),
      );
}

class _TotalItem extends StatelessWidget {
  const _TotalItem({
    this.icon,
    this.iconColor,
    this.leadingText,
    required this.label,
    required this.value,
  });

  final IconData? icon;
  final Color? iconColor;
  final String? leadingText;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (leadingText != null)
            Text(leadingText!, style: const TextStyle(fontSize: 20))
          else if (icon != null)
            Icon(icon, size: 24, color: iconColor),
          const SizedBox(width: 7),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.green,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}
