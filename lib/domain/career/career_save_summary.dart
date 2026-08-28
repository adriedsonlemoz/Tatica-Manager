import '../club/club.dart';

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
    this.userClub,
    this.leaguePosition,
    this.nextOpponentName,
    this.nextMatchDate,
    this.nextMatchAtHome,
    this.totalRounds = 38,
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

  /// Metadados leves persistidos junto do save para a Central de Carreiras não
  /// precisar desserializar o payload completo durante a listagem.
  final Club? userClub;
  final int? leaguePosition;
  final String? nextOpponentName;
  final DateTime? nextMatchDate;
  final bool? nextMatchAtHome;
  final int totalRounds;

  int get currentRound => (roundIndex + 1).clamp(1, totalRounds).toInt();
  bool get seasonComplete => roundIndex >= totalRounds;
}
