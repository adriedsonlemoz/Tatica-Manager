import 'dart:math' as math;

import '../../../domain/match/match_models.dart';

class MatchPlayerMotionState {
  MatchPlayerMotionState({required this.seed});

  final int seed;
  double velocityX = 0;
  double velocityY = 0;
  double delayRemaining = 0;
  FieldPoint? _lastTarget;
  FieldPoint? _transitionStart;
  double _initialDistance = 0;
  double _curveStrength = 0;
  double? _preparedDelay;
  double _preparedCurveScale = 1;
  int _transitionCount = 0;

  double get speed => math.sqrt(velocityX * velocityX + velocityY * velocityY);

  double get movementAmount => (speed / .50).clamp(0.0, 1.0).toDouble();

  double get displayDirection {
    final currentSpeed = speed;
    if (currentSpeed < .005) return 0;
    return (-velocityY / currentSpeed).clamp(-1.0, 1.0).toDouble();
  }

  void prepareNextTransition({
    required double delay,
    double curveScale = 1,
  }) {
    _lastTarget = null;
    _preparedDelay = math.max(0.0, delay).toDouble();
    _preparedCurveScale = curveScale.clamp(0.0, 1.4).toDouble();
  }

  void clearPreparedTransition() {
    _preparedDelay = null;
    _preparedCurveScale = 1;
  }
}

abstract final class MatchPlayerMotion {
  static int nearestIndex(
    List<FieldPoint> points,
    FieldPoint target, {
    int? excluding,
    Set<int> excluded = const {},
  }) {
    var bestIndex = 0;
    var bestDistance = double.infinity;
    for (var index = 0; index < points.length; index++) {
      if (index == excluding || excluded.contains(index)) continue;
      final distance = distanceSquared(points[index], target);
      if (distance < bestDistance) {
        bestDistance = distance;
        bestIndex = index;
      }
    }
    return bestIndex;
  }

  static FieldPoint playerPoint(FieldPoint point) => FieldPoint(
        point.x.clamp(.08, .92).toDouble(),
        point.y.clamp(.07, .93).toDouble(),
      );

  static void supportRun(
    List<FieldPoint> targets,
    FieldPoint destination, {
    required Set<int> excluding,
    required bool attackingHome,
  }) {
    final goalY = attackingHome ? .08 : .92;
    final candidates = List<int>.generate(targets.length, (index) => index)
      ..removeWhere(excluding.contains)
      ..sort(
        (a, b) => distanceSquared(targets[a], destination)
            .compareTo(distanceSquared(targets[b], destination)),
      );
    for (final index in candidates.take(2)) {
      final current = targets[index];
      targets[index] = FieldPoint(
        (current.x * .65 + destination.x * .35).clamp(.08, .92).toDouble(),
        (current.y * .72 + goalY * .28).clamp(.07, .93).toDouble(),
      );
    }
  }

  static void attackBox(
    List<FieldPoint> targets,
    FieldPoint start,
    int activeIndex, {
    required bool attackingHome,
  }) {
    final goalY = attackingHome ? .06 : .94;
    final candidates = List<int>.generate(targets.length, (index) => index)
      ..remove(activeIndex)
      ..sort(
        (a, b) => distanceSquared(targets[a], start)
            .compareTo(distanceSquared(targets[b], start)),
      );
    for (final index in candidates.take(3)) {
      final current = targets[index];
      targets[index] = FieldPoint(
        (current.x * .70 + start.x * .30).clamp(.10, .90).toDouble(),
        (current.y * .58 + goalY * .42).clamp(.08, .92).toDouble(),
      );
    }
  }

  static void defendShot(
    List<FieldPoint> targets,
    FieldPoint target, {
    required bool defendingHome,
  }) {
    final goalY = defendingHome ? .90 : .10;
    targets[0] = FieldPoint(
      target.x.clamp(.34, .66).toDouble(),
      goalY,
    );

    final defenders = List<int>.generate(targets.length - 1, (index) => index + 1)
      ..sort(
        (a, b) => distanceSquared(targets[a], target)
            .compareTo(distanceSquared(targets[b], target)),
      );
    for (final index in defenders.take(2)) {
      final current = targets[index];
      targets[index] = FieldPoint(
        (current.x * .62 + target.x * .38).clamp(.12, .88).toDouble(),
        (current.y * .70 + goalY * .30).clamp(.08, .92).toDouble(),
      );
    }
  }

