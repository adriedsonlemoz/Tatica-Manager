class TechnicalAttributes {
  const TechnicalAttributes({
    required this.finishing,
    required this.passing,
    required this.crossing,
    required this.control,
    required this.dribbling,
    required this.tackling,
  });

  final int finishing;
  final int passing;
  final int crossing;
  final int control;
  final int dribbling;
  final int tackling;

  Map<String, dynamic> toJson() => {
        'finishing': finishing,
        'passing': passing,
        'crossing': crossing,
        'control': control,
        'dribbling': dribbling,
        'tackling': tackling,
      };

  factory TechnicalAttributes.fromJson(Map<String, dynamic> json) => TechnicalAttributes(
        finishing: json['finishing'] as int? ?? 50,
        passing: json['passing'] as int? ?? 50,
        crossing: json['crossing'] as int? ?? 50,
        control: json['control'] as int? ?? 50,
        dribbling: json['dribbling'] as int? ?? 50,
        tackling: json['tackling'] as int? ?? 50,
      );
}

class PhysicalAttributes {
  const PhysicalAttributes({
    required this.speed,
    required this.acceleration,
    required this.strength,
    required this.stamina,
    required this.agility,
  });

  final int speed;
  final int acceleration;
  final int strength;
  final int stamina;
  final int agility;

  Map<String, dynamic> toJson() => {
        'speed': speed,
        'acceleration': acceleration,
        'strength': strength,
        'stamina': stamina,
        'agility': agility,
      };

  factory PhysicalAttributes.fromJson(Map<String, dynamic> json) => PhysicalAttributes(
        speed: json['speed'] as int? ?? 50,
        acceleration: json['acceleration'] as int? ?? 50,
        strength: json['strength'] as int? ?? 50,
        stamina: json['stamina'] as int? ?? 50,
        agility: json['agility'] as int? ?? 50,
      );
}

class MentalAttributes {
  const MentalAttributes({
    required this.positioning,
    required this.vision,
    required this.decision,
    required this.concentration,
    required this.leadership,
  });

  final int positioning;
  final int vision;
  final int decision;
  final int concentration;
  final int leadership;

  Map<String, dynamic> toJson() => {
        'positioning': positioning,
        'vision': vision,
        'decision': decision,
        'concentration': concentration,
        'leadership': leadership,
      };

  factory MentalAttributes.fromJson(Map<String, dynamic> json) => MentalAttributes(
        positioning: json['positioning'] as int? ?? 50,
        vision: json['vision'] as int? ?? 50,
        decision: json['decision'] as int? ?? 50,
        concentration: json['concentration'] as int? ?? 50,
        leadership: json['leadership'] as int? ?? 50,
      );
}

class GoalkeeperAttributes {
  const GoalkeeperAttributes({
    required this.reflexes,
    required this.positioning,
    required this.saving,
    required this.rushingOut,
    required this.aerial,
  });

  final int reflexes;
  final int positioning;
  final int saving;
  final int rushingOut;
  final int aerial;

  Map<String, dynamic> toJson() => {
        'reflexes': reflexes,
        'positioning': positioning,
        'saving': saving,
        'rushingOut': rushingOut,
        'aerial': aerial,
      };

  factory GoalkeeperAttributes.fromJson(Map<String, dynamic> json) => GoalkeeperAttributes(
        reflexes: json['reflexes'] as int? ?? 40,
        positioning: json['positioning'] as int? ?? 40,
        saving: json['saving'] as int? ?? 40,
        rushingOut: json['rushingOut'] as int? ?? 40,
        aerial: json['aerial'] as int? ?? 40,
      );
}

class VisualProfile {
  const VisualProfile({
    required this.skinTone,
    required this.hairStyle,
    required this.hairColor,
    required this.bodyType,
    required this.visualHeight,
    required this.bootStyle,
  });

  final int skinTone;
  final int hairStyle;
  final int hairColor;
  final int bodyType;
  final double visualHeight;
  final int bootStyle;

  Map<String, dynamic> toJson() => {
        'skinTone': skinTone,
        'hairStyle': hairStyle,
        'hairColor': hairColor,
        'bodyType': bodyType,
        'visualHeight': visualHeight,
        'bootStyle': bootStyle,
      };

  factory VisualProfile.fromJson(Map<String, dynamic> json) => VisualProfile(
        skinTone: json['skinTone'] as int? ?? 2,
        hairStyle: json['hairStyle'] as int? ?? 0,
        hairColor: json['hairColor'] as int? ?? 0,
        bodyType: json['bodyType'] as int? ?? 1,
        visualHeight: (json['visualHeight'] as num?)?.toDouble() ?? 1,
        bootStyle: json['bootStyle'] as int? ?? 0,
      );
}
