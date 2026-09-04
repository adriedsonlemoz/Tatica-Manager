import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/data/club_seed.dart';
import 'package:tatica_manager/domain/career/manager_profile.dart';
import 'package:tatica_manager/domain/training/training_plan.dart';
import 'package:tatica_manager/game/assistant/technical_assistant_engine.dart';
import 'package:tatica_manager/game/career/career_factory.dart';
import 'package:tatica_manager/game/season/daily_career_engine.dart';
import 'package:tatica_manager/game/training/training_engine.dart';

void main() {
  test('plano de treino é persistente e retrocompatível', () {
    const plan = TrainingPlan(
      focus: TrainingFocus.recovery,
      intensity: TrainingIntensity.light,
      managedByAssistant: false,
    );
    final restored = TrainingPlan.fromJson(plan.toJson());
    final legacy = TrainingPlan.fromJson(const {});

    expect(restored.focus, TrainingFocus.recovery);
    expect(restored.intensity, TrainingIntensity.light);
    expect(restored.managedByAssistant, isFalse);
    expect(legacy.focus, TrainingFocus.balanced);
    expect(legacy.managedByAssistant, isTrue);
  });

  test('IA ajusta treino pela proximidade da partida e estado do elenco', () {
    final career = CareerFactory.create(
      careerId: 'assistant-training',
      careerName: 'Treino assistido',
      manager: const ManagerProfile(displayName: 'Técnico Teste'),
      userClubId: clubSeeds.first.id,
      seed: 20260904,
    );
    final initial = TrainingEngine.recommend(career);
    final tiredPlayer = career.userClub.squad.first.copyWith(
      condition: 60,
      fatigue: 60,
    );
    final recovered = TrainingEngine.applyDay(
      [tiredPlayer],
      plan: const TrainingPlan(
        focus: TrainingFocus.recovery,
        intensity: TrainingIntensity.light,
      ),
      starterIds: {tiredPlayer.id},
    );

    expect(initial.focus, TrainingFocus.tactical);
    expect(initial.intensity, TrainingIntensity.light);
    expect(recovered.single.condition, greaterThan(64));
    expect(recovered.single.fatigue, lessThan(54));
  });

  test('avanço diário aplica plano automático e registra o foco usado', () {
    final career = CareerFactory.create(
      careerId: 'assistant-daily',
      careerName: 'Treino diário',
      manager: const ManagerProfile(displayName: 'Técnico Teste'),
      userClubId: clubSeeds.first.id,
      seed: 20260904,
    );
    final advance = DailyCareerEngine.advance(career);

    expect(advance.state.trainingPlan.managedByAssistant, isTrue);
    expect(advance.state.trainingPlan.focus, TrainingFocus.tactical);
    expect(
      advance.events.any(
        (event) => event.title == 'Treino: tático',
      ),
      isTrue,
    );
  });

  test('auxiliar produz escalação válida e leitura do próximo adversário', () {
    final career = CareerFactory.create(
      careerId: 'assistant-report',
      careerName: 'Relatório técnico',
      manager: const ManagerProfile(displayName: 'Técnico Teste'),
      userClubId: clubSeeds.first.id,
      seed: 20260904,
    );
    final report = TechnicalAssistantEngine.analyze(career);

    expect(report.recommendedStarterIds, hasLength(11));
    expect(report.opponentName, isNotNull);
    expect(report.readiness, inInclusiveRange(0, 100));
    expect(report.summary, isNotEmpty);
    expect(report.priorities, isNotEmpty);
  });

  test('tela integra IA local sem serviço remoto ou motor paralelo', () {
    final screen = File(
      'lib/features/assistant/technical_assistant_screen.dart',
    ).readAsStringSync();
    final engine = File(
      'lib/game/assistant/technical_assistant_engine.dart',
    ).readAsStringSync();
    final more = File(
      'lib/features/more/more_screen.dart',
    ).readAsStringSync();

    expect(screen, contains('Aplicar recomendações'));
    expect(screen, contains('Plano manual'));
    expect(screen, contains('fit: BoxFit.scaleDown'));
    expect(more, contains("label: 'Auxiliar técnico'"));
    expect(engine, contains('MatchStrengthCalculator.calculate'));
    expect(engine, contains('LiveRoundSimulator.tacticFor'));
    expect(engine, isNot(contains('http')));
    expect(engine, isNot(contains('MatchEngine(')));
  });
}
