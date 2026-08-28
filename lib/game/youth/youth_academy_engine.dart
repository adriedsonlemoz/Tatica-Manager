import 'dart:math';

import '../../domain/contract/contract.dart';
import '../../domain/player/player.dart';
import '../../domain/season/career_event.dart';
import '../../domain/season/career_state.dart';
import '../lineup/lineup_engine.dart';
import '../player/player_factory.dart';

class YouthPromotionResult {
  const YouthPromotionResult({
    required this.state,
    required this.message,
  });

  final CareerState state;
  final String message;
}

abstract final class YouthAcademyEngine {
  static const int defaultAcademySize = 8;

  static CareerState ensureAcademy(CareerState state) {
    if (state.youthAcademy.isNotEmpty || state.managerUnemployed) return state;
    final club = state.userClub;
    final random = Random(_stableSeed('${state.careerId}|${club.id}|${state.season}|academy'));
    final factory = PlayerFactory(random: random);
    const positions = <PlayerPosition>[
      PlayerPosition.gol,
      PlayerPosition.zag,
      PlayerPosition.ld,
      PlayerPosition.vol,
      PlayerPosition.mc,
      PlayerPosition.mei,
      PlayerPosition.pe,
      PlayerPosition.ca,
    ];
    final base = (club.reputation - 18).clamp(48, 68).toInt();
    final youth = <Player>[];
    for (var index = 0; index < defaultAcademySize; index++) {
      final position = positions[index % positions.length];
      final generated = factory.generatePlayer(
        clubId: club.id,
        position: position,
        baseOverall: base + random.nextInt(7) - 3,
        season: state.season,
      );
      final age = 16 + random.nextInt(4);
      final potential = max(
        generated.overall + 5,
        (generated.overall + 8 + random.nextInt(11)).clamp(60, 94).toInt(),
      );
      youth.add(
        generated.copyWith(
          id: 'academy-${state.careerId}-${state.season}-$index',
          age: age,
          birthDate: DateTime(
            state.season - age,
            1 + random.nextInt(12),
            1 + random.nextInt(27),
          ),
          potential: potential,
          marketValue: max(50000, (generated.marketValue * .45).round()),
          contract: PlayerContract(
            salary: max(1000, (generated.salary * .35).round()),
            endSeason: state.season + 3,
          ),
          shirtNumber: 0,
          condition: 94 + random.nextInt(7),
          fatigue: random.nextInt(5),
          listed: false,
        ),
      );
    }
    return state.copyWith(youthAcademy: youth);
  }

  static YouthPromotionResult promote(CareerState state, String playerId) {
    final player = state.youthAcademy
        .where((item) => item.id == playerId)
        .firstOrNull;
    if (player == null) {
      return YouthPromotionResult(
        state: state,
        message: 'Jogador não encontrado na categoria de base.',
      );
    }
    if (state.userClub.squad.length >= 30) {
      return YouthPromotionResult(
        state: state,
        message: 'O elenco profissional já atingiu o limite de 30 jogadores.',
      );
    }
    final promoted = player.copyWith(
      clubId: state.userClubId,
      contract: PlayerContract(
        salary: max(2000, player.salary),
        endSeason: max(player.contract.endSeason, state.season + 2),
      ),
    );
    final updatedClub = state.userClub.copyWith(
      squad: [...state.userClub.squad, promoted],
    );
    var starters = state.starterIds;
    if (starters.length < 11) {
      starters = LineupEngine.autoSelect(updatedClub.squad, state.formation);
    }
    final event = CareerEvent(
      id: 'academy-promotion-${state.season}-${state.currentDate.millisecondsSinceEpoch}-${player.id}',
      date: state.currentDate,
      type: CareerEventType.info,
      title: 'Promovido ao profissional',
      message:
          '${player.displayName} foi promovido da categoria de base ao elenco principal.',
      playerId: player.id,
      clubId: state.userClubId,
    );
    return YouthPromotionResult(
      state: state.copyWith(
        clubs: state.clubs
            .map((club) => club.id == state.userClubId ? updatedClub : club)
            .toList(growable: false),
        youthAcademy: state.youthAcademy
            .where((item) => item.id != playerId)
            .toList(growable: false),
        starterIds: starters,
        news: [...state.news, event],
      ),
      message: '${player.displayName} agora faz parte do elenco profissional.',
    );
  }

  static int estimatedPotentialLow(Player player) {
    final uncertainty = player.age <= 17 ? 8 : 6;
    return (player.potential - uncertainty).clamp(player.overall, 99).toInt();
  }

  static int estimatedPotentialHigh(Player player) {
    final uncertainty = player.age <= 17 ? 5 : 4;
    return (player.potential + uncertainty).clamp(player.overall, 99).toInt();
  }

  static int _stableSeed(String value) {
    var hash = 23;
    for (final code in value.codeUnits) {
      hash = 0x7fffffff & (hash * 37 + code);
    }
    return hash;
  }
}
