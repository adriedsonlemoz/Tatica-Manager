import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/widgets/common.dart';
import '../../app/widgets/player_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/competition_catalog.dart';
import '../../domain/club/club.dart';
import '../../domain/league/standing.dart';
import '../../domain/match/match_models.dart';
import '../../domain/player/player.dart';
import '../../game/league/league_engine.dart';
import '../calendar/calendar_screen.dart';
import '../clubs/club_profile_screen.dart';
import '../player/player_profile_screen.dart';

class StandingsScreen extends ConsumerStatefulWidget {
  const StandingsScreen({super.key});

  @override
  ConsumerState<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends ConsumerState<StandingsScreen> {
  String? _selectedSeriesId;
  _CompetitionView _view = _CompetitionView.table;

  @override
  Widget build(BuildContext context) {
    final career = ref.watch(gameControllerProvider).career!;
    final availableSeries = career.competitionStates
        .map(
          (state) =>
              CompetitionCatalog.competitionByIdOrNull(state.competitionId),
        )
        .whereType<CompetitionSeries>()
        .toList(growable: false);
    final fallback = CompetitionCatalog.seriesById(career.primaryCompetitionId);
    final series = availableSeries.firstWhere(
      (item) => item.id == _selectedSeriesId,
      orElse: () => availableSeries.isEmpty ? fallback : availableSeries.first,
    );
    final competitionName = CompetitionCatalog.displayNameFor(series);
    final competitionState = career.competitionStateFor(series.id);
    final participantIds = competitionState.participantClubIds.toSet();
    final clubs = career.clubs
        .where((club) => participantIds.contains(club.id))
        .toList(growable: false);
    final fixtures = career.fixturesForCompetition(series.id);
    final movements = LeagueEngine.positionMovement(clubs, fixtures);
    final scorers = <({Player player, Club club, PlayerSeasonStats stats})>[
      for (final club in clubs)
        for (final player in club.squad)
          (
            player: player,
            club: club,
            stats: competitionState.statsForPlayer(player.id),
          ),
    ]..sort((a, b) {
        final goals = b.stats.goals.compareTo(a.stats.goals);
        if (goals != 0) return goals;
        final assists = b.stats.assists.compareTo(a.stats.assists);
        if (assists != 0) return assists;
        return a.player.displayName.compareTo(b.player.displayName);
      });

    return PremiumScaffold(
      appBar: AppBar(title: Text(competitionName)),
      body: Column(
        children: [
          _CompetitionTabs(
            selected: _view,
            onSelected: (value) => setState(() => _view = value),
          ),
          if (availableSeries.length > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: DropdownButtonFormField<String>(
                initialValue: series.id,
                decoration: const InputDecoration(
                  labelText: 'Competição',
                  isDense: true,
                ),
                items: availableSeries
                    .map(
                      (item) => DropdownMenuItem(
                        value: item.id,
                        child: Text(CompetitionCatalog.displayNameFor(item)),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) => setState(() => _selectedSeriesId = value),
              ),
            ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: switch (_view) {
                _CompetitionView.table => _TableView(
                    key: const ValueKey('table'),
                    standings: competitionState.standings,
                    clubs: clubs,
                    movements: movements,
                    userClubId: career.userClubId,
                    season: career.season,
                    series: series,
                    goals: competitionState.standings.fold<int>(
                      0,
                      (total, row) => total + row.goalsFor,
                    ),
                  ),
                _CompetitionView.matches => _MatchesView(
                    key: const ValueKey('matches'),
                    fixtures: fixtures,
                    clubs: clubs,
                  ),
                _CompetitionView.scorers => _ScorersView(
                    key: const ValueKey('scorers'),
                    entries: scorers,
                  ),
              },
            ),
          ),
        ],
      ),
    );
  }
}

enum _CompetitionView { table, matches, scorers }

extension on _CompetitionView {
  String get label => switch (this) {
        _CompetitionView.table => 'Tabela',
        _CompetitionView.matches => 'Jogos',
        _CompetitionView.scorers => 'Artilheiros',
      };
}

class _CompetitionTabs extends StatelessWidget {
  const _CompetitionTabs({required this.selected, required this.onSelected});

  final _CompetitionView selected;
  final ValueChanged<_CompetitionView> onSelected;

