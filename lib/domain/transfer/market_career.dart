enum ScoutingLevel {
  initial,
  observed,
  complete,
}

extension ScoutingLevelX on ScoutingLevel {
  String get label => switch (this) {
        ScoutingLevel.initial => 'Relatório inicial',
        ScoutingLevel.observed => 'Observado',
        ScoutingLevel.complete => 'Relatório completo',
      };
}

class PlayerScoutingReport {
  const PlayerScoutingReport({
    required this.playerId,
    required this.level,
    required this.startedAt,
    required this.updatedAt,
    this.daysObserved = 0,
  });

  final String playerId;
  final ScoutingLevel level;
  final DateTime startedAt;
  final DateTime updatedAt;
  final int daysObserved;

  PlayerScoutingReport copyWith({
    ScoutingLevel? level,
    DateTime? updatedAt,
    int? daysObserved,
  }) =>
      PlayerScoutingReport(
        playerId: playerId,
        level: level ?? this.level,
        startedAt: startedAt,
        updatedAt: updatedAt ?? this.updatedAt,
        daysObserved: daysObserved ?? this.daysObserved,
      );

  Map<String, dynamic> toJson() => {
        'playerId': playerId,
        'level': level.name,
        'startedAt': startedAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'daysObserved': daysObserved,
      };

  factory PlayerScoutingReport.fromJson(Map<String, dynamic> json) =>
      PlayerScoutingReport(
        playerId: json['playerId'] as String? ?? '',
        level: ScoutingLevel.values.firstWhere(
          (value) => value.name == json['level'],
          orElse: () => ScoutingLevel.initial,
        ),
        startedAt: DateTime.tryParse(json['startedAt'] as String? ?? '') ??
            DateTime(2026),
        updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
            DateTime.tryParse(json['startedAt'] as String? ?? '') ??
            DateTime(2026),
        daysObserved: json['daysObserved'] as int? ?? 0,
      );
}

enum TransferNegotiationStatus {
  waiting,
  countered,
  accepted,
  rejected,
  completed,
  withdrawn,
}

extension TransferNegotiationStatusX on TransferNegotiationStatus {
  String get label => switch (this) {
        TransferNegotiationStatus.waiting => 'Em análise',
        TransferNegotiationStatus.countered => 'Contraproposta',
        TransferNegotiationStatus.accepted => 'Acordo possível',
        TransferNegotiationStatus.rejected => 'Recusada',
        TransferNegotiationStatus.completed => 'Concluída',
        TransferNegotiationStatus.withdrawn => 'Encerrada',
      };

  bool get isOpen =>
      this == TransferNegotiationStatus.waiting ||
      this == TransferNegotiationStatus.countered ||
      this == TransferNegotiationStatus.accepted;
}

class TransferNegotiation {
  const TransferNegotiation({
    required this.id,
    required this.playerId,
    required this.toClubId,
    required this.fee,
    required this.salary,
    required this.contractYears,
    required this.signingBonus,
    required this.installments,
    required this.startedAt,
    required this.nextActionDate,
    required this.status,
    required this.message,
    this.fromClubId,
    this.counterFee,
    this.counterSalary,
    this.otherClubsInterested = 0,
  });

  final String id;
  final String playerId;
  final String? fromClubId;
  final String toClubId;
  final int fee;
  final int salary;
  final int contractYears;
  final int signingBonus;
  final int installments;
  final DateTime startedAt;
  final DateTime nextActionDate;
  final TransferNegotiationStatus status;
  final String message;
  final int? counterFee;
  final int? counterSalary;
  final int otherClubsInterested;

