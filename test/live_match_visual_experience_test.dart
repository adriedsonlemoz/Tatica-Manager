import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/domain/match/match_models.dart';
import 'package:tatica_manager/features/match/match_event_presentation.dart';
import 'package:tatica_manager/game/match/renderer/match_pitch_camera.dart';
import 'package:tatica_manager/game/match/renderer/match_pitch_game.dart';
import 'package:tatica_manager/game/match/renderer/match_pitch_visuals.dart';
import 'package:tatica_manager/game/match/renderer/match_player_labels.dart';
import 'package:tatica_manager/game/match/renderer/match_player_motion.dart';

void main() {
  test('apresentação ao vivo cobre todos os tipos de evento', () {
    for (final type in MatchEventType.values) {
      expect(
        MatchEventPresentation.headline(type, 'Clube Teste'),
        isNotEmpty,
        reason: 'Evento ${type.name} precisa de headline.',
      );
    }
    expect(MatchEventPresentation.isMajor(MatchEventType.goal), isTrue);
    expect(MatchEventPresentation.isMajor(MatchEventType.red), isTrue);
    expect(MatchEventPresentation.isMajor(MatchEventType.woodwork), isTrue);
    expect(MatchEventPresentation.isMajor(MatchEventType.pass), isFalse);

    const genericPass = MatchEvent(
      minute: 5,
      sequence: 2,
      type: MatchEventType.pass,
      teamId: 'a',
      text: 'Texto genérico.',
    );
    expect(
      MatchEventPresentation.narration(genericPass, 'Clube Teste'),
      contains('Clube Teste'),
    );
    expect(
      MatchEventPresentation.narration(genericPass, 'Clube Teste'),
      isNot('Texto genérico.'),
    );
  });

  test('narração mostra o lance mais recente sem revelar eventos futuros', () {
    const events = [
      MatchEvent(
        minute: 4,
        sequence: 1,
        type: MatchEventType.pass,
        teamId: 'a',
        text: 'Passe.',
      ),
      MatchEvent(
        minute: 8,
        sequence: 2,
        type: MatchEventType.shot,
        teamId: 'a',
        text: 'Chute.',
      ),
      MatchEvent(
        minute: 8,
        sequence: 3,
        type: MatchEventType.goal,
        teamId: 'a',
        text: 'Gol.',
      ),
      MatchEvent(
        minute: 12,
        sequence: 4,
        type: MatchEventType.yellow,
        teamId: 'b',
        text: 'Cartão.',
      ),
    ];

    final visible = MatchEventPresentation.visible(events, 8);
    expect(visible.map((event) => event.sequence), [3, 2, 1]);
    expect(MatchEventPresentation.latest(events, 8)?.type, MatchEventType.goal);
    expect(visible.any((event) => event.minute > 8), isFalse);

    final throughShot = MatchEventPresentation.visible(
      events,
      8,
      throughSequence: 2,
    );
    expect(throughShot.map((event) => event.sequence), [2, 1]);
    expect(throughShot.any((event) => event.type == MatchEventType.goal), isFalse);
  });

  test('tela mantém placar fora da rolagem e troca visual sem dropdowns', () {
    final screen = File('lib/features/match/match_screen.dart').readAsStringSync();
    final pitchPanel = File(
      'lib/features/match/widgets/live_match_pitch_panel.dart',
    ).readAsStringSync();
    final narrationPanel = File(
      'lib/features/match/widgets/live_match_narration_panel.dart',
    ).readAsStringSync();
    final substitution = File(
      'lib/features/match/widgets/live_substitution_sheet.dart',
    ).readAsStringSync();

    expect(screen, contains('child: LiveMatchScoreboard('));
    expect(screen, contains('body: DecoratedBox('));
    expect(screen, contains('child: Column('));
    expect(screen, contains('LiveMatchPitchPanel('));
    expect(
      screen,
      contains("import 'widgets/live_match_event_widgets.dart';"),
    );
    expect(pitchPanel, isNot(contains('LiveMatchMomentCard(')));
    expect(pitchPanel, contains('AspectRatio('));
    expect(pitchPanel, contains('aspectRatio: 105 / 68'));
    expect(narrationPanel, contains('NARRAÇÃO AO VIVO'));
    final controls = File(
      'lib/features/match/widgets/live_match_controls.dart',
    ).readAsStringSync();
    expect(controls, contains('POSSE DE BOLA'));
    expect(controls, contains('CircularProgressIndicator'));
    expect(controls, contains('CHUTES NO GOL'));
    expect(controls, contains('_CardsStat'));
    expect(pitchPanel, contains('LiveMatchBroadcastOverlay('));
    expect(pitchPanel, contains('LiveMatchPhaseTransitionOverlay('));
    expect(screen, contains('LiveMatchNarrationPanel('));
    expect(screen, contains('LiveRoundTicker('));
    expect(screen, contains('showLiveMatchSimulationOptions('));
    expect(screen, contains('pitchGame.blocksClock'));
    expect(pitchPanel, contains('onSkipReplay: game.skipReplay'));
    expect(screen, contains('excludedIncomingIds: alreadySubstitutedOut'));
    expect(substitution, contains('QUEM SAI'));
    expect(substitution, contains('QUEM ENTRA'));
    expect(substitution, contains('PlayerAvatar('));
    expect(substitution, isNot(contains('DropdownButtonFormField')));
  });

  test('campo horizontal rotaciona apenas a representação da timeline', () {
    final homeGoalkeeper = MatchPitchGame.toHorizontalDisplayPoint(
      const FieldPoint(.50, .90),
    );
    final awayGoalkeeper = MatchPitchGame.toHorizontalDisplayPoint(
      const FieldPoint(.50, .10),
    );
    final homeShotTarget = MatchPitchGame.toHorizontalDisplayPoint(
      const FieldPoint(.50, .035),
    );

    expect(homeGoalkeeper.x, closeTo(.10, .0001));
    expect(homeGoalkeeper.y, closeTo(.50, .0001));
    expect(awayGoalkeeper.x, closeTo(.90, .0001));
    expect(awayGoalkeeper.y, closeTo(.50, .0001));
    expect(homeShotTarget.x, closeTo(.965, .0001));
    expect(homeShotTarget.y, closeTo(.50, .0001));
  });

  test('campo 2.5D preserva a geometria da 0.1.1.91 e adiciona profundidade', () {
    final field = MatchPitchVisuals.fieldRect(1000, 400);
    final clip = MatchPitchVisuals.pitchClip(1000, 400);

    expect(field.left, 14);
    expect(field.top, 18);
    expect(field.right, 986);
    expect(field.bottom, 382);
    expect(clip.outerRect, field);
    expect(MatchPitchVisuals.depthScale(0), closeTo(.82, .0001));
    expect(MatchPitchVisuals.depthScale(1), closeTo(1.10, .0001));
    expect(
      MatchPitchVisuals.depthScale(.8),
      greaterThan(MatchPitchVisuals.depthScale(.2)),
    );
    expect(MatchPitchVisuals.interfaceScale(360), closeTo(1, .0001));
  });

  test('nomes dos jogadores são compactados sem inventar identificação', () {
    expect(MatchPlayerLabels.compactName('Rafael S.'), 'Rafael S.');
    expect(MatchPlayerLabels.compactName('João Pedro Silva'), 'Silva');
    expect(
      MatchPlayerLabels.compactName('NomeExtremamenteComprido'),
      endsWith('…'),
    );
  });

  test('renderer mantém estado visual de movimento e de posição dos nomes', () {
    final motion = MatchPlayerMotionState(seed: 11);
    final placement = MatchPlayerLabelPlacement();

    expect(motion.movementAmount, 0);
    expect(placement.anchorIndex, isNull);

    final renderer = File(
      'lib/game/match/renderer/match_pitch_game.dart',
    ).readAsStringSync();
    expect(renderer, contains('_eventUsesStartPosition'));
    expect(renderer, contains('preparePenaltyTransitions'));
    expect(renderer, contains('prepareFormationReturn'));
    expect(renderer, contains('placementStates: _labelPlacements'));
  });

  test('renderer enfileira lances e só representa a timeline do motor', () {
    final screen = File('lib/features/match/match_screen.dart').readAsStringSync();
    final renderer = File(
      'lib/game/match/renderer/match_pitch_game.dart',
    ).readAsStringSync();

    expect(renderer, contains('_cueQueue'));
    expect(renderer, contains('MatchPresentationDirector.buildCues'));
    expect(renderer, contains('void playEvents('));
    expect(renderer, contains('event.start'));
    expect(renderer, contains('event.end'));
    expect(renderer, contains('toHorizontalDisplayPoint'));
    expect(renderer, contains('blocksClock'));
    expect(renderer, contains('skipReplay'));
    expect(renderer, contains('clearPresentationQueue'));
    expect(renderer, isNot(contains('MatchCameraDirector')));
    expect(renderer, contains('_applyCameraTransform'));
    expect(renderer, contains('canvas.translate('));
    expect(renderer, contains('canvas.scale('));
    expect(renderer, isNot(contains('MatchEngine')));
    expect(renderer, isNot(contains('Random(')));

    final visuals = File(
      'lib/game/match/renderer/match_pitch_visuals.dart',
    ).readAsStringSync();
    final playerVisuals = File(
      'lib/game/match/renderer/match_player_visuals.dart',
    ).readAsStringSync();
    final goalVisuals = File(
      'lib/game/match/renderer/match_goal_visuals.dart',
    ).readAsStringSync();
    final stadiumVisuals = File(
      'lib/game/match/renderer/match_stadium_visuals.dart',
    ).readAsStringSync();
    expect(visuals, contains('drawGoal'));
    expect(visuals, contains('pitchClip'));
    expect(visuals, contains('Rect.fromLTWH('));
    expect(visuals, contains('width - 28'));
    expect(visuals, contains('height - 36'));
    expect(visuals, contains('field.width * .17'));
    expect(visuals, isNot(contains('drawFieldImage(')));
    expect(renderer, contains('field.left + display.x * field.width'));
    expect(playerVisuals, contains('required ClubKit kit'));
    expect(playerVisuals, contains('required double scale'));
    expect(playerVisuals, contains('required double movementAmount'));
    expect(playerVisuals, contains('ClubKitPattern.verticalStripes'));
    expect(renderer, contains('entries.sort'));
    expect(renderer, contains('MatchPitchVisuals.depthScale'));
    expect(renderer, contains('MatchPitchVisuals.interfaceScale'));
    expect(renderer, contains('MatchPlayerLabels.draw'));
    expect(renderer, contains('MatchPitchFormation.points'));
    expect(renderer, contains('MatchPlayerMotion.phaseShape'));
    expect(renderer, contains('_playerNames'));
    expect(renderer, contains('homeGoalkeeperKit'));
    expect(renderer, contains('awayGoalkeeperKit'));
    expect(renderer, contains('_ballVisualHeight'));
    expect(visuals, contains('drawGoalReaction'));
    expect(visuals, contains('drawGoalFrames'));
    expect(goalVisuals, contains('drawForegroundFrame'));
    expect(goalVisuals, contains('drawReaction'));
    expect(goalVisuals, contains('for (var row = 1; row < 8; row++)'));
    expect(visuals, contains('required double heightLift'));
    expect(screen, contains('LiveMatchTimelineBar('));
    expect(playerVisuals, contains('goalkeeperDive'));
    expect(playerVisuals, contains('celebration'));
    expect(stadiumVisuals, contains('_crowd('));
    expect(stadiumVisuals, contains('_floodlights('));
    expect(renderer, isNot(contains('assets/images/match/match_field.webp')));
    expect(renderer, isNot(contains('assets/images/match/stadium_crowd.webp')));
    expect(renderer, isNot(contains('fieldImage')));
  });

  test('câmera aproxima somente lances importantes e replay', () {
    expect(
      MatchPitchCamera.eventZoom(MatchEventType.pass, replay: false),
      1,
    );
    expect(
      MatchPitchCamera.eventZoom(MatchEventType.yellow, replay: false),
      1,
    );
    expect(
      MatchPitchCamera.eventZoom(MatchEventType.shot, replay: false),
      greaterThan(1),
    );
    expect(
      MatchPitchCamera.eventZoom(MatchEventType.pass, replay: true),
      greaterThan(1),
    );
    expect(
      MatchPitchCamera.eventZoom(MatchEventType.penalty, replay: true),
      lessThanOrEqualTo(1.13),
    );
  });
}
