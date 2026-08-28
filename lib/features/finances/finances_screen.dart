import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/widgets/common.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/finance/finance.dart';
import '../../domain/player/player.dart';
import '../../game/finance/club_administration_engine.dart';
import '../../game/finance/sponsorship_engine.dart';
import 'finances_management_components.dart';
import '../player/player_profile_screen.dart';
import '../stadium/stadium_screen.dart';

class FinancesScreen extends ConsumerWidget {
  const FinancesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final career = ref.watch(gameControllerProvider).career!;
    final club = career.userClub;
    final txs = career.finances.reversed.toList(growable: false);
    final income = career.finances
        .where((t) => t.amount > 0)
        .fold<int>(0, (sum, t) => sum + t.amount);
    final expenses = career.finances
        .where((t) => t.amount < 0)
        .fold<int>(0, (sum, t) => sum + t.amount.abs());
    final balance = income - expenses;
    final monthTransactions = career.finances.where(
      (tx) => tx.createdAt.year == career.currentDate.year &&
          tx.createdAt.month == career.currentDate.month,
    );
    final monthIncome = monthTransactions
        .where((tx) => tx.amount > 0)
        .fold<int>(0, (sum, tx) => sum + tx.amount);
    final monthExpenses = monthTransactions
        .where((tx) => tx.amount < 0)
        .fold<int>(0, (sum, tx) => sum + tx.amount.abs());
    final transferSales = career.finances
        .where(
          (tx) =>
              tx.amount > 0 &&
              (tx.kind == FinanceKind.playerSale ||
                  tx.kind == FinanceKind.transferIn),
        )
        .fold<int>(0, (sum, tx) => sum + tx.amount);
    final transferPurchases = career.finances
        .where(
          (tx) =>
              tx.amount < 0 &&
              (tx.kind == FinanceKind.playerPurchase ||
                  tx.kind == FinanceKind.transferOut),
        )
        .fold<int>(0, (sum, tx) => sum + tx.amount.abs());
    int categoryIncome(FinanceCategory category) => career.finances
        .where((tx) => tx.kind.category == category && tx.amount > 0)
        .fold<int>(0, (sum, tx) => sum + tx.amount);
    int categoryExpense(FinanceCategory category) => career.finances
        .where((tx) => tx.kind.category == category && tx.amount < 0)
        .fold<int>(0, (sum, tx) => sum + tx.amount.abs());
    final salaryLeaders = [...club.squad]
      ..sort((a, b) => b.salary.compareTo(a.salary));
    final payroll = club.squad.fold<int>(0, (sum, p) => sum + p.salary);
    final sponsors = SponsorshipEngine.contractsFor(
      club,
      season: career.season,
    );
    final budget = career.clubAdministration.budgetPlan;
    final historyPoints = _balanceHistory(career.finances, club.money);

