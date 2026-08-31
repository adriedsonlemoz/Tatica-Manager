import '../contract/contract.dart';
import 'player_attributes.dart';

enum PlayerPosition { gol, ld, le, zag, vol, mc, mei, pe, pd, sa, ca }

enum PreferredFoot { right, left, both }

enum PlayerAvailabilityStatus { available, injured, suspended, lowCondition }

/// Vínculo temporário persistido no atleta enquanto ele está emprestado.
/// O contrato continua pertencendo ao clube em [parentClubId].
class PlayerLoan {
  const PlayerLoan({
    required this.parentClubId,
    required this.endsAt,
  });

  final String parentClubId;
  final DateTime endsAt;

  bool isDueOn(DateTime date) {
    final due = DateTime(endsAt.year, endsAt.month, endsAt.day);
    final current = DateTime(date.year, date.month, date.day);
    return !due.isAfter(current);
  }

  Map<String, dynamic> toJson() => {
        'parentClubId': parentClubId,
        'endsAt': endsAt.toIso8601String(),
      };

  factory PlayerLoan.fromJson(Map<String, dynamic> json) => PlayerLoan(
        parentClubId: json['parentClubId'] as String? ?? '',
        endsAt: DateTime.tryParse(json['endsAt'] as String? ?? '') ??
            DateTime(2026, 12, 31),
      );
}

extension PlayerPositionX on PlayerPosition {
  String get label => switch (this) {
        PlayerPosition.gol => 'GOL',
        PlayerPosition.ld => 'LD',
        PlayerPosition.le => 'LE',
        PlayerPosition.zag => 'ZAG',
        PlayerPosition.vol => 'VOL',
        PlayerPosition.mc => 'MC',
        PlayerPosition.mei => 'MEI',
        PlayerPosition.pe => 'PE',
        PlayerPosition.pd => 'PD',
        PlayerPosition.sa => 'SA',
        PlayerPosition.ca => 'CA',
      };

  static PlayerPosition fromLabel(String label) => PlayerPosition.values.firstWhere(
        (position) => position.label == label,
        orElse: () => PlayerPosition.ca,
      );
}

class PlayerInjury {
  const PlayerInjury({required this.name, required this.roundsRemaining});

  final String name;
  final int roundsRemaining;

  Map<String, dynamic> toJson() => {
        'name': name,
        'roundsRemaining': roundsRemaining,
      };

  factory PlayerInjury.fromJson(Map<String, dynamic> json) => PlayerInjury(
        name: json['name'] as String? ?? 'Lesão',
        roundsRemaining: json['roundsRemaining'] as int? ?? 1,
      );
}

class PlayerDiscipline {
  const PlayerDiscipline({
    this.yellowCards = 0,
    this.redCards = 0,
    this.suspendedRounds = 0,
  });

  final int yellowCards;
  final int redCards;
  final int suspendedRounds;

  Map<String, dynamic> toJson() => {
        'yellowCards': yellowCards,
        'redCards': redCards,
        'suspendedRounds': suspendedRounds,
      };

  factory PlayerDiscipline.fromJson(Map<String, dynamic> json) => PlayerDiscipline(
        yellowCards: json['yellowCards'] as int? ?? 0,
        redCards: json['redCards'] as int? ?? 0,
        suspendedRounds: json['suspendedRounds'] as int? ?? 0,
      );

  PlayerDiscipline copyWith({
    int? yellowCards,
    int? redCards,
    int? suspendedRounds,
  }) =>
      PlayerDiscipline(
        yellowCards: yellowCards ?? this.yellowCards,
        redCards: redCards ?? this.redCards,
        suspendedRounds: suspendedRounds ?? this.suspendedRounds,
      );
}

class PlayerSeasonStats {
  const PlayerSeasonStats({
    this.appearances = 0,
    this.starts = 0,
    this.minutes = 0,
    this.goals = 0,
    this.assists = 0,
    this.yellowCards = 0,
    this.redCards = 0,
    this.ratingTotal = 0,
  });

  final int appearances;
  final int starts;
  final int minutes;
  final int goals;
  final int assists;
  final int yellowCards;
  final int redCards;
  final double ratingTotal;

