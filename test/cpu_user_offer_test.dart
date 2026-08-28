import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/data/club_seed.dart';
import 'package:tatica_manager/domain/career/manager_profile.dart';
import 'package:tatica_manager/domain/club/club.dart';
import 'package:tatica_manager/domain/player/player.dart';
import 'package:tatica_manager/domain/season/career_event.dart';
import 'package:tatica_manager/domain/season/career_state.dart';
import 'package:tatica_manager/game/career/career_factory.dart';
import 'package:tatica_manager/game/cpu/cpu_user_offer_engine.dart';
import 'package:tatica_manager/game/transfer/transfer_engine.dart';

void main() {
  test('CPU cria oferta ao usuário somente quando existe necessidade real', () {
    final base = _career('incoming-offer');
    final buyer = _goalkeeperShortage(base.clubs[1]).copyWith(
      money: 1000000000,
      transferBudget: 1000000000,
    );
    final career = base.copyWith(
      currentDate: DateTime(base.season, 3, 15),
      clubs: [base.userClub, buyer],
    );

    final offer = CpuUserOfferEngine.chooseOffer(
      state: career,
      randomSeed: 77,
    );

    expect(offer, isNotNull);
    final selected = offer!;
    expect(selected.buyer.id, buyer.id);
    expect(
      career.userClub.squad.any((player) => player.id == selected.player.id),
      isTrue,
    );
    expect(selected.need.matches(selected.player), isTrue);
    expect(selected.maxFee, greaterThanOrEqualTo(selected.fee));
  });


  test('caixa alto não ignora teto salarial do comprador', () {
    final base = _career('incoming-salary-ceiling');
    final buyer = _goalkeeperShortage(base.clubs.last).copyWith(
      money: 1000000000,
      transferBudget: 1000000000,
    );
    final career = base.copyWith(
      currentDate: DateTime(base.season, 3, 15),
      clubs: [base.userClub, buyer],
    );

    final offer = CpuUserOfferEngine.chooseOffer(
      state: career,
      randomSeed: 88,
    );

    expect(offer, isNull);
  });

  test('clube sem caixa suficiente não gera oferta pelo jogador do usuário', () {
    final base = _career('incoming-no-money');
    final buyer = _goalkeeperShortage(base.clubs[1]).copyWith(
      money: 1000,
      transferBudget: 1000,
    );
    final career = base.copyWith(
      currentDate: DateTime(base.season, 3, 15),
      clubs: [base.userClub, buyer],
    );

    final offer = CpuUserOfferEngine.chooseOffer(
      state: career,
      randomSeed: 9,
    );

    expect(offer, isNull);
  });

  test('oferta ativa persiste no CareerEvent sem novo schema de save', () {
    final base = _career('incoming-save');
    final buyer = _goalkeeperShortage(base.clubs[1]).copyWith(
      money: 1000000000,
      transferBudget: 1000000000,
    );
    var career = base.copyWith(
      currentDate: DateTime(base.season, 3, 15),
      clubs: [base.userClub, buyer],
    );
    final offer = CpuUserOfferEngine.chooseOffer(
      state: career,
      randomSeed: 17,
    )!;
    final event = CareerEvent(
      id: 'incoming-save-event',
      date: career.currentDate,
      type: CareerEventType.transferOffer,
      title: 'Proposta recebida',
      message: 'Oferta de teste',
      playerId: offer.player.id,
      clubId: offer.buyer.id,
      amount: offer.fee,
    );
    career = career.copyWith(news: [event]);

    final restored = CareerState.fromJson(career.toJson());
    final restoredEvent = restored.news.single;

    expect(restored.schemaVersion, CareerState.currentSchemaVersion);
    expect(restoredEvent.type, CareerEventType.transferOffer);
    expect(restoredEvent.playerId, offer.player.id);
    expect(restoredEvent.clubId, offer.buyer.id);
    expect(restoredEvent.amount, offer.fee);
    expect(
      CpuUserOfferEngine.isOfferActive(state: restored, event: restoredEvent),
      isTrue,
    );
  });

  test('oferta deixa de ser acionável se a situação financeira do comprador mudar', () {
    final base = _career('incoming-finance-change');
    final buyer = _goalkeeperShortage(base.clubs[1]).copyWith(
      money: 1000000000,
      transferBudget: 1000000000,
    );
    var career = base.copyWith(
      currentDate: DateTime(base.season, 3, 15),
      clubs: [base.userClub, buyer],
    );
    final offer = CpuUserOfferEngine.chooseOffer(
      state: career,
      randomSeed: 23,
    )!;
    final event = CareerEvent(
      id: 'incoming-finance-change-event',
      date: career.currentDate,
      type: CareerEventType.transferOffer,
      title: 'Proposta recebida',
      message: 'Oferta de teste',
      playerId: offer.player.id,
      clubId: offer.buyer.id,
      amount: offer.fee,
    );
    career = career.copyWith(news: [event]);
    expect(
      CpuUserOfferEngine.isOfferActive(state: career, event: event),
      isTrue,
    );

    final brokeBuyer = buyer.copyWith(
      money: offer.fee,
      transferBudget: offer.fee,
    );
    final changed = career.copyWith(
      clubs: [career.userClub, brokeBuyer],
    );
    expect(
      CpuUserOfferEngine.isOfferActive(state: changed, event: event),
      isFalse,
    );
  });

  test('contraproposta respeita o limite financeiro e estratégico da CPU', () {
    final base = _career('incoming-counter');
    final buyer = _goalkeeperShortage(base.clubs[1]).copyWith(
      money: 1000000000,
      transferBudget: 1000000000,
    );
    final career = base.copyWith(
      currentDate: DateTime(base.season, 3, 15),
      clubs: [base.userClub, buyer],
    );
    final offer = CpuUserOfferEngine.chooseOffer(
      state: career,
      randomSeed: 31,
    )!;
    expect(offer.maxFee, greaterThan(offer.fee));

    final acceptedFee = offer.fee + ((offer.maxFee - offer.fee) ~/ 2);
    final accepted = CpuUserOfferEngine.evaluateCounter(
      buyer: offer.buyer,
      player: offer.player,
      currentFee: offer.fee,
      proposedFee: acceptedFee,
    );
    final excessive = CpuUserOfferEngine.evaluateCounter(
      buyer: offer.buyer,
      player: offer.player,
      currentFee: offer.fee,
      proposedFee: offer.maxFee * 2,
    );

    expect(accepted.accepted, isTrue);
    expect(excessive.accepted, isFalse);
    expect(excessive.counterOffer, offer.maxFee);
  });

  test('proposta vencida deixa de ser ativa e é marcada como expirada', () {
    final base = _career('incoming-expire');
    final buyer = base.clubs[1].copyWith(
      money: 1000000000,
      transferBudget: 1000000000,
    );
    final player = base.userClub.squad.first;
    final currentDate = DateTime(base.season, 3, 20);
    final event = CareerEvent(
      id: 'old-offer',
      date: currentDate.subtract(
        const Duration(days: CpuUserOfferEngine.offerValidityDays + 1),
      ),
      type: CareerEventType.transferOffer,
      title: 'Proposta recebida',
      message: 'Oferta antiga',
      playerId: player.id,
      clubId: buyer.id,
      amount: 1000000,
    );
    final career = base.copyWith(
      currentDate: currentDate,
      clubs: [base.userClub, buyer],
      news: [event],
    );

    expect(
      CpuUserOfferEngine.isOfferActive(state: career, event: event),
      isFalse,
    );
    final normalized = CpuUserOfferEngine.expireInvalidOffers(
      state: career,
      news: career.news,
    );
    expect(normalized.single.type, CareerEventType.info);
    expect(normalized.single.title, 'Proposta expirada');
  });

  test('mercado aceita universo com mais de 20 clubes e IDs de outras ligas', () {
    final base = _career('future-leagues');
    final buyers = List.generate(23, (index) {
      final seedClub = base.clubs[(index % (base.clubs.length - 1)) + 1];
      final clubId = 'future-country-${index + 1}-club';
      var club = _cloneClub(seedClub, clubId, index);
      if (index == 0) club = _goalkeeperShortage(club);
      return club.copyWith(
        money: 1000000000,
        transferBudget: 1000000000,
      );
    });
    final career = base.copyWith(
      currentDate: DateTime(base.season, 3, 15),
      clubs: [base.userClub, ...buyers],
    );

    final offer = CpuUserOfferEngine.chooseOffer(
      state: career,
      randomSeed: 55,
    );

    expect(career.clubs, hasLength(24));
    expect(offer, isNotNull);
    final selected = offer!;
    expect(selected.buyer.id, startsWith('future-country-'));
    expect(selected.buyer.id, isNot(startsWith('br-club-')));
    expect(
      career.userClub.squad.any((player) => player.id == selected.player.id),
      isTrue,
    );
  });

  test('limites de elenco do mercado ficam centralizados no TransferEngine', () {
    expect(TransferEngine.minimumSquadSize, 20);
    expect(TransferEngine.maximumSquadSize, 30);
  });
}

CareerState _career(String id) => CareerFactory.create(
      careerId: id,
      careerName: id,
      manager: const ManagerProfile(displayName: 'Teste'),
      userClubId: clubSeeds.first.id,
      seed: 20260824,
    );

Club _goalkeeperShortage(Club club) => club.copyWith(
      squad: club.squad
          .where((player) => player.primaryPosition != PlayerPosition.gol)
          .toList(growable: false),
    );

Club _cloneClub(Club source, String id, int index) => source.copyWith(
      id: id,
      name: 'Clube Futuro ${index + 1}',
      shortName: 'F${index + 1}',
      nickname: 'Futuro ${index + 1}',
      squad: source.squad
          .map(
            (player) => player.copyWith(
              id: 'future-$index-${player.id}',
              clubId: id,
            ),
          )
          .toList(growable: false),
    );
