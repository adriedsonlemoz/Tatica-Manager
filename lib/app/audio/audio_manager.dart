import 'dart:async';
import 'dart:io';

import 'package:just_audio/just_audio.dart';

import '../../core/audio/audio_catalog.dart';
import '../../core/platform/haptic_feedback_service.dart';
import '../../domain/match/match_models.dart';
import '../../domain/season/career_state.dart';
import 'match_narration_service.dart';

class MenuPlaybackTrack {
  const MenuPlaybackTrack({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.custom,
  });

  final int index;
  final String title;
  final String subtitle;
  final bool custom;

  String get displayName => subtitle.isEmpty ? title : '$subtitle — $title';
}

class MenuPlaybackState {
  const MenuPlaybackState({
    required this.tracks,
    required this.playing,
    required this.usingCustomPlaylist,
    this.currentIndex,
  });

  final List<MenuPlaybackTrack> tracks;
  final bool playing;
  final bool usingCustomPlaylist;
  final int? currentIndex;

  MenuPlaybackTrack? get currentTrack {
    final index = currentIndex;
    if (index == null || index < 0 || index >= tracks.length) return null;
    return tracks[index];
  }
}

class AudioManager {
  AudioManager()
      : _musicPlayer = AudioPlayer(maxSkipsOnError: 8),
        _uiPlayer = AudioPlayer(),
        _matchPlayer = AudioPlayer(),
        _ambiencePlayer = AudioPlayer(),
        _narration = MatchNarrationService() {
    _musicIndexSubscription = _musicPlayer.currentIndexStream.listen((_) {
      _emitMenuPlaybackState();
    });
    _musicStateSubscription = _musicPlayer.playerStateStream.listen((_) {
      _emitMenuPlaybackState();
    });
  }

  final AudioPlayer _musicPlayer;
  final AudioPlayer _uiPlayer;
  final AudioPlayer _matchPlayer;
  final AudioPlayer _ambiencePlayer;
  final MatchNarrationService _narration;
  final StreamController<MenuPlaybackState> _menuPlaybackController =
      StreamController<MenuPlaybackState>.broadcast();
  late final StreamSubscription<int?> _musicIndexSubscription;
  late final StreamSubscription<PlayerState> _musicStateSubscription;

  GameSettings _settings = const GameSettings();
  bool _inMatch = false;
  bool _matchFinished = false;
  bool _menuPlaylistLoaded = false;
  Future<bool>? _menuLoadTask;
  int? _menuLoadGeneration;
  int _playlistGeneration = 0;
  String _playlistSignature = '';
  List<MenuPlaybackTrack> _activeMenuTracks = const [];
  DateTime _lastUiCueAt = DateTime.fromMillisecondsSinceEpoch(0);
  final Map<MatchAudioCue, DateTime> _lastMatchCueAt = {};
  bool _ambienceLoaded = false;
  int _ambienceDuckToken = 0;

  GameSettings get settings => _settings;

  Stream<MenuPlaybackState> get menuPlaybackStream =>
      _menuPlaybackController.stream;

  MenuPlaybackState get menuPlaybackState => _buildMenuPlaybackState();

  Future<void> applySettings(GameSettings settings) async {
    final previousSignature = _desiredPlaylistSignature(settings);
    _settings = settings;

    await _safe(() => _musicPlayer.setVolume(_musicVolume));
    await _safe(() => _uiPlayer.setVolume(_uiVolume));
    await _safe(() => _matchPlayer.setVolume(_matchVolume));
    await _safe(() => _ambiencePlayer.setVolume(_ambienceVolume));
    await _narration.configure(
      enabled: _narrationEnabled,
      volume: _narrationVolume,
    );

    final shouldReloadPlaylist = previousSignature != _playlistSignature;
    if (shouldReloadPlaylist) {
      _menuPlaylistLoaded = false;
      _playlistGeneration++;
      _playlistSignature = previousSignature;
      _activeMenuTracks = const [];
      await _safe(_musicPlayer.stop);
      _emitMenuPlaybackState();
    }

    if (!_masterEnabled || !_settings.audio.musicEnabled || _inMatch) {
      await _safe(_musicPlayer.pause);
      _emitMenuPlaybackState();
      if (_inMatch) await _startMatchAmbience();
      return;
    }
    await startMenuMusic();
  }

