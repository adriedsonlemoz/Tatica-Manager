import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('seleção de clube exige competição antes dos clubes e usa cards compactos', () {
    final source = File('lib/features/career/club_selection_screen.dart')
        .readAsStringSync();

    expect(source, contains('CompetitionCatalog.brazil'));
    expect(source, contains('CompetitionBrowserLevel.country'));
    expect(source, contains('CompetitionBrowserLevel.championship'));
    expect(source, contains('CompetitionBrowserLevel.series'));
    expect(source, contains('CompetitionBrowserLevel.clubs'));
    expect(source, contains('Icons.sports_soccer_rounded'));
    expect(source, contains('crossAxisCount: 2'));
    expect(source, contains('mainAxisExtent: 108'));
    expect(source, isNot(contains('mainAxisExtent: 164')));
    expect(source, contains('ClubBadge(club: club'));
    expect(source, contains("'OVR \$overall'"));
    expect(source, contains('ClubRatingCalculator.starsForOverall'));
    expect(source, contains('formatMoney(club.transferBudget)'));
  });

  test('catálogo compartilhado modela Brasil, campeonato e Série A', () {
    final source = File('lib/data/competition_catalog.dart').readAsStringSync();
    expect(source, contains("name: 'Brasil'"));
    expect(source, contains("name: 'Liga Nacional'"));
    expect(source, contains("name: 'Série A'"));
    expect(source, contains("'br-club-001'"));
    expect(source, contains("'br-club-020'"));
  });

  test('criação inicial do técnico não exige cidade nem estado', () {
    final source = File('lib/features/career/manager_profile_step.dart')
        .readAsStringSync();

    expect(source, contains('Nome do técnico'));
    expect(source, contains('Apelido'));
    expect(source, contains('Idade'));
    expect(source, contains("labelText: 'País'"));
    expect(source, contains('CountryCatalog.all'));
    expect(source, contains('Editar aparência'));
    expect(source, isNot(contains("labelText: 'Estado'")));
    expect(source, isNot(contains("labelText: 'Cidade'")));
    expect(source, isNot(contains('BrazilLocationCatalog')));
  });

  test('fluxo começa escolhendo técnico e depois segue para clube e estilo', () {
    final setup = File('lib/features/career/career_setup_step.dart').readAsStringSync();
    final style = File('lib/features/career/career_style_step.dart').readAsStringSync();
    final flow = File('lib/features/career/new_career_flow_screen.dart').readAsStringSync();
    final managerSelection =
        File('lib/features/career/manager_selection_step.dart').readAsStringSync();

    expect(setup, contains('FormationMiniPitch'));
    expect(setup, contains('crossAxisCount: 3'));
    expect(setup, contains('FormationType.values'));
    expect(setup, isNot(contains('Pressing.values')));
    expect(style, contains("title: 'MENTALIDADE'"));
    expect(style, contains("title: 'PRESSÃO'"));
    expect(style, contains("title: 'RITMO'"));
    expect(flow, contains("subtitle: 'Etapa \${_step + 1} de 5'"));
    expect(flow, contains('ManagerChoiceStep('));
    expect(flow, contains('ExistingManagerSelectionStep('));
    expect(flow, contains('ManagerProfileStep('));
    expect(flow, contains('ClubSelectionStep('));
    expect(flow, contains('CareerSetupStep('));
    expect(flow, contains('CareerStyleStep('));
    expect(flow, isNot(contains('_birthStateController')));
    expect(flow, isNot(contains('_birthCityController')));

    expect(managerSelection, contains('Escolha seu técnico'));
    expect(managerSelection, contains('Usar técnico existente'));
    expect(managerSelection, contains('Criar meu técnico'));
    expect(managerSelection, contains("labelText: 'Nacionalidade'"));
    expect(managerSelection, contains("labelText: 'Clube'"));
    expect(managerSelection, contains("labelText: 'Reputação'"));
  });
}
