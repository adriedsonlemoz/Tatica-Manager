import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cards visuais apontam apenas para módulos existentes quando parecem acionáveis', () {
    final matchDay = File(
      'lib/features/home/match_day_presentation_screen.dart',
    ).readAsStringSync();
    final matchCards = File(
      'lib/features/home/match_day_presentation_components.dart',
    ).readAsStringSync();
    final matchHeader = File(
      'lib/features/home/match_day_header_components.dart',
    ).readAsStringSync();
    final contracts = File(
      'lib/features/contracts/contracts_components.dart',
    ).readAsStringSync();
    final youth = File(
      'lib/features/youth/youth_academy_components.dart',
    ).readAsStringSync();
    final finances = File(
      'lib/features/finances/finances_screen.dart',
    ).readAsStringSync();
    final financeCards = File(
      'lib/features/finances/finances_dashboard_components.dart',
    ).readAsStringSync();

    expect(matchDay, contains('StandingsScreen()'));
    expect(matchDay, contains('CalendarScreen(initialFixtureId: fixture.id)'));
    expect(matchDay, contains('SquadScreen(showBackButton: true)'));
    expect(matchDay, contains('MedicalDepartmentScreen()'));
    expect(matchDay, contains('TacticsScreen()'));
    expect(matchDay, contains('LineupScreen(showBackButton: true)'));
    expect(matchCards, contains('onTap: onTap'));
    expect(matchHeader, contains('required this.onStadiumTap'));
    expect(matchHeader, contains('onTap: onTap'));

    expect(contracts, contains('onStatusSelected'));
    expect(contracts, contains('onTap: onTap'));
    expect(youth, contains('onTap: onOpen'));

    expect(finances, contains('ContractsScreen()'));
    expect(finances, contains('MarketScreen(showBackButton: true)'));
    expect(finances, contains('StadiumScreen()'));
    expect(financeCards, contains('final VoidCallback? onTap;'));
    expect(financeCards, contains('if (item.onTap != null)'));
  });

  test('fundos e acentos preservam contraste nas telas remodeladas', () {
    final colors = File('lib/core/theme/app_colors.dart').readAsStringSync();
    final theme = File('lib/core/theme/app_theme.dart').readAsStringSync();
    final common = File('lib/app/widgets/common.dart').readAsStringSync();
    final stadiumScene = File(
      'lib/features/stadium/stadium_scene.dart',
    ).readAsStringSync();
    final financeManagement = File(
      'lib/features/finances/finances_management_components.dart',
    ).readAsStringSync();

    expect(colors, contains('static Color readableAccent(Color color)'));
    expect(colors, contains('static Color foregroundOn(Color background)'));
    expect(theme, contains('appBarTheme: const AppBarTheme('));
    expect(theme, contains('surfaceTintColor: Colors.transparent'));
    expect(common, contains('AppColors.readableAccent(Color(club.colors.primaryHex))'));
    expect(stadiumScene, contains('AppColors.readableAccent'));
    expect(stadiumScene, contains('AppColors.foregroundOn(primary)'));
    expect(financeManagement, contains('class _FinanceInsetPanel'));
    expect(financeManagement, contains('color: AppColors.surfaceRaised'));
  });

  test('obras do estádio exibem disponibilidade coerente com caixa e orçamento', () {
    final stadiumScreen = File(
      'lib/features/stadium/stadium_screen.dart',
    ).readAsStringSync();
    final stadiumComponents = File(
      'lib/features/stadium/stadium_components.dart',
    ).readAsStringSync();

    expect(
      stadiumScreen,
      contains('math.min(stadiumBudget, club.money)'),
    );
    expect(stadiumComponents, contains('availableFunds'));
    expect(stadiumComponents, contains('Saldo/orçamento insuficiente'));
  });

  test('mercado pode ser aberto como módulo secundário com retorno visível', () {
    final market = File('lib/features/market/market_screen.dart').readAsStringSync();
    final home = File('lib/features/home/home_screen.dart').readAsStringSync();
    final inbox = File('lib/features/inbox/inbox_screen.dart').readAsStringSync();

    expect(market, contains('this.showBackButton = false'));
    expect(market, contains('if (widget.showBackButton)'));
    expect(market, contains('Navigator.of(context).pop()'));
    expect(home, contains('MarketScreen(showBackButton: true)'));
    expect(inbox, contains('showBackButton: true'));
  });
}
