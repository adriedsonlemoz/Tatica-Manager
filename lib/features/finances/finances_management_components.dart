import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/finance/club_administration.dart';
import '../../domain/finance/finance.dart';
import '../../domain/finance/sponsorship.dart';
import '../../domain/season/career_state.dart';
import '../../game/finance/club_administration_engine.dart';

class DepartmentBudgetSection extends StatelessWidget {
  const DepartmentBudgetSection({
    super.key,
    required this.career,
    required this.onEdit,
  });

  final CareerState career;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final plan = career.clubAdministration.budgetPlan;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'ORÇAMENTOS DEPARTAMENTAIS',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            TextButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.tune_rounded, size: 17),
              label: const Text('Distribuir'),
            ),
          ],
        ),
        const Text(
          'Valores disponíveis e gastos registrados na temporada.',
          style: TextStyle(color: AppColors.muted, fontSize: 10.5),
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.7,
          children: ClubDepartment.values.map((department) {
            final available = department == ClubDepartment.transfers
                ? career.userClub.transferBudget
                : plan.forDepartment(department);
            final spent = ClubAdministrationEngine.spentFor(career, department);
            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    department.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    compactMoney(available),
                    style: const TextStyle(
                      color: AppColors.green,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Utilizado: ${compactMoney(spent)}',
                    style: const TextStyle(fontSize: 9.5),
                  ),
                ],
              ),
            );
          }).toList(growable: false),
        ),
      ],
    );
  }
}

class SponsorshipManagementSection extends StatelessWidget {
  const SponsorshipManagementSection({
    super.key,
    required this.contracts,
    required this.proposals,
    required this.onProposal,
  });

  final List<SponsorshipContract> contracts;
  final List<SponsorshipProposal> proposals;
  final ValueChanged<SponsorshipProposal> onProposal;

