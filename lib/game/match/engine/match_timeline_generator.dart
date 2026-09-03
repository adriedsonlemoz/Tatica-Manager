import 'dart:math';

import '../../../domain/club/club.dart';
import '../../../domain/match/match_models.dart';
import '../../../domain/player/player.dart';
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

class _CpuSubstitution {
  const _CpuSubstitution({
    required this.assignments,
    required this.incomingId,
    required this.outgoingId,
    required this.incomingName,
    required this.outgoingName,
  });

  final List<AssignedPlayer> assignments;
  final String incomingId;
  final String outgoingId;
  final String incomingName;
  final String outgoingName;
}

abstract final class MatchTimelineGenerator {
  static MatchTimelineResult generate({
    required Club home,
    required Club away,
    required List<AssignedPlayer> homeAssignments,
    required List<AssignedPlayer> awayAssignments,
    required int homeManagerOverall,
    required int awayManagerOverall,
    required bool autoSubstituteHome,
    required bool autoSubstituteAway,
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

    var currentHomeAssignments = [...homeAssignments];
    var currentAwayAssignments = [...awayAssignments];
    final homeSubstituted = <String>{};
    final awaySubstituted = <String>{};

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

      if (autoSubstituteHome) {
        final change = _cpuSubstitution(
          club: home,
          assignments: currentHomeAssignments,
          unavailableIds: homeSubstituted,
          minute: minute,
          random: random,
        );
        if (change != null) {
          currentHomeAssignments = change.assignments;
          homeSubstituted.add(change.incomingId);
          homeSubstituted.add(change.outgoingId);
          events.add(
            MatchEvent(
              minute: minute,
              sequence: sequence++,
              type: MatchEventType.substitution,
              teamId: home.id,
              playerId: change.incomingId,
              secondaryPlayerId: change.outgoingId,
              text: 'Substituição em ${home.name}: entra ${change.incomingName}, sai ${change.outgoingName}.',
            ),
          );
        }
      }
      if (autoSubstituteAway) {
        final change = _cpuSubstitution(
          club: away,
          assignments: currentAwayAssignments,
          unavailableIds: awaySubstituted,
          minute: minute,
          random: random,
        );
        if (change != null) {
          currentAwayAssignments = change.assignments;
          awaySubstituted.add(change.incomingId);
          awaySubstituted.add(change.outgoingId);
          events.add(
            MatchEvent(
              minute: minute,
              sequence: sequence++,
              type: MatchEventType.substitution,
              teamId: away.id,
              playerId: change.incomingId,
              secondaryPlayerId: change.outgoingId,
              text: 'Substituição em ${away.name}: entra ${change.incomingName}, sai ${change.outgoingName}.',
            ),
          );
        }
      }

      final activeHomeAssignments =
          discipline.activeAssignments(currentHomeAssignments);
      final activeAwayAssignments =
          discipline.activeAssignments(currentAwayAssignments);
      final currentHomeStrength = MatchStrengthCalculator.applyManagerBonus(
        MatchStrengthCalculator.calculate(activeHomeAssignments, homeTactic),
        homeManagerOverall,
      );
      final currentAwayStrength = MatchStrengthCalculator.applyManagerBonus(
        MatchStrengthCalculator.calculate(activeAwayAssignments, awayTactic),
        awayManagerOverall,
      );

      final probabilities = MatchProbabilityCalculator.forMinute(
        minute: minute,
        homeStrength: currentHomeStrength,
        awayStrength: currentAwayStrength,
        homeTactic: homeTactic,
        awayTactic: awayTactic,
        homeAdvantage: homeAdvantage,
        homeRed: homeRed,
        awayRed: awayRed,
        homeGoals: homeGoals,
        awayGoals: awayGoals,
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
      } else if (roll < probabilities.goalTotal + probabilities.shotTotal) {
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
          probabilities.goalTotal + probabilities.shotTotal + probabilities.foulTotal) {
        batch = MatchEventGenerator.foul(
          minute: minute,
          sequence: sequence,
          home: home,
          away: away,
          homeAssignments: activeHomeAssignments,
          awayAssignments: activeAwayAssignments,
          homeFoulShare: probabilities.homeFoulShare,
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
          homeStrength: currentHomeStrength,
          awayStrength: currentAwayStrength,
          homeScoringShare: probabilities.homeScoringShare,
          random: random,
        );
      } else if (minute > 10 &&
          random.nextDouble() <
              _injuryProbability(
                minute: minute,
                homeAssignments: activeHomeAssignments,
                awayAssignments: activeAwayAssignments,
                homeTactic: homeTactic,
                awayTactic: awayTactic,
              )) {
        batch = MatchEventGenerator.injury(
          minute: minute,
          sequence: sequence,
          home: home,
          away: away,
          homeAssignments: activeHomeAssignments,
          awayAssignments: activeAwayAssignments,
          random: random,
        );
      } else if (random.nextDouble() < .075) {
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
        homeAssignments: currentHomeAssignments,
        awayAssignments: currentAwayAssignments,
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

  static double _injuryProbability({
    required int minute,
    required List<AssignedPlayer> homeAssignments,
    required List<AssignedPlayer> awayAssignments,
    required Tactic homeTactic,
    required Tactic awayTactic,
  }) {
    final players = [...homeAssignments, ...awayAssignments];
    if (players.isEmpty) return 0;
    final physicalRisk = players
            .map(
              (item) =>
                  (100 - item.player.condition) * .005 +
                  item.player.fatigue * .004 +
                  (100 - item.player.physical.stamina) * .003,
            )
            .reduce((a, b) => a + b) /
        players.length;
    final highPressing =
        (homeTactic.pressing == Pressing.high ? .00020 : 0) +
            (awayTactic.pressing == Pressing.high ? .00020 : 0);
    final lateLoad = minute > 70 ? (minute - 70) * .000015 : 0;
    return (.00028 + physicalRisk * .001 + highPressing + lateLoad)
        .clamp(.00025, .00120)
        .toDouble();
  }

  static _CpuSubstitution? _cpuSubstitution({
    required Club club,
    required List<AssignedPlayer> assignments,
    required Set<String> unavailableIds,
    required int minute,
    required Random random,
  }) {
    // Uma troca por janela: a CPU preserva o banco e só mexe a partir da
    // segunda etapa. Não há substituição automática para a partida do usuário.
    if (minute != 60 && minute != 72 && minute != 82) return null;
    if (unavailableIds.length >= 6 || random.nextDouble() > .58) return null;
    final onFieldIds = assignments.map((item) => item.player.id).toSet();
    final bench = club.squad
        .where(
          (player) =>
              !onFieldIds.contains(player.id) &&
              !unavailableIds.contains(player.id) &&
              player.injury == null &&
              player.condition >= 35,
        )
        .toList(growable: false);
    if (bench.isEmpty) return null;

    final candidates = assignments
        .where((item) => item.slot.role != PlayerPosition.gol)
        .toList(growable: false)
      ..sort((a, b) {
        final aLoad = a.effectiveOverall - a.player.fatigue * .16 +
            a.player.condition * .04 + a.player.physical.stamina * .03;
        final bLoad = b.effectiveOverall - b.player.fatigue * .16 +
            b.player.condition * .04 + b.player.physical.stamina * .03;
        return aLoad.compareTo(bLoad);
      });
    if (candidates.isEmpty) return null;
    final outgoing = candidates.first;
    final replacements = bench
        .map(
          (player) => AssignedPlayer(
            slot: outgoing.slot,
            player: player,
            fit: LineupEngine.positionFit(player, outgoing.slot.role),
          ),
        )
        .toList(growable: false)
      ..sort((a, b) => b.effectiveOverall.compareTo(a.effectiveOverall));
    final incoming = replacements.first;
    // Evita trocar sem ganho físico/tático algum salvo na janela final.
    if (minute < 82 &&
        incoming.effectiveOverall < outgoing.effectiveOverall - 4 &&
        outgoing.player.condition >= 72) {
      return null;
    }
    final next = assignments
        .map((item) => item.player.id == outgoing.player.id ? incoming : item)
        .toList(growable: false);
    return _CpuSubstitution(
      assignments: next,
      incomingId: incoming.player.id,
      outgoingId: outgoing.player.id,
      incomingName: incoming.player.displayName,
      outgoingName: outgoing.player.displayName,
    );
  }
}