  Future<void> startMenuMusic() async {
    if (_inMatch || !_masterEnabled || !_settings.audio.musicEnabled) return;
    while (!_menuPlaylistLoaded) {
      final task = _menuLoadTask ??= _loadMenuPlaylist();
      _menuLoadGeneration ??= _playlistGeneration;
      final taskGeneration = _menuLoadGeneration;
      final loaded = await task;
      if (identical(_menuLoadTask, task)) {
        _menuLoadTask = null;
        _menuLoadGeneration = null;
      }
      if (loaded) break;
      if (taskGeneration == _playlistGeneration) return;
      if (_inMatch || !_masterEnabled || !_settings.audio.musicEnabled) return;
    }
    if (!_musicPlayer.playing) unawaited(_safe(_musicPlayer.play));
    _emitMenuPlaybackState();
  }

  Future<bool> _loadMenuPlaylist() async {
    final generation = _playlistGeneration;
    final entries = _menuEntries();
    if (entries.isEmpty) return false;
    final sources = entries.map((entry) => entry.source).toList(growable: false);
    final loaded = await _safeBool(() async {
      final initialIndex = DateTime.now().millisecondsSinceEpoch % sources.length;
      await _musicPlayer.setAudioSources(
        sources,
        initialIndex: initialIndex,
        initialPosition: Duration.zero,
        shuffleOrder: DefaultShuffleOrder(),
      );
      await _musicPlayer.shuffle();
      await _musicPlayer.setShuffleModeEnabled(true);
      await _musicPlayer.setLoopMode(LoopMode.all);
    });
    if (!loaded || generation != _playlistGeneration) return false;
    _activeMenuTracks = entries
        .asMap()
        .entries
        .map(
          (entry) => MenuPlaybackTrack(
            index: entry.key,
            title: entry.value.title,
            subtitle: entry.value.subtitle,
            custom: entry.value.custom,
          ),
        )
        .toList(growable: false);
    _menuPlaylistLoaded = true;
    _emitMenuPlaybackState();
    return true;
  }

  Future<void> nextMenuTrack() async {
    if (_inMatch || !_masterEnabled || !_settings.audio.musicEnabled) return;
    await startMenuMusic();
    if (!_menuPlaylistLoaded || _activeMenuTracks.length < 2) return;
    await _safe(_musicPlayer.seekToNext);
    if (!_musicPlayer.playing) unawaited(_safe(_musicPlayer.play));
    _emitMenuPlaybackState();
  }

  Future<void> selectMenuTrack(int index) async {
    if (_inMatch || !_masterEnabled || !_settings.audio.musicEnabled) return;
    await startMenuMusic();
    if (!_menuPlaylistLoaded ||
        index < 0 ||
        index >= _activeMenuTracks.length) {
      return;
    }
    await _safe(() => _musicPlayer.seek(Duration.zero, index: index));
    if (!_musicPlayer.playing) unawaited(_safe(_musicPlayer.play));
    _emitMenuPlaybackState();
  }

  Future<void> pauseForLifecycle() async {
    await _safe(_musicPlayer.pause);
    await _safe(_uiPlayer.pause);
    await _safe(_matchPlayer.pause);
    await _safe(_ambiencePlayer.pause);
    await _narration.stop();
    _emitMenuPlaybackState();
  }

  Future<void> resumeAfterLifecycle() async {
    if (_inMatch) {
      await _startMatchAmbience();
    } else {
      await startMenuMusic();
    }
  }

  Future<void> enterMatch({
    required String homeName,
    required String awayName,
  }) async {
    _inMatch = true;
    _matchFinished = false;
    await _safe(_musicPlayer.pause);
    _emitMenuPlaybackState();
    await _startMatchAmbience();
    await playMatchCue(MatchAudioCue.kickoff);
    await _narration.speakAnnouncement(
      'Começa a partida. $homeName contra $awayName.',
      delay: const Duration(milliseconds: 240),
    );
  }

  Future<void> finishMatchPresentation() async {
    if (!_inMatch || _matchFinished) return;
    _matchFinished = true;
    _ambienceDuckToken++;
    await _safe(_ambiencePlayer.stop);
    await _narration.stop();
  }

  Future<void> exitMatch() async {
    _inMatch = false;
    _matchFinished = false;
    _ambienceDuckToken++;
    await _safe(_matchPlayer.stop);
    await _safe(_ambiencePlayer.stop);
    await _narration.stop();
    await startMenuMusic();
  }

  Future<void> playUi(UiAudioCue cue) async {
    unawaited(
      HapticFeedbackService.interfaceTap(enabled: _settings.haptics),
    );
    if (!_masterEnabled || !_settings.audio.interfaceEnabled) return;
    final now = DateTime.now();
    final cooldown = _inMatch
        ? const Duration(milliseconds: 180)
        : const Duration(milliseconds: 90);
    if (cue == UiAudioCue.tap && now.difference(_lastUiCueAt) < cooldown) {
      return;
    }
    _lastUiCueAt = now;
    final asset = AudioCatalog.uiAssets[cue];
    if (asset == null) return;
    await _playOneShot(
      _uiPlayer,
      AudioSource.asset(asset),
      volume: _uiVolume,
    );
  }

