import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/data/club_seed.dart';
import 'package:tatica_manager/domain/career/manager_profile.dart';
import 'package:tatica_manager/domain/club/club.dart';
import 'package:tatica_manager/domain/finance/club_administration.dart';
import 'package:tatica_manager/domain/finance/finance.dart';
import 'package:tatica_manager/domain/finance/sponsorship.dart';
import 'package:tatica_manager/domain/season/career_state.dart';
import 'package:tatica_manager/game/career/career_factory.dart';
import 'package:tatica_manager/game/finance/club_administration_engine.dart';
import 'package:tatica_manager/game/finance/finance_engine.dart';
import 'package:tatica_manager/game/finance/sponsorship_engine.dart';
import 'package:tatica_manager/game/stadium/stadium_engine.dart';

void main() {
  test('telas financeiras expõem novo painel do estádio e maiores salários clicáveis', () {
    final finances =
        File('lib/features/finances/finances_screen.dart').readAsStringSync();
    final financeManagement = File(
      'lib/features/finances/finances_management_components.dart',
    ).readAsStringSync();
    final stadium = [
      File('lib/features/stadium/stadium_screen.dart').readAsStringSync(),
      File('lib/features/stadium/stadium_components.dart').readAsStringSync(),
      File('lib/features/stadium/stadium_scene.dart').readAsStringSync(),
    ].join('\n');
    final stadiumEngine =
        File('lib/game/stadium/stadium_engine.dart').readAsStringSync();

    expect(finances, contains("Tab(text: 'Salários')"));
    expect(finances, contains('PlayerProfileScreen('));
    expect(finances, contains("title: 'Patrocínios'"));
    expect(stadium, contains('assets/images/stadium/stadium_night.webp'));
    expect(stadium, contains('assets/images/stadium/covered_stands.webp'));
    expect(File('assets/images/stadium/stadium_night.webp').existsSync(), isTrue);
    expect(File('assets/images/stadium/covered_stands.webp').existsSync(), isTrue);
    expect(stadium, contains('CENTRO DE TREINAMENTO'));
    expect(stadium, contains('MANUTENÇÃO'));
    expect(stadium, contains('MELHORIAS'));
    expect(financeManagement, contains('ORÇAMENTOS DEPARTAMENTAIS'));
    expect(financeManagement, contains('PROPOSTAS RECEBIDAS'));
    expect(stadiumEngine, contains('Camarotes'));
    expect(stadiumEngine, contains('Lojas'));
    expect(stadiumEngine, contains('Alimentação'));
    expect(stadiumEngine, contains('Publicidade'));
    expect(stadiumEngine, contains('Estacionamento'));
    expect(stadiumEngine, contains('Museu do clube'));
  });

  test('rodada em casa separa receitas de estádio e patrocínios', () {
    final career = CareerFactory.create(
      careerId: 'finance-stadium-test',
      careerName: 'Finanças e estádio',
      manager: const ManagerProfile(displayName: 'Teste'),
      userClubId: clubSeeds.first.id,
      seed: 20260825,
    );
    final club = career.userClub;
    final fixture = career.fixtures.first;

    final result = FinanceEngine.settleUserRound(
      club: club,
      fixture: fixture,
      season: career.season,
      round: 1,
      home: true,
      tablePosition: 3,
    );
    final kinds = result.transactions.map((item) => item.kind).toSet();

    expect(kinds, contains(FinanceKind.sponsorship));
    expect(kinds, contains(FinanceKind.matchday));
    expect(kinds, contains(FinanceKind.hospitality));
    expect(kinds, contains(FinanceKind.retail));
    expect(kinds, contains(FinanceKind.food));
    expect(kinds, contains(FinanceKind.stadiumAdvertising));
    expect(kinds, contains(FinanceKind.tvRights));
    expect(kinds, contains(FinanceKind.wages));
    expect(kinds, contains(FinanceKind.operations));
    expect(result.club.money, isNot(club.money));
  });

  test('estádio legado recebe níveis comerciais sem quebrar save antigo', () {
    final restored = Stadium.fromJson({
      'name': 'Estádio legado',
      'capacity': 42000,
      'ticketPrice': 55,
    });

    expect(restored.hospitalityLevel, 1);
    expect(restored.retailLevel, 1);
    expect(restored.foodLevel, 1);
    expect(restored.advertisingLevel, 1);
    expect(restored.commercialLevel, 4);
    expect(restored.standsLevel, 1);
    expect(restored.parkingLevel, 0);
    expect(restored.museumLevel, 0);
    expect(restored.pitchCondition, 88);
    expect(restored.structureCondition, 85);
    expect(restored.securityCondition, 90);
    expect(restored.comfortCondition, 86);
    expect(restored.trainingCenterLevel, 1);
    expect(restored.projects, isEmpty);
  });

  test('contrato de patrocínio persiste e gera receita por rodada', () {
    final career = CareerFactory.create(
      careerId: 'sponsor-persistence-test',
      careerName: 'Patrocínio',
      manager: const ManagerProfile(displayName: 'Teste'),
      userClubId: clubSeeds.first.id,
      seed: 20260825,
    );
    final club = career.userClub;
    final contract = SponsorshipContract(
      id: 'sponsor-test',
      sponsorName: 'Marca Teste',
      type: SponsorshipType.main,
      annualValue: 7600000,
      startSeason: career.season,
      endSeason: career.season + 2,
      performanceBonus: 760000,
      negotiable: true,
    );
    final restored = Club.fromJson(
      club.copyWith(sponsorships: [contract]).toJson(),
    );
    final contracts = SponsorshipEngine.contractsFor(
      restored,
      season: career.season,
    );
    final revenue = SponsorshipEngine.settleRound(
      club: restored,
      season: career.season,
      tablePosition: 2,
    );

    expect(contracts, hasLength(1));
    expect(contracts.single.sponsorName, 'Marca Teste');
    expect(contracts.single.negotiable, isTrue);
    expect(revenue.single.baseValue, greaterThan(0));
    expect(revenue.single.bonusValue, greaterThan(0));
  });

  test('receita comercial do estádio cresce com infraestrutura', () {
    final career = CareerFactory.create(
      careerId: 'stadium-level-test',
      careerName: 'Estádio',
      manager: const ManagerProfile(displayName: 'Teste'),
      userClubId: clubSeeds.first.id,
      seed: 20260825,
    );
    final club = career.userClub;
    final upgraded = club.copyWith(
      stadium: club.stadium.copyWith(
        hospitalityLevel: 3,
        retailLevel: 3,
        foodLevel: 3,
        advertisingLevel: 3,
      ),
    );

    expect(
      StadiumEngine.projectedCommercialRevenue(club: upgraded),
      greaterThan(StadiumEngine.projectedCommercialRevenue(club: club)),
    );
  });

  test('save legado recebe administração retrocompatível sem perder IDs', () {
    final original = CareerFactory.create(
      careerId: 'legacy-administration-test',
      careerName: 'Administração legada',
      manager: const ManagerProfile(displayName: 'Teste'),
      userClubId: clubSeeds.first.id,
      seed: 20260826,
    );
    final legacyJson = original.toJson()
      ..remove('clubAdministration')
      ..['schemaVersion'] = 9;
    final clubs = (legacyJson['clubs'] as List).cast<Map<String, dynamic>>();
    final userClubJson = clubs.firstWhere(
      (club) => club['id'] == original.userClubId,
    );
    (userClubJson['stadium'] as Map<String, dynamic>)
      ..remove('baseName')
      ..remove('standsLevel')
      ..remove('parkingLevel')
      ..remove('museumLevel');
    userClubJson['sponsorships'] = const [];

    final restored = ClubAdministrationEngine.ensureInitialized(
      CareerState.fromJson(legacyJson),
    );

    expect(restored.schemaVersion, original.schemaVersion);
    expect(restored.userClub.id, original.userClub.id);
    expect(restored.userClub.squad.map((player) => player.id),
        original.userClub.squad.map((player) => player.id));
    expect(restored.clubAdministration.budgetPlan.available, hasLength(6));
    expect(restored.userClub.sponsorships, isNotEmpty);
    expect(
      restored.clubAdministration.sponsorshipProposals,
      isNotEmpty,
    );
    expect(
      restored.inbox.any(
        (message) => message.sponsorshipProposalId != null,
      ),
      isTrue,
    );
  });

  test('orçamentos respeitam o caixa e sincronizam transferências', () {
    final career = CareerFactory.create(
      careerId: 'budget-allocation-test',
      careerName: 'Orçamentos',
      manager: const ManagerProfile(displayName: 'Teste'),
      userClubId: clubSeeds.first.id,
      seed: 20260827,
    );
    final available = {
      ClubDepartment.transfers: 30000000,
      ClubDepartment.payroll: 12000000,
      ClubDepartment.infrastructure: 7000000,
      ClubDepartment.youthAcademy: 6000000,
      ClubDepartment.stadium: 9000000,
      ClubDepartment.operations: 5000000,
    };
    final result = ClubAdministrationEngine.allocateBudgets(career, available);

    expect(result.state.userClub.transferBudget, 30000000);
    expect(
      result.state.clubAdministration.budgetPlan
          .forDepartment(ClubDepartment.stadium),
      9000000,
    );
    expect(
      () => ClubAdministrationEngine.allocateBudgets(
        career,
        {
          for (final department in ClubDepartment.values)
            department: career.userClub.money,
        },
      ),
      throwsStateError,
    );
  });

  test('troca de clube não transporta orçamento nem propostas antigas', () {
    final career = CareerFactory.create(
      careerId: 'club-change-administration-test',
      careerName: 'Novo emprego',
      manager: const ManagerProfile(displayName: 'Teste'),
      userClubId: clubSeeds.first.id,
      seed: 20260827,
    );
    final newClubId = career.clubs[1].id;
    final changed = ClubAdministrationEngine.ensureInitialized(
      career.copyWith(userClubId: newClubId),
    );

    expect(changed.clubAdministration.budgetPlan.clubId, newClubId);
    expect(
      changed.clubAdministration.sponsorshipProposals.every(
        (proposal) => proposal.id.startsWith('$newClubId-'),
      ),
      isTrue,
    );
  });

  test('preço do ingresso altera demanda projetada', () {
    final career = CareerFactory.create(
      careerId: 'ticket-demand-test',
      careerName: 'Preço e demanda',
      manager: const ManagerProfile(displayName: 'Teste'),
      userClubId: clubSeeds.first.id,
      seed: 20260828,
    );
    final club = career.userClub;
    final cheap = club.copyWith(
      stadium: club.stadium.copyWith(ticketPrice: 35),
    );
    final expensive = club.copyWith(
      stadium: club.stadium.copyWith(ticketPrice: 260),
    );

    expect(
      StadiumEngine.attendanceFor(club: cheap, tablePosition: 10),
      greaterThan(
        StadiumEngine.attendanceFor(club: expensive, tablePosition: 10),
      ),
    );
  });

  test('obra desconta caixa e orçamento e persiste no histórico', () {
    final career = CareerFactory.create(
      careerId: 'stadium-upgrade-test',
      careerName: 'Obra real',
      manager: const ManagerProfile(displayName: 'Teste'),
      userClubId: clubSeeds.first.id,
      seed: 20260829,
    );
    final budget = {
      for (final department in ClubDepartment.values) department: 0,
      ClubDepartment.transfers: 10000000,
      ClubDepartment.stadium: 12000000,
    };
    final allocated =
        ClubAdministrationEngine.allocateBudgets(career, budget).state;
    final beforeMoney = allocated.userClub.money;
    final beforeBudget = allocated.clubAdministration.budgetPlan
        .forDepartment(ClubDepartment.stadium);
    final result = ClubAdministrationEngine.upgradeStadium(
      allocated,
      StadiumFacility.parking,
      negotiated: true,
    );
    final scheduled = CareerState.fromJson(result.state.toJson());
    final project = scheduled.userClub.stadium.projects.singleWhere(
      (item) => item.kind == StadiumProjectKind.parking && item.isActive,
    );

    expect(scheduled.userClub.stadium.parkingLevel, 0);
    expect(scheduled.userClub.money, lessThan(beforeMoney));
    expect(
      scheduled.clubAdministration.budgetPlan
          .forDepartment(ClubDepartment.stadium),
      lessThan(beforeBudget),
    );
    expect(scheduled.finances.last.kind, FinanceKind.stadiumInvestment);
    expect(project.completesAt.isAfter(project.startedAt), isTrue);

    final completed = ClubAdministrationEngine.advanceDay(
      scheduled.copyWith(currentDate: project.completesAt),
    );
    expect(completed.userClub.stadium.parkingLevel, 1);
    expect(
      completed.userClub.stadium.projects
          .singleWhere((item) => item.id == project.id)
          .status,
      StadiumProjectStatus.completed,
    );
  });

  test('manutenção e centro de treinamento persistem no save', () {
    final career = CareerFactory.create(
      careerId: 'stadium-new-systems-test',
      careerName: 'Novos sistemas do estádio',
      manager: const ManagerProfile(displayName: 'Teste'),
      userClubId: clubSeeds.first.id,
      seed: 20260830,
    );
    final budget = {
      for (final department in ClubDepartment.values) department: 0,
      ClubDepartment.stadium: 15000000,
    };
    final allocated = ClubAdministrationEngine.allocateBudgets(career, budget).state;
    final maintained = ClubAdministrationEngine.performStadiumMaintenance(allocated).state;
    expect(maintained.userClub.stadium.pitchCondition, 100);
    expect(maintained.userClub.stadium.structureCondition, 100);
    expect(maintained.userClub.stadium.securityCondition, 100);
    expect(maintained.userClub.stadium.comfortCondition, 100);

    final training = ClubAdministrationEngine.upgradeTrainingCenter(maintained).state;
    final restored = CareerState.fromJson(training.toJson());
    final project = restored.userClub.stadium.projects.singleWhere(
      (item) => item.kind == StadiumProjectKind.trainingCenter && item.isActive,
    );
    expect(restored.userClub.stadium.trainingCenterLevel, 1);
    expect(project.targetLevel, 2);

    final completed = ClubAdministrationEngine.advanceDay(
      restored.copyWith(currentDate: project.completesAt),
    );
    expect(completed.userClub.stadium.trainingCenterLevel, 2);
  });

  test('patrocínio exige decisão e naming rights preserva nome original', () {
    final career = CareerFactory.create(
      careerId: 'sponsor-decision-test',
      careerName: 'Decisão comercial',
      manager: const ManagerProfile(displayName: 'Teste'),
      userClubId: clubSeeds.first.id,
      seed: 20260830,
    );
    final proposal = career.clubAdministration.sponsorshipProposals.firstWhere(
      (item) => item.type == SponsorshipType.stadium,
    );
    final originalName = career.userClub.stadium.originalName;
    final countered = ClubAdministrationEngine.counterSponsorship(
      career,
      proposal.id,
      requestedAnnualValue: (proposal.annualValue * 1.10).round(),
    ).state;
    final accepted = ClubAdministrationEngine.acceptSponsorship(
      countered,
      proposal.id,
    ).state;
    final restored = CareerState.fromJson(accepted.toJson());

    expect(
      restored.userClub.sponsorships.any(
        (contract) => contract.type == SponsorshipType.stadium,
      ),
      isTrue,
    );
    expect(restored.userClub.stadium.name, contains(proposal.sponsorName));
    expect(restored.userClub.stadium.originalName, originalName);
    expect(
      restored.clubAdministration.sponsorshipProposals
          .firstWhere((item) => item.id == proposal.id)
          .status,
      SponsorshipProposalStatus.accepted,
    );
  });
}
