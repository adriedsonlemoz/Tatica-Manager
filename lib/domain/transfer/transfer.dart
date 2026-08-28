class TransferOffer {
  const TransferOffer({
    required this.playerId,
    required this.fromClubId,
    required this.toClubId,
    required this.transferFee,
    required this.salary,
    required this.contractYears,
  });

  final String playerId;
  final String? fromClubId;
  final String toClubId;
  final int transferFee;
  final int salary;
  final int contractYears;
}

class TransferDecision {
  const TransferDecision(this.accepted, this.reason, {this.counterOffer});
  final bool accepted;
  final String reason;
  final int? counterOffer;
}

class TransferOperationResult {
  const TransferOperationResult({
    required this.accepted,
    required this.message,
    this.counterOffer,
  });

  final bool accepted;
  final String message;
  final int? counterOffer;
}

class PlayerSaleOffer {
  const PlayerSaleOffer({
    required this.playerId,
    required this.buyerClubId,
    required this.buyerClubName,
    required this.fee,
  });

  final String playerId;
  final String buyerClubId;
  final String buyerClubName;
  final int fee;
}

class PlayerSalePreview {
  const PlayerSalePreview({
    required this.available,
    required this.message,
    this.offer,
  });

  final bool available;
  final String message;
  final PlayerSaleOffer? offer;
}
