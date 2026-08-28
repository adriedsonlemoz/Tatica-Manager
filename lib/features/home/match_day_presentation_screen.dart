import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/widgets/common.dart';
import '../../app/widgets/management_dashboard_widgets.dart';
import '../../core/theme/app_colors.dart';
import '../../data/competition_catalog.dart';
import '../../domain/formation/formation.dart';
import '../../domain/tactic/tactic.dart';
import '../../domain/player/player.dart';
import '../../game/morale/morale_engine.dart';
import '../match/pre_match_screen.dart';
import 'match_day_header_components.dart';
import 'match_day_presentation_components.dart';

class MatchDayPresentationScreen extends ConsumerWidget {
  const MatchDayPresentationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final career = ref.watch(gameControllerProvider).career!;
    final fixture = career.nextUserFixture;
    if (fixture == null) {
      return const PremiumScaffold(
        body: Center(child: Text('Nenhuma partida pendente.')),
      );
    }
    final home = career.clubs.firstWhere((club) => club.id == fixture.homeClubId);
    final away = career.clubs.firstWhere((club) => club.id == fixture.awayClubId);
    final competition = CompetitionCatalog.displayNameForId(fixture.competitionId);
    final userClub = career.userClub;
    final position = career.standings.indexWhere((standing) => standing.clubId == career.userClubId) + 1;
    final availableStarters = career.starterIds
        .map((id) => userClub.squad.where((player) => player.id == id).firstOrNull)
        .whereType<Player>()
        .where((player) => player.isAvailable)
        .length;
    final unavailable = userClub.squad.where((player) => !player.isAvailable).length;
    final condition = userClub.squad.isEmpty
        ? 0
        : (userClub.squad.fold<int>(0, (sum, player) => sum + player.condition) / userClub.squad.length).round();

    return PopScope(
      canPop: true,
      child: PremiumScaffold(
        safeBottom: true,
        body: ListView(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 28),
          children: [
            MatchDayHeader(
              competition: competition,
              round: fixture.round,
              onBack: () => Navigator.of(context).pop(),
            ),
            MatchDayVersusCard(
              home: home,
              away: away,
              fixture: fixture,
              userClubId: career.userClubId,
            ),
            const SizedBox(height: 14),
            const DashboardSectionHeader(
              title: 'Informações rápidas',
              subtitle: 'Panorama da equipe antes da partida',
            ),
            const SizedBox(height: 8),
            MatchDayQuickInfoGrid(
              position: position,
              form: userClub.recentForm,
              morale: MoraleEngine.teamMorale(userClub),
              condition: condition,
              pressure: career.tactic.pressing.label,
              formation: career.formation.label,
            ),
            const SizedBox(height: 10),
            MatchDayPreparationCard(
              unavailable: unavailable,
              startersReady: availableStarters,
              onContinue: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const PreMatchScreen()),
              ),
            ),
            const SizedBox(height: 10),
            SectionCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.stadium_outlined, color: AppColors.green),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Palco da partida: ${home.stadium.name}. ${home.id == career.userClubId ? 'Seu clube joga em casa.' : 'Seu clube atua como visitante.'}',
                      style: const TextStyle(color: AppColors.muted, fontSize: 10.5),
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
}
