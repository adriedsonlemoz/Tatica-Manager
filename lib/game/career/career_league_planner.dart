import '../../data/competition_catalog.dart';
import '../../domain/season/league_loading.dart';

enum CareerPerformanceEstimate { fast, normal, heavy }

abstract final class CareerLeaguePlanner {
  static CareerLeagueSetup forPreset({
    required String userClubId,
    CareerWorldPreset preset = CareerWorldPreset.balanced,
  }) {
    final userSeries = CompetitionCatalog.primarySeriesForClub(userClubId);
    final allSeries = CompetitionCatalog.allSeries;
    final levels = <String, LeagueLoadLevel>{
      for (final series in allSeries) series.id: LeagueLoadLevel.unloaded,
    };

    switch (preset) {
      case CareerWorldPreset.fast:
        break;
      case CareerWorldPreset.balanced:
        final others = allSeries
            .where((series) => series.id != userSeries.id)
            .toList(growable: false);
        if (others.isNotEmpty) {
          levels[others.first.id] = LeagueLoadLevel.full;
        }
        for (final series in others.skip(1).take(2)) {
          levels[series.id] = LeagueLoadLevel.background;
        }
        break;
      case CareerWorldPreset.broad:
        for (final series in allSeries) {
          levels[series.id] = LeagueLoadLevel.full;
        }
        break;
      case CareerWorldPreset.custom:
        break;
    }

    levels[userSeries.id] = LeagueLoadLevel.full;
    return CareerLeagueSetup(preset: preset, competitions: levels);
  }

  static CareerLeagueSetup normalize({
    required CareerLeagueSetup setup,
    required String userClubId,
  }) {
    final userSeries = CompetitionCatalog.primarySeriesForClub(userClubId);
    final knownIds = CompetitionCatalog.allSeries.map((series) => series.id).toSet();
    return CareerLeagueSetup(
      preset: setup.preset,
      competitions: {
        for (final id in knownIds)
          id: id == userSeries.id
              ? LeagueLoadLevel.full
              : setup.levelFor(id),
      },
    );
  }

  static CareerLeagueSetup asCustom({
    required CareerLeagueSetup setup,
    required String userClubId,
  }) =>
      normalize(
        setup: setup.copyWith(preset: CareerWorldPreset.custom),
        userClubId: userClubId,
      );

  static Set<String> activeClubIds(CareerLeagueSetup setup) {
    final loadedIds = setup.loadedCompetitionIds.toSet();
    return {
      for (final series in CompetitionCatalog.allSeries)
        if (loadedIds.contains(series.id)) ...series.clubIds,
    };
  }

  static CareerPerformanceEstimate performanceEstimate(
    CareerLeagueSetup setup,
  ) {
    var weight = 0;
    for (final level in setup.competitions.values) {
      weight += switch (level) {
        LeagueLoadLevel.full => 3,
        LeagueLoadLevel.background => 1,
        LeagueLoadLevel.unloaded => 0,
      };
    }
    if (weight <= 4) return CareerPerformanceEstimate.fast;
    if (weight <= 12) return CareerPerformanceEstimate.normal;
    return CareerPerformanceEstimate.heavy;
  }
}
