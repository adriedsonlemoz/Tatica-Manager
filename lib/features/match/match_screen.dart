import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/audio/audio_manager.dart';
import '../../app/audio/audio_providers.dart';
import '../../app/state/game_controller.dart';
import '../../app/state/live_match_controller.dart';
import '../../app/widgets/common.dart';
import '../../domain/club/club.dart';
import '../../domain/match/match_models.dart';
import '../../domain/player/player.dart';
import '../../domain/season/career_state.dart';
import '../../domain/tactic/tactic.dart';
import '../../game/match/live_substitution_rules.dart';
import '../../game/match/renderer/match_pitch_game.dart';
import 'live_match_playback.dart';
import 'live_round_feed.dart';
import 'result_screen.dart';
import 'widgets/live_match_controls.dart';
import 'widgets/live_match_event_widgets.dart';
import 'widgets/live_match_narration_panel.dart';
import 'widgets/live_match_pitch_panel.dart';
import 'widgets/live_match_phase_transition_overlay.dart';
import 'widgets/live_match_scoreboard.dart';
import 'widgets/live_match_simulation_sheet.dart';
import 'widgets/live_match_timeline_bar.dart';
import 'widgets/live_round_widgets.dart';
import 'widgets/live_substitution_sheet.dart';
import 'widgets/live_tactic_sheet.dart';

class MatchScreen extends ConsumerStatefulWidget {
  const MatchScreen({super.key});

  @override
  ConsumerState<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends ConsumerState<MatchScreen> {
  Timer? timer;
  Timer? roundAlertTimer;
  int minute = 0;
  bool paused = false;
  double presentationElapsedMs = 0;
  late MatchPitchGame pitchGame;
  bool finishing = false;
  bool atHalftime = false;
  bool fullTime = false;
  bool replayActive = false;
  bool pendingHalftime = false;
  bool pendingFullTime = false;
  MatchEvent? presentedEvent;
  late final AudioManager _audioManager;
  bool _audioExited = false;
  LiveRoundGoalAlert? roundAlert;

  @override
  void initState() {
    super.initState();
    final career = ref.read(gameControllerProvider).career!;
    final live = ref.read(liveMatchControllerProvider)!;
    final home = career.clubs.firstWhere(
      (club) => club.id == live.fixture.homeClubId,
    );
    final away = career.clubs.firstWhere(
      (club) => club.id == live.fixture.awayClubId,
    );
    _audioManager = ref.read(audioManagerProvider);
    unawaited(_audioManager.enterMatch(homeName: home.name, awayName: away.name));
    pitchGame = MatchPitchGame(
      homeColor: Color(home.colors.primaryHex),
      awayColor: Color(away.colors.primaryHex),
      homeKit: home.homeKit,
      awayKit: away.awayKit,
      homeClubId: home.id,
      awayClubId: away.id,
      homePlayerIds: live.homeStarterIds,
      awayPlayerIds: live.awayStarterIds,
      ballStyle: career.settings.matchBallStyle,
      onEventStarted: (event) {
        if (!mounted) return;
        unawaited(
          _audioManager.presentMatchEvent(
                event,
                teamName: _eventTeamName(event, home, away),
              ),
        );
        setState(() => presentedEvent = event);
      },
      onReplayChanged: (active) {
        if (!mounted) return;
        setState(() {
          replayActive = active;
          if (!active) _completePendingPhase();
        });
      },
    );
    timer = Timer.periodic(const Duration(milliseconds: 100), (_) => _tick());
  }

  void _tick() {
    if (!mounted ||
        paused ||
        finishing ||
        atHalftime ||
        fullTime ||
        pitchGame.blocksClock) {
      return;
    }
    final minutesPerHalf = ref
        .read(gameControllerProvider)
        .career!
        .settings
        .matchDurationMinutes;
    final totalPresentationMinutes = minutesPerHalf * 2;
    final millisecondsPerMatchMinute = totalPresentationMinutes * 60000 / 90;
    presentationElapsedMs += 100;
    if (presentationElapsedMs < millisecondsPerMatchMinute) return;
    presentationElapsedMs -= millisecondsPerMatchMinute;
    if (minute >= 90) return;

    final nextMinute = minute + 1;
    final live = ref.read(liveMatchControllerProvider);
    if (live != null) {
      final newEvents = live.result.events
          .where((event) => event.minute == nextMinute)
          .toList()
        ..sort((a, b) => a.sequence.compareTo(b.sequence));
      pitchGame.playEvents(newEvents);
    }

    if (live != null) _showRoundAlertForRange(minute, nextMinute, live);
    setState(() {
      minute = nextMinute;
      if (minute == 45) {
        if (pitchGame.blocksClock) {
          pendingHalftime = true;
        } else {
          atHalftime = true;
          paused = true;
        }
      } else if (minute == 90) {
        if (pitchGame.blocksClock) {
          pendingFullTime = true;
        } else {
          fullTime = true;
          paused = true;
        }
      }
    });
    if (fullTime) unawaited(_audioManager.finishMatchPresentation());
  }

  void _completePendingPhase() {
    if (pendingHalftime) {
      pendingHalftime = false;
      atHalftime = true;
      paused = true;
    }
    if (pendingFullTime) {
      pendingFullTime = false;
      fullTime = true;
      paused = true;
      unawaited(_audioManager.finishMatchPresentation());
    }
  }

  void _startSecondHalf() {
    if (!mounted || !atHalftime) return;
    unawaited(_audioManager.announceSecondHalf());
    setState(() {
      atHalftime = false;
      paused = false;
    });
  }

  String get _phaseLabel {
    if (fullTime) return 'FIM DE JOGO';
    if (atHalftime) return 'INTERVALO';
    if (minute <= 45) return '1º TEMPO';
    return '2º TEMPO';
  }

  Future<void> _finish() async {
    if (finishing) return;
    finishing = true;
    timer?.cancel();
    final result =
        await ref.read(liveMatchControllerProvider.notifier).finishMatch();
    if (result == null) return;
    await _leaveMatchAudio();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
    );
  }

