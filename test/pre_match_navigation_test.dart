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
  test('pré-jogo usa apenas dados existentes do domínio e importa formação', () {
    final preMatch =
        File('lib/features/match/pre_match_screen.dart').readAsStringSync();

    expect(preMatch, contains("import '../../domain/formation/formation.dart';"));
    expect(preMatch, contains('career.formation.label'));
    expect(preMatch, contains('home.stadium.name'));
    expect(preMatch, isNot(contains('home.city')));
  });

}
