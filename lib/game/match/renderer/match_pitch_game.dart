import 'dart:math';
import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flutter/services.dart';

import '../../../domain/club/club.dart';
import '../../../domain/match/match_models.dart';
import 'match_pitch_moment_state.dart';
import 'match_pitch_visuals.dart';
import 'match_player_motion.dart';
import 'match_player_visuals.dart';
import 'match_presentation_director.dart';
import 'match_stadium_visuals.dart';

class MatchPitchGame extends FlameGame {
  MatchPitchGame({
    required this.homeColor,
    required this.awayColor,
    required this.homeKit,
    required this.awayKit,
    required this.homeClubId,
    required this.awayClubId,
    required List<String> homePlayerIds,
    required List<String> awayPlayerIds,
    this.ballStyle = 0,
    this.onReplayChanged,
    this.onEventStarted,
  })  : _homePlayerIds = [...homePlayerIds],
        _awayPlayerIds = [...awayPlayerIds],
        _homePlayers = _homeBase.map(_copyPoint).toList(),
        _awayPlayers = _awayBase.map(_copyPoint).toList(),
        _homeTargets = _homeBase.map(_copyPoint).toList(),
        _awayTargets = _awayBase.map(_copyPoint).toList();

  final Color homeColor;
  final Color awayColor;
  final ClubKit homeKit;
  final ClubKit awayKit;
  final String homeClubId;
  final String awayClubId;
  final int ballStyle;
  final void Function(bool active)? onReplayChanged;
  final void Function(MatchEvent event)? onEventStarted;
  List<String> _homePlayerIds;
  List<String> _awayPlayerIds;

  static const _homeBase = <FieldPoint>[
    FieldPoint(.50, .90),
    FieldPoint(.15, .75),
    FieldPoint(.38, .78),
    FieldPoint(.62, .78),
    FieldPoint(.85, .75),
    FieldPoint(.27, .58),
    FieldPoint(.50, .54),
    FieldPoint(.73, .58),
    FieldPoint(.18, .35),
    FieldPoint(.50, .29),
    FieldPoint(.82, .35),
  ];

  static const _awayBase = <FieldPoint>[
    FieldPoint(.50, .10),
    FieldPoint(.15, .25),
    FieldPoint(.38, .22),
    FieldPoint(.62, .22),
    FieldPoint(.85, .25),
    FieldPoint(.27, .42),
    FieldPoint(.50, .46),
    FieldPoint(.73, .42),
    FieldPoint(.18, .65),
    FieldPoint(.50, .71),
    FieldPoint(.82, .65),
  ];

  final List<FieldPoint> _homePlayers;
  final List<FieldPoint> _awayPlayers;
  final List<FieldPoint> _homeTargets;
  final List<FieldPoint> _awayTargets;
  final List<MatchPresentationCue> _cueQueue = [];
  final MatchPitchMomentState _momentState = MatchPitchMomentState();

