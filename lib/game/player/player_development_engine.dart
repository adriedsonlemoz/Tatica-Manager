import 'dart:math';

import '../../domain/player/player.dart';

abstract final class PlayerDevelopmentEngine {
  static Player advanceSeason(Player player, int newSeason, Random random, String clubName) {
    final stats = player.stats;
    final age = player.age + 1;
    final performanceSignal = stats.appearances == 0
        ? 0.0
        : (stats.goals * 1.2 + stats.assists + stats.averageRating * 2) / max(1, stats.appearances);

    var chance = .10 + (player.potential - player.overall).clamp(0, 20) * .025;
    if (age <= 18) {
      chance += .25;
    } else if (age <= 20) {
      chance += .18;
    } else if (age <= 21) {
      chance += .10;
    } else if (age >= 32) {
      chance -= .10;
    }
    chance += min(.18, performanceSignal * .02);
    chance *= 1 - (player.fatigue.clamp(0, 100) / 100) * .35;
    if (player.overall >= 88) {
      chance *= .3;
    } else if (player.overall >= 82) {
      chance *= .6;
    }

    var change = 0;
    if (player.overall < player.potential && random.nextDouble() < chance.clamp(0, .9)) {
      change = age <= 20 && chance > .6 && random.nextDouble() < .25 ? 2 : 1;
    }
    if (age >= 34 && player.overall > 65 && random.nextDouble() < .35) {
      change = -1;
    } else if (age >= 32 && player.overall > 70 && random.nextDouble() < .15) {
      change = -1;
    }

    final nextOverall = (player.overall + change).clamp(40, 99).toInt();
    final valueMultiplier = change > 0 ? (change >= 2 ? 1.15 : 1.08) : change < 0 ? .90 : 1.0;
    final history = [
      ...player.history,
      PlayerHistoryEntry(season: newSeason - 1, clubName: clubName, overall: player.overall),
    ];

    return player.copyWith(
      age: age,
      overall: nextOverall,
      marketValue: max(50000, (player.marketValue * valueMultiplier).round()),
      morale: (player.morale + (change > 0 ? 4 : change < 0 ? -3 : 0)).clamp(20, 100).toInt(),
      condition: 100,
      fatigue: 0,
      stats: const PlayerSeasonStats(),
      history: history,
      discipline: const PlayerDiscipline(),
      clearInjury: true,
    );
  }

  /// Recuperação diária entre partidas. Jogadores muito fatigados recebem
  /// prioridade de recuperação, enquanto lesionados recuperam condição mais
  /// lentamente. Lesões e suspensões continuam sendo contadas por rodadas.
  static List<Player> recoverDay(List<Player> players) => players.map((player) {
        final injured = player.injury != null;
        final fatigueRecovery = injured
            ? 2
            : player.fatigue >= 55
                ? 6
                : player.fatigue >= 30
                    ? 5
                    : 4;
        final conditionRecovery = injured
            ? 1
            : player.condition <= 65
                ? 4
                : player.condition <= 85
                    ? 3
                    : 2;
        return player.copyWith(
          condition: min(100, player.condition + conditionRecovery),
          fatigue: max(0, player.fatigue - fatigueRecovery),
        );
      }).toList();

  /// Consome uma rodada de lesão/suspensão que já existia antes do jogo.
  /// Deve ser aplicado antes das consequências da nova partida, para que uma
  /// lesão ou suspensão recém-criada continue ativa para a rodada seguinte.
  static List<Player> advanceRoundAvailability(List<Player> players) => players.map((player) {
        final injury = player.injury;
        final nextInjury = injury == null
            ? null
            : injury.roundsRemaining <= 1
                ? null
                : PlayerInjury(name: injury.name, roundsRemaining: injury.roundsRemaining - 1);
        final suspension = max(0, player.discipline.suspendedRounds - 1);
        return player.copyWith(
          injury: nextInjury,
          clearInjury: injury != null && nextInjury == null,
          discipline: player.discipline.copyWith(suspendedRounds: suspension),
        );
      }).toList();
}
