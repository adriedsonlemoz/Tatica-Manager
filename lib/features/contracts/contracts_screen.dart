import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/widgets/common.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/player/player.dart';
import '../../game/contract/contract_engine.dart';
import '../../game/contract/contract_lifecycle_engine.dart';
import '../player/player_market_dialogs.dart';
import '../player/player_profile_screen.dart';
import 'contracts_components.dart';

class ContractsScreen extends ConsumerStatefulWidget {
  const ContractsScreen({super.key});

  @override
  ConsumerState<ContractsScreen> createState() => _ContractsScreenState();
}

class _ContractsScreenState extends ConsumerState<ContractsScreen> {
  ContractListFilter filter = ContractListFilter.all;

  @override
  Widget build(BuildContext context) {
    final career = ref.watch(gameControllerProvider).career!;
    final players = [...career.userClub.squad]
      ..sort((a, b) => a.contract.endSeason.compareTo(b.contract.endSeason));
    final statuses = {
      for (final player in players)
        player.id: _statusFor(player, career.season),
    };
    final risk = statuses.values.where((status) => status == ContractVisualStatus.risk).length;
    final attention = statuses.values.where((status) => status == ContractVisualStatus.attention).length;
    final safe = statuses.values.where((status) => status == ContractVisualStatus.safe).length;
    final squadValue = players.fold<int>(0, (sum, player) => sum + player.marketValue);
    final visible = players.where((player) {
      final status = statuses[player.id]!;
      return switch (filter) {
        ContractListFilter.all => true,
        ContractListFilter.risk => status == ContractVisualStatus.risk,
        ContractListFilter.attention => status == ContractVisualStatus.attention,
        ContractListFilter.safe => status == ContractVisualStatus.safe,
      };
    }).toList(growable: false);

    return PremiumScaffold(
      safeBottom: true,
      appBar: GameTopBar(
        title: 'Contratos',
        subtitle: 'Temporada ${career.season}',
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
        children: [
          ContractsOverviewCard(
            total: players.length,
            risk: risk,
            attention: attention,
            safe: safe,
            payroll: career.userClub.payroll,
            squadValue: squadValue,
            onStatusSelected: (value) => setState(() => filter = value),
          ),
          const SizedBox(height: 10),
          ContractFilterBar(
            selected: filter,
            onSelected: (value) => setState(() => filter = value),
            counts: {
              ContractListFilter.all: players.length,
              ContractListFilter.risk: risk,
              ContractListFilter.attention: attention,
              ContractListFilter.safe: safe,
            },
          ),
          const SizedBox(height: 10),
          if (visible.isEmpty)
             SectionCard(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Center(
                  child: Text(
                    'Nenhum contrato neste filtro.',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ),
              ),
            )
          else
            ...visible.map(
              (player) => ContractPlayerCard(
                player: player,
                status: statuses[player.id]!,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PlayerProfileScreen(playerId: player.id),
                  ),
                ),
                onRenew: () => showRenewPlayerDialog(
                  context,
                  ref,
                  player,
                  ContractEngine.expectedSalary(player),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static ContractVisualStatus _statusFor(Player player, int season) {
    if (ContractLifecycleEngine.expiresThisSeason(player, season)) {
      return ContractVisualStatus.risk;
    }
    if (ContractLifecycleEngine.expiresNextSeason(player, season)) {
      return ContractVisualStatus.attention;
    }
    return ContractVisualStatus.safe;
  }
}
