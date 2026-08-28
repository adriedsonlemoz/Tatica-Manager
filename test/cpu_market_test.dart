import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/data/club_seed.dart';
import 'package:tatica_manager/domain/career/manager_profile.dart';
import 'package:tatica_manager/domain/club/club.dart';
import 'package:tatica_manager/domain/player/player.dart';
import 'package:tatica_manager/domain/season/career_state.dart';
import 'package:tatica_manager/game/career/career_factory.dart';
import 'package:tatica_manager/game/cpu/cpu_financial_engine.dart';
import 'package:tatica_manager/game/cpu/cpu_manager_engine.dart';
import 'package:tatica_manager/game/cpu/cpu_market_news_engine.dart';
import 'package:tatica_manager/game/cpu/cpu_market_strategy_engine.dart';
import 'package:tatica_manager/game/cpu/cpu_recruitment_engine.dart';
import 'package:tatica_manager/game/cpu/cpu_selling_engine.dart';
import 'package:tatica_manager/game/cpu/cpu_squad_needs_engine.dart';

void main() {
  test('CPU identifica carência real de posição no elenco', () {
    final career = _career('cpu-needs');
    final club = career.clubs[1];
    final withoutGoalkeepers = _withoutPosition(
      club,
      PlayerPosition.gol,
      limit: 19,
    );

    final needs = CpuSquadNeedsEngine.assess(withoutGoalkeepers);

    expect(needs, isNotEmpty);
    expect(needs.first.position, PlayerPosition.gol);
    expect(needs.first.currentDepth, 0);
    expect(needs.first.minimumDepth, 2);
  });

  test('clube equilibrado e com nível compatível não inventa carência', () {
    final career = _career('cpu-no-needs');
    final balanced = career.clubs[1].copyWith(reputation: 60);

    expect(CpuSquadNeedsEngine.assess(balanced), isEmpty);
  });

  test('CPU prioriza agente livre compatível com a maior carência', () {
    final career = _career('cpu-free');
    final buyer = _withoutPosition(
      career.clubs[1],
      PlayerPosition.gol,
      limit: 19,
    );
    final freeGoalkeeper = _freeGoalkeeper(
      career,
      id: 'cpu-free-goalkeeper',
      buyer: buyer,
    );
    final needs = CpuSquadNeedsEngine.assess(buyer);

    final target = CpuRecruitmentEngine.chooseFreeAgent(
      buyer: buyer,
      need: needs.first,
      freeAgents: [freeGoalkeeper],
    );

    expect(target, isNotNull);
    expect(target!.player.id, freeGoalkeeper.id);
    expect(target.fee, 0);
  });

  test('aleatoriedade controlada varia entre os melhores alvos sem perder seed', () {
    final career = _career('cpu-random');
    final buyer = _withoutPosition(
      career.clubs[1],
      PlayerPosition.gol,
      limit: 19,
    );
    final base = _freeGoalkeeper(
      career,
      id: 'random-0',
      buyer: buyer,
    ).copyWith(age: 27, potential: buyer.reputation, overall: buyer.reputation);
    final candidates = List.generate(
      3,
      (index) => base.copyWith(id: 'random-$index'),
    );
    final need = CpuSquadNeedsEngine.assess(buyer).first;

    final first = CpuRecruitmentEngine.chooseFreeAgent(
      buyer: buyer,
      need: need,
      freeAgents: candidates,
      randomSeed: 91,
    );
    final repeated = CpuRecruitmentEngine.chooseFreeAgent(
      buyer: buyer,
      need: need,
      freeAgents: candidates,
      randomSeed: 91,
    );
    final varied = <String>{
      for (var seed = 1; seed <= 30; seed++)
        CpuRecruitmentEngine.chooseFreeAgent(
          buyer: buyer,
          need: need,
          freeAgents: candidates,
          randomSeed: seed,
        )!.player.id,
    };

    expect(first!.player.id, repeated!.player.id);
    expect(varied.length, greaterThan(1));
  });

  test('rodada de mercado contrata livre sem duplicar jogador', () {
    final career = _career('cpu-sign');
    final buyer = _withoutPosition(
      career.clubs[1],
      PlayerPosition.gol,
      limit: 19,
    );
    final freeGoalkeeper = _freeGoalkeeper(
      career,
      id: 'cpu-sign-goalkeeper',
      buyer: buyer,
    );
    final clubs = career.clubs
        .map((club) => club.id == buyer.id ? buyer : club)
        .toList();

    final result = CpuManagerEngine.runRound(
      clubs: clubs,
      freeAgents: [freeGoalkeeper],
      userClubId: career.userClubId,
      season: career.season,
      round: 1,
      currentDate: DateTime(career.season, 3, 15),
      careerId: career.careerId,
    );

    expect(result.moves, isNotEmpty);
    expect(result.moves.first.type, CpuMarketMoveType.freeAgentSigning);
    expect(result.moves.first.playerId, freeGoalkeeper.id);
    expect(
      result.freeAgents.any((player) => player.id == freeGoalkeeper.id),
      isFalse,
    );
    final updatedBuyer = result.clubs.firstWhere((club) => club.id == buyer.id);
    expect(
      updatedBuyer.squad.any((player) => player.id == freeGoalkeeper.id),
      isTrue,
    );
    _expectNoDuplicatePlayers(result.clubs, result.freeAgents);
  });

  test('CPU busca transferência quando vendedor possui atleta negociável', () {
    final career = _career('cpu-transfer');
    final buyer = _withoutPosition(
      career.clubs[1].copyWith(
        money: 1000000000,
        transferBudget: 1000000000,
      ),
      PlayerPosition.gol,
      limit: 19,
    );
    final sellerBase = career.clubs[2];
    final sellerGoalkeeper = sellerBase.squad.lastWhere(
      (player) => player.primaryPosition == PlayerPosition.gol,
    );
    final availableGoalkeeper = sellerGoalkeeper.copyWith(
      overall: buyer.reputation,
      potential: buyer.reputation + 1,
      marketValue: 1000000,
      listed: true,
      contract: sellerGoalkeeper.contract.copyWith(salary: 10000),
    );
    final seller = sellerBase.copyWith(
      squad: sellerBase.squad
          .map(
            (player) => player.id == sellerGoalkeeper.id
                ? availableGoalkeeper
                : player,
          )
          .toList(),
    );
    final clubs = career.clubs.map((club) {
      if (club.id == buyer.id) return buyer;
      if (club.id == seller.id) return seller;
      return club;
    }).toList();

    final result = CpuManagerEngine.runRound(
      clubs: clubs,
      freeAgents: const [],
      userClubId: career.userClubId,
      season: career.season,
      round: 1,
      currentDate: DateTime(career.season, 3, 15),
      careerId: career.careerId,
    );

    expect(result.moves, isNotEmpty);
    final move = result.moves.first;
    expect(move.type, CpuMarketMoveType.transfer);
    expect(move.toClubId, buyer.id);
    expect(move.fromClubId, isNot(career.userClubId));
    expect(move.fee, greaterThan(0));
    final updatedBuyer = result.clubs.firstWhere((club) => club.id == buyer.id);
    expect(
      updatedBuyer.squad
          .where((player) => player.id == move.playerId)
          .single
          .primaryPosition,
      PlayerPosition.gol,
    );
  });

  test('venda estratégica protege titular importante mesmo com profundidade', () {
    final career = _career('cpu-key-player');
    final sellerBase = career.clubs[2];
    final goalkeeper = sellerBase.squad.firstWhere(
      (player) => player.primaryPosition == PlayerPosition.gol,
    );
    final star = goalkeeper.copyWith(
      overall: 95,
      potential: 95,
      listed: false,
    );
    final seller = sellerBase.copyWith(
      squad: sellerBase.squad
          .map((player) => player.id == goalkeeper.id ? star : player)
          .toList(),
    );

    final assessment = CpuSellingEngine.assess(
      club: seller,
      player: star,
      season: career.season,
    );

    expect(assessment.keyPlayer, isTrue);
    expect(assessment.sellable, isFalse);
  });

  test('venda estratégica aceita excedente caro e perto do fim do contrato', () {
    final career = _career('cpu-excess-sale');
    final sellerBase = career.clubs[2];
    final goalkeeper = sellerBase.squad.lastWhere(
      (player) => player.primaryPosition == PlayerPosition.gol,
    );
    final excess = goalkeeper.copyWith(
      overall: 60,
      potential: 61,
      age: 33,
      listed: false,
      contract: goalkeeper.contract.copyWith(
        salary: sellerBase.payroll,
        endSeason: career.season,
      ),
    );
    final seller = sellerBase.copyWith(
      squad: sellerBase.squad
          .map((player) => player.id == goalkeeper.id ? excess : player)
          .toList(),
    );

    final assessment = CpuSellingEngine.assess(
      club: seller,
      player: excess,
      season: career.season,
    );

    expect(assessment.keyPlayer, isFalse);
    expect(assessment.score, greaterThan(0));
    expect(assessment.sellable, isTrue);
  });

  test('CPU não vende quando o clube ficaria sem profundidade mínima', () {
    final career = _career('cpu-depth-protection');
    final seller = career.clubs[2];
    final defender = seller.squad.firstWhere(
      (player) => player.primaryPosition == PlayerPosition.zag,
    );

    final assessment = CpuSellingEngine.assess(
      club: seller,
      player: defender,
      season: career.season,
    );

    expect(assessment.positionDepth, 4);
    expect(assessment.minimumDepth, 4);
    expect(assessment.sellable, isFalse);
  });

  test('comportamento financeiro preserva caixa e evita contratação excessiva', () {
    final career = _career('cpu-finance');
    final buyer = _withoutPosition(
      career.clubs[17].copyWith(
        money: 5000000,
        transferBudget: 5000000,
      ),
      PlayerPosition.gol,
      limit: 19,
    );
    final player = _freeGoalkeeper(
      career,
      id: 'expensive-target',
      buyer: buyer,
    );
    final need = CpuSquadNeedsEngine.assess(buyer).first;

    expect(
      CpuFinancialEngine.canAfford(
        buyer: buyer,
        need: need,
        player: player,
        fee: 4500000,
        salary: 10000,
      ),
      isFalse,
    );
  });

  test('clube sem dinheiro não contrata nem mesmo em carência', () {
    final career = _career('cpu-no-money');
    final buyer = _withoutPosition(
      career.clubs[1].copyWith(money: 1000000, transferBudget: 1000000),
      PlayerPosition.gol,
      limit: 19,
    );
    final freeGoalkeeper = _freeGoalkeeper(
      career,
      id: 'cpu-no-money-gk',
      buyer: buyer,
    );

    final result = CpuManagerEngine.runRound(
      clubs: [career.userClub, buyer],
      freeAgents: [freeGoalkeeper],
      userClubId: career.userClubId,
      season: career.season,
      round: 1,
      currentDate: DateTime(career.season, 3, 15),
      careerId: career.careerId,
    );

    expect(result.moves, isEmpty);
  });

  test('elenco cheio impede nova contratação da CPU', () {
    final career = _career('cpu-full-squad');
    final buyerBase = career.clubs[1];
    final extras = career.clubs[2].squad.take(6).toList().asMap().entries.map(
      (entry) => entry.value.copyWith(
        id: 'extra-${entry.key}',
        clubId: buyerBase.id,
      ),
    );
    final buyer = buyerBase.copyWith(squad: [...buyerBase.squad, ...extras]);
    final freeGoalkeeper = _freeGoalkeeper(
      career,
      id: 'cpu-full-target',
      buyer: buyer,
    );

    final result = CpuManagerEngine.runRound(
      clubs: [career.userClub, buyer],
      freeAgents: [freeGoalkeeper],
      userClubId: career.userClubId,
      season: career.season,
      round: 2,
      currentDate: DateTime(career.season, 3, 15),
      careerId: career.careerId,
    );

    expect(buyer.squad, hasLength(30));
    expect(result.moves, isEmpty);
  });

  test('CPU nunca movimenta automaticamente jogadores do clube do usuário', () {
    final career = _career('cpu-user-protection');
    final beforeUser = career.userClub;

    final result = CpuManagerEngine.runRound(
      clubs: career.clubs,
      freeAgents: career.freeAgents,
      userClubId: career.userClubId,
      season: career.season,
      round: 2,
      currentDate: DateTime(career.season, 3, 15),
      careerId: career.careerId,
    );
    final afterUser = result.clubs.firstWhere(
      (club) => club.id == career.userClubId,
    );

    expect(afterUser.money, beforeUser.money);
    expect(afterUser.transferBudget, beforeUser.transferBudget);
    expect(
      afterUser.squad.map((player) => player.id).toList(),
      beforeUser.squad.map((player) => player.id).toList(),
    );
    expect(
      result.moves.any(
        (move) =>
            move.fromClubId == career.userClubId ||
            move.toClubId == career.userClubId,
      ),
      isFalse,
    );
  });

  test('múltiplos clubes podem demonstrar interesse no mesmo jogador', () {
    final career = _career('cpu-competition');
    final buyerA = _withoutPosition(
      career.clubs[1],
      PlayerPosition.gol,
      limit: 19,
    );
    final buyerB = _withoutPosition(
      career.clubs[2],
      PlayerPosition.gol,
      limit: 19,
    );
    final freeGoalkeeper = _freeGoalkeeper(
      career,
      id: 'shared-free-agent',
      buyer: buyerA,
    );

    final result = CpuManagerEngine.runRound(
      clubs: [career.userClub, buyerA, buyerB],
      freeAgents: [freeGoalkeeper],
      userClubId: career.userClubId,
      season: career.season,
      round: 1,
      currentDate: DateTime(career.season, 3, 15),
      careerId: career.careerId,
    );

    final sharedInterests = result.interests
        .where((interest) => interest.playerId == freeGoalkeeper.id)
        .toList();
    expect(sharedInterests.map((item) => item.clubId).toSet(), hasLength(2));
    expect(
      result.moves.where((move) => move.playerId == freeGoalkeeper.id),
      hasLength(1),
    );
    _expectNoDuplicatePlayers(result.clubs, result.freeAgents);
  });

  test('notícias usam CareerEvent e geram somente um evento por negócio', () {
    final career = _career('cpu-news');
    final buyerA = _withoutPosition(
      career.clubs[1],
      PlayerPosition.gol,
      limit: 19,
    );
    final buyerB = _withoutPosition(
      career.clubs[2],
      PlayerPosition.gol,
      limit: 19,
    );
    final freeGoalkeeper = _freeGoalkeeper(
      career,
      id: 'news-free-agent',
      buyer: buyerA,
    ).copyWith(age: 28, potential: 78, overall: 78);
    final result = CpuManagerEngine.runRound(
      clubs: [career.userClub, buyerA, buyerB],
      freeAgents: [freeGoalkeeper],
      userClubId: career.userClubId,
      season: career.season,
      round: 1,
      currentDate: DateTime(career.season, 3, 15),
      careerId: career.careerId,
    );

    final events = CpuMarketNewsEngine.build(
      result: result,
      date: DateTime(career.season, 3, 15),
      season: career.season,
      round: 1,
    );

    expect(events, hasLength(result.moves.length));
    expect(events, hasLength(1));
    expect(events.single.id, startsWith('cpu-market-'));
    expect(events.single.playerId, freeGoalkeeper.id);
    expect(events.single.message, contains('livre no mercado'));
  });

  test('notícia de transferência destaca origem, destino e contratação forte', () {
    final career = _career('cpu-transfer-news');
    final buyer = career.clubs[1];
    final seller = career.clubs[2];
    final original = seller.squad.first;
    final moved = original.copyWith(
      clubId: buyer.id,
      overall: 85,
      potential: 86,
    );
    final updatedBuyer = buyer.copyWith(squad: [...buyer.squad, moved]);
    final updatedSeller = seller.copyWith(
      squad: seller.squad.where((player) => player.id != original.id).toList(),
    );
    final clubs = career.clubs.map((club) {
      if (club.id == buyer.id) return updatedBuyer;
      if (club.id == seller.id) return updatedSeller;
      return club;
    }).toList();
    final result = CpuMarketResult(
      clubs: clubs,
      freeAgents: career.freeAgents,
      moves: [
        CpuMarketMove(
          type: CpuMarketMoveType.transfer,
          playerId: moved.id,
          playerName: moved.displayName,
          fromClubId: seller.id,
          toClubId: buyer.id,
          fee: 12500000,
        ),
      ],
    );

    final events = CpuMarketNewsEngine.build(
      result: result,
      date: DateTime(career.season, 3, 15),
      season: career.season,
      round: 2,
    );

    expect(events, hasLength(1));
    expect(events.single.title, 'Contratação de destaque');
    expect(events.single.message, contains(buyer.name));
    expect(events.single.message, contains(seller.name));
    expect(events.single.message, contains(r'R$ 12.500.000'));
    expect(events.single.amount, 12500000);
  });

  test('save-load após mercado preserva notícias e não duplica atletas', () {
    var career = _career('cpu-save-load');
    final buyerA = _withoutPosition(
      career.clubs[1],
      PlayerPosition.gol,
      limit: 19,
    );
    final buyerB = _withoutPosition(
      career.clubs[2],
      PlayerPosition.gol,
      limit: 19,
    );
    final freeGoalkeeper = _freeGoalkeeper(
      career,
      id: 'save-load-free-agent',
      buyer: buyerA,
    );
    final clubs = career.clubs.map((club) {
      if (club.id == buyerA.id) return buyerA;
      if (club.id == buyerB.id) return buyerB;
      return club;
    }).toList();
    final result = CpuManagerEngine.runRound(
      clubs: clubs,
      freeAgents: [freeGoalkeeper],
      userClubId: career.userClubId,
      season: career.season,
      round: 1,
      currentDate: DateTime(career.season, 3, 15),
      careerId: career.careerId,
    );
    final events = CpuMarketNewsEngine.build(
      result: result,
      date: DateTime(career.season, 3, 15),
      season: career.season,
      round: 1,
    );
    career = career.copyWith(
      clubs: result.clubs,
      freeAgents: result.freeAgents,
      news: events,
    );

    final restored = CareerState.fromJson(career.toJson());

    expect(restored.news.map((event) => event.id), containsAll(events.map((e) => e.id)));
    _expectNoDuplicatePlayers(restored.clubs, restored.freeAgents);
    expect(
      restored.clubs
          .expand((club) => club.squad)
          .where((player) => player.id == freeGoalkeeper.id),
      hasLength(1),
    );
  });

  test('CPU responde contraproposta de renovação pelo ContractEngine', () {
    final career = _career('cpu-renew-counter');
    final cpuBase = career.clubs[1];
    final original = cpuBase.squad.first;
    final expiring = original.copyWith(
      age: 31,
      overall: cpuBase.reputation,
      potential: cpuBase.reputation,
      contract: original.contract.copyWith(
        salary: 10000,
        endSeason: career.season,
      ),
    );
    final cpu = cpuBase.copyWith(
      money: 1000000000,
      squad: cpuBase.squad
          .map((player) => player.id == original.id ? expiring : player)
          .toList(),
    );
    final clubs = career.clubs
        .map((club) => club.id == cpu.id ? cpu : club)
        .toList();

    final result = CpuManagerEngine.runRound(
      clubs: clubs,
      freeAgents: career.freeAgents,
      userClubId: career.userClubId,
      season: career.season,
      round: 1,
      currentDate: DateTime(career.season, 5, 15),
      careerId: career.careerId,
    );
    final renewed = result.clubs
        .firstWhere((club) => club.id == cpu.id)
        .squad
        .firstWhere((player) => player.id == original.id);

    expect(renewed.contract.endSeason, career.season + 3);
    expect(renewed.salary, greaterThan(expiring.salary));
  });

  test('janela fechada impede contratações da CPU', () {
    final career = _career('cpu-window');

    final result = CpuManagerEngine.runRound(
      clubs: career.clubs,
      freeAgents: career.freeAgents,
      userClubId: career.userClubId,
      season: career.season,
      round: 2,
      currentDate: DateTime(career.season, 5, 15),
      careerId: career.careerId,
    );

    expect(result.moves, isEmpty);
    expect(result.interests, isEmpty);
    expect(result.freeAgents.length, career.freeAgents.length);
  });

  test('CPU limita o volume de negócios por rodada', () {
    final career = _career('cpu-volume');

    final result = CpuManagerEngine.runRound(
      clubs: career.clubs,
      freeAgents: career.freeAgents,
      userClubId: career.userClubId,
      season: career.season,
      round: 2,
      currentDate: DateTime(career.season, 3, 15),
      careerId: career.careerId,
    );

    expect(
      result.moves.length,
      lessThanOrEqualTo(CpuManagerEngine.maxMarketMovesPerRound),
    );
  });

  test('estratégia mantém prioridade e alvos estáveis dentro da mesma janela', () {
    final career = _career('cpu-window-strategy');
    final buyer = _withoutPosition(
      career.clubs[1],
      PlayerPosition.gol,
      limit: 19,
    );
    final needs = CpuSquadNeedsEngine.assess(buyer);

    final first = CpuMarketStrategyEngine.build(
      buyer: buyer,
      needs: needs,
      careerId: career.careerId,
      season: career.season,
      round: 2,
      currentDate: DateTime(career.season, 3, 10),
    );
    final later = CpuMarketStrategyEngine.build(
      buyer: buyer,
      needs: needs,
      careerId: career.careerId,
      season: career.season,
      round: 8,
      currentDate: DateTime(career.season, 4, 20),
    );

    expect(first, isNotNull);
    expect(later, isNotNull);
    final firstPlan = first!;
    final laterPlan = later!;
    expect(firstPlan.need.position, laterPlan.need.position);
    expect(firstPlan.targetSeed, laterPlan.targetSeed);
  });

  test('estratégia muda entre carreiras sem tornar a janela caótica', () {
    final career = _career('cpu-strategy-a');
    final buyer = _withoutPosition(
      career.clubs[1],
      PlayerPosition.gol,
      limit: 19,
    );
    final needs = CpuSquadNeedsEngine.assess(buyer);

    final first = CpuMarketStrategyEngine.build(
      buyer: buyer,
      needs: needs,
      careerId: 'career-a',
      season: career.season,
      round: 2,
      currentDate: DateTime(career.season, 3, 15),
    );
    final otherCareer = CpuMarketStrategyEngine.build(
      buyer: buyer,
      needs: needs,
      careerId: 'career-b',
      season: career.season,
      round: 2,
      currentDate: DateTime(career.season, 3, 15),
    );

    expect(first, isNotNull);
    expect(otherCareer, isNotNull);
    final firstPlan = first!;
    final otherCareerPlan = otherCareer!;
    expect(firstPlan.targetSeed, isNot(otherCareerPlan.targetSeed));
  });

  test('estratégia financeira diferencia oportunidade e clube ambicioso', () {
    final career = _career('cpu-strategy-finance');
    final pressured = _withoutPosition(
      career.clubs[1].copyWith(
        money: 5000000,
        transferBudget: 5000000,
      ),
      PlayerPosition.gol,
      limit: 19,
    );
    final ambitious = _withoutPosition(
      career.clubs[2].copyWith(
        reputation: 85,
        money: 1000000000,
        transferBudget: 1000000000,
      ),
      PlayerPosition.gol,
      limit: 19,
    );

    final low = CpuMarketStrategyEngine.build(
      buyer: pressured,
      needs: CpuSquadNeedsEngine.assess(pressured),
      careerId: career.careerId,
      season: career.season,
      round: 2,
      currentDate: DateTime(career.season, 3, 15),
    );
    final high = CpuMarketStrategyEngine.build(
      buyer: ambitious,
      needs: CpuSquadNeedsEngine.assess(ambitious),
      careerId: career.careerId,
      season: career.season,
      round: 2,
      currentDate: DateTime(career.season, 3, 15),
    );

    expect(low, isNotNull);
    expect(high, isNotNull);
    final lowPlan = low!;
    final highPlan = high!;
    expect(lowPlan.approach, CpuMarketApproach.opportunistic);
    expect(lowPlan.preferFreeAgents, isTrue);
    expect(highPlan.approach, CpuMarketApproach.ambitious);
  });

  test('CPU tenta alvo alternativo quando perde a prioridade para outro clube', () {
    final career = _career('cpu-fallback-target');
    final buyerA = _withoutPosition(
      career.clubs[1].copyWith(
        money: 1000000000,
        transferBudget: 1000000000,
      ),
      PlayerPosition.gol,
      limit: 19,
    );
    final buyerB = _withoutPosition(
      career.clubs[2].copyWith(
        money: 1000000000,
        transferBudget: 1000000000,
      ),
      PlayerPosition.gol,
      limit: 19,
    );
    final highOverall = buyerA.reputation > buyerB.reputation
        ? buyerA.reputation
        : buyerB.reputation;
    final primary = _freeGoalkeeper(
      career,
      id: 'fallback-primary',
      buyer: buyerA,
    ).copyWith(
      overall: highOverall,
      potential: highOverall + 2,
    );
    final alternative = primary.copyWith(
      id: 'fallback-alternative',
      overall: highOverall - 4,
      potential: highOverall - 2,
    );

    final result = CpuManagerEngine.runRound(
      clubs: [career.userClub, buyerA, buyerB],
      freeAgents: [primary, alternative],
      userClubId: career.userClubId,
      season: career.season,
      round: 2,
      currentDate: DateTime(career.season, 3, 15),
      careerId: career.careerId,
    );

    expect(result.interests, hasLength(2));
    expect(
      result.interests.map((interest) => interest.playerId).toSet(),
      {'fallback-primary'},
    );
    expect(result.moves, hasLength(2));
    expect(
      result.moves.map((move) => move.playerId).toSet(),
      {'fallback-primary', 'fallback-alternative'},
    );
    _expectNoDuplicatePlayers(result.clubs, result.freeAgents);
  });

  test('recrutamento mantém lista curta de alternativas para a prioridade', () {
    final career = _career('cpu-shortlist');
    final buyer = _withoutPosition(
      career.clubs[1],
      PlayerPosition.gol,
      limit: 19,
    );
    final need = CpuSquadNeedsEngine.assess(buyer).first;
    final freeAgents = List.generate(
      4,
      (index) => _freeGoalkeeper(
        career,
        id: 'shortlist-$index',
        buyer: buyer,
      ).copyWith(overall: buyer.reputation - index),
    );

    final targets = CpuRecruitmentEngine.shortlist(
      buyer: buyer,
      need: need,
      freeAgents: freeAgents,
      clubs: [career.userClub, buyer],
      userClubId: career.userClubId,
      season: career.season,
      preferFreeAgents: true,
      randomSeed: 77,
      limit: CpuManagerEngine.maxTargetsPerClub,
    );

    expect(targets, hasLength(CpuManagerEngine.maxTargetsPerClub));
    expect(targets.every((target) => target.seller == null), isTrue);
    expect(targets.map((target) => target.player.id).toSet(), hasLength(3));
  });

  test('várias rodadas e temporadas mantêm IDs únicos no mercado CPU', () {
    final career = _career('cpu-multi-season');
    var clubs = career.clubs;
    var freeAgents = career.freeAgents;

    for (final season in [career.season, career.season + 1]) {
      for (var round = 1; round <= 6; round++) {
        final result = CpuManagerEngine.runRound(
          clubs: clubs,
          freeAgents: freeAgents,
          userClubId: career.userClubId,
          season: season,
          round: round,
          currentDate: DateTime(season, 3, 15),
          careerId: career.careerId,
        );
        clubs = result.clubs;
        freeAgents = result.freeAgents;
        _expectNoDuplicatePlayers(clubs, freeAgents);
      }
    }
  });
}

CareerState _career(String id) => CareerFactory.create(
      careerId: id,
      careerName: id,
      manager: const ManagerProfile(displayName: 'Teste'),
      userClubId: clubSeeds.first.id,
    );

Club _withoutPosition(
  Club club,
  PlayerPosition position, {
  required int limit,
}) =>
    club.copyWith(
      squad: club.squad
          .where((player) => player.primaryPosition != position)
          .take(limit)
          .toList(),
    );

Player _freeGoalkeeper(
  CareerState career, {
  required String id,
  required Club buyer,
}) {
  final template = career.clubs[3].squad.firstWhere(
    (player) => player.primaryPosition == PlayerPosition.gol,
  );
  return template.copyWith(
    id: id,
    overall: buyer.reputation,
    potential: buyer.reputation + 2,
    contract: template.contract.copyWith(salary: 10000),
    clearClubId: true,
    listed: true,
    shirtNumber: 0,
  );
}

void _expectNoDuplicatePlayers(List<Club> clubs, List<Player> freeAgents) {
  final ids = <String>[];
  for (final club in clubs) {
    ids.addAll(club.squad.map((player) => player.id));
  }
  ids.addAll(freeAgents.map((player) => player.id));
  expect(ids.toSet().length, ids.length);
}
