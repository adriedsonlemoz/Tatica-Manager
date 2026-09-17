import 'dart:async';

import 'package:just_audio/just_audio.dart';

import '../../core/audio/audio_catalog.dart';
import '../../core/audio/match_narration_formatter.dart';
import '../../domain/match/match_models.dart';

class MatchNarrationService {
  MatchNarrationService() : _voicePlayer = AudioPlayer();

  final AudioPlayer _voicePlayer;
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
      return;
    }
  }

  Future<void> speakEvent(
    MatchEvent event, {
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
    await speakCue(
      cue,
      delay: MatchNarrationFormatter.delayFor(event.type),
    );
  }

  Future<void> speakCue(
    MatchVoiceCue cue, {
    Duration delay = const Duration(milliseconds: 140),
  }) async {
    if (!_enabled || _volume <= 0) return;
    await _playVoice(cue, delay: delay);
  }

  Future<void> testVoice() => speakCue(
        MatchVoiceCue.kickoff,
        delay: Duration.zero,
      );

  Future<void> stop() async {
    _speechToken++;
    await _safe(_voicePlayer.stop);
  }

  Future<void> dispose() async {
    await stop();
    await _safe(_voicePlayer.dispose);
  }

  Future<void> _playVoice(
    MatchVoiceCue cue, {
    required Duration delay,
  }) async {
    final token = ++_speechToken;
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    if (token != _speechToken || !_enabled || _volume <= 0) return;

    final asset = AudioCatalog.voiceAssets[cue];
    if (asset == null) return;

    await _safe(_voicePlayer.stop);
    if (token != _speechToken) return;
    await _safeVoice(() async {
      await _voicePlayer.setAudioSource(AudioSource.asset(asset));
      await _voicePlayer.setVolume(_volume);
      if (token != _speechToken) return;
      await _voicePlayer.play();
    });

    // Intencionalmente não há fallback TTS. Se um asset oficial falhar,
    // o evento fica sem voz em vez de tocar a antiga voz sintética do Android.
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
