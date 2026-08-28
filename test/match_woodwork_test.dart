import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/domain/match/match_models.dart';
import 'package:tatica_manager/game/match/engine/match_trajectory_generator.dart';

void main() {
  test('trajetória da trave aponta para poste e rebate de volta ao campo', () {
    final post = MatchTrajectoryGenerator.woodworkTarget(
      const FieldPoint(.47, .035),
    );
    final rebound = MatchTrajectoryGenerator.woodworkRebound(true, post);

    expect(post.x, .42);
    expect(post.y, .035);
    expect(rebound.y, greaterThan(post.y));
    expect(rebound.y, .16);
  });

  test('evento de bola na trave nasce no Match Engine e não na UI', () {
    final generator = File(
      'lib/game/match/engine/match_event_generator.dart',
    ).readAsStringSync();
    final overlay = File(
      'lib/features/match/widgets/live_match_event_hero.dart',
    ).readAsStringSync();

    expect(generator, contains('type: MatchEventType.woodwork'));
    expect(generator, contains('NA TRAVE!'));
    expect(overlay, contains('MatchEventType.woodwork'));
  });
}
