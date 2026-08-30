import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/state/live_match_controller.dart';
import '../../app/widgets/common.dart';
import '../../core/theme/app_colors.dart';
import '../../data/competition_catalog.dart';
import '../../domain/club/club.dart';
import '../../domain/formation/formation.dart';
import '../../domain/match/match_models.dart';
import '../../domain/player/player.dart';
import '../../game/league/live_round_simulator.dart';
import '../../game/lineup/lineup_engine.dart';
import '../../game/match/engine/match_strength_calculator.dart';
import '../../game/match/renderer/match_kit_resolver.dart';
import '../lineup/lineup_screen.dart';
import '../tactics/tactics_screen.dart';
import 'match_screen.dart';
import 'pre_match_kit_selector.dart';
import 'pre_match_reference_components.dart';
import 'result_screen.dart';

class PreMatchScreen extends ConsumerStatefulWidget {
  const PreMatchScreen({super.key});

  @override
  ConsumerState<PreMatchScreen> createState() => _PreMatchScreenState();
}

class _PreMatchScreenState extends ConsumerState<PreMatchScreen> {
  MatchKitSlot? _selectedKitSlot;
  String? _selectionClubId;
  bool _simulating = false;

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
    final userClub = career.userClub;
    final opponent = home.id == career.userClubId ? away : home;
    final suspended = career.suspendedPlayerIdsForCompetition(
      fixture.competitionId,
    );

    final FormationType userFormation = career.formation;
    final opponentFormation = LiveRoundSimulator.formationFor(opponent);
    final opponentTactic = LiveRoundSimulator.tacticFor(opponent);

    final userValidation = LineupEngine.validate(
      userClub.squad,
      career.starterIds,
      userFormation,
      competitionSuspendedPlayerIds: suspended,
    );
    final opponentStarterIds = LineupEngine.autoSelect(
      opponent.squad,
      opponentFormation,
      competitionSuspendedPlayerIds: suspended,
    );
    final opponentValidation = LineupEngine.validate(
      opponent.squad,
      opponentStarterIds,
      opponentFormation,
      competitionSuspendedPlayerIds: suspended,
    );

    final userStrength = MatchStrengthCalculator.calculate(
      userValidation.assignments,
      career.tactic,
    );
    final opponentStrength = MatchStrengthCalculator.calculate(
      opponentValidation.assignments,
      opponentTactic,
    );

    final userUnavailable = _unavailableForClub(userClub, suspended);
    final opponentUnavailable = _unavailableForClub(opponent, suspended);
    final competitionName = CompetitionCatalog.displayNameForId(
      fixture.competitionId,
    );
    final ready = career.isMatchDay && userValidation.valid;

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
      appBar: const GameTopBar(title: 'Pré-jogo'),
      safeBottom: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF07131A), AppColors.background, Color(0xFF081319)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
          children: [
            PreMatchReferenceHero(
              home: home,
              away: away,
              fixture: fixture,
              competitionName: competitionName,
              homeForm: _recentForm(career.fixtures, home.id),
              awayForm: _recentForm(career.fixtures, away.id),
            ),
            const SizedBox(height: 9),
            PreMatchTacticalComparison(
              userFormation: userFormation,
              opponentFormation: opponentFormation,
              userTactic: career.tactic,
              opponentTactic: opponentTactic,
              userStrength: userStrength,
              opponentStrength: opponentStrength,
            ),
            const SizedBox(height: 9),
            PreMatchProbableLineups(
              userClub: userClub,
              opponent: opponent,
              userAssignments: userValidation.assignments,
              opponentAssignments: opponentValidation.assignments,
            ),
            const SizedBox(height: 9),
            PreMatchAbsences(
              userUnavailable: userUnavailable,
              opponentUnavailable: opponentUnavailable,
              competitionSuspendedPlayerIds: suspended,
            ),
            const SizedBox(height: 10),
            PreMatchActionCards(
              onLineup: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const LineupScreen(showBackButton: true),
                ),
              ),
              onTactics: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TacticsScreen()),
              ),
              onKits: () => _showKitDialog(
                home: home,
                away: away,
                selectedSlot: selectedKitSlot,
              ),
            ),
            const SizedBox(height: 12),
            PreMatchBottomActions(
              enabled: ready,
              simulating: _simulating,
              onPlay: () => _playMatch(kitSelection),
              onSimulate: _simulateMatch,
            ),
          ],
        ),
      ),
    );
  }

  void _playMatch(MatchVisualKitSelection kitSelection) {
    final live = ref.read(liveMatchControllerProvider.notifier).prepareMatch();
    if (live != null && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => MatchScreen(kitSelection: kitSelection),
        ),
      );
    }
  }

  Future<void> _simulateMatch() async {
    if (_simulating) return;
    setState(() => _simulating = true);
    final controller = ref.read(liveMatchControllerProvider.notifier);
    final live = controller.prepareMatch();
    if (live == null) {
      if (mounted) setState(() => _simulating = false);
      return;
    }
    final result = await controller.finishMatch();
    if (!mounted) return;
    setState(() => _simulating = false);
    if (result == null) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
    );
  }

  Future<void> _showKitDialog({
    required Club home,
    required Club away,
    required MatchKitSlot selectedSlot,
  }) async {
    final career = ref.read(gameControllerProvider).career!;
    var localSlot = selectedSlot;
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: .72),
      builder: (_) => StatefulBuilder(
        builder: (_, setDialogState) {
          final selection = MatchKitResolver.resolve(
            home: home,
            away: away,
            userClubId: career.userClubId,
            userSlot: localSlot,
          );
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 470),
              child: PreMatchKitSelector(
                home: home,
                away: away,
                userClubId: career.userClubId,
                selectedSlot: localSlot,
                selection: selection,
                onChanged: (slot) {
                  localSlot = slot;
                  setDialogState(() {});
                  if (mounted) {
                    setState(() {
                      _selectionClubId = career.userClubId;
                      _selectedKitSlot = slot;
                    });
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  static List<Player> _unavailableForClub(
    Club club,
    Set<String> competitionSuspendedPlayerIds,
  ) {
    final players = club.squad
        .where(
          (player) =>
              player.injury != null ||
              player.condition < 35 ||
              competitionSuspendedPlayerIds.contains(player.id),
        )
        .toList(growable: false);
    return [...players]..sort((a, b) => a.displayName.compareTo(b.displayName));
  }

  static List<String> _recentForm(
    List<MatchFixture> fixtures,
    String clubId,
  ) {
    final matches = fixtures
        .where(
          (fixture) =>
              fixture.played &&
              fixture.score != null &&
              (fixture.homeClubId == clubId || fixture.awayClubId == clubId),
        )
        .toList()
      ..sort((a, b) {
        final byDate = b.date.compareTo(a.date);
        return byDate != 0 ? byDate : b.round.compareTo(a.round);
      });
    final form = <String>[];
    for (final fixture in matches.take(5)) {
      final isHome = fixture.homeClubId == clubId;
      final score = fixture.score!;
      final scored = isHome ? score.home : score.away;
      final conceded = isHome ? score.away : score.home;
      form.add(scored > conceded ? 'V' : scored == conceded ? 'E' : 'D');
    }
    while (form.length < 5) {
      form.add('—');
    }
    return form.reversed.toList(growable: false);
  }
}
