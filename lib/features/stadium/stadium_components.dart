import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/widgets/common.dart';
import '../../app/widgets/management_dashboard_widgets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/club/club.dart';
import '../../game/stadium/stadium_engine.dart';

class StadiumSummaryGrid extends StatelessWidget {
  const StadiumSummaryGrid({
    super.key,
    required this.club,
    required this.projection,
    required this.occupancy,
    required this.supporterImpact,
  });

  final Club club;
  final StadiumMatchdayRevenue projection;
  final int occupancy;
  final String supporterImpact;

  @override
  Widget build(BuildContext context) => GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.9,
        children: [
          DashboardStatTile(
            icon: Icons.groups_2_outlined,
            label: 'Público projetado',
            value: '${projection.attendance}',
            caption: '$occupancy% da capacidade',
            compact: true,
          ),
          DashboardStatTile(
            icon: Icons.payments_outlined,
            label: 'Receita por jogo',
            value: compactMoney(projection.total),
            caption: 'Projeção em casa',
            compact: true,
          ),
          DashboardStatTile(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Receita comercial',
            value: compactMoney(projection.commercial),
            caption: 'Além da bilheteria',
            compact: true,
          ),
          DashboardStatTile(
            icon: Icons.local_fire_department_outlined,
            label: 'Impacto da torcida',
            value: supporterImpact,
            caption: 'Preço + ocupação',
            color: supporterImpact == 'Negativo' ? AppColors.warning : AppColors.green,
            compact: true,
          ),
        ],
      );
}

class StadiumRevenueCard extends StatelessWidget {
  const StadiumRevenueCard({super.key, required this.projection});

