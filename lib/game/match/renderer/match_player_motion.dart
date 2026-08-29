import 'dart:math' as math;

import '../../../domain/match/match_models.dart';

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

  static void penaltySetup(
    List<FieldPoint> attackingTargets,
    List<FieldPoint> defendingTargets, {
    required bool attackingHome,
    required int takerIndex,
    required FieldPoint penaltySpot,
  }) {
    attackingTargets[takerIndex] = playerPoint(penaltySpot);
    final waitingY = attackingHome ? .26 : .74;
    final defendingWaitingY = attackingHome ? .22 : .78;

    var lane = 0;
    for (var index = 0; index < attackingTargets.length; index++) {
      if (index == takerIndex) continue;
      final x = .24 + (lane % 5) * .13;
      final rowOffset = lane >= 5 ? .045 : 0.0;
      attackingTargets[index] = FieldPoint(
        x.clamp(.12, .88).toDouble(),
        (waitingY + (attackingHome ? rowOffset : -rowOffset))
            .clamp(.12, .88)
            .toDouble(),
      );
      lane++;
    }

    defendingTargets[0] = FieldPoint(.5, attackingHome ? .10 : .90);
    for (var index = 1; index < defendingTargets.length; index++) {
      final x = .22 + ((index - 1) % 5) * .14;
      final rowOffset = index > 5 ? .045 : 0.0;
      defendingTargets[index] = FieldPoint(
        x.clamp(.12, .88).toDouble(),
        (defendingWaitingY + (attackingHome ? -rowOffset : rowOffset))
            .clamp(.12, .88)
            .toDouble(),
      );
    }
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

  static void moveTeam(
    List<FieldPoint> current,
    List<FieldPoint> targets,
    double dt, {
    required bool replay,
  }) {
    for (var index = 0; index < current.length; index++) {
      final distance = math.sqrt(distanceSquared(current[index], targets[index]));
      final rate = (replay ? 2.8 : 4.4) + math.min(2.2, distance * 7.5);
      final factor = (1 - math.exp(-rate * dt)).clamp(0, 1).toDouble();
      current[index] = FieldPoint(
        current[index].x + (targets[index].x - current[index].x) * factor,
        current[index].y + (targets[index].y - current[index].y) * factor,
      );
    }
  }

  static double distanceSquared(FieldPoint a, FieldPoint b) {
    final dx = a.x - b.x;
    final dy = a.y - b.y;
    return dx * dx + dy * dy;
  }
}
