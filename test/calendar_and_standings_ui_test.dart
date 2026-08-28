import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calendário possui visão mensal e detalhes de partidas', () {
    final source =
        File('lib/features/calendar/calendar_screen.dart').readAsStringSync();

    expect(source, contains('_MonthGrid'));
    expect(source, contains('_selectedDate'));
    expect(source, contains('_showFixtureDetails'));
    expect(source, contains('matchHistory'));
    expect(source, contains('showDialog<void>'));
  });

  test('classificação coloca PTS após o clube e mostra zonas', () {
    final source =
        File('lib/features/standings/standings_screen.dart').readAsStringSync();
    final catalog =
        File('lib/data/competition_catalog.dart').readAsStringSync();

    final club = source.indexOf("Text('Clube')");
    final points = source.indexOf("Text('PTS')");
    final played = source.indexOf("Text('J')");
    expect(club, greaterThanOrEqualTo(0));
    expect(points, greaterThan(club));
    expect(played, greaterThan(points));
    expect(source, contains('Libertadores'));
    expect(source, contains('Sul-Americana'));
    expect(catalog, contains('Campeonato Brasileiro Série A'));
    expect(source, contains('_MovementIndicator'));
    expect(source, contains('positionMovement'));
    expect(source, contains('Rebaixamento'));
  });

  test('home mostra classificação compacta completa e avanço diário contextual', () {
    final home = File('lib/features/home/home_screen.dart').readAsStringSync();
    final widgets = File('lib/features/home/home_overview_widgets.dart')
        .readAsStringSync();

    expect(home, contains('HomeCompactStandings'));
    expect(widgets, contains("_StandingCell('J'"));
    expect(widgets, contains("_StandingCell('V'"));
    expect(widgets, contains("_StandingCell('E'"));
    expect(widgets, contains("_StandingCell('D'"));
    expect(widgets, contains("_StandingCell('SG'"));
    expect(widgets, contains("_StandingCell('PTS'"));
    expect(home, contains('HomeDailyAdvancePanel'));
    expect(widgets, contains('PREPARAÇÃO DIÁRIA'));
    expect(widgets, contains('recuperação, contratos, mercado, notícias'));
    expect(home, contains('final totalRounds = career.fixtures.fold<int>'));
    expect(home, isNot(contains(r'Rodada ${career.currentRound}/38')));
  });

}
