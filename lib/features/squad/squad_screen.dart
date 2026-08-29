import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/widgets/common.dart';
import '../../app/widgets/player_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/club/club.dart';
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
  _SquadView view = _SquadView.players;
  bool searchVisible = false;

  @override
  Widget build(BuildContext context) {
    final career = ref.watch(gameControllerProvider).career!;
    final club = career.userClub;
    final players = _visiblePlayers(club.squad);
    final brazilians = club.squad.where(_isBrazilian).length;

    return PremiumScaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: widget.showBackButton
            ? IconButton(
                tooltip: 'Voltar',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              )
            : null,
        titleSpacing: widget.showBackButton ? 0 : 18,
        title: const Text('Elenco'),
        actions: [
          IconButton(
            tooltip: searchVisible ? 'Fechar busca' : 'Buscar jogador',
            onPressed: () => setState(() {
              searchVisible = !searchVisible;
              if (!searchVisible) query = '';
            }),
            icon: Icon(searchVisible ? Icons.close_rounded : Icons.search_rounded),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                tooltip: 'Filtrar elenco',
                onPressed: _showFilters,
                icon: const Icon(Icons.filter_alt_outlined),
              ),
              if (filter != _SquadFilter.all)
                const Positioned(
                  right: 8,
                  top: 8,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox(width: 9, height: 9),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: _ClubHeader(club: club, season: career.season),
          ),
          if (searchVisible)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: TextField(
                autofocus: true,
                onChanged: (value) => setState(() => query = value),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded),
                  hintText: 'Buscar jogador, posição ou país',
                  isDense: true,
                ),
              ),
            ),
          _SquadTabs(
            selected: view,
            onSelected: (value) => setState(() => view = value),
          ),
          const _SquadTableHeader(),
          Expanded(
            child: players.isEmpty
                ? const Center(child: Text('Nenhum jogador encontrado.'))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    itemCount: players.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 5),
                    itemBuilder: (context, index) {
                      final player = players[index];
                      return _SquadPlayerRow(
                        player: player,
                        accent: Color(club.colors.primaryHex),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                PlayerProfileScreen(playerId: player.id),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          _SquadSummary(
            total: club.squad.length,
            brazilians: brazilians,
            foreigners: club.squad.length - brazilians,
          ),
        ],
      ),
    );
  }

  List<Player> _visiblePlayers(List<Player> squad) {
    final normalizedQuery = query.trim().toLowerCase();
    final players = squad.where((player) {
      final matchesQuery = normalizedQuery.isEmpty ||
          '${player.displayName} ${player.primaryPosition.label} ${_positionName(player.primaryPosition)} ${player.nationality}'
              .toLowerCase()
              .contains(normalizedQuery);
      if (!matchesQuery) return false;
      return switch (filter) {
        _SquadFilter.all => true,
        _SquadFilter.available => player.isAvailable,
        _SquadFilter.attention =>
          !player.isAvailable || player.morale < 50 || player.condition < 70,
      };
    }).toList(growable: false);

    switch (view) {
      case _SquadView.players:
        return players;
      case _SquadView.roles:
        return [...players]
          ..sort((a, b) {
            final position = a.primaryPosition.index.compareTo(
              b.primaryPosition.index,
            );
            if (position != 0) return position;
            return b.overall.compareTo(a.overall);
          });
      case _SquadView.status:
        return [...players]
          ..sort((a, b) {
            if (a.isAvailable != b.isAvailable) return a.isAvailable ? 1 : -1;
            final morale = a.morale.compareTo(b.morale);
            if (morale != 0) return morale;
            return a.condition.compareTo(b.condition);
          });
    }
  }

  Future<void> _showFilters() async {
    final selected = await showModalBottomSheet<_SquadFilter>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Filtrar elenco',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              for (final item in _SquadFilter.values)
                ListTile(
                  leading: Icon(
                    item == filter
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color:
                        item == filter ? AppColors.green : AppColors.muted,
                  ),
                  title: Text(item.label),
                  onTap: () => Navigator.of(context).pop(item),
                ),
            ],
          ),
        ),
      ),
    );
    if (selected != null && mounted) setState(() => filter = selected);
  }

  static bool _isBrazilian(Player player) {
    final country = player.nationality.trim().toLowerCase();
    return country == 'brasil' || country == 'brazil' || country == 'br';
  }
}

enum _SquadView { players, roles, status }

extension on _SquadView {
  String get label => switch (this) {
        _SquadView.players => 'Jogadores',
        _SquadView.roles => 'Funções',
        _SquadView.status => 'Status',
      };
}

enum _SquadFilter { all, available, attention }

extension on _SquadFilter {
  String get label => switch (this) {
        _SquadFilter.all => 'Todos os jogadores',
        _SquadFilter.available => 'Disponíveis',
        _SquadFilter.attention => 'Precisam de atenção',
      };
}

class _ClubHeader extends StatelessWidget {
  const _ClubHeader({required this.club, required this.season});

  final Club club;
  final int season;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            ClubBadge(club: club, size: 78),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    club.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Temporada $season',
                    style: TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.public_rounded, size: 17, color: AppColors.muted),
                      const SizedBox(width: 6),
                      Text(
                        _reputationLabel(club.reputation),
                        style: TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ClubValue(
                  icon: Icons.payments_rounded,
                  color: AppColors.green,
                  value: compactMoney(club.money).replaceFirst(r'R$ ', ''),
                ),
                const SizedBox(height: 12),
                _ClubValue(
                  icon: Icons.monetization_on_rounded,
                  color: AppColors.warning,
                  value:
                      compactMoney(club.transferBudget).replaceFirst(r'R$ ', ''),
                ),
              ],
            ),
          ],
        ),
      );

  static String _reputationLabel(int reputation) {
    if (reputation >= 86) return 'Nível Mundial';
    if (reputation >= 76) return 'Nível Continental';
    if (reputation >= 61) return 'Nível Nacional';
    return 'Nível Regional';
  }
}

