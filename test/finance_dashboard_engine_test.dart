import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/domain/finance/finance.dart';
import 'package:tatica_manager/game/finance/finance_dashboard_engine.dart';

void main() {
  FinanceTransaction transaction({
    required String id,
    required FinanceKind kind,
    required int amount,
    required DateTime date,
  }) =>
      FinanceTransaction(
        id: id,
        season: 2031,
        round: 1,
        kind: kind,
        description: id,
        amount: amount,
        createdAt: date,
      );

  test('painel mensal deriva saldo, categorias e previsão do livro-caixa', () {
    final dashboard = FinanceDashboardEngine.build(
      currentBalance: 1130,
      currentDate: DateTime(2031, 3, 20),
      months: 3,
      transactions: [
        transaction(
          id: 'janeiro-tv',
          kind: FinanceKind.tvRights,
          amount: 200,
          date: DateTime(2031, 1, 10),
        ),
        transaction(
          id: 'fevereiro-salarios',
          kind: FinanceKind.wages,
          amount: -100,
          date: DateTime(2031, 2, 7),
        ),
        transaction(
          id: 'marco-bilheteria',
          kind: FinanceKind.matchday,
          amount: 50,
          date: DateTime(2031, 3, 4),
        ),
        transaction(
          id: 'marco-obras',
          kind: FinanceKind.stadiumInvestment,
          amount: -20,
          date: DateTime(2031, 3, 9),
        ),
      ],
    );

    expect(dashboard.months.map((item) => item.month.month), [1, 2, 3]);
    expect(dashboard.months.map((item) => item.balance), [1200, 1100, 1130]);
    expect(dashboard.currentMonth.income, 50);
    expect(dashboard.currentMonth.expenses, 20);
    expect(
      dashboard.currentMonth.amountFor(FinanceCategory.stadium, income: true),
      50,
    );
    expect(
      dashboard.currentMonth.amountFor(FinanceCategory.stadium, income: false),
      20,
    );
    expect(dashboard.forecast.monthsUsed, 2);
    expect(dashboard.forecast.projectedIncome, 100);
    expect(dashboard.forecast.projectedExpenses, 50);
    expect(dashboard.forecast.projectedNet, 50);
  });

  test('data futura legada é limitada ao calendário da carreira no painel', () {
    final currentDate = DateTime(2031, 1, 15);
    final legacy = transaction(
      id: 'transferencia-legada',
      kind: FinanceKind.playerPurchase,
      amount: -90,
      date: DateTime(2033, 6, 1),
    );

    expect(
      FinanceDashboardEngine.effectiveDate(legacy, currentDate),
      DateTime(2031, 1, 15),
    );
    final dashboard = FinanceDashboardEngine.build(
      currentBalance: 910,
      currentDate: currentDate,
      months: 3,
      transactions: [legacy],
    );
    expect(dashboard.currentMonth.expenses, 90);
    expect(dashboard.currentMonth.balance, 910);
  });

  test('novos lançamentos de mercado usam a data da carreira', () {
    final source = File('lib/app/state/transfer_controller.dart').readAsStringSync();

    expect(source, isNot(contains('createdAt: DateTime.now()')));
    expect(source, contains('createdAt: career.currentDate'));
    expect(source, contains('createdAt: next.currentDate'));
  });

  test('tela financeira possui abas e usa o agregador do livro-caixa', () {
    final screen = File('lib/features/finances/finances_screen.dart').readAsStringSync();
    final components = File(
      'lib/features/finances/finances_dashboard_components.dart',
    ).readAsStringSync();

    expect(screen, contains('DefaultTabController'));
    expect(screen, contains("Tab(text: 'Resumo')"));
    expect(screen, contains("Tab(text: 'Receitas')"));
    expect(screen, contains("Tab(text: 'Despesas')"));
    expect(screen, contains("Tab(text: 'Salários')"));
    expect(screen, contains('FinanceDashboardEngine.build'));
    expect(components, contains('Últimos 6 meses'));
    expect(components, contains('Previsão financeira'));
  });
}
