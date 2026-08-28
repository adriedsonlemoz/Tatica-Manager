import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fluxo de substituição pausa, confirma, aplica no controller e só então retoma', () {
    final screen = File('lib/features/match/match_screen.dart').readAsStringSync();
    final sheet = File('lib/features/match/widgets/live_substitution_sheet.dart').readAsStringSync();

    expect(screen, contains('showModalBottomSheet<LiveSubstitutionSelection>'));
    expect(screen, contains('paused = true;'));
    expect(screen, contains('presentationElapsedMs = 0;'));
    expect(screen, contains('selection.outgoingId'));
    expect(screen, contains('selection.incomingId'));
    expect(screen, contains('.substitute('));
    expect(screen.indexOf('.substitute('), lessThan(screen.lastIndexOf('paused = false')));

    expect(sheet, contains('class LiveSubstitutionSelection'));
    expect(sheet, contains('Navigator.of(context).pop('));
    expect(sheet, contains('LiveSubstitutionSelection('));
    expect(sheet, isNot(contains('onConfirm')));
  });
}
