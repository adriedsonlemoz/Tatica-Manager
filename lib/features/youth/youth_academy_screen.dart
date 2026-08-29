import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/widgets/common.dart';
import '../../app/widgets/management_dashboard_widgets.dart';
import '../../core/theme/app_colors.dart';
import '../../game/youth/youth_academy_engine.dart';
import '../player/player_profile_screen.dart';
import 'youth_academy_components.dart';

class YouthAcademyScreen extends ConsumerWidget {
  const YouthAcademyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final career = ref.watch(gameControllerProvider).career!;
    final players = [...career.youthAcademy]
      ..sort((a, b) {
        final potential = b.potential.compareTo(a.potential);
        return potential != 0 ? potential : b.overall.compareTo(a.overall);
      });
    final accent = AppColors.readableAccent(Color(career.userClub.colors.primaryHex));

    return PremiumScaffold(
      safeBottom: true,
      appBar: GameTopBar(
        title: 'Categoria de base',
        subtitle: '${career.userClub.name} • ${players.length} jovem(ns)',
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
        children: [
          YouthAcademyOverview(club: career.userClub, players: players),
          if (players.isNotEmpty) ...[
            const SizedBox(height: 10),
            YouthProspectHighlight(
              player: players.first,
              accentColor: accent,
              onOpen: () => _openPlayer(context, players.first.id, career.userClubId),
            ),
            const SizedBox(height: 14),
            const DashboardSectionHeader(
              title: 'Jogadores da base',
              subtitle: 'Ordenados pelo maior potencial',
            ),
            const SizedBox(height: 8),
            ...players.map(
              (player) => YouthPlayerCard(
                player: player,
                accentColor: accent,
                onOpen: () => _openPlayer(context, player.id, career.userClubId),
                onPromote: () async {
                  final current = ref.read(gameControllerProvider).career!;
                  final result = YouthAcademyEngine.promote(current, player.id);
                  await ref
                      .read(gameControllerProvider.notifier)
                      .commitCareer(result.state, message: result.message);
                },
              ),
            ),
          ] else
             Padding(
              padding: EdgeInsets.only(top: 10),
              child: SectionCard(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 22),
                  child: Center(
                    child: Text(
                      'Nenhum jovem disponível na base.',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static void _openPlayer(BuildContext context, String playerId, String clubId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlayerProfileScreen(playerId: playerId, clubId: clubId),
      ),
    );
  }
}
