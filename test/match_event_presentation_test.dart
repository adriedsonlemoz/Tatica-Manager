import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/domain/match/match_models.dart';

void main() {
  test('tipos de evento possuem rótulos claros em português', () {
    expect(MatchEventType.yellow.label, 'Cartão amarelo');
    expect(MatchEventType.red.label, 'Cartão vermelho');
    expect(MatchEventType.goal.label, 'Gol');
    expect(MatchEventType.injury.label, 'Lesão');
    expect(MatchEventType.woodwork.label, 'Na trave');
  });

  test('narração e telas da partida não usam abreviação do clube', () {
    final generator = File(
      'lib/game/match/engine/match_event_generator.dart',
    ).readAsStringSync();
    final live =
        File('lib/features/match/match_screen.dart').readAsStringSync();
    final result =
        File('lib/features/match/result_screen.dart').readAsStringSync();

    expect(generator, isNot(contains('.shortName')));
    expect(live, isNot(contains('.shortName')));
    expect(result, isNot(contains('.shortName')));
    expect(generator, contains('Cartão amarelo:'));
    expect(result, contains('MatchEventType.yellow'));
  });
}
