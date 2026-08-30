import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('escalação do pré-jogo possui retorno sem descartar ajustes', () {
    final preMatch =
        File('lib/features/match/pre_match_screen.dart').readAsStringSync();
    final lineup =
        File('lib/features/lineup/lineup_screen.dart').readAsStringSync();

    expect(preMatch, contains('LineupScreen(showBackButton: true)'));
    expect(lineup, contains('this.showBackButton = false'));
    expect(lineup, contains('Navigator.of(context).pop()'));
  });

  test('pré-jogo usa somente dados existentes e abre tática existente', () {
    final preMatch =
        File('lib/features/match/pre_match_screen.dart').readAsStringSync();
    final layout = File(
      'lib/features/match/pre_match_reference_components.dart',
    ).readAsStringSync();

    expect(preMatch, contains("import '../../domain/formation/formation.dart';"));
    expect(preMatch, contains('final FormationType userFormation = career.formation'));
    expect(preMatch, contains('MaterialPageRoute(builder: (_) => const TacticsScreen())'));
    expect(layout, contains('home.stadium.name'));
    expect('$preMatch\n$layout', isNot(contains('home.city')));
  });
}