  MatchPresentationCue? _currentCue;
  FieldPoint _ball = const FieldPoint(.5, .5);
  FieldPoint _ballStart = const FieldPoint(.5, .5);
  FieldPoint _ballTarget = const FieldPoint(.5, .5);
  double _ballMove = 1;
  double _ballMoveRate = 3.4;
  double _ballDelay = 0;
  double _eventRemaining = 0;
  double _returnDelay = 0;
  double _pulse = 0;
  double _elapsed = 0;
  bool _replayActive = false;
  bool _replayPending = false;
  bool? _activeHome;
  int? _activePlayerIndex;
  final Set<int> _dismissedHomeIndexes = {};
  final Set<int> _dismissedAwayIndexes = {};
  Image? _stadiumCrowdImage;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    try {
      final data = await rootBundle.load(
        'assets/images/match/stadium_crowd.webp',
      );
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      final codec = await instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      _stadiumCrowdImage = frame.image;
    } catch (_) {
      _stadiumCrowdImage = null;
    }
  }

  bool get isReplayActive => _replayActive;

  bool get blocksClock => _replayPending || _replayActive;

  void playEvent(MatchEvent event) => playEvents([event]);

  void updateLineups({
    required List<String> homePlayerIds,
    required List<String> awayPlayerIds,
  }) {
    _homePlayerIds = [...homePlayerIds];
    _awayPlayerIds = [...awayPlayerIds];
  }

  void playEvents(Iterable<MatchEvent> events) {
    final list = events.toList();
    if (list.isEmpty) return;
    final cues = MatchPresentationDirector.buildCues(list);
    if (cues.any((cue) => cue.replay)) _replayPending = true;
    _cueQueue.addAll(cues);
    if (_eventRemaining <= 0) _beginNextCue();
  }

  void skipReplay() {
    if (!_replayPending && !_replayActive) return;
    _cueQueue.removeWhere((cue) => cue.replay);
    _replayPending = false;
    _setReplayActive(false);
    if (_currentCue?.replay == true) {
      _eventRemaining = 0;
      _currentCue = null;
      _beginNextCue();
    }
  }

  void clearPresentationQueue() {
    _cueQueue.clear();
    _replayPending = false;
    _setReplayActive(false);
    _currentCue = null;
    _eventRemaining = 0;
    _returnDelay = .24;
    _resetTargets();
  }

  void _beginNextCue() {
    _clearMomentPoses();
    if (_cueQueue.isEmpty) {
      _currentCue = null;
      _eventRemaining = 0;
      if (!_replayPending) {
          }
      return;
    }

    final cue = _cueQueue.removeAt(0);
    _currentCue = cue;
    _eventRemaining = cue.duration;
    _returnDelay = max(_returnDelay, cue.duration + .34);

    if (cue.startsReplay) {
      _setReplayActive(true);
      _resetTargets();
    }


    final event = cue.event;
    if (event == null) return;
    if (!cue.replay) onEventStarted?.call(event);
    _pulse = _isMajor(event.type) ? 1 : .45;
    _momentState.reactTo(event.type);
    _prepareEvent(event, replay: cue.replay);
  }

  void _prepareEvent(MatchEvent event, {required bool replay}) {
    if (event.start != null) {
      _ball = event.start!;
      _ballStart = event.start!;
    } else {
      _ballStart = _ball;
    }
    if (event.end != null) {
      _ballTarget = event.end!;
      _ballMove = 0;
      _ballMoveRate = replay ? 1.55 : 3.4;
    }

    final homeEvent = event.teamId == homeClubId
        ? true
        : event.teamId == awayClubId
            ? false
            : null;
    _activeHome = homeEvent;
    _activePlayerIndex = _playerIndex(event.playerId, homeEvent);
    if (homeEvent == null) return;

    final eventTargets = homeEvent ? _homeTargets : _awayTargets;
    final oppositeTargets = homeEvent ? _awayTargets : _homeTargets;
    final dismissed =
        homeEvent ? _dismissedHomeIndexes : _dismissedAwayIndexes;
    if (_activePlayerIndex != null && dismissed.contains(_activePlayerIndex)) {
      _activePlayerIndex = null;
    }
    if (event.type == MatchEventType.save ||
        event.type == MatchEventType.penaltySaved) {
      _activePlayerIndex ??= dismissed.contains(0)
          ? _firstVisibleIndex(eventTargets.length, dismissed)
          : 0;
    } else if (_activePlayerIndex == null && event.start != null) {
      final activeIndex = MatchPlayerMotion.nearestIndex(
        eventTargets,
        event.start!,
        excluded: dismissed,
      );
      _activePlayerIndex = activeIndex;
      eventTargets[activeIndex] = MatchPlayerMotion.playerPoint(event.start!);
    }

    if (event.type == MatchEventType.red && _activePlayerIndex != null) {
      dismissed.add(_activePlayerIndex!);
      return;
    }

    if (event.type == MatchEventType.penalty && event.start != null) {
      final activeIndex = _activePlayerIndex ?? 0;
      MatchPlayerMotion.penaltySetup(
        eventTargets,
        oppositeTargets,
        attackingHome: homeEvent,
        takerIndex: activeIndex,
        penaltySpot: event.start!,
      );
      _momentState.setPenalty(takerHome: homeEvent, takerIndex: activeIndex);
      _ball = event.start!;
      _ballStart = event.start!;
      _ballTarget = event.start!;
      _ballMove = 1;
      _ballDelay = 0;
      return;
    }

    if (event.type == MatchEventType.pass && event.end != null) {
      final activeIndex = _activePlayerIndex ?? 0;
      final receiver = MatchPlayerMotion.nearestIndex(
        eventTargets,
        event.end!,
        excluding: activeIndex,
        excluded: dismissed,
      );
      eventTargets[receiver] = MatchPlayerMotion.playerPoint(event.end!);
      MatchPlayerMotion.supportRun(
        eventTargets,
        event.end!,
        excluding: {activeIndex, receiver, ...dismissed},
        attackingHome: homeEvent,
      );
      return;
    }

    if (_isAttackingShotEvent(event.type) && event.end != null) {
      final activeIndex = _activePlayerIndex ?? 0;
      MatchPlayerMotion.attackBox(
        eventTargets,
        event.start ?? event.end!,
        activeIndex,
        attackingHome: homeEvent,
      );
      final defensiveTarget = event.type == MatchEventType.woodwork
          ? (event.start ?? event.end!)
          : event.end!;
      MatchPlayerMotion.defendShot(
        oppositeTargets,
        defensiveTarget,
        defendingHome: !homeEvent,
      );
      _momentState.setKeeperDive(
        defendingHome: !homeEvent,
        target: defensiveTarget,
      );
      if (event.type == MatchEventType.goal ||
          event.type == MatchEventType.ownGoal) {
        MatchPlayerMotion.celebrationRun(
          eventTargets,
          activeIndex,
          event.start ?? event.end!,
          attackingHome: homeEvent,
        );
        _momentState.markCelebration(homeEvent, activeIndex, eventTargets);
      }
      if (event.type == MatchEventType.woodwork) {
        _ballMoveRate = replay ? 1.45 : 2.25;
      }
      return;
    }

    if ((event.type == MatchEventType.save ||
            event.type == MatchEventType.penaltySaved) &&
        event.end != null) {
      MatchPlayerMotion.defendShot(
        eventTargets,
        event.end!,
        defendingHome: homeEvent,
      );
      _momentState.setKeeperDive(defendingHome: homeEvent, target: event.end!);
      _ballMoveRate = replay ? 1.3 : 2.0;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    _momentState.update(dt);

    if (_ballDelay > 0) {
      _ballDelay = max(0.0, _ballDelay - dt);
    } else if (_ballMove < 1) {
      _ballMove = (_ballMove + dt * _ballMoveRate).clamp(0, 1).toDouble();
      final eased = 1 - pow(1 - _ballMove, 3).toDouble();
      _ball = FieldPoint(
        _ballStart.x + (_ballTarget.x - _ballStart.x) * eased,
        _ballStart.y + (_ballTarget.y - _ballStart.y) * eased,
      );
    }

    MatchPlayerMotion.moveTeam(
      _homePlayers,
      _homeTargets,
      dt,
      replay: _replayActive,
    );
    MatchPlayerMotion.moveTeam(
      _awayPlayers,
      _awayTargets,
      dt,
      replay: _replayActive,
    );
    _pulse = max(0.0, _pulse - dt * 1.8);

    if (_eventRemaining > 0) {
      _eventRemaining -= dt;
      if (_eventRemaining <= 0) {
        final endingReplay = _currentCue?.endsReplay == true;
        if (endingReplay) {
          _replayPending = false;
          _setReplayActive(false);
              }
        _beginNextCue();
      }
    }

    if (_returnDelay > 0) {
      _returnDelay -= dt;
      if (_returnDelay <= 0 && _cueQueue.isEmpty && !_replayActive) {
        _resetTargets();
          }
    }
  }

  @override
  void render(Canvas canvas) {
    final width = size.x;
    final height = size.y;
    if (width <= 0 || height <= 0) {
      super.render(canvas);
      return;
    }

    final fieldRect = MatchPitchVisuals.fieldRect(width, height);
    MatchStadiumVisuals.draw(
      canvas,
      width,
      height,
      fieldRect: fieldRect,
      homeColor: homeColor,
      awayColor: awayColor,
      elapsed: _elapsed,
      crowdIntensity: _momentState.crowdIntensity,
      crowdImage: _stadiumCrowdImage,
    );
    final pitch = MatchPitchVisuals.pitchPath(width, height);
    canvas.save();
    canvas.clipPath(pitch);
    MatchPitchVisuals.drawPitch(canvas, width, height);
    _drawPlayers(canvas, width, height, _homePlayers, true);
    _drawPlayers(canvas, width, height, _awayPlayers, false);
    _drawBall(canvas, width, height);
    canvas.restore();
    MatchPitchVisuals.drawGoals(canvas, width, height);
    MatchPitchVisuals.drawVignette(canvas, fieldRect);
    MatchPitchVisuals.drawPitchBorder(canvas, pitch);
    super.render(canvas);
  }

  void _drawPlayers(
    Canvas canvas,
    double width,
    double height,
    List<FieldPoint> players,
    bool home,
  ) {
    final dismissed = home ? _dismissedHomeIndexes : _dismissedAwayIndexes;
    for (var index = 0; index < players.length; index++) {
      if (dismissed.contains(index)) continue;
      final display = toHorizontalDisplayPoint(players[index]);
      final center = MatchPitchVisuals.projectDisplayPoint(
        Offset(display.x, display.y),
        width,
        height,
      );
      final active = _activeHome == home && _activePlayerIndex == index;
      final playerIds = home ? _homePlayerIds : _awayPlayerIds;
      final playerId = index < playerIds.length ? playerIds[index] : '${home ? 'home' : 'away'}-$index';
      MatchPlayerVisuals.draw(
        canvas,
        center: center,
        kit: home ? homeKit : awayKit,
        playerId: playerId,
        active: active,
        pulse: _pulse,
        replay: _replayActive,
        goalkeeper: index == 0,
        scale: MatchPitchVisuals.perspectiveScale(display.y),
        pose: _momentState.poseFor(home, index),
        animationPhase: _elapsed,
        diveDirection: _momentState.diveDirection(home),
      );
    }
  }

  static int _firstVisibleIndex(int count, Set<int> dismissed) {
    for (var index = 0; index < count; index++) {
      if (!dismissed.contains(index)) return index;
    }
    return 0;
  }

  void _drawBall(Canvas canvas, double width, double height) {
    final base = _toCanvasOffset(_ball, width, height);
    final idleOffset = _ballMove >= 1 && _currentCue == null
        ? Offset(sin(_elapsed * 1.45) * 1.8, cos(_elapsed * 1.1) * .9)
        : Offset.zero;
    MatchPitchVisuals.drawBall(
      canvas,
      ball: base + idleOffset,
      trailStart: _toCanvasOffset(_ballStart, width, height),
      moving: _ballMove < 1,
      replay: _replayActive,
      woodwork: _currentCue?.event?.type == MatchEventType.woodwork,
      style: ballStyle,
      eventType: _currentCue?.event?.type,
    );
  }

  int? _playerIndex(String? playerId, bool? home) {
    if (playerId == null || home == null) return null;
    final index = (home ? _homePlayerIds : _awayPlayerIds).indexOf(playerId);
    return index < 0 || index >= 11 ? null : index;
  }

  void _clearMomentPoses() {
    _momentState.clear();
    _ballDelay = 0;
  }

  void _resetTargets() {
    for (var index = 0; index < _homeTargets.length; index++) {
      _homeTargets[index] = _copyPoint(_homeBase[index]);
      _awayTargets[index] = _copyPoint(_awayBase[index]);
    }
    _activeHome = null;
    _activePlayerIndex = null;
    _clearMomentPoses();
  }

  void _setReplayActive(bool active) {
    if (_replayActive == active) return;
    _replayActive = active;
    onReplayChanged?.call(active);
  }

  static FieldPoint toHorizontalDisplayPoint(FieldPoint point) => FieldPoint(
        1 - point.y,
        point.x,
      );

  static Offset _toCanvasOffset(FieldPoint point, double width, double height) {
    final display = toHorizontalDisplayPoint(point);
    return MatchPitchVisuals.projectDisplayPoint(
      Offset(display.x, display.y),
      width,
      height,
    );
  }

  static FieldPoint _copyPoint(FieldPoint point) => FieldPoint(point.x, point.y);

  static bool _isAttackingShotEvent(MatchEventType type) =>
      type == MatchEventType.shot ||
      type == MatchEventType.woodwork ||
      type == MatchEventType.goal ||
      type == MatchEventType.ownGoal;

  static bool _isMajor(MatchEventType type) =>
      type == MatchEventType.goal ||
      type == MatchEventType.ownGoal ||
      type == MatchEventType.woodwork ||
      type == MatchEventType.yellow ||
      type == MatchEventType.red ||
      type == MatchEventType.penalty ||
      type == MatchEventType.penaltySaved ||
      type == MatchEventType.substitution ||
      type == MatchEventType.injury;

}
