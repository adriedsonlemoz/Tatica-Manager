import '../../domain/season/career_state.dart';

class ManagerRankingEntry {
  const ManagerRankingEntry({
    required this.clubId,
    required this.managerName,
    required this.score,
    required this.position,
    required this.recentFormPoints,
    required this.titles,
    required this.clubImprovement,
    required this.isUser,
  });

  final String clubId;
  final String managerName;
  final double score;
  final int position;
  final int recentFormPoints;
  final int titles;
  final int clubImprovement;
  final bool isUser;
}

class ManagerRankingEngine {
  const ManagerRankingEngine._();

  static List<ManagerRankingEntry> rank(
    CareerState state, {
    Set<String>? clubIds,
  }) {
    final allowed = clubIds ?? state.clubs.map((club) => club.id).toSet();
    final standings = state.standings.where((item) => allowed.contains(item.clubId)).toList()
      ..sort((a, b) {
        final points = b.points.compareTo(a.points);
        if (points != 0) return points;
        final gd = b.goalDifference.compareTo(a.goalDifference);
        if (gd != 0) return gd;
        return b.goalsFor.compareTo(a.goalsFor);
      });

    final entries = <ManagerRankingEntry>[];
    for (var index = 0; index < standings.length; index++) {
      final standing = standings[index];
      final club = state.clubs.firstWhere((item) => item.id == standing.clubId);
      final isUser = club.id == state.userClubId;
      final recent = state.fixtures
          .where((fixture) =>
              fixture.played &&
              fixture.score != null &&
              (fixture.homeClubId == club.id || fixture.awayClubId == club.id))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      var formPoints = 0;
      for (final fixture in recent.take(5)) {
        final home = fixture.homeClubId == club.id;
        final own = home ? fixture.score!.home : fixture.score!.away;
        final opponent = home ? fixture.score!.away : fixture.score!.home;
        if (own > opponent) {
          formPoints += 3;
        } else if (own == opponent) {
          formPoints += 1;
        }
      }

      final titles = isUser
          ? state.seasonHistory.where((item) => item.position == 1).length
          : 0;
      final lastSeason = isUser
          ? state.seasonHistory.where((item) => item.clubId == club.id).lastOrNull
          : null;
      final improvement = lastSeason == null ? 0 : lastSeason.position - (index + 1);
      final score = standing.points * 2.0 +
          standing.wins * 1.5 +
          standing.goalDifference * .25 +
          formPoints * 1.8 +
          (standings.length - index) * 1.4 +
          titles * 12 +
          improvement * 2.5;
      entries.add(
        ManagerRankingEntry(
          clubId: club.id,
          managerName: isUser ? state.manager.preferredName : club.managerName,
          score: score,
          position: index + 1,
          recentFormPoints: formPoints,
          titles: titles,
          clubImprovement: improvement,
          isUser: isUser,
        ),
      );
    }
    entries.sort((a, b) => b.score.compareTo(a.score));
    return entries;
  }
}
