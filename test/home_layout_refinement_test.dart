import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('home refinada mantém atalhos compactos e resumo em uma faixa', () {
    final home = File('lib/features/home/home_screen.dart').readAsStringSync();
    final header =
        File('lib/features/home/home_clean_header.dart').readAsStringSync();
    final content =
        File('lib/features/home/home_clean_content.dart').readAsStringSync();

    expect(header, contains('height: 50'));
    expect(header, contains('alignment: Alignment.centerRight'));
    expect(header, contains('width: 28'));
    expect(header, contains('height: 72'));
    expect(header, contains('FittedBox('));
    expect(header, contains('maxLines: 1'));
    expect(header, contains('softWrap: false'));

    expect(content, contains("title: 'RESUMO DA TEMPORADA'"));
    expect(content, contains('for (var i = 0; i < values.length; i++) ...['));
    expect(content, contains('Container(width: 1, height: 70'));
    expect(content, isNot(contains('constraints.maxWidth < 520')));
    expect(content, contains('ClubBadge(club: club, size: 58)'));
    expect(content, contains('const SizedBox(height: 11)'));
    expect(content, contains('const SizedBox(width: 12)'));

    expect(home, contains('HomeCleanSeasonSummary(standing: userStanding)'));
    expect(home, contains('const SizedBox(height: 12)'));
  });

  test('menu Mais aberto pela Home possui retorno explícito', () {
    final home = File('lib/features/home/home_screen.dart').readAsStringSync();
    final more = File('lib/features/more/more_screen.dart').readAsStringSync();

    expect(home, contains('const MoreScreen(showBackButton: true)'));
    expect(more, contains('this.showBackButton = false'));
    expect(more, contains('appBar: showBackButton'));
    expect(more, contains("tooltip: 'Voltar'"));
    expect(more, contains('Navigator.of(context).maybePop()'));
  });
}
