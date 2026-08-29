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
    expect(controller, contains("'event': event == null ? null : _eventPayload(event)"));
    expect(controller, isNot(contains('MatchEngine')));
    expect(nativeRenderer, isNot(contains('MatchEngine')));
    expect(nativeRenderer, isNot(contains('Random(')));
  });

  test('Android hospeda libGDX como fragmento dentro do PlatformView', () {
    final activity = File(
      'android/app/src/main/kotlin/com/taticamanager/tatica_manager/MainActivity.kt',
    ).readAsStringSync();
    final view = File(
      'lib/features/match/widgets/libgdx_match_pitch_view.dart',
    ).readAsStringSync();
    final fragment = File(
      'android/app/src/main/kotlin/com/taticamanager/tatica_manager/matchgdx/'
      'LibGdxMatchPitchFragment.kt',
    ).readAsStringSync();
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();

    expect(view, contains('PlatformViewLink('));
    expect(view, contains('AndroidViewSurface('));
    expect(view, contains('PlatformViewsService.initSurfaceAndroidView('));
    expect(activity, contains('FlutterFragmentActivity()'));
    expect(activity, contains('AndroidFragmentApplication.Callbacks'));
    expect(activity, contains('registerViewFactory('));
    expect(fragment, contains('AndroidFragmentApplication()'));
    expect(fragment, contains('initializeForView(game, config)'));
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
}