  double get averageRating => appearances == 0 ? 0 : ratingTotal / appearances;

  Map<String, dynamic> toJson() => {
        'appearances': appearances,
        'starts': starts,
        'minutes': minutes,
        'goals': goals,
        'assists': assists,
        'yellowCards': yellowCards,
        'redCards': redCards,
        'ratingTotal': ratingTotal,
      };

  factory PlayerSeasonStats.fromJson(Map<String, dynamic> json) => PlayerSeasonStats(
        appearances: json['appearances'] as int? ?? 0,
        starts: json['starts'] as int? ?? 0,
        minutes: json['minutes'] as int? ?? 0,
        goals: json['goals'] as int? ?? 0,
        assists: json['assists'] as int? ?? 0,
        yellowCards: json['yellowCards'] as int? ?? 0,
        redCards: json['redCards'] as int? ?? 0,
        ratingTotal: (json['ratingTotal'] as num?)?.toDouble() ?? 0,
      );

  PlayerSeasonStats copyWith({
    int? appearances,
    int? starts,
    int? minutes,
    int? goals,
    int? assists,
    int? yellowCards,
    int? redCards,
    double? ratingTotal,
  }) =>
      PlayerSeasonStats(
        appearances: appearances ?? this.appearances,
        starts: starts ?? this.starts,
        minutes: minutes ?? this.minutes,
        goals: goals ?? this.goals,
        assists: assists ?? this.assists,
        yellowCards: yellowCards ?? this.yellowCards,
        redCards: redCards ?? this.redCards,
        ratingTotal: ratingTotal ?? this.ratingTotal,
      );
}

class PlayerHistoryEntry {
  const PlayerHistoryEntry({
    required this.season,
    required this.clubName,
    required this.overall,
  });

  final int season;
  final String clubName;
  final int overall;

  Map<String, dynamic> toJson() => {
        'season': season,
        'clubName': clubName,
        'overall': overall,
      };

  factory PlayerHistoryEntry.fromJson(Map<String, dynamic> json) => PlayerHistoryEntry(
        season: json['season'] as int? ?? 2026,
        clubName: json['clubName'] as String? ?? '',
        overall: json['overall'] as int? ?? 50,
      );
}

class Player {
  const Player({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.displayName,
    required this.birthDate,
    required this.age,
    required this.nationality,
    required this.primaryPosition,
    required this.secondaryPositions,
    required this.preferredFoot,
    required this.heightCm,
    required this.weightKg,
    this.shirtNumber = 0,
    required this.overall,
    required this.potential,
    required this.technical,
    required this.physical,
    required this.mental,
    required this.goalkeeper,
    required this.marketValue,
    required this.contract,
    required this.morale,
    required this.condition,
    required this.fatigue,
    required this.discipline,
    required this.stats,
    required this.history,
    required this.visual,
    this.injury,
    this.clubId,
    this.listed = false,
    this.availableForLoan = false,
    this.loan,
    this.customAvatarPath,
    this.recentRatings = const [],
  });

  final String id;
  final String firstName;
  final String lastName;
  final String displayName;
  final DateTime birthDate;
  final int age;
  final String nationality;
  final PlayerPosition primaryPosition;
  final List<PlayerPosition> secondaryPositions;
  final PreferredFoot preferredFoot;
  final int heightCm;
  final int weightKg;
  final int shirtNumber;
  final int overall;
  final int potential;
  final TechnicalAttributes technical;
  final PhysicalAttributes physical;
  final MentalAttributes mental;
  final GoalkeeperAttributes goalkeeper;
  final int marketValue;
  final PlayerContract contract;
  final int morale;
  final int condition;
  final int fatigue;
  final PlayerInjury? injury;
  final PlayerDiscipline discipline;
  final PlayerSeasonStats stats;
  final List<PlayerHistoryEntry> history;
  final String? clubId;
  final bool listed;
  final bool availableForLoan;
  final PlayerLoan? loan;
  final VisualProfile visual;

  /// Caminho de uma cópia normalizada mantida no armazenamento privado do app.
  /// É opcional e retrocompatível: saves anteriores continuam usando o avatar
  /// procedural derivado do Player.id/VisualProfile.
  final String? customAvatarPath;

