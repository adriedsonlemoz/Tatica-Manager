import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/domain/formation/formation.dart';
import 'package:tatica_manager/domain/player/player.dart';
import 'package:tatica_manager/domain/tactic/tactic.dart';
import 'package:tatica_manager/game/lineup/lineup_engine.dart';
import 'package:tatica_manager/game/match/engine/match_strength_calculator.dart';
import 'package:tatica_manager/game/player/player_factory.dart';

void main() {
  group('LineupEngine - posição efetiva', () {
    test('assign preserva a ordem persistida dos slots', () {
      final squad = PlayerFactory(random: Random(11)).generateSquad(
        clubId: 'club-test',
        clubReputation: 82,
        season: 2026,
      );
      final ids = squad.take(11).map((player) => player.id).toList();
      final assignments = LineupEngine.assign(squad, ids, FormationType.f433);

      expect(assignments, hasLength(11));
      for (var index = 0; index < assignments.length; index++) {
        expect(assignments[index].player.id, ids[index]);
        expect(
          assignments[index].slot.id,
          FormationCatalog.slots[FormationType.f433]![index].id,
        );
      }
    });

    test('autoescalação nunca seleciona atleta indisponível', () {
      final factory = PlayerFactory(random: Random(21));
      final squad = factory.generateSquad(
        clubId: 'club-test',
        clubReputation: 84,
        season: 2026,
      );
      final injured = squad.first.copyWith(
        injury: const PlayerInjury(name: 'Teste', roundsRemaining: 2),
      );
      final updated = [injured, ...squad.skip(1)];

      final selected = LineupEngine.autoSelect(updated, FormationType.f433);

      expect(selected, hasLength(11));
      expect(selected, isNot(contains(injured.id)));
    });

    test('improvisação reduz OVR e a força usada pelo Match Engine', () {
      final attacker = PlayerFactory(random: Random(31)).generatePlayer(
        clubId: 'club-test',
        position: PlayerPosition.ca,
        baseOverall: 86,
        season: 2026,
      ).copyWith(condition: 100, fatigue: 0, morale: 70);
      final naturalDefender = attacker.copyWith(
        primaryPosition: PlayerPosition.zag,
        secondaryPositions: const [],
      );
      const slot = FormationSlot(
        id: 'cb-test',
        role: PlayerPosition.zag,
        x: .5,
        y: .75,
      );

      final improvisedOverall = LineupEngine.effectiveOverall(
        attacker,
        PlayerPosition.zag,
      );
      final naturalOverall = LineupEngine.effectiveOverall(
        naturalDefender,
        PlayerPosition.zag,
      );
      expect(improvisedOverall, lessThan(naturalOverall));

      final improvisedStrength = MatchStrengthCalculator.calculate(
        [
          AssignedPlayer(
            slot: slot,
            player: attacker,
            fit: LineupEngine.positionFit(attacker, slot.role),
          ),
        ],
        const Tactic(),
      );
      final naturalStrength = MatchStrengthCalculator.calculate(
        [
          AssignedPlayer(
            slot: slot,
            player: naturalDefender,
            fit: LineupEngine.positionFit(naturalDefender, slot.role),
          ),
        ],
        const Tactic(),
      );
      expect(improvisedStrength.defense, lessThan(naturalStrength.defense));
    });

    test('candidatos priorizam OVR efetivo e adequação à função', () {
      final factory = PlayerFactory(random: Random(41));
      final natural = factory
          .generatePlayer(
            clubId: 'club-test',
            position: PlayerPosition.zag,
            baseOverall: 78,
            season: 2026,
          )
          .copyWith(overall: 80, condition: 100, fatigue: 0, morale: 70);
      final improvised = factory
          .generatePlayer(
            clubId: 'club-test',
            position: PlayerPosition.ca,
            baseOverall: 86,
            season: 2026,
          )
          .copyWith(overall: 86, condition: 100, fatigue: 0, morale: 70);

      final candidates = LineupEngine.candidatesForRole(
        [improvised, natural],
        PlayerPosition.zag,
      );

      expect(candidates.first.player.id, natural.id);
      expect(candidates.first.fit, greaterThan(candidates.last.fit));
    });
  });
}
