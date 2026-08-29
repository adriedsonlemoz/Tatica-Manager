import 'dart:async';

import 'package:flutter/services.dart';

import '../../../domain/club/club.dart';
import '../../../domain/match/match_models.dart';
import 'match_pitch_controller.dart';
import 'match_presentation_director.dart';

/// Presentation-only bridge for the Android libGDX renderer.
///
/// The Match Engine remains in Dart. This class sends only already-produced
/// events, lineup ids, names and visual kit data to the native renderer.
class LibGdxMatchPitchController implements MatchPitchController {
  LibGdxMatchPitchController({
    required this.homeColor,
    required this.awayColor,
    required this.homeKit,
    required this.awayKit,
    required this.homeGoalkeeperKit,
    required this.awayGoalkeeperKit,
    required this.homeClubId,
    required this.awayClubId,
    required List<String> homePlayerIds,
    required List<String> awayPlayerIds,
    required Map<String, String> playerNames,
    this.ballStyle = 0,
    this.onReplayChanged,
    this.onEventStarted,
  })  : _homePlayerIds = [...homePlayerIds],
        _awayPlayerIds = [...awayPlayerIds],
        _playerNames = Map<String, String>.unmodifiable(playerNames);

  static const viewType = 'tatica_manager/libgdx_match_pitch';

  final Color homeColor;
  final Color awayColor;
  final ClubKit homeKit;
  final ClubKit awayKit;
  final ClubKit homeGoalkeeperKit;
  final ClubKit awayGoalkeeperKit;
  final String homeClubId;
  final String awayClubId;
  final int ballStyle;
  final void Function(bool active)? onReplayChanged;
  final void Function(MatchEvent event)? onEventStarted;
  final Map<String, String> _playerNames;

  List<String> _homePlayerIds;
  List<String> _awayPlayerIds;
  final List<MatchPresentationCue> _cueQueue = <MatchPresentationCue>[];
  MatchPresentationCue? _currentCue;
  Timer? _cueTimer;
  MethodChannel? _channel;
  final List<_PendingNativeCall> _pendingNativeCalls = <_PendingNativeCall>[];
  bool _replayActive = false;
  bool _replayPending = false;
  bool _disposed = false;

  Map<String, Object?> get creationParams => <String, Object?>{
        'homeColor': homeColor.toARGB32(),
        'awayColor': awayColor.toARGB32(),
        'homeKit': homeKit.toJson(),
        'awayKit': awayKit.toJson(),
        'homeGoalkeeperKit': homeGoalkeeperKit.toJson(),
        'awayGoalkeeperKit': awayGoalkeeperKit.toJson(),
        'homeClubId': homeClubId,
        'awayClubId': awayClubId,
        'homePlayerIds': _homePlayerIds,
        'awayPlayerIds': _awayPlayerIds,
        'playerNames': _playerNames,
        'ballStyle': ballStyle,
      };

  void attachView(int viewId) {
    if (_disposed) return;
    _channel = MethodChannel('tatica_manager/libgdx_match_pitch/$viewId');
    final pending = List<_PendingNativeCall>.from(_pendingNativeCalls);
    _pendingNativeCalls.clear();
    for (final call in pending) {
      _invoke(call.method, call.arguments);
    }
    _invoke('updateLineups', <String, Object?>{
      'homePlayerIds': _homePlayerIds,
      'awayPlayerIds': _awayPlayerIds,
    });
  }

  @override
  bool get isReplayActive => _replayActive;

  @override
  bool get blocksClock => _replayPending || _replayActive;

  @override
  void playEvent(MatchEvent event) => playEvents(<MatchEvent>[event]);

  @override
  void playEvents(Iterable<MatchEvent> events) {
    if (_disposed) return;
    final list = events.toList();
    if (list.isEmpty) return;
    final cues = MatchPresentationDirector.buildCues(list);
    if (cues.any((cue) => cue.replay)) _replayPending = true;
    _cueQueue.addAll(cues);
    if (_currentCue == null) _beginNextCue();
  }

  void _beginNextCue() {
    _cueTimer?.cancel();
    if (_cueQueue.isEmpty || _disposed) {
      _currentCue = null;
      return;
    }

    final cue = _cueQueue.removeAt(0);
    _currentCue = cue;
    if (cue.startsReplay) _setReplayActive(true);

    final event = cue.event;
    if (event != null && !cue.replay) onEventStarted?.call(event);
    _invoke('playCue', <String, Object?>{
      'duration': cue.duration,
      'replay': cue.replay,
      'startsReplay': cue.startsReplay,
      'endsReplay': cue.endsReplay,
      'event': event == null ? null : _eventPayload(event),
    });

    _cueTimer = Timer(
      Duration(milliseconds: (cue.duration * 1000).round()),
      () {
        if (_disposed) return;
        if (cue.endsReplay) {
          _replayPending = false;
          _setReplayActive(false);
        }
        _currentCue = null;
        _beginNextCue();
      },
    );
  }

  @override
  void updateLineups({
    required List<String> homePlayerIds,
    required List<String> awayPlayerIds,
  }) {
    _homePlayerIds = [...homePlayerIds];
    _awayPlayerIds = [...awayPlayerIds];
    _invoke('updateLineups', <String, Object?>{
      'homePlayerIds': _homePlayerIds,
      'awayPlayerIds': _awayPlayerIds,
    });
  }

  @override
  void skipReplay() {
    if (!_replayPending && !_replayActive) return;
    _cueQueue.removeWhere((cue) => cue.replay);
    _replayPending = false;
    _setReplayActive(false);
    _invoke('skipReplay');
    if (_currentCue?.replay == true) {
      _cueTimer?.cancel();
      _currentCue = null;
      _beginNextCue();
    }
  }

  @override
  void clearPresentationQueue() {
    _cueTimer?.cancel();
    _cueQueue.clear();
    _currentCue = null;
    _replayPending = false;
    _setReplayActive(false);
    _invoke('clearPresentation');
  }

  void _setReplayActive(bool active) {
    if (_replayActive == active) return;
    _replayActive = active;
    onReplayChanged?.call(active);
    _invoke('setReplayActive', active);
  }

  Map<String, Object?> _eventPayload(MatchEvent event) => <String, Object?>{
        'minute': event.minute,
        'sequence': event.sequence,
        'type': event.type.name,
        'teamId': event.teamId,
        'playerId': event.playerId,
        'secondaryPlayerId': event.secondaryPlayerId,
        'assistPlayerId': event.assistPlayerId,
        'start': _pointPayload(event.start),
        'end': _pointPayload(event.end),
      };

  static Map<String, double>? _pointPayload(FieldPoint? point) => point == null
      ? null
      : <String, double>{'x': point.x, 'y': point.y};

  void _invoke(String method, [Object? arguments]) {
    if (_disposed) return;
    final channel = _channel;
    if (channel == null) {
      _pendingNativeCalls.add(_PendingNativeCall(method, arguments));
      return;
    }
    unawaited(channel.invokeMethod<void>(method, arguments).catchError((_) {}));
  }

  @override
  void disposeController() {
    _disposed = true;
    _cueTimer?.cancel();
    _cueQueue.clear();
    _pendingNativeCalls.clear();
    _channel = null;
  }
}

class _PendingNativeCall {
  const _PendingNativeCall(this.method, this.arguments);

  final String method;
  final Object? arguments;
}
