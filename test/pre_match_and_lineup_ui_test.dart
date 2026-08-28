import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pré-jogo prioriza titulares e mantém indisponíveis separados', () {
    final screen = File('lib/features/match/pre_match_screen.dart').readAsStringSync();
    final hero = File('lib/features/match/pre_match_hero_card.dart').readAsStringSync();
    final controls = File('lib/features/match/pre_match_controls.dart').readAsStringSync();
    final lineupCard = File('lib/features/match/pre_match_lineup_card.dart').readAsStringSync();
    final combined = '$screen\n$hero\n$controls\n$lineupCard';

    expect(combined, contains('QUEM VAI A CAMPO'));
    expect(combined, contains('Aplicar melhor escalação disponível'));
    expect(screen, contains('INDISPONÍVEIS'));
    expect(screen, contains('PreMatchLineupCard'));
    expect(screen.indexOf('PreMatchLineupCard'), lessThan(screen.indexOf('_UnavailablePanel')));
  });

  test('pré-jogo premium reutiliza estádio e desenha formação com dados reais', () {
    final screen = File('lib/features/match/pre_match_screen.dart').readAsStringSync();
    final hero = File('lib/features/match/pre_match_hero_card.dart').readAsStringSync();
    final controls = File('lib/features/match/pre_match_controls.dart').readAsStringSync();
    final lineupCard = File('lib/features/match/pre_match_lineup_card.dart').readAsStringSync();

    expect(screen, contains('PreMatchHeroCard'));
    expect(screen, contains('PreMatchDurationCard'));
    expect(screen, contains('PreMatchPlanCard'));
    expect(screen, contains('PreMatchLineupCard'));
    expect(hero, contains("assets/images/home/match_stadium.webp"));
    expect(lineupCard, contains('class _ReadOnlyTacticalPitch'));
    expect(lineupCard, contains('assignment.slot.x'));
    expect(lineupCard, contains('assignment.slot.y'));
    expect(lineupCard, contains(r'OVR ${assignment.effectiveOverall}'));
    expect(hero, contains('HOJE É DIA DE JOGO'));
    expect(controls, contains('DURAÇÃO DA TRANSMISSÃO'));
    expect('$hero\n$controls\n$lineupCard', isNot(contains('Image.network')));
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
