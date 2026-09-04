import '../../domain/reward/reward_models.dart';

abstract final class RewardCalculator {
  static RewardMutation forMatch({
    required MatchRewardRequest request,
    required RewardGlobalProgress globalProgress,
    required RewardCareerProgress careerProgress,
    required Set<String> existingTransactionIds,
  }) {
    if (!request.competitive) {
      final grants = RewardRules.nonCompetitiveMatchMode ==
              NonCompetitiveMatchRewardMode.baseOnly
          ? <RewardGrant>[
              RewardGrant(
                id: '${request.eventKey}:base',
                origin: RewardOrigin.matchCompleted,
                amount: RewardRules.matchCompleted,
                relatedId: request.eventKey,
                careerId: request.careerId,
                description: RewardOrigin.matchCompleted.label,
              ),
            ]
          : const <RewardGrant>[];
      return RewardMutation(
        grants: grants,
        globalProgress: globalProgress,
        careerProgress: careerProgress,
      );
    }

    final relatedId = request.eventKey;
    final grants = <RewardGrant>[
      RewardGrant(
        id: '${request.eventKey}:base',
        origin: RewardOrigin.matchCompleted,
        amount: RewardRules.matchCompleted,
        relatedId: relatedId,
        careerId: request.careerId,
        description: RewardOrigin.matchCompleted.label,
      ),
    ];

    if (request.outcome == RewardMatchOutcome.win) {
      grants.add(
        RewardGrant(
          id: '${request.eventKey}:result',
          origin: RewardOrigin.matchWin,
          amount: RewardRules.win,
          relatedId: relatedId,
          careerId: request.careerId,
          description: RewardOrigin.matchWin.label,
        ),
      );
    } else if (request.outcome == RewardMatchOutcome.draw) {
      grants.add(
        RewardGrant(
          id: '${request.eventKey}:result',
          origin: RewardOrigin.matchDraw,
          amount: RewardRules.draw,
          relatedId: relatedId,
          careerId: request.careerId,
          description: RewardOrigin.matchDraw.label,
        ),
      );
    }

    var nextStreak = 0;
    var sequence = careerProgress.streakSequence;
    if (request.outcome == RewardMatchOutcome.win) {
      if (careerProgress.winStreak == 0) sequence++;
      nextStreak = careerProgress.winStreak + 1;
      final streakReward = switch (nextStreak) {
        3 => (RewardOrigin.winStreak3, RewardRules.streak3),
        5 => (RewardOrigin.winStreak5, RewardRules.streak5),
        _ => null,
      };
      if (streakReward != null) {
        final id = 'streak:${request.careerId}:$sequence:$nextStreak';
        if (!existingTransactionIds.contains(id)) {
          grants.add(
            RewardGrant(
              id: id,
              origin: streakReward.$1,
              amount: streakReward.$2,
              relatedId: relatedId,
              careerId: request.careerId,
              description: streakReward.$1.label,
            ),
          );
        }
      }
    }

    final completedMatches = globalProgress.competitiveMatches + 1;
    for (final entry in RewardRules.matchMilestones.entries) {
      if (completedMatches < entry.key) continue;
      final id = 'matches-global:${entry.key}';
      if (existingTransactionIds.contains(id)) continue;
      final origin = switch (entry.key) {
        10 => RewardOrigin.matches10,
        25 => RewardOrigin.matches25,
        _ => RewardOrigin.matches50,
      };
      grants.add(
        RewardGrant(
          id: id,
          origin: origin,
          amount: entry.value,
          relatedId: relatedId,
          careerId: request.careerId,
          description: origin.label,
        ),
      );
    }

    return RewardMutation(
      grants: grants,
      globalProgress: RewardGlobalProgress(
        competitiveMatches: completedMatches,
      ),
      careerProgress: careerProgress.copyWith(
        winStreak: nextStreak,
        streakSequence: sequence,
      ),
    );
  }

  static RewardMutation forSeason({
    required SeasonRewardRequest request,
    required RewardGlobalProgress globalProgress,
    required Set<String> existingTransactionIds,
  }) {
    final grants = <RewardGrant>[];

    void add({
      required String id,
      required RewardOrigin origin,
      required int amount,
    }) {
      if (existingTransactionIds.contains(id)) return;
      grants.add(
        RewardGrant(
          id: id,
          origin: origin,
          amount: amount,
          relatedId: request.eventKey,
          careerId: request.careerId,
          description: origin.label,
        ),
      );
    }

    add(
      id: '${request.eventKey}:completed',
      origin: RewardOrigin.seasonCompleted,
      amount: RewardRules.seasonCompleted,
    );
    if (request.objectiveMet) {
      add(
        id: 'objective:${request.careerId}:${request.season}:${request.competitionId}',
        origin: RewardOrigin.boardObjective,
        amount: RewardRules.boardObjective,
      );
    }
    if (request.leagueChampion) {
      add(
        id: 'league-title:${request.careerId}:${request.season}:${request.competitionId}',
        origin: RewardOrigin.leagueChampion,
        amount: RewardRules.leagueChampion,
      );
    }

    return RewardMutation(
      grants: grants,
      globalProgress: globalProgress,
      careerProgress: null,
    );
  }
}
