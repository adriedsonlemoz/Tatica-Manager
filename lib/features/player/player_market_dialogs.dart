import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/transfer_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/player/player.dart';

Future<void> showRenewPlayerDialog(
  BuildContext context,
  WidgetRef ref,
  Player player,
  int expected,
) async {
  var salary = expected.toDouble();
  var years = 2;
  var sending = false;
  var completed = false;
  String? feedback;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.description_rounded, color: AppColors.green),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            completed ? 'Renovação concluída' : 'Renovar contrato',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          Text(
                            player.displayName,
                            style: TextStyle(color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _MiniValue(
                          label: 'Salário atual',
                          value: formatMoney(player.salary),
                        ),
                      ),
                      Expanded(
                        child: _MiniValue(
                          label: 'Expectativa',
                          value: formatMoney(expected),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!completed) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Salário proposto: ${formatMoney(salary.round())}/mês',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 9),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      for (final option in const [
                        (-.10, '-10%'),
                        (0.0, 'Valor pedido'),
                        (.10, '+10%'),
                        (.20, '+20%'),
                      ])
                        ChoiceChip(
                          label: Text(option.$2),
                          selected:
                              salary.round() == (expected * (1 + option.$1)).round(),
                          onSelected: sending
                              ? null
                              : (_) => setState(() {
                                    salary =
                                        (expected * (1 + option.$1)).roundToDouble();
                                    feedback = null;
                                  }),
                        ),
                    ],
                  ),
                  Slider(
                    value: salary,
                    min: (expected * .75).toDouble(),
                    max: (expected * 1.5).toDouble(),
                    divisions: 20,
                    onChanged: sending
                        ? null
                        : (value) => setState(() {
                              salary = value;
                              feedback = null;
                            }),
                  ),
                  Text(
                    'Duração: $years ano(s)',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  Slider(
                    value: years.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    onChanged: sending
                        ? null
                        : (value) => setState(() {
                              years = value.round();
                              feedback = null;
                            }),
                  ),
                  Text(
                    'Luvas estimadas: ${formatMoney(salary.round() * 2)}',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ],
                if (feedback != null) ...[
                  const SizedBox(height: 14),
                  _DialogFeedback(text: feedback!, success: completed),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: completed
                        ? () => Navigator.of(dialogContext).pop()
                        : sending
                            ? null
                            : () async {
                                setState(() => sending = true);
                                final result = await ref
                                    .read(transferControllerProvider)
                                    .renewPlayer(
                                      playerId: player.id,
                                      salary: salary.round(),
                                      years: years,
                                    );
                                if (!dialogContext.mounted) return;
                                setState(() {
                                  sending = false;
                                  feedback = result.message;
                                  if (result.counterOffer != null) {
                                    salary = result.counterOffer!.toDouble();
                                  }
                                  completed = result.accepted;
                                });
                              },
                    icon: Icon(completed ? Icons.check_rounded : Icons.send_rounded),
                    label: Text(
                      completed
                          ? 'Concluir'
                          : sending
                              ? 'Enviando...'
                              : 'Enviar proposta',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Future<bool?> showPlayerSaleDialog(
  BuildContext context,
  WidgetRef ref,
  Player player,
) async {
  final preview = ref.read(transferControllerProvider).previewSale(player.id);
  var sending = false;
  var completed = false;
  String? feedback;

  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) {
        final offer = preview.offer;
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.sell_rounded, color: AppColors.green),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              completed ? 'Venda concluída' : 'Proposta de venda',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            Text(
                              player.displayName,
                              style: TextStyle(color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(dialogContext).pop(completed),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (!preview.available || offer == null)
                    _DialogFeedback(text: preview.message, success: false)
                  else ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.green.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.green.withValues(alpha: .35),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offer.buyerClubName,
                            style: const TextStyle(
                              color: AppColors.green,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            formatMoney(offer.fee),
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Valor de mercado: ${formatMoney(player.marketValue)}',
                            style: TextStyle(color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Ao aceitar, o valor entra no saldo e no orçamento de transferências. Se o jogador estiver entre os titulares, a escalação será reorganizada automaticamente.',
                      style: TextStyle(color: AppColors.muted, height: 1.4),
                    ),
                  ],
                  if (feedback != null) ...[
                    const SizedBox(height: 12),
                    _DialogFeedback(text: feedback!, success: completed),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (!completed) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: sending
                                ? null
                                : () => Navigator.of(dialogContext).pop(false),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: completed
                              ? () => Navigator.of(dialogContext).pop(true)
                              : !preview.available || offer == null || sending
                                  ? null
                                  : () async {
                                      setState(() => sending = true);
                                      final result = await ref
                                          .read(transferControllerProvider)
                                          .acceptSaleOffer(offer);
                                      if (!dialogContext.mounted) return;
                                      setState(() {
                                        sending = false;
                                        feedback = result.message;
                                        completed = result.accepted;
                                      });
                                    },
                          icon: Icon(
                            completed ? Icons.check_rounded : Icons.sell_outlined,
                          ),
                          label: Text(
                            completed
                                ? 'Concluir'
                                : sending
                                    ? 'Processando...'
                                    : 'Aceitar oferta',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

class _MiniValue extends StatelessWidget {
  const _MiniValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: AppColors.muted, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      );
}

class _DialogFeedback extends StatelessWidget {
  const _DialogFeedback({required this.text, required this.success});

  final String text;
  final bool success;

  @override
  Widget build(BuildContext context) {
    final color = success ? AppColors.green : AppColors.warning;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: color.withValues(alpha: .35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            success ? Icons.check_circle_rounded : Icons.info_outline_rounded,
            color: color,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
