import 'dart:math';

import '../../data/name_seed.dart';
import '../../domain/contract/contract.dart';
import '../../domain/player/player.dart';
import '../../domain/player/player_attributes.dart';

abstract final class OverallCalculator {
  static int calculate({
    required PlayerPosition position,
    required TechnicalAttributes technical,
    required PhysicalAttributes physical,
    required MentalAttributes mental,
    required GoalkeeperAttributes goalkeeper,
  }) {
    double score;
    switch (position) {
      case PlayerPosition.gol:
        score = goalkeeper.reflexes * .24 + goalkeeper.positioning * .22 + goalkeeper.saving * .24 +
            goalkeeper.rushingOut * .13 + goalkeeper.aerial * .12 + mental.concentration * .05;
        break;
      case PlayerPosition.zag:
        score = technical.tackling * .27 + mental.positioning * .20 + physical.strength * .18 +
            mental.concentration * .13 + physical.speed * .08 + physical.stamina * .07 + technical.passing * .07;
        break;
      case PlayerPosition.ld:
      case PlayerPosition.le:
        score = technical.tackling * .18 + technical.crossing * .16 + physical.speed * .19 +
            physical.stamina * .15 + physical.acceleration * .12 + mental.positioning * .11 + technical.passing * .09;
        break;
      case PlayerPosition.vol:
        score = technical.tackling * .20 + technical.passing * .17 + mental.positioning * .17 +
            mental.decision * .13 + physical.stamina * .12 + physical.strength * .10 + technical.control * .11;
        break;
      case PlayerPosition.mc:
        score = technical.passing * .20 + technical.control * .16 + mental.vision * .17 + mental.decision * .14 +
            physical.stamina * .12 + technical.tackling * .08 + mental.positioning * .13;
        break;
      case PlayerPosition.mei:
        score = technical.passing * .18 + technical.control * .17 + technical.dribbling * .16 + mental.vision * .20 +
            mental.decision * .14 + technical.finishing * .08 + physical.agility * .07;
        break;
      case PlayerPosition.pe:
      case PlayerPosition.pd:
        score = physical.speed * .17 + physical.acceleration * .14 + technical.dribbling * .20 +
            technical.crossing * .12 + technical.finishing * .12 + technical.control * .12 + mental.decision * .13;
        break;
      case PlayerPosition.sa:
        score = technical.finishing * .19 + technical.dribbling * .17 + technical.control * .14 +
            mental.vision * .13 + mental.positioning * .13 + physical.acceleration * .11 + technical.passing * .13;
        break;
      case PlayerPosition.ca:
        score = technical.finishing * .28 + mental.positioning * .18 + physical.strength * .12 +
            technical.control * .12 + mental.decision * .11 + physical.acceleration * .09 + physical.speed * .10;
        break;
    }
    return score.round().clamp(35, 99).toInt();
  }
}

class PlayerFactory {
  PlayerFactory({Random? random}) : _random = random ?? Random();

  final Random _random;
  int _counter = 0;

  static const _squadPositions = <PlayerPosition>[
    PlayerPosition.gol, PlayerPosition.gol, PlayerPosition.gol,
    PlayerPosition.zag, PlayerPosition.zag, PlayerPosition.zag, PlayerPosition.zag,
    PlayerPosition.ld, PlayerPosition.ld,
    PlayerPosition.le, PlayerPosition.le,
    PlayerPosition.vol, PlayerPosition.vol,
    PlayerPosition.mc, PlayerPosition.mc,
    PlayerPosition.mei, PlayerPosition.mei,
    PlayerPosition.pe, PlayerPosition.pe,
    PlayerPosition.pd, PlayerPosition.pd,
    PlayerPosition.ca, PlayerPosition.ca, PlayerPosition.ca,
  ];

  List<Player> generateSquad({required String clubId, required int clubReputation, required int season}) {
    final base = (clubReputation - 7).clamp(58, 84).toInt();
    return _squadPositions.asMap().entries.map((entry) {
      final index = entry.key;
      final position = entry.value;
      var modifier = 0;
      if (position == PlayerPosition.gol && index > 0) modifier = -3;
      return generatePlayer(
        clubId: clubId,
        position: position,
        baseOverall: base + modifier,
        season: season,
        shirtNumber: index + 1,
      );
    }).toList();
  }

  List<Player> generateFreeAgents({required int count, required int season, int baseOverall = 70}) => List.generate(
        count,
        (index) => generatePlayer(
          clubId: null,
          position: PlayerPosition.values[_random.nextInt(PlayerPosition.values.length)],
          baseOverall: baseOverall + _random.nextInt(9) - 4,
          season: season,
        ).copyWith(listed: true, clearClubId: true),
      );

