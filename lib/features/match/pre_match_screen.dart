import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/state/live_match_controller.dart';
import '../../app/widgets/common.dart';
import '../../app/widgets/player_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/competition_catalog.dart';
import '../../domain/formation/formation.dart';
import '../../domain/player/player.dart';
import '../../game/lineup/lineup_engine.dart';
import '../../game/match/renderer/match_kit_resolver.dart';
import '../lineup/lineup_screen.dart';
import '../tactics/tactics_screen.dart';
import 'match_screen.dart';
import 'pre_match_visual_components.dart';

class PreMatchScreen extends ConsumerStatefulWidget {
  const PreMatchScreen({super.key});

  @override
  ConsumerState<PreMatchScreen> createState() => _PreMatchScreenState();

  static String _availabilityText(Player player) =>
      switch (player.availabilityStatus) {
        PlayerAvailabilityStatus.injured =>
          '${player.injury?.name ?? 'Lesão'} • ${player.injury?.roundsRemaining ?? 1} rodada(s)',
        PlayerAvailabilityStatus.suspended =>
          'Suspenso • ${player.discipline.suspendedRounds} rodada(s)',
        PlayerAvailabilityStatus.lowCondition =>
          'Afastado • condição física ${player.condition}%',
        PlayerAvailabilityStatus.available => 'Disponível',
      };
}

class _PreMatchScreenState extends ConsumerState<PreMatchScreen> {
  MatchKitSlot? _selectedKitSlot;
  String? _selectionClubId;

