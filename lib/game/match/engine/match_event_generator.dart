import 'dart:math';

import '../../../domain/club/club.dart';
import '../../../domain/match/match_models.dart';
import '../../lineup/lineup_engine.dart';
import 'match_player_selector.dart';
import 'match_probability_calculator.dart';
import 'match_strength_calculator.dart';
import 'match_trajectory_generator.dart';

class MatchEventBatch {
  const MatchEventBatch({
    required this.events,
    this.homeGoals = 0,
    this.awayGoals = 0,
    this.homeReds = 0,
    this.awayReds = 0,
  });

  final List<MatchEvent> events;
  final int homeGoals;
  final int awayGoals;
  final int homeReds;
  final int awayReds;
}

abstract final class MatchEventGenerator {
  static const double _ownGoalShare = .03;

  static MatchEventBatch goal({
    required int minute,
    required int sequence,
    required Club home,
    required Club away,
    required List<AssignedPlayer> homeAssignments,
    required List<AssignedPlayer> awayAssignments,
    required double homeScoringShare,
    required Random random,
  }) {
    final homeSide = random.nextDouble() < homeScoringShare;
    final scoringClub = homeSide ? home : away;
    final defendingClub = homeSide ? away : home;
    final scoringAssignments = homeSide ? homeAssignments : awayAssignments;
    final defendingAssignments = homeSide ? awayAssignments : homeAssignments;
    final scorer = MatchPlayerSelector.pickScorer(scoringAssignments, random);
    final assister = MatchPlayerSelector.pickAssister(
      scoringAssignments,
      scorer,
      random,
    );
    final passPoints = MatchTrajectoryGenerator.pass(homeSide, random);
    final shot = MatchTrajectoryGenerator.shot(homeSide, random);
    final events = <MatchEvent>[
      MatchEvent(
        minute: minute,
        sequence: sequence++,
        type: MatchEventType.pass,
        teamId: scoringClub.id,
        playerId: assister?.id,
        secondaryPlayerId: scorer.id,
        text: assister == null
            ? '${scoringClub.name} acelera a jogada.'
            : '${assister.displayName} encontra ${scorer.displayName}.',
        start: passPoints.$1,
        end: passPoints.$2,
      ),
      MatchEvent(
        minute: minute,
        sequence: sequence++,
        type: MatchEventType.shot,
        teamId: scoringClub.id,
        playerId: scorer.id,
        text: '${scorer.displayName} finaliza!',
        start: shot.$1,
        end: shot.$2,
      ),
    ];

    if (random.nextDouble() < _ownGoalShare &&
        defendingAssignments.isNotEmpty) {
      final defender = MatchPlayerSelector.pickAny(
        defendingAssignments,
        random,
      )!;
      events.add(
        MatchEvent(
          minute: minute,
          sequence: sequence,
          type: MatchEventType.ownGoal,
          teamId: scoringClub.id,
          playerId: defender.id,
          text:
              'Gol contra de ${defender.displayName}, do ${defendingClub.name}. ${scoringClub.name} comemora.',
          start: shot.$1,
          end: shot.$2,
        ),
      );
    } else {
      events.add(
        MatchEvent(
          minute: minute,
          sequence: sequence,
          type: MatchEventType.goal,
          teamId: scoringClub.id,
          playerId: scorer.id,
          assistPlayerId: assister?.id,
          text: 'GOL! ${scorer.displayName} marca para ${scoringClub.name}.',
          start: shot.$1,
          end: shot.$2,
        ),
      );
    }

    return MatchEventBatch(
      events: events,
      homeGoals: homeSide ? 1 : 0,
      awayGoals: homeSide ? 0 : 1,
    );
  }

