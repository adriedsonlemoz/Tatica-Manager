import 'sponsorship.dart';

enum ClubDepartment {
  transfers,
  payroll,
  infrastructure,
  youthAcademy,
  stadium,
  operations,
}

extension ClubDepartmentX on ClubDepartment {
  String get label => switch (this) {
        ClubDepartment.transfers => 'Transferências',
        ClubDepartment.payroll => 'Salários',
        ClubDepartment.infrastructure => 'Estrutura',
        ClubDepartment.youthAcademy => 'Categoria de base',
        ClubDepartment.stadium => 'Estádio',
        ClubDepartment.operations => 'Outros departamentos',
      };
}

class ClubBudgetPlan {
  const ClubBudgetPlan({
    this.season = 0,
    this.clubId = '',
    this.available = const {},
  });

  final int season;
  final String clubId;
  final Map<ClubDepartment, int> available;

  bool get isConfigured =>
      season > 0 && clubId.isNotEmpty && available.isNotEmpty;

  int forDepartment(ClubDepartment department) =>
      available[department] ?? 0;

  int get totalAvailable =>
      available.values.fold<int>(0, (sum, value) => sum + value);

  ClubBudgetPlan copyWith({
    int? season,
    String? clubId,
    Map<ClubDepartment, int>? available,
  }) =>
      ClubBudgetPlan(
        season: season ?? this.season,
        clubId: clubId ?? this.clubId,
        available: available ?? this.available,
      );

  ClubBudgetPlan spend(ClubDepartment department, int amount) {
    if (amount < 0 || amount > forDepartment(department)) {
      throw StateError('Orçamento insuficiente em ${department.label}.');
    }
    return copyWith(
      available: {
        ...available,
        department: forDepartment(department) - amount,
      },
    );
  }

  Map<String, dynamic> toJson() => {
        'season': season,
        'clubId': clubId,
        'available': {
          for (final department in ClubDepartment.values)
            department.name: forDepartment(department),
        },
      };

  factory ClubBudgetPlan.fromJson(Map<String, dynamic> json) {
    final raw = Map<String, dynamic>.from(
      json['available'] as Map? ?? const {},
    );
    return ClubBudgetPlan(
      season: json['season'] as int? ?? 0,
      clubId: json['clubId'] as String? ?? '',
      available: {
        for (final department in ClubDepartment.values)
          department: (raw[department.name] as num?)?.toInt() ?? 0,
      },
    );
  }
}

class ClubAdministrationState {
  const ClubAdministrationState({
    this.budgetPlan = const ClubBudgetPlan(),
    this.sponsorshipProposals = const [],
  });

  final ClubBudgetPlan budgetPlan;
  final List<SponsorshipProposal> sponsorshipProposals;

  ClubAdministrationState copyWith({
    ClubBudgetPlan? budgetPlan,
    List<SponsorshipProposal>? sponsorshipProposals,
  }) =>
      ClubAdministrationState(
        budgetPlan: budgetPlan ?? this.budgetPlan,
        sponsorshipProposals:
            sponsorshipProposals ?? this.sponsorshipProposals,
      );

  Map<String, dynamic> toJson() => {
        'budgetPlan': budgetPlan.toJson(),
        'sponsorshipProposals': sponsorshipProposals
            .map((proposal) => proposal.toJson())
            .toList(growable: false),
      };

  factory ClubAdministrationState.fromJson(Map<String, dynamic> json) =>
      ClubAdministrationState(
        budgetPlan: ClubBudgetPlan.fromJson(
          Map<String, dynamic>.from(json['budgetPlan'] as Map? ?? const {}),
        ),
        sponsorshipProposals:
            ((json['sponsorshipProposals'] as List?) ?? const [])
                .whereType<Map>()
                .map(
                  (item) => SponsorshipProposal.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .where((proposal) => proposal.id.isNotEmpty)
                .toList(growable: false),
      );
}
