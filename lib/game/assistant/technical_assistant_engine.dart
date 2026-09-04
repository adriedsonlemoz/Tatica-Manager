import 'dart:math';

import '../../domain/formation/formation.dart';
import '../../domain/player/player.dart';
import '../../domain/season/career_state.dart';
import '../../domain/tactic/tactic.dart';
import '../../domain/training/training_plan.dart';
import '../league/live_round_simulator.dart';
import '../lineup/lineup_engine.dart';
import '../match/engine/match_strength_calculator.dart';
import '../training/training_engine.dart';

enum AssistantPriorityLevel { information, attention, critical }

class AssistantPriority {
  const AssistantPriority({
    required this.title,
    required this.message,
    required this.level,
    this.playerId,
  });

  final String title;
  final String message;
  final AssistantPriorityLevel level;
  final String? playerId;
}

class TechnicalAssistantReport {
  const TechnicalAssistantReport({
    required this.readiness,
    required this.averageCondition,
    required this.averageFatigue,
    required this.unavailableCount,
    required this.atRiskCount,
    required this.recommendedTraining,
    required this.trainingReason,
    required this.recommendedFormation,
    required this.recommendedStarterIds,
    required this.recommendedTactic,
    required this.lineupChanges,
    required this.opponentName,
    required this.summary,
    required this.priorities,
  });

  final int readiness;
  final int averageCondition;
  final int averageFatigue;
  final int unavailableCount;
  final int atRiskCount;
  final TrainingPlan recommendedTraining;
  final String trainingReason;
  final FormationType recommendedFormation;
  final List<String> recommendedStarterIds;
  final Tactic recommendedTactic;
  final int lineupChanges;
  final String? opponentName;
  final String summary;
  final List<AssistantPriority> priorities;
}

abstract final class TechnicalAssistantEngine {
  static TechnicalAssistantReport analyze(CareerState state) {
    final squad = state.userClub.squad;
    final fixture = state.nextUserFixture;
    final competitionId =
        fixture?.competitionId ?? state.primaryCompetitionId;
    final suspended =
        state.suspendedPlayerIdsForCompetition(competitionId);
    final unavailable = squad
        .where(
          (player) =>
              !state.isPlayerAvailableForCompetition(player, competitionId),
        )
        .toList(growable: false);
    final atRisk = squad
        .where(
          (player) => state
              .playerDisciplineForCompetition(competitionId, player.id)
              .isAtRisk,
        )
        .toList(growable: false);
    final condition = _average(squad.map((player) => player.condition));
    final fatigue = _average(squad.map((player) => player.fatigue));
    final training = TrainingEngine.recommend(state);
    final lineup = _recommendLineup(state, suspended);
    final opponent = fixture == null
        ? null
        : state.clubs.firstWhere(
            (club) =>
                club.id ==
                (fixture.homeClubId == state.userClubId
                    ? fixture.awayClubId
                    : fixture.homeClubId),
          );
    final tactic = opponent == null
        ? state.tactic
        : _recommendTactic(
            state,
            opponentId: opponent.id,
            formation: lineup.formation,
            starterIds: lineup.starterIds,
            suspended: suspended,
            fatigue: fatigue,
          );
    final availableRatio = squad.isEmpty
        ? 0.0
        : (squad.length - unavailable.length) / squad.length;
    final readiness = (condition * .52 +
            (100 - fatigue) * .36 +
            availableRatio * 12)
        .round()
        .clamp(0, 100)
        .toInt();
    final changes = _lineupChanges(
      state.starterIds,
      lineup.starterIds,
    );
    final priorities = _priorities(
      state,
      unavailable: unavailable,
      atRisk: atRisk,
      assignments: lineup.assignments,
      competitionId: competitionId,
    );
    return TechnicalAssistantReport(
      readiness: readiness,
      averageCondition: condition,
      averageFatigue: fatigue,
      unavailableCount: unavailable.length,
      atRiskCount: atRisk.length,
      recommendedTraining: training,
      trainingReason: _trainingReason(training, state.daysUntilNextMatch),
      recommendedFormation: lineup.formation,
      recommendedStarterIds: lineup.starterIds,
      recommendedTactic: tactic,
      lineupChanges: changes,
      opponentName: opponent?.name,
      summary: _summary(
        readiness: readiness,
        opponentName: opponent?.name,
        changes: changes,
        training: training,
      ),
      priorities: priorities,
    );
  }

