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
import '../contracts/contracts_screen.dart';
import '../market/market_screen.dart';
import '../player/player_profile_screen.dart';
import '../stadium/stadium_screen.dart';
import 'finances_dashboard_components.dart';
import 'finances_management_components.dart';

class FinancesScreen extends ConsumerWidget {
  const FinancesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final career = ref.watch(gameControllerProvider).career!;
    final club = career.userClub;
    final txs = career.finances.reversed.toList(growable: false);
    final monthTransactions = career.finances
        .where(
          (tx) => tx.createdAt.year == career.currentDate.year && tx.createdAt.month == career.currentDate.month,
        )
        .toList(growable: false);
    final monthIncome = monthTransactions
        .where((tx) => tx.amount > 0)
        .fold<int>(0, (sum, tx) => sum + tx.amount);
    final monthExpenses = monthTransactions
        .where((tx) => tx.amount < 0)
        .fold<int>(0, (sum, tx) => sum + tx.amount.abs());
    final totalIncome = career.finances
        .where((tx) => tx.amount > 0)
        .fold<int>(0, (sum, tx) => sum + tx.amount);
    final totalExpenses = career.finances
        .where((tx) => tx.amount < 0)
        .fold<int>(0, (sum, tx) => sum + tx.amount.abs());
    final salaryLeaders = [...club.squad]..sort((a, b) => b.salary.compareTo(a.salary));
    final payroll = club.payroll;
    final sponsors = SponsorshipEngine.contractsFor(club, season: career.season);
    final budget = career.clubAdministration.budgetPlan;
    final historyPoints = _balanceHistory(career.finances, club.money);

    int monthCategory(FinanceCategory category, {required bool income}) => monthTransactions
        .where(
          (tx) => tx.kind.category == category && (income ? tx.amount > 0 : tx.amount < 0),
        )
        .fold<int>(0, (sum, tx) => sum + tx.amount.abs());