    return PremiumScaffold(
      appBar: GameTopBar(
        title: 'Finanças',
        subtitle: '${club.name} • Temporada ${career.season}',
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
        children: [
          _FinanceHero(
            clubName: club.name,
            balance: club.money,
            budget: budget.totalAvailable,
            income: monthIncome,
            expenses: monthExpenses,
            result: monthIncome - monthExpenses,
          ),
          const SizedBox(height: 10),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle(
                  title: 'RESUMO VISUAL',
                  subtitle: 'Receitas x despesas',
                ),
                const SizedBox(height: 12),
                _IncomeExpenseBars(income: monthIncome, expenses: monthExpenses),
                const SizedBox(height: 16),
                const _SectionTitle(
                  title: 'EVOLUÇÃO DO SALDO',
                  subtitle: 'Últimos lançamentos',
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 92,
                  width: double.infinity,
                  child: CustomPaint(painter: _BalanceSparklinePainter(historyPoints)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle(
                  title: 'VISÃO GERAL',
                  subtitle: 'Situação atual do clube',
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.75,
                  children: [
                    _SummaryTile(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Saldo atual',
                      value: compactMoney(club.money),
                    ),
                    _SummaryTile(
                      icon: Icons.swap_horiz_rounded,
                      label: 'Orçamento transferências',
                      value: compactMoney(club.transferBudget),
                    ),
                    _SummaryTile(
                      icon: Icons.groups_rounded,
                      label: 'Folha salarial',
                      value: '${compactMoney(payroll)}/mês',
                    ),
                    _SummaryTile(
                      icon: Icons.trending_up_rounded,
                      label: 'Resultado acumulado',
                      value: compactMoney(balance),
                      negative: balance < 0,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _FinanceExpansion(
            icon: Icons.pie_chart_outline_rounded,
            title: 'Orçamentos',
            subtitle: 'Distribuição por departamento',
            child: DepartmentBudgetSection(
              career: career,
              onEdit: () => _editBudgets(context, ref),
            ),
          ),
          _FinanceExpansion(
            icon: Icons.south_west_rounded,
            title: 'Receitas',
            subtitle: compactMoney(income),
            child: _CategoryGrid(
              entries: [
                _CategoryData(Icons.stadium_rounded, 'Estádio', categoryIncome(FinanceCategory.stadium)),
                _CategoryData(Icons.handshake_rounded, 'Comercial', categoryIncome(FinanceCategory.commercial)),
                _CategoryData(Icons.emoji_events_rounded, 'Premiações', categoryIncome(FinanceCategory.prizes)),
                _CategoryData(Icons.sell_outlined, 'Vendas', transferSales),
              ],
            ),
          ),
          _FinanceExpansion(
            icon: Icons.north_east_rounded,
            title: 'Despesas',
            subtitle: compactMoney(expenses),
            child: _CategoryGrid(
              entries: [
                _CategoryData(Icons.groups_rounded, 'Salários', categoryExpense(FinanceCategory.payroll)),
                _CategoryData(Icons.shopping_cart_outlined, 'Compras', transferPurchases),
                _CategoryData(Icons.settings_suggest_rounded, 'Operações', categoryExpense(FinanceCategory.operations)),
              ],
            ),
          ),
          _FinanceExpansion(
            icon: Icons.swap_horiz_rounded,
            title: 'Transferências',
            subtitle: 'Vendas ${compactMoney(transferSales)} • Compras ${compactMoney(transferPurchases)}',
            child: _CategoryGrid(
              entries: [
                _CategoryData(Icons.sell_outlined, 'Vendas de jogadores', transferSales),
                _CategoryData(Icons.shopping_cart_outlined, 'Compras de jogadores', transferPurchases),
              ],
            ),
          ),
          _FinanceExpansion(
            icon: Icons.groups_rounded,
            title: 'Salários',
            subtitle: '${compactMoney(payroll)}/mês',
            child: Column(
              children: salaryLeaders
                  .take(6)
                  .map(
                    (player) => _SalaryRow(
                      player: player,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PlayerProfileScreen(
                            playerId: player.id,
                            clubId: club.id,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
          _FinanceExpansion(
            icon: Icons.handshake_outlined,
            title: 'Patrocínios',
            subtitle: '${sponsors.length} contratos',
            child: SponsorshipManagementSection(
              contracts: sponsors,
              proposals: career.clubAdministration.sponsorshipProposals,
              onProposal: (proposal) =>
                  _openSponsorshipProposal(context, ref, proposal.id),
            ),
          ),
          _FinanceExpansion(
            icon: Icons.stadium_outlined,
            title: 'Estádio',
            subtitle: club.stadium.name,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.stadium_rounded, color: AppColors.green),
              title: Text(club.stadium.name,
                  style: const TextStyle(fontWeight: FontWeight.w900)),
              subtitle: Text(
                '${club.stadium.capacity} lugares • ingresso ${formatMoney(club.stadium.ticketPrice)}',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const StadiumScreen()),
              ),
            ),
          ),
          _FinanceExpansion(
            icon: Icons.history_rounded,
            title: 'Histórico',
            subtitle: '${txs.length} lançamentos',
            initiallyExpanded: false,
            child: txs.isEmpty
                ? const EmptyState(
                    icon: Icons.receipt_long_rounded,
                    title: 'Sem movimentações',
                    text: 'Receitas e despesas aparecerão aqui conforme a carreira avançar.',
                  )
                : Column(
                    children: txs
                        .map(
                          (tx) => ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            onTap: () => showFinanceTransactionDialog(context, tx),
                            leading: Icon(
                              tx.isIncome
                                  ? Icons.add_circle_outline_rounded
                                  : Icons.remove_circle_outline_rounded,
                              color: tx.isIncome ? AppColors.green : AppColors.danger,
                            ),
                            title: Text(tx.description,
                                style: const TextStyle(fontWeight: FontWeight.w700)),
                            subtitle: Text('Rodada ${tx.round} • ${tx.kind.label}'),
                            trailing: Text(
                              formatMoney(tx.amount),
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: tx.isIncome ? AppColors.green : AppColors.danger,
                              ),
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
          ),
        ],
      ),
    );
  }

  static List<double> _balanceHistory(
    List<FinanceTransaction> transactions,
    int currentBalance,
  ) {
    if (transactions.isEmpty) return const [0, 0];
    final recent = transactions.length > 12
        ? transactions.sublist(transactions.length - 12)
        : transactions;
    var start = currentBalance - recent.fold<int>(0, (sum, tx) => sum + tx.amount);
    final points = <double>[start.toDouble()];
    for (final tx in recent) {
      start += tx.amount;
      points.add(start.toDouble());
    }
    return points;
  }
}

class _FinanceHero extends StatelessWidget {
  const _FinanceHero({
    required this.clubName,
    required this.balance,
    required this.budget,
    required this.income,
    required this.expenses,
    required this.result,
  });

  final String clubName;
  final int balance;
  final int budget;
  final int income;
  final int expenses;
  final int result;

  @override
  Widget build(BuildContext context) => SectionCard(
        borderColor: AppColors.green.withValues(alpha: .35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(clubName,
                style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              formatMoney(balance),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: balance < 0 ? AppColors.danger : AppColors.green,
                  ),
            ),
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.15,
              children: [
                _MiniFinanceCard('Orçamento', compactMoney(budget), Icons.account_balance_outlined),
                _MiniFinanceCard('Receitas do mês', compactMoney(income), Icons.south_west_rounded),
                _MiniFinanceCard('Despesas do mês', compactMoney(expenses), Icons.north_east_rounded),
                _MiniFinanceCard('Resultado do mês', compactMoney(result), Icons.balance_rounded,
                    negative: result < 0),
              ],
            ),
          ],
        ),
      );
}

class _MiniFinanceCard extends StatelessWidget {
  const _MiniFinanceCard(this.label, this.value, this.icon, {this.negative = false});
  final String label;
  final String value;
  final IconData icon;
  final bool negative;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: negative ? AppColors.danger : AppColors.green),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 10)),
                  const SizedBox(height: 2),
                  Text(value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: negative ? AppColors.danger : null,
                      )),
                ],
              ),
            ),
          ],
        ),
      );
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.icon,
    required this.label,
    required this.value,
    this.negative = false,
  });
  final IconData icon;
  final String label;
  final String value;
  final bool negative;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: negative ? AppColors.danger : AppColors.green, size: 20),
            const SizedBox(height: 7),
            Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 10)),
            const SizedBox(height: 2),
            Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: negative ? AppColors.danger : null)),
          ],
        ),
      );
}

