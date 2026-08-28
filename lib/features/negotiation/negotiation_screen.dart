import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/state/transfer_controller.dart';
import '../../app/widgets/common.dart';
import '../../app/widgets/player_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/club/club.dart';
import '../../domain/player/player.dart';
import '../../game/transfer/transfer_engine.dart';

Future<bool?> showNegotiationDialog(
  BuildContext context, {
  required String playerId,
}) =>
    showDialog<bool>(
      context: context,
      builder: (_) => NegotiationDialog(playerId: playerId),
    );

class NegotiationDialog extends ConsumerStatefulWidget {
  const NegotiationDialog({super.key, required this.playerId});

  final String playerId;

  @override
  ConsumerState<NegotiationDialog> createState() => _NegotiationDialogState();
}

class _NegotiationDialogState extends ConsumerState<NegotiationDialog> {
  Player? player;
  Club? seller;
  double fee = 0;
  double salary = 0;
  int years = 2;
  bool sending = false;
  bool completed = false;
  int? counterOffer;
  String? feedback;

  void _initialize() {
    if (player != null) return;
    final career = ref.read(gameControllerProvider).career!;
    for (final club in career.clubs) {
      if (club.id == career.userClubId) continue;
      for (final item in club.squad) {
        if (item.id == widget.playerId) {
          player = item;
          seller = club;
          break;
        }
      }
      if (player != null) break;
    }
    player ??= career.freeAgents.firstWhere((p) => p.id == widget.playerId);

    final buyer = career.userClub;
    final minimumFee = TransferEngine.minimumFee(
      player: player!,
      buyer: buyer,
      seller: seller,
    );
    fee = seller == null
        ? 0
        : max(player!.marketValue, minimumFee).toDouble();
    salary = (player!.salary * 1.05).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    _initialize();
    final currentPlayer = player!;
    final career = ref.watch(gameControllerProvider).career!;
    final buyer = career.userClub;
    final minimumFee = TransferEngine.minimumFee(
      player: currentPlayer,
      buyer: buyer,
      seller: seller,
    );
    final feeMax = seller == null
        ? 0.0
        : max(currentPlayer.marketValue * 1.8, minimumFee * 1.25).toDouble();
    final projectedMoney = max(0, buyer.money - fee.round());
    final projectedBudget = max(0, buyer.transferBudget - fee.round());

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 460,
          maxHeight: MediaQuery.sizeOf(context).height * .86,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DialogHeader(
              icon: Icons.handshake_rounded,
              title: completed ? 'Contratação concluída' : 'Negociar contratação',
              subtitle: currentPlayer.displayName,
              onClose: () => Navigator.of(context).pop(completed),
            ),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        PlayerAvatar(
                          player: currentPlayer,
                          size: 58,
                          accentColor: seller == null
                              ? AppColors.green
                              : Color(seller!.colors.primaryHex),
                        ),
                        const SizedBox(width: 10),
                        OverallShield(value: currentPlayer.overall, compact: true),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentPlayer.displayName,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                              Text(
                                '${currentPlayer.primaryPosition.label} • ${currentPlayer.age} anos • POT ${currentPlayer.potential}',
                                style: TextStyle(color: AppColors.muted),
                              ),
                              Text(
                                seller?.name ?? 'Jogador sem clube',
                                style: const TextStyle(
                                  color: AppColors.green,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (completed) ...[
                      _FeedbackBanner(
                        text: feedback ?? 'Contratação concluída.',
                        success: true,
                      ),
                    ] else ...[
                      _DialogSection(
                        title: seller == null ? 'JOGADOR LIVRE' : 'PROPOSTA AO CLUBE',
                        child: seller == null
                            ? const Text(
                                'Não há taxa de transferência. Ajuste apenas salário e duração do contrato.',
                                style: TextStyle(color: AppColors.green),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Oferta: ${formatMoney(fee.round())}',
                                    style: const TextStyle(fontWeight: FontWeight.w900),
                                  ),
                                  Slider(
                                    value: fee
                                        .clamp(currentPlayer.marketValue * .65, feeMax)
                                        .toDouble(),
                                    min: currentPlayer.marketValue * .65,
                                    max: feeMax,
                                    divisions: 46,
                                    onChanged: sending
                                        ? null
                                        : (value) => setState(() {
                                              fee = value;
                                              counterOffer = null;
                                              feedback = null;
                                            }),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Mercado: ${formatMoney(currentPlayer.marketValue)}',
                                          style: TextStyle(color: AppColors.muted),
                                        ),
                                      ),
                                      Text(
                                        'Mín.: ${formatMoney(minimumFee)}',
                                        style: TextStyle(
                                          color: fee.round() < minimumFee
                                              ? AppColors.warning
                                              : AppColors.green,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (counterOffer != null) ...[
                                    const SizedBox(height: 10),
                                    _CounterOffer(
                                      value: counterOffer!,
                                      onAccept: () => setState(() {
                                        fee = counterOffer!.toDouble();
                                        counterOffer = null;
                                        feedback = null;
                                      }),
                                    ),
                                  ],
                                ],
                              ),
                      ),
                      const SizedBox(height: 10),
                      _DialogSection(
                        title: 'CONTRATO DO JOGADOR',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Salário: ${formatMoney(salary.round())}/mês',
                              style: const TextStyle(fontWeight: FontWeight.w900),
                            ),
                            Slider(
                              value: salary,
                              min: currentPlayer.salary * .75,
                              max: currentPlayer.salary * 1.8,
                              divisions: 32,
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      _DialogSection(
                        title: 'IMPACTO FINANCEIRO',
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Metric(
                                  label: 'Orçamento',
                                  value: formatMoney(buyer.transferBudget),
                                ),
                                const SizedBox(width: 10),
                                Metric(
                                  label: 'Após compra',
                                  value: formatMoney(projectedBudget),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Metric(label: 'Saldo', value: formatMoney(buyer.money)),
                                const SizedBox(width: 10),
                                Metric(
                                  label: 'Saldo após taxa',
                                  value: formatMoney(projectedMoney),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (feedback != null) ...[
                        const SizedBox(height: 10),
                        _FeedbackBanner(text: feedback!, success: false),
                      ],
                    ],
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  if (!completed) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: sending ? null : () => Navigator.of(context).pop(false),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: completed
                          ? () => Navigator.of(context).pop(true)
                          : sending
                              ? null
                              : _send,
                      icon: Icon(completed ? Icons.check_rounded : Icons.send_rounded),
                      label: Text(
                        completed
                            ? 'Concluir'
                            : sending
                                ? 'Negociando...'
                                : 'Enviar proposta',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _send() async {
    setState(() => sending = true);
    final result = await ref.read(transferControllerProvider).buyPlayer(
          playerId: widget.playerId,
          fee: fee.round(),
          salary: salary.round(),
          years: years,
        );
    if (!mounted) return;
    setState(() {
      sending = false;
      feedback = result.message;
      counterOffer = result.counterOffer;
      if (result.counterOffer != null) {
        fee = result.counterOffer!.toDouble();
      }
      completed = result.accepted;
    });
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onClose,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.green),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                  Text(
                    subtitle,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(onPressed: onClose, icon: const Icon(Icons.close_rounded)),
          ],
        ),
      );
}

class _DialogSection extends StatelessWidget {
  const _DialogSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
            const SizedBox(height: 10),
            child,
          ],
        ),
      );
}

class _CounterOffer extends StatelessWidget {
  const _CounterOffer({required this.value, required this.onAccept});

  final int value;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.warning.withValues(alpha: .35)),
        ),
        child: Row(
          children: [
            const Icon(Icons.swap_horiz_rounded, color: AppColors.warning),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Contraproposta: ${formatMoney(value)}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            TextButton(onPressed: onAccept, child: const Text('Usar valor')),
          ],
        ),
      );
}

class _FeedbackBanner extends StatelessWidget {
  const _FeedbackBanner({required this.text, required this.success});

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
          Icon(success ? Icons.check_circle_rounded : Icons.info_outline_rounded, color: color),
          const SizedBox(width: 9),
          Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }
}
