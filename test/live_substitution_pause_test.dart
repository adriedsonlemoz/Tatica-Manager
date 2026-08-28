import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fluxo prepara várias trocas, confirma em lote e só então retoma', () {
    final screen = File('lib/features/match/match_screen.dart').readAsStringSync();
    final sheet = File('lib/features/match/widgets/live_substitution_sheet.dart').readAsStringSync();
    final controller = File('lib/app/state/live_match_controller.dart').readAsStringSync();

    expect(
      screen,
      contains('showModalBottomSheet<List<LiveSubstitutionChange>>'),
    );
    expect(screen, contains('paused = true;'));
    expect(screen, contains('presentationElapsedMs = 0;'));
    expect(screen, contains('.substituteMany(selections, minute)'));
    expect(
      screen.indexOf('.substituteMany(selections, minute)'),
      lessThan(screen.lastIndexOf('paused = false')),
    );

    expect(sheet, contains('final List<LiveSubstitutionChange> plannedChanges'));
    expect(sheet, contains('_prepareCurrentChange'));
    expect(sheet, contains('Adicionar troca'));
    expect(sheet, contains('Confirmar 1 troca'));
    expect(sheet, contains(r'Confirmar ${plannedChanges.length} trocas'));
    expect(sheet, contains('TROCAS PREPARADAS'));
    expect(sheet, contains('List<LiveSubstitutionChange>.unmodifiable'));
    expect(controller, contains('bool substituteMany('));
    expect(controller, contains('requestedSubstitutions: changes.length'));

    expect(screen, contains('LiveMatchController.maxSubstitutions'));
    expect(screen, contains('LiveMatchController.maxSubstitutionWindows'));
    expect(sheet, contains('substitutionsUsed'));
    expect(sheet, contains('substitutionLimit'));
    expect(sheet, contains('substitutionWindowsUsed'));
    expect(sheet, contains('substitutionWindowLimit'));
  });
}
