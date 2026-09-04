import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/domain/reward/reward_models.dart';
import 'package:tatica_manager/game/reward/reward_calculator.dart';

void main() {
  test('valores de PM permanecem centralizados e previsíveis', () {
    expect(RewardRules.matchCompleted, 5);
    expect(RewardRules.win, 5);
    expect(RewardRules.draw, 2);
    expect(RewardRules.streak3, 10);
    expect(RewardRules.streak5, 20);
    expect(RewardRules.matchMilestones, const {10: 25, 25: 60, 50: 120});
    expect(RewardRules.boardObjective, 50);
    expect(RewardRules.promotion, 100);
    expect(RewardRules.seasonCompleted, 80);
    expect(RewardRules.leagueChampion, 150);
    expect(RewardRules.cupChampion, 120);
    expect(RewardRules.minimumAchievement, 20);
    expect(RewardRules.maximumAchievement, 200);
    expect(
      RewardRules.nonCompetitiveMatchMode,
      NonCompetitiveMatchRewardMode.none,
    );
  });

  test('chave de partida separa o mesmo fixture entre carreiras', () {
    const first = MatchRewardRequest(
      careerId: 'career-a',
      fixtureId: '2026-r1-m1',
      outcome: RewardMatchOutcome.win,
    );
    const second = MatchRewardRequest(
      careerId: 'career-b',
      fixtureId: '2026-r1-m1',
      outcome: RewardMatchOutcome.win,
    );

    expect(first.eventKey, 'match:career-a:2026-r1-m1');
    expect(second.eventKey, isNot(first.eventKey));
  });

  group('RewardCalculator partidas', () {
    test('aplica base e bônus fixo do resultado', () {
      RewardMutation calculate(RewardMatchOutcome outcome) =>
          RewardCalculator.forMatch(
            request: MatchRewardRequest(
              careerId: 'career-1',
              fixtureId: '2026-r1-m1',
              outcome: outcome,
            ),
            globalProgress: const RewardGlobalProgress(),
            careerProgress:
                const RewardCareerProgress(careerId: 'career-1'),
            existingTransactionIds: const {},
          );

      expect(
        calculate(RewardMatchOutcome.win).grants
            .fold<int>(0, (sum, item) => sum + item.amount),
        10,
      );
      expect(
        calculate(RewardMatchOutcome.draw).grants
            .fold<int>(0, (sum, item) => sum + item.amount),
        7,
      );
      expect(
        calculate(RewardMatchOutcome.loss).grants
            .fold<int>(0, (sum, item) => sum + item.amount),
        5,
      );
    });

    test('paga os marcos 3 e 5 uma vez dentro da sequência', () {
      final third = RewardCalculator.forMatch(
        request: const MatchRewardRequest(
          careerId: 'career-1',
          fixtureId: 'third',
          outcome: RewardMatchOutcome.win,
        ),
        globalProgress: const RewardGlobalProgress(),
        careerProgress: const RewardCareerProgress(
          careerId: 'career-1',
          winStreak: 2,
          streakSequence: 1,
        ),
        existingTransactionIds: const {},
      );
      expect(
        third.grants.map((item) => item.origin),
        contains(RewardOrigin.winStreak3),
      );
      expect(third.careerProgress?.winStreak, 3);

      final fifth = RewardCalculator.forMatch(
        request: const MatchRewardRequest(
          careerId: 'career-1',
          fixtureId: 'fifth',
          outcome: RewardMatchOutcome.win,
        ),
        globalProgress: const RewardGlobalProgress(),
        careerProgress: const RewardCareerProgress(
          careerId: 'career-1',
          winStreak: 4,
          streakSequence: 1,
        ),
        existingTransactionIds: const {},
      );
      expect(
        fifth.grants.map((item) => item.origin),
        contains(RewardOrigin.winStreak5),
      );
      expect(
        fifth.grants.map((item) => item.origin),
        isNot(contains(RewardOrigin.winStreak3)),
      );
    });

    test('empate encerra sequência e décima partida libera marco global', () {
      final mutation = RewardCalculator.forMatch(
        request: const MatchRewardRequest(
          careerId: 'career-1',
          fixtureId: 'tenth',
          outcome: RewardMatchOutcome.draw,
        ),
        globalProgress: const RewardGlobalProgress(competitiveMatches: 9),
        careerProgress: const RewardCareerProgress(
          careerId: 'career-1',
          winStreak: 4,
          streakSequence: 2,
        ),
        existingTransactionIds: const {},
      );

      expect(mutation.careerProgress?.winStreak, 0);
      expect(mutation.globalProgress.competitiveMatches, 10);
      expect(
        mutation.grants.map((item) => item.origin),
        contains(RewardOrigin.matches10),
      );
      expect(
        mutation.grants.fold<int>(0, (sum, item) => sum + item.amount),
        32,
      );

      final defeat = RewardCalculator.forMatch(
        request: const MatchRewardRequest(
          careerId: 'career-1',
          fixtureId: 'defeat',
          outcome: RewardMatchOutcome.loss,
        ),
        globalProgress: mutation.globalProgress,
        careerProgress: const RewardCareerProgress(
          careerId: 'career-1',
          winStreak: 5,
          streakSequence: 2,
        ),
        existingTransactionIds: const {},
      );
      expect(defeat.careerProgress?.winStreak, 0);
      expect(
        defeat.grants.fold<int>(0, (sum, item) => sum + item.amount),
        5,
      );
    });

    test('registros permanentes impedem repetir marcos já pagos', () {
      final mutation = RewardCalculator.forMatch(
        request: const MatchRewardRequest(
          careerId: 'career-1',
          fixtureId: 'already-paid',
          outcome: RewardMatchOutcome.win,
        ),
        globalProgress: const RewardGlobalProgress(competitiveMatches: 9),
        careerProgress: const RewardCareerProgress(
          careerId: 'career-1',
          winStreak: 2,
          streakSequence: 4,
        ),
        existingTransactionIds: const {
          'streak:career-1:4:3',
          'matches-global:10',
        },
      );

      expect(
        mutation.grants.map((item) => item.origin),
        isNot(contains(RewardOrigin.winStreak3)),
      );
      expect(
        mutation.grants.map((item) => item.origin),
        isNot(contains(RewardOrigin.matches10)),
      );
      expect(
        mutation.grants.fold<int>(0, (sum, item) => sum + item.amount),
        10,
      );
    });

    test('partida não competitiva não altera PM nem progresso', () {
      final mutation = RewardCalculator.forMatch(
        request: const MatchRewardRequest(
          careerId: 'career-1',
          fixtureId: 'friendly',
          outcome: RewardMatchOutcome.win,
          competitive: false,
        ),
        globalProgress: const RewardGlobalProgress(competitiveMatches: 9),
        careerProgress: const RewardCareerProgress(
          careerId: 'career-1',
          winStreak: 2,
        ),
        existingTransactionIds: const {},
      );

      expect(mutation.grants, isEmpty);
      expect(mutation.globalProgress.competitiveMatches, 9);
      expect(mutation.careerProgress?.winStreak, 2);
    });
  });

  test('temporada soma conclusão, objetivo e título', () {
    final mutation = RewardCalculator.forSeason(
      request: const SeasonRewardRequest(
        careerId: 'career-1',
        season: 2026,
        competitionId: 'br-series-a',
        objectiveMet: true,
        leagueChampion: true,
      ),
      globalProgress: const RewardGlobalProgress(),
      existingTransactionIds: const {},
    );

    expect(
      mutation.grants.fold<int>(0, (sum, item) => sum + item.amount),
      280,
    );
    expect(
      mutation.grants.map((item) => item.origin),
      containsAll([
        RewardOrigin.seasonCompleted,
        RewardOrigin.boardObjective,
        RewardOrigin.leagueChampion,
      ]),
    );
  });

  test('persistência usa chaves únicas e commit atômico com o save', () {
    final repository =
        File('lib/core/database/sqlite_career_repository.dart')
            .readAsStringSync();
    final matchController =
        File('lib/app/state/live_match_controller.dart').readAsStringSync();

    expect(repository, contains('event_key TEXT PRIMARY KEY'));
    expect(repository, contains('CREATE TABLE IF NOT EXISTS pm_wallet'));
    expect(repository, contains('CHECK(balance >= 0)'));
    expect(repository, contains('db.transaction((transaction) async'));
    expect(repository, contains('await _insert(transaction, commit.nextCareer)'));
    expect(matchController, contains('fixtureId: live.fixture.id'));
    expect(matchController, contains('_finalizing'));
  });
}
