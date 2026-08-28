import '../../domain/club/club.dart';
import '../../domain/finance/sponsorship.dart';

class SponsorshipRoundRevenue {
  const SponsorshipRoundRevenue({
    required this.contract,
    required this.baseValue,
    required this.bonusValue,
  });

  final SponsorshipContract contract;
  final int baseValue;
  final int bonusValue;

  int get total => baseValue + bonusValue;
}

abstract final class SponsorshipEngine {
  static List<SponsorshipContract> contractsFor(
    Club club, {
    required int season,
  }) {
    final persisted = club.sponsorships
        .where((contract) => contract.isActiveIn(season))
        .toList(growable: false);
    return persisted;
  }

  static List<SponsorshipContract> defaultContracts(
    Club club, {
    required int season,
  }) {
    final reputation = club.reputation.clamp(1, 100).toInt();
    final mainValue = 3800000 + reputation * 68000;
    final kitValue = 1450000 + reputation * 26000;
    final stadiumValue = 800000 + reputation * 15500;
    return [
      SponsorshipContract(
        id: '${club.id}-$season-master',
        sponsorName: 'Parceiro Master',
        type: SponsorshipType.main,
        annualValue: mainValue,
        startSeason: season,
        endSeason: season + 1,
        performanceBonus: 700000 + reputation * 4500,
      ),
      SponsorshipContract(
        id: '${club.id}-$season-kit',
        sponsorName: 'Fornecedor Esportivo',
        type: SponsorshipType.kit,
        annualValue: kitValue,
        startSeason: season,
        endSeason: season + 2,
        performanceBonus: 280000 + reputation * 1800,
      ),
      SponsorshipContract(
        id: '${club.id}-$season-stadium',
        sponsorName: 'Parceiro do Estádio',
        type: SponsorshipType.stadium,
        annualValue: stadiumValue,
        startSeason: season,
        endSeason: season + 1,
      ),
    ];
  }

  static List<SponsorshipRoundRevenue> settleRound({
    required Club club,
    required int season,
    required int tablePosition,
    int roundsPerSeason = 38,
  }) {
    final topFour = tablePosition <= 4;
    final topHalf = tablePosition <= 10;
    return contractsFor(club, season: season)
        .map((contract) {
          final base = contract.valueForRound(roundsPerSeason: roundsPerSeason);
          final bonus = contract.performanceBonus <= 0
              ? 0
              : ((contract.performanceBonus / roundsPerSeason) *
                      (topFour
                          ? 1.0
                          : topHalf
                              ? .45
                              : 0.0))
                  .round();
          return SponsorshipRoundRevenue(
            contract: contract,
            baseValue: base,
            bonusValue: bonus,
          );
        })
        .toList(growable: false);
  }
}
