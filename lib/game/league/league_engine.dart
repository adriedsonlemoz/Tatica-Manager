import '../../domain/club/club.dart';
import '../../domain/league/standing.dart';
import '../../domain/match/match_models.dart';

class LeagueScheduleReport {
  const LeagueScheduleReport({
    required this.rounds,
    required this.matches,
    required this.errors,
  });

  final int rounds;
  final int matches;
  final List<String> errors;
  bool get isValid => errors.isEmpty;
}

abstract final class LeagueEngine {
  static const int minimumRestDays = 2;
  static const List<int> defaultRoundGapDays = [7, 6, 8, 5, 9, 4, 7, 6, 8, 5, 7, 10];

  static DateTime firstMatchDate(int season) => DateTime(season, 4, 12);

  static List<MatchFixture> generateDoubleRoundRobin(
    List<Club> clubs, {
    required int season,
    String competitionId = 'br-series-a',
    List<int> roundGapDays = defaultRoundGapDays,
    DateTime? startDate,
  }) {
    if (clubs.length < 2 || clubs.length.isOdd) return const [];
    if (roundGapDays.isEmpty || roundGapDays.any((gap) => gap <= minimumRestDays)) {
      throw ArgumentError(
        'O calendário precisa preservar pelo menos $minimumRestDays dias de descanso.',
      );
    }

    final rotating = clubs.map((club) => club.id).toList(growable: true);
    final firstHalf = <MatchFixture>[];
    final matchesPerRound = clubs.length ~/ 2;
    final totalRounds = (clubs.length - 1) * 2;
    final roundDates = _roundDates(
      startDate ?? firstMatchDate(season),
      totalRounds,
      roundGapDays,
    );

    for (var roundIndex = 0; roundIndex < clubs.length - 1; roundIndex++) {
      final round = roundIndex + 1;
      final roundDate = roundDates[roundIndex];
      for (var matchIndex = 0; matchIndex < matchesPerRound; matchIndex++) {
        var home = rotating[matchIndex];
        var away = rotating[rotating.length - 1 - matchIndex];
        if (roundIndex.isEven && matchIndex == 0) {
          final swap = home;
          home = away;
          away = swap;
        }
        final kickoff = _kickoffFor(roundDate, matchIndex);
        firstHalf.add(
          MatchFixture(
            id: _fixtureId(
              competitionId,
              season,
              round,
              matchIndex + 1,
            ),
            round: round,
            homeClubId: home,
            awayClubId: away,
            date: roundDate,
            competitionId: competitionId,
            kickoffHour: kickoff.$1,
            kickoffMinute: kickoff.$2,
          ),
        );
      }
      final last = rotating.removeLast();
      rotating.insert(1, last);
    }

    final secondHalf = <MatchFixture>[];
    for (final fixture in firstHalf) {
      final round = fixture.round + clubs.length - 1;
      final matchIndex = secondHalf.where((m) => m.round == round).length + 1;
      final roundDate = roundDates[round - 1];
      final kickoff = _kickoffFor(roundDate, matchIndex - 1);
      secondHalf.add(
        MatchFixture(
          id: _fixtureId(competitionId, season, round, matchIndex),
          round: round,
          homeClubId: fixture.awayClubId,
          awayClubId: fixture.homeClubId,
          date: roundDate,
          competitionId: competitionId,
          kickoffHour: kickoff.$1,
          kickoffMinute: kickoff.$2,
        ),
      );
    }

    return [...firstHalf, ...secondHalf];
  }


  static String _fixtureId(
    String competitionId,
    int season,
    int round,
    int match,
  ) {
    // Mantém exatamente os IDs históricos da Série A já persistidos. Novas
    // competições recebem prefixo para não colidir com jogos da mesma temporada.
    final legacyPrefix = competitionId == 'br-series-a' ? '' : '$competitionId-';
    return '$legacyPrefix$season-r$round-m$match';
  }

  static List<DateTime> _roundDates(
    DateTime firstDate,
    int totalRounds,
    List<int> gapPattern,
  ) {
    final dates = <DateTime>[firstDate];
    while (dates.length < totalRounds) {
      final gap = gapPattern[(dates.length - 1) % gapPattern.length];
      dates.add(dates.last.add(Duration(days: gap)));
    }
    return dates;
  }

