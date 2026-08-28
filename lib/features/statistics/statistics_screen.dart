import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/widgets/common.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/competition_catalog.dart';
import '../../domain/club/club.dart';
import '../../domain/league/standing.dart';
import '../../domain/match/match_models.dart';
import '../../domain/player/player.dart';
import '../../game/career/manager_ranking_engine.dart';
import '../calendar/calendar_screen.dart';
import '../clubs/club_profile_screen.dart';
import '../player/player_profile_screen.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  String? _selectedSeriesId;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final career = ref.watch(gameControllerProvider).career!;
    final clubIds = career.clubs.map((club) => club.id).toSet();
    final availableSeries = CompetitionCatalog.allSeries
        .where((series) => series.clubIds.any(clubIds.contains))
        .toList(growable: false);
    final fallback = CompetitionCatalog.primarySeriesForClub(career.userClubId);
    final series = availableSeries.firstWhere(
      (item) => item.id == _selectedSeriesId,
      orElse: () => availableSeries.isEmpty ? fallback : availableSeries.first,
    );
    final allowed = series.clubIds.toSet();
    final clubs = career.clubs.where((club) => allowed.contains(club.id)).toList();
    final fixtures = career.fixtures
        .where((fixture) => allowed.contains(fixture.homeClubId) && allowed.contains(fixture.awayClubId))
        .toList();
    final standings = career.standings.where((item) => allowed.contains(item.clubId)).toList()
      ..sort((a, b) {
        final pts = b.points.compareTo(a.points);
        if (pts != 0) return pts;
        final gd = b.goalDifference.compareTo(a.goalDifference);
        return gd != 0 ? gd : b.goalsFor.compareTo(a.goalsFor);
      });
    final players = <({Player player, Club club})>[
      for (final club in clubs)
        for (final player in club.squad) (player: player, club: club),
    ];
    final scorers = [...players]
      ..sort((a, b) {
        final goals = b.player.stats.goals.compareTo(a.player.stats.goals);
        if (goals != 0) return goals;
        return b.player.stats.assists.compareTo(a.player.stats.assists);
      });
    final assists = [...players]
      ..sort((a, b) {
        final value = b.player.stats.assists.compareTo(a.player.stats.assists);
        if (value != 0) return value;
        return b.player.stats.goals.compareTo(a.player.stats.goals);
      });
    final discipline = [...players]
      ..sort((a, b) {
        final aScore = a.player.stats.redCards * 4 + a.player.stats.yellowCards;
        final bScore = b.player.stats.redCards * 4 + b.player.stats.yellowCards;
        return bScore.compareTo(aScore);
      });
    final managers = ManagerRankingEngine.rank(career, clubIds: allowed);

    return PremiumScaffold(
      appBar: GameTopBar(
        title: 'Estatísticas',
        subtitle: '${CompetitionCatalog.displayNameFor(series)} • ${career.season}',
      ),
      body: Column(
        children: [
          if (availableSeries.length > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: DropdownButtonFormField<String>(
                initialValue: series.id,
                decoration: const InputDecoration(labelText: 'Competição', isDense: true),
                items: availableSeries
                    .map((item) => DropdownMenuItem(
                          value: item.id,
                          child: Text(CompetitionCatalog.displayNameFor(item)),
                        ))
                    .toList(growable: false),
                onChanged: (value) => setState(() => _selectedSeriesId = value),
              ),
            ),
          TabBar(
            controller: _tabs,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Classificação'),
              Tab(text: 'Jogos'),
              Tab(text: 'Artilheiros'),
              Tab(text: 'Assistências'),
              Tab(text: 'Disciplina'),
              Tab(text: 'Técnicos'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _StandingsTab(standings: standings, clubs: clubs),
                _MatchesTab(fixtures: fixtures, clubs: clubs),
                _PlayerRankingTab(entries: scorers, valueBuilder: (p) => '${p.stats.goals} G', secondaryBuilder: (p) => '${p.stats.assists} A'),
                _PlayerRankingTab(entries: assists, valueBuilder: (p) => '${p.stats.assists} A', secondaryBuilder: (p) => '${p.stats.goals} G'),
                _PlayerRankingTab(entries: discipline, valueBuilder: (p) => '${p.stats.yellowCards} A', secondaryBuilder: (p) => '${p.stats.redCards} V'),
                _ManagersTab(entries: managers, clubs: clubs),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StandingsTab extends StatelessWidget {
  const _StandingsTab({required this.standings, required this.clubs});
  final List<Standing> standings;
  final List<Club> clubs;

  @override
  Widget build(BuildContext context) => ListView.builder(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
        itemCount: standings.length,
        itemBuilder: (context, index) {
          final standing = standings[index];
          final club = clubs.firstWhere((item) => item.id == standing.clubId);
          return SectionCard(
            margin: const EdgeInsets.only(bottom: 7),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: InkWell(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ClubProfileScreen(clubId: club.id))),
              child: Row(children: [
                SizedBox(width: 28, child: Text('${index + 1}º', style: const TextStyle(fontWeight: FontWeight.w900))),
                ClubBadge(club: club, size: 30),
                const SizedBox(width: 9),
                Expanded(child: Text(club.name, style: const TextStyle(fontWeight: FontWeight.w800))),
                Text('${standing.points} pts', style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w900)),
                const SizedBox(width: 9),
                Text('${standing.played}J', style: TextStyle(color: AppColors.muted, fontSize: 11)),
              ]),
            ),
          );
        },
      );
}

class _MatchesTab extends StatelessWidget {
  const _MatchesTab({required this.fixtures, required this.clubs});
  final List<MatchFixture> fixtures;
  final List<Club> clubs;

  @override
  Widget build(BuildContext context) {
    final ordered = [...fixtures]
      ..sort((a, b) {
        if (a.played != b.played) return a.played ? -1 : 1;
        return a.played ? b.date.compareTo(a.date) : a.date.compareTo(b.date);
      });
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
      itemCount: ordered.length,
      itemBuilder: (context, index) {
        final fixture = ordered[index];
        final home = clubs.firstWhere((item) => item.id == fixture.homeClubId);
        final away = clubs.firstWhere((item) => item.id == fixture.awayClubId);
        return SectionCard(
          margin: const EdgeInsets.only(bottom: 7),
          child: InkWell(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CalendarScreen(initialFixtureId: fixture.id))),
            child: Column(children: [
              Text('Rodada ${fixture.round} • ${shortDate(fixture.date)}', style: TextStyle(color: AppColors.muted, fontSize: 11)),
              const SizedBox(height: 7),
              Row(children: [
                Expanded(child: Text(home.name, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w800))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(fixture.score?.display ?? fixture.kickoffLabel, style: const TextStyle(fontWeight: FontWeight.w900)),
                ),
                Expanded(child: Text(away.name, style: const TextStyle(fontWeight: FontWeight.w800))),
              ]),
            ]),
          ),
        );
      },
    );
  }
}

