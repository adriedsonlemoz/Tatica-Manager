import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/domain/match/match_models.dart';
import 'package:tatica_manager/game/match/renderer/match_player_motion.dart';

void main() {
  test('pênalti reposiciona somente atletas próximos da área', () {
    final attacking = <FieldPoint>[
      const FieldPoint(.50, .90),
      const FieldPoint(.15, .30),
      const FieldPoint(.38, .24),
      const FieldPoint(.62, .20),
      const FieldPoint(.85, .34),
      const FieldPoint(.27, .58),
      const FieldPoint(.50, .54),
      const FieldPoint(.73, .58),
      const FieldPoint(.18, .35),
      const FieldPoint(.50, .34),
      const FieldPoint(.82, .35),
    ];
    final defending = <FieldPoint>[
      const FieldPoint(.50, .10),
      const FieldPoint(.15, .20),
      const FieldPoint(.38, .30),
      const FieldPoint(.62, .22),
      const FieldPoint(.85, .31),
      const FieldPoint(.27, .42),
      const FieldPoint(.50, .46),
      const FieldPoint(.73, .42),
      const FieldPoint(.18, .65),
      const FieldPoint(.50, .71),
      const FieldPoint(.82, .65),
    ];
    final attackingBefore = [...attacking];
    final defendingBefore = [...defending];

    final moved = MatchPlayerMotion.penaltySetup(
      attacking,
      defending,
      attackingHome: true,
      takerIndex: 9,
      penaltySpot: const FieldPoint(.50, .12),
    );

    expect(moved.$1, containsAll(<int>{2, 3, 9}));
    expect(moved.$2, containsAll(<int>{0, 1, 3}));
    expect(moved.$1.length, lessThan(6));
    expect(moved.$2.length, lessThan(6));
    expect(attacking[0].x, attackingBefore[0].x);
    expect(attacking[0].y, attackingBefore[0].y);
    expect(attacking[5].x, attackingBefore[5].x);
    expect(attacking[5].y, attackingBefore[5].y);
    expect(defending[6].x, defendingBefore[6].x);
    expect(defending[6].y, defendingBefore[6].y);
  });

  test('movimento acelera, freia e termina exatamente no alvo', () {
    final current = <FieldPoint>[const FieldPoint(.20, .20)];
    final targets = <FieldPoint>[const FieldPoint(.80, .65)];
    final states = <MatchPlayerMotionState>[
      MatchPlayerMotionState(seed: 17),
    ];

    for (var frame = 0; frame < 12; frame++) {
      MatchPlayerMotion.moveTeam(
        current,
        targets,
        states,
        1 / 60,
        replay: false,
      );
    }
    expect(current.single.x, greaterThan(.20));
    expect(current.single.x, lessThan(.80));
    expect(states.single.movementAmount, greaterThan(0));

    for (var frame = 0; frame < 240; frame++) {
      MatchPlayerMotion.moveTeam(
        current,
        targets,
        states,
        1 / 60,
        replay: false,
      );
    }
    expect(current.single.x, closeTo(.80, .001));
    expect(current.single.y, closeTo(.65, .001));
    expect(states.single.movementAmount, closeTo(0, .001));
  });

  test('atraso preparado evita saída simultânea dos jogadores', () {
    final current = <FieldPoint>[const FieldPoint(.20, .20)];
    final targets = <FieldPoint>[const FieldPoint(.70, .20)];
    final state = MatchPlayerMotionState(seed: 23)
      ..prepareNextTransition(delay: .20, curveScale: .5);

    MatchPlayerMotion.moveTeam(
      current,
      targets,
      <MatchPlayerMotionState>[state],
      .10,
      replay: false,
    );
    expect(current.single.x, closeTo(.20, .0001));

    MatchPlayerMotion.moveTeam(
      current,
      targets,
      <MatchPlayerMotionState>[state],
      .10,
      replay: false,
    );
    expect(current.single.x, closeTo(.20, .0001));

    MatchPlayerMotion.moveTeam(
      current,
      targets,
      <MatchPlayerMotionState>[state],
      .10,
      replay: false,
    );
    expect(current.single.x, greaterThan(.20));
  });
}
