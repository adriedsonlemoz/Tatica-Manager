import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/app/state/career_controller.dart';
import 'package:tatica_manager/app/state/game_controller.dart';
import 'package:tatica_manager/app/state/live_match_controller.dart';
import 'package:tatica_manager/app/state/providers.dart';
import 'package:tatica_manager/app/state/transfer_controller.dart';
import 'package:tatica_manager/core/save/career_repository.dart';
import 'package:tatica_manager/data/club_seed.dart';
import 'package:tatica_manager/domain/career/career_save_summary.dart';
import 'package:tatica_manager/domain/career/manager_profile.dart';
import 'package:tatica_manager/domain/career/new_career_config.dart';
import 'package:tatica_manager/domain/contract/contract.dart';
import 'package:tatica_manager/domain/formation/formation.dart';
import 'package:tatica_manager/domain/player/player.dart';
import 'package:tatica_manager/domain/tactic/tactic.dart';
import 'package:tatica_manager/domain/club/club_identity.dart';
import 'package:tatica_manager/domain/season/career_event.dart';
import 'package:tatica_manager/domain/season/career_state.dart';
import 'package:tatica_manager/domain/transfer/market_career.dart';
import 'package:tatica_manager/game/career/career_factory.dart';
import 'package:tatica_manager/game/contract/contract_engine.dart';
import 'package:tatica_manager/game/transfer/transfer_engine.dart';
import 'package:tatica_manager/game/transfer/market_career_engine.dart';
import 'package:tatica_manager/game/club/club_identity_engine.dart';

