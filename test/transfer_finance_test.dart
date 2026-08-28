import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/data/club_seed.dart';
import 'package:tatica_manager/domain/career/manager_profile.dart';
import 'package:tatica_manager/game/career/career_factory.dart';
import 'package:tatica_manager/game/contract/contract_engine.dart';
import 'package:tatica_manager/game/transfer/transfer_engine.dart';

void main() {
  test('compra desconta a taxa uma única vez e salário fica na folha', () {
    final career = CareerFactory.create(
      careerId: 'finance-test',
      careerName: 'Teste financeiro',
      manager: const ManagerProfile(displayName: 'Teste'),
      userClubId: clubSeeds.first.id,
    );
    final buyer = career.userClub;
    final seller = career.clubs.firstWhere((club) => club.id != buyer.id);
    final player = seller.squad.first;
    final fee = TransferEngine.minimumFee(
      player: player,
      buyer: buyer,
      seller: seller,
    );

    final result = TransferEngine.execute(
      player: player,
      buyer: buyer,
      seller: seller,
      fee: fee,
      salary: player.salary * 2,
      years: 2,
      season: career.season,
    );

    expect(seller.squad.length, greaterThan(20));
    expect(result.decision.accepted, isTrue);
    expect(result.buyer.money, buyer.money - fee);
    expect(result.buyer.transferBudget, buyer.transferBudget - fee);
    expect(result.buyer.payroll, greaterThan(buyer.payroll));
    expect(result.seller?.money, seller.money + fee);
  });

  test('venda pelo elenco aceita oferta da CPU sem cobrar mínimo do próprio clube', () {
    final career = CareerFactory.create(
      careerId: 'sale-test',
      careerName: 'Teste de venda',
      manager: const ManagerProfile(displayName: 'Teste'),
      userClubId: clubSeeds.first.id,
    );
    final seller = career.userClub;
    final player = [...seller.squad]
      ..sort((a, b) => a.marketValue.compareTo(b.marketValue));
    final buyerBase = career.clubs.firstWhere((club) => club.id != seller.id);
    final buyer = buyerBase.copyWith(
      money: 1000000000,
      transferBudget: 1000000000,
    );
    final selected = player.first;
    final offer = TransferEngine.saleOfferFee(player: selected, buyer: buyer);

    expect(seller.squad.length, greaterThan(20));
    expect(buyer.squad.length, lessThan(30));

    final result = TransferEngine.execute(
      player: selected,
      buyer: buyer,
      seller: seller,
      fee: offer,
      salary: selected.salary * 2,
      years: 2,
      season: career.season,
      requireSellerMinimum: false,
    );

    expect(result.decision.accepted, isTrue);
    expect(result.seller!.squad, hasLength(seller.squad.length - 1));
    expect(result.buyer.squad, hasLength(buyer.squad.length + 1));
    expect(result.seller!.money, seller.money + offer);
    expect(result.buyer.money, buyer.money - offer);
    expect(result.player.clubId, buyer.id);
  });

  test('renovação rejeitada devolve contraproposta salarial numérica', () {
    final career = CareerFactory.create(
      careerId: 'renew-test',
      careerName: 'Teste de renovação',
      manager: const ManagerProfile(displayName: 'Teste'),
      userClubId: clubSeeds.first.id,
    );
    final player = career.userClub.squad.first;
    final result = ContractEngine.negotiate(
      player: player,
      proposal: const ContractProposal(salary: 1, years: 2),
      season: career.season,
      clubMoney: career.userClub.money,
    );

    expect(result.accepted, isFalse);
    expect(result.requiredSalary, isNotNull);
    expect(result.requiredSalary, greaterThan(1));
    expect(result.message, isNot(contains('R\$')));
  });
}
