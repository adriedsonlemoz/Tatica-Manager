import 'dart:math' as math;

import '../../../domain/club/club.dart';

enum MatchKitSlot { primary, away, third }

extension MatchKitSlotX on MatchKitSlot {
  String get label => switch (this) {
        MatchKitSlot.primary => 'Uniforme 1',
        MatchKitSlot.away => 'Uniforme 2',
        MatchKitSlot.third => 'Uniforme 3',
      };

  String get shortLabel => switch (this) {
        MatchKitSlot.primary => '1',
        MatchKitSlot.away => '2',
        MatchKitSlot.third => '3',
      };

  String get roleLabel => switch (this) {
        MatchKitSlot.primary => 'Principal',
        MatchKitSlot.away => 'Visitante',
        MatchKitSlot.third => 'Alternativo',
      };

  ClubKit kitOf(Club club) => switch (this) {
        MatchKitSlot.primary => club.homeKit,
        MatchKitSlot.away => club.awayKit,
        MatchKitSlot.third => club.thirdKit,
      };
}

class MatchVisualKitSelection {
  const MatchVisualKitSelection({
    required this.homeKit,
    required this.awayKit,
    required this.homeSlot,
    required this.awaySlot,
    required this.homeGoalkeeperKit,
    required this.awayGoalkeeperKit,
    required this.contrastScore,
    required this.safetyFallbackUsed,
    required this.adjustedClubId,
  });

  final ClubKit homeKit;
  final ClubKit awayKit;
  final MatchKitSlot homeSlot;
  final MatchKitSlot awaySlot;
  final ClubKit homeGoalkeeperKit;
  final ClubKit awayGoalkeeperKit;
  final double contrastScore;
  final bool safetyFallbackUsed;
  final String? adjustedClubId;

  MatchKitSlot slotForClub(String clubId, String homeClubId) =>
      clubId == homeClubId ? homeSlot : awaySlot;

  ClubKit kitForClub(String clubId, String homeClubId) =>
      clubId == homeClubId ? homeKit : awayKit;
}

/// Resolve somente a apresentação visual dos uniformes. Nenhum valor desta
/// classe participa do Match Engine ou é persistido no save.
abstract final class MatchKitResolver {
  static const double minimumContrastScore = 38;

  static MatchVisualKitSelection resolve({
    required Club home,
    required Club away,
    required String userClubId,
    required MatchKitSlot userSlot,
  }) {
    final userIsHome = home.id == userClubId;
    final userClub = userIsHome ? home : away;
    final opponent = userIsHome ? away : home;
    final userKit = userSlot.kitOf(userClub);

    var opponentSlot = MatchKitSlot.primary;
    var opponentKit = opponentSlot.kitOf(opponent);
    var bestScore = -1.0;
    for (final slot in MatchKitSlot.values) {
      final candidate = slot.kitOf(opponent);
      final score = contrastScore(userKit, candidate);
      if (score > bestScore) {
        bestScore = score;
        opponentSlot = slot;
        opponentKit = candidate;
      }
    }

    var safetyFallbackUsed = false;
    if (bestScore < minimumContrastScore) {
      opponentKit = _safetyKitAgainst(userKit, opponentKit);
      bestScore = contrastScore(userKit, opponentKit);
      safetyFallbackUsed = true;
    }

    final homeKit = userIsHome ? userKit : opponentKit;
    final awayKit = userIsHome ? opponentKit : userKit;
    final goalkeeperKits = _goalkeeperKits(homeKit, awayKit);

    return MatchVisualKitSelection(
      homeKit: homeKit,
      awayKit: awayKit,
      homeSlot: userIsHome ? userSlot : opponentSlot,
      awaySlot: userIsHome ? opponentSlot : userSlot,
      homeGoalkeeperKit: goalkeeperKits.$1,
      awayGoalkeeperKit: goalkeeperKits.$2,
      contrastScore: bestScore,
      safetyFallbackUsed: safetyFallbackUsed,
      adjustedClubId: safetyFallbackUsed ? opponent.id : null,
    );
  }

  static bool kitsConflict(ClubKit first, ClubKit second) =>
      contrastScore(first, second) < minimumContrastScore;

  static double contrastScore(ClubKit first, ClubKit second) {
    final primary = _deltaE(first.primaryHex, second.primaryHex);
    final shorts = _deltaE(first.shortsHex, second.shortsHex);
    final socks = _deltaE(first.socksHex, second.socksHex);
    final secondary = math.max(
      _deltaE(first.secondaryHex, second.primaryHex),
      _deltaE(first.primaryHex, second.secondaryHex),
    );
    final luminanceGap =
        (_relativeLuminance(first.primaryHex) -
                _relativeLuminance(second.primaryHex))
            .abs();
    final patternBonus = first.pattern == second.pattern ? 0.0 : 3.5;
    final lowLuminancePenalty = luminanceGap < .07 && primary < 32 ? 6.0 : 0.0;
    return (primary * .64 +
            shorts * .18 +
            socks * .10 +
            math.min(secondary, 70) * .08 +
            patternBonus -
            lowLuminancePenalty)
        .clamp(0.0, 100.0)
        .toDouble();
  }

