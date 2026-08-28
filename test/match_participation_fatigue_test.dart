import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('desgaste pós-jogo usa a escalação, não apenas jogadores com eventos', () {
    final source =
        File('lib/app/state/live_match_controller.dart').readAsStringSync();

    expect(source, contains('participantsByClub'));
    expect(source, contains('...career.starterIds'));
    expect(source, contains('...live.userStarterIds'));
    expect(source, contains('player.fatigue + max'));
    expect(source, contains('starts: player.stats.starts + (isStarter ? 1 : 0)'));
    expect(source, contains('minutes: player.stats.minutes + minutesPlayed')); 
    expect(source, contains('player.condition - max')); 
  });
}
