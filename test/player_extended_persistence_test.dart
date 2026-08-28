import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/domain/player/player.dart';
import 'package:tatica_manager/game/player/player_factory.dart';

void main() {
  test('foto personalizada e forma recente sobrevivem ao JSON', () {
    final player = PlayerFactory(random: Random(51)).generatePlayer(
      clubId: 'club-test',
      position: PlayerPosition.mc,
      baseOverall: 80,
      season: 2026,
    ).copyWith(
      customAvatarPath: '/private/player_photos/test.png',
      recentRatings: const [6.5, 7.1, 6.9, 8.0, 7.4],
    );

    final restored = Player.fromJson(player.toJson());

    expect(restored.customAvatarPath, player.customAvatarPath);
    expect(restored.recentRatings, player.recentRatings);
    expect(restored.recentFormAverage, closeTo(7.18, .001));
  });

  test('save antigo sem novos campos continua retrocompatível', () {
    final player = PlayerFactory(random: Random(61)).generatePlayer(
      clubId: 'club-test',
      position: PlayerPosition.le,
      baseOverall: 75,
      season: 2026,
    );
    final legacyJson = player.toJson()
      ..remove('customAvatarPath')
      ..remove('recentRatings');

    final restored = Player.fromJson(legacyJson);

    expect(restored.customAvatarPath, isNull);
    expect(restored.recentRatings, isEmpty);
    expect(restored.recentFormAverage, isNull);
  });

  test('forma recente limita leitura a cinco partidas', () {
    final player = PlayerFactory(random: Random(71)).generatePlayer(
      clubId: 'club-test',
      position: PlayerPosition.pd,
      baseOverall: 78,
      season: 2026,
    );
    final json = player.toJson()
      ..['recentRatings'] = [5.9, 6.2, 6.8, 7.0, 7.3, 8.1];

    final restored = Player.fromJson(json);

    expect(restored.recentRatings, hasLength(5));
  });
}