  static ({
    FormationType formation,
    List<String> starterIds,
    List<AssignedPlayer> assignments,
  }) _recommendLineup(CareerState state, Set<String> suspended) {
    var bestFormation = state.formation;
    var bestStarters = LineupEngine.autoSelect(
      state.userClub.squad,
      state.formation,
      competitionSuspendedPlayerIds: suspended,
    );
    var bestValidation = LineupEngine.validate(
      state.userClub.squad,
      bestStarters,
      state.formation,
      competitionSuspendedPlayerIds: suspended,
    );
    var bestScore = _lineupScore(bestValidation.assignments, state.tactic);

    for (final formation in FormationType.values) {
      final starters = LineupEngine.autoSelect(
        state.userClub.squad,
        formation,
        competitionSuspendedPlayerIds: suspended,
      );
      final validation = LineupEngine.validate(
        state.userClub.squad,
        starters,
        formation,
        competitionSuspendedPlayerIds: suspended,
      );
      if (!validation.valid) continue;
      final score = _lineupScore(validation.assignments, state.tactic);
      if (score > bestScore + .65) {
        bestFormation = formation;
        bestStarters = starters;
        bestValidation = validation;
        bestScore = score;
      }
    }
    return (
      formation: bestFormation,
      starterIds: bestStarters,
      assignments: bestValidation.assignments,
    );
  }

  static double _lineupScore(
    List<AssignedPlayer> assignments,
    Tactic tactic,
  ) {
    if (assignments.length != 11) return -1000;
    final strength = MatchStrengthCalculator.calculate(assignments, tactic);
    final improvised = assignments
        .where((assignment) => assignment.outOfPosition)
        .length;
    return strength.attack * .28 +
        strength.midfield * .28 +
        strength.defense * .28 +
        strength.goalkeeper * .16 -
        improvised * .55;
  }

  static Tactic _recommendTactic(
    CareerState state, {
    required String opponentId,
    required FormationType formation,
    required List<String> starterIds,
    required Set<String> suspended,
    required int fatigue,
  }) {
    final opponent = state.clubs.firstWhere((club) => club.id == opponentId);
    final opponentManager =
        LiveRoundSimulator.managerFor(state, opponent.id);
    final opponentFormation = LiveRoundSimulator.formationFor(
      opponent,
      manager: opponentManager,
    );
    final opponentTactic = LiveRoundSimulator.tacticFor(
      opponent,
      manager: opponentManager,
    );
    final userAssignments = LineupEngine.assign(
      state.userClub.squad,
      starterIds,
      formation,
    );
    final opponentIds = LineupEngine.autoSelect(
      opponent.squad,
      opponentFormation,
      competitionSuspendedPlayerIds: suspended,
    );
    final opponentAssignments = LineupEngine.assign(
      opponent.squad,
      opponentIds,
      opponentFormation,
    );
    final userStrength = MatchStrengthCalculator.calculate(
      userAssignments,
      state.tactic,
    );
    final opponentStrength = MatchStrengthCalculator.calculate(
      opponentAssignments,
      opponentTactic,
    );
    final userAverage = _strengthAverage(userStrength);
    final opponentAverage = _strengthAverage(opponentStrength);

    if (opponentAverage > userAverage + 3) {
      return Tactic(
        mentality: Mentality.defensive,
        pressing: fatigue >= 42 ? Pressing.low : Pressing.medium,
        tempo: MatchTempo.normal,
        defensiveLine: DefensiveLine.low,
        buildUp: BuildUp.direct,
      );
    }
    if (userStrength.attack > opponentStrength.defense + 4 && fatigue < 42) {
      return const Tactic(
        mentality: Mentality.attacking,
        pressing: Pressing.high,
        tempo: MatchTempo.fast,
        defensiveLine: DefensiveLine.high,
        buildUp: BuildUp.balanced,
      );
    }
    if (userStrength.midfield >= opponentStrength.midfield + 2) {
      return Tactic(
        mentality: Mentality.balanced,
        pressing: fatigue >= 44 ? Pressing.low : Pressing.medium,
        tempo: MatchTempo.normal,
        defensiveLine: DefensiveLine.medium,
        buildUp: BuildUp.short,
      );
    }
    return Tactic(
      mentality: Mentality.balanced,
      pressing: fatigue >= 44 ? Pressing.low : Pressing.medium,
      tempo: MatchTempo.normal,
      defensiveLine: DefensiveLine.medium,
      buildUp: BuildUp.balanced,
    );
  }

  static double _strengthAverage(TeamMatchStrength strength) =>
      (strength.attack +
          strength.midfield +
          strength.defense +
          strength.goalkeeper) /
      4;

