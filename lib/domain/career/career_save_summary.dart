class CareerSaveSummary {
  const CareerSaveSummary({
    required this.careerId,
    required this.careerName,
    required this.managerName,
    required this.userClubId,
    required this.userClubName,
    required this.season,
    required this.roundIndex,
    required this.createdAt,
    required this.updatedAt,
  });

  final String careerId;
  final String careerName;
  final String managerName;
  final String userClubId;
  final String userClubName;
  final int season;
  final int roundIndex;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get currentRound => (roundIndex + 1).clamp(1, 38).toInt();
  bool get seasonComplete => roundIndex >= 38;
}