  @override
  Widget build(BuildContext context) {
    final career = ref.watch(gameControllerProvider).career!;
    final fixture = career.nextUserFixture;
    if (fixture == null) {
      return const PremiumScaffold(
        appBar: GameTopBar(title: 'Pré-jogo'),
        body: EmptyState(
          icon: Icons.event_busy_rounded,
          title: 'Nenhuma partida pendente',
          text: 'Volte ao clube para continuar a carreira.',
        ),
      );
    }

    final home = career.clubs.firstWhere((club) => club.id == fixture.homeClubId);
    final away = career.clubs.firstWhere((club) => club.id == fixture.awayClubId);
    final suspended = career.suspendedPlayerIdsForCompetition(
      fixture.competitionId,
    );
    final FormationType formation = career.formation;
    final validation = LineupEngine.validate(
      career.userClub.squad,
      career.starterIds,
      formation,
      competitionSuspendedPlayerIds: suspended,
    );
    final unavailable = [
      ...career.unavailableUserPlayersForCompetition(fixture.competitionId),
    ]..sort((a, b) => a.displayName.compareTo(b.displayName));
    final suggestedIds = LineupEngine.autoSelect(
      career.userClub.squad,
      formation,
      competitionSuspendedPlayerIds: suspended,
    );
    final suggestedDiffers = suggestedIds.join('|') != career.starterIds.join('|');
    final competitionName = CompetitionCatalog.displayNameForId(fixture.competitionId);
    final ready = career.isMatchDay && validation.valid;
    final accent = AppColors.readableAccent(Color(career.userClub.colors.primaryHex));
    final defaultKitSlot = home.id == career.userClubId
        ? MatchKitSlot.primary
        : MatchKitSlot.away;
    final selectedKitSlot = _selectionClubId == career.userClubId
        ? (_selectedKitSlot ?? defaultKitSlot)
        : defaultKitSlot;
    final kitSelection = MatchKitResolver.resolve(
      home: home,
      away: away,
      userClubId: career.userClubId,
      userSlot: selectedKitSlot,
    );

    return PremiumScaffold(
      appBar: GameTopBar(
        title: 'Preparação da partida',
        subtitle: 'Rodada ${fixture.round} • ${fullDate(fixture.date)}',
      ),
      safeBottom: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.broadcastGradient,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
          children: [
            PreMatchHeroCard(
              home: home,
              away: away,
              fixture: fixture,
              competitionName: competitionName,
              userClubId: career.userClubId,
              isMatchDay: career.isMatchDay,
              ready: ready,
            ),
            const SizedBox(height: 10),
            PreMatchKitSelector(
              home: home,
              away: away,
              userClubId: career.userClubId,
              selectedSlot: selectedKitSlot,
              selection: kitSelection,
              onChanged: (slot) => setState(() {
                _selectionClubId = career.userClubId;
                _selectedKitSlot = slot;
              }),
            ),
            const SizedBox(height: 10),
            PreMatchDurationCard(
              selectedMinutes: career.settings.matchDurationMinutes,
              onChanged: (minutes) => ref
                  .read(gameControllerProvider.notifier)
                  .updateSettings(
                    career.settings.copyWith(matchDurationMinutes: minutes),
                  ),
            ),
            const SizedBox(height: 10),
            PreMatchPlanCard(
              validation: validation,
              formationLabel: formation.label,
              suggestedDiffers: suggestedDiffers,
              onLineupTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const LineupScreen(showBackButton: true),
                ),
              ),
              onTacticsTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TacticsScreen()),
              ),
              onAutoSelect: () =>
                  ref.read(gameControllerProvider.notifier).autoSelectLineup(),
            ),
            const SizedBox(height: 10),
            PreMatchLineupCard(
              assignments: validation.assignments,
              formation: formation,
              accentColor: accent,
            ),
            const SizedBox(height: 10),
            _UnavailablePanel(
              unavailable: unavailable,
              accentColor: accent,
            ),
            const SizedBox(height: 14),
            _StartMatchButton(
              ready: ready,
              isMatchDay: career.isMatchDay,
              lineupValid: validation.valid,
              onPressed: () {
                final live = ref
                    .read(liveMatchControllerProvider.notifier)
                    .prepareMatch();
                if (live != null && context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => MatchScreen(
                        kitSelection: kitSelection,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

}

class _UnavailablePanel extends StatelessWidget {
  const _UnavailablePanel({
    required this.unavailable,
    required this.accentColor,
  });

  final List<Player> unavailable;
  final Color accentColor;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.panelGradient,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border.withValues(alpha: .82)),
          boxShadow: const [
            BoxShadow(color: Color(0x26000000), blurRadius: 14, offset: Offset(0, 6)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.warning.withValues(alpha: .11),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: .34),
                    ),
                  ),
                  child: const Icon(
                    Icons.medical_information_outlined,
                    color: AppColors.warning,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'INDISPONÍVEIS',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  '${unavailable.length}',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (unavailable.isEmpty)
              Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.green,
                    size: 22,
                  ),
                  const SizedBox(width: 9),
                   Expanded(
                    child: Text(
                      'Todo o elenco está disponível para a partida.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              )
            else
              ...unavailable.map(
                (player) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      PlayerAvatar(
                        player: player,
                        size: 36,
                        accentColor: accentColor,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              player.displayName,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              PreMatchScreen._availabilityText(player),
                              style: const TextStyle(
                                color: AppColors.warning,
                                fontSize: 8.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      OverallShield(value: player.overall, compact: true),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
}

class _StartMatchButton extends StatelessWidget {
  const _StartMatchButton({
    required this.ready,
    required this.isMatchDay,
    required this.lineupValid,
    required this.onPressed,
  });

  final bool ready;
  final bool isMatchDay;
  final bool lineupValid;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: ready ? onPressed : null,
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            height: 64,
            decoration: BoxDecoration(
              gradient: ready
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFB6F928), Color(0xFF91E312), Color(0xFF72C90B)],
                    )
                  : LinearGradient(
                      colors: [AppColors.surfaceSoft, AppColors.surfaceRaised],
                    ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: ready
                    ? const Color(0xFFBFFF44).withValues(alpha: .55)
                    : AppColors.border,
              ),
              boxShadow: ready
                  ? const [
                      BoxShadow(
                        color: Color(0x3A76D91B),
                        blurRadius: 18,
                        offset: Offset(0, 7),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_circle_fill_rounded,
                  color: ready ? Colors.black : AppColors.textSecondary,
                  size: 28,
                ),
                const SizedBox(width: 9),
                Text(
                  !isMatchDay
                      ? 'A partida ainda não chegou'
                      : lineupValid
                          ? 'Iniciar partida'
                          : 'Corrija a escalação para jogar',
                  style: TextStyle(
                    color: ready ? Colors.black : AppColors.textSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
