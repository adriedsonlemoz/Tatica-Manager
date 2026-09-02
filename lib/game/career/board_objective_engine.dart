import '../../domain/career/board_objective.dart';
import '../../domain/season/career_event.dart';
import '../../domain/season/career_state.dart';

/// Calcula metas e confiança somente com reputação, tabela e caixa já salvos.
abstract final class BoardObjectiveEngine {
  static BoardObjective create(CareerState state) {
    final participants = state.clubsForPrimaryCompetition().toList()
      ..sort((a, b) => b.reputation.compareTo(a.reputation));
    final rank = participants.indexWhere((club) => club.id == state.userClubId);
    final rawTarget = rank < 0 ? 10 : rank + 1;
    final target = rawTarget.clamp(1, participants.length.clamp(1, 20)).toInt();
    return BoardObjective(
      season: state.season,
      clubId: state.userClubId,
      targetPosition: target,
    );
  }

  static BoardObjective evaluate(CareerState state) {
    final current = state.boardObjective;
    final mustReset = current.clubId != state.userClubId ||
        current.season != state.season ||
        (current.lastEvaluatedAt == null &&
            current.targetPosition == 10 &&
            current.currentConfidence == 70);
    final baseline = mustReset ? create(state) : current;
    final standings = state.standings;
    final position = standings.indexWhere((row) => row.clubId == state.userClubId);
    if (position < 0 || standings[position].played == 0) {
      return baseline.copyWith(lastEvaluatedAt: state.currentDate);
    }
    final positionDelta = baseline.targetPosition - (position + 1);
    var confidence = 70 + positionDelta * 6;
    if (state.userClub.money < 0) confidence -= 12;
    if (state.userClub.transferBudget < 0) confidence -= 6;
    return baseline.copyWith(
      currentConfidence: confidence.clamp(5, 95).toInt(),
      lastEvaluatedAt: state.currentDate,
    );
  }

  static CareerEvent? weeklyUpdateEvent(CareerState state) {
    if (state.currentDate.weekday != DateTime.monday) return null;
    final id = 'board-update-${state.season}-${state.currentDate.year}-${state.currentDate.month}-${state.currentDate.day}';
    if (state.news.any((event) => event.id == id)) return null;
    final objective = state.boardObjective;
    final status = switch (objective.status) {
      BoardObjectiveStatus.onTrack => 'A diretoria aprova o momento da equipe.',
      BoardObjectiveStatus.attention => 'A diretoria pede atenção ao desempenho.',
      BoardObjectiveStatus.risk => 'A diretoria considera o momento preocupante.',
    };
    return CareerEvent(
      id: id,
      date: state.currentDate,
      type: CareerEventType.info,
      title: 'Avaliação da diretoria',
      message:
          '$status Meta: ${objective.targetLabel}. Confiança atual: ${objective.currentConfidence}%.',
      clubId: state.userClubId,
    );
  }
}
