import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/widgets/common.dart';
import '../../app/widgets/management_dashboard_widgets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/finance/club_administration.dart';
import '../../domain/finance/sponsorship.dart';
import '../../game/stadium/stadium_engine.dart';
import 'stadium_actions.dart';
import 'stadium_components.dart';
import 'stadium_scene.dart';

class StadiumScreen extends ConsumerWidget {
  const StadiumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final career = ref.watch(gameControllerProvider).career!;
    final club = career.userClub;
    final stadium = club.stadium;
    final tablePosition = career.standings.indexWhere((standing) => standing.clubId == club.id) + 1;
    final projection = StadiumEngine.settleMatchday(
      club: club,
      tablePosition: tablePosition <= 0 ? 10 : tablePosition,
    );
    final occupancy = stadium.capacity <= 0
        ? 0
        : (projection.attendance * 100 / stadium.capacity).round();
    final stadiumBudget = career.clubAdministration.budgetPlan.forDepartment(ClubDepartment.stadium);
    final availableForWorks = math.max(0, math.min(stadiumBudget, club.money));
    final namingContracts = club.sponsorships
        .where(
          (contract) => contract.type == SponsorshipType.stadium && contract.isActiveIn(career.season),
        )
        .toList(growable: false);
    final namingRights = namingContracts.isEmpty ? null : namingContracts.first;
    final supporterImpact = StadiumEngine.supporterImpact(
      club: club,
      attendance: projection.attendance,
    );

    return PremiumScaffold(
      safeBottom: true,
      appBar: GameTopBar(
        title: 'Estádio',
        subtitle: stadium.name,
        actions: [
          IconButton(
            tooltip: 'Editar informações',
            onPressed: () => showEditStadiumDialog(context, ref),
            icon: const Icon(Icons.edit_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
        children: [
          StadiumSceneCard(
            club: club,
            occupancy: occupancy,
            namingSponsor: namingRights?.sponsorName,
          ),
          const SizedBox(height: 10),
          StadiumSummaryGrid(
            club: club,
            projection: projection,
            occupancy: occupancy,
            supporterImpact: supporterImpact,
          ),
          const SizedBox(height: 10),
          StadiumRevenueCard(projection: projection),
          const SizedBox(height: 10),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DashboardSectionHeader(
                  title: 'Administração',
                  subtitle: 'Orçamento reservado; obras também respeitam o caixa atual',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const DashboardIconBadge(icon: Icons.account_balance_wallet_outlined),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text('Orçamento do estádio', style: TextStyle(color: AppColors.muted, fontSize: 10)),
                          Text(
                            formatMoney(stadiumBudget),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                    DashboardStatusPill(
                      label: 'Arquibancadas ${stadium.standsLevel}/${StadiumEngine.maxFacilityLevel}',
                      color: AppColors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  namingRights == null
                      ? 'O nome original do estádio está preservado. Propostas de naming rights continuam em Finanças.'
                      : 'Naming rights ativo com ${namingRights.sponsorName}; o nome original permanece salvo.',
                  style:  TextStyle(color: AppColors.muted, fontSize: 9.8, height: 1.35),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const DashboardSectionHeader(
            title: 'Infraestrutura e melhorias',
            subtitle: 'Estruturas já existentes no sistema do estádio',
          ),
          const SizedBox(height: 8),
          StadiumFacilityGrid(
            club: club,
            projection: projection,
            availableFunds: availableForWorks,
            onUpgrade: (facility, negotiated) => showStadiumUpgradeDialog(
              context,
              ref,
              facility,
              negotiated: negotiated,
            ),
          ),
        ],
      ),
    );
  }
}
