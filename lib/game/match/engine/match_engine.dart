import 'dart:math';

import '../../../domain/club/club.dart';
import '../../../domain/formation/formation.dart';
import '../../../domain/match/match_models.dart';
import '../../../domain/tactic/tactic.dart';
import '../../lineup/lineup_engine.dart';
import 'match_statistics_calculator.dart';
import 'match_strength_calculator.dart';
import 'match_timeline_generator.dart';

abstract final class MatchEngine {
  static MatchResult simulate({
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
    bool autoSubstituteHome = false,
    bool autoSubstituteAway = false,
    int? seed,
    int startMinute = 1,
    MatchScore initialScore = const MatchScore(0, 0),
    List<MatchEvent> prefixEvents = const [],
  }) {
    final resolvedSeed = seed ?? _seedFromFixture(fixture.id);
    final random = Random(
      resolvedSeed +
          startMinute * 7919 +
          home.squad.length * 17 +
          away.squad.length * 31,
    );

    final homeIds = homeStarterIds ??
        LineupEngine.autoSelect(home.squad, homeFormation);
    final awayIds = awayStarterIds ??
        LineupEngine.autoSelect(away.squad, awayFormation);
    final homeAssignments = LineupEngine.assign(
      home.squad,
      homeIds,
      homeFormation,
    );
    final awayAssignments = LineupEngine.assign(
      away.squad,
      awayIds,
      awayFormation,
    );
    final homeStrength = MatchStrengthCalculator.applyManagerBonus(
      MatchStrengthCalculator.calculate(homeAssignments, homeTactic),
      homeManagerOverall,
    );
    final awayStrength = MatchStrengthCalculator.applyManagerBonus(
      MatchStrengthCalculator.calculate(awayAssignments, awayTactic),
      awayManagerOverall,
    );
    final homeAdvantage =
        (1.08 + home.fanBase * .10 - away.fanBase * .04)
            .clamp(1.04, 1.25)
            .toDouble();

    final timeline = MatchTimelineGenerator.generate(
      home: home,
      away: away,
      homeAssignments: homeAssignments,
      awayAssignments: awayAssignments,
      homeManagerOverall: homeManagerOverall,
      awayManagerOverall: awayManagerOverall,
      autoSubstituteHome: autoSubstituteHome,
      autoSubstituteAway: autoSubstituteAway,
      homeTactic: homeTactic,
      awayTactic: awayTactic,
      homeAdvantage: homeAdvantage,
      random: random,
      startMinute: startMinute,
      initialScore: initialScore,
      prefixEvents: prefixEvents,
    );

    final statistics = MatchStatisticsCalculator.calculate(
      events: timeline.events,
      home: home,
      away: away,
      homeStrength: homeStrength,
      awayStrength: awayStrength,
      homeTactic: homeTactic,
      awayTactic: awayTactic,
      homeAdvantage: homeAdvantage,
      random: random,
    );

    return MatchResult(
      fixtureId: fixture.id,
      homeClubId: home.id,
      awayClubId: away.id,
      score: timeline.score,
      events: timeline.events
        ..sort((a, b) {
          final minute = a.minute.compareTo(b.minute);
          return minute != 0 ? minute : a.sequence.compareTo(b.sequence);
        }),
      statistics: statistics,
      seed: resolvedSeed,
    );
  }

  static int _seedFromFixture(String id) {
    var hash = 17;
    for (final code in id.codeUnits) {
      hash = 37 * hash + code;
    }
    return hash & 0x7fffffff;
  }
}