  @override
  Widget build(BuildContext context) {
    final open = proposals.where((proposal) => proposal.canRespond).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PROPOSTAS RECEBIDAS (${open.length})',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 7),
        if (open.isEmpty)
          const _FinanceInsetPanel(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Nenhuma proposta comercial aguarda decisão.',
                style: TextStyle(color: AppColors.muted),
              ),
            ),
          )
        else
          _FinanceInsetPanel(
            child: Column(
              children: open
                  .map(
                    (proposal) => ListTile(
                      dense: true,
                      leading: const Icon(
                        Icons.mark_email_unread_rounded,
                        color: AppColors.warning,
                      ),
                      title: Text(
                        proposal.sponsorName,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(
                        '${proposal.type.label} • ${proposal.status.label}',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => onProposal(proposal),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        const SizedBox(height: 12),
        Text(
          'CONTRATOS ATIVOS (${contracts.length})',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 7),
        if (contracts.isEmpty)
          const _FinanceInsetPanel(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Sem contratos ativos. Analise as propostas antes que expirem.',
                style: TextStyle(color: AppColors.muted),
              ),
            ),
          )
        else
          _FinanceInsetPanel(
            child: Column(
              children: contracts
                  .map(
                    (contract) => ListTile(
                      dense: true,
                      leading: const Icon(
                        Icons.handshake_rounded,
                        color: AppColors.green,
                      ),
                      title: Text(
                        contract.sponsorName,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(
                        '${contract.type.label} • ${contract.startSeason}–${contract.endSeason}',
                      ),
                      trailing: Text(
                        compactMoney(contract.annualValue),
                        style: const TextStyle(
                          color: AppColors.green,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      onTap: () => showSponsorshipContractDialog(
                        context,
                        contract,
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

class _FinanceInsetPanel extends StatelessWidget {
  const _FinanceInsetPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Material(
        color: AppColors.surfaceRaised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      );
}

enum SponsorshipDecisionType { accept, reject, counter }

class SponsorshipDecision {
  const SponsorshipDecision(this.type, {this.requestedAnnualValue});

  final SponsorshipDecisionType type;
  final int? requestedAnnualValue;
}

Future<Map<ClubDepartment, int>?> showBudgetAllocationDialog(
  BuildContext context,
  CareerState career,
) async {
  final values = {
    for (final department in ClubDepartment.values)
      department: department == ClubDepartment.transfers
          ? career.userClub.transferBudget
          : career.clubAdministration.budgetPlan.forDepartment(department),
  };
  final controllers = {
    for (final department in ClubDepartment.values)
      department: TextEditingController(text: '${values[department]}'),
  };
  final result = await showDialog<Map<ClubDepartment, int>>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Distribuir orçamentos'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Saldo máximo para distribuição: ${formatMoney(career.userClub.money)}',
                style: const TextStyle(color: AppColors.muted, fontSize: 11),
              ),
              const SizedBox(height: 12),
              for (final department in ClubDepartment.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: controllers[department],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: department.label,
                      prefixText: 'R\$ ',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            final allocation = {
              for (final department in ClubDepartment.values)
                department: int.tryParse(
                      controllers[department]!
                          .text
                          .replaceAll(RegExp(r'[^0-9]'), ''),
                    ) ??
                    0,
            };
            Navigator.of(dialogContext).pop(allocation);
          },
          child: const Text('Salvar distribuição'),
        ),
      ],
    ),
  );
  for (final controller in controllers.values) {
    controller.dispose();
  }
  return result;
}

Future<SponsorshipDecision?> showSponsorshipProposalDialog(
  BuildContext context,
  SponsorshipProposal proposal,
) =>
    showDialog<SponsorshipDecision>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(proposal.sponsorName),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailLine(label: 'Tipo', value: proposal.type.label),
              _DetailLine(
                label: 'Valor',
                value: '${formatMoney(proposal.currentAnnualValue)} por temporada',
              ),
              _DetailLine(
                label: 'Duração',
                value: '${proposal.durationSeasons} temporada(s)',
              ),
              _DetailLine(
                label: 'Bônus',
                value: formatMoney(proposal.performanceBonus),
              ),
              _DetailLine(label: 'Objetivo', value: proposal.objective),
              _DetailLine(label: 'Condições', value: proposal.conditions),
              _DetailLine(
                label: 'Prazo',
                value: fullDate(proposal.expiresAt),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(
              const SponsorshipDecision(SponsorshipDecisionType.reject),
            ),
            child: const Text('Recusar'),
          ),
          OutlinedButton(
            onPressed: () => Navigator.of(dialogContext).pop(
              SponsorshipDecision(
                SponsorshipDecisionType.counter,
                requestedAnnualValue:
                    (proposal.currentAnnualValue * 1.10).round(),
              ),
            ),
            child: const Text('Negociar +10%'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(
              const SponsorshipDecision(SponsorshipDecisionType.accept),
            ),
            child: const Text('Aceitar'),
          ),
        ],
      ),
    );

Future<void> showSponsorshipContractDialog(
  BuildContext context,
  SponsorshipContract contract,
) =>
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(contract.sponsorName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailLine(label: 'Contrato', value: contract.type.label),
            _DetailLine(
              label: 'Valor anual',
              value: formatMoney(contract.annualValue),
            ),
            _DetailLine(
              label: 'Duração',
              value: '${contract.startSeason}–${contract.endSeason}',
            ),
            _DetailLine(
              label: 'Bônus por objetivo',
              value: formatMoney(contract.performanceBonus),
            ),
            const _DetailLine(
              label: 'Pagamento',
              value: 'Distribuído pelas rodadas da temporada.',
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );

Future<void> showFinanceTransactionDialog(
  BuildContext context,
  FinanceTransaction transaction,
) =>
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Detalhes da movimentação'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailLine(label: 'Origem', value: transaction.kind.label),
            _DetailLine(
              label: 'Valor',
              value: formatMoney(transaction.amount),
            ),
            _DetailLine(label: 'Data', value: fullDate(transaction.createdAt)),
            _DetailLine(
              label: 'Categoria',
              value: transaction.kind.category.label,
            ),
            _DetailLine(label: 'Descrição', value: transaction.description),
            _DetailLine(
              label: 'Impacto financeiro',
              value: transaction.isIncome
                  ? 'Entrada no caixa do clube'
                  : 'Saída do caixa do clube',
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: AppColors.muted, fontSize: 10),
            ),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      );
}