  static MatchEventBatch openPlayShot({
    required int minute,
    required int sequence,
    required Club home,
    required Club away,
    required List<AssignedPlayer> homeAssignments,
    required List<AssignedPlayer> awayAssignments,
    required double homePossessionShare,
    required Random random,
  }) {
    final homeSide = random.nextDouble() < homePossessionShare;
    final attackingClub = homeSide ? home : away;
    final defendingClub = homeSide ? away : home;
    final assignments = homeSide ? homeAssignments : awayAssignments;
    final scorer = MatchPlayerSelector.pickScorer(assignments, random);
    final rawShot = MatchTrajectoryGenerator.shot(homeSide, random);
    final outcomeRoll = random.nextDouble();
    final hitsWoodwork = outcomeRoll < .09;
    final shotEnd = hitsWoodwork
        ? MatchTrajectoryGenerator.woodworkTarget(rawShot.$2)
        : rawShot.$2;
    final events = <MatchEvent>[
      MatchEvent(
        minute: minute,
        sequence: sequence++,
        type: MatchEventType.shot,
        teamId: attackingClub.id,
        playerId: scorer.id,
        text: '${scorer.displayName}, do ${attackingClub.name}, arrisca a finalização.',
        start: rawShot.$1,
        end: shotEnd,
      ),
    ];

    if (hitsWoodwork) {
      events.add(
        MatchEvent(
          minute: minute,
          sequence: sequence,
          type: MatchEventType.woodwork,
          teamId: attackingClub.id,
          playerId: scorer.id,
          text: 'NA TRAVE! ${scorer.displayName} quase marca para ${attackingClub.name}.',
          start: shotEnd,
          end: MatchTrajectoryGenerator.woodworkRebound(homeSide, shotEnd),
        ),
      );
    } else if (outcomeRoll < .55) {
      final goalkeeper = MatchPlayerSelector.goalkeeper(
        homeSide ? awayAssignments : homeAssignments,
      );
      events.add(
        MatchEvent(
          minute: minute,
          sequence: sequence,
          type: MatchEventType.save,
          teamId: defendingClub.id,
          playerId: goalkeeper?.id,
          text: goalkeeper == null
              ? 'A defesa bloqueia a finalização.'
              : '${goalkeeper.displayName} faz a defesa.',
          start: shotEnd,
          end: shotEnd,
        ),
      );
    }

    return MatchEventBatch(events: events);
  }

  static MatchEventBatch foul({
    required int minute,
    required int sequence,
    required Club home,
    required Club away,
    required List<AssignedPlayer> homeAssignments,
    required List<AssignedPlayer> awayAssignments,
    required double homeFoulShare,
    required Random random,
  }) {
    final homeSide = random.nextDouble() < homeFoulShare;
    final club = homeSide ? home : away;
    final assignments = homeSide ? homeAssignments : awayAssignments;
    final player = MatchPlayerSelector.pickFouler(assignments, random);
    final events = <MatchEvent>[
      MatchEvent(
        minute: minute,
        sequence: sequence++,
        type: MatchEventType.foul,
        teamId: club.id,
        playerId: player?.id,
        text: player == null ? '${club.name} comete falta.' : '${player.displayName}, do ${club.name}, comete falta.',
        start: MatchTrajectoryGenerator.randomFieldPoint(random),
        end: MatchTrajectoryGenerator.randomFieldPoint(random),
      ),
    ];

    if (player != null &&
        random.nextDouble() <
            MatchPlayerSelector.yellowRisk(player, minute: minute)) {
      events.add(
        MatchEvent(
          minute: minute,
          sequence: sequence,
          type: MatchEventType.yellow,
          teamId: club.id,
          playerId: player.id,
          text: 'Cartão amarelo: ${player.displayName} (${club.name}).',
        ),
      );
    }

    return MatchEventBatch(events: events);
  }

  static MatchEventBatch redCard({
    required int minute,
    required int sequence,
    required Club home,
    required Club away,
    required List<AssignedPlayer> homeAssignments,
    required List<AssignedPlayer> awayAssignments,
    required Random random,
  }) {
    final homeSide = random.nextDouble() < .5;
    final club = homeSide ? home : away;
    final assignments = homeSide ? homeAssignments : awayAssignments;
    final player = MatchPlayerSelector.pickFouler(assignments, random);
    AssignedPlayer? assignment;
    if (player != null) {
      for (final item in assignments) {
        if (item.player.id == player.id) {
          assignment = item;
          break;
        }
      }
    }
    return MatchEventBatch(
      events: [
        MatchEvent(
          minute: minute,
          sequence: sequence,
          type: MatchEventType.red,
          teamId: club.id,
          playerId: player?.id,
          cardReason: MatchCardReason.direct,
          text: player == null
              ? 'Cartão vermelho para ${club.name}.'
              : 'Cartão vermelho direto: ${player.displayName} (${club.name}).',
          start: assignment == null
              ? null
              : FieldPoint(assignment.slot.x, assignment.slot.y),
        ),
      ],
      homeReds: homeSide ? 1 : 0,
      awayReds: homeSide ? 0 : 1,
    );
  }

