import '../../domain/club/club.dart';
import '../../domain/formation/formation.dart';
import '../../domain/match/match_models.dart';
import '../../domain/season/career_state.dart';
import '../../domain/tactic/tactic.dart';
import '../lineup/lineup_engine.dart';
import '../match/engine/match_engine.dart';

class PreparedRoundMatch {
  const PreparedRoundMatch({
    required this.fixture,
    required this.result,
    required this.homeStarterIds,
    required this.awayStarterIds,
  });

  final MatchFixture fixture;
  final MatchResult result;
  final List<String> homeStarterIds;
  final List<String> awayStarterIds;
}

/// Prepara os outros jogos com o Match Engine existente. O resultado é criado
/// uma única vez, exibido de forma progressiva na transmissão e reutilizado ao
/// concluir a rodada.
abstract final class LiveRoundSimulator {
  static List<PreparedRoundMatch> prepareOtherMatches({
    required CareerState career,
    required int round,
    required String userFixtureId,
  }) {
    return career.fixtures
        .where(
          (fixture) =>
              fixture.round == round &&
              !fixture.played &&
              fixture.id != userFixtureId,
        )
        .map((fixture) => _simulateFixture(career, fixture))
        .toList(growable: false);
  }

  static PreparedRoundMatch _simulateFixture(
    CareerState career,
    MatchFixture fixture,
  ) {
    final home = _club(career, fixture.homeClubId);
    final away = _club(career, fixture.awayClubId);
    final homeFormation = formationFor(home);
    final awayFormation = formationFor(away);
    final homeStarters = LineupEngine.autoSelect(home.squad, homeFormation);
    final awayStarters = LineupEngine.autoSelect(away.squad, awayFormation);
    final result = MatchEngine.simulate(
      fixture: fixture,
      home: home,
      away: away,
      homeFormation: homeFormation,
      awayFormation: awayFormation,
      homeTactic: tacticFor(home),
      awayTactic: tacticFor(away),
      homeStarterIds: homeStarters,
      awayStarterIds: awayStarters,
    );
    return PreparedRoundMatch(
      fixture: fixture,
      result: result,
      homeStarterIds: homeStarters,
      awayStarterIds: awayStarters,
    );
  }

  static FormationType formationFor(Club club) {
    final code = club.id.codeUnits.fold<int>(0, (sum, item) => sum + item);
    const options = [
      FormationType.f433,
      FormationType.f4231,
      FormationType.f442,
      FormationType.f4141,
    ];
    return options[code % options.length];
  }

  static Tactic tacticFor(Club club) {
    if (club.reputation >= 84) {
      return const Tactic(
        mentality: Mentality.attacking,
        pressing: Pressing.high,
        tempo: MatchTempo.fast,
      );
    }
    if (club.reputation <= 76) {
      return const Tactic(
        mentality: Mentality.defensive,
        defensiveLine: DefensiveLine.low,
        buildUp: BuildUp.direct,
      );
    }
    return const Tactic();
  }

  static Club _club(CareerState career, String id) =>
      career.clubs.firstWhere((club) => club.id == id);
}
