import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/core/audio/audio_catalog.dart';
import 'package:tatica_manager/core/audio/match_narration_formatter.dart';
import 'package:tatica_manager/domain/match/match_models.dart';
import 'package:tatica_manager/domain/season/career_state.dart';
import 'package:tatica_manager/domain/settings/audio_settings.dart';

void main() {
  test('save legado mantém chave sound e recebe preferências de áudio padrão', () {
    final settings = GameSettings.fromJson({
      'haptics': false,
      'sound': false,
      'matchSpeed': 4,
    });

    expect(settings.haptics, isFalse);
    expect(settings.sound, isFalse);
    expect(settings.matchSpeed, 4);
    expect(settings.audio.musicEnabled, isTrue);
    expect(settings.audio.interfaceEnabled, isTrue);
    expect(settings.audio.matchEnabled, isTrue);
    expect(settings.audio.cleanAudio, isTrue);
    expect(settings.audio.narrationEnabled, isFalse);
    expect(settings.audio.musicVolume, closeTo(.12, .001));
  });

  test('preferências de áudio personalizadas sobrevivem à serialização', () {
    const original = GameSettings(
      sound: true,
      audio: AudioSettings(
        musicEnabled: false,
        cleanAudio: false,
        masterVolume: .61,
        matchVolume: .72,
        narrationEnabled: false,
        narrationVolume: .58,
        useCustomMenuMusic: true,
        customMenuTracks: ['/private/song.m4a'],
        customMatchSounds: {'goal': '/private/goal.wav'},
      ),
    );

    final restored = GameSettings.fromJson(original.toJson());

    expect(restored.sound, isTrue);
    expect(restored.audio.musicEnabled, isFalse);
    expect(restored.audio.cleanAudio, isFalse);
    expect(restored.audio.masterVolume, closeTo(.61, .001));
    expect(restored.audio.matchVolume, closeTo(.72, .001));
    expect(restored.audio.narrationEnabled, isFalse);
    expect(restored.audio.narrationVolume, closeTo(.58, .001));
    expect(restored.audio.useCustomMenuMusic, isTrue);
    expect(restored.audio.customMenuTracks, ['/private/song.m4a']);
    expect(restored.audio.customMatchSounds['goal'], '/private/goal.wav');
  });

  test('eventos da partida resolvem para efeitos sem alterar o Match Engine', () {
    MatchEvent event(MatchEventType type) => MatchEvent(
          minute: 10,
          sequence: 1,
          type: type,
          teamId: 'club-a',
          text: type.label,
        );

    expect(AudioCatalog.cueForEvent(event(MatchEventType.goal)), MatchAudioCue.goal);
    expect(AudioCatalog.cueForEvent(event(MatchEventType.yellow)), MatchAudioCue.yellowCard);
    expect(AudioCatalog.cueForEvent(event(MatchEventType.red)), MatchAudioCue.redCard);
    expect(AudioCatalog.cueForEvent(event(MatchEventType.woodwork)), MatchAudioCue.woodwork);
    expect(
      AudioCatalog.cueForEvent(event(MatchEventType.pass)),
      MatchAudioCue.pass,
    );
    expect(AudioCatalog.cueForEvent(event(MatchEventType.possession)), isNull);
  });

  test('catálogo padrão usa somente as 11 novas músicas OGG', () {
    expect(AudioCatalog.menuTracks, hasLength(11));
    expect(AudioCatalog.menuAssets, hasLength(11));
    expect(
      AudioCatalog.menuTracks.map((track) => track.displayName),
      containsAll([
        "Ash O'Connor — Vibe",
        'Electro-Light — Symbolism',
        "Lensko — Let's Go",
        'Jim Yosef — Lights',
        'DEAF KEV — Invincible',
      ]),
    );
    for (final path in AudioCatalog.menuAssets) {
      expect(path, endsWith('.ogg'));
      expect(File(path).existsSync(), isTrue, reason: path);
    }
    expect(File('assets/audio/menu/football.mp3').existsSync(), isFalse);
    for (var index = 1; index <= 5; index++) {
      final suffix = index.toString().padLeft(2, '0');
      expect(File('assets/audio/menu/menu_$suffix.m4a').existsSync(), isFalse);
    }
    for (final path in AudioCatalog.uiAssets.values) {
      expect(File(path).existsSync(), isTrue, reason: path);
    }
    for (final path in AudioCatalog.matchAssets.values) {
      expect(File(path).existsSync(), isTrue, reason: path);
    }
    expect(
      File(AudioCatalog.matchAmbienceAsset).existsSync(),
      isTrue,
      reason: AudioCatalog.matchAmbienceAsset,
    );
    expect(
      AudioCatalog.uiAssets[UiAudioCue.navigation],
      'assets/audio/ui/navigation.mp3',
    );
    expect(
      AudioCatalog.uiAssets[UiAudioCue.tap],
      'assets/audio/ui/navigation.mp3',
    );
  });


  test('player de menu expõe faixa atual, seleção e próxima música', () {
    final manager = File('lib/app/audio/audio_manager.dart').readAsStringSync();
    final player =
        File('lib/features/settings/menu_music_player_card.dart').readAsStringSync();
    final settings =
        File('lib/features/settings/audio_settings_screen.dart').readAsStringSync();

    expect(manager, contains('Stream<MenuPlaybackState> get menuPlaybackStream'));
    expect(manager, contains('Future<void> nextMenuTrack()'));
    expect(manager, contains('Future<void> selectMenuTrack(int index)'));
    expect(manager, contains('_musicPlayer.seekToNext'));
    expect(manager, contains('_musicPlayer.seek(Duration.zero, index: index)'));
    expect(player, contains('TOCANDO AGORA'));
    expect(player, contains('Selecionar música'));
    expect(player, contains('Próxima música'));
    expect(settings, contains('MenuMusicPlayerCard('));
  });

  test('gerador de efeitos não recria a playlist antiga', () {
    final generator = File('tool/generate_audio_assets.py').readAsStringSync();
    expect(generator, isNot(contains('menu_{idx:02d}.m4a')));
    expect(generator, isNot(contains('5 original menu loops')));
  });

  test('duração, velocidade legada e bola recebem defaults retrocompatíveis', () {
    final legacy = GameSettings.fromJson(const {});
    expect(legacy.matchSpeed, 1);
    expect(legacy.matchBallStyle, 0);
    expect(legacy.matchDurationMinutes, 2);

    final restored = GameSettings.fromJson(
      const GameSettings(
        matchSpeed: 4,
        matchBallStyle: 3,
        matchDurationMinutes: 3,
      ).toJson(),
    );
    expect(restored.matchSpeed, 4);
    expect(restored.matchBallStyle, 3);
    expect(restored.matchDurationMinutes, 3);

    final legacyQuick = GameSettings.fromJson({'matchDurationMinutes': 4});
    final legacyNormal = GameSettings.fromJson({'matchDurationMinutes': 6});
    final legacyComplete = GameSettings.fromJson({'matchDurationMinutes': 8});
    expect(legacyQuick.matchDurationMinutes, 1);
    expect(legacyNormal.matchDurationMinutes, 2);
    expect(legacyComplete.matchDurationMinutes, 3);
  });
  test('dependências e assets de áudio permanecem declarados no pubspec', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();

    expect(pubspec, contains('just_audio: ^0.10.6'));
    expect(pubspec, contains('flutter_tts: ^4.2.5'));
    expect(pubspec, contains('path_provider: ^2.1.6'));
    expect(pubspec, contains('assets/audio/menu/'));
    expect(pubspec, contains('assets/audio/match/'));
    expect(pubspec, contains('assets/audio/ui/'));
  });

  test('narração falada ignora posse/passe e prioriza eventos importantes', () {
    const goal = MatchEvent(
      minute: 67,
      sequence: 4,
      type: MatchEventType.goal,
      teamId: 'club-a',
      text: 'GOL! João marca para Aurora FC.',
    );
    const pass = MatchEvent(
      minute: 68,
      sequence: 5,
      type: MatchEventType.pass,
      teamId: 'club-a',
      text: 'João toca para Pedro.',
    );

    expect(MatchNarrationFormatter.shouldNarrate(goal), isTrue);
    expect(MatchNarrationFormatter.shouldNarrate(pass), isFalse);
    expect(
      MatchNarrationFormatter.textFor(goal, teamName: 'Aurora FC'),
      contains('Aos 67 minutos.'),
    );
  });

  test('Android declara descoberta do serviço TTS', () {
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    expect(manifest, contains('android.intent.action.TTS_SERVICE'));
  });

  test('Match Engine permanece independente da camada de áudio', () {
    final engineDir = Directory('lib/game/match/engine');
    final dartFiles = engineDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    for (final file in dartFiles) {
      final source = file.readAsStringSync();
      expect(source, isNot(contains('core/audio/')), reason: file.path);
      expect(source, isNot(contains('just_audio')), reason: file.path);
      expect(source, isNot(contains('flutter_tts')), reason: file.path);
    }
  });

  test('importação múltipla de músicas usa stream sequencial e arquivo temporário', () {
    final source = File('lib/core/audio/audio_file_store.dart').readAsStringSync();
    expect(source, contains('for (final file in files)'));
    expect(source, contains('await for (final chunk in source.openRead())'));
    expect(source, contains('sink.add(chunk)'));
    expect(source, contains('await sink.flush()'));
    expect(source, isNot(contains('.pipe(sink)')));
    expect(source, contains('.part'));
    expect(source, isNot(contains('readAsBytes')));
  });

  test('tela de áudio não consulta ref durante dispose', () {
    final source = File('lib/features/settings/audio_settings_screen.dart').readAsStringSync();
    final disposeStart = source.indexOf('void dispose()');
    final disposeEnd = source.indexOf('@override', disposeStart + 1);
    final disposeBody = source.substring(disposeStart, disposeEnd);
    expect(disposeBody, contains('_gameController.updateSettings(_settings)'));
    expect(disposeBody, isNot(contains('ref.read')));
    expect(disposeBody, isNot(contains('ref.watch')));
  });

  test('feedback tátil fica restrito a gol e respeita configuração', () {
    final source = File('lib/core/platform/haptic_feedback_service.dart')
        .readAsStringSync();
    expect(source, contains('MatchEventType.goal'));
    expect(source, contains('MatchEventType.ownGoal'));
    expect(source, contains('if (!enabled) return'));
    expect(source, contains('HapticFeedback.mediumImpact'));
    expect(source, isNot(contains('selectionClick')));
    expect(source, isNot(contains('lightImpact')));
    expect(source, isNot(contains('heavyImpact')));
  });

  test('música é preparada cedo e carga da playlist é serializada', () {
    final app = File('lib/app/tatica_manager_app.dart').readAsStringSync();
    final manager = File('lib/app/audio/audio_manager.dart').readAsStringSync();
    expect(app, contains('unawaited(_primeAudio())'));
    expect(app, contains('loadLastActiveCareerId'));
    expect(manager, contains('Future<bool>? _menuLoadTask'));
    expect(manager, contains('while (!_menuPlaylistLoaded)'));
    expect(manager, contains('_loadMenuPlaylist()'));
    expect(manager, contains('AudioPlayer(maxSkipsOnError: 8)'));
  });

  test('fim da partida encerra ambiente e efeitos sem usar ref no dispose', () {
    final manager = File('lib/app/audio/audio_manager.dart').readAsStringSync();
    final match = File('lib/features/match/match_screen.dart').readAsStringSync();
    final disposeStart = match.indexOf('void dispose()');
    final disposeEnd = match.indexOf('@override', disposeStart + 1);
    final disposeBody = match.substring(disposeStart, disposeEnd);

    expect(manager, contains('Future<void> finishMatchPresentation()'));
    expect(manager, contains('await _safe(_matchPlayer.stop)'));
    expect(manager, contains('await _safe(_ambiencePlayer.stop)'));
    expect(manager, contains('_matchFinished'));
    expect(match, contains('late final AudioManager _audioManager'));
    expect(match, contains('_audioManager.finishMatchPresentation()'));
    expect(match, contains('await _leaveMatchAudio()'));
    expect(disposeBody, isNot(contains('ref.read')));
  });

}
