enum ManagerEmploymentStatus { employed, unemployed }

class ManagerClubTenure {
  const ManagerClubTenure({
    required this.clubId,
    required this.startedAt,
    required this.startSeason,
    this.endedAt,
    this.endSeason,
    this.endReason = '',
  });

  final String clubId;
  final DateTime startedAt;
  final int startSeason;
  final DateTime? endedAt;
  final int? endSeason;
  final String endReason;

  bool get active => endedAt == null;

  ManagerClubTenure copyWith({
    DateTime? endedAt,
    int? endSeason,
    String? endReason,
  }) =>
      ManagerClubTenure(
        clubId: clubId,
        startedAt: startedAt,
        startSeason: startSeason,
        endedAt: endedAt ?? this.endedAt,
        endSeason: endSeason ?? this.endSeason,
        endReason: endReason ?? this.endReason,
      );

  Map<String, dynamic> toJson() => {
        'clubId': clubId,
        'startedAt': startedAt.toIso8601String(),
        'startSeason': startSeason,
        'endedAt': endedAt?.toIso8601String(),
        'endSeason': endSeason,
        'endReason': endReason,
      };

  factory ManagerClubTenure.fromJson(Map<String, dynamic> json) =>
      ManagerClubTenure(
        clubId: json['clubId'] as String? ?? '',
        startedAt: DateTime.tryParse(json['startedAt'] as String? ?? '') ??
            DateTime(json['startSeason'] as int? ?? 2026),
        startSeason: json['startSeason'] as int? ?? 2026,
        endedAt: DateTime.tryParse(json['endedAt'] as String? ?? ''),
        endSeason: json['endSeason'] as int?,
        endReason: json['endReason'] as String? ?? '',
      );
}

class ManagerJobOffer {
  const ManagerJobOffer({
    required this.id,
    required this.clubId,
    required this.createdAt,
    required this.expiresAt,
    required this.interestScore,
    required this.reason,
  });

  final String id;
  final String clubId;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int interestScore;
  final String reason;

  bool isActiveOn(DateTime date) => !date.isAfter(expiresAt);

  Map<String, dynamic> toJson() => {
        'id': id,
        'clubId': clubId,
        'createdAt': createdAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
        'interestScore': interestScore,
        'reason': reason,
      };

  factory ManagerJobOffer.fromJson(Map<String, dynamic> json) => ManagerJobOffer(
        id: json['id'] as String? ?? '',
        clubId: json['clubId'] as String? ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime(2026),
        expiresAt: DateTime.tryParse(json['expiresAt'] as String? ?? '') ??
            DateTime(2026, 1, 8),
        interestScore: (json['interestScore'] as int? ?? 50).clamp(0, 100).toInt(),
        reason: json['reason'] as String? ?? '',
      );
}

class ManagerCareerState {
  const ManagerCareerState({
    required this.status,
    required this.tenures,
    required this.offers,
  });

  final ManagerEmploymentStatus status;
  final List<ManagerClubTenure> tenures;
  final List<ManagerJobOffer> offers;

  bool get isEmployed => status == ManagerEmploymentStatus.employed;
  bool get isUnemployed => !isEmployed;

  ManagerClubTenure? get activeTenure {
    for (final tenure in tenures.reversed) {
      if (tenure.active) return tenure;
    }
    return null;
  }

  factory ManagerCareerState.initial({
    required String clubId,
    required int season,
    required DateTime startedAt,
  }) =>
      ManagerCareerState(
        status: ManagerEmploymentStatus.employed,
        tenures: [
          ManagerClubTenure(
            clubId: clubId,
            startedAt: startedAt,
            startSeason: season,
          ),
        ],
        offers: const [],
      );

  ManagerCareerState copyWith({
    ManagerEmploymentStatus? status,
    List<ManagerClubTenure>? tenures,
    List<ManagerJobOffer>? offers,
  }) =>
      ManagerCareerState(
        status: status ?? this.status,
        tenures: tenures ?? this.tenures,
        offers: offers ?? this.offers,
      );

  Map<String, dynamic> toJson() => {
        'status': status.name,
        'tenures': tenures.map((item) => item.toJson()).toList(),
        'offers': offers.map((item) => item.toJson()).toList(),
      };

  factory ManagerCareerState.fromJson(
    Map<String, dynamic> json, {
    required String fallbackClubId,
    required int fallbackSeason,
    required DateTime fallbackDate,
  }) {
    final tenures = ((json['tenures'] as List?) ?? const [])
        .whereType<Map>()
        .map((item) => ManagerClubTenure.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .where((item) => item.clubId.isNotEmpty)
        .toList();
    final offers = ((json['offers'] as List?) ?? const [])
        .whereType<Map>()
        .map((item) => ManagerJobOffer.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .where((item) => item.id.isNotEmpty && item.clubId.isNotEmpty)
        .toList();
    final status = ManagerEmploymentStatus.values.firstWhere(
      (value) => value.name == json['status'],
      orElse: () => ManagerEmploymentStatus.employed,
    );
    return ManagerCareerState(
      status: status,
      tenures: tenures.isEmpty
          ? [
              ManagerClubTenure(
                clubId: fallbackClubId,
                startedAt: fallbackDate,
                startSeason: fallbackSeason,
              ),
            ]
          : tenures,
      offers: offers,
    );
  }
}