  static (int, int) _kickoffFor(DateTime date, int matchIndex) {
    late final List<(int, int)> options;
    if (date.weekday == DateTime.saturday) {
      options = const [(16, 0), (18, 30), (21, 0)];
    } else if (date.weekday == DateTime.sunday) {
      options = const [(16, 0), (18, 30), (20, 30)];
    } else if (date.weekday == DateTime.wednesday ||
        date.weekday == DateTime.thursday) {
      options = const [(19, 0), (19, 30), (21, 30)];
    } else if (date.weekday == DateTime.friday) {
      options = const [(19, 0), (20, 0), (21, 0)];
    } else {
      options = const [(19, 0), (20, 0), (21, 0)];
    }
    return options[matchIndex % options.length];
  }

  static List<Standing> initialStandings(List<Club> clubs) => clubs
      .map((club) => Standing(clubId: club.id, clubName: club.name))
      .toList(growable: false);

  static Map<String, int> positionMovement(
    List<Club> clubs,
    List<MatchFixture> fixtures,
  ) {
    final played = fixtures.where((fixture) => fixture.played).toList();
    if (played.isEmpty) return {for (final club in clubs) club.id: 0};
    final latestRound = played.map((fixture) => fixture.round).reduce((a, b) => a > b ? a : b);
    if (latestRound <= 1) return {for (final club in clubs) club.id: 0};

    final current = rebuildStandings(
      clubs,
      fixtures.where((fixture) => fixture.played && fixture.round <= latestRound).toList(),
    );
    final previous = rebuildStandings(
      clubs,
      fixtures.where((fixture) => fixture.played && fixture.round < latestRound).toList(),
    );
    final previousPosition = <String, int>{
      for (var index = 0; index < previous.length; index++)
        previous[index].clubId: index + 1,
    };
    return {
      for (var index = 0; index < current.length; index++)
        current[index].clubId:
            (previousPosition[current[index].clubId] ?? index + 1) - (index + 1),
    };
  }

  static List<Standing> rebuildStandings(List<Club> clubs, List<MatchFixture> fixtures) {
    final rows = <String, Standing>{
      for (final club in clubs) club.id: Standing(clubId: club.id, clubName: club.name),
    };

    for (final fixture in fixtures.where((fixture) => fixture.played && fixture.score != null)) {
      final home = rows[fixture.homeClubId];
      final away = rows[fixture.awayClubId];
      final score = fixture.score;
      if (home == null || away == null || score == null) continue;

      var nextHome = home.copyWith(
        played: home.played + 1,
        goalsFor: home.goalsFor + score.home,
        goalsAgainst: home.goalsAgainst + score.away,
      );
      var nextAway = away.copyWith(
        played: away.played + 1,
        goalsFor: away.goalsFor + score.away,
        goalsAgainst: away.goalsAgainst + score.home,
      );

      if (score.home > score.away) {
        nextHome = nextHome.copyWith(wins: nextHome.wins + 1, points: nextHome.points + 3);
        nextAway = nextAway.copyWith(losses: nextAway.losses + 1);
      } else if (score.away > score.home) {
        nextAway = nextAway.copyWith(wins: nextAway.wins + 1, points: nextAway.points + 3);
        nextHome = nextHome.copyWith(losses: nextHome.losses + 1);
      } else {
        nextHome = nextHome.copyWith(draws: nextHome.draws + 1, points: nextHome.points + 1);
        nextAway = nextAway.copyWith(draws: nextAway.draws + 1, points: nextAway.points + 1);
      }

      rows[home.clubId] = nextHome;
      rows[away.clubId] = nextAway;
    }

    final sorted = rows.values.toList()..sort(_comparePrimary);
    final output = <Standing>[];
    var index = 0;
    while (index < sorted.length) {
      final first = sorted[index];
      var end = index + 1;
      while (end < sorted.length && _primaryKey(sorted[end]) == _primaryKey(first)) {
        end++;
      }
      final tied = sorted.sublist(index, end);
      if (tied.length == 2) {
        final direct = _compareHeadToHead(tied.first, tied.last, fixtures);
        if (direct > 0) {
          final tmp = tied[0];
          tied[0] = tied[1];
          tied[1] = tmp;
        } else if (direct == 0) {
          tied.sort((a, b) => a.clubName.compareTo(b.clubName));
        }
      } else if (tied.length > 1) {
        tied.sort((a, b) => a.clubName.compareTo(b.clubName));
      }
      output.addAll(tied);
      index = end;
    }
    return output;
  }

  static int _comparePrimary(Standing a, Standing b) {
    var compare = b.points.compareTo(a.points);
    if (compare != 0) return compare;
    compare = b.wins.compareTo(a.wins);
    if (compare != 0) return compare;
    compare = b.goalDifference.compareTo(a.goalDifference);
    if (compare != 0) return compare;
    compare = b.goalsFor.compareTo(a.goalsFor);
    if (compare != 0) return compare;
    return a.clubName.compareTo(b.clubName);
  }

