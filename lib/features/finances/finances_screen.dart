import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/widgets/common.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/finance/finance.dart';
import '../../domain/finance/sponsorship.dart';
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

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
      children: [
        FinanceBalanceOverview(
          balance: club.money,
          dashboard: dashboard,
          periodMonths: _historyMonths,
          onPeriodChanged: (value) => setState(() => _historyMonths = value),
        ),
        const SizedBox(height: 10),
        FinanceMonthlyStatGrid(
          current: dashboard.currentMonth,
          previous: dashboard.previousMonth,
        ),
        const SizedBox(height: 10),
        FinanceDistributionCard(entries: monthExpenseEntries),
        const SizedBox(height: 10),
        FinanceForecastCard(
          forecast: dashboard.forecast,
          balance: club.money,
          payroll: club.payroll,
          transferBudget: club.transferBudget,
          onBudgetTap: () => _editBudgets(context, ref),
        ),
        const SizedBox(height: 13),
        const Text(
          'SISTEMAS RELACIONADOS',
          style: TextStyle(
            color: AppColors.muted,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: .5,
          ),
        ),
        const SizedBox(height: 8),
        FinanceQuickLinks(
          links: [
            FinanceQuickLink(
              icon: Icons.stadium_outlined,
              title: 'Estádio',
              value: club.stadium.name,
              onTap: () => _openStadium(context),
            ),
            FinanceQuickLink(
              icon: Icons.swap_horiz_rounded,
              title: 'Transferências',
              value: compactMoney(club.transferBudget),
              onTap: () => _openMarket(context),
            ),
            FinanceQuickLink(
              icon: Icons.description_outlined,
              title: 'Contratos',
              value: '${compactMoney(club.payroll)}/mês',
              onTap: () => _openContracts(context),
            ),
            FinanceQuickLink(
              icon: Icons.account_balance_outlined,
              title: 'Orçamentos',
              value: '${career.clubAdministration.budgetPlan.available.length} áreas',
              onTap: () => _editBudgets(context, ref),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _FinanceExpansion(
          icon: Icons.tune_rounded,
          title: 'Orçamentos',
          subtitle: 'Distribuição por departamento',
          child: DepartmentBudgetSection(
            career: career,
            onEdit: () => _editBudgets(context, ref),
          ),
        ),
        _FinanceExpansion(
          icon: Icons.handshake_outlined,
          title: 'Patrocínios',
          subtitle: '${sponsors.length} contrato(s) ativo(s)',
          child: SponsorshipManagementSection(
            contracts: sponsors,
            proposals: career.clubAdministration.sponsorshipProposals,
            onProposal: (proposal) =>
                _openSponsorshipProposal(context, ref, proposal.id),
          ),
        ),
        _FinanceExpansion(
          icon: Icons.trending_up_rounded,
          title: 'Receitas do mês',
          subtitle: compactMoney(dashboard.currentMonth.income),
          child: FinanceCategoryOverview(
            title: 'Origem das receitas',
            entries: monthIncomeEntries,
            income: true,
            emptyText: 'Nenhuma receita foi registrada neste mês.',
          ),
        ),
        _FinanceExpansion(
          icon: Icons.history_rounded,
          title: 'Histórico financeiro',
          subtitle: '${career.finances.length} lançamento(s) na carreira',
          child: FinanceTransactionsList(
            transactions: _sortTransactions(career.finances, career.currentDate),
            currentDate: career.currentDate,
            emptyTitle: 'Sem movimentações',
            emptyText: 'Receitas e despesas aparecerão aqui conforme a carreira avançar.',
            onTap: (transaction) => showFinanceTransactionDialog(context, transaction),
          ),
        ),
      ],
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

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
      children: [
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardSectionHeader(
                title: '$title da temporada',
                subtitle: 'Lançamentos já registrados na temporada ${career.season}',
              ),
              const SizedBox(height: 11),
              FinanceFilterChips(
                categories: categories,
                selected: selectedCategory,
                onSelected: onCategorySelected,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
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
          transactions: visible,
          currentDate: career.currentDate,
          emptyTitle: income ? 'Sem receitas' : 'Sem despesas',
          emptyText: selectedCategory == null
              ? 'Os lançamentos aparecerão aqui conforme a carreira avançar.'
              : 'Não há lançamentos nesta categoria para a temporada.',
          onTap: (transaction) => showFinanceTransactionDialog(context, transaction),
        ),
      ],
    );
  }

  Widget _salariesTab(BuildContext context, {required int monthIncome}) {
    final career = ref.read(gameControllerProvider).career!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
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

class _FinanceExpansion extends StatelessWidget {
  const _FinanceExpansion({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: SectionCard(
          padding: EdgeInsets.zero,
          child: ExpansionTile(
            leading: Icon(icon, color: AppColors.green),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
            childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            children: [child],
          ),
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
