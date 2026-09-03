import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/domain/match/match_models.dart';
import 'package:tatica_manager/features/match/live_round_feed.dart';
import 'package:tatica_manager/features/match/live_match_playback.dart';
import 'package:tatica_manager/features/match/match_event_presentation.dart';
import 'package:tatica_manager/game/league/live_round_simulator.dart';

void main() {
  test('campo permanece fixo e replay não transforma o canvas', () {
    final renderer = File(
      'lib/game/match/renderer/match_pitch_game.dart',
    ).readAsStringSync();

    expect(renderer, isNot(contains('MatchCameraDirector')));
    expect(renderer, isNot(contains('_applyCamera(')));
    expect(renderer, isNot(contains('canvas.translate(')));
    expect(renderer, isNot(contains('canvas.scale(')));
  });

  test('feed revela gols dos outros jogos conforme o minuto', () {
    final match = PreparedRoundMatch(
      fixture: MatchFixture(
        id: 'round-1-other',
        round: 1,
        homeClubId: 'a',
        awayClubId: 'b',
        date: DateTime(2026, 4, 12),
      ),
      result: _result(),
      homeStarterIds: const [],
      awayStarterIds: const [],
    );

    expect(LiveRoundFeed.scoreUntil(match.result, 20).display, '0 - 0');
    expect(LiveRoundFeed.scoreUntil(match.result, 21).display, '1 - 0');
    final alerts = LiveRoundFeed.alertsAtMinute([match], 21);
    expect(alerts, hasLength(1));
    expect(alerts.single.score.display, '1 - 0');
  });

  test('narração filtra importantes e eventos do clube do usuário', () {
    final events = _result().events;
    final important = MatchEventPresentation.visible(
      events,
      90,
      filter: MatchNarrationFilter.important,
    );
    final mine = MatchEventPresentation.visible(
      events,
      90,
      filter: MatchNarrationFilter.userClub,
      userClubId: 'a',
    );

    expect(important.every((event) => MatchEventPresentation.isMajor(event.type)), isTrue);
    expect(mine.every((event) => event.teamId == 'a'), isTrue);
  });

  test('avanço de apresentação encontra o próximo lance sem recalcular', () {
    final target = LiveMatchPlayback.targetFor(
      option: LiveMatchSimulationOption.nextImportant,
      currentMinute: 8,
      events: _result().events,
    );
    expect(target, 21);
    expect(
      LiveMatchPlayback.targetFor(
        option: LiveMatchSimulationOption.tenMinutes,
        currentMinute: 84,
        events: _result().events,
      ),
      90,
    );
  });

  test('simulação de transmissão não cria Match Engine paralelo', () {
    final screen = File('lib/features/match/match_screen.dart').readAsStringSync();
    final renderer = File(
      'lib/game/match/renderer/match_pitch_game.dart',
    ).readAsStringSync();
    final round = File(
      'lib/game/league/live_round_simulator.dart',
    ).readAsStringSync();
    final resolver = File(
      'lib/game/league/cpu_fixture_resolver.dart',
    ).readAsStringSync();

    expect(screen, isNot(contains('MatchEngine.simulate')));
    expect(renderer, isNot(contains('MatchEngine')));
    expect(round, contains('CpuFixtureResolver.resolve'));
    expect(round, contains('fixture.competitionId == competitionId'));
    expect(round, contains('PreparedRoundMatch'));
    expect(resolver, contains('MatchEngine.simulate'));
    expect(resolver, isNot(contains('BackgroundFixtureResolver.resolve')));
    expect(resolver, contains('autoSubstituteHome: true'));
    expect(resolver, contains('autoSubstituteAway: true'));
    expect(resolver, isNot(contains('class MatchEngine')));
  });
}

MatchResult _result() => const MatchResult(
      fixtureId: 'round-1-other',
      homeClubId: 'a',
      awayClubId: 'b',
      score: MatchScore(1, 0),
      events: [
        MatchEvent(
          minute: 8,
          sequence: 1,
          type: MatchEventType.pass,
          teamId: 'a',
          text: 'Passe.',
        ),
        MatchEvent(
          minute: 21,
          sequence: 2,
          type: MatchEventType.goal,
          teamId: 'a',
          text: 'Gol.',
        ),
        MatchEvent(
          minute: 90,
          sequence: 3,
          type: MatchEventType.fulltime,
          teamId: '',
          text: 'Fim.',
        ),
      ],
      statistics: MatchStatistics(
        homePossession: 50,
        awayPossession: 50,
        homeShots: 1,
        awayShots: 0,
        homeShotsOnTarget: 1,
        awayShotsOnTarget: 0,
        homeCorners: 0,
        awayCorners: 0,
        homeFouls: 0,
        awayFouls: 0,
        homeYellow: 0,
        awayYellow: 0,
        homeRed: 0,
        awayRed: 0,
      ),
      seed: 1,
    );
