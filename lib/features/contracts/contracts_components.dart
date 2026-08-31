import 'package:flutter/material.dart';

import '../../app/widgets/common.dart';
import '../../app/widgets/management_dashboard_widgets.dart';
import '../../app/widgets/player_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/player/player.dart';
import '../../game/contract/contract_engine.dart';

enum ContractVisualStatus { risk, attention, safe }

extension ContractVisualStatusX on ContractVisualStatus {
  String get label => switch (this) {
        ContractVisualStatus.risk => 'RISCO DE SAÍDA',
        ContractVisualStatus.attention => 'RENOVAR EM BREVE',
        ContractVisualStatus.safe => 'CONTRATO ATIVO',
      };

  String get shortLabel => switch (this) {
        ContractVisualStatus.risk => 'Vence nesta temporada',
        ContractVisualStatus.attention => 'Vence na próxima',
        ContractVisualStatus.safe => 'Seguro',
      };

  Color get color => switch (this) {
        ContractVisualStatus.risk => AppColors.danger,
        ContractVisualStatus.attention => AppColors.warning,
        ContractVisualStatus.safe => AppColors.green,
      };

  IconData get icon => switch (this) {
        ContractVisualStatus.risk => Icons.error_outline_rounded,
        ContractVisualStatus.attention => Icons.schedule_rounded,
        ContractVisualStatus.safe => Icons.verified_user_outlined,
      };
}

class ContractsOverviewCard extends StatelessWidget {
  const ContractsOverviewCard({
    super.key,
    required this.total,
    required this.risk,
    required this.attention,
    required this.safe,
    required this.payroll,
    required this.squadValue,
    required this.onStatusSelected,
  });

  final int total;
  final int risk;
  final int attention;
  final int safe;
  final int payroll;
  final int squadValue;
  final ValueChanged<ContractListFilter> onStatusSelected;

  @override
  Widget build(BuildContext context) {
    final secureShare = total == 0 ? 0.0 : safe / total;
    final headline = risk == 0 && attention == 0
        ? 'Todos os contratos estão sob controle'
        : safe >= risk + attention
            ? 'A maioria do elenco está segura'
            : 'Atenção aos próximos vencimentos';
    return SectionCard(
      borderColor: AppColors.green.withValues(alpha: .35),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DashboardIconBadge(
                icon: Icons.edit_document,
                size: 52,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      headline,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Revisão de $total atleta(s) do elenco principal',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 10.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DashboardProgress(value: secureShare),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _OverviewCount(
                  value: safe,
                  label: 'Seguros',
                  color: AppColors.green,
                  onTap: () => onStatusSelected(ContractListFilter.safe),
                ),
              ),
              Expanded(
                child: _OverviewCount(
                  value: attention,
                  label: 'Atenção',
                  color: AppColors.warning,
                  onTap: () => onStatusSelected(ContractListFilter.attention),
                ),
              ),
              Expanded(
                child: _OverviewCount(
                  value: risk,
                  label: 'Vencendo',
                  color: AppColors.danger,
                  onTap: () => onStatusSelected(ContractListFilter.risk),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _MoneyMetric(
                    label: 'Folha salarial',
                    value: '${compactMoney(payroll)}/mês',
                  ),
                ),
                Container(width: 1, height: 34, color: AppColors.border),
                const SizedBox(width: 12),
                Expanded(
                  child: _MoneyMetric(
                    label: 'Valor do elenco',
                    value: compactMoney(squadValue),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ContractFilterBar extends StatelessWidget {
  const ContractFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.counts,
  });

  final ContractListFilter selected;
  final ValueChanged<ContractListFilter> onSelected;
  final Map<ContractListFilter, int> counts;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: ContractListFilter.values.length,
          separatorBuilder: (_, _) => const SizedBox(width: 7),
          itemBuilder: (context, index) {
            final filter = ContractListFilter.values[index];
            final active = filter == selected;
            return ChoiceChip(
              selected: active,
              onSelected: (_) => onSelected(filter),
              showCheckmark: false,
              label: Text('${filter.label} ${counts[filter] ?? 0}'),
              labelStyle: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: active ? Colors.black : AppColors.muted,
              ),
              selectedColor: AppColors.green,
              backgroundColor: AppColors.surface,
              side: BorderSide(
                color: active ? AppColors.green : AppColors.border,
              ),
            );
          },
        ),
      );
}

enum ContractListFilter { all, risk, attention, safe }

extension ContractListFilterX on ContractListFilter {
  String get label => switch (this) {
        ContractListFilter.all => 'Todos',
        ContractListFilter.risk => 'Vence agora',
        ContractListFilter.attention => 'Próx. temp.',
        ContractListFilter.safe => 'Seguros',
      };
}

class ContractPlayerCard extends StatelessWidget {
  const ContractPlayerCard({
    super.key,
    required this.player,
    required this.status,
    required this.onTap,
    required this.onRenew,
    this.loanedOut = false,
    this.loanedTo,
  });

  final Player player;
  final ContractVisualStatus status;
  final VoidCallback onTap;
  final VoidCallback onRenew;
  final bool loanedOut;
  final String? loanedTo;

  @override
  Widget build(BuildContext context) {
    final color = status.color;
    return SectionCard(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.only(bottom: 8),
      borderColor: color.withValues(alpha: .24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(11, 10, 8, 10),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  PlayerAvatar(player: player, size: 46),
                  Positioned(
                    right: -5,
                    bottom: -4,
                    child: OverallShield(value: player.overall, compact: true),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            player.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                        Text(
                          '${compactMoney(player.salary)}/mês',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${player.age} anos • ${player.primaryPosition.label} • contrato até ${player.contract.endSeason}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.muted, fontSize: 9.8),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Expanded(
                          child: DashboardStatusPill(
                            label: status.shortLabel,
                            color: color,
                            icon: status.icon,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            loanedOut
                                ? 'Emprestado para ${loanedTo ?? 'outro clube'}'
                                : 'Pede ${compactMoney(ContractEngine.expectedSalary(player))}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Renovar contrato',
                visualDensity: VisualDensity.compact,
                onPressed: onRenew,
                icon: Icon(Icons.edit_note_rounded, color: color),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewCount extends StatelessWidget {
  const _OverviewCount({
    required this.value,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final int value;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Column(
              children: [
                Text(
                  '$value',
                  style: TextStyle(
                    color: color,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.muted, fontSize: 9.5),
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.muted, size: 13),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}

class _MoneyMetric extends StatelessWidget {
  const _MoneyMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 9.5)),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      );
}
