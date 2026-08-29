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

  test('classificação compacta cabe na largura e mantém dados e zonas', () {
    final source =
        File('lib/features/standings/standings_screen.dart').readAsStringSync();
    final catalog =
        File('lib/data/competition_catalog.dart').readAsStringSync();

    final team = source.indexOf("_TableLabel('TIME')");
    final played = source.indexOf("_StatLabel('J')");
    final wins = source.indexOf("_StatLabel('V')");
    final points = source.indexOf("_StatLabel('PTS')");
    expect(team, greaterThanOrEqualTo(0));
    expect(played, greaterThan(team));
    expect(wins, greaterThan(played));
    expect(points, greaterThan(wins));
    expect(catalog, contains('Campeonato Brasileiro Série A'));
    expect(source, contains('_StandingsTable'));
    expect(source, contains('positionMovement'));
    expect(source, contains('SOBRE O CAMPEONATO'));
    expect(source, contains('Critérios de desempate'));
    expect(source, contains("_CompetitionView.matches => 'Jogos'"));
    expect(source, contains("_CompetitionView.scorers => 'Artilheiros'"));
    expect(source, isNot(contains('DataTable(')));
  });

  test('home clara usa composição simples, responsiva e somente dados reais', () {
    final home = File('lib/features/home/home_screen.dart').readAsStringSync();
    final header =
        File('lib/features/home/home_clean_header.dart').readAsStringSync();
    final content =
        File('lib/features/home/home_clean_content.dart').readAsStringSync();

    expect(home, contains('HomeCleanTopBar'));
    expect(home, contains('HomeCleanClubCard'));
    expect(home, contains('HomeCleanPrimaryAction'));
    expect(home, contains('HomeCleanModules'));
    expect(home, contains('HomeCleanNextMatch'));
    expect(home, contains('HomeCleanSeasonSummary'));
    expect(home, contains('HomeCleanRankings'));
    expect(home, contains('HomeCleanNews'));

    expect(home, contains("label: 'Elenco'"));
    expect(home, contains("label: 'Táticas'"));
    expect(home, contains("label: 'Transferências'"));
    expect(home, contains("label: 'Finanças'"));
    expect(home, contains("label: 'Calendário'"));
    expect(home, contains("label: 'Base'"));
    expect(home, contains('SquadScreen()'));
    expect(home, contains('MarketScreen(showBackButton: true)'));
    expect(home, contains('FinancesScreen()'));
    expect(home, contains('YouthAcademyScreen()'));
    expect(home, contains('const MoreScreen(showBackButton: true)'));

    expect(home, contains("? 'REVISAR TEMPORADA'"));
    expect(home, contains("? 'JOGAR PARTIDA'"));
    expect(home, contains(": 'AVANÇAR DIA'"));
    expect(home, contains('_advanceDayWithTransition'));
    expect(home, contains('_AdvanceDateCard'));
    expect(home, contains('PROCESSANDO O DIA'));
    expect(home, contains('Condição física e fadiga do elenco'));

    expect(header, contains("'Tática Manager'"));
    expect(header, contains('width >= 330 ? 6 : 3'));
    expect(header, contains('club.money'));
    expect(header, contains('club.transferBudget'));
    expect(header, contains('AppColors.surface'));

    expect(content, contains("title: 'PRÓXIMA PARTIDA'"));
    expect(content, contains("title: 'RESUMO DA TEMPORADA'"));
    expect(content, contains("title: 'CLASSIFICAÇÃO'"));
    expect(content, contains("title: 'ARTILHARIA'"));
    expect(content, contains("title: 'NOTÍCIAS E DESTAQUES'"));
    expect(content, contains(r"value: '${s?.played ?? 0}'"));
    expect(content, contains(r"value: '${s?.wins ?? 0}'"));
    expect(content, contains(r"value: '${s?.draws ?? 0}'"));
    expect(content, contains(r"value: '${s?.losses ?? 0}'"));
    expect(content, contains(r"value: '${s?.goalsFor ?? 0}'"));
    expect(content, contains(r"value: '${s?.goalsAgainst ?? 0}'"));

    expect(home, contains('_homeCompetitionLabel'));
    expect(home, contains(r"'Brasileiro ${value.substring(prefix.length)}'"));
    expect(home, contains('NewsHighlightsScreen'));
    expect(home, contains('onNotificationsTap: openNews'));
    expect(home, isNot(contains(r'Rodada ${career.currentRound}/38')));
  });
}