  Future<void> presentMatchEvent(
    MatchEvent event, {
    required String teamName,
  }) async {
    unawaited(
      HapticFeedbackService.matchEvent(
        event,
        enabled: _settings.haptics,
      ),
    );
    final cue = AudioCatalog.cueForEvent(event);
    if (cue != null) unawaited(playMatchCue(cue));
    await _narration.speakEvent(event, teamName: teamName);
  }

  Future<void> announceSecondHalf() async {
    unawaited(playMatchCue(MatchAudioCue.secondHalf));
    await _narration.speakAnnouncement('Começa o segundo tempo.');
  }

  Future<void> testNarration() => _narration.testVoice();

  Future<void> playMatchCue(MatchAudioCue cue) async {
    if (!_masterEnabled || !_settings.audio.matchEnabled) return;
    if (_settings.audio.cleanAudio && !AudioCatalog.isCleanMatchCue(cue)) {
      return;
    }
    final now = DateTime.now();
    final previous = _lastMatchCueAt[cue];
    if (previous != null && now.difference(previous) < _matchCueCooldown(cue)) {
      return;
    }
    _lastMatchCueAt[cue] = now;
    unawaited(_duckAmbience(_duckDuration(cue)));
    final custom = _settings.audio.customMatchSounds[cue.name];
    AudioSource? source;
    if (custom != null && custom.isNotEmpty && File(custom).existsSync()) {
      source = AudioSource.file(custom);
    } else {
      final asset = AudioCatalog.matchAssets[cue];
      if (asset != null) source = AudioSource.asset(asset);
    }
    if (source == null) return;
    await _playOneShot(_matchPlayer, source, volume: _matchVolume);
  }

  Future<void> stopAll() async {
    _inMatch = false;
    _matchFinished = false;
    _ambienceDuckToken++;
    await _safe(_musicPlayer.stop);
    await _safe(_uiPlayer.stop);
    await _safe(_matchPlayer.stop);
    await _safe(_ambiencePlayer.stop);
    await _narration.stop();
    _emitMenuPlaybackState();
  }

  Future<void> dispose() async {
    await _musicIndexSubscription.cancel();
    await _musicStateSubscription.cancel();
    await _safe(_musicPlayer.dispose);
    await _safe(_uiPlayer.dispose);
    await _safe(_matchPlayer.dispose);
    await _safe(_ambiencePlayer.dispose);
    await _narration.dispose();
    await _menuPlaybackController.close();
  }

  bool get _masterEnabled => _settings.sound && _settings.audio.masterVolume > 0;
  double get _musicVolume =>
      (!_masterEnabled
          ? 0
          : _settings.audio.masterVolume * _settings.audio.musicVolume)
          .clamp(0.0, 1.0)
          .toDouble();
  double get _uiVolume =>
      (!_masterEnabled
          ? 0
          : _settings.audio.masterVolume * _settings.audio.interfaceVolume)
          .clamp(0.0, 1.0)
          .toDouble();
  double get _matchVolume =>
      (!_masterEnabled
          ? 0
          : _settings.audio.masterVolume * _settings.audio.matchVolume)
          .clamp(0.0, 1.0)
          .toDouble();
  double get _ambienceVolume =>
      (_matchVolume * .18).clamp(0.0, 1.0).toDouble();
  bool get _narrationEnabled =>
      _masterEnabled && _settings.audio.narrationEnabled;
  double get _narrationVolume =>
      (_settings.audio.masterVolume * _settings.audio.narrationVolume)
          .clamp(0.0, 1.0)
          .toDouble();

  List<_MenuEntry> _menuEntries() {
    final customPaths = _settings.audio.customMenuTracks
        .where((path) => path.isNotEmpty && File(path).existsSync())
        .toList(growable: false);
    if (_settings.audio.useCustomMenuMusic && customPaths.isNotEmpty) {
      return customPaths
          .map(
            (path) => _MenuEntry(
              source: AudioSource.file(path),
              title: _customTrackTitle(path),
              subtitle: 'Minha playlist',
              custom: true,
            ),
          )
          .toList(growable: false);
    }
    return AudioCatalog.menuTracks
        .map(
          (track) => _MenuEntry(
            source: AudioSource.asset(track.asset),
            title: track.title,
            subtitle: track.artist,
            custom: false,
          ),
        )
        .toList(growable: false);
  }

