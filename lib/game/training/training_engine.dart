import 'dart:math';

import '../../domain/player/player.dart';
import '../../domain/season/career_state.dart';
import '../../domain/training/training_plan.dart';
import '../player/player_development_engine.dart';

abstract final class TrainingEngine {
  static TrainingPlan recommend(CareerState state) {
    final players = state.userClub.squad;
    if (players.isEmpty) return const TrainingPlan();
    final available = players.where((player) => player.injury == null).toList();
    final sample = available.isEmpty ? players : available;
    final condition = _average(sample.map((player) => player.condition));
    final fatigue = _average(sample.map((player) => player.fatigue));
    final days = state.daysUntilNextMatch ?? 7;

    if (days <= 1 || condition < 72 || fatigue >= 48) {
      return const TrainingPlan(
        focus: TrainingFocus.recovery,
        intensity: TrainingIntensity.light,
      );
    }
    if (days <= 3) {
      return const TrainingPlan(
        focus: TrainingFocus.tactical,
        intensity: TrainingIntensity.light,
      );
    }
    if (days >= 5 && fatigue < 24 && condition >= 86) {
      return const TrainingPlan(
        focus: TrainingFocus.physical,
        intensity: TrainingIntensity.normal,
      );
    }
    if (days >= 4 && fatigue < 34) {
      return const TrainingPlan(
        focus: TrainingFocus.technical,
        intensity: TrainingIntensity.normal,
      );
    }
    return const TrainingPlan();
  }

  static List<Player> applyDay(
    List<Player> players, {
    required TrainingPlan plan,
    required Set<String> starterIds,
  }) {
    final recovered = PlayerDevelopmentEngine.recoverDay(players);
    return recovered.map((player) {
      if (player.injury != null) return player;
      final effects = _effects(plan, starter: starterIds.contains(player.id));
      return player.copyWith(
        condition: (player.condition + effects.condition)
            .clamp(0, 100)
            .toInt(),
        fatigue: (player.fatigue + effects.fatigue).clamp(0, 100).toInt(),
        morale: (player.morale + effects.morale).clamp(20, 100).toInt(),
      );
    }).toList(growable: false);
  }

  static ({int condition, int fatigue, int morale}) _effects(
    TrainingPlan plan, {
    required bool starter,
  }) {
    final focus = switch (plan.focus) {
      TrainingFocus.recovery => (condition: 2, fatigue: -2, morale: 0),
      TrainingFocus.balanced => (condition: 0, fatigue: 0, morale: 0),
      TrainingFocus.tactical =>
        (condition: 0, fatigue: 1, morale: starter ? 1 : 0),
      TrainingFocus.physical => (condition: -1, fatigue: 2, morale: 0),
      TrainingFocus.technical => (condition: 0, fatigue: 1, morale: 0),
    };
    final intensity = switch (plan.intensity) {
      TrainingIntensity.light => (condition: 1, fatigue: -1),
      TrainingIntensity.normal => (condition: 0, fatigue: 0),
      TrainingIntensity.high => (condition: -1, fatigue: 2),
    };
    return (
      condition: focus.condition + intensity.condition,
      fatigue: focus.fatigue + intensity.fatigue,
      morale: focus.morale,
    );
  }

  static double _average(Iterable<int> values) {
    final list = values.toList(growable: false);
    if (list.isEmpty) return 0;
    return list.reduce((first, second) => first + second) / max(1, list.length);
  }
}