  static ClubKit _safetyKitAgainst(ClubKit reference, ClubKit fallback) {
    final candidates = <ClubKit>[
      _solidKit(0xFFF7F7F7, 0xFF111417),
      _solidKit(0xFF121619, 0xFFF7F7F7),
      _solidKit(0xFFF2D13D, 0xFF181A1C),
      _solidKit(0xFF1DBBD1, 0xFF10242B),
      _solidKit(0xFFF07B31, 0xFF24150D),
      _solidKit(0xFF8B69E8, 0xFFF8F8F8),
      _solidKit(0xFFE84C9A, 0xFF24101A),
    ];
    var selected = fallback;
    var bestScore = contrastScore(reference, fallback);
    for (final candidate in candidates) {
      final score = contrastScore(reference, candidate);
      if (score > bestScore) {
        selected = candidate;
        bestScore = score;
      }
    }
    return selected;
  }

  static (ClubKit, ClubKit) _goalkeeperKits(
    ClubKit homeKit,
    ClubKit awayKit,
  ) {
    final candidates = <ClubKit>[
      _solidKit(0xFFF0CD38, 0xFF222222),
      _solidKit(0xFF23BFA7, 0xFF102722),
      _solidKit(0xFFF27B32, 0xFF2B160D),
      _solidKit(0xFF7C68E8, 0xFFF7F7F7),
      _solidKit(0xFF39A9E8, 0xFF10212B),
      _solidKit(0xFFE64B91, 0xFF2A101C),
      _solidKit(0xFFB6E33A, 0xFF1A210C),
    ];
    const grass = ClubKit(
      primaryHex: 0xFF245A24,
      secondaryHex: 0xFF245A24,
      shortsHex: 0xFF245A24,
      socksHex: 0xFF245A24,
    );

    ClubKit choose({ClubKit? excluded}) {
      var selected = candidates.first;
      var bestScore = -1.0;
      for (final candidate in candidates) {
        final scores = <double>[
          contrastScore(candidate, homeKit),
          contrastScore(candidate, awayKit),
          contrastScore(candidate, grass),
          if (excluded != null) contrastScore(candidate, excluded),
        ];
        final minimum = scores.reduce(
          (first, second) => math.min(first, second).toDouble(),
        );
        if (minimum > bestScore) {
          bestScore = minimum;
          selected = candidate;
        }
      }
      return selected;
    }

    final homeGoalkeeper = choose();
    final awayGoalkeeper = choose(excluded: homeGoalkeeper);
    return (homeGoalkeeper, awayGoalkeeper);
  }

  static ClubKit _solidKit(int primary, int secondary) => ClubKit(
        primaryHex: primary,
        secondaryHex: secondary,
        accentHex: secondary,
        shortsHex: primary,
        socksHex: secondary,
        pattern: ClubKitPattern.solid,
      );

  static double _deltaE(int first, int second) {
    final a = _lab(first);
    final b = _lab(second);
    final dl = a.$1 - b.$1;
    final da = a.$2 - b.$2;
    final db = a.$3 - b.$3;
    return math.sqrt(dl * dl + da * da + db * db);
  }

  static (double, double, double) _lab(int color) {
    final red = _linearChannel((color >> 16) & 0xFF);
    final green = _linearChannel((color >> 8) & 0xFF);
    final blue = _linearChannel(color & 0xFF);
    final x = (red * .4124 + green * .3576 + blue * .1805) / .95047;
    final y = red * .2126 + green * .7152 + blue * .0722;
    final z = (red * .0193 + green * .1192 + blue * .9505) / 1.08883;
    final fx = _labPivot(x);
    final fy = _labPivot(y);
    final fz = _labPivot(z);
    return (116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz));
  }

  static double _relativeLuminance(int color) {
    final red = _linearChannel((color >> 16) & 0xFF);
    final green = _linearChannel((color >> 8) & 0xFF);
    final blue = _linearChannel(color & 0xFF);
    return red * .2126 + green * .7152 + blue * .0722;
  }

  static double _linearChannel(int channel) {
    final value = channel / 255;
    return value <= .04045
        ? value / 12.92
        : math.pow((value + .055) / 1.055, 2.4).toDouble();
  }

  static double _labPivot(double value) => value > .008856
      ? math.pow(value, 1 / 3).toDouble()
      : 7.787 * value + 16 / 116;
}
