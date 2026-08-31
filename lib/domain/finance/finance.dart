enum FinanceKind {
  matchIncome,
  matchday,
  hospitality,
  retail,
  food,
  stadiumAdvertising,
  tvRights,
  sponsorship,
  prizeMoney,
  playerSale,
  transferIn,
  wages,
  playerPurchase,
  transferOut,
  operations,
  contractRenewal,
  signingBonus,
  stadiumInvestment,
}

enum FinanceCategory {
  stadium,
  commercial,
  payroll,
  transfers,
  prizes,
  operations,
}

extension FinanceKindX on FinanceKind {
  String get label => switch (this) {
        FinanceKind.matchIncome || FinanceKind.matchday => 'Bilheteria',
        FinanceKind.hospitality => 'Camarotes e hospitalidade',
        FinanceKind.retail => 'Lojas do estádio',
        FinanceKind.food => 'Alimentação',
        FinanceKind.stadiumAdvertising => 'Publicidade do estádio',
        FinanceKind.tvRights => 'Direitos de transmissão',
        FinanceKind.sponsorship => 'Patrocínios',
        FinanceKind.prizeMoney => 'Premiações',
        FinanceKind.playerSale || FinanceKind.transferIn => 'Venda de jogador',
        FinanceKind.playerPurchase || FinanceKind.transferOut => 'Compra de jogador',
        FinanceKind.wages => 'Salários',
        FinanceKind.operations => 'Operações',
        FinanceKind.contractRenewal => 'Renovação contratual',
        FinanceKind.signingBonus => 'Luvas e bônus de assinatura',
        FinanceKind.stadiumInvestment => 'Investimento no estádio',
      };

  FinanceCategory get category => switch (this) {
        FinanceKind.matchIncome ||
        FinanceKind.matchday ||
        FinanceKind.hospitality ||
        FinanceKind.retail ||
        FinanceKind.food ||
        FinanceKind.stadiumAdvertising ||
        FinanceKind.stadiumInvestment =>
          FinanceCategory.stadium,
        FinanceKind.tvRights || FinanceKind.sponsorship =>
          FinanceCategory.commercial,
        FinanceKind.wages ||
        FinanceKind.contractRenewal ||
        FinanceKind.signingBonus =>
          FinanceCategory.payroll,
        FinanceKind.playerSale ||
        FinanceKind.transferIn ||
        FinanceKind.playerPurchase ||
        FinanceKind.transferOut =>
          FinanceCategory.transfers,
        FinanceKind.prizeMoney => FinanceCategory.prizes,
        FinanceKind.operations => FinanceCategory.operations,
      };
}

extension FinanceCategoryX on FinanceCategory {
  String get label => switch (this) {
        FinanceCategory.stadium => 'Estádio',
        FinanceCategory.commercial => 'Comercial',
        FinanceCategory.payroll => 'Folha salarial',
        FinanceCategory.transfers => 'Transferências',
        FinanceCategory.prizes => 'Premiações',
        FinanceCategory.operations => 'Operações',
      };
}

class FinanceTransaction {
  const FinanceTransaction({
    required this.id,
    required this.season,
    required this.round,
    required this.kind,
    required this.description,
    required this.amount,
    required this.createdAt,
  });

  final String id;
  final int season;
  final int round;
  final FinanceKind kind;
  final String description;
  final int amount;
  final DateTime createdAt;

  bool get isIncome => amount >= 0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'season': season,
        'round': round,
        'kind': kind.name,
        'description': description,
        'amount': amount,
        'createdAt': createdAt.toIso8601String(),
      };

  factory FinanceTransaction.fromJson(Map<String, dynamic> json) =>
      FinanceTransaction(
        id: json['id'] as String,
        season: json['season'] as int? ?? 2026,
        round: json['round'] as int? ?? 0,
        kind: FinanceKind.values.firstWhere(
          (e) => e.name == json['kind'],
          orElse: () => FinanceKind.operations,
        ),
        description: json['description'] as String? ?? '',
        amount: json['amount'] as int? ?? 0,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
}