  TransferNegotiation copyWith({
    int? fee,
    int? salary,
    int? contractYears,
    int? signingBonus,
    int? installments,
    DateTime? nextActionDate,
    TransferNegotiationStatus? status,
    String? message,
    int? counterFee,
    bool clearCounterFee = false,
    int? counterSalary,
    bool clearCounterSalary = false,
    int? otherClubsInterested,
  }) =>
      TransferNegotiation(
        id: id,
        playerId: playerId,
        fromClubId: fromClubId,
        toClubId: toClubId,
        fee: fee ?? this.fee,
        salary: salary ?? this.salary,
        contractYears: contractYears ?? this.contractYears,
        signingBonus: signingBonus ?? this.signingBonus,
        installments: installments ?? this.installments,
        startedAt: startedAt,
        nextActionDate: nextActionDate ?? this.nextActionDate,
        status: status ?? this.status,
        message: message ?? this.message,
        counterFee:
            clearCounterFee ? null : (counterFee ?? this.counterFee),
        counterSalary:
            clearCounterSalary ? null : (counterSalary ?? this.counterSalary),
        otherClubsInterested:
            otherClubsInterested ?? this.otherClubsInterested,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'playerId': playerId,
        'fromClubId': fromClubId,
        'toClubId': toClubId,
        'fee': fee,
        'salary': salary,
        'contractYears': contractYears,
        'signingBonus': signingBonus,
        'installments': installments,
        'startedAt': startedAt.toIso8601String(),
        'nextActionDate': nextActionDate.toIso8601String(),
        'status': status.name,
        'message': message,
        'counterFee': counterFee,
        'counterSalary': counterSalary,
        'otherClubsInterested': otherClubsInterested,
      };

  factory TransferNegotiation.fromJson(Map<String, dynamic> json) =>
      TransferNegotiation(
        id: json['id'] as String? ?? '',
        playerId: json['playerId'] as String? ?? '',
        fromClubId: json['fromClubId'] as String?,
        toClubId: json['toClubId'] as String? ?? '',
        fee: json['fee'] as int? ?? 0,
        salary: json['salary'] as int? ?? 0,
        contractYears: json['contractYears'] as int? ?? 1,
        signingBonus: json['signingBonus'] as int? ?? 0,
        installments: json['installments'] as int? ?? 1,
        startedAt: DateTime.tryParse(json['startedAt'] as String? ?? '') ??
            DateTime(2026),
        nextActionDate:
            DateTime.tryParse(json['nextActionDate'] as String? ?? '') ??
                DateTime.tryParse(json['startedAt'] as String? ?? '') ??
                DateTime(2026),
        status: TransferNegotiationStatus.values.firstWhere(
          (value) => value.name == json['status'],
          orElse: () => TransferNegotiationStatus.waiting,
        ),
        message: json['message'] as String? ?? '',
        counterFee: json['counterFee'] as int?,
        counterSalary: json['counterSalary'] as int?,
        otherClubsInterested: json['otherClubsInterested'] as int? ?? 0,
      );
}


class TransferInstallmentPayment {
  const TransferInstallmentPayment({
    required this.id,
    required this.negotiationId,
    required this.playerId,
    required this.fromClubId,
    required this.toClubId,
    required this.amount,
    required this.dueDate,
    this.paid = false,
    this.paidAt,
  });

  final String id;
  final String negotiationId;
  final String playerId;
  final String fromClubId;
  final String? toClubId;
  final int amount;
  final DateTime dueDate;
  final bool paid;
  final DateTime? paidAt;

  TransferInstallmentPayment copyWith({
    bool? paid,
    DateTime? paidAt,
  }) =>
      TransferInstallmentPayment(
        id: id,
        negotiationId: negotiationId,
        playerId: playerId,
        fromClubId: fromClubId,
        toClubId: toClubId,
        amount: amount,
        dueDate: dueDate,
        paid: paid ?? this.paid,
        paidAt: paidAt ?? this.paidAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'negotiationId': negotiationId,
        'playerId': playerId,
        'fromClubId': fromClubId,
        'toClubId': toClubId,
        'amount': amount,
        'dueDate': dueDate.toIso8601String(),
        'paid': paid,
        'paidAt': paidAt?.toIso8601String(),
      };

  factory TransferInstallmentPayment.fromJson(Map<String, dynamic> json) =>
      TransferInstallmentPayment(
        id: json['id'] as String? ?? '',
        negotiationId: json['negotiationId'] as String? ?? '',
        playerId: json['playerId'] as String? ?? '',
        fromClubId: json['fromClubId'] as String? ?? '',
        toClubId: json['toClubId'] as String?,
        amount: json['amount'] as int? ?? 0,
        dueDate: DateTime.tryParse(json['dueDate'] as String? ?? '') ?? DateTime(2026),
        paid: json['paid'] as bool? ?? false,
        paidAt: DateTime.tryParse(json['paidAt'] as String? ?? ''),
      );
}
