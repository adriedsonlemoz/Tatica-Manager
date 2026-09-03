import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/domain/formation/formation.dart';
import 'package:tatica_manager/domain/match/match_models.dart';
import 'package:tatica_manager/features/match/live_match_statistics.dart';
import 'package:tatica_manager/game/match/renderer/match_pitch_formation.dart';
import 'package:tatica_manager/game/match/renderer/match_player_motion.dart';

void main() {
  test('campo usa os onze pontos da formação real para cada lado', () {
    final home442 = MatchPitchFormation.points(
      FormationType.f442,
      home: true,
    );
    final home352 = MatchPitchFormation.points(
      FormationType.f352,
      home: true,
    );
    final away442 = MatchPitchFormation.points(
      FormationType.f442,
      home: false,
    );

    expect(home442, hasLength(11));
    expect(home352, hasLength(11));
    expect(home442[4].y, isNot(home352[4].y));
    expect(away442.first.x, home442.first.x);
    expect(away442.first.y, closeTo(1 - home442.first.y, .0001));
  });

  test('posse ao vivo não produz extremos com poucos eventos', () {
    const events = [
      MatchEvent(
        minute: 2,
        sequence: 1,
        type: MatchEventType.pass,
        teamId: 'away',
        text: 'Passe visitante.',
      ),
    ];

    final early = LiveMatchStatistics.possession(
      events: events,
      minute: 2,
      homeId: 'home',
      awayId: 'away',
      targetHomePossession: 54,
      throughSequence: 1,
    );
    final finalValue = LiveMatchStatistics.possession(
      events: events,
      minute: 90,
      homeId: 'home',
      awayId: 'away',
      targetHomePossession: 54,
    );

    expect(early.$1, inInclusiveRange(30, 70));
    expect(early.$2, inInclusiveRange(30, 70));
    expect(early, isNot((0, 100)));
    expect(finalValue, (54, 46));
  });

  test('bloco acompanha a bola sem abandonar a formação', () {
    final base = MatchPitchFormation.points(
      FormationType.f433,
      home: true,
    );
    final advanced = MatchPlayerMotion.phaseShape(
      base,
      const FieldPoint(.30, .18),
      home: true,
      inPossession: true,
    );

    expect(advanced, hasLength(base.length));
    expect(advanced[6].y, lessThan(base[6].y));
    expect(advanced[9].y, lessThan(base[9].y));
    expect(
      (advanced.first.y - base.first.y).abs(),
      lessThan((advanced[9].y - base[9].y).abs()),
    );
    expect(
      advanced.every((point) => point.x >= .07 && point.x <= .93),
      isTrue,
    );
    expect(
      advanced.every((point) => point.y >= .06 && point.y <= .94),
      isTrue,
    );
  });

  test('renderer conecta formação, etiquetas compactas e leitura da bola', () {
    final screen = File(
      'lib/features/match/match_screen.dart',
    ).readAsStringSync();
    final renderer = File(
      'lib/game/match/renderer/match_pitch_game.dart',
    ).readAsStringSync();
    final labels = File(
      'lib/game/match/renderer/match_player_labels.dart',
    ).readAsStringSync();
    final visuals = File(
      'lib/game/match/renderer/match_pitch_visuals.dart',
    ).readAsStringSync();
    final goals = File(
      'lib/game/match/renderer/match_goal_visuals.dart',
    ).readAsStringSync();

    expect(screen, contains('homeFormation: live.homeFormation'));
    expect(screen, contains('awayFormation: live.awayFormation'));
    expect(renderer, contains('_involvedPlayerIds'));
    expect(labels, contains('candidate.active || candidate.involved'));
    expect(labels, contains('if (collisions.isEmpty) return'));
    expect(labels, isNot(contains('bestEffort')));
    expect(visuals, contains('radius: 5.05 * scale'));
    expect(goals, contains('field.height * .29'));
    expect(goals, contains('math.min(15.0'));
  });
}
