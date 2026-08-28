import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/widgets/common.dart';
import '../../app/widgets/management_dashboard_widgets.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/player/player.dart';
import '../../game/medical/medical_engine.dart';
import '../player/player_profile_screen.dart';
import 'medical_department_components.dart';

class MedicalDepartmentScreen extends ConsumerWidget {
  const MedicalDepartmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final career = ref.watch(gameControllerProvider).career!;
    final squad = [...career.userClub.squad]
      ..sort((a, b) {
        final injury = (b.injury != null ? 1 : 0).compareTo(a.injury != null ? 1 : 0);
        if (injury != 0) return injury;
        return MedicalEngine.reinjuryRisk(b).compareTo(MedicalEngine.reinjuryRisk(a));
      });
    final injured = squad.where((player) => player.injury != null).toList();
    final highRisk = squad
        .where((player) => player.injury == null && MedicalEngine.reinjuryRisk(player) >= 55)
        .toList();
    final nextReturnDays = injured.isEmpty
        ? null
        : injured
            .map((player) => MedicalEngine.assess(player).estimatedDays)
            .reduce((a, b) => a < b ? a : b);
    final accent = Color(career.userClub.colors.primaryHex);

    return PremiumScaffold(
      safeBottom: true,
      appBar: GameTopBar(
        title: 'Departamento médico',
        subtitle: 'Saúde, lesões e recuperação do elenco',
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
        children: [
          MedicalSummaryGrid(
            injured: injured.length,
            highRisk: highRisk.length,
            averageCondition: _averageCondition(squad),
            nextReturnDays: nextReturnDays,
          ),
          const SizedBox(height: 10),
          MedicalStatusBanner(injured: injured.length, highRisk: highRisk.length),
          const SizedBox(height: 14),
          DashboardSectionHeader(
            title: 'Monitoramento físico',
            subtitle: '${squad.length} jogadores do elenco',
          ),
          const SizedBox(height: 8),
          SectionCard(
            padding: const EdgeInsets.all(9),
            child: Column(
              children: [
                const _MedicalTableHeader(),
                const SizedBox(height: 7),
                ...squad.map(
                  (player) => Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: MedicalPlayerRow(
                      player: player,
                      accentColor: accent,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PlayerProfileScreen(
                            playerId: player.id,
                            clubId: career.userClubId,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          MedicalDistributionCard(players: squad),
        ],
      ),
    );
  }

  static int _averageCondition(List<Player> players) {
    if (players.isEmpty) return 0;
    return (players.fold<int>(0, (sum, player) => sum + player.condition) / players.length).round();
  }
}

class _MedicalTableHeader extends StatelessWidget {
  const _MedicalTableHeader();

  @override
  Widget build(BuildContext context) => const Row(
        children: [
          Expanded(
            flex: 5,
            child: Text('JOGADOR', style: TextStyle(color: AppColors.muted, fontSize: 8.5, fontWeight: FontWeight.w900)),
          ),
          SizedBox(width: 58),
          Expanded(
            flex: 3,
            child: Text('COND.', style: TextStyle(color: AppColors.muted, fontSize: 8.5, fontWeight: FontWeight.w900)),
          ),
          SizedBox(width: 7),
          Expanded(
            flex: 3,
            child: Text('RISCO', style: TextStyle(color: AppColors.muted, fontSize: 8.5, fontWeight: FontWeight.w900)),
          ),
          SizedBox(width: 84),
        ],
      );
}