class _ClubValue extends StatelessWidget {
  const _ClubValue({required this.icon, required this.color, required this.value});

  final IconData icon;
  final Color color;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 21),
          const SizedBox(width: 7),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      );
}

class _SquadTabs extends StatelessWidget {
  const _SquadTabs({required this.selected, required this.onSelected});

  final _SquadView selected;
  final ValueChanged<_SquadView> onSelected;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            for (final item in _SquadView.values)
              Expanded(
                child: InkWell(
                  onTap: () => onSelected(item),
                  child: Column(
                    children: [
                      const SizedBox(height: 15),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: item == selected
                              ? AppColors.green
                              : AppColors.textPrimary,
                          fontWeight: item == selected
                              ? FontWeight.w900
                              : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        height: 3,
                        decoration: BoxDecoration(
                          color: item == selected
                              ? AppColors.green
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
}

class _SquadTableHeader extends StatelessWidget {
  const _SquadTableHeader();

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.fromLTRB(10, 10, 12, 9),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            left: BorderSide(color: AppColors.border),
            right: BorderSide(color: AppColors.border),
            bottom: BorderSide(color: AppColors.border),
          ),
        ),
        child: const Row(
          children: [
            SizedBox(width: 34, child: _HeaderLabel('#')),
            Expanded(child: _HeaderLabel('JOGADOR')),
            SizedBox(width: 42, child: _HeaderLabel('POS', center: true)),
            SizedBox(width: 46, child: _HeaderLabel('GER', center: true)),
            SizedBox(width: 80, child: _HeaderLabel('MORAL', center: true)),
          ],
        ),
      );
}

class _HeaderLabel extends StatelessWidget {
  const _HeaderLabel(this.text, {this.center = false});

  final String text;
  final bool center;

  @override
  Widget build(BuildContext context) => Text(
        text,
        textAlign: center ? TextAlign.center : TextAlign.left,
        style: TextStyle(
          color: AppColors.muted,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: .35,
        ),
      );
}

class _SquadPlayerRow extends StatelessWidget {
  const _SquadPlayerRow({
    required this.player,
    required this.accent,
    required this.onTap,
  });

  final Player player;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final morale = _moralePresentation(player);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          height: 68,
          padding: const EdgeInsets.fromLTRB(10, 7, 12, 7),
          decoration: BoxDecoration(
            color: AppColors.surfaceRaised,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 34,
                child: Text(
                  player.shirtNumber > 0 ? '${player.shirtNumber}' : '—',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              PlayerAvatar(player: player, size: 45, accentColor: accent),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _positionName(player.primaryPosition),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: AppColors.muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                width: 38,
                padding: const EdgeInsets.symmetric(vertical: 5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  player.primaryPosition.label,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
              SizedBox(
                width: 46,
                child: Text(
                  '${player.overall}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.green,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(
                width: 78,
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: morale.color,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(morale.icon, size: 16, color: Colors.white),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        morale.label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppColors.muted, fontSize: 10.5),
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
}

class _SquadSummary extends StatelessWidget {
  const _SquadSummary({
    required this.total,
    required this.brazilians,
    required this.foreigners,
  });

  final int total;
  final int brazilians;
  final int foreigners;

  @override
  Widget build(BuildContext context) => SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  icon: Icons.groups_2_rounded,
                  color: AppColors.green,
                  label: 'Total de jogadores',
                  value: '$total',
                ),
              ),
              Container(width: 1, height: 38, color: AppColors.border),
              Expanded(
                child: _SummaryItem(
                  icon: Icons.flag_circle_rounded,
                  color: AppColors.warning,
                  label: 'Brasileiros',
                  value: '$brazilians',
                ),
              ),
              Container(width: 1, height: 38, color: AppColors.border),
              Expanded(
                child: _SummaryItem(
                  icon: Icons.public_rounded,
                  color: AppColors.info,
                  label: 'Estrangeiros',
                  value: '$foreigners',
                ),
              ),
            ],
          ),
        ),
      );
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 25),
          const SizedBox(width: 7),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColors.muted, fontSize: 9.5),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}

({Color color, IconData icon, String label}) _moralePresentation(Player player) {
  if (player.injury != null) {
    return (
      color: AppColors.danger,
      icon: Icons.medical_services_rounded,
      label: 'Lesionado',
    );
  }
  if (player.discipline.suspendedRounds > 0) {
    return (
      color: AppColors.danger,
      icon: Icons.block_rounded,
      label: 'Suspenso',
    );
  }
  if (player.condition < 35) {
    return (
      color: AppColors.warning,
      icon: Icons.arrow_downward_rounded,
      label: 'Cond. baixa',
    );
  }
  if (player.morale >= 80) {
    return (
      color: AppColors.green,
      icon: Icons.arrow_upward_rounded,
      label: 'Excelente',
    );
  }
  if (player.morale >= 65) {
    return (
      color: AppColors.green,
      icon: Icons.arrow_upward_rounded,
      label: 'Muito bom',
    );
  }
  if (player.morale >= 45) {
    return (
      color: AppColors.warning,
      icon: Icons.remove_rounded,
      label: 'Regular',
    );
  }
  return (
    color: AppColors.danger,
    icon: Icons.arrow_downward_rounded,
    label: 'Baixo',
  );
}

String _positionName(PlayerPosition position) => switch (position) {
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
