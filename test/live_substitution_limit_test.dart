import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('controller limita a cinco substituições e impede retorno de substituído', () {
    final controller =
        File('lib/app/state/live_match_controller.dart').readAsStringSync();
    final screen =
        File('lib/features/match/match_screen.dart').readAsStringSync();

    expect(controller, contains('static const int maxSubstitutions = 5;'));
    expect(controller, contains('substitutionsUsed >= maxSubstitutions'));
    expect(controller, contains('final substitutionsUsed = previousSubstitutions.length;'));
    expect(
      controller,
      isNot(contains('final substitutionsUsed = previousSubstitutions.length;\n        .where(')),
    );
    expect(controller, contains('Limite de \$maxSubstitutions substituições'));
    expect(controller, contains('alreadySubstitutedOut.contains(incomingId)'));
    expect(controller, contains('Jogador substituído não pode retornar à partida.'));
    expect(screen, contains('substitutionsUsed >= LiveMatchController.maxSubstitutions'));
  });
}
