import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/widgets/common.dart';
import '../../app/widgets/management_dashboard_widgets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/club/club.dart';
import '../../domain/finance/finance.dart';
import '../../domain/player/player.dart';
import '../../game/finance/finance_dashboard_engine.dart';

class FinanceClubHeader extends StatelessWidget {
  const FinanceClubHeader({
    super.key,
    required this.club,
    required this.season,
  });

  final Club club;
  final int season;

  @override
  Widget build(BuildContext context) => SectionCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            ClubBadge(club: club, size: 64),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    club.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Temporada $season',
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.public_outlined,
                          color: AppColors.muted, size: 15),
                      const SizedBox(width: 5),
                      Text(
                        'Reputação ${club.reputation}',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 108),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _HeaderAmount(
                    icon: Icons.account_balance_wallet_outlined,
                    value: compactMoney(club.money),
                    color: club.money < 0 ? AppColors.danger : AppColors.green,
                    label: 'Caixa',
                  ),
                  const SizedBox(height: 8),
                  _HeaderAmount(
                    icon: Icons.swap_horiz_rounded,
                    value: compactMoney(club.transferBudget),
                    color: AppColors.warning,
                    label: 'Reforços',
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _HeaderAmount extends StatelessWidget {
  const _HeaderAmount({
    required this.icon,
    required this.value,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final String value;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 5),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: color, fontWeight: FontWeight.w900),
                ),
                Text(
                  label,
                  style: const TextStyle(color: AppColors.muted, fontSize: 9),
                ),
              ],
            ),
          ),
        ],
      );
}

class FinanceBalanceOverview extends StatelessWidget {
  const FinanceBalanceOverview({
    super.key,
    required this.balance,
    required this.dashboard,
    required this.periodMonths,
    required this.onPeriodChanged,
  });

  final int balance;
  final FinanceDashboardSnapshot dashboard;
  final int periodMonths;
  final ValueChanged<int> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    final delta = FinanceDashboardEngine.percentChange(
      current: dashboard.currentMonth.balance,
      previous: dashboard.previousMonth.balance,
    );
    final deltaAmount =
        dashboard.currentMonth.balance - dashboard.previousMonth.balance;
    final positive = deltaAmount >= 0;
    final deltaColor = positive ? AppColors.green : AppColors.danger;
    final hasComparableMonth = dashboard.previousMonth.hasTransactions;

    return SectionCard(
      padding: const EdgeInsets.all(15),
      borderColor: AppColors.green.withValues(alpha: .36),
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
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .4,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      formatMoney(balance),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: balance < 0 ? AppColors.danger : AppColors.green,
                        fontSize: 31,
                        height: 1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 7),
                    if (hasComparableMonth)
                      Row(
                        children: [
                          Icon(
                            positive
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            color: deltaColor,
                            size: 15,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${positive ? '+' : ''}${compactMoney(deltaAmount)}'
                              '${delta == null ? '' : ' (${positive ? '+' : ''}$delta%)'}'
                              ' vs. mês anterior',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: deltaColor,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      const Text(
                        'Aguardando comparação mensal',
                        style: TextStyle(color: AppColors.muted, fontSize: 10.5),
                      ),
                  ],
                ),
              ),
              PopupMenuButton<int>(
                initialValue: periodMonths,
                onSelected: onPeriodChanged,
                color: AppColors.surfaceRaised,
                tooltip: 'Período do gráfico',
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 3, child: Text('Últimos 3 meses')),
                  PopupMenuItem(value: 6, child: Text('Últimos 6 meses')),
                  PopupMenuItem(value: 12, child: Text('Últimos 12 meses')),
                ],
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Últimos $periodMonths meses',
                        style: const TextStyle(fontSize: 10.5),
                      ),
                      const SizedBox(width: 3),
                      const Icon(Icons.expand_more_rounded, size: 17),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FinanceBalanceChart(months: dashboard.months),
        ],
      ),
    );
  }
}

class FinanceBalanceChart extends StatelessWidget {
  const FinanceBalanceChart({
    super.key,
    required this.months,
    this.height = 166,
  });

  final List<FinanceMonthSummary> months;
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: FinanceMonthlyBalancePainter(months),
        ),
      );
}

