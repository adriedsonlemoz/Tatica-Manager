import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/audio/audio_catalog.dart';
import '../audio/audio_manager.dart';

class AudioInteractionLayer extends StatefulWidget {
  const AudioInteractionLayer({
    super.key,
    required this.audioManager,
    required this.child,
  });

  final AudioManager audioManager;
  final Widget child;

  @override
  State<AudioInteractionLayer> createState() => _AudioInteractionLayerState();
}

class _AudioInteractionLayerState extends State<AudioInteractionLayer> {
  final Map<int, Offset> _pointerStarts = {};
  final Map<int, DateTime> _pointerStartTimes = {};

  @override
  Widget build(BuildContext context) => Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (event) {
          _pointerStarts[event.pointer] = event.position;
          _pointerStartTimes[event.pointer] = DateTime.now();
        },
        onPointerCancel: (event) => _clear(event.pointer),
        onPointerUp: (event) {
          final start = _pointerStarts[event.pointer];
          final startedAt = _pointerStartTimes[event.pointer];
          _clear(event.pointer);
          if (start == null || startedAt == null) return;
          final moved = (event.position - start).distance;
          final elapsed = DateTime.now().difference(startedAt);
          if (moved <= 10 && elapsed <= const Duration(milliseconds: 650)) {
            unawaited(widget.audioManager.playUi(UiAudioCue.tap));
          }
        },
        child: widget.child,
      );

  void _clear(int pointer) {
    _pointerStarts.remove(pointer);
    _pointerStartTimes.remove(pointer);
  }
}

class AudioNavigationObserver extends NavigatorObserver {
  AudioNavigationObserver(this.audioManager);

  final AudioManager audioManager;
  bool _hasPresentedFirstRoute = false;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (!_hasPresentedFirstRoute) {
      _hasPresentedFirstRoute = true;
      return;
    }
    unawaited(audioManager.playUi(UiAudioCue.navigation));
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    unawaited(audioManager.playUi(UiAudioCue.navigation));
  }
}