  MenuPlaybackState _buildMenuPlaybackState() {
    final tracks = _activeMenuTracks.isNotEmpty
        ? _activeMenuTracks
        : _menuEntries()
            .asMap()
            .entries
            .map(
              (entry) => MenuPlaybackTrack(
                index: entry.key,
                title: entry.value.title,
                subtitle: entry.value.subtitle,
                custom: entry.value.custom,
              ),
            )
            .toList(growable: false);
    return MenuPlaybackState(
      tracks: tracks,
      currentIndex: _musicPlayer.currentIndex,
      playing: _musicPlayer.playing && !_inMatch,
      usingCustomPlaylist: tracks.isNotEmpty && tracks.every((track) => track.custom),
    );
  }

  void _emitMenuPlaybackState() {
    if (_menuPlaybackController.isClosed) return;
    _menuPlaybackController.add(_buildMenuPlaybackState());
  }

  static String _customTrackTitle(String path) {
    final normalized = path.replaceAll('\\', '/');
    final fileName = normalized.split('/').last;
    final dot = fileName.lastIndexOf('.');
    final base = dot > 0 ? fileName.substring(0, dot) : fileName;
    final readable = base.replaceAll(RegExp(r'[_-]+'), ' ').trim();
    return readable.isEmpty ? 'Faixa personalizada' : readable;
  }

  static String _desiredPlaylistSignature(GameSettings settings) {
    final audio = settings.audio;
    final custom = audio.customMenuTracks.join('|');
    return '${audio.useCustomMenuMusic}:$custom';
  }

  static Duration _matchCueCooldown(MatchAudioCue cue) => switch (cue) {
        MatchAudioCue.goal ||
        MatchAudioCue.halftime ||
        MatchAudioCue.fulltime => const Duration(milliseconds: 900),
        MatchAudioCue.shot ||
        MatchAudioCue.save ||
        MatchAudioCue.woodwork ||
        MatchAudioCue.penalty ||
        MatchAudioCue.penaltySaved => const Duration(milliseconds: 560),
        MatchAudioCue.yellowCard ||
        MatchAudioCue.redCard ||
        MatchAudioCue.substitution ||
        MatchAudioCue.injury => const Duration(milliseconds: 650),
        _ => const Duration(milliseconds: 320),
      };

  static Duration _duckDuration(MatchAudioCue cue) => switch (cue) {
        MatchAudioCue.goal ||
        MatchAudioCue.halftime ||
        MatchAudioCue.fulltime ||
        MatchAudioCue.redCard ||
        MatchAudioCue.penalty ||
        MatchAudioCue.penaltySaved => const Duration(milliseconds: 1450),
        _ => const Duration(milliseconds: 850),
      };

  Future<void> _startMatchAmbience() async {
    if (!_inMatch ||
        _matchFinished ||
        !_masterEnabled ||
        !_settings.audio.matchEnabled) {
      await _safe(_ambiencePlayer.pause);
      return;
    }
    if (!_ambienceLoaded) {
      final loaded = await _safeBool(() async {
        await _ambiencePlayer.setAudioSource(
          AudioSource.asset(AudioCatalog.matchAmbienceAsset),
        );
        await _ambiencePlayer.setLoopMode(LoopMode.one);
      });
      if (!loaded) return;
      _ambienceLoaded = true;
    }
    await _safe(() => _ambiencePlayer.setVolume(_ambienceVolume));
    if (!_ambiencePlayer.playing) {
      unawaited(_safe(_ambiencePlayer.play));
    }
  }

  Future<void> _duckAmbience(Duration duration) async {
    if (!_ambiencePlayer.playing || _ambienceVolume <= 0) return;
    final token = ++_ambienceDuckToken;
    await _safe(() => _ambiencePlayer.setVolume(_ambienceVolume * .28));
    await Future<void>.delayed(duration);
    if (token != _ambienceDuckToken || !_inMatch) return;
    await _safe(() => _ambiencePlayer.setVolume(_ambienceVolume));
  }

  Future<void> _playOneShot(
    AudioPlayer player,
    AudioSource source, {
    required double volume,
  }) async {
    await _safe(() async {
      await player.stop();
      await player.setVolume(volume);
      await player.setAudioSource(source);
      unawaited(_safe(player.play));
    });
  }

  static Future<void> _safe(Future<void> Function() operation) async {
    try {
      await operation();
    } catch (_) {
      // Áudio nunca deve impedir navegação, save ou a partida de continuar.
    }
  }

  static Future<bool> _safeBool(Future<void> Function() operation) async {
    try {
      await operation();
      return true;
    } catch (_) {
      return false;
    }
  }
}

class _MenuEntry {
  const _MenuEntry({
    required this.source,
    required this.title,
    required this.subtitle,
    required this.custom,
  });

  final AudioSource source;
  final String title;
  final String subtitle;
  final bool custom;
}