  static String _primaryKey(Standing row) => '${row.points}|${row.wins}|${row.goalDifference}|${row.goalsFor}';

  static int _compareHeadToHead(Standing a, Standing b, List<MatchFixture> fixtures) {
    var aPoints = 0;
    var bPoints = 0;
    var aGoals = 0;
    var bGoals = 0;
    var matches = 0;

    for (final fixture in fixtures) {
      if (!fixture.played || fixture.score == null) continue;
      final direct = (fixture.homeClubId == a.clubId && fixture.awayClubId == b.clubId) ||
          (fixture.homeClubId == b.clubId && fixture.awayClubId == a.clubId);
      if (!direct) continue;
      matches++;
      final score = fixture.score!;
      final aHome = fixture.homeClubId == a.clubId;
      final ag = aHome ? score.home : score.away;
      final bg = aHome ? score.away : score.home;
      aGoals += ag;
      bGoals += bg;
      if (ag > bg) {
        aPoints += 3;
      } else if (bg > ag) {
        bPoints += 3;
      } else {
        aPoints++;
        bPoints++;
      }
    }
    if (matches == 0) return 0;
    if (bPoints != aPoints) return bPoints.compareTo(aPoints);
    if (bGoals != aGoals) return bGoals.compareTo(aGoals);
    return 0;
  }

  static LeagueScheduleReport validateSchedule(List<Club> clubs, List<MatchFixture> fixtures) {
    final errors = <String>[];
    final expectedRounds = (clubs.length - 1) * 2;
    final expectedMatches = clubs.length * (clubs.length - 1);
    final byRound = <int, List<MatchFixture>>{};
    for (final fixture in fixtures) {
      byRound.putIfAbsent(fixture.round, () => []).add(fixture);
    }

    if (byRound.length != expectedRounds) errors.add('Esperado $expectedRounds rodadas, recebido ${byRound.length}.');
    if (fixtures.length != expectedMatches) errors.add('Esperado $expectedMatches jogos, recebido ${fixtures.length}.');

    for (var round = 1; round <= expectedRounds; round++) {
      final seen = <String>{};
      final games = byRound[round] ?? const [];
      if (games.length != clubs.length ~/ 2) errors.add('Rodada $round tem ${games.length} jogos.');
      for (final game in games) {
        if (!seen.add(game.homeClubId)) errors.add('${game.homeClubId} duplicado na rodada $round.');
        if (!seen.add(game.awayClubId)) errors.add('${game.awayClubId} duplicado na rodada $round.');
      }
    }

    final pairCount = <String, int>{};
    final homePair = <String, int>{};
    for (final game in fixtures) {
      final pair = [game.homeClubId, game.awayClubId]..sort();
      final key = '${pair[0]}|${pair[1]}';
      pairCount[key] = (pairCount[key] ?? 0) + 1;
      homePair['$key|${game.homeClubId}'] = (homePair['$key|${game.homeClubId}'] ?? 0) + 1;
    }
    for (var i = 0; i < clubs.length; i++) {
      for (var j = i + 1; j < clubs.length; j++) {
        final pair = [clubs[i].id, clubs[j].id]..sort();
        final key = '${pair[0]}|${pair[1]}';
        if (pairCount[key] != 2) errors.add('$key não se enfrenta exatamente duas vezes.');
        if (homePair['$key|${clubs[i].id}'] != 1 || homePair['$key|${clubs[j].id}'] != 1) {
          errors.add('$key não possui mando invertido corretamente.');
        }
      }
    }

    for (final club in clubs) {
      final clubFixtures = fixtures
          .where((fixture) => fixture.homeClubId == club.id || fixture.awayClubId == club.id)
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));
      for (var i = 1; i < clubFixtures.length; i++) {
        final previous = clubFixtures[i - 1];
        final current = clubFixtures[i];
        final gapDays = DateTime(current.date.year, current.date.month, current.date.day)
            .difference(DateTime(previous.date.year, previous.date.month, previous.date.day))
            .inDays;
        if (gapDays <= minimumRestDays) {
          errors.add(
            '${club.name} tem apenas ${gapDays - 1} dia(s) completo(s) de descanso entre as rodadas ${previous.round} e ${current.round}.',
          );
        }
      }
    }

    return LeagueScheduleReport(rounds: byRound.length, matches: fixtures.length, errors: errors);
  }
}
