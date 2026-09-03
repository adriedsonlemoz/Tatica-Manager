import 'dart:math' as math;

import '../../../domain/match/match_models.dart';

class MatchPitchCameraState {
  double zoom = 1;
  FieldPoint focus = const FieldPoint(.5, .5);

  double _targetZoom = 1;
  FieldPoint _targetFocus = const FieldPoint(.5, .5);

  void frame(
    MatchEventType? type,
    FieldPoint? point, {
    required bool replay,
  }) {
    _targetZoom = MatchPitchCamera.eventZoom(type, replay: replay);
    final next = point ?? const FieldPoint(.5, .5);
    _targetFocus = FieldPoint(
      next.x.clamp(.10, .90).toDouble(),
      next.y.clamp(.06, .94).toDouble(),
    );
  }

  void release() {
    _targetZoom = 1;
    _targetFocus = const FieldPoint(.5, .5);
  }

  void update(double dt) {
    final speed = _targetZoom > zoom ? 6.0 : 3.8;
    final blend = 1 - math.exp(-dt.clamp(0.0, .12) * speed);
    zoom += (_targetZoom - zoom) * blend;
    focus = FieldPoint(
      focus.x + (_targetFocus.x - focus.x) * blend,
      focus.y + (_targetFocus.y - focus.y) * blend,
    );
    if ((zoom - _targetZoom).abs() < .0005) zoom = _targetZoom;
  }
}

abstract final class MatchPitchCamera {
  static double eventZoom(
    MatchEventType? type, {
    required bool replay,
  }) {
    final liveZoom = switch (type) {
      MatchEventType.shot => 1.075,
      MatchEventType.save || MatchEventType.woodwork => 1.09,
      MatchEventType.goal || MatchEventType.ownGoal => 1.105,
      MatchEventType.penalty || MatchEventType.penaltySaved => 1.12,
      _ => 1.0,
    };
    if (!replay) return liveZoom;
    return math.max(liveZoom, 1.065).clamp(1.0, 1.13).toDouble();
  }
}
