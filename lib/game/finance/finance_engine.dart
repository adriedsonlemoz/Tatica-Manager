import 'dart:math';

import '../../domain/club/club.dart';
import '../../domain/finance/finance.dart';
import '../../domain/finance/sponsorship.dart';
import '../../domain/match/match_models.dart';
import '../stadium/stadium_engine.dart';
import 'sponsorship_engine.dart';

class FinanceRoundResult {
  const FinanceRoundResult({required this.club, required this.transactions});
  final Club club;
  final List<FinanceTransaction> transactions;
}

abstract final class FinanceEngine {
  static FinanceRoundResult settleUserRound({
    required Club club,
    required MatchFixture fixture,
    required int season,
    required int round,
    required bool home,
    required int tablePosition,
    int roundsPerSeason = 38,
  }) {
    final transactions = <FinanceTransaction>[];
    var balance = club.money;
    var budget = club.transferBudget;

    void add(String id, String description, int amount, FinanceKind kind) {
      balance += amount;
      if (kind == FinanceKind.transferIn || kind == FinanceKind.transferOut) {
        budget += amount;
      }
      transactions.add(
        FinanceTransaction(
          id: '${season}_${round}_$id',
          season: season,
          round: round,
          description: description,
          amount: amount,
          kind: kind,
          createdAt: DateTime(season, 4, 1).add(Duration(days: round * 7)),
        ),
      );
    }

    add(
      'tv',
      'Direitos de transmissão — rodada $round',
      400000,
      FinanceKind.tvRights,
    );

    final sponsorships = SponsorshipEngine.settleRound(
      club: club,
      season: season,
      tablePosition: tablePosition,
      roundsPerSeason: roundsPerSeason,
    );
    for (final revenue in sponsorships) {
      add(
        'sponsor-${revenue.contract.id}',
        '${revenue.contract.type.shortLabel} — ${revenue.contract.sponsorName}',
        revenue.total,
        FinanceKind.sponsorship,
      );
    }

    if (home) {
      final stadium = StadiumEngine.settleMatchday(
        club: club,
        tablePosition: tablePosition,
      );
      add(
        'tickets',
        'Bilheteria — ${fixture.id} (${stadium.attendance} torcedores)',
        stadium.ticketing,
        FinanceKind.matchday,
      );
      add(
        'hospitality',
        'Camarotes e hospitalidade — ${fixture.id}',
        stadium.hospitality,
        FinanceKind.hospitality,
      );
      add(
        'retail',
        'Lojas e produtos oficiais — ${fixture.id}',
        stadium.retail,
        FinanceKind.retail,
      );
      add(
        'food',
        'Alimentação — ${fixture.id}',
        stadium.food,
        FinanceKind.food,
      );
      add(
        'stadium-ads',
        'Publicidade no estádio — ${fixture.id}',
        stadium.advertising,
        FinanceKind.stadiumAdvertising,
      );
    }

    final wageCost = -(club.payroll / 4).round();
    add('wages', 'Salários — parcela semanal', wageCost, FinanceKind.wages);

    final operations = -StadiumEngine.operatingCost(club.stadium);
    add(
      'ops',
      'Custos operacionais da rodada',
      operations,
      FinanceKind.operations,
    );

    return FinanceRoundResult(
      club: club.copyWith(money: balance, transferBudget: max(0, budget)),
      transactions: transactions,
    );
  }
}