class FinanceMonthlyBalancePainter extends CustomPainter {
  const FinanceMonthlyBalancePainter(this.months);

  final List<FinanceMonthSummary> months;

  @override
  void paint(Canvas canvas, Size size) {
    if (months.isEmpty || size.width <= 0 || size.height <= 0) return;
    final compact = size.height < 80;
    final top = compact ? 4.0 : 12.0;
    final bottom = compact ? 13.0 : 27.0;
    const side = 5.0;
    final chartHeight = math.max(1.0, size.height - top - bottom).toDouble();
    final chartWidth = math.max(1.0, size.width - side * 2).toDouble();
    final values = months.map((month) => month.balance.toDouble()).toList();
    final rawMin = values.reduce(math.min).toDouble();
    final rawMax = values.reduce(math.max).toDouble();
    final padding = math.max((rawMax - rawMin).abs() * .12, 1.0).toDouble();
    final minValue = rawMin - padding;
    final maxValue = rawMax + padding;
    final range = math.max(1.0, maxValue - minValue).toDouble();

    final gridPaint = Paint()
      ..color = AppColors.border.withValues(alpha: .56)
      ..strokeWidth = 1;
    for (var row = 0; row < 4; row++) {
      final y = top + (chartHeight * row / 3);
      canvas.drawLine(Offset(side, y), Offset(size.width - side, y), gridPaint);
    }

    Offset pointAt(int index) {
      final x = (months.length == 1
          ? size.width / 2
          : side + chartWidth * index / (months.length - 1))
          .toDouble();
      final normalized = (values[index] - minValue) / range;
      return Offset(x, top + chartHeight * (1 - normalized));
    }

    final line = Path();
    for (var index = 0; index < months.length; index++) {
      final point = pointAt(index);
      if (index == 0) {
        line.moveTo(point.dx, point.dy);
      } else {
        line.lineTo(point.dx, point.dy);
      }
    }
    final fill = Path.from(line)
      ..lineTo(size.width - side, top + chartHeight)
      ..lineTo(side, top + chartHeight)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.green.withValues(alpha: .25), Colors.transparent],
        ).createShader(Rect.fromLTWH(side, top, chartWidth, chartHeight)),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = AppColors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    for (var index = 0; index < months.length; index++) {
      final point = pointAt(index);
      canvas.drawCircle(point, 4.8, Paint()..color = AppColors.green);
      canvas.drawCircle(point, 2.2, Paint()..color = AppColors.surface);
      _paintLabel(
        canvas,
        _monthLabel(months[index].month),
        Offset(point.dx, size.height - (compact ? 10 : 17)),
        alignCenter: true,
        compact: compact,
      );
    }
  }

  void _paintLabel(
    Canvas canvas,
    String text,
    Offset offset, {
    bool alignCenter = false,
    bool compact = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: AppColors.muted, fontSize: compact ? 7 : 9),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      Offset(alignCenter ? offset.dx - painter.width / 2 : offset.dx, offset.dy),
    );
  }

  @override
  bool shouldRepaint(covariant FinanceMonthlyBalancePainter oldDelegate) =>
      oldDelegate.months != months;
}

String _monthLabel(DateTime month) => const [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez',
    ][month.month - 1];

class FinanceMonthlyStatGrid extends StatelessWidget {
  const FinanceMonthlyStatGrid({
    super.key,
    required this.current,
    required this.previous,
  });

  final FinanceMonthSummary current;
  final FinanceMonthSummary previous;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final vertical = constraints.maxWidth < 330;
          final tiles = [
            _MonthlyStat(
              icon: Icons.trending_up_rounded,
              label: 'Receita do mês',
              value: current.income,
              previousValue: previous.income,
              color: AppColors.green,
            ),
            _MonthlyStat(
              icon: Icons.trending_down_rounded,
              label: 'Despesa do mês',
              value: current.expenses,
              previousValue: previous.expenses,
              color: AppColors.danger,
            ),
            _MonthlyStat(
              icon: Icons.balance_rounded,
              label: 'Resultado do mês',
              value: current.net,
              previousValue: previous.net,
              color: current.net < 0 ? AppColors.danger : AppColors.green,
              signedValue: true,
            ),
          ];
          if (vertical) {
            return Column(
              children: [
                for (var index = 0; index < tiles.length; index++) ...[
                  SizedBox(height: 100, child: tiles[index]),
                  if (index < tiles.length - 1) const SizedBox(height: 8),
                ],
              ],
            );
          }
          return Row(
            children: [
              for (var index = 0; index < tiles.length; index++) ...[
                Expanded(child: SizedBox(height: 126, child: tiles[index])),
                if (index < tiles.length - 1) const SizedBox(width: 8),
              ],
            ],
          );
        },
      );
}

