import '../../game/player/player_avatar_identity.dart';

class ManagerAppearance {
  const ManagerAppearance({
    this.skinTone = 2,
    this.hairStyle = 0,
    this.hairColor = 0,
    this.faceShape = 0,
    this.eyeStyle = 0,
    this.eyeColor = 0,
    this.eyebrowStyle = 0,
    this.noseStyle = 0,
    this.mouthStyle = 0,
    this.beardStyle = 0,
    this.moustacheStyle = 0,
    this.detailStyle = 0,
    this.customPhotoPath,
  });

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
  final String? customPhotoPath;

  ManagerAppearance copyWith({
    int? skinTone,
    int? hairStyle,
    int? hairColor,
    int? faceShape,
    int? eyeStyle,
    int? eyeColor,
    int? eyebrowStyle,
    int? noseStyle,
    int? mouthStyle,
    int? beardStyle,
    int? moustacheStyle,
    int? detailStyle,
    String? customPhotoPath,
    bool clearCustomPhoto = false,
  }) =>
      ManagerAppearance(
        skinTone: skinTone ?? this.skinTone,
        hairStyle: hairStyle ?? this.hairStyle,
        hairColor: hairColor ?? this.hairColor,
        faceShape: faceShape ?? this.faceShape,
        eyeStyle: eyeStyle ?? this.eyeStyle,
        eyeColor: eyeColor ?? this.eyeColor,
        eyebrowStyle: eyebrowStyle ?? this.eyebrowStyle,
        noseStyle: noseStyle ?? this.noseStyle,
        mouthStyle: mouthStyle ?? this.mouthStyle,
        beardStyle: beardStyle ?? this.beardStyle,
        moustacheStyle: moustacheStyle ?? this.moustacheStyle,
        detailStyle: detailStyle ?? this.detailStyle,
        customPhotoPath:
            clearCustomPhoto ? null : customPhotoPath ?? this.customPhotoPath,
      );

  Map<String, dynamic> toJson() => {
        'skinTone': skinTone,
        'hairStyle': hairStyle,
        'hairColor': hairColor,
        'faceShape': faceShape,
        'eyeStyle': eyeStyle,
        'eyeColor': eyeColor,
        'eyebrowStyle': eyebrowStyle,
        'noseStyle': noseStyle,
        'mouthStyle': mouthStyle,
        'beardStyle': beardStyle,
        'moustacheStyle': moustacheStyle,
        'detailStyle': detailStyle,
        if (customPhotoPath != null) 'customPhotoPath': customPhotoPath,
      };

  factory ManagerAppearance.fromJson(Map<String, dynamic> json) =>
      ManagerAppearance(
        skinTone: _clamp(json['skinTone'], 0, 5, 2),
        hairStyle: _clamp(json['hairStyle'], 0, 7, 0),
        hairColor: _clamp(json['hairColor'], 0, 4, 0),
        faceShape: _clamp(json['faceShape'], 0, 3, 0),
        eyeStyle: _clamp(json['eyeStyle'], 0, 3, 0),
        eyeColor: _clamp(json['eyeColor'], 0, 4, 0),
        eyebrowStyle: _clamp(json['eyebrowStyle'], 0, 3, 0),
        noseStyle: _clamp(json['noseStyle'], 0, 3, 0),
        mouthStyle: _clamp(json['mouthStyle'], 0, 3, 0),
        beardStyle: _clamp(json['beardStyle'], 0, 4, 0),
        moustacheStyle: _clamp(json['moustacheStyle'], 0, 3, 0),
        detailStyle: _clamp(json['detailStyle'], 0, 4, 0),
        customPhotoPath: _optionalPath(json['customPhotoPath']),
      );

  bool get isDefault =>
      skinTone == 2 &&
      hairStyle == 0 &&
      hairColor == 0 &&
      faceShape == 0 &&
      eyeStyle == 0 &&
      eyeColor == 0 &&
      eyebrowStyle == 0 &&
      noseStyle == 0 &&
      mouthStyle == 0 &&
      beardStyle == 0 &&
      moustacheStyle == 0 &&
      detailStyle == 0 &&
      customPhotoPath == null;

  PlayerAvatarIdentity toAvatarIdentity(
    String seedSource, {
    int age = 35,
  }) {
    final seed = stablePlayerSeed(seedSource);
    if (!isDefault) {
      return PlayerAvatarIdentity(
        seed: seed,
        skinTone: skinTone.clamp(0, 5).toInt(),
        hairStyle: hairStyle.clamp(0, 7).toInt(),
        hairColor: hairColor.clamp(0, 4).toInt(),
        faceShape: faceShape.clamp(0, 3).toInt(),
        eyeStyle: eyeStyle.clamp(0, 3).toInt(),
        eyeColor: eyeColor.clamp(0, 4).toInt(),
        eyebrowStyle: eyebrowStyle.clamp(0, 3).toInt(),
        noseStyle: noseStyle.clamp(0, 3).toInt(),
        mouthStyle: mouthStyle.clamp(0, 3).toInt(),
        beardStyle: beardStyle.clamp(0, 4).toInt(),
        moustacheStyle: moustacheStyle.clamp(0, 3).toInt(),
        detailStyle: detailStyle.clamp(0, 4).toInt(),
        ageStyle: age >= 34 ? 2 : age >= 29 ? 1 : 0,
      );
    }

    // Técnicos importados sem aparência própria não devem compartilhar a mesma
    // face. A identidade é derivada do seed estável do perfil sem persistir
    // campos novos, preservando saves e IDs existentes.
    var state = seed;
    int next(int max) {
      state = ((state * 1103515245 + 12345) & 0x7fffffff);
      return state % max;
    }

    final generatedBeard = age >= 28 && next(10) >= 5 ? 1 + next(4) : 0;
    final generatedMoustache = generatedBeard == 4 || next(10) < 6 ? 0 : 1 + next(3);
    return PlayerAvatarIdentity(
      seed: seed,
      skinTone: next(6),
      hairStyle: next(8),
      hairColor: next(5),
      faceShape: next(4),
      eyeStyle: next(4),
      eyeColor: next(5),
      eyebrowStyle: next(4),
      noseStyle: next(4),
      mouthStyle: next(4),
      beardStyle: generatedBeard,
      moustacheStyle: generatedMoustache,
      detailStyle: next(5),
      ageStyle: age >= 34 ? 2 : age >= 29 ? 1 : 0,
    );
  }

  static int _clamp(Object? value, int min, int max, int fallback) {
    if (value is! num) return fallback;
    return value.toInt().clamp(min, max).toInt();
  }

  static String? _optionalPath(Object? value) {
    if (value is! String) return null;
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }
}