  Future<void> _leaveMatchAudio() async {
    if (_audioExited) return;
    _audioExited = true;
    await _audioManager.exitMatch();
  }

  @override
  void dispose() {
    timer?.cancel();
    roundAlertTimer?.cancel();
    unawaited(_leaveMatchAudio());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final career = ref.watch(gameControllerProvider).career!;
    final live = ref.watch(liveMatchControllerProvider);
    if (live == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final result = live.result;
    final home = career.clubs.firstWhere(
      (club) => club.id == live.fixture.homeClubId,
    );
    final away = career.clubs.firstWhere(
      (club) => club.id == live.fixture.awayClubId,
    );
    // Não antecipa no placar ou nas estatísticas um evento que o renderer ainda
    // não apresentou. Isso também evita o placar avançar e recuar quando há
    // mais de um evento no mesmo minuto.
    final currentSequence = minute == 0
        ? null
        : presentedEvent?.minute == minute
            ? presentedEvent!.sequence
            : -1;
    final currentScore = LiveRoundFeed.scoreUntil(
      result,
      minute,
      throughSequence: currentSequence,
    );
    final playersById = <String, Player>{
      for (final player in home.squad) player.id: player,
      for (final player in away.squad) player.id: player,
    };
    final userClub = career.userClub;

    return PopScope(
      canPop: false,
      child: PremiumScaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF091117), Color(0xFF0D171C), Color(0xFF101A20)],
            ),
          ),
          child: Column(
            children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 7),
              child: LiveMatchScoreboard(
                home: home,
                away: away,
                score: currentScore,
                minute: minute,
                phaseLabel: _phaseLabel,
                events: result.events,
                throughSequence: currentSequence,
                paused: paused,
              ),
            ),
            LiveRoundTicker(
              round: live.fixture.round,
              alert: _roundAlertText(career),
              venue: home.stadium.name,
              onOpenRound: () => _showRound(context, career, live),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 22),
                children: [
                  if (atHalftime) ...[
                    MatchPhasePanel(
                      icon: Icons.pause_circle_filled_rounded,
                      title: 'Intervalo',
                      message:
                          'Ajuste a equipe antes de voltar. O placar e os comandos continuam sempre à mão.',
                      buttonLabel: 'Começar segundo tempo',
                      buttonIcon: Icons.play_arrow_rounded,
                      onPressed: _startSecondHalf,
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (fullTime) ...[
                    MatchPhasePanel(
                      icon: Icons.sports_score_rounded,
                      title: 'Fim de jogo',
                      message:
                          '${home.name} ${currentScore.display} ${away.name}',
                      buttonLabel: 'Ver resumo da partida',
                      buttonIcon: Icons.analytics_rounded,
                      onPressed: _finish,
                    ),
                    const SizedBox(height: 8),
                  ],
                  LiveMatchPitchPanel(
                    game: pitchGame,
                    event: presentedEvent,
                    teamName: presentedEvent == null
                        ? 'Partida'
                        : _eventTeamName(presentedEvent!, home, away),
                    player: presentedEvent == null
                        ? null
                        : playersById[presentedEvent!.playerId],
                    secondaryPlayer: presentedEvent == null
                        ? null
                        : playersById[presentedEvent!.secondaryPlayerId],
                    assistPlayer: presentedEvent == null
                        ? null
                        : playersById[presentedEvent!.assistPlayerId],
                    replayActive: replayActive,
                    score: currentScore,
                    phaseTransition: fullTime
                        ? LiveMatchPhaseTransition.fulltime
                        : atHalftime
                            ? LiveMatchPhaseTransition.halftime
                            : null,
                  ),
                  const SizedBox(height: 5),
                  LiveMatchTimelineBar(
                    events: result.events,
                    minute: minute,
                    throughSequence: currentSequence,
                  ),
                  const SizedBox(height: 7),
                  LiveMatchControlBar(
                    paused: paused,
                    enabled: !fullTime,
                    onPauseToggle: () {
                      if (atHalftime) {
                        _startSecondHalf();
                      } else {
                        setState(() => paused = !paused);
                      }
                    },
                    onSimulate: () => _simulate(context, live),
                    soundEnabled: career.settings.sound,
                    onSoundToggle: () async {
                      final settings = career.settings.copyWith(
                        sound: !career.settings.sound,
                      );
                      await ref
                          .read(gameControllerProvider.notifier)
                          .updateSettings(settings);
                      await _audioManager.applySettings(settings);
                    },
                    onTactic: () => _liveTactic(context, ref, live.userTactic),
                    onSubstitution: () => _substitution(
                      context,
                      ref,
                      userClub.squad,
                      live.userStarterIds,
                      Color(userClub.colors.primaryHex),
                    ),
                  ),
                  const SizedBox(height: 8),
                  LiveMatchStatsCard(
                    events: result.events,
                    minute: minute,
                    homeId: home.id,
                    awayId: away.id,
                    throughSequence: currentSequence,
                  ),
                  const SizedBox(height: 8),
                  LiveMatchNarrationPanel(
                    events: result.events,
                    minute: minute,
                    throughSequence: currentSequence,
                    home: home,
                    away: away,
                    userClubId: userClub.id,
                    playersById: playersById,
                  ),
                ],
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  Future<void> _liveTactic(
    BuildContext context,
    WidgetRef ref,
    Tactic current,
  ) async {
    final resumeAfterSheet = !paused && !atHalftime && !fullTime;
    setState(() => paused = true);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => LiveTacticSheet(
        current: current,
        onApply: (tactic) => ref
            .read(liveMatchControllerProvider.notifier)
            .changeTactic(tactic, minute),
      ),
    );
    if (mounted && resumeAfterSheet) setState(() => paused = false);
  }

  Future<void> _substitution(
    BuildContext context,
    WidgetRef ref,
    List<Player> squad,
    List<String> starters,
    Color accentColor,
  ) async {
    final resumeAfterSheet = !paused && !atHalftime && !fullTime;
    final currentLive = ref.read(liveMatchControllerProvider);
    if (currentLive == null) return;
    final userClubId = ref.read(gameControllerProvider).career?.userClubId;
    if (userClubId == null) return;
    final previousSubstitutions = LiveSubstitutionRules.substitutionsForTeam(
      currentLive.result.events,
      userClubId,
    );
    final alreadySubstitutedOut = previousSubstitutions
        .map((event) => event.secondaryPlayerId)
        .whereType<String>()
        .toSet();
    final substitutionsUsed = previousSubstitutions.length;
    final substitutionWindowsUsed = LiveSubstitutionRules.substitutionWindowsUsed(
      currentLive.result.events,
      userClubId,
    );
    final violation = LiveSubstitutionRules.violationMessage(
      events: currentLive.result.events,
      teamId: userClubId,
      minute: minute,
    );
    if (violation != null) {
      ref.read(gameControllerProvider.notifier).showMessage(violation);
      return;
    }
    final dismissedPlayerIds = currentLive.result.events
        .where(
          (event) =>
              event.type == MatchEventType.red &&
              event.teamId == userClubId &&
              event.minute <= minute,
        )
        .map((event) => event.playerId)
        .whereType<String>()
        .toSet();
    setState(() {
      paused = true;
      presentationElapsedMs = 0;
    });
    final willUseNewWindow = LiveSubstitutionRules.wouldConsumeNewWindow(
      events: currentLive.result.events,
      teamId: userClubId,
      minute: minute,
    );
    final selections = await showModalBottomSheet<List<LiveSubstitutionChange>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => LiveSubstitutionSheet(
        squad: squad,
        starterIds: starters,
        formation: currentLive.userFormation,
        accentColor: accentColor,
        excludedIncomingIds: alreadySubstitutedOut,
        dismissedPlayerIds: dismissedPlayerIds,
        substitutionsUsed: substitutionsUsed,
        substitutionLimit: LiveMatchController.maxSubstitutions,
        substitutionWindowsUsed: substitutionWindowsUsed,
        substitutionWindowLimit: LiveMatchController.maxSubstitutionWindows,
        halftime: minute == LiveSubstitutionRules.halftimeMinute,
        willUseNewWindow: willUseNewWindow,
      ),
    );
    if (!mounted) return;
    if (selections != null && selections.isNotEmpty) {
      final applied = ref
          .read(liveMatchControllerProvider.notifier)
          .substituteMany(selections, minute);
      final updated = ref.read(liveMatchControllerProvider);
      if (applied && updated != null) {
        pitchGame.updateLineups(
          homePlayerIds: updated.homeStarterIds,
          awayPlayerIds: updated.awayStarterIds,
        );
        final selectedPairs = {
          for (final selection in selections)
            '${selection.incomingId}|${selection.outgoingId}',
        };
        final substitutionEvents = updated.result.events
            .where(
              (event) =>
                  event.minute == minute &&
                  event.type == MatchEventType.substitution &&
                  event.playerId != null &&
                  event.secondaryPlayerId != null &&
                  selectedPairs.contains(
                    '${event.playerId}|${event.secondaryPlayerId}',
                  ),
            )
            .toList()
          ..sort((a, b) => a.sequence.compareTo(b.sequence));
        if (substitutionEvents.isNotEmpty) {
          pitchGame.playEvents(substitutionEvents);
        }
      }
    }
    setState(() {
      presentationElapsedMs = 0;
      if (resumeAfterSheet) paused = false;
    });
  }

  Future<void> _simulate(
    BuildContext context,
    LiveMatchSession live,
  ) async {
    final resumeAfterSheet = !paused && !atHalftime && !fullTime;
    setState(() => paused = true);
    final option = await showLiveMatchSimulationOptions(
      context,
      minute: minute,
    );
    if (!mounted) return;
    if (option == null) {
      if (resumeAfterSheet) setState(() => paused = false);
      return;
    }
    final target = LiveMatchPlayback.targetFor(
      option: option,
      currentMinute: minute,
      events: live.result.events,
    );
    pitchGame.clearPresentationQueue();
    _showRoundAlertForRange(minute, target, live);
    final eventsAtTarget = live.result.events
        .where((event) => event.minute == target)
        .toList()
      ..sort((a, b) => a.sequence.compareTo(b.sequence));
    final landing = eventsAtTarget.isEmpty ? null : eventsAtTarget.last;
    if (option == LiveMatchSimulationOption.nextImportant &&
        eventsAtTarget.isNotEmpty) {
      pitchGame.playEvents(eventsAtTarget);
    } else if (landing != null &&
        (landing.type == MatchEventType.halftime ||
            landing.type == MatchEventType.fulltime)) {
      unawaited(
        _audioManager.presentMatchEvent(
              landing,
              teamName: 'Partida',
            ),
      );
    }
    setState(() {
      minute = target;
      presentedEvent = option == LiveMatchSimulationOption.nextImportant
          ? presentedEvent
          : landing;
      presentationElapsedMs = 0;
      pendingHalftime = false;
      pendingFullTime = false;
      atHalftime = target == 45;
      fullTime = target >= 90;
      paused = atHalftime || fullTime || !resumeAfterSheet;
    });
    if (fullTime) unawaited(_audioManager.finishMatchPresentation());
  }

  void _showRoundAlertForRange(
    int fromMinute,
    int toMinute,
    LiveMatchSession live,
  ) {
    if (toMinute <= fromMinute) return;
    final alerts = <LiveRoundGoalAlert>[];
    for (var value = fromMinute + 1; value <= toMinute; value++) {
      alerts.addAll(LiveRoundFeed.alertsAtMinute(live.otherMatches, value));
    }
    if (alerts.isEmpty || !mounted) return;
    roundAlertTimer?.cancel();
    setState(() => roundAlert = alerts.last);
    roundAlertTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => roundAlert = null);
    });
  }

  String? _roundAlertText(CareerState career) {
    final alert = roundAlert;
    if (alert == null) return null;
    final home = career.clubs.firstWhere(
      (club) => club.id == alert.match.fixture.homeClubId,
    );
    final away = career.clubs.firstWhere(
      (club) => club.id == alert.match.fixture.awayClubId,
    );
    return 'Gol em outro jogo: ${home.name} ${alert.score.display} ${away.name}';
  }

  Future<void> _showRound(
    BuildContext context,
    CareerState career,
    LiveMatchSession live,
  ) async {
    final resumeAfterSheet = !paused && !atHalftime && !fullTime;
    setState(() => paused = true);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => LiveRoundSheet(
        career: career,
        live: live,
        minute: minute,
      ),
    );
    if (mounted && resumeAfterSheet) setState(() => paused = false);
  }

  static String _eventTeamName(MatchEvent event, Club home, Club away) {
    if (event.teamId == home.id) return home.name;
    if (event.teamId == away.id) return away.name;
    return 'Partida';
  }

}