  final StadiumMatchdayRevenue projection;

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String, int)>[
      (Icons.confirmation_number_outlined, 'Bilheteria', projection.ticketing),
      (Icons.workspace_premium_outlined, 'Hospitalidade', projection.hospitality),
      (Icons.storefront_outlined, 'Lojas', projection.retail),
      (Icons.restaurant_outlined, 'Alimentação', projection.food),
      (Icons.campaign_outlined, 'Publicidade', projection.advertising),
      (Icons.local_parking_outlined, 'Estacionamento', projection.parking),
      (Icons.museum_outlined, 'Museu', projection.museum),
    ];
    final maxValue = items.fold<int>(1, (maxValue, item) => math.max(maxValue, item.$3));
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardSectionHeader(
            title: 'Receitas e público',
            subtitle: 'Projeção para um jogo em casa',
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                children: [
                  Icon(item.$1, size: 17, color: AppColors.green),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 96,
                    child: Text(item.$2, style:  TextStyle(color: AppColors.muted, fontSize: 9.7)),
                  ),
                  Expanded(
                    child: DashboardProgress(
                      value: item.$3 / maxValue,
                      height: 6,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 70,
                    child: Text(
                      compactMoney(item.$3),
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 9.7, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StadiumFacilityGrid extends StatelessWidget {
  const StadiumFacilityGrid({
    super.key,
    required this.club,
    required this.projection,
    required this.availableFunds,
    required this.onUpgrade,
  });

  final Club club;
  final StadiumMatchdayRevenue projection;
  final int availableFunds;
  final void Function(StadiumFacility facility, bool negotiated) onUpgrade;

  @override
  Widget build(BuildContext context) {
    final values = <StadiumFacility, int>{
      StadiumFacility.stands: projection.ticketing,
      StadiumFacility.hospitality: projection.hospitality,
      StadiumFacility.retail: projection.retail,
      StadiumFacility.food: projection.food,
      StadiumFacility.advertising: projection.advertising,
      StadiumFacility.parking: projection.parking,
      StadiumFacility.museum: projection.museum,
    };
    final icons = <StadiumFacility, IconData>{
      StadiumFacility.stands: Icons.stadium_outlined,
      StadiumFacility.hospitality: Icons.workspace_premium_outlined,
      StadiumFacility.retail: Icons.storefront_outlined,
      StadiumFacility.food: Icons.restaurant_outlined,
      StadiumFacility.advertising: Icons.campaign_outlined,
      StadiumFacility.parking: Icons.local_parking_outlined,
      StadiumFacility.museum: Icons.museum_outlined,
    };
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 650 ? 3 : 2;
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: columns == 2 ? .68 : .95,
          children: StadiumFacility.values
              .map(
                (facility) => StadiumFacilityTile(
                  facility: facility,
                  icon: icons[facility]!,
                  level: StadiumEngine.facilityLevel(club.stadium, facility),
                  projectedValue: values[facility]!,
                  availableFunds: availableFunds,
                  locked: StadiumEngine.isLocked(club.stadium, facility),
                  cost: StadiumEngine.upgradeCost(club.stadium, facility),
                  negotiatedCost: StadiumEngine.negotiatedUpgradeCost(club: club, facility: facility),
                  onUpgrade: (negotiated) => onUpgrade(facility, negotiated),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class StadiumFacilityTile extends StatelessWidget {
  const StadiumFacilityTile({
    super.key,
    required this.facility,
    required this.icon,
    required this.level,
    required this.projectedValue,
    required this.availableFunds,
    required this.locked,
    required this.cost,
    required this.negotiatedCost,
    required this.onUpgrade,
  });

  final StadiumFacility facility;
  final IconData icon;
  final int level;
  final int projectedValue;
  final int availableFunds;
  final bool locked;
  final int cost;
  final int negotiatedCost;
  final ValueChanged<bool> onUpgrade;

  @override
  Widget build(BuildContext context) {
    final maxed = level >= StadiumEngine.maxFacilityLevel;
    final canUpgrade = cost > 0 && cost <= availableFunds;
    final canNegotiate = negotiatedCost > 0 && negotiatedCost <= availableFunds;
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DashboardIconBadge(icon: icon, size: 36),
              const Spacer(),
              DashboardStatusPill(
                label: locked ? 'Bloqueado' : 'Nível $level',
                color: locked ? AppColors.muted : AppColors.green,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            facility.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11.5),
          ),
          const SizedBox(height: 4),
          Text(
            facility.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style:  TextStyle(color: AppColors.muted, fontSize: 8.8, height: 1.25),
          ),
          const Spacer(),
          Text(
            'Receita proj. ${compactMoney(projectedValue)}',
            style: const TextStyle(color: AppColors.green, fontSize: 9.2, fontWeight: FontWeight.w900),
          ),
          if (!maxed) ...[
            const SizedBox(height: 4),
            Text(
              'Obra ${compactMoney(cost)}',
              style:  TextStyle(color: AppColors.muted, fontSize: 8.7),
            ),
            const SizedBox(height: 7),
            SizedBox(
              width: double.infinity,
              height: 34,
              child: FilledButton(
                onPressed: canUpgrade ? () => onUpgrade(false) : null,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  minimumSize: const Size(30, 34),
                ),
                child: Text(locked ? 'Desbloquear' : 'Melhorar', style: const TextStyle(fontSize: 9.5)),
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              width: double.infinity,
              height: 32,
              child: OutlinedButton(
                onPressed: canNegotiate ? () => onUpgrade(true) : null,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  minimumSize: const Size(30, 32),
                ),
                child: const Text('Negociar obra', style: TextStyle(fontSize: 8.8)),
              ),
            ),
            if (!canUpgrade && !canNegotiate) ...[
              const SizedBox(height: 5),
              const Text(
                'Saldo/orçamento insuficiente',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppColors.warning, fontSize: 8.2, fontWeight: FontWeight.w800),
              ),
            ],
          ] else
            const Padding(
              padding: EdgeInsets.only(top: 7),
              child: DashboardStatusPill(label: 'Nível máximo', color: AppColors.green),
            ),
        ],
      ),
    );
  }
}

