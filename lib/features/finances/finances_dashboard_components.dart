import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/widgets/common.dart';
import '../../app/widgets/management_dashboard_widgets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';

class FinanceHeroDashboard extends StatelessWidget {
  const FinanceHeroDashboard({
    super.key,
    required this.balance,
    required this.transferBudget,
    required this.monthIncome,
    required this.monthExpenses,
  });

  final int balance;
  final int transferBudget;
  final int monthIncome;
  final int monthExpenses;

  @override
  Widget build(BuildContext context) {
    final monthResult = monthIncome - monthExpenses;
    final resultColor = monthResult < 0 ? AppColors.danger : AppColors.green;
    return SectionCard(
      padding: const EdgeInsets.all(15),
      borderColor: AppColors.green.withValues(alpha: .42),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const DashboardIconBadge(icon: Icons.account_balance_wallet_outlined, size: 44),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text('CAIXA ATUAL', style: TextStyle(color: AppColors.muted, fontSize: 9.5, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 2),
                    Text(
                      formatMoney(balance),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: balance < 0 ? AppColors.danger : AppColors.green,
                        fontSize: 29,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              DashboardStatusPill(
                label: monthResult < 0 ? 'Mês negativo' : 'Mês positivo',
                color: resultColor,
                icon: monthResult < 0 ? Icons.trending_down_rounded : Icons.trending_up_rounded,
              ),
            ],
          ),
          const SizedBox(height: 15),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.05,
            children: [
              DashboardStatTile(
                icon: Icons.south_west_rounded,
                label: 'Receitas do mês',
                value: compactMoney(monthIncome),
                compact: true,
              ),
              DashboardStatTile(
                icon: Icons.north_east_rounded,
                label: 'Despesas do mês',
                value: compactMoney(monthExpenses),
                color: monthExpenses > monthIncome && monthExpenses > 0 ? AppColors.danger : AppColors.warning,
                compact: true,
              ),
              DashboardStatTile(
                icon: Icons.balance_rounded,
                label: 'Fluxo mensal',
                value: compactMoney(monthResult),
                color: resultColor,
                compact: true,
              ),
              DashboardStatTile(
                icon: Icons.swap_horiz_rounded,
                label: 'Orç. transferências',
                value: compactMoney(transferBudget),
                compact: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FinanceVisualSummary extends StatelessWidget {
  const FinanceVisualSummary({
    super.key,
    required this.income,
    required this.expenses,
    required this.historyPoints,
  });

  final int income;
  final int expenses;
  final List<double> historyPoints;

  @override
  Widget build(BuildContext context) {
    final maxValue = math.max(1, math.max(income, expenses));
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardSectionHeader(
            title: 'Receitas x despesas',
            subtitle: 'Movimentação do mês atual',
          ),
          const SizedBox(height: 11),
          _CashBar(
            label: 'Receitas',
            value: income,
            maxValue: maxValue,
            color: AppColors.green,
          ),
          const SizedBox(height: 10),
          _CashBar(
            label: 'Despesas',
            value: expenses,
            maxValue: maxValue,
            color: AppColors.danger,
          ),
          const SizedBox(height: 16),
          const DashboardSectionHeader(
            title: 'EVOLUÇÃO DO SALDO',
            subtitle: 'Últimos lançamentos financeiros',
          ),
          const SizedBox(height: 8),
          Container(
            height: 104,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(15),
            ),
            child: CustomPaint(
              painter: FinanceBalancePainter(historyPoints),
            ),
          ),
        ],
      ),
    );
  }
}

class FinanceCategoryOverview extends StatelessWidget {
  const FinanceCategoryOverview({
    super.key,
    required this.title,
    required this.entries,
    required this.income,
  });

  final String title;
  final List<FinanceCategoryAmount> entries;
  final bool income;

