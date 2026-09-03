import '../../domain/club/club.dart';
import '../../domain/formation/formation.dart';
import '../../domain/match/match_models.dart';
import '../../domain/season/league_loading.dart';
import '../../domain/tactic/tactic.dart';
import '../match/engine/match_engine.dart';

/// Resolve partidas CPU no mesmo motor de regras usado na carreira.
///
/// A configuração da liga continua controlando a apresentação/carregamento,
/// mas nunca mais troca para um placar sem eventos: gols, cartões, artilharia,
/// fadiga e suspensões precisam ter a mesma origem em todas as competições.
abstract final class CpuFixtureResolver {
  static MatchResult resolve({
    required LeagueLoadLevel level,
    required MatchFixture fixture,
    required Club home,
    required Club away,
    FormationType homeFormation = FormationType.f433,
    FormationType awayFormation = FormationType.f433,
    Tactic homeTactic = const Tactic(),
    Tactic awayTactic = const Tactic(),
    List<String>? homeStarterIds,
    List<String>? awayStarterIds,
    int homeManagerOverall = 70,
    int awayManagerOverall = 70,
  }) {
    return MatchEngine.simulate(
      fixture: fixture,
      home: home,
      away: away,
      homeFormation: homeFormation,
      awayFormation: awayFormation,
      homeTactic: homeTactic,
      awayTactic: awayTactic,
      homeStarterIds: homeStarterIds,
      awayStarterIds: awayStarterIds,
      homeManagerOverall: homeManagerOverall,
      awayManagerOverall: awayManagerOverall,
      autoSubstituteHome: true,
      autoSubstituteAway: true,
    );
  }
}
