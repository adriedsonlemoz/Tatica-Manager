import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/data/club_seed.dart';
import 'package:tatica_manager/domain/career/manager_profile.dart';
import 'package:tatica_manager/domain/season/career_event.dart';
import 'package:tatica_manager/domain/season/career_state.dart';
import 'package:tatica_manager/domain/transfer/market_career.dart';
import 'package:tatica_manager/game/career/career_factory.dart';
import 'package:tatica_manager/game/career/manager_ranking_engine.dart';
import 'package:tatica_manager/game/season/inbox_engine.dart';
import 'package:tatica_manager/game/transfer/market_career_engine.dart';
import 'package:tatica_manager/game/youth/youth_academy_engine.dart';

void main() {
  CareerState career(String id) => CareerFactory.create(
        careerId: id,
        careerName: 'Teste mercado',
        manager: const ManagerProfile(displayName: 'Técnico Teste'),
        userClubId: clubSeeds.first.id,
        seed: 20260826,
      );

  test('categoria de base nasce persistente e promoção preserva id', () {
    final original = career('academy-test');
    expect(original.youthAcademy, hasLength(YouthAcademyEngine.defaultAcademySize));
    final prospect = original.youthAcademy.first;

    final result = YouthAcademyEngine.promote(original, prospect.id);

    expect(result.state.youthAcademy.any((item) => item.id == prospect.id), isFalse);
    expect(result.state.userClub.squad.any((item) => item.id == prospect.id), isTrue);
    expect(
      result.state.news.any((event) => event.playerId == prospect.id),
      isTrue,
    );
  });

  test('scouting revela informações progressivamente ao passar dos dias', () {
    var state = career('scouting-test');
    final target = state.clubs
        .firstWhere((club) => club.id != state.userClubId)
        .squad
        .first;
    state = MarketCareerEngine.startScouting(state, target.id);
    expect(MarketCareerEngine.reportFor(state, target.id)!.level, ScoutingLevel.initial);

    final sameDay = MarketCareerEngine.advanceDay(state).state;
    expect(MarketCareerEngine.reportFor(sameDay, target.id)!.daysObserved, 0);

    for (var day = 1; day <= 4; day++) {
      state = state.copyWith(
        currentDate: state.currentDate.add(const Duration(days: 1)),
      );
      state = MarketCareerEngine.advanceDay(state).state;
    }

    final report = MarketCareerEngine.reportFor(state, target.id)!;
    expect(report.level, ScoutingLevel.complete);
    expect(report.daysObserved, 4);
  });

  test('negociação persiste condições e responde somente após data de ação', () {
    var state = career('negotiation-test');
    final seller = state.clubs.firstWhere((club) => club.id != state.userClubId);
    final target = seller.squad.first;
    final negotiation = MarketCareerEngine.createNegotiation(
      state: state,
      playerId: target.id,
      fee: target.marketValue,
      salary: target.salary,
      years: 3,
      signingBonus: 25000,
      installments: 2,
    );
    state = state.copyWith(transferNegotiations: [negotiation]);

    expect(MarketCareerEngine.advanceDay(state).state.transferNegotiations.single.status,
        TransferNegotiationStatus.waiting);

    state = state.copyWith(currentDate: state.currentDate.add(const Duration(days: 1)));
    final advanced = MarketCareerEngine.advanceDay(state);
    expect(
      advanced.state.transferNegotiations.single.status,
      isNot(TransferNegotiationStatus.waiting),
    );
    expect(advanced.events.single.negotiationId, negotiation.id);
  });

  test('caixa de entrada é idempotente e mantém referência acionável', () {
    final state = career('inbox-test');
    final fixture = state.nextUserFixture!;
    final event = CareerEvent(
      id: 'fixture-alert',
      date: state.currentDate,
      type: CareerEventType.nextMatch,
      title: 'Próxima partida',
      message: 'Detalhes do jogo.',
      fixtureId: fixture.id,
    );

    final once = InboxEngine.appendEvents(state, [event]);
    final twice = InboxEngine.appendEvents(once, [event]);
    final fixtureMessages = twice.inbox
        .where((message) => message.id == 'inbox-fixture-alert')
        .toList(growable: false);

    expect(twice.inbox, hasLength(state.inbox.length + 1));
    expect(fixtureMessages, hasLength(1));
    expect(fixtureMessages.single.fixtureId, fixture.id);
    expect(fixtureMessages.single.read, isFalse);
    expect(
      twice.inbox.where((message) => message.sponsorshipProposalId != null),
      hasLength(3),
    );
  });

  test('mensagem excluída mantém tombstone e não é recriada pelo evento', () {
    final state = career('inbox-delete-test');
    final event = CareerEvent(
      id: 'persisted-news',
      date: state.currentDate,
      type: CareerEventType.info,
      title: 'Notícia persistida',
      message: 'Mensagem que não deve voltar após exclusão.',
    );

    final withMessage = InboxEngine.appendEvents(state, [event]);
    final deleted = InboxEngine.delete(withMessage, 'inbox-persisted-news');
    final appendedAgain = InboxEngine.appendEvents(deleted, [event]);
    final persistedNews = appendedAgain.inbox
        .where((message) => message.id == 'inbox-persisted-news')
        .toList(growable: false);

    expect(appendedAgain.inbox, hasLength(state.inbox.length + 1));
    expect(persistedNews, hasLength(1));
    expect(persistedNews.single.deleted, isTrue);
    expect(persistedNews.single.read, isTrue);
    expect(
      appendedAgain.inbox
          .where((message) => message.sponsorshipProposalId != null),
      hasLength(3),
    );
  });

  test('save legado sem novos campos permanece compatível com schema atual', () {
    final original = career('legacy-market');
    final json = Map<String, dynamic>.from(original.toJson())
      ..remove('scoutingReports')
      ..remove('transferNegotiations')
      ..remove('transferInstallments')
      ..remove('inbox')
      ..remove('youthAcademy')
      ..['schemaVersion'] = 8;

    final restored = CareerState.fromJson(json);

    expect(restored.schemaVersion, CareerState.currentSchemaVersion);
    expect(restored.scoutingReports, isEmpty);
    expect(restored.transferNegotiations, isEmpty);
    expect(restored.transferInstallments, isEmpty);
    expect(restored.inbox, isEmpty);
    expect(restored.youthAcademy, isEmpty);
  });


  test('parcelamento reserva acordo e liquida parcelas futuras no caixa', () {
    var state = career('installment-test');
    final seller = state.clubs.firstWhere((club) => club.id != state.userClubId);
    final target = seller.squad.first;
    final negotiation = MarketCareerEngine.createNegotiation(
      state: state,
      playerId: target.id,
      fee: 1000000,
      salary: target.salary,
      years: 3,
      signingBonus: 0,
      installments: 4,
    );
    final payments = MarketCareerEngine.buildFutureInstallments(
      negotiation,
      state.currentDate,
    );
    expect(payments, hasLength(3));
    expect(
      MarketCareerEngine.upfrontAmount(negotiation.fee, negotiation.installments) +
          payments.fold<int>(0, (sum, item) => sum + item.amount),
      negotiation.fee,
    );

    final buyerMoney = state.userClub.money;
    state = state.copyWith(
      transferInstallments: payments,
      currentDate: payments.first.dueDate,
    );
    final advanced = MarketCareerEngine.advanceDay(state);

    expect(advanced.state.transferInstallments.first.paid, isTrue);
    expect(
      advanced.state.userClub.money,
      buyerMoney - payments.first.amount,
    );
    expect(
      advanced.state.finances.any(
        (item) => item.description == 'Parcela de transferência' &&
            item.amount == -payments.first.amount,
      ),
      isTrue,
    );
  });

  test('ranking de técnicos inclui o treinador do usuário', () {
    final state = career('manager-ranking');
    final ranking = ManagerRankingEngine.rank(state);

    expect(ranking, isNotEmpty);
    expect(ranking.any((entry) => entry.isUser), isTrue);
    expect(
      ranking.firstWhere((entry) => entry.isUser).managerName,
      state.manager.preferredName,
    );
  });
}
