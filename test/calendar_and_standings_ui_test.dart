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

  test('home premium acompanha a estrutura atual responsiva e os dados reais', () {
    final home = File('lib/features/home/home_screen.dart').readAsStringSync();
    final overview = File('lib/features/home/home_overview_widgets.dart')
        .readAsStringSync();
    final rankings = File('lib/features/home/home_dashboard_rankings.dart')
        .readAsStringSync();
    final news = File('lib/features/home/home_dashboard_news.dart')
        .readAsStringSync();
    final matchCard = File('lib/features/home/home_dashboard_match.dart')
        .readAsStringSync();
    final controls = File('lib/features/home/home_dashboard_controls.dart')
        .readAsStringSync();
    final visuals = File('lib/features/home/home_visual_components.dart')
        .readAsStringSync();
    final pubspec = File('pubspec.yaml').readAsStringSync();

    expect(home, contains('HomeClubHeader'));
    expect(home, contains('_HomeBackdrop'));
    expect(home, contains('_AdvanceDateCard'));
    expect(home, contains('PROCESSANDO O DIA'));
    expect(home, contains('Condição física e fadiga do elenco'));
    expect(home, contains('HomePrimaryActionButton'));
    expect(home, contains('HomeQuickAccess'));
    expect(home, contains('HomeNextMatchCard'));
    expect(home, contains('HomeSeasonSummaryRow'));
    expect(home, contains('HomeLeagueAndScorers'));
    expect(home, contains('HomeNewsHighlights'));
    expect(home, contains('career.news.reversed.take(4)'));
    expect(home, contains('showDot: lineupNeedsAttention'));
    expect(home, contains('showDot: career.isMatchDay'));
    expect(home, contains('showDot: financeNeedsAttention'));
    expect(home, contains('_homeCompetitionLabel'));
    expect(home, contains(r"'Brasileiro ${value.substring(prefix.length)}'"));
    expect(home, contains('NewsHighlightsScreen'));
    expect(home, isNot(contains('onNotificationsTap')));

    expect(controls, contains('class HomePrimaryActionButton'));
    expect(controls, contains("isMatchDay ? 'JOGAR PARTIDA' : 'AVANÇAR DIA'"));
    expect(controls, contains('padding: const EdgeInsets.only(left: 16, right: 6)'));
    expect(controls, contains('width: 36'));
    expect(controls, contains('height: 36'));
    expect(controls, contains('PANORAMA DA TEMPORADA'));
    expect(controls, contains('_SeasonTrendPainter'));

    expect(news, contains('class HomeQuickAccess'));
    expect(news, contains('constraints.maxWidth >= 300'));
    expect(news, contains('height: 62'));
    expect(news, contains('width: 80'));
    expect(news, contains('final bool showDot'));
    expect(news, contains('NOTÍCIAS E DESTAQUES'));

    expect(matchCard, contains('PRÓXIMA PARTIDA'));
    expect(matchCard, contains('HomeClubCrest(club: club, size: 46)'));
    expect(matchCard, contains('Icons.calendar_today_rounded'));
    expect(matchCard, contains('Icons.stadium_rounded'));
    expect(matchCard, contains('const SizedBox(height: 8)'));

    expect(overview, contains('class HomeSeasonSummaryRow'));
    expect(overview, contains('RESUMO DA TEMPORADA'));
    expect(RegExp(r'Expanded\(\s*child: _SummaryStat\(').allMatches(overview).length, 6);
    expect(overview, contains("label: 'Jogos'"));
    expect(overview, contains("label: 'Vitórias'"));
    expect(overview, contains("label: 'Empates'"));
    expect(overview, contains("label: 'Derrotas'"));
    expect(overview, contains("label: 'Gols marcados'"));
    expect(overview, contains("label: 'Gols sofridos'"));
    expect(overview, contains('club.name'));
    expect(overview, contains("_StandingCell('J'"));
    expect(overview, contains("_StandingCell('V'"));
    expect(overview, contains("_StandingCell('E'"));
    expect(overview, contains("_StandingCell('D'"));
    expect(overview, contains("_StandingCell('SG'"));
    expect(overview, contains("_StandingCell('PTS'"));

    expect(rankings, contains('HomeCompactStandings'));
    expect(rankings, contains('compactColumns: true'));
    expect(rankings, contains('compactSingleRow'));
    expect(rankings, contains('IntrinsicHeight'));
    expect(rankings, contains("title: 'CLASSIFICAÇÃO'"));
    expect(rankings, contains("title: 'ARTILHARIA'"));
    expect(rankings, isNot(contains('final IconData? icon')));

    expect(visuals, contains('class HomeClubCrest'));
    expect(pubspec, contains('assets/images/home/'));
    expect(File('assets/images/home/match_stadium.webp').existsSync(), isTrue);
    expect(File('assets/images/home/stadium_aerial.webp').existsSync(), isTrue);
  });


}