  Player generatePlayer({
    required String? clubId,
    required PlayerPosition position,
    required int baseOverall,
    required int season,
    int shirtNumber = 0,
  }) {
    final target = (baseOverall + _random.nextInt(10) - 5).clamp(40, 94).toInt();
    final age = _ageForTarget(target);
    final firstName = firstNames[_random.nextInt(firstNames.length)];
    final lastName = lastNames[_random.nextInt(lastNames.length)];
    final attributes = _buildAttributes(position, target);
    final overall = OverallCalculator.calculate(
      position: position,
      technical: attributes.$1,
      physical: attributes.$2,
      mental: attributes.$3,
      goalkeeper: attributes.$4,
    );
    final potentialGap = age <= 20 ? 6 + _random.nextInt(10) : age <= 23 ? 3 + _random.nextInt(7) : _random.nextInt(4);
    final potential = (overall + potentialGap).clamp(overall, 96).toInt();
    final marketValue = _marketValue(overall, age, potential);
    final salary = max(2000, ((marketValue * .012) / 1000).round() * 1000);
    final years = age <= 21 || age >= 30 ? 1 + _random.nextInt(2) : 1 + _random.nextInt(3);
    final birthDate = DateTime(season - age, 1 + _random.nextInt(12), 1 + _random.nextInt(27));

    return Player(
      id: '${season}_${clubId ?? 'free'}_${_counter++}_${_random.nextInt(1 << 30).toRadixString(36)}',
      firstName: firstName,
      lastName: lastName,
      displayName: _random.nextDouble() < .28 ? firstName : '$firstName ${lastName.substring(0, 1)}.',
      birthDate: birthDate,
      age: age,
      nationality: 'Brasil',
      primaryPosition: position,
      secondaryPositions: _secondaryPositions(position),
      preferredFoot: _preferredFoot(position),
      heightCm: _height(position),
      weightKg: _weight(position),
      shirtNumber: shirtNumber,
      overall: overall,
      potential: potential,
      technical: attributes.$1,
      physical: attributes.$2,
      mental: attributes.$3,
      goalkeeper: attributes.$4,
      marketValue: marketValue,
      contract: PlayerContract(salary: salary, endSeason: season + years),
      morale: 55 + _random.nextInt(16),
      condition: 92 + _random.nextInt(9),
      fatigue: _random.nextInt(7),
      discipline: const PlayerDiscipline(),
      stats: const PlayerSeasonStats(),
      history: const [],
      clubId: clubId,
      visual: VisualProfile(
        skinTone: _random.nextInt(6),
        hairStyle: _random.nextInt(8),
        hairColor: _random.nextInt(5),
        bodyType: _random.nextInt(4),
        visualHeight: .93 + _random.nextDouble() * .14,
        bootStyle: _random.nextInt(6),
      ),
    );
  }

  int _ageForTarget(int ovr) {
    if (ovr <= 65) return _random.nextDouble() < .6 ? 18 + _random.nextInt(5) : 22 + _random.nextInt(8);
    if (ovr <= 75) return 21 + _random.nextInt(12);
    return _random.nextDouble() < .75 ? 23 + _random.nextInt(7) : 29 + _random.nextInt(5);
  }

  int _marketValue(int overall, int age, int potential) {
    final raw = pow(max(1, overall - 50), 2).toDouble() * 4000;
    final agePenalty = age >= 32 ? .55 : age >= 30 ? .75 : age >= 28 ? .90 : 1.0;
    final potentialBonus = 1 + max(0, potential - overall) * .025;
    return max(50000, ((raw * agePenalty * potentialBonus) / 10000).round() * 10000);
  }

