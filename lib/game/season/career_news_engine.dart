import '../../data/competition_catalog.dart';
import '../../domain/match/match_models.dart';
import '../../domain/season/career_event.dart';
import '../../domain/season/career_state.dart';

/// Transforma somente fatos já presentes na carreira em notícias de contexto.
abstract final class CareerNewsEngine {
  static CareerEvent? preMatchPreview(CareerState state) {
    if (state.daysUntilNextMatch != 2) return null;
    final fixture = state.nextUserFixture;
    if (fixture == null) return null;
    final opponentId = fixture.homeClubId == state.userClubId
        ? fixture.awayClubId
        : fixture.homeClubId;
    final opponent = state.clubs.firstWhere((club) => club.id == opponentId);
    final standings = state.standingsFor(fixture.competitionId);
    final userPosition = standings.indexWhere((row) => row.clubId == state.userClubId);
    final opponentPosition = standings.indexWhere((row) => row.clubId == opponentId);
    final positionText = userPosition >= 0 && opponentPosition >= 0
        ? ' O confronto reúne o ${userPosition + 1}º e o ${opponentPosition + 1}º colocados.'
        : '';
    return CareerEvent(
      id: 'match-preview-${fixture.id}',
      date: state.currentDate,
      type: CareerEventType.nextMatch,
      title: 'Preparação para a próxima partida',
      message:
          'Faltam dois dias para enfrentar ${opponent.name} pela ${CompetitionCatalog.displayNameForId(fixture.competitionId)}.$positionText',
      clubId: opponentId,
      fixtureId: fixture.id,
    );
  }

  static CareerEvent? weeklyTableBrief(CareerState state) {
    if (state.currentDate.weekday != DateTime.monday) return null;
    final standings = state.standings;
    final position = standings.indexWhere((row) => row.clubId == state.userClubId);
    if (position < 0 || standings[position].played == 0) return null;
    final row = standings[position];
    final id = 'table-brief-${state.season}-${state.currentDate.year}-${state.currentDate.month}-${state.currentDate.day}';
    if (state.news.any((item) => item.id == id)) return null;
    final goalDifference = row.goalDifference;
    final goalDifferenceText = goalDifference >= 0
        ? '+$goalDifference'
        : '$goalDifference';
    return CareerEvent(
      id: id,
      date: state.currentDate,
      type: CareerEventType.info,
      title: 'Panorama da tabela',
      message:
          '${state.userClub.name} está em ${position + 1}º, com ${row.points} pontos em ${row.played} jogos e saldo $goalDifferenceText.',
      clubId: state.userClubId,
    );
  }

  static List<CareerEvent> postMatchReports({
    required CareerState state,
    required MatchFixture fixture,
    required MatchResult result,
  }) {
    final home = state.clubs.firstWhere((club) => club.id == result.homeClubId);
    final away = state.clubs.firstWhere((club) => club.id == result.awayClubId);
    final userAtHome = result.homeClubId == state.userClubId;
    final userGoals = userAtHome ? result.score.home : result.score.away;
    final opponentGoals = userAtHome ? result.score.away : result.score.home;
    final outcome = userGoals > opponentGoals
        ? 'Vitória do ${state.userClub.shortName}'
        : userGoals < opponentGoals
            ? 'Derrota do ${state.userClub.shortName}'
            : 'Empate no confronto';
    final events = <CareerEvent>[
      CareerEvent(
        id: 'match-report-${fixture.id}',
        date: state.currentDate,
        type: CareerEventType.matchReport,
        title: outcome,
        message:
            '${home.name} ${result.score.display} ${away.name} pela ${CompetitionCatalog.displayNameForId(fixture.competitionId)}.',
        clubId: state.userClubId,
        fixtureId: fixture.id,
      ),
    ];

    final playerById = {
      for (final player in state.userClub.squad) player.id: player,
    };
    final goalsByPlayer = <String, int>{};
    final involvementsByPlayer = <String, int>{};
    for (final event in result.events) {
      if (event.teamId != state.userClubId) continue;
      if (event.type == MatchEventType.goal && event.playerId != null) {
        goalsByPlayer.update(event.playerId!, (value) => value + 1, ifAbsent: () => 1);
        involvementsByPlayer.update(event.playerId!, (value) => value + 1, ifAbsent: () => 1);
      }
      if (event.assistPlayerId != null) {
        involvementsByPlayer.update(event.assistPlayerId!, (value) => value + 1, ifAbsent: () => 1);
      }
    }
    String? highlightId;
    var highestInvolvements = 0;
    for (final entry in involvementsByPlayer.entries) {
      if (entry.value > highestInvolvements && playerById.containsKey(entry.key)) {
        highlightId = entry.key;
        highestInvolvements = entry.value;
      }
    }
    if (highlightId != null && highestInvolvements >= 2) {
      final player = playerById[highlightId]!;
      final goals = goalsByPlayer[highlightId] ?? 0;
      final detail = goals >= 2
          ? 'marcou $goals gols'
          : 'participou diretamente de $highestInvolvements gols';
      events.add(
        CareerEvent(
          id: 'match-highlight-${fixture.id}-${player.id}',
          date: state.currentDate,
          type: CareerEventType.matchReport,
          title: 'Destaque da partida',
          message: '${player.displayName} $detail no confronto contra ${userAtHome ? away.name : home.name}.',
          playerId: player.id,
          clubId: state.userClubId,
          fixtureId: fixture.id,
        ),
      );
    }
    return events;
  }
}