  static (Set<int>, Set<int>) penaltySetup(
    List<FieldPoint> attackingTargets,
    List<FieldPoint> defendingTargets, {
    required bool attackingHome,
    required int takerIndex,
    required FieldPoint penaltySpot,
  }) {
    final movedAttackers = <int>{takerIndex};
    final movedDefenders = <int>{0};
    attackingTargets[takerIndex] = playerPoint(penaltySpot);
    final attackingBoundary = attackingHome ? .29 : .71;
    final defendingBoundary = attackingHome ? .255 : .745;

    // O goleiro atacante e os jogadores que já estão fora da área mantêm a
    // posição. Assim o pênalti não puxa os 22 atletas para uma única coluna.
    for (var index = 1; index < attackingTargets.length; index++) {
      if (index == takerIndex) continue;
      final current = attackingTargets[index];
      if (!_insidePenaltyApproach(
        current.y,
        attackingHome: attackingHome,
        boundary: attackingBoundary,
      )) {
        continue;
      }
      attackingTargets[index] = _penaltyWaitingPoint(
        current,
        index: index,
        attackingHome: attackingHome,
        boundary: attackingBoundary,
        teamOffset: .020,
      );
      movedAttackers.add(index);
    }

    defendingTargets[0] = FieldPoint(.5, attackingHome ? .10 : .90);
    for (var index = 1; index < defendingTargets.length; index++) {
      final current = defendingTargets[index];
      if (!_insidePenaltyApproach(
        current.y,
        attackingHome: attackingHome,
        boundary: defendingBoundary,
      )) {
        continue;
      }
      defendingTargets[index] = _penaltyWaitingPoint(
        current,
        index: index,
        attackingHome: attackingHome,
        boundary: defendingBoundary,
        teamOffset: 0,
      );
      movedDefenders.add(index);
    }
    return (movedAttackers, movedDefenders);
  }

  static bool _insidePenaltyApproach(
    double y, {
    required bool attackingHome,
    required double boundary,
  }) =>
      attackingHome ? y < boundary : y > boundary;

  static FieldPoint _penaltyWaitingPoint(
    FieldPoint current, {
    required int index,
    required bool attackingHome,
    required double boundary,
    required double teamOffset,
  }) {
    final row = (index - 1) ~/ 4;
    final depth = teamOffset + row * .018;
    final lateral = ((index % 3) - 1) * .012;
    return FieldPoint(
      (current.x + lateral).clamp(.10, .90).toDouble(),
      (boundary + (attackingHome ? depth : -depth))
          .clamp(.12, .88)
          .toDouble(),
    );
  }

  static void celebrationRun(
    List<FieldPoint> targets,
    int scorerIndex,
    FieldPoint start, {
    required bool attackingHome,
  }) {
    final celebrationY = attackingHome ? .14 : .86;
    final celebrationX = (start.x + (start.x < .5 ? -.08 : .08))
        .clamp(.15, .85)
        .toDouble();
    targets[scorerIndex] = FieldPoint(celebrationX, celebrationY);
    final partners = List<int>.generate(targets.length, (index) => index)
      ..remove(scorerIndex)
      ..sort(
        (a, b) => distanceSquared(targets[a], start)
            .compareTo(distanceSquared(targets[b], start)),
      );
    for (var slot = 0; slot < partners.take(4).length; slot++) {
      final index = partners[slot];
      final side = slot.isEven ? -1.0 : 1.0;
      targets[index] = FieldPoint(
        (celebrationX + side * (.035 + (slot ~/ 2) * .025))
            .clamp(.10, .90)
            .toDouble(),
        (celebrationY + .035 + (slot ~/ 2) * .025)
            .clamp(.08, .92)
            .toDouble(),
      );
    }
  }

