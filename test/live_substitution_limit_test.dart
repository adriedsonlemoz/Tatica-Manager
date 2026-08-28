import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/domain/match/match_models.dart';
import 'package:tatica_manager/game/match/live_substitution_rules.dart';

MatchEvent _sub(int minute, int sequence) => MatchEvent(
      minute: minute,
      sequence: sequence,
      type: MatchEventType.substitution,
      teamId: 'user',
      playerId: 'in-$sequence',
      secondaryPlayerId: 'out-$sequence',
      text: 'Substituição',
    );

void main() {
  group('regras reais de substituição', () {
    test('limita a cinco jogadores substituídos', () {
      final events = [
        _sub(10, 1),
        _sub(10, 2),
        _sub(25, 3),
        _sub(45, 4),
        _sub(70, 5),
      ];

      expect(LiveSubstitutionRules.substitutionsUsed(events, 'user'), 5);
      expect(
        LiveSubstitutionRules.violationMessage(
          events: events,
          teamId: 'user',
          minute: 80,
        ),
        contains('Limite de 5 substituições'),
      );
    });

    test('várias trocas no mesmo minuto usam uma única janela', () {
      final events = [_sub(12, 1), _sub(12, 2), _sub(38, 3)];

      expect(LiveSubstitutionRules.substitutionWindowsUsed(events, 'user'), 2);
      expect(
        LiveSubstitutionRules.violationMessage(
          events: events,
          teamId: 'user',
          minute: 38,
        ),
        isNull,
      );
    });


    test('valida o total de um lote antes de aplicar qualquer troca', () {
      final events = [_sub(20, 1), _sub(20, 2), _sub(50, 3), _sub(70, 4)];

      expect(
        LiveSubstitutionRules.violationMessage(
          events: events,
          teamId: 'user',
          minute: 70,
          requestedSubstitutions: 2,
        ),
        contains('apenas 1 substituição'),
      );
      expect(
        LiveSubstitutionRules.violationMessage(
          events: events,
          teamId: 'user',
          minute: 70,
          requestedSubstitutions: 1,
        ),
        isNull,
      );
    });

    test('bloqueia a quarta janela, mas intervalo não consome janela', () {
      final events = [_sub(10, 1), _sub(30, 2), _sub(60, 3)];

      expect(LiveSubstitutionRules.substitutionWindowsUsed(events, 'user'), 3);
      expect(
        LiveSubstitutionRules.violationMessage(
          events: events,
          teamId: 'user',
          minute: 75,
        ),
        contains('3 janelas'),
      );
      expect(
        LiveSubstitutionRules.violationMessage(
          events: events,
          teamId: 'user',
          minute: LiveSubstitutionRules.halftimeMinute,
        ),
        isNull,
      );
    });
  });

  test('controller e tela usam a regra central em vez de limite só visual', () {
    final controller =
        File('lib/app/state/live_match_controller.dart').readAsStringSync();
    final screen =
        File('lib/features/match/match_screen.dart').readAsStringSync();
    final sheet = File(
      'lib/features/match/widgets/live_substitution_sheet.dart',
    ).readAsStringSync();

    expect(controller, contains('LiveSubstitutionRules.violationMessage'));
    expect(controller, contains('alreadySubstitutedOut.contains(incomingId)'));
    expect(controller, contains('Jogador substituído não pode retornar à partida.'));
    expect(screen, contains('LiveSubstitutionRules.substitutionWindowsUsed'));
    expect(screen, contains('substitutionWindowsUsed: substitutionWindowsUsed'));
    expect(sheet, contains(r'janelas: $projectedWindows/${widget.substitutionWindowLimit}'));
    expect(sheet, contains('willUseNewWindow'));
    expect(sheet, contains('intervalo não consome janela'));
  });
}
