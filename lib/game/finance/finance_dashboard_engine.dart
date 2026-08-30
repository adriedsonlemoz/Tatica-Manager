import '../../domain/finance/finance.dart';

/// Agrega o livro-caixa persistido da carreira para as telas de Finanças.
///
/// Não cria saldo, receitas ou despesas paralelas. Toda informação exibida
/// parte de [FinanceTransaction] e do saldo atual persistido no clube.
class FinanceDashboardSnapshot {
  const FinanceDashboardSnapshot({
    required this.months,
    required this.currentMonth,
    required this.previousMonth,
    required this.forecast,
  });

  final List<FinanceMonthSummary> months;
  final FinanceMonthSummary currentMonth;
  final FinanceMonthSummary previousMonth;
  final FinanceForecast forecast;
}

class FinanceMonthSummary {
  const FinanceMonthSummary({
    required this.month,
    required this.income,
    required this.expenses,
    required this.balance,
    required this.incomeByCategory,
    required this.expensesByCategory,
    required this.transactionCount,
  });

  /// Primeiro dia do mês representado pelo resumo.
  final DateTime month;
  final int income;
  final int expenses;
  final int balance;
  final Map<FinanceCategory, int> incomeByCategory;
  final Map<FinanceCategory, int> expensesByCategory;
  final int transactionCount;

  int get net => income - expenses;
  bool get hasTransactions => transactionCount > 0;

  int amountFor(FinanceCategory category, {required bool income}) =>
      (income ? incomeByCategory : expensesByCategory)[category] ?? 0;
}

class FinanceForecast {
  const FinanceForecast({
    required this.monthsUsed,
    this.projectedIncome,
    this.projectedExpenses,
  });

  /// Quantos meses fechados com lançamentos foram usados no cálculo.
  final int monthsUsed;
  final int? projectedIncome;
  final int? projectedExpenses;

  bool get hasData => projectedIncome != null && projectedExpenses != null;
  int? get projectedNet => hasData ? projectedIncome! - projectedExpenses! : null;
}

abstract final class FinanceDashboardEngine {
  /// Constrói uma série mensal recente sem exigir uma tabela nova no save.
  ///
  /// O saldo ao fim de cada mês é reconstituído a partir do caixa atual e dos
  /// lançamentos posteriores. Isso preserva compatibilidade com saves já
  /// existentes, que ainda não possuíam snapshots mensais persistidos.
  static FinanceDashboardSnapshot build({
    required List<FinanceTransaction> transactions,
    required int currentBalance,
    required DateTime currentDate,
    int months = 6,
  }) {
    final safeMonths = months.clamp(2, 12).toInt();
    final orderedMonths = <DateTime>[
      for (var offset = safeMonths - 1; offset >= 0; offset--)
        DateTime(currentDate.year, currentDate.month - offset, 1),
    ];
    final normalized = [
      for (final transaction in transactions)
        _DatedTransaction(
          transaction: transaction,
          date: effectiveDate(transaction, currentDate),
        ),
    ];

    final summaries = orderedMonths.map((month) {
      final nextMonth = DateTime(month.year, month.month + 1, 1);
      final incomeByCategory = _emptyCategories();
      final expensesByCategory = _emptyCategories();
      var income = 0;
      var expenses = 0;
      var transactionCount = 0;

      for (final item in normalized) {
        if (item.date.year != month.year || item.date.month != month.month) {
          continue;
        }
        transactionCount++;
        final category = item.transaction.kind.category;
        if (item.transaction.amount >= 0) {
          income += item.transaction.amount;
          incomeByCategory[category] =
              incomeByCategory[category]! + item.transaction.amount;
        } else {
          final amount = item.transaction.amount.abs();
          expenses += amount;
          expensesByCategory[category] = expensesByCategory[category]! + amount;
        }
      }

      final laterTransactions = normalized
          .where((item) => !item.date.isBefore(nextMonth))
          .fold<int>(0, (sum, item) => sum + item.transaction.amount);
      return FinanceMonthSummary(
        month: month,
        income: income,
        expenses: expenses,
        balance: currentBalance - laterTransactions,
        incomeByCategory: incomeByCategory,
        expensesByCategory: expensesByCategory,
        transactionCount: transactionCount,
      );
    }).toList(growable: false);

    final current = summaries.last;
    final previous = summaries[summaries.length - 2];
    return FinanceDashboardSnapshot(
      months: summaries,
      currentMonth: current,
      previousMonth: previous,
      forecast: _forecast(summaries),
    );
  }

  /// Corrige apenas para visualização lançamentos de saves antigos que foram
  /// gravados com a data do aparelho em vez da data da carreira.
  static DateTime effectiveDate(
    FinanceTransaction transaction,
    DateTime currentDate,
  ) {
    var date = DateTime(
      transaction.createdAt.year,
      transaction.createdAt.month,
      transaction.createdAt.day,
    );
    if (date.year != transaction.season) {
      final lastDayOfMonth =
          DateTime(transaction.season, date.month + 1, 0).day;
      date = DateTime(
        transaction.season,
        date.month,
        date.day > lastDayOfMonth ? lastDayOfMonth : date.day,
      );
    }
    final careerDay = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
    );
    return date.isAfter(careerDay) ? careerDay : date;
  }

  static int? percentChange({required int current, required int previous}) {
    if (previous == 0) return null;
    return (((current - previous) * 100) / previous.abs()).round();
  }

  static Map<FinanceCategory, int> _emptyCategories() => {
        for (final category in FinanceCategory.values) category: 0,
      };

  static FinanceForecast _forecast(List<FinanceMonthSummary> months) {
    final completed = months
        .take(months.length - 1)
        .where((month) => month.hasTransactions)
        .toList(growable: false);
    if (completed.isEmpty) {
      return const FinanceForecast(monthsUsed: 0);
    }
    final sample = completed.length > 3
        ? completed.sublist(completed.length - 3)
        : completed;
    final income =
        (sample.fold<int>(0, (sum, month) => sum + month.income) / sample.length)
            .round();
    final expenses =
        (sample.fold<int>(0, (sum, month) => sum + month.expenses) / sample.length)
            .round();
    return FinanceForecast(
      monthsUsed: sample.length,
      projectedIncome: income,
      projectedExpenses: expenses,
    );
  }
}

class _DatedTransaction {
  const _DatedTransaction({required this.transaction, required this.date});

  final FinanceTransaction transaction;
  final DateTime date;
}
