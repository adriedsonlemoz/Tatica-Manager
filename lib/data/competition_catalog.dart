enum CompetitionScope {
  nationalLeague,
  regionalLeague,
  domesticCup,
  continental,
  world,
}

enum CompetitionFormat {
  leagueDoubleRoundRobin,
  leagueSingleRoundRobin,
  knockout,
  groupAndKnockout,
  singleMatch,
}

extension CompetitionFormatX on CompetitionFormat {
  bool get hasLeagueTable => switch (this) {
        CompetitionFormat.leagueDoubleRoundRobin ||
        CompetitionFormat.leagueSingleRoundRobin => true,
        _ => false,
      };

  bool get hasAutomaticSchedule => switch (this) {
        CompetitionFormat.leagueDoubleRoundRobin ||
        CompetitionFormat.leagueSingleRoundRobin => true,
        _ => false,
      };
}

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

/// Definição de competição disponível na instalação.
///
/// O nome histórico `CompetitionSeries` é preservado para não quebrar a
/// navegação/editor existentes. Os campos [scope] e [format] tornam a mesma
/// definição apta a representar futuramente ligas nacionais/regionais e a
/// conviver no catálogo com copas, torneios continentais e mundiais sem
/// alterar IDs já persistidos.
class CompetitionSeries {
  const CompetitionSeries({
    required this.id,
    required this.name,
    required this.clubIds,
    this.displayName,
    this.scope = CompetitionScope.nationalLeague,
    this.format = CompetitionFormat.leagueDoubleRoundRobin,
    this.calendarPriority = 100,
    this.calendarStartMonth = 4,
    this.calendarStartDay = 12,
  });

  final String id;
  final String name;
  final String? displayName;
  final List<String> clubIds;
  final CompetitionScope scope;
  final CompetitionFormat format;

  /// Menor número = maior prioridade ao conciliar datas entre torneios.
  /// A definição atual usa um único valor; futuros calendários podem priorizar
  /// finais/copas sem mover essa responsabilidade para a UI.
  final int calendarPriority;

  /// Janela inicial usada pelos geradores automáticos. Competições com regras
  /// próprias (copas/grupos) podem ignorar estes campos quando tiverem seu
  /// gerador específico.
  final int calendarStartMonth;
  final int calendarStartDay;
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

  /// Torneios que não pertencem a um único país, como competições
  /// continentais ou mundiais. A lista permanece vazia até os dados reais
  /// serem cadastrados; ela existe para evitar encaixar Libertadores/Mundial
  /// artificialmente dentro do catálogo de um país.
  static const List<CompetitionSeries> internationalCompetitions = [];

  /// Competições domésticas organizadas por país. O nome histórico é mantido
  /// por compatibilidade com editor e navegação já existentes.
  static List<CompetitionSeries> get allSeries => [
        for (final country in countries)
          for (final championship in country.championships)
            ...championship.series,
      ];

  static List<CompetitionSeries> get allCompetitions => [
        ...allSeries,
        ...internationalCompetitions,
      ];

  static CompetitionSeries primarySeriesForClub(String clubId) {
    final national = allCompetitions.where(
      (competition) =>
          competition.scope == CompetitionScope.nationalLeague &&
          competition.clubIds.contains(clubId),
    );
    if (national.isNotEmpty) return national.first;
    for (final competition in allCompetitions) {
      if (competition.clubIds.contains(clubId)) return competition;
    }
    return allCompetitions.first;
  }

  static String displayNameFor(CompetitionSeries series) =>
      series.displayName ?? series.name;

  static CompetitionSeries? competitionByIdOrNull(String id) {
    for (final competition in allCompetitions) {
      if (competition.id == id) return competition;
    }
    return null;
  }

  static CompetitionSeries seriesById(String id) =>
      competitionByIdOrNull(id) ?? allCompetitions.first;

  static String displayNameForId(String id) {
    final competition = competitionByIdOrNull(id);
    return competition == null ? id : displayNameFor(competition);
  }
}
