enum LeagueLoadLevel { full, background, unloaded }

enum CareerWorldPreset { fast, balanced, broad, custom }

class CareerLeagueSetup {
  const CareerLeagueSetup({
    this.preset = CareerWorldPreset.balanced,
    this.competitions = const {},
  });

  final CareerWorldPreset preset;
  final Map<String, LeagueLoadLevel> competitions;

  LeagueLoadLevel levelFor(String competitionId) =>
      competitions[competitionId] ?? LeagueLoadLevel.unloaded;

  bool isLoaded(String competitionId) =>
      levelFor(competitionId) != LeagueLoadLevel.unloaded;

  Iterable<String> get loadedCompetitionIds => competitions.entries
      .where((entry) => entry.value != LeagueLoadLevel.unloaded)
      .map((entry) => entry.key);

  Iterable<String> get fullCompetitionIds => competitions.entries
      .where((entry) => entry.value == LeagueLoadLevel.full)
      .map((entry) => entry.key);

  Iterable<String> get backgroundCompetitionIds => competitions.entries
      .where((entry) => entry.value == LeagueLoadLevel.background)
      .map((entry) => entry.key);

  CareerLeagueSetup copyWith({
    CareerWorldPreset? preset,
    Map<String, LeagueLoadLevel>? competitions,
  }) =>
      CareerLeagueSetup(
        preset: preset ?? this.preset,
        competitions: competitions ?? this.competitions,
      );

  CareerLeagueSetup withLevel(
    String competitionId,
    LeagueLoadLevel level, {
    CareerWorldPreset? preset,
  }) {
    return CareerLeagueSetup(
      preset: preset ?? this.preset,
      competitions: {
        ...competitions,
        competitionId: level,
      },
    );
  }

  CareerLeagueSetup ensureFull(String competitionId) =>
      levelFor(competitionId) == LeagueLoadLevel.full
          ? this
          : withLevel(competitionId, LeagueLoadLevel.full);

  Map<String, dynamic> toJson() => {
        'preset': preset.name,
        'competitions': {
          for (final entry in competitions.entries)
            entry.key: entry.value.name,
        },
      };

  factory CareerLeagueSetup.fromJson(Map<String, dynamic> json) {
    final rawCompetitions = json['competitions'];
    final competitions = <String, LeagueLoadLevel>{};
    if (rawCompetitions is Map) {
      for (final entry in rawCompetitions.entries) {
        final id = entry.key.toString().trim();
        if (id.isEmpty) continue;
        competitions[id] = LeagueLoadLevel.values.firstWhere(
          (value) => value.name == entry.value?.toString(),
          orElse: () => LeagueLoadLevel.unloaded,
        );
      }
    }
    return CareerLeagueSetup(
      preset: CareerWorldPreset.values.firstWhere(
        (value) => value.name == json['preset'],
        orElse: () => CareerWorldPreset.balanced,
      ),
      competitions: competitions,
    );
  }

  factory CareerLeagueSetup.legacy({
    required Iterable<String> competitionIds,
    required String userCompetitionId,
  }) {
    final levels = <String, LeagueLoadLevel>{
      for (final id in competitionIds)
        if (id.trim().isNotEmpty) id: LeagueLoadLevel.full,
    };
    levels[userCompetitionId] = LeagueLoadLevel.full;
    return CareerLeagueSetup(
      preset: CareerWorldPreset.balanced,
      competitions: levels,
    );
  }
}
