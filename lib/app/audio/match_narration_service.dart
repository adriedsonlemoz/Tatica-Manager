import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';

import '../../core/audio/match_narration_formatter.dart';
import '../../domain/match/match_models.dart';

class MatchNarrationService {
  MatchNarrationService() : _tts = FlutterTts();

  final FlutterTts _tts;
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
    if (!_enabled || _volume <= 0) {
      _speechToken++;
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
  }) async {
    if (!_enabled || _volume <= 0 ||
        !MatchNarrationFormatter.shouldNarrate(event)) {
      return;
    }
    final key = '${event.minute}:${event.sequence}:${event.type.name}';
    if (_lastEventKey == key) return;
    _lastEventKey = key;

    final text = MatchNarrationFormatter.textFor(event, teamName: teamName);
    if (text.isEmpty) return;
    await _speak(text, delay: MatchNarrationFormatter.delayFor(event.type));
  }

  Future<void> speakAnnouncement(
    String text, {
    Duration delay = const Duration(milliseconds: 140),
  }) async {
    if (!_enabled || _volume <= 0 || text.trim().isEmpty) return;
    await _speak(text.trim(), delay: delay);
  }

  Future<void> testVoice() => speakAnnouncement(
        'Narração ativada. Tática Manager pronto para o jogo.',
        delay: Duration.zero,
      );

  Future<void> stop() async {
    _speechToken++;
    await _safe(_tts.stop);
  }

  Future<void> dispose() async {
    await stop();
  }

  Future<void> _speak(String text, {required Duration delay}) async {
    final token = ++_speechToken;
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    if (token != _speechToken || !_enabled || _volume <= 0) return;

    await _ensureInitialized();
    if (token != _speechToken) return;
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

  Future<void> _safe(Future<dynamic> Function() action) async {
    try {
      await action();
    } catch (_) {
      // Narração nunca pode interromper a partida ou a navegação.
    }
  }
}
