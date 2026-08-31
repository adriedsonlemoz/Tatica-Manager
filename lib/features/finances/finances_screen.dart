import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/widgets/common.dart';
import '../../app/widgets/management_dashboard_widgets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/finance/finance.dart';
import '../../domain/finance/sponsorship.dart';
import '../../domain/player/player.dart';
import '../../domain/season/career_state.dart';
import '../../game/finance/club_administration_engine.dart';
import '../../game/finance/finance_dashboard_engine.dart';
import '../../game/finance/sponsorship_engine.dart';
import '../contracts/contracts_screen.dart';
import '../market/market_screen.dart';
import '../player/player_profile_screen.dart';
import '../stadium/stadium_screen.dart';
import 'finances_dashboard_components.dart';
import 'finances_management_components.dart';

class FinancesScreen extends ConsumerStatefulWidget {
  const FinancesScreen({super.key});

  @override
  ConsumerState<FinancesScreen> createState() => _FinancesScreenState();
}

class _FinancesScreenState extends ConsumerState<FinancesScreen> {
  int _historyMonths = 6;
  FinanceCategory? _incomeCategory;
  FinanceCategory? _expenseCategory;

  @override
  Widget build(BuildContext context) {
    final career = ref.watch(gameControllerProvider).career!;
    final club = career.userClub;
    final dashboard = FinanceDashboardEngine.build(
      transactions: career.finances,
      currentBalance: club.money,
      currentDate: career.currentDate,
      months: _historyMonths,
    );
    final seasonTransactions = career.finances
        .where((transaction) => transaction.season == career.season)
        .toList(growable: false);
    final sponsors = SponsorshipEngine.contractsFor(club, season: career.season);

    return DefaultTabController(
      length: 4,
      child: PremiumScaffold(
        safeBottom: true,
        appBar: GameTopBar(
          title: 'Finanças',
          subtitle:
              'Temporada ${career.season} • ${career.currentDate.month.toString().padLeft(2, '0')}/${career.currentDate.year}',
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
              child: FinanceClubHeader(club: club, season: career.season),
            ),
            Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: const TabBar(
                isScrollable: false,
                labelColor: AppColors.green,
                unselectedLabelColor: AppColors.muted,
                indicatorColor: AppColors.green,
                indicatorWeight: 3,
                labelStyle: TextStyle(fontWeight: FontWeight.w900),
                tabs: [
                  Tab(text: 'Resumo'),
                  Tab(text: 'Receitas'),
                  Tab(text: 'Despesas'),
                  Tab(text: 'Salários'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _summaryTab(
                    context,
                    dashboard: dashboard,
                    sponsors: sponsors,
                  ),
                  _transactionsTab(
                    context,
                    title: 'Receitas',
                    income: true,
                    transactions: seasonTransactions,
                    selectedCategory: _incomeCategory,
                    onCategorySelected: (value) =>
                        setState(() => _incomeCategory = value),
                  ),
                  _transactionsTab(
                    context,
                    title: 'Despesas',
                    income: false,
                    transactions: seasonTransactions,
                    selectedCategory: _expenseCategory,
                    onCategorySelected: (value) =>
                        setState(() => _expenseCategory = value),
                  ),
                  _salariesTab(
                    context,
                    monthIncome: dashboard.currentMonth.income,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryTab(
    BuildContext context, {
    required FinanceDashboardSnapshot dashboard,
    required List<SponsorshipContract> sponsors,
  }) {
    final career = ref.read(gameControllerProvider).career!;
    final club = career.userClub;
    final monthIncomeEntries = _categoryEntries(
      context,
      amounts: dashboard.currentMonth.incomeByCategory,
    );
    final monthExpenseEntries = _categoryEntries(
      context,
      amounts: dashboard.currentMonth.expensesByCategory,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final veryCompact = constraints.maxHeight < 370;
        final compact = constraints.maxHeight < 560;
        final spacing = veryCompact ? 4.0 : compact ? 6.0 : 8.0;
        return Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
          child: Column(
            children: [
              SizedBox(
                height: veryCompact ? 80 : compact ? 110 : 142,
                child: _FinanceCompactBalanceCard(
                  balance: club.money,
                  dashboard: dashboard,
                  periodMonths: _historyMonths,
                  showChart: !compact,
                  onPeriodChanged: (value) =>
                      setState(() => _historyMonths = value),
                ),
              ),
              SizedBox(height: spacing),
              SizedBox(
                height: veryCompact ? 62 : compact ? 66 : 78,
                child: _FinanceCompactMetrics(
                  current: dashboard.currentMonth,
                  previous: dashboard.previousMonth,
                ),
              ),
              SizedBox(height: spacing),
              SizedBox(
                height: veryCompact ? 64 : compact ? 84 : 104,
                child: _FinanceActionGrid(
                  actions: [
                    _FinanceAction(
                      icon: Icons.stadium_outlined,
                      label: 'Estádio',
                      value: club.stadium.name,
                      onTap: () => _openStadium(context),
                    ),
                    _FinanceAction(
                      icon: Icons.swap_horiz_rounded,
                      label: 'Transferências',
                      value: compactMoney(club.transferBudget),
                      onTap: () => _openMarket(context),
                    ),
                    _FinanceAction(
                      icon: Icons.description_outlined,
                      label: 'Contratos',
                      value: '${compactMoney(club.payroll)}/mês',
                      onTap: () => _openContracts(context),
                    ),
                    _FinanceAction(
                      icon: Icons.account_balance_outlined,
                      label: 'Orçamentos',
                      value:
                          '${career.clubAdministration.budgetPlan.available.length} áreas',
                      onTap: () => _editBudgets(context, ref),
                    ),
                  ],
                ),
              ),
              SizedBox(height: spacing),
              if (veryCompact)
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: OutlinedButton.icon(
                    onPressed: () => _showFinanceDetailsSheet(
                      context,
                      career: career,
                      dashboard: dashboard,
                      sponsors: sponsors,
                      incomeEntries: monthIncomeEntries,
                      expenseEntries: monthExpenseEntries,
                      onEditBudgets: () => _editBudgets(context, ref),
                      onProposal: (proposalId) =>
                          _openSponsorshipProposal(context, ref, proposalId),
                    ),
                    icon: const Icon(Icons.insights_outlined, size: 17),
                    label: const Text('Mais detalhes financeiros'),
                  ),
                )
              else
                Expanded(
                  child: _FinanceMoreCard(
                    dashboard: dashboard,
                    sponsors: sponsors,
                    monthIncomeEntries: monthIncomeEntries,
                    monthExpenseEntries: monthExpenseEntries,
                    onOpenDetails: () => _showFinanceDetailsSheet(
                      context,
                      career: career,
                      dashboard: dashboard,
                      sponsors: sponsors,
                      incomeEntries: monthIncomeEntries,
                      expenseEntries: monthExpenseEntries,
                      onEditBudgets: () => _editBudgets(context, ref),
                      onProposal: (proposalId) =>
                          _openSponsorshipProposal(context, ref, proposalId),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _transactionsTab(
    BuildContext context, {
    required String title,
    required bool income,
    required List<FinanceTransaction> transactions,
    required FinanceCategory? selectedCategory,
    required ValueChanged<FinanceCategory?> onCategorySelected,
  }) {
    final career = ref.read(gameControllerProvider).career!;
    final matching = transactions
        .where((transaction) => income ? transaction.amount >= 0 : transaction.amount < 0)
        .toList(growable: false);
    final categories = FinanceCategory.values
        .where(
          (category) => matching.any((transaction) => transaction.kind.category == category),
        )
        .toList(growable: false);
    final visible = _sortTransactions(
      matching
          .where(
            (transaction) =>
                selectedCategory == null ||
                transaction.kind.category == selectedCategory,
          )
          .toList(growable: false),
      career.currentDate,
    );
    final totals = _categoryTotals(matching, income: income);
    final entries = _categoryEntries(context, amounts: totals);

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        children: [
          SectionCard(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DashboardSectionHeader(
                  title: '$title da temporada',
                  subtitle: 'Filtros e total já registrado em ${career.season}',
                ),
                const SizedBox(height: 8),
                FinanceFilterChips(
                  categories: categories,
                  selected: selectedCategory,
                  onSelected: onCategorySelected,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _FinanceCategoryPreview(
              title: income ? 'Principais receitas' : 'Principais despesas',
              total: matching.fold<int>(0, (sum, item) => sum + item.amount.abs()),
              entries: entries,
              income: income,
              emptyText: income
                  ? 'Nenhuma receita foi registrada nesta temporada.'
                  : 'Nenhuma despesa foi registrada nesta temporada.',
              onOpenDetails: () => _showTransactionsSheet(
                context,
                title: title,
                income: income,
                entries: entries,
                transactions: visible,
                currentDate: career.currentDate,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _salariesTab(BuildContext context, {required int monthIncome}) {
    final career = ref.read(gameControllerProvider).career!;
    final players = [...career.userClub.squad]
      ..sort((a, b) => b.salary.compareTo(a.salary));
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        children: [
          _FinancePayrollSummary(
            payroll: career.userClub.payroll,
            playerCount: players.length,
            monthIncome: monthIncome,
            onContractsTap: () => _openContracts(context),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _FinanceSalaryPreview(
              players: players,
              onPlayerTap: (player) => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PlayerProfileScreen(
                    playerId: player.id,
                    clubId: career.userClub.id,
                  ),
                ),
              ),
              onOpenDetails: () => _showSalariesSheet(
                context,
                career: career,
                monthIncome: monthIncome,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFinanceDetailsSheet(
    BuildContext context, {
    required CareerState career,
    required FinanceDashboardSnapshot dashboard,
    required List<SponsorshipContract> sponsors,
    required List<FinanceCategoryAmount> incomeEntries,
    required List<FinanceCategoryAmount> expenseEntries,
    required VoidCallback onEditBudgets,
    required ValueChanged<String> onProposal,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: .78,
        minChildSize: .48,
        maxChildSize: .95,
        builder: (context, controller) => Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              _FinanceSheetHeader(
                title: 'Detalhes financeiros',
                onClose: () => Navigator.of(sheetContext).pop(),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 28),
                  children: [
                    FinanceForecastCard(
                      forecast: dashboard.forecast,
                      balance: career.userClub.money,
                      payroll: career.userClub.payroll,
                      transferBudget: career.userClub.transferBudget,
                      onBudgetTap: onEditBudgets,
                    ),
                    const SizedBox(height: 10),
                    DepartmentBudgetSection(
                      career: career,
                      onEdit: onEditBudgets,
                    ),
                    const SizedBox(height: 10),
                    SponsorshipManagementSection(
                      contracts: sponsors,
                      proposals: career.clubAdministration.sponsorshipProposals,
                      onProposal: (proposal) => onProposal(proposal.id),
                    ),
                    const SizedBox(height: 10),
                    FinanceCategoryOverview(
                      title: 'Receitas do mês',
                      entries: incomeEntries,
                      income: true,
                      emptyText: 'Nenhuma receita foi registrada neste mês.',
                    ),
                    const SizedBox(height: 10),
                    FinanceDistributionCard(entries: expenseEntries),
                    const SizedBox(height: 10),
                    FinanceTransactionsList(
                      transactions: _sortTransactions(
                        career.finances,
                        career.currentDate,
                      ),
                      currentDate: career.currentDate,
                      emptyTitle: 'Sem movimentações',
                      emptyText:
                          'Receitas e despesas aparecerão aqui conforme a carreira avançar.',
                      onTap: (transaction) =>
                          showFinanceTransactionDialog(sheetContext, transaction),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTransactionsSheet(
    BuildContext context, {
    required String title,
    required bool income,
    required List<FinanceCategoryAmount> entries,
    required List<FinanceTransaction> transactions,
    required DateTime currentDate,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: .74,
        minChildSize: .48,
        maxChildSize: .95,
        builder: (context, controller) => Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              _FinanceSheetHeader(
                title: '$title da temporada',
                onClose: () => Navigator.of(sheetContext).pop(),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 28),
                  children: [
                    FinanceCategoryOverview(
                      title: 'Distribuição por categoria',
                      entries: entries,
                      income: income,
                      emptyText: income
                          ? 'Nenhuma receita foi registrada nesta temporada.'
                          : 'Nenhuma despesa foi registrada nesta temporada.',
                    ),
                    const SizedBox(height: 10),
                    FinanceTransactionsList(
                      transactions: transactions,
                      currentDate: currentDate,
                      emptyTitle: income ? 'Sem receitas' : 'Sem despesas',
                      emptyText: 'Não há lançamentos para os filtros atuais.',
                      onTap: (transaction) =>
                          showFinanceTransactionDialog(sheetContext, transaction),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSalariesSheet(
    BuildContext context, {
    required CareerState career,
    required int monthIncome,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: .76,
        minChildSize: .48,
        maxChildSize: .95,
        builder: (context, controller) => Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              _FinanceSheetHeader(
                title: 'Folha salarial',
                onClose: () => Navigator.of(sheetContext).pop(),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 28),
                  children: [
                    FinanceSalaryPanel(
                      players: career.userClub.squad,
                      payroll: career.userClub.payroll,
                      monthIncome: monthIncome,
                      onPlayerTap: (player) => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PlayerProfileScreen(
                            playerId: player.id,
                            clubId: career.userClub.id,
                          ),
                        ),
                      ),
                      onContractsTap: () => _openContracts(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<FinanceCategoryAmount> _categoryEntries(
    BuildContext context, {
    required Map<FinanceCategory, int> amounts,
  }) {
    final entries = FinanceCategory.values
        .map(
          (category) => FinanceCategoryAmount(
            category: category,
            icon: _iconFor(category),
            label: category.label,
            amount: amounts[category] ?? 0,
            onTap: _categoryTap(context, category),
          ),
        )
        .where((entry) => entry.amount > 0)
        .toList(growable: false)
      ..sort((a, b) => b.amount.compareTo(a.amount));
    return entries;
  }

  Map<FinanceCategory, int> _categoryTotals(
    List<FinanceTransaction> transactions, {
    required bool income,
  }) {
    final totals = <FinanceCategory, int>{
      for (final category in FinanceCategory.values) category: 0,
    };
    for (final transaction in transactions) {
      if (income && transaction.amount < 0) continue;
      if (!income && transaction.amount >= 0) continue;
      final category = transaction.kind.category;
      totals[category] = totals[category]! + transaction.amount.abs();
    }
    return totals;
  }

  List<FinanceTransaction> _sortTransactions(
    List<FinanceTransaction> transactions,
    DateTime currentDate,
  ) {
    final sorted = [...transactions];
    sorted.sort(
      (a, b) => FinanceDashboardEngine.effectiveDate(b, currentDate).compareTo(
            FinanceDashboardEngine.effectiveDate(a, currentDate),
          ),
    );
    return sorted;
  }

  IconData _iconFor(FinanceCategory category) => switch (category) {
        FinanceCategory.stadium => Icons.stadium_outlined,
        FinanceCategory.commercial => Icons.handshake_outlined,
        FinanceCategory.payroll => Icons.groups_2_outlined,
        FinanceCategory.transfers => Icons.swap_horiz_rounded,
        FinanceCategory.prizes => Icons.emoji_events_outlined,
        FinanceCategory.operations => Icons.settings_suggest_outlined,
      };

  VoidCallback? _categoryTap(BuildContext context, FinanceCategory category) =>
      switch (category) {
        FinanceCategory.stadium => () => _openStadium(context),
        FinanceCategory.transfers => () => _openMarket(context),
        FinanceCategory.payroll => () => _openContracts(context),
        _ => null,
      };

  void _openStadium(BuildContext context) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const StadiumScreen()),
      );

  void _openMarket(BuildContext context) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const MarketScreen(showBackButton: true)),
      );

  void _openContracts(BuildContext context) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ContractsScreen()),
      );
}

class _FinanceCompactBalanceCard extends StatelessWidget {
  const _FinanceCompactBalanceCard({
    required this.balance,
    required this.dashboard,
    required this.periodMonths,
    required this.showChart,
    required this.onPeriodChanged,
  });

  final int balance;
  final FinanceDashboardSnapshot dashboard;
  final int periodMonths;
  final bool showChart;
  final ValueChanged<int> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    final delta = dashboard.currentMonth.balance - dashboard.previousMonth.balance;
    final positive = delta >= 0;
    final color = positive ? AppColors.green : AppColors.danger;
    return SectionCard(
      padding: const EdgeInsets.fromLTRB(13, 10, 11, 8),
      borderColor: AppColors.green.withValues(alpha: .34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SALDO EM CAIXA',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      compactMoney(balance),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: balance < 0 ? AppColors.danger : AppColors.green,
                        fontSize: 26,
                        height: 1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dashboard.previousMonth.hasTransactions
                          ? '${positive ? '+' : ''}${compactMoney(delta)} vs. mês anterior'
                          : 'Sem comparação mensal fechada',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: dashboard.previousMonth.hasTransactions
                            ? color
                            : AppColors.muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<int>(
                initialValue: periodMonths,
                onSelected: onPeriodChanged,
                tooltip: 'Período do histórico',
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 3, child: Text('Últimos 3 meses')),
                  PopupMenuItem(value: 6, child: Text('Últimos 6 meses')),
                  PopupMenuItem(value: 12, child: Text('Últimos 12 meses')),
                ],
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.more_horiz_rounded, color: AppColors.muted),
                ),
              ),
            ],
          ),
          if (showChart) ...[
            const SizedBox(height: 4),
            Expanded(
              child: IgnorePointer(
                child: FinanceBalanceChart(
                  months: dashboard.months,
                  height: 46,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FinanceCompactMetrics extends StatelessWidget {
  const _FinanceCompactMetrics({required this.current, required this.previous});

  final FinanceMonthSummary current;
  final FinanceMonthSummary previous;

  @override
  Widget build(BuildContext context) => SectionCard(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: _FinanceInlineMetric(
                label: 'Receitas',
                value: current.income,
                previous: previous.income,
                color: AppColors.green,
              ),
            ),
            _MetricDivider(),
            Expanded(
              child: _FinanceInlineMetric(
                label: 'Despesas',
                value: current.expenses,
                previous: previous.expenses,
                color: AppColors.danger,
              ),
            ),
            _MetricDivider(),
            Expanded(
              child: _FinanceInlineMetric(
                label: 'Resultado',
                value: current.net,
                previous: previous.net,
                color: current.net < 0 ? AppColors.danger : AppColors.green,
                signed: true,
              ),
            ),
          ],
        ),
      );
}

class _MetricDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 36,
        color: AppColors.border,
      );
}

class _FinanceInlineMetric extends StatelessWidget {
  const _FinanceInlineMetric({
    required this.label,
    required this.value,
    required this.previous,
    required this.color,
    this.signed = false,
  });

  final String label;
  final int value;
  final int previous;
  final Color color;
  final bool signed;

  @override
  Widget build(BuildContext context) {
    final change = FinanceDashboardEngine.percentChange(
      current: value,
      previous: previous,
    );
    final display = signed && value > 0 ? '+${compactMoney(value)}' : compactMoney(value);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.muted, fontSize: 9),
          ),
          const SizedBox(height: 3),
          Text(
            display,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color, fontWeight: FontWeight.w900),
          ),
          Text(
            change == null ? 'sem base' : '${change >= 0 ? '+' : ''}$change%',
            style: TextStyle(
              color: change == null ? AppColors.muted : color,
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _FinanceAction {
  const _FinanceAction({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
}

class _FinanceActionGrid extends StatelessWidget {
  const _FinanceActionGrid({required this.actions});

  final List<_FinanceAction> actions;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final width = (constraints.maxWidth - 8) / 2;
          final height = (constraints.maxHeight - 8) / 2;
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: actions
                .map(
                  (action) => SizedBox(
                    width: width,
                    height: height,
                    child: Material(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: action.onTap,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 9),
                          child: Row(
                            children: [
                              Icon(action.icon, size: 18, color: AppColors.green),
                              const SizedBox(width: 7),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      action.label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.muted,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      action.value,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          );
        },
      );
}

class _FinanceMoreCard extends StatelessWidget {
  const _FinanceMoreCard({
    required this.dashboard,
    required this.sponsors,
    required this.monthIncomeEntries,
    required this.monthExpenseEntries,
    required this.onOpenDetails,
  });

  final FinanceDashboardSnapshot dashboard;
  final List<SponsorshipContract> sponsors;
  final List<FinanceCategoryAmount> monthIncomeEntries;
  final List<FinanceCategoryAmount> monthExpenseEntries;
  final VoidCallback onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final projected = dashboard.forecast.projectedNet;
    final color = projected != null && projected < 0
        ? AppColors.danger
        : AppColors.green;
    final text = projected == null
        ? 'Previsão será exibida quando houver meses fechados com lançamentos.'
        : 'Previsão do próximo mês: ${projected >= 0 ? '+' : ''}${compactMoney(projected)}.';
    return SectionCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.insights_rounded, color: color),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              '$text ${sponsors.length} patrocínio(s), ${monthIncomeEntries.length} origem(ns) de receita e ${monthExpenseEntries.length} categoria(s) de gasto.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.muted, fontSize: 10.5),
            ),
          ),
          TextButton(
            onPressed: onOpenDetails,
            child: const Text('Detalhes'),
          ),
        ],
      ),
    );
  }
}

class _FinanceCategoryPreview extends StatelessWidget {
  const _FinanceCategoryPreview({
    required this.title,
    required this.total,
    required this.entries,
    required this.income,
    required this.emptyText,
    required this.onOpenDetails,
  });

  final String title;
  final int total;
  final List<FinanceCategoryAmount> entries;
  final bool income;
  final String emptyText;
  final VoidCallback onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final color = income ? AppColors.green : AppColors.danger;
    return SizedBox.expand(
      child: SectionCard(
        padding: const EdgeInsets.fromLTRB(13, 11, 13, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DashboardSectionHeader(
              title: title,
              subtitle: total == 0 ? 'Sem lançamentos no filtro atual' : compactMoney(total),
            ),
            const SizedBox(height: 8),
            if (entries.isEmpty)
              Text(emptyText, style: const TextStyle(color: AppColors.muted))
            else
              ...entries.take(3).map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Row(
                    children: [
                      Icon(entry.icon, size: 17, color: color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                      Text(
                        compactMoney(entry.amount),
                        style: TextStyle(color: color, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onOpenDetails,
                icon: const Icon(Icons.receipt_long_outlined, size: 17),
                label: const Text('Ver lançamentos'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinancePayrollSummary extends StatelessWidget {
  const _FinancePayrollSummary({
    required this.payroll,
    required this.playerCount,
    required this.monthIncome,
    required this.onContractsTap,
  });

  final int payroll;
  final int playerCount;
  final int monthIncome;
  final VoidCallback onContractsTap;

  @override
  Widget build(BuildContext context) {
    final ratio = monthIncome <= 0 ? null : (payroll * 100 / monthIncome).round();
    return SectionCard(
      padding: const EdgeInsets.fromLTRB(13, 11, 8, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FOLHA SALARIAL',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${compactMoney(payroll)}/mês',
                  style: const TextStyle(
                    color: AppColors.green,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '$playerCount jogador(es) • ${ratio == null ? 'sem base de receita no mês' : '$ratio% da receita do mês'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted, fontSize: 10),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onContractsTap,
            icon: const Icon(Icons.description_outlined, size: 17),
            label: const Text('Contratos'),
          ),
        ],
      ),
    );
  }
}

class _FinanceSalaryPreview extends StatelessWidget {
  const _FinanceSalaryPreview({
    required this.players,
    required this.onPlayerTap,
    required this.onOpenDetails,
  });

  final List<Player> players;
  final ValueChanged<Player> onPlayerTap;
  final VoidCallback onOpenDetails;

  @override
  Widget build(BuildContext context) => SizedBox.expand(
        child: SectionCard(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MAIORES SALÁRIOS',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              if (players.isEmpty)
                const Text(
                  'Nenhum jogador sob contrato.',
                  style: TextStyle(color: AppColors.muted),
                )
              else
                ...players.take(3).map(
                  (player) => InkWell(
                    onTap: () => onPlayerTap(player),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 3),
                      child: Row(
                        children: [
                          OverallShield(value: player.overall, compact: true),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  player.displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w800),
                                ),
                                Text(
                                  '${player.primaryPosition.label} • até ${player.contract.endSeason}',
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${compactMoney(player.salary)}/mês',
                            style: const TextStyle(
                              color: AppColors.green,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onOpenDetails,
                  icon: const Icon(Icons.groups_2_outlined, size: 17),
                  label: const Text('Ver toda a folha'),
                ),
              ),
            ],
          ),
        ),
      );
}

class _FinanceSheetHeader extends StatelessWidget {
  const _FinanceSheetHeader({required this.title, required this.onClose});

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 8, 8),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
            ),
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
      );
}

Future<void> _editBudgets(BuildContext context, WidgetRef ref) async {
  final career = ref.read(gameControllerProvider).career!;
  final allocation = await showBudgetAllocationDialog(context, career);
  if (allocation == null) return;
  try {
    final result = ClubAdministrationEngine.allocateBudgets(
      ref.read(gameControllerProvider).career!,
      allocation,
    );
    await ref.read(gameControllerProvider.notifier).commitCareer(
          result.state,
          message: result.message,
        );
  } on StateError catch (error) {
    ref.read(gameControllerProvider.notifier).showMessage(error.message.toString());
  }
}

Future<void> _openSponsorshipProposal(
  BuildContext context,
  WidgetRef ref,
  String proposalId,
) async {
  final career = ref.read(gameControllerProvider).career!;
  final proposal = career.clubAdministration.sponsorshipProposals
      .firstWhere((item) => item.id == proposalId);
  final decision = await showSponsorshipProposalDialog(context, proposal);
  if (decision == null) return;
  try {
    final current = ref.read(gameControllerProvider).career!;
    final result = switch (decision.type) {
      SponsorshipDecisionType.accept =>
        ClubAdministrationEngine.acceptSponsorship(current, proposalId),
      SponsorshipDecisionType.reject =>
        ClubAdministrationEngine.rejectSponsorship(current, proposalId),
      SponsorshipDecisionType.counter => ClubAdministrationEngine.counterSponsorship(
          current,
          proposalId,
          requestedAnnualValue: decision.requestedAnnualValue!,
        ),
    };
    await ref.read(gameControllerProvider.notifier).commitCareer(
          result.state,
          message: result.message,
        );
  } on StateError catch (error) {
    ref.read(gameControllerProvider.notifier).showMessage(error.message.toString());
  }
}
