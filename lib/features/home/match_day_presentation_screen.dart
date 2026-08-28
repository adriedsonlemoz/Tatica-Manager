import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/widgets/common.dart';
import '../../app/widgets/management_dashboard_widgets.dart';
import '../../data/competition_catalog.dart';
import '../../domain/player/player.dart';
import '../../game/morale/morale_engine.dart';
import '../calendar/calendar_screen.dart';
import '../clubs/club_profile_screen.dart';
import '../lineup/lineup_screen.dart';
import '../match/pre_match_screen.dart';
import '../medical/medical_department_screen.dart';
import '../squad/squad_screen.dart';
import '../stadium/stadium_screen.dart';
import '../standings/standings_screen.dart';
import '../tactics/tactics_screen.dart';
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

    void open(Widget page) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    }

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
              onAgenda: () => open(CalendarScreen(initialFixtureId: fixture.id)),
            ),
            MatchDayVersusCard(
              home: home,
              away: away,
              fixture: fixture,
              userClubId: career.userClubId,
              onStadiumTap: () => open(
                home.id == career.userClubId
                    ? const StadiumScreen()
                    : ClubProfileScreen(clubId: home.id),
              ),
            ),
            const SizedBox(height: 14),
            const DashboardSectionHeader(
              title: 'Informações rápidas',
              subtitle: 'Os cards com seta abrem os módulos já existentes',
            ),
            const SizedBox(height: 8),
            MatchDayQuickInfoGrid(
              position: position,
              form: userClub.recentForm,
              morale: MoraleEngine.teamMorale(userClub),
              condition: condition,
              pressure: career.tactic.pressing.label,
              formation: career.formation.label,
              onPosition: () => open(const StandingsScreen()),
              onForm: () => open(CalendarScreen(initialFixtureId: fixture.id)),
              onMorale: () => open(const SquadScreen(showBackButton: true)),
              onCondition: () => open(const MedicalDepartmentScreen()),
              onPressure: () => open(const TacticsScreen()),
              onFormation: () => open(const LineupScreen(showBackButton: true)),
            ),
            const SizedBox(height: 10),
            MatchDayPreparationCard(
              unavailable: unavailable,
              startersReady: availableStarters,
              onContinue: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const PreMatchScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
