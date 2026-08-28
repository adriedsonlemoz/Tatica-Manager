import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/data/club_seed.dart';
import 'package:tatica_manager/domain/career/manager_profile.dart';
import 'package:tatica_manager/domain/season/career_event.dart';
import 'package:tatica_manager/domain/season/career_state.dart';
import 'package:tatica_manager/game/match/engine/match_engine.dart';
import 'package:tatica_manager/game/career/career_factory.dart';
import 'package:tatica_manager/game/contract/contract_lifecycle_engine.dart';

void main() {
  test('carreira sobrevive a serialização mantendo metadados do save', () {
    final original = CareerFactory.create(
      careerId: 'career-serialization',
      careerName: 'Rumo à Glória',
      manager: const ManagerProfile(
        displayName: 'Adriedson Lemos',
        nickname: 'Adri',
        nationality: 'Brasil',
        ageAtStart: 35,
        birthPlace: 'São Paulo, SP, Brasil',
        birthCountry: 'Brasil',
        birthState: 'SP',
        birthCity: 'São Paulo',
      ),
      userClubId: clubSeeds.first.id,
    );
    final fixture = original.fixtures.first;
    final home = original.clubs.firstWhere((club) => club.id == fixture.homeClubId);
    final away = original.clubs.firstWhere((club) => club.id == fixture.awayClubId);
    final result = MatchEngine.simulate(
      fixture: fixture,
      home: home,
      away: away,
      seed: 12345,
    );
    final withHistory = original.copyWith(
      news: [
        CareerEvent(
          id: 'serialization-news',
          date: original.currentDate,
          type: CareerEventType.info,
          title: 'Teste',
          message: 'Persistência de notícia.',
          clubId: original.userClubId,
        ),
      ],
      matchHistory: [result],
    );
    final restored = CareerState.fromJson(withHistory.toJson());

    expect(restored.careerId, original.careerId);
    expect(restored.careerName, original.careerName);
    expect(restored.manager.displayName, original.manager.displayName);
    expect(restored.manager.nickname, 'Adri');
    expect(restored.manager.ageAtStart, 35);
    expect(restored.manager.birthPlace, 'São Paulo, SP, Brasil');
    expect(restored.manager.birthCountry, 'Brasil');
    expect(restored.manager.birthState, 'SP');
    expect(restored.manager.birthCity, 'São Paulo');
    expect(restored.managerHistory, hasLength(1));
    expect(restored.managerHistory.single.displayName, 'Adriedson Lemos');
    expect(restored.userClubId, original.userClubId);
    expect(restored.clubs.length, original.clubs.length);
    expect(restored.fixtures.length, original.fixtures.length);
    expect(restored.currentDate, original.currentDate);
    expect(restored.starterIds.length, 11);
    expect(restored.news.single.id, 'serialization-news');
    expect(restored.matchHistory.single.fixtureId, fixture.id);
  });

  test('save legado sem metadados ainda pode ser aberto', () {
    final original = CareerFactory.create(
      careerId: 'legacy-source',
      careerName: 'Origem',
      manager: const ManagerProfile(displayName: 'Técnico Teste'),
      userClubId: clubSeeds.first.id,
    );
    final legacyJson = Map<String, dynamic>.from(original.toJson())
      ..remove('careerId')
      ..remove('careerName')
      ..remove('manager')
      ..remove('createdAt')
      ..remove('currentDate')
      ..['schemaVersion'] = 1;

    final restored = CareerState.fromJson(legacyJson);

    expect(restored.careerId, startsWith('legacy-'));
    expect(restored.userClubId, original.userClubId);
    expect(restored.clubs, hasLength(20));
    expect(restored.currentDate, original.nextUserFixture!.date.subtract(const Duration(days: 3)));
  });
  test('save anterior reaproveita lastMatch como histórico inicial', () {
    final original = CareerFactory.create(
      careerId: 'legacy-match-history',
      careerName: 'Histórico legado',
      manager: const ManagerProfile(displayName: 'Técnico Teste'),
      userClubId: clubSeeds.first.id,
      seed: 20260824,
    );
    final fixture = original.fixtures.first;
    final home = original.clubs.firstWhere((club) => club.id == fixture.homeClubId);
    final away = original.clubs.firstWhere((club) => club.id == fixture.awayClubId);
    final result = MatchEngine.simulate(
      fixture: fixture,
      home: home,
      away: away,
      seed: 54321,
    );
    final legacyJson = original.copyWith(lastMatch: result).toJson()
      ..remove('matchHistory');

    final restored = CareerState.fromJson(legacyJson);

    expect(restored.lastMatch?.fixtureId, fixture.id);
    expect(restored.matchHistory.single.fixtureId, fixture.id);
  });


  test('save-load reconcilia vínculo vencido preservando o jogador livre', () {
    var career = CareerFactory.create(
      careerId: 'expired-save-load',
      careerName: 'Contrato vencido',
      manager: const ManagerProfile(displayName: 'Técnico Teste'),
      userClubId: clubSeeds.first.id,
      seed: 20260824,
    );
    final club = career.userClub;
    final player = club.squad.first;
    final expired = player.copyWith(
      contract: player.contract.copyWith(endSeason: career.season - 1),
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

    final restored = CareerState.fromJson(career.toJson());
    final reconciled = ContractLifecycleEngine.reconcile(restored).state;

    expect(
      reconciled.userClub.squad.any((item) => item.id == player.id),
      isFalse,
    );
    final free = reconciled.freeAgents.singleWhere(
      (item) => item.id == player.id,
    );
    expect(free.id, player.id);
    expect(free.overall, player.overall);
    expect(free.clubId, isNull);
  });

}
