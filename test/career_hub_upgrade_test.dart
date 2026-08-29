import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('hub lista saves como cards ricos sem ação de editar carreira', () {
    final hub = File('lib/features/career/career_hub_screen.dart').readAsStringSync();
    final cards = File('lib/features/career/career_hub_save_cards.dart').readAsStringSync();
    final repository = File('lib/core/database/sqlite_career_repository.dart').readAsStringSync();

    expect(hub, contains('CareerSaveCard('));
    expect(hub, isNot(contains('Continuar')));
    expect(hub, isNot(contains('PopupMenuButton')));
    expect(cards, contains('ClubBadge('));
    expect(cards, contains('leaguePosition'));
    expect(cards, contains('nextOpponentName'));
    expect(cards, contains('Icons.delete_outline_rounded'));
    expect(cards, contains('Excluir esta carreira?'));
    expect(cards, contains('não pode ser desfeita'));
    expect(repository, contains('CareerState.fromJson'));
    expect(repository, contains('nextUserFixture'));
    expect(repository, contains('LeagueEngine.rebuildStandings'));
  });

  test('marca usa logo arredondada, subtítulo de save e diagnóstico pela versão', () {
    final hub = File('lib/features/career/career_hub_screen.dart').readAsStringSync();

    expect(hub, contains('ClipRRect('));
    expect(hub, contains("Text('Carregar jogo salvo'"));
    expect(hub, contains('Tática Manager Beta 2.0'));
    expect(hub, contains('AppInfo.version'));
    expect(hub, contains('DiagnosticScreen'));
  });
}
