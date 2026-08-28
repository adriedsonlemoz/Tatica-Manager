import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/data/club_seed.dart';
import 'package:tatica_manager/domain/career/manager_profile.dart';
import 'package:tatica_manager/domain/season/career_state.dart';
import 'package:tatica_manager/game/career/career_factory.dart';
import 'package:tatica_manager/game/career/manager_career_engine.dart';

void main() {
  test('save legado cria trajetória profissional sem quebrar carreira', () {
    final original = CareerFactory.create(
      careerId: 'manager-legacy',
      careerName: 'Legado',
      manager: const ManagerProfile(displayName: 'Técnico'),
      userClubId: clubSeeds.first.id,
    );
    final json = Map<String, dynamic>.from(original.toJson())..remove('managerCareer');

    final restored = CareerState.fromJson(json);

    expect(restored.schemaVersion, CareerState.currentSchemaVersion);
    expect(restored.managerEmployed, isTrue);
    expect(restored.managerCareer.tenures, hasLength(1));
    expect(restored.managerCareer.activeTenure?.clubId, original.userClubId);
  });

  test('técnico pode deixar clube, procurar vaga e assumir novo projeto', () {
    final original = CareerFactory.create(
      careerId: 'manager-move',
      careerName: 'Mudança',
      manager: const ManagerProfile(displayName: 'Técnico'),
      userClubId: clubSeeds.first.id,
    );

    final unemployed = ManagerCareerEngine.leaveCurrentClub(original);
    expect(unemployed.managerUnemployed, isTrue);
    expect(unemployed.managerCareer.activeTenure, isNull);
    expect(unemployed.managerCareer.tenures.single.endReason, 'Pedido de demissão');
    expect(unemployed.nextUserFixture, isNull);

    final jobs = ManagerCareerEngine.availableJobs(unemployed);
    expect(jobs.length, greaterThanOrEqualTo(3));
    final target = jobs.firstWhere((job) => job.canApply);
    final hired = ManagerCareerEngine.acceptJob(unemployed, target.club.id);

    expect(hired.managerEmployed, isTrue);
    expect(hired.userClubId, target.club.id);
    expect(hired.managerCareer.activeTenure?.clubId, target.club.id);
    expect(hired.managerCareer.tenures, hasLength(2));
    expect(hired.starterIds, hasLength(11));
    expect(hired.userClub.managerName, hired.manager.displayName);
  });

  test('assumir clube após dias sem emprego atualiza rodadas passadas sem travar calendário', () {
    final original = CareerFactory.create(
      careerId: 'manager-catchup',
      careerName: 'Mercado longo',
      manager: const ManagerProfile(displayName: 'Técnico'),
      userClubId: clubSeeds.first.id,
    );
    final unemployed = ManagerCareerEngine.leaveCurrentClub(original).copyWith(
      currentDate: original.currentDate.add(const Duration(days: 12)),
    );
    final target = ManagerCareerEngine.availableJobs(unemployed)
        .firstWhere((job) => job.canApply);

    final hired = ManagerCareerEngine.acceptJob(unemployed, target.club.id);

    expect(hired.roundIndex, greaterThan(0));
    expect(
      hired.fixtures.where((fixture) => fixture.date.isBefore(hired.currentDate)).every((fixture) => fixture.played),
      isTrue,
    );
    expect(
      hired.nextUserFixture == null || !hired.nextUserFixture!.date.isBefore(hired.currentDate),
      isTrue,
    );
  });

  test('reputação profissional considera desempenho apenas após partidas', () {
    final career = CareerFactory.create(
      careerId: 'manager-reputation',
      careerName: 'Reputação',
      manager: const ManagerProfile(displayName: 'Técnico'),
      userClubId: clubSeeds.first.id,
    );

    expect(ManagerCareerEngine.reputationFor(career), career.userClub.reputation);
  });
}
