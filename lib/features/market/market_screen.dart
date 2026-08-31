import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/state/transfer_controller.dart';
import '../../app/widgets/common.dart';
import '../../app/widgets/player_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/competition_catalog.dart';
import '../../domain/club/club.dart';
import '../../domain/player/player.dart';
import '../../domain/season/career_state.dart';
import '../../domain/transfer/market_career.dart';
import '../../game/transfer/market_career_engine.dart';
import '../../game/transfer/transfer_window_engine.dart';
import '../player/player_profile_screen.dart';

part 'market_components.dart';
part 'market_dialogs.dart';

enum MarketSection { market, observed, negotiations }

class MarketScreen extends ConsumerStatefulWidget {
  const MarketScreen({
    super.key,
    this.initialSection = MarketSection.market,
    this.initialTab,
    this.showBackButton = false,
  });

  /// Mantém rotas antigas funcionais: 0=Mercado, 1=Observados e qualquer
  /// aba legada de negociação abre a nova Central de Negociações.
  final int? initialTab;
  final MarketSection initialSection;
  final bool showBackButton;

  @override
  ConsumerState<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends ConsumerState<MarketScreen> {
  String query = '';
  PlayerPosition? position;
  _MarketFilters filters = const _MarketFilters();
  bool _searchExpanded = false;
  late int _activeTab;

  @override
  void initState() {
    super.initState();
    final legacy = widget.initialTab;
    _activeTab = legacy == null
        ? widget.initialSection.index
        : legacy == 1
            ? MarketSection.observed.index
            : legacy >= 2
                ? MarketSection.negotiations.index
                : MarketSection.market.index;
  }

  @override
  Widget build(BuildContext context) {
    final career = ref.watch(gameControllerProvider).career!;
    final windowOpen = TransferWindowEngine.isOpen(career.currentDate);
    final entries = _entries(career);
    final filtered = entries.where((entry) => _matchesFilters(entry, career.season)).toList()
      ..sort((a, b) => b.player.overall.compareTo(a.player.overall));
    final observedEntries = entries
        .where(
          (entry) => career.scoutingReports.any(
            (report) => report.playerId == entry.player.id,
          ),
        )
        .toList()
      ..sort((a, b) {
        final ra = MarketCareerEngine.reportFor(career, a.player.id)!;
        final rb = MarketCareerEngine.reportFor(career, b.player.id)!;
        final level = rb.level.index.compareTo(ra.level.index);
        return level != 0 ? level : b.player.overall.compareTo(a.player.overall);
      });

    return DefaultTabController(
      length: 3,
      initialIndex: _activeTab,
      child: PremiumScaffold(
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (widget.showBackButton) ...[
                        IconButton(
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
                              'Transferências',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Buscar jogadores',
                        onPressed: () => setState(
                          () => _searchExpanded = !_searchExpanded,
                        ),
                        icon: Icon(
                          _searchExpanded
                              ? Icons.search_off_rounded
                              : Icons.search_rounded,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Filtros avançados',
                        onPressed: () async {
                          final next = await showModalBottomSheet<_MarketFilters>(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => _MarketFiltersSheet(
                              initial: filters,
                              clubs: career.clubs,
                              nationalities: entries
                                  .map((entry) => entry.player.nationality)
                                  .toSet()
                                  .toList()
                                ..sort(),
                            ),
                          );
                          if (next != null && mounted) {
                            setState(() => filters = next);
                          }
                        },
                        icon: Badge(
                          isLabelVisible: filters.isActive,
                          child: const Icon(Icons.filter_alt_outlined),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _TransferClubSummary(
                    club: career.userClub,
                    season: career.season,
                    competitionName: CompetitionCatalog.displayNameForId(
                      career.primaryCompetitionId,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _WindowStatus(open: windowOpen, date: career.currentDate),
                  if (_searchExpanded && _activeTab == MarketSection.market.index)
                    _MarketSearchControls(
                      query: query,
                      position: position,
                      filters: filters,
                      onQueryChanged: (value) => setState(() => query = value),
                      onPositionChanged: (value) => setState(() => position = value),
                      onClearFilters: () =>
                          setState(() => filters = const _MarketFilters()),
                    ),
                ],
              ),
            ),
            TabBar(
              onTap: (value) => setState(() => _activeTab = value),
              tabs: [
                const Tab(text: 'Mercado'),
                const Tab(text: 'Observados'),
                Tab(text: 'Negociações'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _SearchTab(
                    entries: filtered,
                    windowOpen: windowOpen,
                  ),
                  _ScoutingTab(entries: observedEntries),
                  _NegotiationsTab(career: career),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_MarketEntry> _entries(CareerState career) {
    final result = <_MarketEntry>[];
    for (final club in career.clubs.where((Club c) => c.id != career.userClubId)) {
      final series = CompetitionCatalog.primarySeriesForClub(club.id);
      for (final player in club.squad) {
        result.add(
          _MarketEntry(
            player: player,
            club: club,
            free: false,
            seriesId: series.id,
          ),
        );
      }
    }
    for (final player in career.freeAgents) {
      result.add(
        _MarketEntry(
          player: player,
          club: null,
          free: true,
          seriesId: null,
        ),
      );
    }
    return result;
  }

  bool _matchesFilters(_MarketEntry entry, int currentSeason) {
    final term = query.trim().toLowerCase();
    final haystack = [
      entry.player.displayName,
      entry.player.nationality,
      entry.player.primaryPosition.label,
      entry.club?.name ?? 'Sem clube',
    ].join(' ').toLowerCase();
    if (term.isNotEmpty && !haystack.contains(term)) return false;
    if (position != null && entry.player.primaryPosition != position) return false;
    if (filters.nationality != null &&
        entry.player.nationality != filters.nationality) {
      return false;
    }
    if (filters.clubId != null && entry.club?.id != filters.clubId) return false;
    if (filters.seriesId != null && entry.seriesId != filters.seriesId) return false;
    if (filters.freeOnly && !entry.free) return false;
    if (filters.expiringOnly &&
        entry.player.contract.endSeason > currentSeason + 1) {
      return false;
    }
    if (entry.player.age < filters.minAge || entry.player.age > filters.maxAge) {
      return false;
    }
    if (entry.player.overall < filters.minOverall) return false;
    if (entry.player.potential < filters.minPotential) return false;
    if (filters.maxValue > 0 && entry.player.marketValue > filters.maxValue) {
      return false;
    }
    if (filters.maxSalary > 0 && entry.player.salary > filters.maxSalary) {
      return false;
    }
    return true;
  }
}

class _TransferClubSummary extends StatelessWidget {
  const _TransferClubSummary({
    required this.club,
    required this.season,
    required this.competitionName,
  });

  final Club club;
  final int season;
  final String competitionName;

  @override
  Widget build(BuildContext context) => SectionCard(
        padding: const EdgeInsets.all(13),
        child: Row(
          children: [
            ClubBadge(club: club, size: 58),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    club.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Temporada $season',
                    style: const TextStyle(color: AppColors.muted, fontSize: 11),
                  ),
                  Text(
                    competitionName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.muted, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'ORÇAMENTO',
                  style: TextStyle(color: AppColors.muted, fontSize: 9),
                ),
                Text(
                  formatMoney(club.transferBudget),
                  style: const TextStyle(
                    color: AppColors.green,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'FOLHA MENSAL',
                  style: TextStyle(color: AppColors.muted, fontSize: 9),
                ),
                Text(
                  formatMoney(club.payroll),
                  style: const TextStyle(
                    color: AppColors.green,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

class _MarketSearchControls extends StatelessWidget {
  const _MarketSearchControls({
    required this.query,
    required this.position,
    required this.filters,
    required this.onQueryChanged,
    required this.onPositionChanged,
    required this.onClearFilters,
  });

  final String query;
  final PlayerPosition? position;
  final _MarketFilters filters;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<PlayerPosition?> onPositionChanged;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 9),
        child: Column(
          children: [
            TextField(
              onChanged: onQueryChanged,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                hintText: 'Nome, clube, país ou posição',
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 35,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ChoiceChip(
                    label: const Text('Todas'),
                    selected: position == null,
                    onSelected: (_) => onPositionChanged(null),
                  ),
                  const SizedBox(width: 6),
                  ...PlayerPosition.values.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(item.label),
                        selected: position == item,
                        onSelected: (_) => onPositionChanged(item),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (filters.isActive) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.filter_alt_rounded,
                    size: 16,
                    color: AppColors.green,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      filters.summary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.muted, fontSize: 11),
                    ),
                  ),
                  TextButton(onPressed: onClearFilters, child: const Text('Limpar')),
                ],
              ),
            ],
          ],
        ),
      );
}
