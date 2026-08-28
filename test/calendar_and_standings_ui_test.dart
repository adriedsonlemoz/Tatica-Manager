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

  test('home premium mantém classificação, avanço contextual e dados reais', () {
    final home = File('lib/features/home/home_screen.dart').readAsStringSync();
    final overview = File('lib/features/home/home_overview_widgets.dart')
        .readAsStringSync();
    final rankings = File('lib/features/home/home_dashboard_rankings.dart')
        .readAsStringSync();
    final news = File('lib/features/home/home_dashboard_news.dart')
        .readAsStringSync();
    final dashboard = File('lib/features/home/home_dashboard_match.dart')
        .readAsStringSync();
    final board = File('lib/features/home/home_dashboard_board.dart')
        .readAsStringSync();
    final controls = File('lib/features/home/home_dashboard_controls.dart')
        .readAsStringSync();
    final visuals = File('lib/features/home/home_visual_components.dart')
        .readAsStringSync();
    final pubspec = File('pubspec.yaml').readAsStringSync();

    expect(home, contains('HomeClubHeader'));
    expect(home, contains('_HomeBackdrop'));
    expect(
      home,
      contains('      );\n}\n\nclass _DayAdvanceTransition extends StatelessWidget'),
    );
    expect(home, contains('HomeFinanceGrid'));
    expect(home, contains('monthIncome'));
    expect(home, contains('monthExpenses'));
    expect(home, contains('HomeMainOverview'));
    expect(home, contains('HomeAdvanceStrip'));
    expect(home, contains('HomeNewsHighlights'));
    expect(home, contains('HomeLeagueAndScorers'));
    expect(rankings, contains('HomeCompactStandings'));
    expect(rankings, isNot(contains('this.padding = const EdgeInsets.all(12)')));
    expect(news, isNot(contains('this.padding = const EdgeInsets.all(12)')));
    expect(overview, contains("_StandingCell('J'"));
    expect(overview, contains("_StandingCell('V'"));
    expect(overview, contains("_StandingCell('E'"));
    expect(overview, contains("_StandingCell('D'"));
    expect(overview, contains("_StandingCell('SG'"));
    expect(overview, contains("_StandingCell('PTS'"));
    expect(dashboard, contains('PREPARAÇÃO EM ANDAMENTO'));
    expect(dashboard, contains('height: 142'));
    expect(board, contains('ESTÁDIO'));
    expect(board, contains('HomeVisualAssets.stadiumAerial'));
    expect(dashboard, contains('HomeVisualAssets.matchStadium'));
    expect(controls, contains('PANORAMA DA TEMPORADA'));
    expect(controls, contains('_SeasonTrendPainter'));
    expect(home, contains(r"label: 'Departamento\nMédico'"));
    expect(home, contains('onSeasonTap'));
    expect(visuals, contains('class HomeClubCrest'));
    expect(pubspec, contains('assets/images/home/'));
    expect(File('assets/images/home/match_stadium.webp').existsSync(), isTrue);
    expect(File('assets/images/home/stadium_aerial.webp').existsSync(), isTrue);
    expect(dashboard, isNot(contains('ÚLTIMAS 5 PARTIDAS')));
    expect(rankings, contains('compactColumns: dense && canSplit'));
    expect(home, contains('NewsHighlightsScreen'));
    expect(home, isNot(contains('onNotificationsTap')));
    expect(home, contains('final totalRounds = career.fixtures.fold<int>'));
    expect(home, isNot(contains(r'Rodada ${career.currentRound}/38')));
  });

}
