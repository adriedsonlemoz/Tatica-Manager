import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/data/club_seed.dart';
import 'package:tatica_manager/data/competition_catalog.dart';
import 'package:tatica_manager/domain/career/manager_profile.dart';
import 'package:tatica_manager/domain/match/match_models.dart';
import 'package:tatica_manager/domain/player/player.dart';
import 'package:tatica_manager/domain/season/career_state.dart';
import 'package:tatica_manager/domain/season/competition_state.dart';
import 'package:tatica_manager/game/career/career_factory.dart';
import 'package:tatica_manager/game/competition/competition_calendar_engine.dart';
import 'package:tatica_manager/game/competition/competition_state_engine.dart';
import 'package:tatica_manager/game/league/league_engine.dart';
import 'package:tatica_manager/game/lineup/lineup_engine.dart';

void main() {
  test('schema 12 migra para estado por competição preservando ids persistidos', () {
    final current = _career();
    final fixtureIds = current.fixtures.map((fixture) => fixture.id).toList();
    final clubIds = current.clubs.map((club) => club.id).toList();
    final legacy = current.toJson()
      ..['schemaVersion'] = 12
      ..remove('primaryCompetitionId')
      ..remove('competitionStates');

    final restored = CareerState.fromJson(legacy);

    expect(restored.schemaVersion, CareerState.currentSchemaVersion);
    expect(restored.primaryCompetitionId, 'br-series-a');
    expect(restored.fixtures.map((fixture) => fixture.id).toList(), fixtureIds);
    expect(restored.clubs.map((club) => club.id).toList(), clubIds);
    expect(restored.competitionStates, hasLength(1));
    expect(restored.competitionStates.single.competitionId, 'br-series-a');
    expect(restored.standings, restored.competitionStates.single.standings);
    expect(restored.competitionStates.single.stages, isNotEmpty);
    expect(restored.competitionStates.single.stages.single.id, 'main');
  });

  test('catálogo internacional fica separado sem criar torneios fictícios', () {
    expect(CompetitionCatalog.internationalCompetitions, isEmpty);
    expect(
      CompetitionCatalog.allCompetitions,
      containsAll(CompetitionCatalog.allSeries),
    );
  });

  test('troca da competição principal sincroniza espelho legado sem reconstruir save', () {
    final career = _career();
    final secondaryStandings = career.standings.reversed.toList(growable: false);
    final secondary = CompetitionSeasonState(
      competitionId: 'competition-secondary',
      participantClubIds: career.primaryCompetitionClubIds.toList(),
      roundIndex: 7,
      standings: secondaryStandings,
    );
    final withSecondary = career.copyWith(
      competitionStates: [...career.competitionStates, secondary],
    );

    final switched = withSecondary.copyWith(
      primaryCompetitionId: 'competition-secondary',
    );

    expect(switched.primaryCompetitionId, 'competition-secondary');
    expect(switched.roundIndex, 7);
    expect(switched.standings.first.clubId, secondaryStandings.first.clubId);
  });

  test('ids históricos da Série A permanecem e novas competições não colidem', () {
    final clubs = clubSeeds.take(2).map((seed) => seed.toClub()).toList();
    final seriesA = LeagueEngine.generateDoubleRoundRobin(
      clubs,
      season: 2026,
      competitionId: 'br-series-a',
    );
    final anotherCompetition = LeagueEngine.generateDoubleRoundRobin(
      clubs,
      season: 2026,
      competitionId: 'competition-secondary',
    );

    expect(seriesA.first.id, '2026-r1-m1');
    expect(anotherCompetition.first.id, 'competition-secondary-2026-r1-m1');
    expect(
      seriesA.map((fixture) => fixture.id).toSet().intersection(
            anotherCompetition.map((fixture) => fixture.id).toSet(),
          ),
      isEmpty,
    );
  });

  test('calendário global desloca conflito do mesmo clube sem alterar ids', () {
    final fixtures = [
      MatchFixture(
        id: 'competition-a-match',
        round: 1,
        homeClubId: 'club-a',
        awayClubId: 'club-b',
        date: DateTime(2026, 4, 12),
        competitionId: 'competition-a',
      ),
      MatchFixture(
        id: 'competition-b-match',
        round: 1,
        homeClubId: 'club-a',
        awayClubId: 'club-c',
        date: DateTime(2026, 4, 12),
        competitionId: 'competition-b',
      ),
    ];

    final resolved = CompetitionCalendarEngine.resolveClubConflicts(fixtures);
    final first = resolved.firstWhere((fixture) => fixture.id == 'competition-a-match');
    final second = resolved.firstWhere((fixture) => fixture.id == 'competition-b-match');

    expect(resolved.map((fixture) => fixture.id).toSet(), {
      'competition-a-match',
      'competition-b-match',
    });
    expect(
      second.date.difference(first.date).inDays.abs(),
      greaterThanOrEqualTo(CompetitionCalendarEngine.minimumCompleteRestDays + 1),
    );
  });

  test('classificações de duas competições com os mesmos clubes são independentes', () {
    final clubs = clubSeeds.take(2).map((seed) => seed.toClub()).toList();
    final ids = clubs.map((club) => club.id).toList(growable: false);
    final states = [
      CompetitionSeasonState(
        competitionId: 'competition-a',
        participantClubIds: ids,
        standings: LeagueEngine.initialStandings(clubs),
      ),
      CompetitionSeasonState(
        competitionId: 'competition-b',
        participantClubIds: ids,
        standings: LeagueEngine.initialStandings(clubs),
      ),
    ];
    final fixtures = [
      MatchFixture(
        id: 'a-1',
        round: 1,
        homeClubId: ids[0],
        awayClubId: ids[1],
        date: DateTime(2026, 4, 12),
        competitionId: 'competition-a',
        played: true,
        score: const MatchScore(2, 0),
      ),
      MatchFixture(
        id: 'b-1',
        round: 1,
        homeClubId: ids[0],
        awayClubId: ids[1],
        date: DateTime(2026, 4, 16),
        competitionId: 'competition-b',
        played: true,
        score: const MatchScore(0, 3),
      ),
    ];

    final rebuilt = CompetitionStateEngine.rebuildAll(
      states: states,
      clubs: clubs,
      fixtures: fixtures,
    );
    final a = rebuilt.firstWhere((state) => state.competitionId == 'competition-a');
    final b = rebuilt.firstWhere((state) => state.competitionId == 'competition-b');

    expect(a.standings.first.clubId, ids[0]);
    expect(a.standings.first.points, 3);
    expect(b.standings.first.clubId, ids[1]);
    expect(b.standings.first.points, 3);
    expect(a.roundIndex, 1);
    expect(b.roundIndex, 1);
  });

  test('estatísticas e suspensões permanecem isoladas por competição', () {
    final career = _career();
    final playerId = career.starterIds.first;
    final first = CompetitionSeasonState(
      competitionId: 'competition-a',
      participantClubIds: [career.userClubId],
      playerStats: {
        playerId: const PlayerSeasonStats(goals: 4, assists: 2),
      },
      playerDiscipline: {
        playerId: const PlayerDiscipline(suspendedRounds: 1),
      },
    );
    final second = CompetitionSeasonState(
      competitionId: 'competition-b',
      participantClubIds: [career.userClubId],
      playerStats: {
        playerId: const PlayerSeasonStats(goals: 1),
      },
    );

    expect(first.statsForPlayer(playerId).goals, 4);
    expect(second.statsForPlayer(playerId).goals, 1);
    expect(first.suspendedPlayerIds, contains(playerId));
    expect(second.suspendedPlayerIds, isNot(contains(playerId)));

    final suspendedValidation = LineupEngine.validate(
      career.userClub.squad,
      career.starterIds,
      career.formation,
      competitionSuspendedPlayerIds: {playerId},
    );
    final otherCompetitionValidation = LineupEngine.validate(
      career.userClub.squad,
      career.starterIds,
      career.formation,
      competitionSuspendedPlayerIds: const {},
    );
    expect(suspendedValidation.valid, isFalse);
    expect(otherCompetitionValidation.valid, isTrue);

    final restored = CompetitionSeasonState.fromJson(first.toJson());
    expect(restored.statsForPlayer(playerId).goals, 4);
    expect(restored.disciplineForPlayer(playerId).suspendedRounds, 1);
  });

  test('fixture preserva fase grupo confronto e perna no save', () {
    final fixture = MatchFixture(
      id: 'fixture-stage-test',
      round: 2,
      homeClubId: 'club-a',
      awayClubId: 'club-b',
      date: DateTime(2026, 8, 20),
      competitionId: 'competition-cup',
      stageId: 'semifinal',
      groupId: 'group-a',
      tieId: 'tie-01',
      leg: 2,
    );

    final restored = MatchFixture.fromJson(fixture.toJson());

    expect(restored.id, fixture.id);
    expect(restored.stageId, 'semifinal');
    expect(restored.groupId, 'group-a');
    expect(restored.tieId, 'tie-01');
    expect(restored.leg, 2);
  });

  test('fixture legado sem metadados de fase continua compatível', () {
    final restored = MatchFixture.fromJson({
      'id': 'legacy-fixture',
      'round': 1,
      'homeClubId': 'club-a',
      'awayClubId': 'club-b',
      'date': DateTime(2026, 4, 12).toIso8601String(),
      'competitionId': 'br-series-a',
    });

    expect(restored.stageId, 'main');
    expect(restored.groupId, isNull);
    expect(restored.tieId, isNull);
    expect(restored.leg, 1);
  });
}

CareerState _career() => CareerFactory.create(
      careerId: 'career-multi-competition-foundation',
      careerName: 'Fundação multi-competição',
      manager: const ManagerProfile(displayName: 'Técnico Teste'),
      userClubId: 'br-club-001',
    );
