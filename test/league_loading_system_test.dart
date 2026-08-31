import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/data/competition_catalog.dart';
import 'package:tatica_manager/domain/career/manager_profile.dart';
import 'package:tatica_manager/domain/season/career_state.dart';
import 'package:tatica_manager/domain/season/league_loading.dart';
import 'package:tatica_manager/game/career/career_factory.dart';
import 'package:tatica_manager/game/career/career_league_planner.dart';
import 'package:tatica_manager/game/league/background_fixture_resolver.dart';

void main() {
  const userClubId = 'br-club-001';

  test('presets usam somente competições reais e forçam liga do jogador completa', () {
    final knownIds = CompetitionCatalog.allSeries.map((series) => series.id).toSet();

    for (final preset in CareerWorldPreset.values) {
      final setup = CareerLeaguePlanner.forPreset(
        userClubId: userClubId,
        preset: preset,
      );
      expect(setup.competitions.keys.toSet(), knownIds);
      expect(setup.levelFor('br-series-a'), LeagueLoadLevel.full);
    }
  });

  test('personalizado não consegue descarregar a liga do clube escolhido', () {
    final normalized = CareerLeaguePlanner.normalize(
      setup: const CareerLeagueSetup(
        preset: CareerWorldPreset.custom,
        competitions: {'br-series-a': LeagueLoadLevel.unloaded},
      ),
      userClubId: userClubId,
    );

    expect(normalized.levelFor('br-series-a'), LeagueLoadLevel.full);
  });

  test('nova carreira persiste configuração sem criar clubes ou ligas fictícias', () {
    final career = _career();
    final realClubIds = CompetitionCatalog.primarySeriesForClub(userClubId).clubIds.toSet();

    expect(career.schemaVersion, CareerState.currentSchemaVersion);
    expect(career.leagueSetup.levelFor('br-series-a'), LeagueLoadLevel.full);
    expect(career.clubs.map((club) => club.id).toSet(), realClubIds);
    expect(career.fixtures, isNotEmpty);
    expect(career.fixtures.every((fixture) => fixture.competitionId == 'br-series-a'), isTrue);
    expect(career.totalUserRounds, 38);
  });

  test('save schema 11 sem leagueSetup migra mantendo ids e competição existente', () {
    final original = _career();
    final legacyJson = original.toJson()
      ..remove('leagueSetup')
      ..['schemaVersion'] = 11;

    final restored = CareerState.fromJson(legacyJson);

    expect(restored.schemaVersion, CareerState.currentSchemaVersion);
    expect(restored.careerId, original.careerId);
    expect(restored.userClubId, original.userClubId);
    expect(restored.clubs.map((club) => club.id).toList(),
        original.clubs.map((club) => club.id).toList());
    expect(restored.leagueSetup.levelFor('br-series-a'), LeagueLoadLevel.full);
  });

  test('resolver de segundo plano é determinístico e não produz timeline visual', () {
    final career = _career();
    final fixture = career.fixtures.first;
    final home = career.clubs.firstWhere((club) => club.id == fixture.homeClubId);
    final away = career.clubs.firstWhere((club) => club.id == fixture.awayClubId);

    final first = BackgroundFixtureResolver.resolve(
      fixture: fixture,
      home: home,
      away: away,
    );
    final second = BackgroundFixtureResolver.resolve(
      fixture: fixture,
      home: home,
      away: away,
    );

    expect(first.score.home, second.score.home);
    expect(first.score.away, second.score.away);
    expect(first.events, isEmpty);
    expect(first.statistics.homePossession + first.statistics.awayPossession, 100);
  });

  test('fluxo de criação reutiliza pacote de clubes já carregado', () {
    final flow = File('lib/features/career/new_career_flow_screen.dart')
        .readAsStringSync();
    final controller =
        File('lib/app/state/career_controller.dart').readAsStringSync();

    expect(flow, contains('clubIdentityPack: _clubIdentityPack'));
    expect(controller, contains('config.clubIdentityPack ?? await loadClubIdentityPack()'));
    expect(controller, contains('clubIdentityPackIsValidated: true'));
  });

  test('listagem de saves usa resumo SQL sem selecionar payload completo', () {
    final repository =
        File('lib/core/database/sqlite_career_repository.dart').readAsStringSync();
    final listMethod = repository.substring(
      repository.indexOf('Future<List<CareerSaveSummary>> listSaves'),
      repository.indexOf('static Map<String, Object?> _summaryValues'),
    );

    expect(repository, contains('version: 3'));
    expect(repository, contains('_migrateV2ToV3'));
    expect(listMethod, contains('columns: const ['));
    expect(listMethod, isNot(contains("'payload'")));
  });

  test('interface oferece presets e indicador qualitativo sem números técnicos', () {
    final source = File('lib/features/career/league_selection_step.dart')
        .readAsStringSync();

    expect(source, contains("CareerWorldPreset.fast => 'Rápido'"));
    expect(source, contains("CareerWorldPreset.balanced => 'Equilibrado'"));
    expect(source, contains("CareerWorldPreset.broad => 'Mundo amplo'"));
    expect(source, contains("CareerWorldPreset.custom => 'Personalizado'"));
    expect(source, contains("'Desempenho estimado'"));
    expect(source, isNot(contains('RAM')));
    expect(source, isNot(contains('thread')));
  });
}

CareerState _career() => CareerFactory.create(
      careerId: 'career-league-loading',
      careerName: 'Teste de ligas',
      manager: const ManagerProfile(displayName: 'Técnico Teste'),
      userClubId: 'br-club-001',
      leagueSetup: CareerLeaguePlanner.forPreset(
        userClubId: 'br-club-001',
        preset: CareerWorldPreset.fast,
      ),
    );