class _MonthlyStat extends StatelessWidget {
  const _MonthlyStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.previousValue,
    required this.color,
    this.signedValue = false,
  });

  final IconData icon;
  final String label;
  final int value;
  final int previousValue;
  final Color color;
  final bool signedValue;

  @override
  Widget build(BuildContext context) {
    final delta = FinanceDashboardEngine.percentChange(
      current: value,
      previous: previousValue,
    );
    final caption = delta == null
        ? 'Sem comparação'
        : '${delta >= 0 ? '+' : ''}$delta% vs. mês anterior';
    final visibleValue = signedValue && value > 0
        ? '+${compactMoney(value)}'
        : compactMoney(value);
    return DashboardStatTile(
      icon: icon,
      label: label,
      value: visibleValue,
      caption: caption,
      color: color,
      compact: true,
    );
  }
}

class FinanceCategoryAmount {
  const FinanceCategoryAmount({
    required this.category,
    required this.icon,
    required this.label,
    required this.amount,
    this.onTap,
  });

  final FinanceCategory category;
  final IconData icon;
  final String label;
  final int amount;
  final VoidCallback? onTap;
}

class FinanceCategoryOverview extends StatelessWidget {
  const FinanceCategoryOverview({
    super.key,
    required this.title,
    required this.entries,
    required this.income,
    this.emptyText,
  });

