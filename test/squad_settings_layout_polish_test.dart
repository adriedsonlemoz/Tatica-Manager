import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('menu Mais não reserva espaço excessivo após Configurações', () {
    final source =
        File('lib/features/more/more_screen.dart').readAsStringSync();

    expect(source, contains("label: 'Configurações'"));
    expect(source, contains('EdgeInsets.fromLTRB(14, 12, 14, 20)'));
    expect(source, isNot(contains('EdgeInsets.fromLTRB(14, 12, 14, 96)')));
    expect(source, contains('dense: true'));
    expect(source, contains('minTileHeight: 52'));
  });

  test('elenco agrupa posições e mantém os controles existentes', () {
    final source =
        File('lib/features/squad/squad_screen.dart').readAsStringSync();

    for (final group in [
      "goalkeepers('Goleiros')",
      "defenders('Defensores')",
      "midfielders('Meio-campistas')",
      "attackers('Atacantes')",
    ]) {
      expect(source, contains(group));
    }

    expect(source, contains('group.includes(player.primaryPosition)'));
    expect(source, contains('PopupMenuButton<_SquadFilter>'));
    expect(source, contains("hintText: 'Buscar jogador, posição ou país'"));
    expect(source, contains('PlayerProfileScreen(playerId: player.id)'));
    expect(source, isNot(contains('TabBar(')));
  });

  test('linha compacta mostra idade real e destaca indisponibilidades', () {
    final source =
        File('lib/features/squad/squad_screen.dart').readAsStringSync();

    expect(source, contains("'\${player.age} anos • \${status.label}'"));
    expect(source, contains("label: 'Lesionado'"));
    expect(source, contains("label: 'Suspenso'"));
    expect(source, contains("label: 'Condição baixa'"));
    expect(source, contains('status.color.withValues(alpha: .08)'));
    expect(source, contains('BorderSide(color: status.color.withValues(alpha: .62))'));
    expect(source, contains('player.primaryPosition.label'));
    expect(source, contains("child: Center(child: Text('GER'"));
    expect(source, contains("child: Center(child: Text('CARTÕES'"));
    expect(source, isNot(contains('_positionName(')));

    final rowStart = source.indexOf('class _SquadPlayerRow');
    final rowEnd = source.indexOf('class _PlayerRowStatus');
    final row = source.substring(rowStart, rowEnd);
    expect(row, contains('size: 38'));
    expect(row, contains('EdgeInsets.fromLTRB(8, 8, 8, 8)'));
  });

  test('resumo do clube fica menor sem perder seus dados', () {
    final source =
        File('lib/features/squad/squad_screen.dart').readAsStringSync();

    expect(source, contains('ClubBadge(club: club, size: 56)'));
    expect(source, contains("'Temporada \$season'"));
    expect(source, contains("'Reputação \$reputation'"));
    expect(source, contains('compactMoney(balance)'));
    expect(source, contains('compactMoney(transferBudget)'));
  });
}
