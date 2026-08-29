import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('libGDX substitui apenas o renderer Android da partida', () {
    final screen = File('lib/features/match/match_screen.dart').readAsStringSync();
    final panel = File(
      'lib/features/match/widgets/live_match_pitch_panel.dart',
    ).readAsStringSync();
    final controller = File(
      'lib/game/match/renderer/libgdx_match_pitch_controller.dart',
    ).readAsStringSync();
    final nativeRenderer = File(
      'android/app/src/main/kotlin/com/taticamanager/tatica_manager/matchgdx/'
      'LibGdxMatchRenderer.kt',
    ).readAsStringSync();

    expect(
      screen,
      contains('defaultTargetPlatform == TargetPlatform.android'),
    );
    expect(screen, contains('LibGdxMatchPitchController('));
    expect(screen, contains('MatchPitchGame('));
    expect(panel, contains('LibGdxMatchPitchView('));
    expect(panel, contains('GameWidget(game: renderer)'));
    expect(controller, contains('MatchPresentationDirector.buildCues'));
    expect(
      controller,
      contains("'event': event == null ? null : _eventPayload(event)"),
    );
    expect(controller, isNot(contains('MatchEngine')));
    expect(nativeRenderer, isNot(contains('MatchEngine')));
    expect(nativeRenderer, isNot(contains('Random(')));
  });

  test('SurfaceView do libGDX fica preso ao retângulo Flutter', () {
    final activity = File(
      'android/app/src/main/kotlin/com/taticamanager/tatica_manager/MainActivity.kt',
    ).readAsStringSync();
    final view = File(
      'lib/features/match/widgets/libgdx_match_pitch_view.dart',
    ).readAsStringSync();
    final panel = File(
      'lib/features/match/widgets/live_match_pitch_panel.dart',
    ).readAsStringSync();
    final fragment = File(
      'android/app/src/main/kotlin/com/taticamanager/tatica_manager/matchgdx/'
      'LibGdxMatchPitchFragment.kt',
    ).readAsStringSync();
    final platformView = File(
      'android/app/src/main/kotlin/com/taticamanager/tatica_manager/matchgdx/'
      'LibGdxMatchPitchPlatformView.kt',
    ).readAsStringSync();
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();

    expect(view, contains('PlatformViewLink('));
    expect(view, contains('AndroidViewSurface('));
    expect(view, contains('PlatformViewsService.initExpensiveAndroidView('));
    expect(view, isNot(contains('PlatformViewsService.initSurfaceAndroidView(')));
    expect(view, contains('ClipRect('));
    expect(panel, contains('final height = width / pitchAspectRatio;'));
    expect(panel, contains('SizedBox('));
    expect(panel, contains('clipBehavior: Clip.hardEdge'));
    expect(activity, contains('FlutterFragmentActivity()'));
    expect(activity, contains('AndroidFragmentApplication.Callbacks'));
    expect(activity, contains('registerViewFactory('));
    expect(fragment, contains('AndroidFragmentApplication()'));
    expect(fragment, contains('initializeForView(game, config)'));
    expect(fragment, contains('ViewGroup.LayoutParams.MATCH_PARENT'));
    expect(fragment, contains('clipChildren = true'));
    expect(platformView, contains('clipChildren = true'));
    expect(platformView, contains('clipToPadding = true'));
    expect(fragment, contains('useGL30 = false'));
    expect(gradle, contains('gdxVersion = "1.14.2"'));
    expect(gradle, contains('gdx-backend-android'));
    expect(gradle, contains('natives-arm64-v8a'));
    expect(gradle, contains('natives-armeabi-v7a'));
    expect(gradle, contains('natives-x86_64'));
    expect(
      gradle,
      contains('variant.sources.jniLibs?.addGeneratedSourceDirectory('),
    );
    expect(gradle, contains('ExtractGdxNativesTask::outputDirectory'));
    expect(gradle, isNot(contains('jniLibs.srcDir(generatedGdxNatives)')));
    expect(gradle, isNot(contains('android.sourceset.disallowProvider=false')));
  });

  test('renderer usa viewport estável e nomes legíveis sem tocar no motor', () {
    final renderer = File(
      'android/app/src/main/kotlin/com/taticamanager/tatica_manager/matchgdx/'
      'LibGdxMatchRenderer.kt',
    ).readAsStringSync();
    final painter = File(
      'android/app/src/main/kotlin/com/taticamanager/tatica_manager/matchgdx/'
      'LibGdxPitchPainter.kt',
    ).readAsStringSync();
    final labels = File(
      'android/app/src/main/kotlin/com/taticamanager/tatica_manager/matchgdx/'
      'LibGdxPlayerLabelPainter.kt',
    ).readAsStringSync();
    final geometry = File(
      'android/app/src/main/kotlin/com/taticamanager/tatica_manager/matchgdx/'
      'LibGdxMatchVisualModels.kt',
    ).readAsStringSync();

    expect(renderer, contains('FitViewport('));
    expect(renderer, contains('viewport.update(width, height, true)'));
    expect(renderer, contains('viewport.apply(true)'));
    expect(renderer, contains('GdxPitchGeometry.WORLD_WIDTH'));
    expect(geometry, contains('const val WORLD_WIDTH = 1050f'));
    expect(geometry, contains('const val WORLD_HEIGHT = 680f'));
    expect(painter, contains('drawGoals('));
    expect(painter, contains('homeGoalkeeperKit'));
    expect(painter, contains('GdxPitchGeometry.PLAYER_RADIUS'));
    expect(
      RegExp(r'crowdPulse: Float').allMatches(painter).length,
      greaterThanOrEqualTo(3),
    );
    expect(painter, contains('crowdPulse = crowdPulse'));
    expect(labels, contains('buildPlacements('));
    expect(labels, contains('placementAnchors'));
    expect(labels, contains('val preferred = placementAnchors[id]'));
    expect(labels, contains('supportedName(compactName(raw, active))'));
    expect(labels, contains('Normalizer.normalize'));
    expect(renderer, isNot(contains('MatchEngine')));
    expect(painter, isNot(contains('MatchEngine')));
    expect(labels, isNot(contains('MatchEngine')));
  });

  test('movimento do Work foi portado para o renderer libGDX', () {
    final renderer = File(
      'android/app/src/main/kotlin/com/taticamanager/tatica_manager/matchgdx/'
      'LibGdxMatchRenderer.kt',
    ).readAsStringSync();
    final motion = File(
      'android/app/src/main/kotlin/com/taticamanager/tatica_manager/matchgdx/'
      'LibGdxPlayerMotion.kt',
    ).readAsStringSync();
    final painter = File(
      'android/app/src/main/kotlin/com/taticamanager/tatica_manager/matchgdx/'
      'LibGdxPitchPainter.kt',
    ).readAsStringSync();
    final models = File(
      'android/app/src/main/kotlin/com/taticamanager/tatica_manager/matchgdx/'
      'LibGdxMatchVisualModels.kt',
    ).readAsStringSync();

    expect(renderer, contains('LibGdxPlayerMotion.moveTeam'));
    expect(renderer, contains('preparePenaltyTransitions'));
    expect(renderer, contains('prepareFormationReturn'));
    expect(renderer, contains('eventUsesStartPosition'));
    expect(renderer, contains('celebrationRun'));
    expect(motion, contains('delayRemaining'));
    expect(motion, contains('curveStrength'));
    expect(motion, contains('desiredSpeed'));
    expect(motion, contains('acceleration'));
    expect(motion, contains('deceleration'));
    expect(motion, contains('penaltySetup'));
    expect(motion, contains('insidePenaltyApproach'));
    expect(models, contains('GdxPlayerMotionState'));
    expect(models, contains('movementAmount'));
    expect(models, contains('displayDirection'));
    expect(painter, contains('val run = motion.movementAmount'));
    expect(painter, contains('val gait = MathUtils.sin'));
    expect(painter, contains('val lean = motion.displayDirection'));
    expect(motion, isNot(contains('Random(')));
    expect(motion, isNot(contains('MatchEngine')));
    expect(renderer, isNot(contains('MatchEngine')));
  });
}
