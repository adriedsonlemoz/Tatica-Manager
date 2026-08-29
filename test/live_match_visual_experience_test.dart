import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/domain/match/match_models.dart';
import 'package:tatica_manager/features/match/match_event_presentation.dart';
import 'package:tatica_manager/game/match/renderer/match_pitch_game.dart';
import 'package:tatica_manager/game/match/renderer/match_pitch_visuals.dart';

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

  test('campo ao vivo restaura a geometria visual da 0.1.1.91', () {
    final field = MatchPitchVisuals.fieldRect(1000, 400);
    final clip = MatchPitchVisuals.pitchClip(1000, 400);

    expect(field.left, 14);
    expect(field.top, 18);
    expect(field.right, 986);
    expect(field.bottom, 382);
    expect(clip.outerRect, field);
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
    expect(renderer, isNot(contains('_applyCamera(')));
    expect(renderer, isNot(contains('canvas.translate(')));
    expect(renderer, isNot(contains('canvas.scale(')));
    expect(renderer, isNot(contains('MatchEngine')));
    expect(renderer, isNot(contains('Random(')));

    final visuals = File(
      'lib/game/match/renderer/match_pitch_visuals.dart',
    ).readAsStringSync();
    final playerVisuals = File(
      'lib/game/match/renderer/match_player_visuals.dart',
    ).readAsStringSync();
    final stadiumVisuals = File(
      'lib/game/match/renderer/match_stadium_visuals.dart',
    ).readAsStringSync();
    expect(visuals, contains('drawGoal'));
    expect(visuals, contains('pitchClip'));
    expect(visuals, contains('Rect.fromLTWH('));
    expect(visuals, contains('width - 28'));
    expect(visuals, contains('height - 36'));
    expect(visuals, contains('field.width * .16'));
    expect(visuals, isNot(contains('drawFieldImage(')));
    expect(renderer, contains('field.left + display.x * field.width'));
    expect(playerVisuals, contains('required Color color'));
    expect(screen, contains('LiveMatchTimelineBar('));
    expect(playerVisuals, contains('goalkeeperDive'));
    expect(playerVisuals, contains('celebration'));
    expect(stadiumVisuals, contains('_crowd('));
    expect(stadiumVisuals, contains('_floodlights('));
    expect(renderer, isNot(contains('assets/images/match/match_field.webp')));
    expect(renderer, isNot(contains('assets/images/match/stadium_crowd.webp')));
    expect(renderer, isNot(contains('fieldImage')));
  });
}
