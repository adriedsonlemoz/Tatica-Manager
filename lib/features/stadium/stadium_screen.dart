import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/widgets/common.dart';
import '../../domain/club/club.dart';
import '../../domain/finance/club_administration.dart';
import '../../domain/finance/finance.dart';
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
    final tablePosition =
        career.standings.indexWhere((standing) => standing.clubId == club.id) + 1;
    final projection = StadiumEngine.settleMatchday(
      club: club,
      tablePosition: tablePosition <= 0 ? 10 : tablePosition,
    );
    final occupancy = stadium.capacity <= 0
        ? 0
        : (projection.attendance * 100 / stadium.capacity).round();
    final ticketTransactions = career.finances.where(
      (transaction) =>
          transaction.amount > 0 &&
          (transaction.kind == FinanceKind.matchIncome ||
              transaction.kind == FinanceKind.matchday),
    );
    final monthRevenue = ticketTransactions
        .where(
          (transaction) =>
              transaction.createdAt.year == career.currentDate.year &&
              transaction.createdAt.month == career.currentDate.month,
        )
        .fold<int>(0, (sum, transaction) => sum + transaction.amount);
    final previousMonthDate = DateTime(
      career.currentDate.year,
      career.currentDate.month - 1,
      1,
    );
    final previousMonthRevenue = ticketTransactions
        .where(
          (transaction) =>
              transaction.createdAt.year == previousMonthDate.year &&
              transaction.createdAt.month == previousMonthDate.month,
        )
        .fold<int>(0, (sum, transaction) => sum + transaction.amount);
    final seasonRevenue = ticketTransactions
        .where((transaction) => transaction.season == career.season)
        .fold<int>(0, (sum, transaction) => sum + transaction.amount);
    final monthDeltaPercent = previousMonthRevenue <= 0
        ? (monthRevenue > 0 ? 100 : 0)
        : (((monthRevenue - previousMonthRevenue) * 100) /
                previousMonthRevenue)
            .round();

    final since = career.currentDate.subtract(const Duration(days: 365));
    final invested = career.finances
        .where(
          (transaction) =>
              transaction.kind == FinanceKind.stadiumInvestment &&
              transaction.amount < 0 &&
              !transaction.createdAt.isBefore(since),
        )
        .fold<int>(0, (sum, transaction) => sum + transaction.amount.abs());
    final completed = stadium.projects
        .where((project) => project.status == StadiumProjectStatus.completed)
        .length;
    final inProgress = stadium.projects
        .where((project) => project.status == StadiumProjectStatus.inProgress)
        .length;
    final planned = stadium.projects
        .where((project) => project.status == StadiumProjectStatus.planned)
        .length;
    final recommended = _recommendedFacility(stadium);
    final stadiumBudget = career.clubAdministration.budgetPlan
        .forDepartment(ClubDepartment.stadium);
    final availableFunds = math.min(stadiumBudget, club.money).toInt();

    return PremiumScaffold(
      safeBottom: true,
      appBar: const GameTopBar(title: 'Estádio'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 28),
        children: [
          StadiumClubHeader(club: club, season: career.season),
          const SizedBox(height: 10),
          StadiumOverviewCard(
            club: club,
            projectedAttendance: projection.attendance,
            onEdit: () => showEditStadiumDialog(context, ref),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 292,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: StadiumRevenuePanel(
                    monthRevenue: monthRevenue,
                    seasonRevenue: seasonRevenue,
                    occupancy: occupancy,
                    monthDeltaPercent: monthDeltaPercent,
                    onDetails: () => showStadiumRevenueDetails(
                      context,
                      monthRevenue: monthRevenue,
                      seasonRevenue: seasonRevenue,
                      projection: projection,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StadiumMaintenancePanel(
                    stadium: stadium,
                    monthlyCost: StadiumEngine.operatingCost(stadium),
                    onDetails: () => showStadiumMaintenanceDialog(context, ref),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 244,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: TrainingCenterPanel(
                    stadium: stadium,
                    onDetails: () => showTrainingCenterDialog(context, ref),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StadiumImprovementsPanel(
                    invested: invested,
                    completed: completed,
                    inProgress: inProgress,
                    planned: planned,
                    onDetails: () => showStadiumProjectsSheet(
                      context,
                      ref,
                      availableFunds: availableFunds,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (recommended != null) ...[
            const SizedBox(height: 10),
            SuggestedStadiumUpgradeCard(
              facility: recommended,
              cost: StadiumEngine.upgradeCost(stadium, recommended),
              durationDays: StadiumEngine.projectDurationDays(
                StadiumEngine.projectKindForFacility(recommended),
              ),
              availableFunds: availableFunds,
              onTap: () => showStadiumUpgradeDialog(
                context,
                ref,
                recommended,
                negotiated: false,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

StadiumFacility? _recommendedFacility(Stadium stadium) {
  for (final facility in StadiumFacility.values) {
    final kind = StadiumEngine.projectKindForFacility(facility);
    if (StadiumEngine.facilityLevel(stadium, facility) >=
        StadiumEngine.maxFacilityLevel) {
      continue;
    }
    if (StadiumEngine.hasActiveProject(stadium, kind)) continue;
    return facility;
  }
  return null;
}