class _PlayerRankingTab extends StatelessWidget {
  const _PlayerRankingTab({required this.entries, required this.valueBuilder, required this.secondaryBuilder});
  final List<({Player player, Club club})> entries;
  final String Function(Player) valueBuilder;
  final String Function(Player) secondaryBuilder;

  @override
  Widget build(BuildContext context) => ListView.builder(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
        itemCount: entries.length > 30 ? 30 : entries.length,
        itemBuilder: (context, index) {
          final item = entries[index];
          return SectionCard(
            margin: const EdgeInsets.only(bottom: 7),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(children: [
              SizedBox(width: 28, child: Text('${index + 1}º', style: const TextStyle(fontWeight: FontWeight.w900))),
              Expanded(
                child: PlayerRow(
                  player: item.player,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlayerProfileScreen(playerId: item.player.id, clubId: item.club.id))),
                  trailing: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(valueBuilder(item.player), style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w900)),
                      Text(secondaryBuilder(item.player), style: TextStyle(color: AppColors.muted, fontSize: 10)),
                    ],
                  ),
                ),
              ),
            ]),
          );
        },
      );
}

class _ManagersTab extends StatelessWidget {
  const _ManagersTab({required this.entries, required this.clubs});
  final List<ManagerRankingEntry> entries;
  final List<Club> clubs;

  @override
  Widget build(BuildContext context) => ListView.builder(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final item = entries[index];
          final club = clubs.firstWhere((candidate) => candidate.id == item.clubId);
          return SectionCard(
            margin: const EdgeInsets.only(bottom: 7),
            child: InkWell(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ClubProfileScreen(clubId: club.id))),
              child: Row(children: [
                SizedBox(width: 30, child: Text('${index + 1}º', style: const TextStyle(fontWeight: FontWeight.w900))),
                ClubBadge(club: club, size: 34),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item.managerName, style: TextStyle(fontWeight: FontWeight.w900, color: item.isUser ? AppColors.green : null)),
                    Text('${club.name} • ${item.position}º • forma ${item.recentFormPoints}/15', style: TextStyle(color: AppColors.muted, fontSize: 11)),
                    if (item.titles > 0 || item.clubImprovement != 0)
                      Text('Títulos ${item.titles} • evolução ${item.clubImprovement >= 0 ? '+' : ''}${item.clubImprovement}', style: TextStyle(color: AppColors.muted, fontSize: 10)),
                  ]),
                ),
                Text(item.score.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w900)),
              ]),
            ),
          );
        },
      );
}
