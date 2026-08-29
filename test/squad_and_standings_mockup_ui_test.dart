import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('elenco reproduz cabeçalho, abas, tabela e resumo do mockup', () {
    final source =
        File('lib/features/squad/squad_screen.dart').readAsStringSync();

    expect(source, contains("title: const Text('Elenco')"));
    expect(source, contains('ClubBadge(club: club, size: 78)'));
    expect(source, contains("_SquadView.players => 'Jogadores'"));
    expect(source, contains("_SquadView.roles => 'Funções'"));
    expect(source, contains("_SquadView.status => 'Status'"));
    expect(source, contains("_HeaderLabel('JOGADOR')"));
    expect(source, contains("_HeaderLabel('POS'"));
    expect(source, contains("_HeaderLabel('GER'"));
    expect(source, contains("_HeaderLabel('MORAL'"));
    expect(source, contains('Total de jogadores'));
    expect(source, contains('Brasileiros'));
    expect(source, contains('Estrangeiros'));
    expect(source, contains('AppColors.surface'));
    expect(source, contains('AppColors.surfaceRaised'));
  });

  test('classificação reproduz abas, tabela e informações do mockup', () {
    final source =
        File('lib/features/standings/standings_screen.dart').readAsStringSync();

    expect(source, contains("_CompetitionView.table => 'Tabela'"));
    expect(source, contains("_CompetitionView.matches => 'Jogos'"));
    expect(source, contains("_CompetitionView.scorers => 'Artilheiros'"));
    expect(source, contains("_TableLabel('TIME')"));
    expect(source, contains("_StatLabel('GP')"));
    expect(source, contains("_StatLabel('PTS')"));
    expect(source, contains('SOBRE O CAMPEONATO'));
    expect(source, contains('Critérios de desempate'));
    expect(source, contains('AppColors.surface'));
    expect(source, contains('AppColors.surfaceRaised'));
    expect(source, isNot(contains('SingleChildScrollView(\n                scrollDirection')));
  });
}
