import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/domain/match/match_models.dart';
import 'package:tatica_manager/game/match/renderer/match_presentation_director.dart';

void main() {
  test('gol gera replay apenas a partir da timeline já calculada', () {
    const events = [
      MatchEvent(
        minute: 18,
        sequence: 10,
        type: MatchEventType.pass,
        teamId: 'home',
        text: 'Passe.',
        start: FieldPoint(.4, .6),
        end: FieldPoint(.5, .3),
      ),
      MatchEvent(
        minute: 18,
        sequence: 11,
        type: MatchEventType.shot,
        teamId: 'home',
        text: 'Chute.',
        start: FieldPoint(.5, .3),
        end: FieldPoint(.5, .03),
      ),
      MatchEvent(
        minute: 18,
        sequence: 12,
        type: MatchEventType.goal,
        teamId: 'home',
        text: 'Gol.',
        start: FieldPoint(.5, .3),
        end: FieldPoint(.5, .03),
      ),
    ];

    final cues = MatchPresentationDirector.buildCues(events);
    final replay = cues.where((cue) => cue.replay).toList();

    expect(cues.take(3).map((cue) => cue.event?.type), [
      MatchEventType.pass,
      MatchEventType.shot,
      MatchEventType.goal,
    ]);
    expect(replay.first.startsReplay, isTrue);
    expect(replay.last.endsReplay, isTrue);
    expect(
      replay.where((cue) => cue.event != null).map((cue) => cue.event!.type),
      [MatchEventType.pass, MatchEventType.shot, MatchEventType.goal],
    );
  });

  test('cartão não cria replay automático', () {
    const events = [
      MatchEvent(
        minute: 33,
        sequence: 20,
        type: MatchEventType.yellow,
        teamId: 'away',
        text: 'Cartão amarelo.',
      ),
    ];

    final cues = MatchPresentationDirector.buildCues(events);
    expect(cues, hasLength(1));
    expect(cues.single.replay, isFalse);
  });

  test('bola na trave e pênalti defendido recebem replay sem nova simulação', () {
    const woodwork = [
      MatchEvent(
        minute: 52,
        sequence: 30,
        type: MatchEventType.shot,
        teamId: 'home',
        text: 'Chute.',
        start: FieldPoint(.5, .3),
        end: FieldPoint(.42, .03),
      ),
      MatchEvent(
        minute: 52,
        sequence: 31,
        type: MatchEventType.woodwork,
        teamId: 'home',
        text: 'Na trave.',
        start: FieldPoint(.42, .03),
        end: FieldPoint(.45, .16),
      ),
    ];
    const penaltySaved = [
      MatchEvent(
        minute: 74,
        sequence: 40,
        type: MatchEventType.penalty,
        teamId: 'away',
        text: 'Pênalti.',
        start: FieldPoint(.5, .82),
        end: FieldPoint(.5, .96),
      ),
      MatchEvent(
        minute: 74,
        sequence: 41,
        type: MatchEventType.penaltySaved,
        teamId: 'home',
        text: 'Defendido.',
        start: FieldPoint(.5, .96),
        end: FieldPoint(.5, .96),
      ),
    ];

    final woodworkReplay = MatchPresentationDirector.buildCues(woodwork)
        .where((cue) => cue.replay && cue.event != null)
        .map((cue) => cue.event!.type)
        .toList();
    final penaltyReplay = MatchPresentationDirector.buildCues(penaltySaved)
        .where((cue) => cue.replay && cue.event != null)
        .map((cue) => cue.event!.type)
        .toList();

    expect(woodworkReplay, [MatchEventType.shot, MatchEventType.woodwork]);
    expect(penaltyReplay, [MatchEventType.penalty, MatchEventType.penaltySaved]);
  });
}