class _IncomeExpenseBars extends StatelessWidget {
  const _IncomeExpenseBars({required this.income, required this.expenses});
  final int income;
  final int expenses;

  @override
  Widget build(BuildContext context) {
    final maxValue = [income, expenses, 1].reduce((a, b) => a > b ? a : b);
    return Column(
      children: [
        _bar('Receitas', income, maxValue, false),
        const SizedBox(height: 10),
        _bar('Despesas', expenses, maxValue, true),
      ],
    );
  }

  Widget _bar(String label, int value, int maxValue, bool expense) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800))),
              Text(compactMoney(value), style: const TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              minHeight: 9,
              value: value / maxValue,
              backgroundColor: AppColors.surfaceRaised,
              color: expense ? AppColors.danger : AppColors.green,
            ),
          ),
        ],
      );
}

class _BalanceSparklinePainter extends CustomPainter {
  const _BalanceSparklinePainter(this.points);
  final List<double> points;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final minValue = points.reduce((a, b) => a < b ? a : b);
    final maxValue = points.reduce((a, b) => a > b ? a : b);
    final range = (maxValue - minValue).abs() < 1 ? 1.0 : maxValue - minValue;
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = size.width * i / (points.length - 1);
      final normalized = (points[i] - minValue) / range;
      final y = size.height - (normalized * (size.height - 12)) - 6;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final paint = Paint()
      ..color = AppColors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BalanceSparklinePainter oldDelegate) =>
      oldDelegate.points != points;
}

