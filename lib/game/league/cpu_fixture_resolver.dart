import '../../domain/club/club.dart';
import '../../domain/formation/formation.dart';
import '../../domain/match/match_models.dart';
import '../../domain/season/league_loading.dart';
import '../../domain/tactic/tactic.dart';
import '../match/engine/match_engine.dart';
import 'background_fixture_resolver.dart';

/// Escolhe o custo da resolução de uma partida CPU conforme a configuração
/// persistida da competição. Ligas completas continuam no MatchEngine atual.
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
  }) {
    if (level == LeagueLoadLevel.background) {
      return BackgroundFixtureResolver.resolve(
        fixture: fixture,
        home: home,
        away: away,
      );
    }
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
    );
  }
}
