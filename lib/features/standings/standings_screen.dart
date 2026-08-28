import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/widgets/common.dart';
import '../../core/theme/app_colors.dart';
import '../../data/competition_catalog.dart';
import '../../game/league/league_engine.dart';
import '../clubs/club_profile_screen.dart';

class StandingsScreen extends ConsumerStatefulWidget {
  const StandingsScreen({super.key});

  @override
  ConsumerState<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends ConsumerState<StandingsScreen> {
  static const _continentalSecondary = Color(0xFF55A8FF);
  String? _selectedSeriesId;

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
    final competitionName = CompetitionCatalog.displayNameFor(series);
    final seriesClubIds = series.clubIds.toSet();
    final seriesClubs = career.clubs
        .where((club) => seriesClubIds.contains(club.id))
        .toList(growable: false);
    final seriesFixtures = career.fixtures
        .where(
          (fixture) =>
              seriesClubIds.contains(fixture.homeClubId) &&
              seriesClubIds.contains(fixture.awayClubId),
        )
        .toList(growable: false);
    final movements = LeagueEngine.positionMovement(
      seriesClubs.isEmpty ? career.clubs : seriesClubs,
      seriesFixtures.isEmpty ? career.fixtures : seriesFixtures,
    );
    final filtered = career.standings
        .where((standing) => series.clubIds.contains(standing.clubId))
        .toList(growable: false);
    final standings = filtered.isEmpty ? career.standings : filtered;

    return PremiumScaffold(
      appBar: GameTopBar(
        title: competitionName,
        subtitle:
            'Classificação • Temporada ${career.season} • após ${career.roundIndex} rodada(s)',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionCard(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.emoji_events_rounded,
                        size: 18,
                        color: AppColors.green,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          competitionName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (availableSeries.length > 1) ...[
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
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
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            SectionCard(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 14,
                  horizontalMargin: 8,
                  columns: const [
                    DataColumn(label: Text('#')),
                    DataColumn(label: Text('Clube')),
                    DataColumn(label: Text('PTS')),
                    DataColumn(label: Text('J')),
                    DataColumn(label: Text('V')),
                    DataColumn(label: Text('E')),
                    DataColumn(label: Text('D')),
                    DataColumn(label: Text('GP')),
                    DataColumn(label: Text('GC')),
                    DataColumn(label: Text('SG')),
                  ],
                  rows: standings.asMap().entries.map((entry) {
                    final standing = entry.value;
                    final club = career.clubs.firstWhere(
                      (item) => item.id == standing.clubId,
                    );
                    final isUser = club.id == career.userClubId;
                    final zone = _zoneColor(entry.key);
                    final movement = movements[standing.clubId] ?? 0;
                    return DataRow(
                      color: WidgetStatePropertyAll(
                        isUser
                            ? AppColors.green.withValues(alpha: .10)
                            : zone?.withValues(alpha: .045),
                      ),
                      cells: [
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 4,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: zone ?? AppColors.border,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 7),
                              SizedBox(
                                width: 23,
                                child: Text(
                                  '${entry.key + 1}',
                                  style: TextStyle(
                                    color: zone ?? Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              _MovementIndicator(movement: movement),
                            ],
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              ClubBadge(club: club, size: 26),
                              const SizedBox(width: 7),
                              SizedBox(
                                width: 122,
                                child: Text(
                                  club.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight:
                                        isUser ? FontWeight.w900 : FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ClubProfileScreen(clubId: club.id),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            '${standing.points}',
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                        DataCell(Text('${standing.played}')),
                        DataCell(Text('${standing.wins}')),
                        DataCell(Text('${standing.draws}')),
                        DataCell(Text('${standing.losses}')),
                        DataCell(Text('${standing.goalsFor}')),
                        DataCell(Text('${standing.goalsAgainst}')),
                        DataCell(
                          Text(
                            '${standing.goalDifference > 0 ? '+' : ''}${standing.goalDifference}',
                          ),
                        ),
                      ],
                    );
                  }).toList(growable: false),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Expanded(
                  child: _ZoneChip(
                    color: AppColors.green,
                    title: 'Libertadores',
                    positions: '1º–4º',
                  ),
                ),
                SizedBox(width: 6),
                Expanded(
                  child: _ZoneChip(
                    color: _continentalSecondary,
                    title: 'Sul-Americana',
                    positions: '5º–12º',
                  ),
                ),
                SizedBox(width: 6),
                Expanded(
                  child: _ZoneChip(
                    color: AppColors.danger,
                    title: 'Rebaixamento',
                    positions: '17º–20º',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Color? _zoneColor(int zeroBasedPosition) {
    if (zeroBasedPosition < 4) return AppColors.green;
    if (zeroBasedPosition < 12) return _continentalSecondary;
    if (zeroBasedPosition >= 16) return AppColors.danger;
    return null;
  }
}

class _MovementIndicator extends StatelessWidget {
  const _MovementIndicator({required this.movement});

  final int movement;

  @override
  Widget build(BuildContext context) {
    final up = movement > 0;
    final down = movement < 0;
    final color = up
        ? AppColors.green
        : down
            ? AppColors.danger
            : AppColors.muted;
    final icon = up
        ? Icons.arrow_drop_up_rounded
        : down
            ? Icons.arrow_drop_down_rounded
            : Icons.remove_rounded;
    return SizedBox(
      width: 28,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          if (movement != 0)
            Text(
              '${movement.abs()}',
              style: TextStyle(
                color: color,
                fontSize: 8.5,
                fontWeight: FontWeight.w900,
              ),
            ),
        ],
      ),
    );
  }
}

class _ZoneChip extends StatelessWidget {
  const _ZoneChip({
    required this.color,
    required this.title,
    required this.positions,
  });

  final Color color;
  final String title;
  final String positions;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: .28)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              '$title • $positions',
              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      );
}