  static List<AssistantPriority> _priorities(
    CareerState state, {
    required List<Player> unavailable,
    required List<Player> atRisk,
    required List<AssignedPlayer> assignments,
    required String competitionId,
  }) {
    final priorities = <AssistantPriority>[];
    final suspended = unavailable
        .where(
          (player) => state
              .playerDisciplineForCompetition(competitionId, player.id)
              .isSuspended,
        )
        .toList(growable: false);
    if (suspended.isNotEmpty) {
      priorities.add(
        AssistantPriority(
          title: 'Suspensão na próxima partida',
          message: suspended
              .take(2)
              .map((player) => player.displayName)
              .join(' e '),
          level: AssistantPriorityLevel.critical,
          playerId: suspended.first.id,
        ),
      );
    }
    final tired = state.userClub.squad
        .where((player) => player.fatigue >= 50)
        .toList()
      ..sort((first, second) => second.fatigue.compareTo(first.fatigue));
    if (tired.isNotEmpty) {
      priorities.add(
        AssistantPriority(
          title: 'Carga física elevada',
          message:
              '${tired.first.displayName} está com ${tired.first.fatigue}% de fadiga.',
          level: AssistantPriorityLevel.critical,
          playerId: tired.first.id,
        ),
      );
    }
    final improvised = assignments
        .where((assignment) => assignment.outOfPosition)
        .toList(growable: false);
    if (improvised.isNotEmpty) {
      priorities.add(
        AssistantPriority(
          title: 'Jogador improvisado',
          message:
              '${improvised.first.player.displayName} rende menos em ${improvised.first.slot.role.label}.',
          level: AssistantPriorityLevel.attention,
          playerId: improvised.first.player.id,
        ),
      );
    }
    if (atRisk.isNotEmpty) {
      priorities.add(
        AssistantPriority(
          title: 'Cartões acumulados',
          message:
              '${atRisk.length} jogador${atRisk.length == 1 ? '' : 'es'} pendurado${atRisk.length == 1 ? '' : 's'} nesta competição.',
          level: AssistantPriorityLevel.attention,
          playerId: atRisk.first.id,
        ),
      );
    }
    final prospect = state.userClub.squad
        .where((player) => player.potential - player.overall >= 5)
        .toList()
      ..sort(
        (first, second) => (second.potential - second.overall)
            .compareTo(first.potential - first.overall),
      );
    if (prospect.isNotEmpty) {
      priorities.add(
        AssistantPriority(
          title: 'Potencial de evolução',
          message:
              '${prospect.first.displayName} tem margem de ${prospect.first.potential - prospect.first.overall} pontos.',
          level: AssistantPriorityLevel.information,
          playerId: prospect.first.id,
        ),
      );
    }
    if (priorities.isEmpty) {
      priorities.add(
        const AssistantPriority(
          title: 'Elenco equilibrado',
          message: 'Nenhum alerta crítico foi encontrado para a próxima partida.',
          level: AssistantPriorityLevel.information,
        ),
      );
    }
    return priorities.take(4).toList(growable: false);
  }

  static String _trainingReason(TrainingPlan plan, int? days) {
    final interval = days == null
        ? 'sem partida imediata'
        : days == 0
            ? 'com jogo hoje'
            : days == 1
                ? 'com jogo amanhã'
                : 'com jogo em $days dias';
    return switch (plan.focus) {
      TrainingFocus.recovery =>
        'A equipe precisa reduzir carga $interval.',
      TrainingFocus.tactical =>
        'A proximidade da partida favorece uma sessão leve de organização.',
      TrainingFocus.physical =>
        'A condição está alta e existe intervalo seguro para trabalho físico.',
      TrainingFocus.technical =>
        'A fadiga está controlada e permite uma sessão moderada com bola.',
      TrainingFocus.balanced =>
        'Condição e fadiga pedem uma carga equilibrada $interval.',
    };
  }

  static String _summary({
    required int readiness,
    required String? opponentName,
    required int changes,
    required TrainingPlan training,
  }) {
    final status = readiness >= 86
        ? 'O elenco está pronto'
        : readiness >= 72
            ? 'A preparação está controlada'
            : 'A equipe precisa de atenção';
    final opponent = opponentName == null ? '' : ' para enfrentar $opponentName';
    final lineup = changes == 0
        ? ' A escalação atual é competitiva.'
        : ' Recomendo $changes mudança${changes == 1 ? '' : 's'} na escalação.';
    return '$status$opponent. Treino ${training.focus.label.toLowerCase()} indicado.$lineup';
  }

  static int _lineupChanges(List<String> current, List<String> recommended) {
    final length = min(current.length, recommended.length);
    var changes = (current.length - recommended.length).abs();
    for (var index = 0; index < length; index++) {
      if (current[index] != recommended[index]) changes++;
    }
    return changes;
  }

  static int _average(Iterable<int> values) {
    final list = values.toList(growable: false);
    if (list.isEmpty) return 0;
    return (list.reduce((first, second) => first + second) / list.length)
        .round();
  }
}