  /// Últimas notas do atleta, do jogo mais antigo ao mais recente. O controller
  /// de pós-jogo mantém no máximo cinco itens para representar a forma recente.
  final List<double> recentRatings;

  PlayerAvailabilityStatus get availabilityStatus {
    if (injury != null) return PlayerAvailabilityStatus.injured;
    if (discipline.suspendedRounds > 0) return PlayerAvailabilityStatus.suspended;
    if (condition < 35) return PlayerAvailabilityStatus.lowCondition;
    return PlayerAvailabilityStatus.available;
  }

  bool get isAvailable => availabilityStatus == PlayerAvailabilityStatus.available;
  int get salary => contract.salary;

  double? get recentFormAverage {
    if (recentRatings.isEmpty) return null;
    return recentRatings.reduce((a, b) => a + b) / recentRatings.length;
  }

  Player copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? displayName,
    DateTime? birthDate,
    int? age,
    String? nationality,
    PlayerPosition? primaryPosition,
    List<PlayerPosition>? secondaryPositions,
    PreferredFoot? preferredFoot,
    int? heightCm,
    int? weightKg,
    int? shirtNumber,
    int? overall,
    int? potential,
    TechnicalAttributes? technical,
    PhysicalAttributes? physical,
    MentalAttributes? mental,
    GoalkeeperAttributes? goalkeeper,
    int? marketValue,
    PlayerContract? contract,
    int? morale,
    int? condition,
    int? fatigue,
    PlayerInjury? injury,
    bool clearInjury = false,
    PlayerDiscipline? discipline,
    PlayerSeasonStats? stats,
    List<PlayerHistoryEntry>? history,
    String? clubId,
    bool clearClubId = false,
    bool? listed,
    bool? availableForLoan,
    PlayerLoan? loan,
    bool clearLoan = false,
    VisualProfile? visual,
    String? customAvatarPath,
    bool clearCustomAvatar = false,
    List<double>? recentRatings,
  }) =>
      Player(
        id: id ?? this.id,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        displayName: displayName ?? this.displayName,
        birthDate: birthDate ?? this.birthDate,
        age: age ?? this.age,
        nationality: nationality ?? this.nationality,
        primaryPosition: primaryPosition ?? this.primaryPosition,
        secondaryPositions: secondaryPositions ?? this.secondaryPositions,
        preferredFoot: preferredFoot ?? this.preferredFoot,
        heightCm: heightCm ?? this.heightCm,
        weightKg: weightKg ?? this.weightKg,
        shirtNumber: shirtNumber ?? this.shirtNumber,
        overall: overall ?? this.overall,
        potential: potential ?? this.potential,
        technical: technical ?? this.technical,
        physical: physical ?? this.physical,
        mental: mental ?? this.mental,
        goalkeeper: goalkeeper ?? this.goalkeeper,
        marketValue: marketValue ?? this.marketValue,
        contract: contract ?? this.contract,
        morale: morale ?? this.morale,
        condition: condition ?? this.condition,
        fatigue: fatigue ?? this.fatigue,
        injury: clearInjury ? null : (injury ?? this.injury),
        discipline: discipline ?? this.discipline,
        stats: stats ?? this.stats,
        history: history ?? this.history,
        clubId: clearClubId ? null : (clubId ?? this.clubId),
        listed: listed ?? this.listed,
        availableForLoan: availableForLoan ?? this.availableForLoan,
        loan: clearLoan ? null : (loan ?? this.loan),
        visual: visual ?? this.visual,
        customAvatarPath:
            clearCustomAvatar ? null : (customAvatarPath ?? this.customAvatarPath),
        recentRatings: recentRatings ?? this.recentRatings,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'displayName': displayName,
        'birthDate': birthDate.toIso8601String(),
        'age': age,
        'nationality': nationality,
        'primaryPosition': primaryPosition.label,
        'secondaryPositions': secondaryPositions.map((e) => e.label).toList(),
        'preferredFoot': preferredFoot.name,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'shirtNumber': shirtNumber,
        'overall': overall,
        'potential': potential,
        'technical': technical.toJson(),
        'physical': physical.toJson(),
        'mental': mental.toJson(),
        'goalkeeper': goalkeeper.toJson(),
        'marketValue': marketValue,
        'contract': contract.toJson(),
        'morale': morale,
        'condition': condition,
        'fatigue': fatigue,
        'injury': injury?.toJson(),
        'discipline': discipline.toJson(),
        'stats': stats.toJson(),
        'history': history.map((e) => e.toJson()).toList(),
        'clubId': clubId,
        'listed': listed,
        'availableForLoan': availableForLoan,
        if (loan != null) 'loan': loan!.toJson(),
        'visual': visual.toJson(),
        if (customAvatarPath != null) 'customAvatarPath': customAvatarPath,
        if (recentRatings.isNotEmpty) 'recentRatings': recentRatings,
      };

  static List<double> _recentRatingsFromJson(Object? raw) {
    final values = ((raw as List?) ?? const [])
        .map((value) => (value as num).toDouble())
        .toList();
    return values.length <= 5 ? values : values.sublist(values.length - 5);
  }

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json['id'] as String,
        firstName: json['firstName'] as String? ?? '',
        lastName: json['lastName'] as String? ?? '',
        displayName: json['displayName'] as String? ?? '',
        birthDate: DateTime.tryParse(json['birthDate'] as String? ?? '') ?? DateTime(2000),
        age: json['age'] as int? ?? 26,
        nationality: json['nationality'] as String? ?? 'Brasil',
        primaryPosition: PlayerPositionX.fromLabel(json['primaryPosition'] as String? ?? 'CA'),
        secondaryPositions: ((json['secondaryPositions'] as List?) ?? const [])
            .map((e) => PlayerPositionX.fromLabel(e.toString()))
            .toList(),
        preferredFoot: PreferredFoot.values.firstWhere(
          (foot) => foot.name == json['preferredFoot'],
          orElse: () => PreferredFoot.right,
        ),
        heightCm: json['heightCm'] as int? ?? 178,
        weightKg: json['weightKg'] as int? ?? 76,
        shirtNumber: json['shirtNumber'] as int? ?? 0,
        overall: json['overall'] as int? ?? 50,
        potential: json['potential'] as int? ?? 60,
        technical: TechnicalAttributes.fromJson(
          Map<String, dynamic>.from(json['technical'] as Map? ?? const {}),
        ),
        physical: PhysicalAttributes.fromJson(
          Map<String, dynamic>.from(json['physical'] as Map? ?? const {}),
        ),
        mental: MentalAttributes.fromJson(
          Map<String, dynamic>.from(json['mental'] as Map? ?? const {}),
        ),
        goalkeeper: GoalkeeperAttributes.fromJson(
          Map<String, dynamic>.from(json['goalkeeper'] as Map? ?? const {}),
        ),
        marketValue: json['marketValue'] as int? ?? 50000,
        contract: PlayerContract.fromJson(
          Map<String, dynamic>.from(json['contract'] as Map? ?? const {}),
        ),
        morale: json['morale'] as int? ?? 60,
        condition: json['condition'] as int? ?? 100,
        fatigue: json['fatigue'] as int? ?? 0,
        injury: json['injury'] == null
            ? null
            : PlayerInjury.fromJson(
                Map<String, dynamic>.from(json['injury'] as Map),
              ),
        discipline: PlayerDiscipline.fromJson(
          Map<String, dynamic>.from(json['discipline'] as Map? ?? const {}),
        ),
        stats: PlayerSeasonStats.fromJson(
          Map<String, dynamic>.from(json['stats'] as Map? ?? const {}),
        ),
        history: ((json['history'] as List?) ?? const [])
            .map((e) => PlayerHistoryEntry.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        clubId: json['clubId'] as String?,
        listed: json['listed'] as bool? ?? false,
        availableForLoan: json['availableForLoan'] as bool? ?? false,
        loan: json['loan'] is Map
            ? PlayerLoan.fromJson(Map<String, dynamic>.from(json['loan'] as Map))
            : null,
        visual: VisualProfile.fromJson(
          Map<String, dynamic>.from(json['visual'] as Map? ?? const {}),
        ),
        customAvatarPath: json['customAvatarPath'] as String?,
        recentRatings: _recentRatingsFromJson(json['recentRatings']),
      );
}