    final incomeCategories = [
      FinanceCategoryAmount(
        icon: Icons.stadium_outlined,
        label: 'Estádio',
        amount: monthCategory(FinanceCategory.stadium, income: true),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const StadiumScreen()),
        ),
      ),
      FinanceCategoryAmount(
        icon: Icons.handshake_outlined,
        label: 'Comercial',
        amount: monthCategory(FinanceCategory.commercial, income: true),
      ),
      FinanceCategoryAmount(
        icon: Icons.emoji_events_outlined,
        label: 'Premiações',
        amount: monthCategory(FinanceCategory.prizes, income: true),
      ),
      FinanceCategoryAmount(
        icon: Icons.sell_outlined,
        label: 'Transferências',
        amount: monthCategory(FinanceCategory.transfers, income: true),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MarketScreen(showBackButton: true)),
        ),
      ),
    ];
    final expenseCategories = [
      FinanceCategoryAmount(
        icon: Icons.groups_2_outlined,
        label: 'Folha salarial',
        amount: monthCategory(FinanceCategory.payroll, income: false),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ContractsScreen()),
        ),
      ),
      FinanceCategoryAmount(
        icon: Icons.shopping_cart_outlined,
        label: 'Transferências',
        amount: monthCategory(FinanceCategory.transfers, income: false),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MarketScreen(showBackButton: true)),
        ),
      ),
      FinanceCategoryAmount(
        icon: Icons.settings_suggest_outlined,
        label: 'Operações',
        amount: monthCategory(FinanceCategory.operations, income: false),
      ),
      FinanceCategoryAmount(
        icon: Icons.stadium_rounded,
        label: 'Estádio / obras',
        amount: monthCategory(FinanceCategory.stadium, income: false),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const StadiumScreen()),
        ),
      ),
    ];

    return PremiumScaffold(
      safeBottom: true,
      appBar: GameTopBar(
        title: 'Finanças',
        subtitle: 'Temporada ${career.season} • ${career.currentDate.month.toString().padLeft(2, '0')}/${career.currentDate.year}',
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
        children: [
          _FinanceHero(
            balance: club.money,
            transferBudget: club.transferBudget,
            income: monthIncome,
            expenses: monthExpenses,
          ),
          const SizedBox(height: 10),
          FinanceVisualSummary(
            income: monthIncome,
            expenses: monthExpenses,
            historyPoints: historyPoints,
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final split = constraints.maxWidth >= 680;
              final incomeCard = FinanceCategoryOverview(
                title: 'Receitas do mês',
                entries: incomeCategories,
                income: true,
              );
              final expenseCard = FinanceCategoryOverview(
                title: 'Maiores despesas do mês',
                entries: expenseCategories,
                income: false,
              );
              if (!split) {
                return Column(
                  children: [incomeCard, const SizedBox(height: 10), expenseCard],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: incomeCard),
                  const SizedBox(width: 10),
                  Expanded(child: expenseCard),
                ],
              );
            },
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
              onProposal: (proposal) => _openSponsorshipProposal(context, ref, proposal.id),
            ),
          ),
          _FinanceExpansion(
            icon: Icons.stadium_outlined,
            title: 'Estádio',
            subtitle: club.stadium.name,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.stadium_rounded, color: AppColors.green),
              title: Text(club.stadium.name, style: const TextStyle(fontWeight: FontWeight.w900)),
              subtitle: Text('${club.stadium.capacity} lugares • ingresso ${formatMoney(club.stadium.ticketPrice)}'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const StadiumScreen()),
              ),
            ),
          ),
          _FinanceExpansion(
            icon: Icons.receipt_long_outlined,
            title: 'Resumo acumulado',
            subtitle: 'Receitas ${compactMoney(totalIncome)} • Despesas ${compactMoney(totalExpenses)}',
            child: Row(
              children: [
                Expanded(
                  child: _CompactTotal(label: 'Receitas', value: totalIncome, color: AppColors.green),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _CompactTotal(label: 'Despesas', value: totalExpenses, color: AppColors.danger),
                ),
              ],
            ),
          ),
          _FinanceExpansion(
            icon: Icons.history_rounded,
            title: 'Histórico',
            subtitle: '${txs.length} lançamentos',
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
                              tx.isIncome ? Icons.add_circle_outline_rounded : Icons.remove_circle_outline_rounded,
                              color: tx.isIncome ? AppColors.green : AppColors.danger,
                            ),
                            title: Text(tx.description, style: const TextStyle(fontWeight: FontWeight.w700)),
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
          const SizedBox(height: 2),
          FinanceHealthStrip(
            balance: club.money,
            payroll: payroll,
            monthIncome: monthIncome,
            monthExpenses: monthExpenses,
          ),
        ],
      ),
    );
  }

  static List<double> _balanceHistory(List<FinanceTransaction> transactions, int currentBalance) {
    if (transactions.isEmpty) return [currentBalance.toDouble(), currentBalance.toDouble()];
    final recent = transactions.length > 12 ? transactions.sublist(transactions.length - 12) : transactions;
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
    required this.balance,
    required this.transferBudget,
    required this.income,
    required this.expenses,
  });

  final int balance;
  final int transferBudget;
  final int income;
  final int expenses;

  @override
  Widget build(BuildContext context) => FinanceHeroDashboard(
        balance: balance,
        transferBudget: transferBudget,
        monthIncome: income,
        monthExpenses: expenses,
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

class _SalaryRow extends StatelessWidget {
  const _SalaryRow({required this.player, required this.onTap});

  final Player player;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        leading: OverallShield(value: player.overall, compact: true),
        title: Text(player.displayName, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text('${player.primaryPosition.label} • ${player.age} anos'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${compactMoney(player.salary)}/mês', style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, size: 18),
          ],
        ),
        onTap: onTap,
      );
}

class _CompactTotal extends StatelessWidget {
  const _CompactTotal({required this.label, required this.value, required this.color});

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 9.5)),
            const SizedBox(height: 3),
            Text(compactMoney(value), style: TextStyle(color: color, fontWeight: FontWeight.w900)),
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
  final proposal = career.clubAdministration.sponsorshipProposals.firstWhere((item) => item.id == proposalId);
  final decision = await showSponsorshipProposalDialog(context, proposal);
  if (decision == null) return;
  try {
    final current = ref.read(gameControllerProvider).career!;
    final result = switch (decision.type) {
      SponsorshipDecisionType.accept => ClubAdministrationEngine.acceptSponsorship(current, proposalId),
      SponsorshipDecisionType.reject => ClubAdministrationEngine.rejectSponsorship(current, proposalId),
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
