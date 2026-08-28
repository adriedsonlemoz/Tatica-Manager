import 'dart:math';

import '../../../domain/club/club.dart';
import '../../../domain/match/match_models.dart';
import '../../../domain/tactic/tactic.dart';
import '../../lineup/lineup_engine.dart';
import 'match_discipline_engine.dart';
import 'match_event_generator.dart';
import 'match_probability_calculator.dart';
import 'match_strength_calculator.dart';

class MatchTimelineResult {
  const MatchTimelineResult({
    required this.score,
    required this.events,
  });

  final MatchScore score;
  final List<MatchEvent> events;
}

abstract final class MatchTimelineGenerator {
  static MatchTimelineResult generate({
    required Club home,
    required Club away,
    required List<AssignedPlayer> homeAssignments,
    required List<AssignedPlayer> awayAssignments,
    required TeamMatchStrength homeStrength,
    required TeamMatchStrength awayStrength,
    required Tactic homeTactic,
    required Tactic awayTactic,
    required double homeAdvantage,
    required Random random,
    required int startMinute,
    required MatchScore initialScore,
    required List<MatchEvent> prefixEvents,
  }) {
    var homeGoals = initialScore.home;
    var awayGoals = initialScore.away;
    var homeRed = prefixEvents
        .where(
          (event) =>
              event.teamId == home.id && event.type == MatchEventType.red,
        )
        .length;
    var awayRed = prefixEvents
        .where(
          (event) =>
              event.teamId == away.id && event.type == MatchEventType.red,
        )
        .length;
    final discipline = MatchDisciplineTracker.fromPrefix(prefixEvents);
    var sequence = prefixEvents.isEmpty
        ? 0
        : prefixEvents.map((event) => event.sequence).reduce(max) + 1;
    final events = <MatchEvent>[
      ...prefixEvents.where(
        (event) => event.type != MatchEventType.fulltime,
      ),
    ];

    if (startMinute <= 1 && prefixEvents.isEmpty) {
      events.add(
        MatchEvent(
          minute: 0,
          sequence: sequence++,
          type: MatchEventType.kickoff,
          teamId: home.id,
          text: 'A bola está rolando.',
          start: const FieldPoint(.5, .5),
          end: const FieldPoint(.5, .46),
        ),
      );
    }

    for (var minute = startMinute.clamp(1, 90).toInt();
        minute <= 90;
        minute++) {
      if (minute == 46 && startMinute <= 45) {
        events.add(
          MatchEvent(
            minute: 45,
            sequence: sequence++,
            type: MatchEventType.halftime,
            teamId: home.id,
            text: 'Intervalo de jogo.',
          ),
        );
      }

      final activeHomeAssignments =
          discipline.activeAssignments(homeAssignments);
      final activeAwayAssignments =
          discipline.activeAssignments(awayAssignments);

      final probabilities = MatchProbabilityCalculator.forMinute(
        minute: minute,
        homeStrength: homeStrength,
        awayStrength: awayStrength,
        homeTactic: homeTactic,
        awayTactic: awayTactic,
        homeAdvantage: homeAdvantage,
        homeRed: homeRed,
        awayRed: awayRed,
      );
      final roll = random.nextDouble();
      MatchEventBatch? batch;

      if (roll < probabilities.goalTotal) {
        batch = MatchEventGenerator.goal(
          minute: minute,
          sequence: sequence,
          home: home,
          away: away,
          homeAssignments: activeHomeAssignments,
          awayAssignments: activeAwayAssignments,
          homeScoringShare: probabilities.homeScoringShare,
          random: random,
        );
      } else if (roll < probabilities.goalTotal + .060) {
        batch = MatchEventGenerator.openPlayShot(
          minute: minute,
          sequence: sequence,
          home: home,
          away: away,
          homeAssignments: activeHomeAssignments,
          awayAssignments: activeAwayAssignments,
          homePossessionShare: probabilities.homePossessionShare,
          random: random,
        );
      } else if (roll <
          probabilities.goalTotal +
              .060 +
              MatchProbabilityCalculator.yellowPerTeamPerMinute * 2) {
        batch = MatchEventGenerator.foul(
          minute: minute,
          sequence: sequence,
          home: home,
          away: away,
          homeAssignments: activeHomeAssignments,
          awayAssignments: activeAwayAssignments,
          random: random,
        );
      } else if (roll >
          1 - MatchProbabilityCalculator.directRedPerMinuteTotal) {
        batch = MatchEventGenerator.redCard(
          minute: minute,
          sequence: sequence,
          home: home,
          away: away,
          homeAssignments: activeHomeAssignments,
          awayAssignments: activeAwayAssignments,
          random: random,
        );
      } else if (roll >
          1 -
              MatchProbabilityCalculator.directRedPerMinuteTotal -
              MatchProbabilityCalculator.penaltyPerMinuteTotal) {
        batch = MatchEventGenerator.penalty(
          minute: minute,
          sequence: sequence,
          home: home,
          away: away,
          homeAssignments: activeHomeAssignments,
          awayAssignments: activeAwayAssignments,
          homeStrength: homeStrength,
          awayStrength: awayStrength,
          homeScoringShare: probabilities.homeScoringShare,
          random: random,
        );
      } else if (minute > 10 && random.nextDouble() < .0020) {
        batch = MatchEventGenerator.injury(
          minute: minute,
          sequence: sequence,
          home: home,
          away: away,
          homeAssignments: activeHomeAssignments,
          awayAssignments: activeAwayAssignments,
          random: random,
        );
      } else if (random.nextDouble() < .115) {
        batch = MatchEventGenerator.possession(
          minute: minute,
          sequence: sequence,
          home: home,
          away: away,
          homePossessionShare: probabilities.homePossessionShare,
          random: random,
        );
      }

      if (batch == null) continue;
      final disciplinedBatch = discipline.applyBatch(
        batch: batch,
        home: home,
        away: away,
        homeAssignments: homeAssignments,
        awayAssignments: awayAssignments,
      );
      events.addAll(disciplinedBatch.events);
      sequence += disciplinedBatch.events.length;
      homeGoals += disciplinedBatch.homeGoals;
      awayGoals += disciplinedBatch.awayGoals;
      homeRed += disciplinedBatch.homeReds;
      awayRed += disciplinedBatch.awayReds;
    }

    events.add(
      MatchEvent(
        minute: 90,
        sequence: sequence,
        type: MatchEventType.fulltime,
        teamId: home.id,
        text: 'Fim de jogo: ${home.name} $homeGoals x $awayGoals ${away.name}.',
      ),
    );

    return MatchTimelineResult(
      score: MatchScore(homeGoals, awayGoals),
      events: events,
    );
  }
}
