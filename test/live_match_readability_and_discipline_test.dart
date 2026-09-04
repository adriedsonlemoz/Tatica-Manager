import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/domain/player/player.dart';

void main() {
  test('disciplina identifica suspensão e jogador pendurado', () {
    const clear = PlayerDiscipline();
    const atRisk = PlayerDiscipline(yellowCards: 2);
    const suspended = PlayerDiscipline(suspendedRounds: 1);

    expect(PlayerDiscipline.yellowCardSuspensionThreshold, 3);
    expect(clear.isAtRisk, isFalse);
    expect(atRisk.isAtRisk, isTrue);
    expect(suspended.isSuspended, isTrue);
    expect(suspended.isAtRisk, isFalse);
  });

  test('transmissão fixa prioriza o campo e reduz poluição visual', () {
    final screen = File(
      'lib/features/match/match_screen.dart',
    ).readAsStringSync();
    final renderer = File(
      'lib/game/match/renderer/match_pitch_game.dart',
    ).readAsStringSync();
    final timeline = File(
      'lib/features/match/widgets/live_match_timeline_bar.dart',
    ).readAsStringSync();

    expect(screen, contains('fit: BoxFit.scaleDown'));
    expect(screen, isNot(contains('child: ListView(')));
    expect(screen, contains('pitchGame.setPaused('));
    expect(renderer, contains('void setPaused(bool paused)'));
    expect(renderer, contains('_contextualLabelIds'));
    expect(renderer, contains('MatchPlayerMotion.resolveCrowding'));
    expect(renderer, contains('const idleOffset = Offset.zero'));
    expect(timeline, contains('_isTimelineEvent'));
  });

  test('cartões aparecem na escalação, elenco, perfil e transmissão', () {
    final lineup = File(
      'lib/features/lineup/lineup_screen.dart',
    ).readAsStringSync();
    final squad = File(
      'lib/features/squad/squad_screen.dart',
    ).readAsStringSync();
    final profile = File(
      'lib/features/player/player_profile_screen.dart',
    ).readAsStringSync();
    final stats = File(
      'lib/features/match/widgets/live_match_controls.dart',
    ).readAsStringSync();

    expect(lineup, contains('playerDisciplineForCompetition'));
    expect(lineup, contains('PlayerDisciplineIndicator'));
    expect(squad, contains("Text('CARTÕES'"));
    expect(squad, contains('PlayerDisciplineIndicator'));
    expect(profile, contains('DISCIPLINA •'));
    expect(profile, contains('Amarelos atuais'));
    expect(stats, contains('homeYellow'));
    expect(stats, contains('awayYellow'));
    expect(stats, contains('_TeamCards'));
  });
}
