import '../../data/competition_catalog.dart';
import '../../domain/match/match_models.dart';

/// Concilia os calendários de todas as competições carregadas.
///
/// Um clube nunca pode ter duas partidas no mesmo dia e, por padrão, recebe
/// dois dias completos de descanso entre jogos. A lista global de fixtures é
/// preservada porque ela é a fonte correta para conflitos entre estadual,
/// liga, copa e torneios internacionais.
abstract final class CompetitionCalendarEngine {
  static const int minimumCompleteRestDays = 2;

  static List<MatchFixture> resolveClubConflicts(
    List<MatchFixture> source, {
    int minimumRestDays = minimumCompleteRestDays,
  }) {
    if (source.length < 2) return List.unmodifiable(source);

    final ordered = [...source]
      ..sort((a, b) {
        final byDate = a.date.compareTo(b.date);
        if (byDate != 0) return byDate;
        final aPriority = CompetitionCatalog.competitionByIdOrNull(
              a.competitionId,
            )?.calendarPriority ??
            100;
        final bPriority = CompetitionCatalog.competitionByIdOrNull(
              b.competitionId,
            )?.calendarPriority ??
            100;
        final byPriority = aPriority.compareTo(bPriority);
        if (byPriority != 0) return byPriority;
        final byRound = a.round.compareTo(b.round);
        if (byRound != 0) return byRound;
        return a.id.compareTo(b.id);
      });

    final lastDateByClub = <String, DateTime>{};
    final resolved = <MatchFixture>[];
    final requiredGap = minimumRestDays + 1;

    for (final fixture in ordered) {
      var date = _dateOnly(fixture.date);
      final homeLast = lastDateByClub[fixture.homeClubId];
      final awayLast = lastDateByClub[fixture.awayClubId];
      final latestPrevious = _latest(homeLast, awayLast);
      if (latestPrevious != null) {
        final earliest = latestPrevious.add(Duration(days: requiredGap));
        if (date.isBefore(earliest)) date = earliest;
      }

      final shifted = _sameDate(date, fixture.date)
          ? fixture
          : fixture.copyWith(
              date: DateTime(
                date.year,
                date.month,
                date.day,
                fixture.kickoffHour,
                fixture.kickoffMinute,
              ),
            );
      resolved.add(shifted);
      lastDateByClub[fixture.homeClubId] = date;
      lastDateByClub[fixture.awayClubId] = date;
    }

    resolved.sort((a, b) {
      final byDate = a.date.compareTo(b.date);
      if (byDate != 0) return byDate;
      return a.id.compareTo(b.id);
    });
    return List.unmodifiable(resolved);
  }

  static DateTime? _latest(DateTime? a, DateTime? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a.isAfter(b) ? a : b;
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static bool _sameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
