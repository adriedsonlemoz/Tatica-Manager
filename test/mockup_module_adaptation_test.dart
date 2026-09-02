import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calendário usa layout fixo, abas e dados reais da carreira', () {
    final source =
        File('lib/features/calendar/calendar_screen.dart').readAsStringSync();

    expect(source, contains('ClubContextHeader'));
    expect(source, contains('_CalendarTabs'));
    expect(source, contains("(_CalendarTab.agenda, 'Agenda')"));
    expect(source, contains("(_CalendarTab.results, 'Resultados')"));
    expect(source, contains('CareerEventType.training'));
    expect(source, contains('BoxFit.scaleDown'));
    expect(source, isNot(contains('body: ListView')));
  });

  test('táticas adapta somente as escolhas suportadas pelo motor', () {
    final source =
        File('lib/features/tactics/tactics_screen.dart').readAsStringSync();

    expect(source, contains('CompactFormationPitch'));
    expect(source, contains('_TeamStyleBoard'));
    expect(source, contains('LineupEngine.validate'));
    expect(source, contains('Mentality.values'));
    expect(source, contains('BuildUp.values'));
    expect(source, isNot(contains('Instruções')));
    expect(source, isNot(contains('Bolas paradas')));
    expect(source, isNot(contains('ListView')));
  });

  test('escalação compartilha o campo compacto e não rola verticalmente', () {
    final source =
        File('lib/features/lineup/lineup_screen.dart').readAsStringSync();

    expect(source, contains("title: 'Escalação'"));
    expect(source, contains('ClubContextHeader'));
    expect(source, contains('CompactFormationPitch'));
    expect(source, contains('LineupCandidateSheet'));
    expect(source, contains('_BenchPager'));
    expect(source, contains('BoxFit.scaleDown'));
    expect(source, isNot(contains('CustomScrollView')));
    expect(source, isNot(contains('ListView')));
  });

  test('configurações compactas preservam áudio, velocidade e bola', () {
    final settings =
        File('lib/features/settings/settings_screen.dart').readAsStringSync();
    final match = File('lib/features/match/match_screen.dart').readAsStringSync();

    expect(settings, contains("title: 'ÁUDIO'"));
    expect(settings, contains("title: 'Velocidade da partida'"));
    expect(settings, contains('MatchBallPicker('));
    expect(settings, contains('AudioSettingsScreen'));
    expect(settings, isNot(contains('body: ListView')));
    expect(match, contains('100 * settings.matchSpeed'));
  });
}
