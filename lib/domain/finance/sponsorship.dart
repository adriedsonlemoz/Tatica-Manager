enum SponsorshipType {
  main,
  kit,
  stadium,
  sleeve,
  commercial,
}

extension SponsorshipTypeX on SponsorshipType {
  String get label => switch (this) {
        SponsorshipType.main => 'Patrocinador master',
        SponsorshipType.kit => 'Material esportivo',
        SponsorshipType.stadium => 'Naming rights / estádio',
        SponsorshipType.sleeve => 'Manga do uniforme',
        SponsorshipType.commercial => 'Parceiro comercial',
      };

  String get shortLabel => switch (this) {
        SponsorshipType.main => 'Master',
        SponsorshipType.kit => 'Uniforme',
        SponsorshipType.stadium => 'Estádio',
        SponsorshipType.sleeve => 'Manga',
        SponsorshipType.commercial => 'Comercial',
      };
}

class SponsorshipContract {
  const SponsorshipContract({
    required this.id,
    required this.sponsorName,
    required this.type,
    required this.annualValue,
    required this.startSeason,
    required this.endSeason,
    this.performanceBonus = 0,
    this.negotiable = true,
  });

  final String id;
  final String sponsorName;
  final SponsorshipType type;
  final int annualValue;
  final int startSeason;
  final int endSeason;
  final int performanceBonus;
  final bool negotiable;

  bool isActiveIn(int season) => season >= startSeason && season <= endSeason;

  int get durationSeasons => endSeason - startSeason + 1;

  int valueForRound({int roundsPerSeason = 38}) =>
      roundsPerSeason <= 0 ? annualValue : (annualValue / roundsPerSeason).round();

  SponsorshipContract copyWith({
    String? sponsorName,
    SponsorshipType? type,
    int? annualValue,
    int? startSeason,
    int? endSeason,
    int? performanceBonus,
    bool? negotiable,
  }) =>
      SponsorshipContract(
        id: id,
        sponsorName: sponsorName ?? this.sponsorName,
        type: type ?? this.type,
        annualValue: annualValue ?? this.annualValue,
        startSeason: startSeason ?? this.startSeason,
        endSeason: endSeason ?? this.endSeason,
        performanceBonus: performanceBonus ?? this.performanceBonus,
        negotiable: negotiable ?? this.negotiable,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'sponsorName': sponsorName,
        'type': type.name,
        'annualValue': annualValue,
        'startSeason': startSeason,
        'endSeason': endSeason,
        'performanceBonus': performanceBonus,
        'negotiable': negotiable,
      };

  factory SponsorshipContract.fromJson(Map<String, dynamic> json) =>
      SponsorshipContract(
        id: json['id'] as String? ?? '',
        sponsorName: json['sponsorName'] as String? ?? 'Parceiro comercial',
        type: SponsorshipType.values.firstWhere(
          (value) => value.name == json['type'],
          orElse: () => SponsorshipType.commercial,
        ),
        annualValue: json['annualValue'] as int? ?? 0,
        startSeason: json['startSeason'] as int? ?? 2026,
        endSeason: json['endSeason'] as int? ??
            (json['startSeason'] as int? ?? 2026),
        performanceBonus: json['performanceBonus'] as int? ?? 0,
        negotiable: json['negotiable'] as bool? ?? true,
      );
}

enum SponsorshipProposalStatus {
  pending,
  countered,
  accepted,
  rejected,
  expired,
}

extension SponsorshipProposalStatusX on SponsorshipProposalStatus {
  String get label => switch (this) {
        SponsorshipProposalStatus.pending => 'Aguardando decisão',
        SponsorshipProposalStatus.countered => 'Contraproposta recebida',
        SponsorshipProposalStatus.accepted => 'Aceita',
        SponsorshipProposalStatus.rejected => 'Recusada',
        SponsorshipProposalStatus.expired => 'Expirada',
      };
}

class SponsorshipProposal {
  const SponsorshipProposal({
    required this.id,
    required this.sponsorName,
    required this.type,
    required this.annualValue,
    required this.durationSeasons,
    required this.performanceBonus,
    required this.objective,
    required this.conditions,
    required this.offeredAt,
    required this.expiresAt,
    this.negotiatedAnnualValue,
    this.status = SponsorshipProposalStatus.pending,
  });

  final String id;
  final String sponsorName;
  final SponsorshipType type;
  final int annualValue;
  final int durationSeasons;
  final int performanceBonus;
  final String objective;
  final String conditions;
  final DateTime offeredAt;
  final DateTime expiresAt;
  final int? negotiatedAnnualValue;
  final SponsorshipProposalStatus status;

  int get currentAnnualValue => negotiatedAnnualValue ?? annualValue;
  bool get canRespond =>
      status == SponsorshipProposalStatus.pending ||
      status == SponsorshipProposalStatus.countered;

  bool isExpiredAt(DateTime date) => date.isAfter(expiresAt);

  SponsorshipProposal copyWith({
    int? negotiatedAnnualValue,
    bool clearNegotiatedAnnualValue = false,
    SponsorshipProposalStatus? status,
  }) =>
      SponsorshipProposal(
        id: id,
        sponsorName: sponsorName,
        type: type,
        annualValue: annualValue,
        durationSeasons: durationSeasons,
        performanceBonus: performanceBonus,
        objective: objective,
        conditions: conditions,
        offeredAt: offeredAt,
        expiresAt: expiresAt,
        negotiatedAnnualValue: clearNegotiatedAnnualValue
            ? null
            : (negotiatedAnnualValue ?? this.negotiatedAnnualValue),
        status: status ?? this.status,
      );

  SponsorshipContract toContract(int season) => SponsorshipContract(
        id: 'contract-$id',
        sponsorName: sponsorName,
        type: type,
        annualValue: currentAnnualValue,
        startSeason: season,
        endSeason: season + durationSeasons - 1,
        performanceBonus: performanceBonus,
        negotiable: false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'sponsorName': sponsorName,
        'type': type.name,
        'annualValue': annualValue,
        'durationSeasons': durationSeasons,
        'performanceBonus': performanceBonus,
        'objective': objective,
        'conditions': conditions,
        'offeredAt': offeredAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
        'negotiatedAnnualValue': negotiatedAnnualValue,
        'status': status.name,
      };

  factory SponsorshipProposal.fromJson(Map<String, dynamic> json) =>
      SponsorshipProposal(
        id: json['id'] as String? ?? '',
        sponsorName: json['sponsorName'] as String? ?? 'Parceiro comercial',
        type: SponsorshipType.values.firstWhere(
          (value) => value.name == json['type'],
          orElse: () => SponsorshipType.commercial,
        ),
        annualValue: json['annualValue'] as int? ?? 0,
        durationSeasons: json['durationSeasons'] as int? ?? 1,
        performanceBonus: json['performanceBonus'] as int? ?? 0,
        objective: json['objective'] as String? ?? 'Fortalecer a marca do clube.',
        conditions: json['conditions'] as String? ?? 'Pagamento dividido por rodada.',
        offeredAt:
            DateTime.tryParse(json['offeredAt'] as String? ?? '') ??
                DateTime(2026),
        expiresAt:
            DateTime.tryParse(json['expiresAt'] as String? ?? '') ??
                DateTime(2026, 12, 31),
        negotiatedAnnualValue:
            (json['negotiatedAnnualValue'] as num?)?.toInt(),
        status: SponsorshipProposalStatus.values.firstWhere(
          (value) => value.name == json['status'],
          orElse: () => SponsorshipProposalStatus.pending,
        ),
      );
}
