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
import '../../domain/season/career_event.dart';
import '../../domain/season/career_state.dart';
import '../../domain/transfer/market_career.dart';
import '../../game/cpu/cpu_user_offer_engine.dart';
import '../../game/transfer/market_career_engine.dart';
import '../../game/transfer/transfer_window_engine.dart';
import '../player/player_profile_screen.dart';
import 'incoming_transfer_offer_dialog.dart';

part 'market_components.dart';
part 'market_dialogs.dart';

class MarketScreen extends ConsumerStatefulWidget {
  const MarketScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  ConsumerState<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends ConsumerState<MarketScreen> {
  String query = '';
  PlayerPosition? position;
  _MarketFilters filters = const _MarketFilters();

  @override
  Widget build(BuildContext context) {
    final career = ref.watch(gameControllerProvider).career!;
    final windowOpen = TransferWindowEngine.isOpen(career.currentDate);
    final entries = _entries(career);
    final filtered = entries.where((entry) => _matchesFilters(entry, career.season)).toList()
      ..sort((a, b) => b.player.overall.compareTo(a.player.overall));
    final incomingOffers = career.news
        .where(
          (event) => CpuUserOfferEngine.isOfferActive(
            state: career,
            event: event,
          ),
        )
        .toList()
        .reversed
        .toList(growable: false);
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
    final activeNegotiations = career.transferNegotiations
        .where((item) => item.status.isOpen)
        .toList()
        .reversed
        .toList(growable: false);
    final negotiationHistory = career.transferNegotiations
        .where((item) => !item.status.isOpen)
        .toList()
        .reversed
        .toList(growable: false);

    return DefaultTabController(
      length: 5,
      initialIndex: widget.initialTab.clamp(0, 4).toInt(),
      child: PremiumScaffold(
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CENTRAL DE MERCADO',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            Text(
                              '${formatMoney(career.userClub.transferBudget)} disponíveis',
                              style: const TextStyle(color: AppColors.green),
                            ),
                          ],
                        ),
                      ),
                      IconButton.filledTonal(
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
                        icon: const Icon(Icons.tune_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _WindowStatus(open: windowOpen, date: career.currentDate),
                  const SizedBox(height: 10),
                  TextField(
                    onChanged: (value) => setState(() => query = value),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search_rounded),
                      hintText: 'Nome, clube, país ou posição',
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        ChoiceChip(
                          label: const Text('Todas'),
                          selected: position == null,
                          onSelected: (_) => setState(() => position = null),
                        ),
                        const SizedBox(width: 6),
                        ...PlayerPosition.values.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text(item.label),
                              selected: position == item,
                              onSelected: (_) => setState(() => position = item),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (filters.isActive) ...[
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        const Icon(Icons.filter_alt_rounded,
                            size: 16, color: AppColors.green),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            filters.summary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              setState(() => filters = const _MarketFilters()),
                          child: const Text('Limpar'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [
                Tab(text: 'Buscar'),
                Tab(text: 'Observação'),
                Tab(text: 'Negociações'),
                Tab(text: 'Propostas recebidas'),
                Tab(text: 'Histórico'),
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
                  _NegotiationsTab(
                    negotiations: activeNegotiations,
                    entries: entries,
                  ),
                  _IncomingOffersTab(events: incomingOffers),
                  _NegotiationHistoryTab(
                    negotiations: negotiationHistory,
                    entries: entries,
                  ),
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
