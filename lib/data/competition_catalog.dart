class CountryCompetition {
  const CountryCompetition({
    required this.id,
    required this.name,
    required this.code,
    required this.championships,
  });

  final String id;
  final String name;
  final String code;
  final List<ChampionshipCompetition> championships;
}

class ChampionshipCompetition {
  const ChampionshipCompetition({
    required this.id,
    required this.name,
    required this.series,
  });

  final String id;
  final String name;
  final List<CompetitionSeries> series;
}

class CompetitionSeries {
  const CompetitionSeries({
    required this.id,
    required this.name,
    required this.clubIds,
    this.displayName,
  });

  final String id;
  final String name;
  final String? displayName;
  final List<String> clubIds;
}

abstract final class CompetitionCatalog {
  static const brazil = CountryCompetition(
    id: 'br',
    name: 'Brasil',
    code: 'BR',
    championships: [
      ChampionshipCompetition(
        id: 'br-national-league',
        name: 'Liga Nacional',
        series: [
          CompetitionSeries(
            id: 'br-series-a',
            name: 'Série A',
            displayName: 'Campeonato Brasileiro Série A',
            clubIds: [
              'br-club-001',
              'br-club-002',
              'br-club-003',
              'br-club-004',
              'br-club-005',
              'br-club-006',
              'br-club-007',
              'br-club-008',
              'br-club-009',
              'br-club-010',
              'br-club-011',
              'br-club-012',
              'br-club-013',
              'br-club-014',
              'br-club-015',
              'br-club-016',
              'br-club-017',
              'br-club-018',
              'br-club-019',
              'br-club-020',
            ],
          ),
        ],
      ),
    ],
  );

  static const countries = [brazil];

  static List<CompetitionSeries> get allSeries => [
        for (final country in countries)
          for (final championship in country.championships)
            ...championship.series,
      ];

  static CompetitionSeries primarySeriesForClub(String clubId) {
    for (final series in allSeries) {
      if (series.clubIds.contains(clubId)) return series;
    }
    return allSeries.first;
  }

  static String displayNameFor(CompetitionSeries series) =>
      series.displayName ?? series.name;

  static CompetitionSeries seriesById(String id) {
    for (final series in allSeries) {
      if (series.id == id) return series;
    }
    return allSeries.first;
  }

  static String displayNameForId(String id) => displayNameFor(seriesById(id));
}