class _FinanceExpansion extends StatelessWidget {
  const _FinanceExpansion({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
    this.initiallyExpanded = false,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: SectionCard(
          padding: EdgeInsets.zero,
          child: ExpansionTile(
            initiallyExpanded: initiallyExpanded,
            leading: Icon(icon, color: AppColors.green),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            subtitle: Text(subtitle),
            childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            children: [child],
          ),
        ),
      );
}

class _CategoryData {
  const _CategoryData(this.icon, this.label, this.amount);
  final IconData icon;
  final String label;
  final int amount;
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.entries});
  final List<_CategoryData> entries;

  @override
  Widget build(BuildContext context) => GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 2.05,
        children: entries
            .map((item) => _CategoryTile(
                  icon: item.icon,
                  label: item.label,
                  amount: item.amount,
                ))
            .toList(growable: false),
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
    ref.read(gameControllerProvider.notifier).showMessage(
          error.message.toString(),
        );
  }
}

Future<void> _openSponsorshipProposal(
  BuildContext context,
  WidgetRef ref,
  String proposalId,
) async {
  final career = ref.read(gameControllerProvider).career!;
  final proposal = career.clubAdministration.sponsorshipProposals.firstWhere(
    (item) => item.id == proposalId,
  );
  final decision = await showSponsorshipProposalDialog(context, proposal);
  if (decision == null) return;
  try {
    final current = ref.read(gameControllerProvider).career!;
    final result = switch (decision.type) {
      SponsorshipDecisionType.accept =>
        ClubAdministrationEngine.acceptSponsorship(current, proposalId),
      SponsorshipDecisionType.reject =>
        ClubAdministrationEngine.rejectSponsorship(current, proposalId),
      SponsorshipDecisionType.counter =>
        ClubAdministrationEngine.counterSponsorship(
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
    ref.read(gameControllerProvider.notifier).showMessage(
          error.message.toString(),
        );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: AppColors.muted, fontSize: 9.5),
          ),
        ],
      );
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.icon,
    required this.label,
    required this.amount,
  });

  final IconData icon;
  final String label;
  final int amount;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.green, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    compactMoney(amount),
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: amount < 0 ? AppColors.danger : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _SalaryRow extends StatelessWidget {
  const _SalaryRow({required this.player, required this.onTap});

  final Player player;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
        leading: OverallShield(value: player.overall, compact: true),
        title: Text(
          player.displayName,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text('${player.primaryPosition.label} • ${player.age} anos'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${compactMoney(player.salary)}/mês',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, size: 18),
          ],
        ),
        onTap: onTap,
      );
}
