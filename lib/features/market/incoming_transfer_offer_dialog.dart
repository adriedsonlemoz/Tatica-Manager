import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/state/transfer_controller.dart';
import '../../app/widgets/player_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../game/cpu/cpu_user_offer_engine.dart';

Future<bool?> showIncomingTransferOfferDialog(
  BuildContext context,
  WidgetRef ref, {
  required String eventId,
}) async {
  var preview = ref.read(transferControllerProvider).previewIncomingOffer(eventId);
  var currentFee = preview.offer?.fee ?? 0;
  var counterFee = currentFee > 0 ? (currentFee * 1.10).round() : 0;
  var sending = false;
  var resolved = false;
  var sold = false;
  String? feedback;

  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) {
        final career = ref.read(gameControllerProvider).career;
        final offer = preview.offer;
        final sourceEvent = career?.news
            .where((event) => event.id == eventId)
            .firstOrNull;
        final isFinalCounter = sourceEvent != null &&
            CpuUserOfferEngine.isFinalCounterOffer(sourceEvent);
        final player = career?.userClub.squad
            .where((item) => item.id == offer?.playerId)
            .firstOrNull;
        final minimumIncrease = currentFee > 0
            ? (currentFee * .01).round().clamp(1, currentFee).toInt()
            : 1;
        final minimumCounter = currentFee > 0
            ? currentFee + minimumIncrease
            : 1;
        final scaledMax = (currentFee * 1.50).round();
        final sliderMax =
            scaledMax > minimumCounter ? scaledMax : minimumCounter;
        if (counterFee < minimumCounter) counterFee = minimumCounter;
        if (counterFee > sliderMax) counterFee = sliderMax;

        return Dialog(
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
                      if (player != null)
                        PlayerAvatar(
                          player: player,
                          size: 46,
                          accentColor: career == null
                              ? AppColors.green
                              : Color(career.userClub.colors.primaryHex),
                        )
                      else
                        const Icon(
                          Icons.swap_horiz_rounded,
                          color: AppColors.green,
                        ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sold
                                  ? 'Transferência concluída'
                                  : resolved
                                      ? 'Negociação encerrada'
                                      : 'Proposta recebida',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            Text(
                              player?.displayName ?? 'Jogador',
                              style: TextStyle(color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(dialogContext).pop(sold),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (!preview.available || offer == null || player == null)
                    _OfferFeedback(text: preview.message, success: false)
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
                            formatMoney(currentFee),
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
                    const SizedBox(height: 14),
                    if (isFinalCounter)
                      const _OfferFeedback(
                        text: 'O clube informou que este é o valor final da negociação.',
                        success: false,
                      )
                    else ...[
                      Text(
                        'CONTRAPROPOSTA',
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatMoney(counterFee),
                        style: const TextStyle(
                          color: AppColors.green,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Slider(
                        value: counterFee.toDouble(),
                        min: minimumCounter.toDouble(),
                        max: sliderMax.toDouble(),
                        divisions: 10,
                        label: formatMoney(counterFee),
                        onChanged: sending || resolved
                            ? null
                            : (value) => setState(
                                  () => counterFee = value.round(),
                                ),
                      ),
                      Text(
                        'A CPU pode aceitar, apresentar o limite financeiro do clube ou encerrar a negociação.',
                        style: TextStyle(color: AppColors.muted, height: 1.4),
                      ),
                    ],
                  ],
                  if (feedback != null) ...[
                    const SizedBox(height: 12),
                    _OfferFeedback(text: feedback!, success: sold),
                  ],
                  const SizedBox(height: 16),
                  if (resolved || sold || !preview.available || offer == null)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.of(dialogContext).pop(sold),
                        child: const Text('Concluir'),
                      ),
                    )
                  else ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: sending
                                ? null
                                : () async {
                                    setState(() => sending = true);
                                    final result = await ref
                                        .read(transferControllerProvider)
                                        .rejectIncomingOffer(eventId);
                                    if (!dialogContext.mounted) return;
                                    setState(() {
                                      sending = false;
                                      feedback = result.message;
                                      resolved = result.accepted;
                                    });
                                  },
                            child: const Text('Recusar'),
                          ),
                        ),
                        if (!isFinalCounter) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: sending
                                  ? null
                                  : () async {
                                      setState(() => sending = true);
                                      final result = await ref
                                          .read(transferControllerProvider)
                                          .counterIncomingOffer(
                                            eventId: eventId,
                                            fee: counterFee,
                                          );
                                      if (!dialogContext.mounted) return;
                                      setState(() {
                                        sending = false;
                                        feedback = result.message;
                                        sold = result.accepted;
                                        if (result.counterOffer != null) {
                                          currentFee = result.counterOffer!;
                                          counterFee =
                                              (currentFee * 1.10).round();
                                          preview = ref
                                              .read(transferControllerProvider)
                                              .previewIncomingOffer(eventId);
                                        } else if (!result.accepted) {
                                          resolved = !ref
                                              .read(transferControllerProvider)
                                              .previewIncomingOffer(eventId)
                                              .available;
                                        }
                                      });
                                    },
                              child: const Text('Contrapropor'),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: sending
                            ? null
                            : () async {
                                setState(() => sending = true);
                                final result = await ref
                                    .read(transferControllerProvider)
                                    .acceptIncomingOffer(eventId);
                                if (!dialogContext.mounted) return;
                                setState(() {
                                  sending = false;
                                  feedback = result.message;
                                  sold = result.accepted;
                                  resolved = result.accepted;
                                });
                              },
                        icon: const Icon(Icons.check_rounded),
                        label: Text(
                          sending ? 'Processando...' : 'Aceitar oferta',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

class _OfferFeedback extends StatelessWidget {
  const _OfferFeedback({required this.text, required this.success});

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

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