  (TechnicalAttributes, PhysicalAttributes, MentalAttributes, GoalkeeperAttributes) _buildAttributes(
    PlayerPosition position,
    int target,
  ) {
    int a([int delta = 0]) => (target + delta + _random.nextInt(13) - 6).clamp(30, 99).toInt();
    int low() => (target - 24 + _random.nextInt(12)).clamp(20, 75).toInt();

    var finishing = a();
    var passing = a();
    var crossing = a();
    var control = a();
    var dribbling = a();
    var tackling = a();
    var speed = a();
    var acceleration = a();
    var strength = a();
    var stamina = a();
    var agility = a();
    var positioning = a();
    var vision = a();
    var decision = a();
    var concentration = a();
    var leadership = a(-3);

    switch (position) {
      case PlayerPosition.gol:
        finishing = low(); dribbling = low(); crossing = low(); tackling = low(); speed = low();
        break;
      case PlayerPosition.zag:
        tackling = a(5); strength = a(4); positioning = a(4); finishing = low(); dribbling = a(-7);
        break;
      case PlayerPosition.ld:
      case PlayerPosition.le:
        speed = a(4); acceleration = a(3); stamina = a(3); crossing = a(4); tackling = a(1); finishing = a(-9);
        break;
      case PlayerPosition.vol:
        tackling = a(4); positioning = a(3); stamina = a(3); passing = a(2); finishing = a(-7);
        break;
      case PlayerPosition.mc:
        passing = a(4); vision = a(3); control = a(3); stamina = a(2); tackling = a(-1);
        break;
      case PlayerPosition.mei:
        passing = a(4); vision = a(5); control = a(4); dribbling = a(3); tackling = low();
        break;
      case PlayerPosition.pe:
      case PlayerPosition.pd:
        speed = a(5); acceleration = a(5); dribbling = a(5); crossing = a(2); tackling = low();
        break;
      case PlayerPosition.sa:
        finishing = a(3); dribbling = a(4); control = a(3); vision = a(2); tackling = low();
        break;
      case PlayerPosition.ca:
        finishing = a(6); positioning = a(5); strength = a(2); tackling = low(); crossing = a(-5);
        break;
    }

    final technical = TechnicalAttributes(
      finishing: finishing,
      passing: passing,
      crossing: crossing,
      control: control,
      dribbling: dribbling,
      tackling: tackling,
    );
    final physical = PhysicalAttributes(
      speed: speed,
      acceleration: acceleration,
      strength: strength,
      stamina: stamina,
      agility: agility,
    );
    final mental = MentalAttributes(
      positioning: positioning,
      vision: vision,
      decision: decision,
      concentration: concentration,
      leadership: leadership,
    );
    final goalkeeper = GoalkeeperAttributes(
      reflexes: position == PlayerPosition.gol ? a(5) : low(),
      positioning: position == PlayerPosition.gol ? a(4) : low(),
      saving: position == PlayerPosition.gol ? a(5) : low(),
      rushingOut: position == PlayerPosition.gol ? a(1) : low(),
      aerial: position == PlayerPosition.gol ? a(2) : low(),
    );
    return (technical, physical, mental, goalkeeper);
  }

  List<PlayerPosition> _secondaryPositions(PlayerPosition position) => switch (position) {
        PlayerPosition.gol => const [],
        PlayerPosition.ld => const [PlayerPosition.zag, PlayerPosition.pd],
        PlayerPosition.le => const [PlayerPosition.zag, PlayerPosition.pe],
        PlayerPosition.zag => const [PlayerPosition.vol, PlayerPosition.ld, PlayerPosition.le],
        PlayerPosition.vol => const [PlayerPosition.mc, PlayerPosition.zag],
        PlayerPosition.mc => const [PlayerPosition.vol, PlayerPosition.mei],
        PlayerPosition.mei => const [PlayerPosition.mc, PlayerPosition.sa],
        PlayerPosition.pe => const [PlayerPosition.pd, PlayerPosition.sa, PlayerPosition.ca],
        PlayerPosition.pd => const [PlayerPosition.pe, PlayerPosition.sa, PlayerPosition.ca],
        PlayerPosition.sa => const [PlayerPosition.mei, PlayerPosition.ca, PlayerPosition.pe, PlayerPosition.pd],
        PlayerPosition.ca => const [PlayerPosition.sa, PlayerPosition.pe, PlayerPosition.pd],
      };

  PreferredFoot _preferredFoot(PlayerPosition position) {
    if (position == PlayerPosition.le || position == PlayerPosition.pe) return _random.nextDouble() < .82 ? PreferredFoot.left : PreferredFoot.right;
    if (position == PlayerPosition.ld || position == PlayerPosition.pd) return _random.nextDouble() < .86 ? PreferredFoot.right : PreferredFoot.left;
    final roll = _random.nextDouble();
    return roll < .12 ? PreferredFoot.left : roll < .17 ? PreferredFoot.both : PreferredFoot.right;
  }

  int _height(PlayerPosition position) {
    final base = switch (position) {
      PlayerPosition.gol => 188,
      PlayerPosition.zag => 184,
      PlayerPosition.ca => 181,
      _ => 177,
    };
    return base + _random.nextInt(11) - 5;
  }

  int _weight(PlayerPosition position) {
    final base = switch (position) {
      PlayerPosition.gol => 84,
      PlayerPosition.zag => 82,
      PlayerPosition.ca => 79,
      _ => 74,
    };
    return base + _random.nextInt(9) - 4;
  }
}