void main() {
  test('partida ao vivo possui estado separado da carreira ativa', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final career = _career();
    final matchDayCareer = career.copyWith(
      currentDate: career.nextUserFixture!.date,
    );

    container.read(gameControllerProvider.notifier).attachCareer(matchDayCareer);
    final live =
        container.read(liveMatchControllerProvider.notifier).prepareMatch();

    expect(live, isNotNull);
    expect(container.read(liveMatchControllerProvider), isNotNull);
    expect(container.read(gameControllerProvider).career?.careerId, matchDayCareer.careerId);

    container.read(liveMatchControllerProvider.notifier).reset();

    expect(container.read(liveMatchControllerProvider), isNull);
    expect(container.read(gameControllerProvider).career?.careerId, matchDayCareer.careerId);
  });

  test('compra entra em Negociações antes de alterar elenco ou caixa', () async {
    final repository = _MemoryCareerRepository();
    final container = ProviderContainer(
      overrides: [careerRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final career = _career();
    final freeAgent = career.freeAgents.first;

    container.read(gameControllerProvider.notifier).attachCareer(career);
    final result = await container.read(transferControllerProvider).buyPlayer(
          playerId: freeAgent.id,
          fee: 0,
          salary: freeAgent.salary * 2,
          years: 2,
        );

    final staged = container.read(gameControllerProvider).career!;
    expect(result.accepted, isTrue);
    expect(result.message, contains('Proposta enviada'));
    expect(staged.userClub.squad.any((player) => player.id == freeAgent.id), isFalse);
    expect(staged.freeAgents.any((player) => player.id == freeAgent.id), isTrue);
    expect(staged.finances, isEmpty);
    final negotiation = staged.transferNegotiations.single;
    expect(negotiation.status, TransferNegotiationStatus.waiting);

    final responded = MarketCareerEngine.advanceDay(
      staged.copyWith(currentDate: negotiation.nextActionDate),
    ).state;
    expect(
      responded.transferNegotiations.single.status,
      TransferNegotiationStatus.accepted,
    );
    container.read(gameControllerProvider.notifier).attachCareer(responded);
    final completed = await container
        .read(transferControllerProvider)
        .completeMarketNegotiation(negotiation.id);
    final updated = container.read(gameControllerProvider).career!;

    expect(completed.accepted, isTrue);
    expect(updated.userClub.squad.any((player) => player.id == freeAgent.id), isTrue);
    expect(updated.freeAgents.any((player) => player.id == freeAgent.id), isFalse);
    expect(repository.saved[career.careerId]?.careerId, career.careerId);
  });

  test('abrir save reconcilia contrato vencido sem duplicar jogador', () async {
    final repository = _MemoryCareerRepository();
    final container = ProviderContainer(
      overrides: [careerRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    var career = _career();
    final club = career.userClub;
    final player = club.squad.first;
    final expired = player.copyWith(
      contract: PlayerContract(
        salary: player.salary,
        endSeason: career.season - 1,
      ),
    );
    career = career.copyWith(
      clubs: career.clubs
          .map(
            (item) => item.id == club.id
                ? club.copyWith(
                    squad: club.squad
                        .map((candidate) =>
                            candidate.id == player.id ? expired : candidate)
                        .toList(),
                  )
                : item,
          )
          .toList(),
    );
    repository.saved[career.careerId] = career;

    final opened = await container
        .read(careerControllerProvider.notifier)
        .openCareer(career.careerId);
    final loaded = container.read(gameControllerProvider).career!;

    expect(opened, isTrue);
    expect(loaded.userClub.squad.any((item) => item.id == player.id), isFalse);
    expect(loaded.freeAgents.where((item) => item.id == player.id), hasLength(1));
    expect(repository.saved[career.careerId]!.freeAgents
        .where((item) => item.id == player.id), hasLength(1));
  });

  test('renovação entra em Negociações antes de aplicar luvas e salário', () async {
    final repository = _MemoryCareerRepository();
    final container = ProviderContainer(
      overrides: [careerRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final career = _career();
    final player = career.userClub.squad.first;
    final salary = ContractEngine.expectedSalary(player) + 1000;
    final moneyBefore = career.userClub.money;

    container.read(gameControllerProvider.notifier).attachCareer(career);
    final result = await container.read(transferControllerProvider).renewPlayer(
          playerId: player.id,
          salary: salary,
          years: 2,
        );
    final staged = container.read(gameControllerProvider).career!;

    expect(result.accepted, isTrue);
    expect(staged.userClub.money, moneyBefore);
    expect(
      staged.userClub.squad.singleWhere((item) => item.id == player.id).salary,
      player.salary,
    );
    expect(staged.finances, isEmpty);
    final negotiation = staged.transferNegotiations.single;
    expect(negotiation.kind, TransferNegotiationKind.contractRenewal);
    expect(negotiation.status, TransferNegotiationStatus.waiting);

    final responded = MarketCareerEngine.advanceDay(
      staged.copyWith(currentDate: negotiation.nextActionDate),
    ).state;
    expect(
      responded.transferNegotiations.single.status,
      TransferNegotiationStatus.accepted,
    );
    container.read(gameControllerProvider.notifier).attachCareer(responded);
    final completed = await container
        .read(transferControllerProvider)
        .completeMarketNegotiation(negotiation.id);
    final updated = container.read(gameControllerProvider).career!;
    final renewed = updated.userClub.squad
        .singleWhere((item) => item.id == player.id);

    expect(completed.accepted, isTrue);
    expect(updated.userClub.money, moneyBefore - salary * 2);
    expect(renewed.salary, salary);
    expect(renewed.contract.endSeason, career.season + 2);
    expect(
      updated.finances.where((tx) => tx.description.contains(player.displayName)),
      hasLength(1),
    );
  });

  test('pacote padrão personalizado é aplicado ao criar nova carreira', () async {
    final repository = _MemoryCareerRepository();
    final base = ClubIdentityEngine.defaultPack();
    repository.defaultClubIdentityPack = ClubIdentityPack(
      name: 'Comunidade',
      clubs: [
        base.clubs.first.copyWith(
          name: 'Horizonte Nacional FC',
          nickname: 'Horizonte',
          shortName: 'HNF',
        ),
        ...base.clubs.skip(1),
      ],
    );
    final container = ProviderContainer(
      overrides: [careerRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final created = await container.read(careerControllerProvider.notifier).createCareer(
          NewCareerConfig(
            careerName: 'Carreira Comunitária',
            manager: const ManagerProfile(displayName: 'Técnico Teste'),
            clubId: clubSeeds.first.id,
            formation: FormationType.f433,
            tactic: const Tactic(),
          ),
        );
    final career = container.read(gameControllerProvider).career!;

    expect(created, isTrue);
    expect(career.userClub.id, clubSeeds.first.id);
    expect(career.userClub.name, 'Horizonte Nacional FC');
    expect(career.userClub.nickname, 'Horizonte');
    expect(career.userClub.shortName, 'HNF');
  });

  test('editar clubes de um save não altera outro save nem seus IDs', () async {
    final repository = _MemoryCareerRepository();
    final first = _career().copyWith(careerId: 'career-one', careerName: 'Um');
    final second = _career().copyWith(careerId: 'career-two', careerName: 'Dois');
    repository.saved[first.careerId] = first;
    repository.saved[second.careerId] = second;
    final container = ProviderContainer(
      overrides: [careerRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final base = ClubIdentityEngine.packFromCareer(first);
    final pack = ClubIdentityPack(
      clubs: [
        base.clubs.first.copyWith(
          name: 'Clube Independente FC',
          nickname: 'Independente',
          shortName: 'CIF',
        ),
        ...base.clubs.skip(1),
      ],
    );

    await container.read(careerControllerProvider.notifier).saveClubIdentityPack(
          careerId: first.careerId,
          pack: pack,
        );

    expect(repository.saved[first.careerId]!.userClub.id, first.userClub.id);
    expect(repository.saved[first.careerId]!.userClub.name, 'Clube Independente FC');
    expect(repository.saved[second.careerId]!.userClub.name, second.userClub.name);
  });

  test('proposta recebida da CPU exige aceite das bases e conclusão separada', () async {
    final repository = _MemoryCareerRepository();
    final container = ProviderContainer(
      overrides: [careerRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    var career = _career().copyWith(currentDate: DateTime(2026, 3, 15));
    final player = career.userClub.squad.firstWhere(
      (item) => item.primaryPosition == PlayerPosition.gol,
    );
    final buyerBase = career.clubs[1];
    final buyer = buyerBase.copyWith(
      money: 1000000000,
      transferBudget: 1000000000,
      squad: buyerBase.squad
          .where((item) => item.primaryPosition != PlayerPosition.gol)
          .toList(),
    );
    final fee = TransferEngine.saleOfferFee(player: player, buyer: buyer);
    const eventId = 'incoming-controller-offer';
    final event = CareerEvent(
      id: eventId,
      date: career.currentDate,
      type: CareerEventType.transferOffer,
      title: 'Proposta recebida',
      message: 'Oferta de teste',
      playerId: player.id,
      clubId: buyer.id,
      amount: fee,
    );
    career = career.copyWith(
      clubs: career.clubs
          .map((club) => club.id == buyer.id ? buyer : club)
          .toList(),
      news: [event],
    );

    container.read(gameControllerProvider.notifier).attachCareer(career);
    final result = await container
        .read(transferControllerProvider)
        .acceptIncomingOffer(eventId);
    final updated = container.read(gameControllerProvider).career!;

    expect(result.accepted, isTrue);
    expect(updated.userClub.squad.any((item) => item.id == player.id), isTrue);
    expect(updated.finances, isEmpty);
    final negotiation = updated.transferNegotiations.single;
    expect(negotiation.status, TransferNegotiationStatus.accepted);
    final completion = await container
        .read(transferControllerProvider)
        .completeMarketNegotiation(negotiation.id);
    final completed = container.read(gameControllerProvider).career!;

    expect(completion.accepted, isTrue);
    expect(completed.userClub.squad.any((item) => item.id == player.id), isFalse);
    expect(
      completed.clubs
          .firstWhere((club) => club.id == buyer.id)
          .squad
          .where((item) => item.id == player.id),
      hasLength(1),
    );
    expect(
      completed.finances.where((tx) => tx.description.contains(player.displayName)),
      hasLength(1),
    );
  });

  test('recusar proposta da CPU preserva jogador e resolve o evento', () async {
    final repository = _MemoryCareerRepository();
    final container = ProviderContainer(
      overrides: [careerRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    var career = _career().copyWith(currentDate: DateTime(2026, 3, 15));
    final player = career.userClub.squad.firstWhere(
      (item) => item.primaryPosition == PlayerPosition.gol,
    );
    final buyerBase = career.clubs[1];
    final buyer = buyerBase.copyWith(
      money: 1000000000,
      transferBudget: 1000000000,
      squad: buyerBase.squad
          .where((item) => item.primaryPosition != PlayerPosition.gol)
          .toList(),
    );
    final fee = TransferEngine.saleOfferFee(player: player, buyer: buyer);
    const eventId = 'incoming-controller-reject';
    career = career.copyWith(
      clubs: career.clubs
          .map((club) => club.id == buyer.id ? buyer : club)
          .toList(),
      news: [
        CareerEvent(
          id: eventId,
          date: career.currentDate,
          type: CareerEventType.transferOffer,
          title: 'Proposta recebida',
          message: 'Oferta de teste',
          playerId: player.id,
          clubId: buyer.id,
          amount: fee,
        ),
      ],
    );

    container.read(gameControllerProvider.notifier).attachCareer(career);
    final result = await container
        .read(transferControllerProvider)
        .rejectIncomingOffer(eventId);
    final updated = container.read(gameControllerProvider).career!;

    expect(result.accepted, isTrue);
    expect(updated.userClub.squad.any((item) => item.id == player.id), isTrue);
    expect(updated.news.single.type, CareerEventType.info);
    expect(updated.news.single.title, 'Proposta recusada');
    expect(updated.finances, isEmpty);
    expect(
      updated.transferNegotiations.single.status,
      TransferNegotiationStatus.rejected,
    );
  });

  test('contraproposta entra em análise antes de qualquer conclusão', () async {
    final repository = _MemoryCareerRepository();
    final container = ProviderContainer(
      overrides: [careerRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    var career = _career().copyWith(currentDate: DateTime(2026, 3, 15));
    final player = career.userClub.squad.firstWhere(
      (item) => item.primaryPosition == PlayerPosition.gol,
    );
    final buyerBase = career.clubs[1];
    final buyer = buyerBase.copyWith(
      money: 1000000000,
      transferBudget: 1000000000,
      squad: buyerBase.squad
          .where((item) => item.primaryPosition != PlayerPosition.gol)
          .toList(),
    );
    final fee = TransferEngine.saleOfferFee(player: player, buyer: buyer);
    const eventId = 'incoming-controller-counter';
    career = career.copyWith(
      clubs: career.clubs
          .map((club) => club.id == buyer.id ? buyer : club)
          .toList(),
      news: [
        CareerEvent(
          id: eventId,
          date: career.currentDate,
          type: CareerEventType.transferOffer,
          title: 'Proposta recebida',
          message: 'Oferta de teste',
          playerId: player.id,
          clubId: buyer.id,
          amount: fee,
        ),
      ],
    );

    container.read(gameControllerProvider.notifier).attachCareer(career);
    final result = await container
        .read(transferControllerProvider)
        .counterIncomingOffer(eventId: eventId, fee: fee * 2);
    final updated = container.read(gameControllerProvider).career!;

    expect(result.accepted, isTrue);
    expect(updated.userClub.squad.any((item) => item.id == player.id), isTrue);
    expect(updated.transferNegotiations.single.status, TransferNegotiationStatus.waiting);
    expect(updated.finances, isEmpty);

    final advanced = MarketCareerEngine.advanceDay(
      updated.copyWith(
        currentDate: updated.transferNegotiations.single.nextActionDate,
      ),
    ).state;
    expect(
      advanced.transferNegotiations.single.status,
      isNot(TransferNegotiationStatus.waiting),
    );
    expect(advanced.userClub.squad.any((item) => item.id == player.id), isTrue);
  });

}

CareerState _career() => CareerFactory.create(
      careerId: 'controller-refactor',
      careerName: 'Refatoração',
      manager: const ManagerProfile(displayName: 'Técnico Teste'),
      userClubId: clubSeeds.first.id,
      seed: 20260824,
    );

class _MemoryCareerRepository implements CareerRepository {
  final Map<String, CareerState> saved = {};
  String? lastActiveCareerId;
  ClubIdentityPack? defaultClubIdentityPack;
  final Map<String, String> appValues = {};

  @override
  Future<void> delete(String careerId) async {
    saved.remove(careerId);
  }

  @override
  Future<CareerState?> load(String careerId) async => saved[careerId];

  @override
  Future<String?> loadLastActiveCareerId() async => lastActiveCareerId;

  @override
  Future<ClubIdentityPack?> loadDefaultClubIdentityPack() async =>
      defaultClubIdentityPack;

  @override
  Future<List<CareerSaveSummary>> listSaves() async => const [];

  @override
  Future<void> save(CareerState state) async {
    saved[state.careerId] = state;
  }

  @override
  Future<void> saveLastActiveCareerId(String? careerId) async {
    lastActiveCareerId = careerId;
  }

  @override
  Future<void> saveDefaultClubIdentityPack(ClubIdentityPack? pack) async {
    defaultClubIdentityPack = pack;
  }

  @override
  Future<String?> loadAppValue(String key) async => appValues[key];

  @override
  Future<void> saveAppValue(String key, String? value) async {
    if (value == null || value.trim().isEmpty) {
      appValues.remove(key);
    } else {
      appValues[key] = value;
    }
  }
}
