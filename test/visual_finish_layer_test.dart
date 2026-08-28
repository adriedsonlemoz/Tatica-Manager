import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/game/player/player_avatar_identity.dart';

void main() {
  test('stablePlayerSeed keeps the same visual identity seed for a player id', () {
    expect(stablePlayerSeed('player-permanent-42'), stablePlayerSeed('player-permanent-42'));
    expect(stablePlayerSeed('player-permanent-42'), isNot(stablePlayerSeed('player-permanent-43')));
  });
}
