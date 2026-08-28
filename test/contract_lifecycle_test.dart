import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/data/club_seed.dart';
import 'package:tatica_manager/domain/career/manager_profile.dart';
import 'package:tatica_manager/domain/match/match_models.dart';
import 'package:tatica_manager/domain/player/player.dart';
import 'package:tatica_manager/domain/season/career_event.dart';
import 'package:tatica_manager/domain/season/career_state.dart';
import 'package:tatica_manager/game/career/career_factory.dart';
import 'package:tatica_manager/game/contract/contract_engine.dart';
import 'package:tatica_manager/game/contract/contract_lifecycle_engine.dart';
import 'package:tatica_manager/game/league/league_engine.dart';
import 'package:tatica_manager/game/season/daily_career_engine.dart';
import 'package:tatica_manager/game/season/season_engine.dart';

void main() {
  test('contrato próximo do vencimento gera alerta no avanço diário', () {
    var career = _career('contract-alert');
    final player = career.userClub.squad.first;
    career = _replaceUserPlayer(
      career,
      player.copyWith(
        overall: 99,
        contract: player.contract.copyWith(endSeason: career.season),
      ),
    );
    career = career.copyWith(
      currentDate: DateTime(career.season, 6, 30),
      fixtures: career.fixtures
          .map(
            (fixture) => fixture.date.isBefore(DateTime(career.season, 7, 1))
                ? fixture.copyWith(
                    played: true,
                    score: const MatchScore(0, 0),
                  )
                : fixture,
          )
          .toList(),
    );

    final result = DailyCareerEngine.advance(career);

    expect(result.state.currentDate, DateTime(career.season, 7, 1));
    expect(
      result.events.any(
        (event) =>
            event.type == CareerEventType.contractExpiring &&
            event.playerId == player.id,
      ),
      isTrue,
    );
  });

  test('contrato vencido é processado durante o avanço diário', () {
    var career = _career('daily-expiration');
    final player = career.userClub.squad.first;
    final expired = player.copyWith(
      contract: player.contract.copyWith(endSeason: career.season - 1),
    );
    career = _replaceUserPlayer(career, expired);

    final result = DailyCareerEngine.advance(career);

    expect(
      result.state.userClub.squad.any((item) => item.id == player.id),
      isFalse,
    );
    final free = result.state.freeAgents.singleWhere(
      (item) => item.id == player.id,
    );
    expect(free.id, player.id);
    expect(free.clubId, isNull);
    expect(free.overall, player.overall);
  });

  test('renovação aceita considera salário, duração e atualiza vínculo', () {
    final career = _career('renew-accepted');
    final player = career.userClub.squad.first;
    final salary = ContractEngine.expectedSalary(player) + 1000;

    final result = ContractEngine.negotiate(
      player: player,
      proposal: ContractProposal(salary: salary, years: 3),
      season: career.season,
      clubMoney: career.userClub.money,
    );

    expect(result.accepted, isTrue);
    expect(result.player.contract.salary, salary);
    expect(result.player.contract.endSeason, career.season + 3);
    expect(result.signingCost, salary * 2);
  });

  test('jogador veterano pode recusar duração excessiva', () {
    final career = _career('renew-refused');
    final player = career.userClub.squad.first.copyWith(age: 35);

    final result = ContractEngine.negotiate(
      player: player,
      proposal: ContractProposal(
        salary: ContractEngine.expectedSalary(player) * 2,
        years: 4,
      ),
      season: career.season,
      clubMoney: career.userClub.money,
    );

    expect(result.accepted, isFalse);
    expect(result.requiredSalary, isNull);
    expect(result.message, contains('recusou'));
  });

  test('salário abaixo da expectativa gera contraproposta', () {
    final career = _career('renew-counter');
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
    expect(result.message, contains('contraproposta'));
  });

  test('jogador livre preserva ID, atributos e histórico relevante', () {
    var career = _career('free-agent-preservation');
    final player = career.userClub.squad.first;
    final expired = player.copyWith(
      contract: player.contract.copyWith(endSeason: career.season - 1),
      history: [
        PlayerHistoryEntry(
          season: career.season - 1,
          clubName: career.userClub.name,
          overall: player.overall,
        ),
      ],
    );
    career = _replaceUserPlayer(career, expired);

    final result = ContractLifecycleEngine.reconcile(career);
    final free = result.state.freeAgents.singleWhere(
      (item) => item.id == player.id,
    );

    expect(result.releasedPlayerIds, contains(player.id));
    expect(free.id, player.id);
    expect(free.overall, expired.overall);
    expect(free.potential, expired.potential);
    expect(free.history.single.clubName, career.userClub.name);
    expect(free.clubId, isNull);
    expect(free.listed, isTrue);
  });

  test('vencimento remove do clube sem duplicar e é idempotente', () {
    var career = _career('expiration-idempotent');
    final player = career.userClub.squad.first;
    final expired = player.copyWith(
      contract: player.contract.copyWith(endSeason: career.season - 1),
    );
    career = _replaceUserPlayer(career, expired).copyWith(
      freeAgents: [...career.freeAgents, expired.copyWith(clearClubId: true)],
    );

    final first = ContractLifecycleEngine.reconcile(career);
    final second = ContractLifecycleEngine.reconcile(first.state);

    expect(
      first.state.userClub.squad.where((item) => item.id == player.id),
      isEmpty,
    );
    expect(
      first.state.freeAgents.where((item) => item.id == player.id),
      hasLength(1),
    );
    expect(second.changed, isFalse);
    expect(second.releasedPlayers, isEmpty);
    expect(
      second.state.freeAgents.where((item) => item.id == player.id),
      hasLength(1),
    );
  });

  test('virada de temporada libera contrato encerrado uma única vez', () {
    var career = _career('season-expiration');
    final player = career.userClub.squad.first;
    career = _replaceUserPlayer(
      career,
      player.copyWith(
        contract: player.contract.copyWith(endSeason: career.season),
      ),
    );
    career = _completeSeason(career);

    final next = SeasonEngine.advance(career);

    expect(next.season, career.season + 1);
    expect(
      next.clubs.expand((club) => club.squad).any((item) => item.id == player.id),
      isFalse,
    );
    final free = next.freeAgents.singleWhere((item) => item.id == player.id);
    expect(free.id, player.id);
    expect(free.clubId, isNull);
    expect(free.history.any((entry) => entry.season == career.season), isTrue);
  });

  test('save anterior sem campos novos continua compatível', () {
    final career = _career('legacy-contract-save');
    final legacyJson = Map<String, dynamic>.from(career.toJson())
      ..['schemaVersion'] = 3;
    final clubs = (legacyJson['clubs'] as List).cast<Map<String, dynamic>>();
    final firstClub = Map<String, dynamic>.from(clubs.first);
    final squad = (firstClub['squad'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
    squad.first.remove('listed');
    firstClub['squad'] = squad;
    legacyJson['clubs'] = [firstClub, ...clubs.skip(1)];

    final restored = CareerState.fromJson(legacyJson);

    expect(restored.schemaVersion, CareerState.currentSchemaVersion);
    expect(restored.userClub.squad.first.id, career.userClub.squad.first.id);
    expect(restored.userClub.squad.first.listed, isFalse);
  });
}

CareerState _career(String id) => CareerFactory.create(
      careerId: id,
      careerName: 'Contratos',
      manager: const ManagerProfile(displayName: 'Técnico Teste'),
      userClubId: clubSeeds.first.id,
      seed: 20260824,
    );

CareerState _replaceUserPlayer(CareerState career, Player replacement) {
  final club = career.userClub;
  return career.copyWith(
    clubs: career.clubs
        .map(
          (item) => item.id == club.id
              ? club.copyWith(
                  squad: club.squad
                      .map(
                        (player) =>
                            player.id == replacement.id ? replacement : player,
                      )
                      .toList(),
                )
              : item,
        )
        .toList(),
  );
}

CareerState _completeSeason(CareerState career) {
  final completedFixtures = career.fixtures
      .map(
        (fixture) => fixture.copyWith(
          played: true,
          score: const MatchScore(0, 0),
        ),
      )
      .toList();
  final standings = LeagueEngine.rebuildStandings(
    career.clubs,
    completedFixtures,
  );
  final lastUserFixture = completedFixtures
      .where(
        (fixture) =>
            fixture.homeClubId == career.userClubId ||
            fixture.awayClubId == career.userClubId,
      )
      .last;
  return career.copyWith(
    roundIndex: 38,
    currentDate: lastUserFixture.date,
    fixtures: completedFixtures,
    standings: standings,
  );
}