  static List<FieldPoint> phaseShape(
    List<FieldPoint> formation,
    FieldPoint ball, {
    required bool home,
    required bool? inPossession,
  }) {
    final horizontalShift = ball.x - .5;
    final verticalShift = ball.y - .5;
    final possessionPush = inPossession == null
        ? 0.0
        : inPossession
            ? (home ? -.026 : .026)
            : (home ? .014 : -.014);

    return List<FieldPoint>.generate(formation.length, (index) {
      final base = formation[index];
      final ownDepth = home ? base.y : 1 - base.y;
      final sectorFollow = index == 0
          ? .055
          : ownDepth > .64
              ? .145
              : ownDepth > .35
                  ? .215
                  : .265;
      final lateralFollow = index == 0 ? .055 : sectorFollow * .72;
      return FieldPoint(
        (base.x + horizontalShift * lateralFollow)
            .clamp(.07, .93)
            .toDouble(),
        (base.y + verticalShift * sectorFollow + possessionPush)
            .clamp(.06, .94)
            .toDouble(),
      );
    }, growable: false);
  }

  static void moveTeam(
    List<FieldPoint> current,
    List<FieldPoint> targets,
    List<MatchPlayerMotionState> motionStates,
    double dt, {
    required bool replay,
  }) {
    for (var index = 0; index < current.length; index++) {
      final state = motionStates[index];
      if (state._lastTarget == null &&
          distanceSquared(current[index], targets[index]) <= .00000025) {
        state._lastTarget = _copyPoint(targets[index]);
        state.clearPreparedTransition();
      } else if (state._lastTarget == null ||
          distanceSquared(state._lastTarget!, targets[index]) > .00000025) {
        _beginTransition(
          state,
          current: current[index],
          target: targets[index],
          index: index,
        );
      }

      var remaining = dt.clamp(0.0, .12).toDouble();
      while (remaining > 0) {
        final step = math.min(.025, remaining).toDouble();
        current[index] = _advancePlayer(
          current[index],
          targets[index],
          state,
          step,
          replay: replay,
          goalkeeper: index == 0,
        );
        remaining -= step;
      }
    }
  }

  static void preparePenaltyTransitions(
    List<MatchPlayerMotionState> attacking,
    List<MatchPlayerMotionState> defending, {
    required int takerIndex,
    required Set<int> attackingIndexes,
    required Set<int> defendingIndexes,
  }) {
    clearPreparedTransitions(attacking);
    clearPreparedTransitions(defending);
    for (final index in attackingIndexes) {
      final delay = index == takerIndex ? 0.0 : .08 + (index % 4) * .035;
      attacking[index].prepareNextTransition(
        delay: delay,
        curveScale: index == takerIndex ? .30 : .65,
      );
    }
    for (final index in defendingIndexes) {
      defending[index].prepareNextTransition(
        delay: index == 0 ? .025 : .12 + (index % 4) * .035,
        curveScale: index == 0 ? .20 : .65,
      );
    }
  }

  static void prepareFormationReturn(
    List<MatchPlayerMotionState> states, {
    required bool home,
    required List<FieldPoint> current,
    required List<FieldPoint> formation,
  }) {
    for (var index = 0; index < states.length; index++) {
      states[index].clearPreparedTransition();
      if (distanceSquared(current[index], formation[index]) < .00000025) {
        continue;
      }
      final sectorDelay = switch (index) {
        0 => .12,
        >= 1 && <= 4 => .04,
        >= 5 && <= 7 => .11,
        _ => .19,
      };
      states[index].prepareNextTransition(
        delay: sectorDelay + (index % 3) * .035 + (home ? 0 : .025),
        curveScale: .72,
      );
    }
  }

  static void clearPreparedTransitions(
    List<MatchPlayerMotionState> states,
  ) {
    for (final state in states) {
      state.clearPreparedTransition();
    }
  }

