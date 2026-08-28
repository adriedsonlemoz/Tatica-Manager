import '../../domain/player/player.dart';

/// Pure, deterministic visual identity for a player's 2D avatar.
///
/// Existing editable fields from [VisualProfile] remain authoritative for skin
/// and hair. Extra facial traits are derived only from the permanent player ID,
/// so they do not need to be persisted and stay stable across save/load.
class PlayerAvatarIdentity {
  const PlayerAvatarIdentity({
    required this.seed,
    required this.skinTone,
    required this.hairStyle,
    required this.hairColor,
    required this.faceShape,
    required this.eyeStyle,
    required this.eyeColor,
    required this.eyebrowStyle,
    required this.noseStyle,
    required this.mouthStyle,
    required this.beardStyle,
    required this.moustacheStyle,
    required this.detailStyle,
    required this.ageStyle,
  });

  final int seed;
  final int skinTone;
  final int hairStyle;
  final int hairColor;
  final int faceShape;
  final int eyeStyle;
  final int eyeColor;
  final int eyebrowStyle;
  final int noseStyle;
  final int mouthStyle;
  final int beardStyle;
  final int moustacheStyle;
  final int detailStyle;
  final int ageStyle;

  factory PlayerAvatarIdentity.fromPlayer(Player player) {
    final seed = stablePlayerSeed(player.id);
    var state = seed;

    int next(int max) {
      state = _mix32(state + 0x9E3779B9);
      return state % max;
    }

    final beardRoll = next(10);
    final beardStyle = beardRoll < 5 ? 0 : 1 + next(4);
    final moustacheStyle = beardStyle == 4 || next(10) < 6 ? 0 : 1 + next(3);

    return PlayerAvatarIdentity(
      seed: seed,
      skinTone: player.visual.skinTone.clamp(0, 5).toInt(),
      hairStyle: player.visual.hairStyle.clamp(0, 7).toInt(),
      hairColor: player.visual.hairColor.clamp(0, 4).toInt(),
      faceShape: next(4),
      eyeStyle: next(4),
      eyeColor: next(5),
      eyebrowStyle: next(4),
      noseStyle: next(4),
      mouthStyle: next(4),
      beardStyle: beardStyle,
      moustacheStyle: moustacheStyle,
      detailStyle: next(5),
      ageStyle: player.age >= 34 ? 2 : player.age >= 29 ? 1 : 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PlayerAvatarIdentity &&
      seed == other.seed &&
      skinTone == other.skinTone &&
      hairStyle == other.hairStyle &&
      hairColor == other.hairColor &&
      faceShape == other.faceShape &&
      eyeStyle == other.eyeStyle &&
      eyeColor == other.eyeColor &&
      eyebrowStyle == other.eyebrowStyle &&
      noseStyle == other.noseStyle &&
      mouthStyle == other.mouthStyle &&
      beardStyle == other.beardStyle &&
      moustacheStyle == other.moustacheStyle &&
      detailStyle == other.detailStyle &&
      ageStyle == other.ageStyle;

  @override
  int get hashCode => Object.hash(
        seed,
        skinTone,
        hairStyle,
        hairColor,
        faceShape,
        eyeStyle,
        eyeColor,
        eyebrowStyle,
        noseStyle,
        mouthStyle,
        beardStyle,
        moustacheStyle,
        detailStyle,
        ageStyle,
      );
}

/// Stable FNV-1a hash. Unlike [String.hashCode], this is deliberately defined
/// here so avatar seeds remain portable between app runs and platforms.
int stablePlayerSeed(String playerId) {
  var hash = 0x811C9DC5;
  for (final unit in playerId.codeUnits) {
    hash ^= unit & 0xFF;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
    if (unit > 0xFF) {
      hash ^= (unit >> 8) & 0xFF;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
  }
  return hash & 0x7FFFFFFF;
}

int _mix32(int value) {
  var x = value & 0xFFFFFFFF;
  x ^= x >> 16;
  x = (x * 0x7FEB352D) & 0xFFFFFFFF;
  x ^= x >> 15;
  x = (x * 0x846CA68B) & 0xFFFFFFFF;
  x ^= x >> 16;
  return x & 0x7FFFFFFF;
}