  @override
  Widget build(BuildContext context) => Container(
        color: AppColors.surface,
        child: Row(
          children: [
            for (final item in _CompetitionView.values)
              Expanded(
                child: InkWell(
                  onTap: () => onSelected(item),
                  child: Column(
                    children: [
                      const SizedBox(height: 18),
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
                      const SizedBox(height: 14),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        height: 3,
                        color: item == selected
                            ? AppColors.green
                            : Colors.transparent,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
}

class _TableView extends StatelessWidget {
  const _TableView({
    super.key,
    required this.standings,
    required this.clubs,
    required this.movements,
    required this.userClubId,
    required this.season,
    required this.series,
    required this.goals,
  });

  final List<Standing> standings;
  final List<Club> clubs;
  final Map<String, int> movements;
  final String userClubId;
  final int season;
  final CompetitionSeries series;
  final int goals;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(10, 12, 10, 28),
        children: [
          _StandingsTable(
            standings: standings,
            clubs: clubs,
            movements: movements,
            userClubId: userClubId,
            showSerieAZones: series.id == 'br-series-a',
          ),
          const SizedBox(height: 10),
          _CompetitionAbout(
            name: CompetitionCatalog.displayNameFor(series),
            season: season,
            format: _formatLabel(series.format),
            participants: clubs.length,
            goals: goals,
          ),
          const SizedBox(height: 10),
          const _TiebreakerCard(),
        ],
      );

  static String _formatLabel(CompetitionFormat format) => switch (format) {
        CompetitionFormat.leagueDoubleRoundRobin => 'Pontos corridos',
        CompetitionFormat.leagueSingleRoundRobin => 'Turno único',
        CompetitionFormat.knockout => 'Mata-mata',
        CompetitionFormat.groupAndKnockout => 'Grupos e mata-mata',
        CompetitionFormat.singleMatch => 'Jogo único',
      };
}

class _StandingsTable extends StatelessWidget {
  const _StandingsTable({
    required this.standings,
    required this.clubs,
    required this.movements,
    required this.userClubId,
    required this.showSerieAZones,
  });

  final List<Standing> standings;
  final List<Club> clubs;
  final Map<String, int> movements;
  final String userClubId;
  final bool showSerieAZones;

  @override
  Widget build(BuildContext context) => Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            const _StandingsHeader(),
            for (final entry in standings.asMap().entries)
              _StandingsRow(
                position: entry.key + 1,
                standing: entry.value,
                club: clubs.firstWhere((club) => club.id == entry.value.clubId),
                movement: movements[entry.value.clubId] ?? 0,
                isUser: entry.value.clubId == userClubId,
                zoneColor: showSerieAZones ? _zoneColor(entry.key) : null,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        ClubProfileScreen(clubId: entry.value.clubId),
                  ),
                ),
              ),
          ],
        ),
      );

  static Color? _zoneColor(int index) {
    if (index < 4) return AppColors.green;
    if (index < 12) return const Color(0xFF55A8FF);
    if (index >= 16) return AppColors.danger;
    return null;
  }
}

class _StandingsHeader extends StatelessWidget {
  const _StandingsHeader();

  @override
  Widget build(BuildContext context) => Container(
        height: 48,
        padding: const EdgeInsets.only(right: 7),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: const Row(
          children: [
            SizedBox(width: 37, child: _TableLabel('#')),
            Expanded(child: _TableLabel('TIME')),
            _StatLabel('J'),
            _StatLabel('V'),
            _StatLabel('E'),
            _StatLabel('D'),
            _StatLabel('GP'),
            _StatLabel('PTS'),
          ],
        ),
      );
}

class _TableLabel extends StatelessWidget {
  const _TableLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          color: AppColors.muted,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
        ),
      );
}

class _StatLabel extends StatelessWidget {
  const _StatLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 31,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.muted,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
}

class _StandingsRow extends StatelessWidget {
  const _StandingsRow({
    required this.position,
    required this.standing,
    required this.club,
    required this.movement,
    required this.isUser,
    required this.zoneColor,
    required this.onTap,
  });

  final int position;
  final Standing standing;
  final Club club;
  final int movement;
  final bool isUser;
  final Color? zoneColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: isUser
            ? AppColors.green.withValues(alpha: AppColors.isDarkMode ? .10 : .08)
            : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 61,
            padding: const EdgeInsets.only(right: 7),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: double.infinity,
                  color: zoneColor ?? Colors.transparent,
                ),
                SizedBox(
                  width: 34,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Text(
                        '$position',
                        style: TextStyle(
                          color: isUser ? AppColors.green : null,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (movement != 0)
                        Positioned(
                          bottom: 7,
                          left: 13,
                          child: Icon(
                            movement > 0
                                ? Icons.arrow_drop_up_rounded
                                : Icons.arrow_drop_down_rounded,
                            color: movement > 0
                                ? AppColors.green
                                : AppColors.danger,
                            size: 14,
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      ClubBadge(club: club, size: 35),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          club.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isUser ? AppColors.green : null,
                            fontSize: 12,
                            fontWeight:
                                isUser ? FontWeight.w900 : FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
                _StatValue(standing.played),
                _StatValue(standing.wins),
                _StatValue(standing.draws),
                _StatValue(standing.losses),
                _StatValue(standing.goalsFor),
                _StatValue(standing.points, points: true),
              ],
            ),
          ),
        ),
      );
}

class _StatValue extends StatelessWidget {
  const _StatValue(this.value, {this.points = false});

