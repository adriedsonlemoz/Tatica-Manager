import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('encerramento da partida tem estado único e controles úteis', () {
    final screen = File(
      'lib/features/match/match_screen.dart',
    ).readAsStringSync();
    final scoreboard = File(
      'lib/features/match/widgets/live_match_scoreboard.dart',
    ).readAsStringSync();
    final narration = File(
      'lib/features/match/widgets/live_match_narration_panel.dart',
    ).readAsStringSync();

    expect(scoreboard, contains('required this.fullTime'));
    expect(scoreboard, contains("? 'FIM DE JOGO'"));
    expect(scoreboard, contains('if (!fullTime) ...['));
    expect(screen, contains('final contentHeight = availableHeight'));
    expect(screen, contains('height: contentHeight'));
    expect(screen, contains('if (!fullTime) ...['));
    expect(screen, isNot(contains('enabled:')));
    expect(screen, contains('height: 82'));
    expect(narration, contains('final visibleLines = constraints.maxHeight'));
    expect(narration, contains('limit: visibleLines'));
  });

  test('etiquetas dos jogadores preservam distância visual', () {
    final labels = File(
      'lib/game/match/renderer/match_player_labels.dart',
    ).readAsStringSync();

    expect(labels, contains('rect.inflate((emphasized ? 2.4 : 4.0)'));
    expect(labels, contains('if (collisions.isEmpty) return'));
  });

  test('disciplina usa duas colunas legíveis em vez de quatro métricas', () {
    final profile = File(
      'lib/features/player/player_profile_screen.dart',
    ).readAsStringSync();

    expect(profile, contains('final itemWidth = (constraints.maxWidth - spacing) / 2'));
    expect(profile, contains('return Wrap('));
    expect(profile, contains('class _DisciplineMetric'));
    expect(profile, contains('constraints: const BoxConstraints(minHeight: 62)'));
  });

  test('prioridades e menu Mais não reservam altura desnecessária', () {
    final assistant = File(
      'lib/features/assistant/technical_assistant_screen.dart',
    ).readAsStringSync();
    final more = File(
      'lib/features/more/more_screen.dart',
    ).readAsStringSync();
    final priorityStart = assistant.indexOf('class _PrioritiesCard');
    final priorityEnd = assistant.indexOf('class _IconBox');
    final prioritySection = assistant.substring(priorityStart, priorityEnd);

    expect(assistant, contains('const Spacer()'));
    expect(prioritySection, contains('for (final priority in priorities)'));
    expect(prioritySection, isNot(contains('child: Column(\n                children')));
    expect(more, contains('dense: true'));
    expect(more, contains('visualDensity: VisualDensity.compact'));
    expect(more, contains('minTileHeight: 52'));
    expect(more, contains('width: 36, height: 36'));
    expect(more, contains('EdgeInsets.fromLTRB(14, 12, 14, 20)'));
  });
}
