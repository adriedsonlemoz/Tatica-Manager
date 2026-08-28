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

  /// Metadados visuais derivados do payload do save. Permanecem opcionais para
  /// que um payload antigo ou parcialmente corrompido ainda possa ser listado.
  final Club? userClub;
  final int? leaguePosition;
  final String? nextOpponentName;
  final DateTime? nextMatchDate;
  final bool? nextMatchAtHome;

  int get currentRound => (roundIndex + 1).clamp(1, 38).toInt();
  bool get seasonComplete => roundIndex >= 38;
}