  @override
  Widget build(BuildContext context) {
    final total = entries.fold<int>(0, (sum, item) => sum + item.amount);
    final maxValue = entries.fold<int>(1, (value, item) => math.max(value, item.amount));
    final accent = income ? AppColors.green : AppColors.danger;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardSectionHeader(
            title: title,
            subtitle: total == 0 ? 'Sem movimentação no mês' : compactMoney(total),
          ),
          const SizedBox(height: 8),
          ...entries.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _FinanceCategoryRow(
                item: item,
                maxValue: maxValue,
                accent: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FinanceCategoryAmount {
  const FinanceCategoryAmount({
    required this.icon,
    required this.label,
    required this.amount,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final int amount;
  final VoidCallback? onTap;
}

class _FinanceCategoryRow extends StatelessWidget {
  const _FinanceCategoryRow({
    required this.item,
    required this.maxValue,
    required this.accent,
  });

  final FinanceCategoryAmount item;
  final int maxValue;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
      child: Row(
        children: [
          Container(
            width: 31,
            height: 31,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: accent, size: 16),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 92,
            child: Text(
              item.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style:  TextStyle(color: AppColors.muted, fontSize: 9.5),
            ),
          ),
          Expanded(
            child: DashboardProgress(
              value: item.amount / maxValue,
              color: accent,
              height: 5,
            ),
          ),
          const SizedBox(width: 7),
          SizedBox(
            width: 66,
            child: Text(
              compactMoney(item.amount),
              textAlign: TextAlign.right,
              style: TextStyle(color: accent, fontSize: 9.5, fontWeight: FontWeight.w900),
            ),
          ),
          if (item.onTap != null) ...[
            const SizedBox(width: 2),
             Icon(Icons.chevron_right_rounded, color: AppColors.muted, size: 16),
          ],
        ],
      ),
    );

    if (item.onTap == null) return content;
    return Material(
      color: AppColors.surfaceRaised.withValues(alpha: .62),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(12),
        child: content,
      ),
    );
  }
}

class FinanceHealthStrip extends StatelessWidget {
  const FinanceHealthStrip({
    super.key,
    required this.balance,
    required this.payroll,
    required this.monthIncome,
    required this.monthExpenses,
  });

  final int balance;
  final int payroll;
  final int monthIncome;
  final int monthExpenses;

  @override
  Widget build(BuildContext context) {
    final payrollBase = math.max(1, monthIncome);
    final payrollRatio = payroll / payrollBase;
    final expenseRatio = monthIncome == 0 ? (monthExpenses == 0 ? 0.0 : 1.0) : monthExpenses / monthIncome;
    final liquidity = monthExpenses <= 0 ? 1.0 : balance / monthExpenses;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 1.95,
      children: [
        DashboardStatTile(
          icon: Icons.health_and_safety_outlined,
          label: 'Saúde financeira',
          value: balance >= 0 ? 'Positiva' : 'Crítica',
          color: balance >= 0 ? AppColors.green : AppColors.danger,
          compact: true,
        ),
        DashboardStatTile(
          icon: Icons.groups_2_outlined,
          label: 'Folha / receita do mês',
          value: monthIncome == 0 ? '—' : '${(payrollRatio * 100).round()}%',
          color: payrollRatio > .75 ? AppColors.warning : AppColors.green,
          compact: true,
        ),
        DashboardStatTile(
          icon: Icons.water_drop_outlined,
          label: 'Liquidez corrente',
          value: monthExpenses == 0 ? '—' : '${liquidity.toStringAsFixed(1)}x',
          color: liquidity < 1 ? AppColors.warning : AppColors.green,
          compact: true,
        ),
        DashboardStatTile(
          icon: Icons.percent_rounded,
          label: 'Despesa / receita',
          value: monthIncome == 0 ? '—' : '${(expenseRatio * 100).round()}%',
          color: expenseRatio > 1 ? AppColors.danger : AppColors.green,
          compact: true,
        ),
      ],
    );
  }
}

class FinanceBalancePainter extends CustomPainter {
  const FinanceBalancePainter(this.points);

  final List<double> points;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final minValue = points.reduce(math.min);
    final maxValue = points.reduce(math.max);
    final range = (maxValue - minValue).abs() < 1 ? 1.0 : maxValue - minValue;
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = size.width * i / (points.length - 1);
      final normalized = (points[i] - minValue) / range;
      final y = size.height - normalized * (size.height - 12) - 6;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.green.withValues(alpha: .18), Colors.transparent],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant FinanceBalancePainter oldDelegate) => oldDelegate.points != points;
}

class _CashBar extends StatelessWidget {
  const _CashBar({required this.label, required this.value, required this.maxValue, required this.color});

  final String label;
  final int value;
  final int maxValue;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
              Text(compactMoney(value), style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 5),
          DashboardProgress(value: value / maxValue, color: color, height: 7),
        ],
      );
}
