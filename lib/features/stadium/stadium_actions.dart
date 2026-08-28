import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../core/utils/formatters.dart';
import '../../domain/finance/club_administration.dart';
import '../../game/finance/club_administration_engine.dart';
import '../../game/stadium/stadium_engine.dart';

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
  final cost = negotiated
      ? StadiumEngine.negotiatedUpgradeCost(club: club, facility: facility)
      : StadiumEngine.upgradeCost(club.stadium, facility);
  final available = career.clubAdministration.budgetPlan
      .forDepartment(ClubDepartment.stadium);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(
        StadiumEngine.isLocked(club.stadium, facility)
            ? 'Desbloquear ${facility.label}'
            : 'Melhorar ${facility.label}',
      ),
      content: Text(
        '${facility.description}\n\nCusto${negotiated ? ' negociado' : ''}: ${formatMoney(cost)}\nOrçamento do estádio: ${formatMoney(available)}',
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
          child: Text(negotiated ? 'Aceitar negociação' : 'Confirmar obra'),
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
