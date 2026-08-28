import 'dart:math';

import '../../../domain/match/match_models.dart';

abstract final class MatchTrajectoryGenerator {
  static (FieldPoint, FieldPoint) pass(bool homeSide, Random random) {
    final x1 = .18 + random.nextDouble() * .64;
    final x2 = .18 + random.nextDouble() * .64;
    final y1 = homeSide
        ? .68 - random.nextDouble() * .20
        : .32 + random.nextDouble() * .20;
    final y2 = homeSide
        ? .36 - random.nextDouble() * .16
        : .64 + random.nextDouble() * .16;
    return (FieldPoint(x1, y1), FieldPoint(x2, y2));
  }

  static (FieldPoint, FieldPoint) shot(bool homeSide, Random random) {
    final start = FieldPoint(
      .30 + random.nextDouble() * .40,
      homeSide
          ? .24 + random.nextDouble() * .10
          : .66 + random.nextDouble() * .10,
    );
    final end = FieldPoint(
      .42 + random.nextDouble() * .16,
      homeSide ? .035 : .965,
    );
    return (start, end);
  }

  static FieldPoint woodworkTarget(FieldPoint original) {
    final postX = original.x < .5 ? .42 : .58;
    return FieldPoint(postX, original.y);
  }

  static FieldPoint woodworkRebound(bool homeSide, FieldPoint post) =>
      FieldPoint(
        (post.x * .72 + .5 * .28).clamp(.36, .64).toDouble(),
        homeSide ? .16 : .84,
      );

  static FieldPoint randomFieldPoint(Random random) => FieldPoint(
        .1 + random.nextDouble() * .8,
        .1 + random.nextDouble() * .8,
      );
}
