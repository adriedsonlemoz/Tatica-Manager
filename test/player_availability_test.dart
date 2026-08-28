import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/data/club_seed.dart';
import 'package:tatica_manager/domain/career/manager_profile.dart';
import 'package:tatica_manager/domain/player/player.dart';
import 'package:tatica_manager/game/career/career_factory.dart';
import 'package:tatica_manager/game/lineup/lineup_engine.dart';
import 'package:tatica_manager/game/player/player_development_engine.dart';

void main() {
  test('lesionado, suspenso e jogador sem condição ficam indisponíveis', () {
    final career = CareerFactory.create(
      careerId: 'availability-status',
      careerName: 'Disponibilidade',
      manager: const ManagerProfile(displayName: 'Técnico Teste'),
      userClubId: clubSeeds.first.id,
      seed: 20260824,
    );
    final player = career.userClub.squad.first;

    expect(
      player
          .copyWith(injury: const PlayerInjury(name: 'Contusão', roundsRemaining: 1))
          .availabilityStatus,
      PlayerAvailabilityStatus.injured,
    );
    expect(
      player
          .copyWith(
            discipline: player.discipline.copyWith(suspendedRounds: 1),
          )
          .availabilityStatus,
      PlayerAvailabilityStatus.suspended,
    );
    expect(
      player.copyWith(condition: 20).availabilityStatus,
      PlayerAvailabilityStatus.lowCondition,
    );
  });

  test('escalação rejeita indisponível e seleção automática o exclui', () {
    final career = CareerFactory.create(
      careerId: 'availability-lineup',
      careerName: 'Escalação',
      manager: const ManagerProfile(displayName: 'Técnico Teste'),
      userClubId: clubSeeds.first.id,
      seed: 20260824,
    );
    final blockedId = career.starterIds.first;
    final squad = career.userClub.squad
        .map(
          (player) => player.id == blockedId
              ? player.copyWith(
                  injury: const PlayerInjury(
                    name: 'Lesão muscular',
                    roundsRemaining: 1,
                  ),
                )
              : player,
        )
        .toList();

    final validation = LineupEngine.validate(
      squad,
      career.starterIds,
      career.formation,
    );
    final automatic = LineupEngine.autoSelect(squad, career.formation);

    expect(validation.availableOnly, isFalse);
    expect(validation.valid, isFalse);
    expect(automatic, isNot(contains(blockedId)));
  });

  test('indisponibilidade antiga é consumida por rodada, não por dia', () {
    final career = CareerFactory.create(
      careerId: 'availability-round',
      careerName: 'Rodadas',
      manager: const ManagerProfile(displayName: 'Técnico Teste'),
      userClubId: clubSeeds.first.id,
      seed: 20260824,
    );
    final player = career.userClub.squad.first.copyWith(
      injury: const PlayerInjury(name: 'Contusão', roundsRemaining: 2),
      discipline: const PlayerDiscipline(suspendedRounds: 2),
    );

    final afterDay = PlayerDevelopmentEngine.recoverDay([player]).single;
    final afterRound =
        PlayerDevelopmentEngine.advanceRoundAvailability([afterDay]).single;

    expect(afterDay.injury?.roundsRemaining, 2);
    expect(afterDay.discipline.suspendedRounds, 2);
    expect(afterRound.injury?.roundsRemaining, 1);
    expect(afterRound.discipline.suspendedRounds, 1);
  });
}
