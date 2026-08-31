import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/data/club_seed.dart';
import 'package:tatica_manager/domain/career/manager_profile.dart';
import 'package:tatica_manager/domain/finance/finance.dart';
import 'package:tatica_manager/domain/season/career_state.dart';
import 'package:tatica_manager/domain/transfer/market_career.dart';
import 'package:tatica_manager/game/career/career_factory.dart';
import 'package:tatica_manager/game/transfer/market_career_engine.dart';

void main() {
  CareerState career(String id) => CareerFactory.create(
        careerId: id,
        careerName: id,
        manager: const ManagerProfile(displayName: 'Teste'),
        userClubId: clubSeeds.first.id,
        seed: 20260831,
      );

  test('proposta acima do orçamento não entra na Central de Negociações', () {
    final state = career('transfer-budget-check');
    final seller = state.clubs.firstWhere((club) => club.id != state.userClubId);
    final player = seller.squad.first;
    final limitedUser = state.userClub.copyWith(
      money: 0,
      transferBudget: 0,
    );
    final limitedState = state.copyWith(
      clubs: state.clubs
          .map((club) => club.id == limitedUser.id ? limitedUser : club)
          .toList(growable: false),
    );

    expect(
      () => MarketCareerEngine.createNegotiation(
        state: limitedState,
        playerId: player.id,
        fee: player.marketValue,
        salary: player.salary,
        years: 2,
        signingBonus: 0,
        installments: 1,
      ),
      throwsStateError,
    );
  });

  test('propostas em andamento também reservam o orçamento de transferências', () {
    var state = career('transfer-commitment-check');
    final targets = state.clubs
        .where((club) => club.id != state.userClubId)
        .expand((club) => club.squad)
        .take(2)
        .toList(growable: false);
    final user = state.userClub.copyWith(
      money: 2000000,
      transferBudget: 1000000,
    );
    state = state.copyWith(
      clubs: state.clubs
          .map((club) => club.id == user.id ? user : club)
          .toList(growable: false),
    );
    final first = MarketCareerEngine.createNegotiation(
      state: state,
      playerId: targets.first.id,
      fee: 600000,
      salary: targets.first.salary,
      years: 2,
      signingBonus: 0,
      installments: 1,
    );
    state = state.copyWith(transferNegotiations: [first]);

    expect(
      () => MarketCareerEngine.createNegotiation(
        state: state,
        playerId: targets.last.id,
        fee: 600000,
        salary: targets.last.salary,
        years: 2,
        signingBonus: 0,
        installments: 1,
      ),
      throwsStateError,
    );
  });

  test('empréstimo transfere a folha ao receptor e devolve o atleta no prazo', () {
    var state = career('loan-flow');
    final user = state.userClub;
    final player = user.squad.first;
    final buyer = state.clubs.firstWhere((club) => club.id != user.id);
    final payrollBefore = user.payroll;
    final availableUser = user.copyWith(
      squad: user.squad
          .map(
            (item) => item.id == player.id
                ? item.copyWith(availableForLoan: true)
                : item,
          )
          .toList(growable: false),
    );
    state = state.copyWith(
      clubs: state.clubs
          .map((club) => club.id == user.id ? availableUser : club)
          .toList(growable: false),
    );
    final loan = MarketCareerEngine.createIncomingOffer(
      state: state,
      playerId: player.id,
      buyerClubId: buyer.id,
      fee: 0,
      salary: player.salary,
      years: 1,
      kind: TransferNegotiationKind.loan,
      loanEndDate: state.currentDate.add(const Duration(days: 7)),
    );
    state = state.copyWith(transferNegotiations: [loan]);
    state = MarketCareerEngine.acceptReceivedNegotiation(state, loan.id);
    state = MarketCareerEngine.completeLoan(state, loan.id);

    final borrower = state.clubs.firstWhere((club) => club.id == buyer.id);
    final borrowed = borrower.squad.singleWhere((item) => item.id == player.id);
    expect(state.userClub.squad.any((item) => item.id == player.id), isFalse);
    expect(state.userClub.payroll, payrollBefore - player.salary);
    expect(borrowed.loan?.parentClubId, user.id);
    expect(borrowed.availableForLoan, isFalse);

    state = CareerState.fromJson(state.toJson());
    expect(
      state.clubs
          .firstWhere((club) => club.id == buyer.id)
          .squad
          .singleWhere((item) => item.id == player.id)
          .loan
          ?.parentClubId,
      user.id,
    );

    final returned = MarketCareerEngine.advanceDay(
      state.copyWith(currentDate: loan.loanEndDate!),
    ).state;
    final returnedPlayer = returned.userClub.squad
        .singleWhere((item) => item.id == player.id);
    expect(returnedPlayer.loan, isNull);
    expect(returned.userClub.payroll, payrollBefore);
    expect(
      returned.clubs
          .firstWhere((club) => club.id == buyer.id)
          .squad
          .any((item) => item.id == player.id),
      isFalse,
    );
  });

  test('parcela de venda atualiza caixa e livro-caixa do clube do usuário', () {
    var state = career('sale-installment-flow');
    final buyerBase = state.clubs.firstWhere(
      (club) => club.id != state.userClubId,
    );
    final buyer = buyerBase.copyWith(money: 1000000000);
    final player = state.userClub.squad.first;
    const amount = 125000;
    final moneyBefore = state.userClub.money;
    state = state.copyWith(
      clubs: state.clubs
          .map((club) => club.id == buyer.id ? buyer : club)
          .toList(growable: false),
      transferInstallments: [
        TransferInstallmentPayment(
          id: 'sale-installment',
          negotiationId: 'sale-negotiation',
          playerId: player.id,
          fromClubId: buyer.id,
          toClubId: state.userClubId,
          amount: amount,
          dueDate: state.currentDate,
        ),
      ],
    );

    final advanced = MarketCareerEngine.advanceDay(state);

    expect(advanced.state.userClub.money, moneyBefore + amount);
    expect(advanced.state.transferInstallments.single.paid, isTrue);
    expect(
      advanced.state.finances.any(
        (transaction) =>
            transaction.kind == FinanceKind.playerSale &&
            transaction.amount == amount,
      ),
      isTrue,
    );
  });
}
