import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pré-jogo segue a referência aprovada sem abas ou dados inventados', () {
    final screen =
        File('lib/features/match/pre_match_screen.dart').readAsStringSync();
    final layout = File(
      'lib/features/match/pre_match_reference_components.dart',
    ).readAsStringSync();
    final combined = '$screen\n$layout';

    expect(screen, contains("GameTopBar(title: 'Pré-jogo')"));
    expect(screen, contains('PreMatchReferenceHero'));
    expect(screen, contains('PreMatchTacticalComparison'));
    expect(screen, contains('PreMatchProbableLineups'));
    expect(screen, contains('PreMatchAbsences'));
    expect(screen, contains('PreMatchActionCards'));
    expect(screen, contains('PreMatchBottomActions'));
    expect(layout, contains('CONFRONTO TÁTICO'));
    expect(layout, contains('ESCALAÇÃO PROVÁVEL'));
    expect(layout, contains('DESFALQUES'));
    expect(layout, contains('ESCALAÇÃO'));
    expect(layout, contains('TÁTICA'));
    expect(layout, contains('UNIFORMES'));
    expect(layout, contains('JOGAR PARTIDA'));
    expect(layout, contains('SIMULAR'));
    expect(combined, isNot(contains('Preparação da partida')));
    expect(combined.toLowerCase(), isNot(contains('árbitro')));
    expect(combined.toLowerCase(), isNot(contains('clima')));
    expect(combined.toLowerCase(), isNot(contains('técnico')));
  });

  test('confronto tático e rival usam a mesma lógica real da partida', () {
    final screen =
        File('lib/features/match/pre_match_screen.dart').readAsStringSync();
    final layout = File(
      'lib/features/match/pre_match_reference_components.dart',
    ).readAsStringSync();

    expect(screen, contains('LiveRoundSimulator.formationFor(opponent)'));
    expect(screen, contains('LiveRoundSimulator.tacticFor(opponent)'));
    expect(screen, contains('LineupEngine.autoSelect('));
    expect(screen, contains('MatchStrengthCalculator.calculate('));
    expect(screen, contains('opponentValidation.assignments'));
    expect(layout, contains('FormationCatalog.slots[formation]'));
    expect(layout, contains('userStrength.attack'));
    expect(layout, contains('opponentStrength.attack'));
    expect(layout, contains('userStrength.midfield'));
    expect(layout, contains('opponentStrength.defense'));
    expect(layout, contains('home.stadium.name'));
    expect('$screen\n$layout', isNot(contains('home.city')));
  });

  test('uniformes abrem em popup e mantêm resolução automática de conflito', () {
    final screen =
        File('lib/features/match/pre_match_screen.dart').readAsStringSync();
    final kits = File(
      'lib/features/match/pre_match_kit_selector.dart',
    ).readAsStringSync();

    expect(screen, contains('showDialog<void>('));
    expect(screen, contains('PreMatchKitSelector('));
    expect(screen, contains('MatchKitResolver.resolve('));
    expect(kits, contains('MatchKitSlot.values'));
    expect(kits, contains('Combinação automática sem conflito de cores'));
    expect(screen, isNot(contains('PreMatchDurationCard')));
  });

  test('simular usa o mesmo LiveMatchController e conclui a partida', () {
    final screen =
        File('lib/features/match/pre_match_screen.dart').readAsStringSync();

    expect(screen, contains('Future<void> _simulateMatch()'));
    expect(screen, contains('controller.prepareMatch()'));
    expect(screen, contains('await controller.finishMatch()'));
    expect(screen, contains('ResultScreen(result: result)'));
    expect(screen, contains('MatchScreen(kitSelection: kitSelection)'));
  });

  test('escalação agrupa banco por setores e separa inelegíveis', () {
    final source =
        File('lib/features/lineup/lineup_screen.dart').readAsStringSync();
    expect(source, contains('GOLEIROS'));
    expect(source, contains('DEFENSORES'));
    expect(source, contains('MEIO-CAMPISTAS'));
    expect(source, contains('ATACANTES'));
    expect(source, contains('INELEGÍVEIS / INDISPONÍVEIS'));
    expect(source, contains('formationLabel: career.formation.label'));
  });
}
