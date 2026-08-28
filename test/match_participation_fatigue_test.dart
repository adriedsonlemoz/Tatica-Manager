import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('desgaste pós-jogo usa a escalação, não apenas jogadores com eventos', () {
    final controller =
        File('lib/app/state/live_match_controller.dart').readAsStringSync();
    final impact =
        File('lib/game/match/match_career_impact_engine.dart').readAsStringSync();

    expect(controller, contains('participantsByClub'));
    expect(controller, contains('...career.starterIds'));
    expect(controller, contains('...live.userStarterIds'));
    expect(controller, contains('MatchCareerImpactEngine.apply'));
    expect(impact, contains('player.fatigue + max'));
    expect(impact, contains('starts: base.starts + (isStarter ? 1 : 0)'));
    expect(impact, contains('minutes: base.minutes + minutesPlayed'));
    expect(impact, contains('player.condition - max'));
  });
}
