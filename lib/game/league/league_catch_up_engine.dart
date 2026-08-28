import '../../domain/season/career_state.dart';
import '../competition/competition_simulation_engine.dart';

/// Mantém todas as competições carregadas em dia quando o usuário está sem
/// clube. Apenas partidas anteriores à data atual são resolvidas, preservando
/// um jogo do dia caso o técnico aceite um emprego antes do kickoff.
abstract final class LeagueCatchUpEngine {
  static CareerState resolvePastFixtures(CareerState state) {
    final yesterday = DateTime(
      state.currentDate.year,
      state.currentDate.month,
      state.currentDate.day,
    ).subtract(const Duration(days: 1));
    return CompetitionSimulationEngine.resolveCpuFixturesThroughDate(
      state,
      throughDate: yesterday,
      protectUserFixtures: false,
    );
  }
}