  static void _beginTransition(
    MatchPlayerMotionState state, {
    required FieldPoint current,
    required FieldPoint target,
    required int index,
  }) {
    state._lastTarget = _copyPoint(target);
    state._transitionStart = _copyPoint(current);
    state._initialDistance = math.sqrt(distanceSquared(current, target));
    state._transitionCount++;
    state.delayRemaining = state._preparedDelay ??
        (index == 0
            ? .015
            : .025 * ((state.seed + index) % 4) + .018 * (index ~/ 4));
    final sign = (state.seed + state._transitionCount).isEven ? 1.0 : -1.0;
    final curveScale = state._preparedCurveScale;
    state._curveStrength = state._initialDistance < .07
        ? 0
        : math.min(.032, state._initialDistance * .11) * sign * curveScale;
    state.clearPreparedTransition();
  }

  static FieldPoint _advancePlayer(
    FieldPoint current,
    FieldPoint target,
    MatchPlayerMotionState state,
    double dt, {
    required bool replay,
    required bool goalkeeper,
  }) {
    if (state.delayRemaining > 0) {
      state.delayRemaining = math.max(0.0, state.delayRemaining - dt).toDouble();
      final braking = (replay ? 1.8 : 3.0) * dt;
      state.velocityX = _approach(state.velocityX, 0, braking);
      state.velocityY = _approach(state.velocityY, 0, braking);
      return current;
    }

    final dx = target.x - current.x;
    final dy = target.y - current.y;
    final distance = math.sqrt(dx * dx + dy * dy);
    if (distance < .0015 && state.speed < .025) {
      state.velocityX = 0;
      state.velocityY = 0;
      return _copyPoint(target);
    }

    var guidanceX = target.x;
    var guidanceY = target.y;
    final start = state._transitionStart;
    if (start != null && state._initialDistance > .001 && distance > .025) {
      final routeX = target.x - start.x;
      final routeY = target.y - start.y;
      final routeLength = math.sqrt(routeX * routeX + routeY * routeY);
      if (routeLength > .001) {
        final progress = (1 - distance / state._initialDistance)
            .clamp(0.0, 1.0)
            .toDouble();
        final bend = math.sin(progress * math.pi) * state._curveStrength;
        guidanceX += -routeY / routeLength * bend;
        guidanceY += routeX / routeLength * bend;
      }
    }

    var guideX = guidanceX - current.x;
    var guideY = guidanceY - current.y;
    var guideDistance = math.sqrt(guideX * guideX + guideY * guideY);
    if (guideDistance < .001) {
      guideX = dx;
      guideY = dy;
      guideDistance = math.max(distance, .001).toDouble();
    }

    final maximumSpeed = (replay ? .42 : .66) * (goalkeeper ? .90 : 1);
    final deceleration = replay ? 1.15 : 1.90;
    final desiredSpeed = math
        .min(maximumSpeed, math.sqrt(2 * deceleration * distance))
        .toDouble();
    final desiredX = guideX / guideDistance * desiredSpeed;
    final desiredY = guideY / guideDistance * desiredSpeed;
    final acceleration = (replay ? 1.35 : 2.55) * dt;
    state.velocityX = _approach(state.velocityX, desiredX, acceleration);
    state.velocityY = _approach(state.velocityY, desiredY, acceleration);

    final next = FieldPoint(
      (current.x + state.velocityX * dt).clamp(.04, .96).toDouble(),
      (current.y + state.velocityY * dt).clamp(.04, .96).toDouble(),
    );
    if (distanceSquared(next, target) < .00000225 && state.speed < .05) {
      state.velocityX = 0;
      state.velocityY = 0;
      return _copyPoint(target);
    }
    return next;
  }

  static double _approach(double current, double target, double maximumDelta) {
    final difference = target - current;
    if (difference.abs() <= maximumDelta) return target;
    return current + difference.sign * maximumDelta;
  }

  static FieldPoint _copyPoint(FieldPoint point) =>
      FieldPoint(point.x, point.y);

  static double distanceSquared(FieldPoint a, FieldPoint b) {
    final dx = a.x - b.x;
    final dy = a.y - b.y;
    return dx * dx + dy * dy;
  }
}
