import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/widgets/common.dart';
import '../../app/widgets/player_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../game/contract/contract_engine.dart';
import '../../game/contract/contract_lifecycle_engine.dart';
import '../player/player_profile_screen.dart';
import '../player/player_market_dialogs.dart';

class ContractsScreen extends ConsumerWidget {
  const ContractsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final career = ref.watch(gameControllerProvider).career!;
    final players = [...career.userClub.squad]
      ..sort((a, b) => a.contract.endSeason.compareTo(b.contract.endSeason));
    final risk = players
        .where(
          (player) =>
              ContractLifecycleEngine.expiresThisSeason(player, career.season),
        )
        .length;
    final attention = players
        .where(
          (player) =>
              ContractLifecycleEngine.expiresNextSeason(player, career.season),
        )
        .length;

    return PremiumScaffold(
      appBar: GameTopBar(
        title: 'Contratos',
        subtitle: 'Temporada ${career.season}',
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
        children: [
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.description_rounded,
                      color: AppColors.green,
                      size: 34,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${risk + attention} contratos exigem atenção',
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          Text(
                            'Folha atual: ${formatMoney(career.userClub.payroll)}/mês',
                            style: TextStyle(color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (risk > 0 || attention > 0) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (risk > 0)
                        _ContractCountBadge(
                          label: '$risk com risco de saída',
                          color: AppColors.danger,
                        ),
                      if (attention > 0)
                        _ContractCountBadge(
                          label: '$attention para renovar em breve',
                          color: AppColors.warning,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          ...players.map((player) {
            final riskOfLeaving = ContractLifecycleEngine.expiresThisSeason(
              player,
              career.season,
            );
            final renewSoon = ContractLifecycleEngine.expiresNextSeason(
              player,
              career.season,
            );
            final color = riskOfLeaving
                ? AppColors.danger
                : renewSoon
                    ? AppColors.warning
                    : AppColors.muted;
            final status = riskOfLeaving
                ? 'RISCO DE SAÍDA'
                : renewSoon
                    ? 'RENOVAR EM BREVE'
                    : 'CONTRATO ATIVO';

            return SectionCard(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PlayerProfileScreen(playerId: player.id),
                  ),
                ),
                child: Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        PlayerAvatar(player: player, size: 48),
                        Positioned(
                          right: -5,
                          bottom: -4,
                          child: OverallShield(
                            value: player.overall,
                            compact: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            player.displayName,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${formatMoney(player.salary)}/mês • até ${player.contract.endSeason}',
                            style: TextStyle(color: color, fontSize: 11),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: .12),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: color.withValues(alpha: .35),
                              ),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: color,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Pede ${compactMoney(ContractEngine.expectedSalary(player))}',
                          style: const TextStyle(
                            fontSize: 9.5,
                            color: AppColors.green,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Renovar contrato',
                          visualDensity: VisualDensity.compact,
                          onPressed: () => showRenewPlayerDialog(
                            context,
                            ref,
                            player,
                            ContractEngine.expectedSalary(player),
                          ),
                          icon: const Icon(Icons.edit_document, size: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ContractCountBadge extends StatelessWidget {
  const _ContractCountBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: .35)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
}