  static MatchEventBatch penalty({
    required int minute,
    required int sequence,
    required Club home,
    required Club away,
    required List<AssignedPlayer> homeAssignments,
    required List<AssignedPlayer> awayAssignments,
    required TeamMatchStrength homeStrength,
    required TeamMatchStrength awayStrength,
    required double homeScoringShare,
    required Random random,
  }) {
    final homeSide = random.nextDouble() < homeScoringShare;
    final club = homeSide ? home : away;
    final assignments = homeSide ? homeAssignments : awayAssignments;
    final scorer = MatchPlayerSelector.pickScorer(assignments, random);
    final target = homeSide
        ? const FieldPoint(.5, .04)
        : const FieldPoint(.5, .96);
    final start = homeSide
        ? const FieldPoint(.5, .18)
        : const FieldPoint(.5, .82);
    final events = <MatchEvent>[
      MatchEvent(
        minute: minute,
        sequence: sequence++,
        type: MatchEventType.penalty,
        teamId: club.id,
        playerId: scorer.id,
        text: 'Pênalti para ${club.name}. ${scorer.displayName} pega a bola.',
        start: start,
        end: target,
      ),
    ];
    final conversion = MatchProbabilityCalculator.penaltyConversion(
      homeSide ? homeStrength.attack : awayStrength.attack,
    );

    if (random.nextDouble() < conversion) {
      events.add(
        MatchEvent(
          minute: minute,
          sequence: sequence,
          type: MatchEventType.goal,
          teamId: club.id,
          playerId: scorer.id,
          text: 'GOL! ${scorer.displayName} converte o pênalti para ${club.name}.',
          start: start,
          end: target,
        ),
      );
      return MatchEventBatch(
        events: events,
        homeGoals: homeSide ? 1 : 0,
        awayGoals: homeSide ? 0 : 1,
      );
    }

    final goalkeeper = MatchPlayerSelector.goalkeeper(
      homeSide ? awayAssignments : homeAssignments,
    );
    events.add(
      MatchEvent(
        minute: minute,
        sequence: sequence,
        type: MatchEventType.penaltySaved,
        teamId: homeSide ? away.id : home.id,
        playerId: goalkeeper?.id,
        secondaryPlayerId: scorer.id,
        text: goalkeeper == null
            ? 'Pênalti defendido por ${homeSide ? away.name : home.name}.'
            : '${goalkeeper.displayName} defende o pênalti de ${scorer.displayName}.',
        start: start,
        end: target,
      ),
    );
    return MatchEventBatch(events: events);
  }

  static MatchEventBatch injury({
    required int minute,
    required int sequence,
    required Club home,
    required Club away,
    required List<AssignedPlayer> homeAssignments,
    required List<AssignedPlayer> awayAssignments,
    required Random random,
  }) {
    final homeSide = random.nextDouble() < .5;
    final club = homeSide ? home : away;
    final assignments = homeSide ? homeAssignments : awayAssignments;
    final player = MatchPlayerSelector.pickAny(assignments, random);
    return MatchEventBatch(
      events: [
        MatchEvent(
          minute: minute,
          sequence: sequence,
          type: MatchEventType.injury,
          teamId: club.id,
          playerId: player?.id,
          text: player == null ? 'Problema físico em ${club.name}.' : '${player.displayName}, do ${club.name}, sente a parte física.',
        ),
      ],
    );
  }

  static MatchEventBatch possession({
    required int minute,
    required int sequence,
    required Club home,
    required Club away,
    required double homePossessionShare,
    required Random random,
  }) {
    final homeSide = random.nextDouble() < homePossessionShare;
    final club = homeSide ? home : away;
    final points = MatchTrajectoryGenerator.pass(homeSide, random);
    return MatchEventBatch(
      events: [
        MatchEvent(
          minute: minute,
          sequence: sequence,
          type: random.nextDouble() < .72
              ? MatchEventType.pass
              : MatchEventType.possession,
          teamId: club.id,
          text: '${club.name} trabalha a posse no campo adversário.',
          start: points.$1,
          end: points.$2,
        ),
      ],
    );
  }
}
