import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/data/club_seed.dart';
import 'package:tatica_manager/domain/career/manager_profile.dart';
import 'package:tatica_manager/domain/formation/formation.dart';
import 'package:tatica_manager/domain/match/match_models.dart';
import 'package:tatica_manager/domain/tactic/tactic.dart';
import 'package:tatica_manager/game/career/career_factory.dart';
import 'package:tatica_manager/game/lineup/lineup_engine.dart';
import 'package:tatica_manager/game/match/engine/match_discipline_engine.dart';
import 'package:tatica_manager/game/match/engine/match_engine.dart';
import 'package:tatica_manager/game/match/engine/match_event_generator.dart';
import 'package:tatica_manager/game/match/engine/match_statistics_calculator.dart';
import 'package:tatica_manager/game/match/engine/match_strength_calculator.dart';

void main() {
  test('segundo amarelo gera vermelho e remove atleta da partida', () {
    final career = CareerFactory.create(
      careerId: 'second-yellow-test',
      careerName: 'Segundo amarelo',
      manager: const ManagerProfile(displayName: 'Teste'),
      userClubId: clubSeeds.first.id,
      seed: 20260825,
    );
    final fixture = career.fixtures.first;
    final home = career.clubs.firstWhere(
      (club) => club.id == fixture.homeClubId,
    );
    final away = career.clubs.firstWhere(
      (club) => club.id == fixture.awayClubId,
    );
    final homeIds = LineupEngine.autoSelect(home.squad, FormationType.f433);
    final awayIds = LineupEngine.autoSelect(away.squad, FormationType.f433);
    final homeAssignments = LineupEngine.assign(
      home.squad,
      homeIds,
      FormationType.f433,
    );
    final awayAssignments = LineupEngine.assign(
      away.squad,
      awayIds,
      FormationType.f433,
    );
    final player = homeAssignments[4].player;
    final tracker = MatchDisciplineTracker.fromPrefix(const []);

    MatchEventBatch yellow(int minute, int sequence) => MatchEventBatch(
          events: [
            MatchEvent(
              minute: minute,
              sequence: sequence,
              type: MatchEventType.yellow,
              teamId: home.id,
              playerId: player.id,
              text: 'Cartão amarelo: ${player.displayName}.',
            ),
          ],
        );

    final first = tracker.applyBatch(
      batch: yellow(12, 0),
      home: home,
      away: away,
      homeAssignments: homeAssignments,
      awayAssignments: awayAssignments,
    );
    expect(first.events.where((event) => event.type == MatchEventType.red), isEmpty);
    expect(tracker.yellowCardsFor(player.id), 1);
    expect(tracker.isDismissed(player.id), isFalse);

    final second = tracker.applyBatch(
      batch: yellow(70, 1),
      home: home,
      away: away,
      homeAssignments: homeAssignments,
      awayAssignments: awayAssignments,
    );
    final red = second.events.singleWhere(
      (event) => event.type == MatchEventType.red,
    );

    expect(tracker.yellowCardsFor(player.id), 2);
    expect(tracker.isDismissed(player.id), isTrue);
    expect(second.homeReds, 1);
    expect(red.playerId, player.id);
    expect(red.cardReason, MatchCardReason.secondYellow);
    expect(red.start, isNotNull);
    expect(red.text, contains('Segundo cartão amarelo'));
    expect(
      tracker.activeAssignments(homeAssignments).map((item) => item.player.id),
      isNot(contains(player.id)),
    );

    final restored = MatchEvent.fromJson(red.toJson());
    expect(restored.cardReason, MatchCardReason.secondYellow);
  });

  test('atleta expulso não participa de eventos posteriores do Match Engine', () {
    final career = CareerFactory.create(
      careerId: 'dismissed-no-return-test',
      careerName: 'Expulsão persistente',
      manager: const ManagerProfile(displayName: 'Teste'),
      userClubId: clubSeeds.first.id,
      seed: 20260826,
    );
    final fixture = career.fixtures.first;
    final home = career.clubs.firstWhere(
      (club) => club.id == fixture.homeClubId,
    );
    final away = career.clubs.firstWhere(
      (club) => club.id == fixture.awayClubId,
    );
    final homeIds = LineupEngine.autoSelect(home.squad, FormationType.f433);
    final dismissedId = homeIds[4];
    final prefix = [
      MatchEvent(
        minute: 12,
        sequence: 0,
        type: MatchEventType.yellow,
        teamId: home.id,
        playerId: dismissedId,
        text: 'Primeiro amarelo.',
      ),
      MatchEvent(
        minute: 20,
        sequence: 1,
        type: MatchEventType.yellow,
        teamId: home.id,
        playerId: dismissedId,
        text: 'Segundo amarelo.',
      ),
      MatchEvent(
        minute: 20,
        sequence: 2,
        type: MatchEventType.red,
        teamId: home.id,
        playerId: dismissedId,
        cardReason: MatchCardReason.secondYellow,
        text: 'Expulso por segundo amarelo.',
      ),
    ];

    final result = MatchEngine.simulate(
      fixture: fixture,
      home: home,
      away: away,
      homeStarterIds: homeIds,
      seed: 20260826,
      startMinute: 21,
      prefixEvents: prefix,
    );

    final future = result.events.where((event) => event.minute > 20);
    for (final event in future) {
      expect(event.playerId, isNot(dismissedId), reason: event.text);
      expect(event.assistPlayerId, isNot(dismissedId), reason: event.text);
      expect(event.secondaryPlayerId, isNot(dismissedId), reason: event.text);
    }
  });

  test('segundo amarelo conta dois cartões, um vermelho e duas faltas', () {
    final career = CareerFactory.create(
      careerId: 'discipline-stats-test',
      careerName: 'Estatísticas disciplinares',
      manager: const ManagerProfile(displayName: 'Teste'),
      userClubId: clubSeeds.first.id,
      seed: 20260827,
    );
    final home = career.clubs[0];
    final away = career.clubs[1];
    final playerId = home.squad.first.id;
    final events = [
      MatchEvent(
        minute: 12,
        sequence: 0,
        type: MatchEventType.foul,
        teamId: home.id,
        playerId: playerId,
        text: 'Falta.',
      ),
      MatchEvent(
        minute: 12,
        sequence: 1,
        type: MatchEventType.yellow,
        teamId: home.id,
        playerId: playerId,
        text: 'Primeiro amarelo.',
      ),
      MatchEvent(
        minute: 70,
        sequence: 2,
        type: MatchEventType.foul,
        teamId: home.id,
        playerId: playerId,
        text: 'Falta.',
      ),
      MatchEvent(
        minute: 70,
        sequence: 3,
        type: MatchEventType.yellow,
        teamId: home.id,
        playerId: playerId,
        text: 'Segundo amarelo.',
      ),
      MatchEvent(
        minute: 70,
        sequence: 4,
        type: MatchEventType.red,
        teamId: home.id,
        playerId: playerId,
        cardReason: MatchCardReason.secondYellow,
        text: 'Expulso.',
      ),
    ];
    const strength = TeamMatchStrength(
      attack: 70,
      midfield: 70,
      defense: 70,
      goalkeeper: 70,
    );

    final statistics = MatchStatisticsCalculator.calculate(
      events: events,
      home: home,
      away: away,
      homeStrength: strength,
      awayStrength: strength,
      homeTactic: const Tactic(),
      awayTactic: const Tactic(),
      homeAdvantage: 1.08,
      random: Random(7),
    );

    expect(statistics.homeFouls, 2);
    expect(statistics.homeYellow, 2);
    expect(statistics.homeRed, 1);
  });

  test('substituição ao vivo filtra jogadores já expulsos', () {
    final sheet = File(
      'lib/features/match/widgets/live_substitution_sheet.dart',
    ).readAsStringSync();
    final controller = File(
      'lib/app/state/live_match_controller.dart',
    ).readAsStringSync();

    expect(sheet, contains('dismissedPlayerIds'));
    expect(controller, contains('Jogador expulso não pode ser substituído.'));
  });
}
