import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/club/club.dart';
import '../../domain/finance/club_administration.dart';
import '../../game/finance/club_administration_engine.dart';
import '../../game/stadium/stadium_engine.dart';
import 'stadium_components.dart';

class _StadiumProfileInput {
  const _StadiumProfileInput({required this.name, required this.ticketPrice});

  final String name;
  final int ticketPrice;
}

Future<void> showEditStadiumDialog(
  BuildContext context,
  WidgetRef ref,
) async {
  final stadium = ref.read(gameControllerProvider).career!.userClub.stadium;
  final nameController = TextEditingController(text: stadium.originalName);
  final ticketController = TextEditingController(text: '${stadium.ticketPrice}');
  final input = await showDialog<_StadiumProfileInput>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Editar estádio'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            maxLength: 48,
            decoration: const InputDecoration(labelText: 'Nome original'),
          ),
          TextField(
            controller: ticketController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Valor do ingresso',
              prefixText: 'R\$ ',
              helperText: 'O preço altera a procura e a lotação.',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(
            _StadiumProfileInput(
              name: nameController.text,
              ticketPrice: int.tryParse(
                    ticketController.text.replaceAll(RegExp(r'[^0-9]'), ''),
                  ) ??
                  0,
            ),
          ),
          child: const Text('Salvar'),
        ),
      ],
    ),
  );
  nameController.dispose();
  ticketController.dispose();
  if (input == null) return;
  try {
    final result = ClubAdministrationEngine.updateStadiumProfile(
      ref.read(gameControllerProvider).career!,
      name: input.name,
      ticketPrice: input.ticketPrice,
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

Future<void> showStadiumUpgradeDialog(
  BuildContext context,
  WidgetRef ref,
  StadiumFacility facility, {
  required bool negotiated,
}) async {
  final career = ref.read(gameControllerProvider).career!;
  final club = career.userClub;
  final kind = StadiumEngine.projectKindForFacility(facility);
  if (StadiumEngine.hasActiveProject(club.stadium, kind)) {
    ref.read(gameControllerProvider.notifier).showMessage(
          'Já existe uma obra de ${facility.label} em andamento.',
        );
    return;
  }
  final cost = negotiated
      ? StadiumEngine.negotiatedUpgradeCost(club: club, facility: facility)
      : StadiumEngine.upgradeCost(club.stadium, facility);
  final available = career.clubAdministration.budgetPlan
      .forDepartment(ClubDepartment.stadium);
  final duration = StadiumEngine.projectDurationDays(kind);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(
        StadiumEngine.isLocked(club.stadium, facility)
            ? 'Desbloquear ${facility.label}'
            : 'Melhorar ${facility.label}',
      ),
      content: Text(
        '${facility.description}\n\n'
        'Custo${negotiated ? ' negociado' : ''}: ${formatMoney(cost)}\n'
        'Tempo de construção: $duration dias\n'
        'Orçamento do estádio: ${formatMoney(available)}\n\n'
        'A melhoria só entra em funcionamento quando a obra terminar.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: cost > 0 && cost <= available && cost <= club.money
              ? () => Navigator.of(dialogContext).pop(true)
              : null,
          child: Text(negotiated ? 'Aceitar e iniciar' : 'Iniciar obra'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  try {
    final result = ClubAdministrationEngine.upgradeStadium(
      ref.read(gameControllerProvider).career!,
      facility,
      negotiated: negotiated,
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

Future<void> showStadiumMaintenanceDialog(
  BuildContext context,
  WidgetRef ref,
) async {
  final career = ref.read(gameControllerProvider).career!;
  final stadium = career.userClub.stadium;
  final cost = StadiumEngine.maintenanceCost(stadium);
  final available = career.clubAdministration.budgetPlan
      .forDepartment(ClubDepartment.stadium);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Manutenção do estádio'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ConditionDialogLine(label: 'Gramado', value: stadium.pitchCondition),
          _ConditionDialogLine(label: 'Estrutura', value: stadium.structureCondition),
          _ConditionDialogLine(label: 'Segurança', value: stadium.securityCondition),
          _ConditionDialogLine(label: 'Conforto', value: stadium.comfortCondition),
          const SizedBox(height: 12),
          Text('Custo da manutenção: ${formatMoney(cost)}'),
          Text('Orçamento do estádio: ${formatMoney(available)}'),
          const SizedBox(height: 8),
          const Text(
            'A manutenção restaura as quatro condições para 100%.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Fechar'),
        ),
        FilledButton(
          onPressed: cost <= available && cost <= career.userClub.money
              ? () => Navigator.of(dialogContext).pop(true)
              : null,
          child: const Text('Realizar manutenção'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  try {
    final result = ClubAdministrationEngine.performStadiumMaintenance(
      ref.read(gameControllerProvider).career!,
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

Future<void> showTrainingCenterDialog(
  BuildContext context,
  WidgetRef ref,
) async {
  final career = ref.read(gameControllerProvider).career!;
  final stadium = career.userClub.stadium;
  final active = stadium.projects.where(
    (project) =>
        project.kind == StadiumProjectKind.trainingCenter && project.isActive,
  );
  final cost = StadiumEngine.trainingCenterUpgradeCost(stadium);
  final duration = StadiumEngine.projectDurationDays(
    StadiumProjectKind.trainingCenter,
  );
  final available = career.clubAdministration.budgetPlan
      .forDepartment(ClubDepartment.stadium);
  final canUpgrade = active.isEmpty &&
      cost > 0 &&
      cost <= available &&
      cost <= career.userClub.money;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Centro de treinamento'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nível atual: ${stadium.trainingCenterLevel}/${StadiumEngine.maxFacilityLevel}'),
          Text('Qualidade: ${StadiumEngine.trainingCenterQuality(stadium)}%'),
          const SizedBox(height: 10),
          if (active.isNotEmpty) ...[
            Text(
              'Obra em andamento: ${active.first.daysRemaining(career.currentDate)} dias restantes.',
              style: const TextStyle(color: AppColors.warning),
            ),
          ] else if (cost > 0) ...[
            Text('Próxima melhoria: ${formatMoney(cost)}'),
            Text('Tempo de construção: $duration dias'),
            Text('Orçamento do estádio: ${formatMoney(available)}'),
          ] else
            const Text('O centro de treinamento já está no nível máximo.'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Fechar'),
        ),
        if (cost > 0 && active.isEmpty)
          FilledButton(
            onPressed: canUpgrade ? () => Navigator.of(dialogContext).pop(true) : null,
            child: const Text('Iniciar melhoria'),
          ),
      ],
    ),
  );
  if (confirmed != true) return;
  try {
    final result = ClubAdministrationEngine.upgradeTrainingCenter(
      ref.read(gameControllerProvider).career!,
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

Future<void> showStadiumProjectsSheet(
  BuildContext context,
  WidgetRef ref,
) async {
  final career = ref.read(gameControllerProvider).career!;
  final club = career.userClub;
  final available = career.clubAdministration.budgetPlan
      .forDepartment(ClubDepartment.stadium);
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    builder: (sheetContext) => SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: .78,
        minChildSize: .55,
        maxChildSize: .94,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
          children: [
            const Text(
              'Melhorias do estádio',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            const Text(
              'As obras têm prazo e só aplicam a melhoria quando concluídas.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
            const SizedBox(height: 14),
            if (club.stadium.projects.isNotEmpty) ...[
              const Text(
                'OBRAS REGISTRADAS',
                style: TextStyle(color: AppColors.green, fontSize: 11, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              ...club.stadium.projects.reversed.take(5).map(
                    (project) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        project.isActive ? Icons.schedule_rounded : Icons.check_circle_rounded,
                        color: project.isActive ? AppColors.warning : AppColors.green,
                      ),
                      title: Text(project.kind.label),
                      subtitle: Text(
                        project.isActive
                            ? '${project.daysRemaining(career.currentDate)} dias restantes'
                            : 'Concluída',
                      ),
                      trailing: Text(
                        compactMoney(project.cost),
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                      ),
                    ),
                  ),
              const SizedBox(height: 12),
            ],
            const Text(
              'INFRAESTRUTURA',
              style: TextStyle(color: AppColors.green, fontSize: 11, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            StadiumFacilityGrid(
              club: club,
              availableFunds: available,
              onUpgrade: (facility, negotiated) {
                Navigator.of(sheetContext).pop();
                showStadiumUpgradeDialog(
                  context,
                  ref,
                  facility,
                  negotiated: negotiated,
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}

void showStadiumRevenueDetails(
  BuildContext context, {
  required int monthRevenue,
  required int seasonRevenue,
  required StadiumMatchdayRevenue projection,
}) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Receita de bilheteria'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Este mês: ${formatMoney(monthRevenue)}'),
          Text('Na temporada: ${formatMoney(seasonRevenue)}'),
          const SizedBox(height: 10),
          Text('Próximo jogo — bilheteria projetada: ${formatMoney(projection.ticketing)}'),
          Text('Público projetado: ${projection.attendance}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Fechar'),
        ),
      ],
    ),
  );
}

class _ConditionDialogLine extends StatelessWidget {
  const _ConditionDialogLine({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Expanded(child: Text(label)),
            Text(
              '$value%',
              style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      );
}
