import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('configurações exibem as quatro bolas diretamente na tela', () {
    final settings = [
      File('lib/features/settings/settings_screen.dart').readAsStringSync(),
      File('lib/features/settings/pre_career_settings_screen.dart').readAsStringSync(),
    ].join('\n');
    final picker = File('lib/features/settings/match_ball_picker.dart').readAsStringSync();
    final styles = File('lib/core/theme/match_ball_styles.dart').readAsStringSync();

    expect(RegExp(r'MatchBallPicker\(').allMatches(settings), hasLength(2));
    expect(settings, isNot(contains('DropdownButtonFormField<int>')));
    expect(picker, contains('drawMatchBallGraphic'));
    expect(styles, contains("label: 'Clássica'"));
    expect(styles, contains("label: 'Branca e verde'"));
    expect(styles, contains("label: 'Amarela'"));
    expect(styles, contains("label: 'Retrô'"));
  });

  test('a mesma escolha visual é encaminhada ao campo da partida', () {
    final match = File('lib/features/match/match_screen.dart').readAsStringSync();
    final pitch = File('lib/game/match/renderer/match_pitch_visuals.dart').readAsStringSync();

    expect(match, contains('ballStyle: career.settings.matchBallStyle'));
    expect(pitch, contains('drawMatchBallGraphic('));
    expect(pitch, contains('style: style'));
  });
}
