import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/audio/audio_catalog.dart';
import '../../core/audio/match_narration_formatter.dart';
import '../../domain/match/match_models.dart';

class MatchNarrationService {
  MatchNarrationService()
      : _tts = FlutterTts(),
        _voicePlayer = AudioPlayer();

  final FlutterTts _tts;
  final AudioPlayer _voicePlayer;
  bool _initialized = false;
  bool _enabled = true;
  double _volume = .72;
  int _speechToken = 0;
  String? _lastEventKey;

  Future<void> configure({
    required bool enabled,
    required double volume,
  }) async {
    _enabled = enabled;
    _volume = volume.clamp(0.0, 1.0).toDouble();
    await _safe(() => _voicePlayer.setVolume(_volume));
    if (!_enabled || _volume <= 0) {
      _speechToken++;
      await _safe(_voicePlayer.stop);
      await _safe(_tts.stop);
      return;
    }
    if (_initialized) {
      await _safe(() => _tts.setVolume(_volume));
    }
  }

  Future<void> speakEvent(
    MatchEvent event, {
    required String teamName,
    bool? isHomeTeam,
  }) async {
    if (!_enabled ||
        _volume <= 0 ||
        !MatchNarrationFormatter.shouldNarrate(event)) {
      return;
    }
    final key = '${event.minute}:${event.sequence}:${event.type.name}';
    if (_lastEventKey == key) return;
    _lastEventKey = key;

    final cue = AudioCatalog.voiceCueForEvent(
      event,
      isHomeTeam: isHomeTeam,
    );
    if (cue == null) return;
    final text = MatchNarrationFormatter.textFor(event, teamName: teamName);
    await speakCue(
      cue,
      fallbackText: text,
      delay: MatchNarrationFormatter.delayFor(event.type),
    );
  }

  Future<void> speakCue(
    MatchVoiceCue cue, {
    required String fallbackText,
    Duration delay = const Duration(milliseconds: 140),
  }) async {
    if (!_enabled || _volume <= 0) return;
    await _playVoice(cue, fallbackText: fallbackText, delay: delay);
  }

  Future<void> speakAnnouncement(
    String text, {
    Duration delay = const Duration(milliseconds: 140),
  }) async {
    if (!_enabled || _volume <= 0 || text.trim().isEmpty) return;
    await _speakTts(text.trim(), delay: delay);
  }

  Future<void> testVoice() => speakCue(
        MatchVoiceCue.kickoff,
        fallbackText: 'Começa o jogo!',
        delay: Duration.zero,
      );

  Future<void> stop() async {
    _speechToken++;
    await _safe(_voicePlayer.stop);
    await _safe(_tts.stop);
  }

  Future<void> dispose() async {
    await stop();
    await _safe(_voicePlayer.dispose);
  }

  Future<void> _playVoice(
    MatchVoiceCue cue, {
    required String fallbackText,
    required Duration delay,
  }) async {
    final token = ++_speechToken;
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    if (token != _speechToken || !_enabled || _volume <= 0) return;

    final asset = AudioCatalog.voiceAssets[cue];
    if (asset != null) {
      await _safe(_voicePlayer.stop);
      if (token != _speechToken) return;
      final played = await _safeVoice(() async {
        await _voicePlayer.setAudioSource(AudioSource.asset(asset));
        await _voicePlayer.setVolume(_volume);
        if (token != _speechToken) return;
        await _voicePlayer.play();
      });
      if (played || token != _speechToken) return;
    }

    if (fallbackText.trim().isNotEmpty) {
      await _speakTtsWithToken(fallbackText.trim(), token);
    }
  }

  Future<void> _speakTts(String text, {required Duration delay}) async {
    final token = ++_speechToken;
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    if (token != _speechToken || !_enabled || _volume <= 0) return;
    await _speakTtsWithToken(text, token);
  }

  Future<void> _speakTtsWithToken(String text, int token) async {
    await _ensureInitialized();
    if (token != _speechToken || !_enabled || _volume <= 0) return;
    await _safe(_tts.stop);
    await _safe(() => _tts.setVolume(_volume));
    await _safe(() => _tts.speak(text, focus: false));
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;
    await _safe(() => _tts.setLanguage('pt-BR'));
    await _safe(() => _tts.setSpeechRate(.46));
    await _safe(() => _tts.setPitch(1.0));
    await _safe(() => _tts.setVolume(_volume));
  }

  Future<bool> _safeVoice(Future<void> Function() action) async {
    try {
      await action();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _safe(Future<dynamic> Function() action) async {
    try {
      await action();
    } catch (_) {
      // Narração nunca pode interromper a partida ou a navegação.
    }
  }
}
