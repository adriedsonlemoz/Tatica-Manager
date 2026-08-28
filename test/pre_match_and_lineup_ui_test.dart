import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pré-jogo prioriza titulares e mantém indisponíveis separados', () {
    final source = File('lib/features/match/pre_match_screen.dart').readAsStringSync();
    expect(source, contains('QUEM VAI A CAMPO'));
    expect(source, contains('Aplicar melhor escalação disponível'));
    expect(source, contains('INDISPONÍVEIS'));
    expect(source.indexOf('QUEM VAI A CAMPO'), lessThan(source.indexOf('INDISPONÍVEIS')));
  });

  test('escalação agrupa banco por setores e separa inelegíveis', () {
    final source = File('lib/features/lineup/lineup_screen.dart').readAsStringSync();
    expect(source, contains('GOLEIROS'));
    expect(source, contains('DEFENSORES'));
    expect(source, contains('MEIO-CAMPISTAS'));
    expect(source, contains('ATACANTES'));
    expect(source, contains('INELEGÍVEIS / INDISPONÍVEIS'));
    expect(source, contains('formationLabel: career.formation.label'));
  });
}