  final int value;
  final bool points;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 31,
        child: Text(
          '$value',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: points ? AppColors.green : null,
            fontSize: 12,
            fontWeight: points ? FontWeight.w900 : FontWeight.w600,
          ),
        ),
      );
}

class _CompetitionAbout extends StatelessWidget {
  const _CompetitionAbout({
    required this.name,
    required this.season,
    required this.format,
    required this.participants,
    required this.goals,
  });

  final String name;
  final int season;
  final String format;
  final int participants;
  final int goals;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(12, 13, 12, 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SOBRE O CAMPEONATO',
              style: TextStyle(
                color: AppColors.green,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 11),
            Row(
              children: [
                Expanded(
                  child: _AboutItem(
                    icon: Icons.emoji_events_rounded,
                    title: name,
                    value: 'Temporada $season',
                  ),
                ),
                const _AboutDivider(),
                Expanded(
                  child: _AboutItem(
                    icon: Icons.calendar_month_rounded,
                    title: 'Formato',
                    value: format,
                  ),
                ),
                const _AboutDivider(),
                Expanded(
                  child: _AboutItem(
                    icon: Icons.groups_2_rounded,
                    title: 'Participantes',
                    value: '$participants clubes',
                  ),
                ),
                const _AboutDivider(),
                Expanded(
                  child: _AboutItem(
                    icon: Icons.sports_soccer_rounded,
                    title: 'Gols marcados',
                    value: '$goals',
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

class _AboutDivider extends StatelessWidget {
  const _AboutDivider();

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 64, color: AppColors.border);
}

class _AboutItem extends StatelessWidget {
  const _AboutItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Icon(icon, color: AppColors.green, size: 25),
            const SizedBox(height: 7),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, fontSize: 10.5),
            ),
          ],
        ),
      );
}

class _TiebreakerCard extends StatelessWidget {
  const _TiebreakerCard();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.star_border_rounded, color: AppColors.green, size: 27),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Critérios de desempate',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '1º Pontos • 2º Vitórias • 3º Saldo de gols • 4º Gols pró',
                    style: TextStyle(color: AppColors.muted, fontSize: 10.5),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.muted),
          ],
        ),
      );
}

class _MatchesView extends StatelessWidget {
  const _MatchesView({super.key, required this.fixtures, required this.clubs});

  final List<MatchFixture> fixtures;
  final List<Club> clubs;

  @override
  Widget build(BuildContext context) {
    final ordered = [...fixtures]
      ..sort((a, b) {
        if (a.played != b.played) return a.played ? -1 : 1;
        return a.played ? b.date.compareTo(a.date) : a.date.compareTo(b.date);
      });
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 28),
      itemCount: ordered.length,
      separatorBuilder: (_, _) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final fixture = ordered[index];
        final home = clubs.firstWhere((club) => club.id == fixture.homeClubId);
        final away = clubs.firstWhere((club) => club.id == fixture.awayClubId);
        return _MatchRow(
          fixture: fixture,
          home: home,
          away: away,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CalendarScreen(initialFixtureId: fixture.id),
            ),
          ),
        );
      },
    );
  }
}

class _MatchRow extends StatelessWidget {
  const _MatchRow({
    required this.fixture,
    required this.home,
    required this.away,
    required this.onTap,
  });

  final MatchFixture fixture;
  final Club home;
  final Club away;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Text(
                  'Rodada ${fixture.round} • ${shortDate(fixture.date)}',
                  style: TextStyle(color: AppColors.muted, fontSize: 10.5),
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              home.shortName,
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                          const SizedBox(width: 7),
                          ClubBadge(club: home, size: 34),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 68,
                      child: Text(
                        fixture.score?.display ?? fixture.kickoffLabel,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          ClubBadge(club: away, size: 34),
                          const SizedBox(width: 7),
                          Flexible(
                            child: Text(
                              away.shortName,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w800),
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
        ),
      );
}

class _ScorersView extends StatelessWidget {
  const _ScorersView({super.key, required this.entries});

  final List<({Player player, Club club, PlayerSeasonStats stats})> entries;

  @override
  Widget build(BuildContext context) {
    final visible = entries.where((entry) => entry.stats.goals > 0).toList();
    if (visible.isEmpty) {
      return Center(
        child: Text(
          'A artilharia aparecerá após os primeiros gols.',
          style: TextStyle(color: AppColors.muted),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 28),
      itemCount: visible.length,
      separatorBuilder: (_, _) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final entry = visible[index];
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    PlayerProfileScreen(playerId: entry.player.id),
              ),
            ),
            borderRadius: BorderRadius.circular(12),
            child: Ink(
              height: 68,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 28,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  PlayerAvatar(
                    player: entry.player,
                    size: 45,
                    accentColor: Color(entry.club.colors.primaryHex),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.player.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          entry.club.shortName,
                          style: TextStyle(color: AppColors.muted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${entry.stats.goals}',
                    style: const TextStyle(
                      color: AppColors.green,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'gols',
                    style: TextStyle(color: AppColors.muted, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