  final String title;
  final List<FinanceCategoryAmount> entries;
  final bool income;
  final String? emptyText;

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
            subtitle: total == 0 ? 'Sem movimentação no período' : compactMoney(total),
          ),
          const SizedBox(height: 9),
          if (entries.isEmpty)
            Text(
              emptyText ?? 'Nenhum lançamento nesta categoria.',
              style: const TextStyle(color: AppColors.muted, fontSize: 11),
            )
          else
            ...entries.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
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
            width: 88,
            child: Text(
              item.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.muted, fontSize: 10),
            ),
          ),
          Expanded(
            child: DashboardProgress(
              value: item.amount / maxValue,
              color: accent,
              height: 6,
            ),
          ),
          const SizedBox(width: 7),
          SizedBox(
            width: 62,
            child: Text(
              compactMoney(item.amount),
              textAlign: TextAlign.right,
              style: TextStyle(
                color: accent,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          if (item.onTap != null) ...[
            const SizedBox(width: 2),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.muted, size: 16),
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

class FinanceDistributionCard extends StatelessWidget {
  const FinanceDistributionCard({
    super.key,
    required this.entries,
  });

  final List<FinanceCategoryAmount> entries;

  @override
  Widget build(BuildContext context) {
    final total = entries.fold<int>(0, (sum, item) => sum + item.amount);
    final maxValue = entries.fold<int>(1, (value, item) => math.max(value, item.amount));
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardSectionHeader(
            title: 'Distribuição de gastos',
            subtitle: 'Lançamentos do mês atual',
          ),
          const SizedBox(height: 9),
          if (entries.isEmpty)
            const Text(
              'Ainda não há despesas registradas neste mês.',
              style: TextStyle(color: AppColors.muted, fontSize: 11),
            )
          else
            ...entries.map((item) {
              final percent = total == 0 ? 0 : (item.amount * 100 / total).round();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Icon(item.icon, color: AppColors.green, size: 19),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 96,
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Expanded(
                      child: DashboardProgress(
                        value: item.amount / maxValue,
                        color: AppColors.green,
                        height: 8,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 48,
                      child: Text(
                        compactMoney(item.amount),
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 5),
                    SizedBox(
                      width: 32,
                      child: Text(
                        '$percent%',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: AppColors.green,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class FinanceForecastCard extends StatelessWidget {
  const FinanceForecastCard({
    super.key,
    required this.forecast,
    required this.balance,
    required this.payroll,
    required this.transferBudget,
    required this.onBudgetTap,
  });

  final FinanceForecast forecast;
  final int balance;
  final int payroll;
  final int transferBudget;
  final VoidCallback onBudgetTap;

  @override
  Widget build(BuildContext context) {
    final projectedNet = forecast.projectedNet;
    final projectedBalance = projectedNet == null ? null : balance + projectedNet;
    final color = (projectedNet ?? 0) < 0 ? AppColors.danger : AppColors.green;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardSectionHeader(
            title: 'Previsão financeira',
            subtitle: 'Estimativa baseada somente no histórico registrado',
          ),
          const SizedBox(height: 13),
          if (!forecast.hasData)
            const _ForecastEmptyState()
          else ...[
            Row(
              children: [
                DashboardIconBadge(
                  icon: projectedNet! >= 0
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  color: color,
                  size: 62,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PRÓXIMO MÊS',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${projectedNet! >= 0 ? '+' : ''}${compactMoney(projectedNet!)}',
                        style: TextStyle(
                          color: color,
                          fontSize: 25,
                          height: 1,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Saldo projetado: ${compactMoney(projectedBalance!)}',
                        style: const TextStyle(color: AppColors.muted, fontSize: 10.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ForecastLine(
              icon: Icons.analytics_outlined,
              label: 'Base da estimativa',
              text: 'Média dos últimos ${forecast.monthsUsed} mês(es) fechados.',
            ),
            _ForecastLine(
              icon: Icons.arrow_upward_rounded,
              label: 'Receita média',
              text: compactMoney(forecast.projectedIncome!),
              positive: true,
            ),
            _ForecastLine(
              icon: Icons.arrow_downward_rounded,
              label: 'Despesa média',
              text: compactMoney(forecast.projectedExpenses!),
              positive: false,
            ),
          ],
          const SizedBox(height: 12),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 11),
          _ForecastLine(
            icon: Icons.groups_2_outlined,
            label: 'Folha salarial atual',
            text: '${compactMoney(payroll)}/mês',
          ),
          _ForecastLine(
            icon: Icons.swap_horiz_rounded,
            label: 'Orçamento para reforços',
            text: compactMoney(transferBudget),
          ),
          const SizedBox(height: 7),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onBudgetTap,
              icon: const Icon(Icons.account_balance_outlined, size: 18),
              label: const Text('VER DETALHES DO ORÇAMENTO'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ForecastEmptyState extends StatelessWidget {
  const _ForecastEmptyState();

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            Icon(Icons.schedule_rounded, color: AppColors.warning),
            SizedBox(width: 9),
            Expanded(
              child: Text(
                'A previsão será exibida após existir pelo menos um mês fechado com lançamentos.',
                style: TextStyle(color: AppColors.muted, fontSize: 11),
              ),
            ),
          ],
        ),
      );
}

class _ForecastLine extends StatelessWidget {
  const _ForecastLine({
    required this.icon,
    required this.label,
    required this.text,
    this.positive,
  });

  final IconData icon;
  final String label;
  final String text;
  final bool? positive;

  @override
  Widget build(BuildContext context) {
    final color = positive == null
        ? AppColors.green
        : positive!
            ? AppColors.green
            : AppColors.danger;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 11)),
          ),
          Text(
            text,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class FinanceQuickLink {
  const FinanceQuickLink({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;
}

class FinanceQuickLinks extends StatelessWidget {
  const FinanceQuickLinks({super.key, required this.links});

  final List<FinanceQuickLink> links;

  @override
  Widget build(BuildContext context) => GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.98,
        children: links
            .map(
              (link) => Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: link.onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        DashboardIconBadge(icon: link.icon, size: 32),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                link.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                link.value,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded,
                            color: AppColors.muted, size: 17),
                      ],
                    ),
                  ),
                ),
              ),
            )
            .toList(growable: false),
      );
}

class FinanceFilterChips extends StatelessWidget {
  const FinanceFilterChips({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  final List<FinanceCategory> categories;
  final FinanceCategory? selected;
  final ValueChanged<FinanceCategory?> onSelected;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ChoiceChip(
              label: const Text('Todas'),
              selected: selected == null,
              onSelected: (_) => onSelected(null),
            ),
            for (final category in categories) ...[
              const SizedBox(width: 6),
              ChoiceChip(
                label: Text(category.label),
                selected: selected == category,
                onSelected: (_) => onSelected(category),
              ),
            ],
          ],
        ),
      );
}

class FinanceTransactionsList extends StatelessWidget {
  const FinanceTransactionsList({
    super.key,
    required this.transactions,
    required this.currentDate,
    required this.emptyTitle,
    required this.emptyText,
    required this.onTap,
  });

  final List<FinanceTransaction> transactions;
  final DateTime currentDate;
  final String emptyTitle;
  final String emptyText;
  final ValueChanged<FinanceTransaction> onTap;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return SectionCard(
        child: EmptyState(
          icon: Icons.receipt_long_outlined,
          title: emptyTitle,
          text: emptyText,
        ),
      );
    }
    return SectionCard(
      padding: const EdgeInsets.fromLTRB(12, 5, 12, 5),
      child: Column(
        children: transactions
            .map(
              (transaction) => ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 2),
                onTap: () => onTap(transaction),
                leading: Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: (transaction.isIncome
                            ? AppColors.green
                            : AppColors.danger)
                        .withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    transaction.isIncome
                        ? Icons.add_circle_outline_rounded
                        : Icons.remove_circle_outline_rounded,
                    color: transaction.isIncome
                        ? AppColors.green
                        : AppColors.danger,
                    size: 18,
                  ),
                ),
                title: Text(
                  transaction.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  '${fullDate(FinanceDashboardEngine.effectiveDate(transaction, currentDate))} • ${transaction.kind.label}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted, fontSize: 10),
                ),
                trailing: Text(
                  formatMoney(transaction.amount),
                  style: TextStyle(
                    color: transaction.isIncome
                        ? AppColors.green
                        : AppColors.danger,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class FinanceSalaryPanel extends StatelessWidget {
  const FinanceSalaryPanel({
    super.key,
    required this.players,
    required this.payroll,
    required this.monthIncome,
    required this.onPlayerTap,
    required this.onContractsTap,
  });

  final List<Player> players;
  final int payroll;
  final int monthIncome;
  final ValueChanged<Player> onPlayerTap;
  final VoidCallback onContractsTap;

  @override
  Widget build(BuildContext context) {
    final sorted = [...players]..sort((a, b) => b.salary.compareTo(a.salary));
    final ratio = monthIncome <= 0 ? null : (payroll * 100 / monthIncome).round();
    return Column(
      children: [
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardSectionHeader(
                title: 'Folha salarial',
                subtitle: '${players.length} jogador(es) sob contrato',
                trailing: TextButton.icon(
                  onPressed: onContractsTap,
                  icon: const Icon(Icons.description_outlined, size: 16),
                  label: const Text('Contratos'),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _SalaryMetric(
                      label: 'Folha atual',
                      value: '${compactMoney(payroll)}/mês',
                      color: AppColors.green,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SalaryMetric(
                      label: 'Folha / receita do mês',
                      value: ratio == null ? '—' : '$ratio%',
                      color: ratio != null && ratio > 75
                          ? AppColors.warning
                          : AppColors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SectionCard(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Column(
            children: sorted
                .map(
                  (player) => ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 2),
                    dense: true,
                    onTap: () => onPlayerTap(player),
                    leading: OverallShield(value: player.overall, compact: true),
                    title: Text(
                      player.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      '${player.primaryPosition.label} • contrato até ${player.contract.endSeason}',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 10,
                      ),
                    ),
                    trailing: Text(
                      '${compactMoney(player.salary)}/mês',
                      style: const TextStyle(
                        color: AppColors.green,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ),
      ],
    );
  }
}

class _SalaryMetric extends StatelessWidget {
  const _SalaryMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: color.withValues(alpha: .22)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.muted, fontSize: 9.5),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      );
}
