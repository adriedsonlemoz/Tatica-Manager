import '../../domain/match/match_models.dart';
import '../../domain/season/career_state.dart';
import '../player/player_development_engine.dart';
import '../training/training_engine.dart';

abstract final class CareerCalendarEngine {
  static const int preparationDaysBeforeFirstMatch = 3;

  static DateTime initialDate(CareerState state) => initialDateFor(
        fixtures: state.fixtures,
        userClubId: state.userClubId,
        season: state.season,
      );

  static DateTime initialDateFor({
    required List<MatchFixture> fixtures,
    required String userClubId,
    required int season,
  }) {
    final userFixtures = fixtures
        .where((fixture) =>
            fixture.homeClubId == userClubId || fixture.awayClubId == userClubId)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    if (userFixtures.isEmpty) return DateTime(season, 1, 1);
    final firstDate = _dateOnly(userFixtures.first.date);
    return firstDate.subtract(
      const Duration(days: preparationDaysBeforeFirstMatch),
    );
  }

  static CareerState advanceDay(CareerState state) {
    if (state.seasonComplete) {
      throw StateError('A temporada terminou. Inicie a próxima temporada.');
    }
    if (state.managerEmployed && state.isMatchDay) {
      throw StateError('Hoje é dia de jogo. Prepare a equipe antes de continuar.');
    }

    final nextFixture = state.managerEmployed ? state.nextUserFixture : null;
    final nextDate = _dateOnly(state.currentDate).add(const Duration(days: 1));
    if (nextFixture != null && nextDate.isAfter(_dateOnly(nextFixture.date))) {
      throw StateError('Não é possível avançar além de uma partida pendente.');
    }

    final activeTrainingPlan = state.managerEmployed &&
            state.trainingPlan.managedByAssistant
        ? TrainingEngine.recommend(state)
        : state.trainingPlan;
    final clubs = state.clubs
        .map(
          (club) => club.copyWith(
            squad: state.managerEmployed && club.id == state.userClubId
                ? TrainingEngine.applyDay(
                    club.squad,
                    plan: activeTrainingPlan,
                    starterIds: state.starterIds.toSet(),
                  )
                : PlayerDevelopmentEngine.recoverDay(club.squad),
          ),
        )
        .toList();

    return state.copyWith(
      currentDate: nextDate,
      clubs: clubs,
      trainingPlan: activeTrainingPlan,
    );
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
