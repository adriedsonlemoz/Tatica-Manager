import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/domain/season/career_event.dart';

void main() {
  test('avisos globais priorizam recompensas acima do Navigator', () {
    final app = File('lib/app/tatica_manager_app.dart').readAsStringSync();
    final host =
        File('lib/app/widgets/global_notice_host.dart').readAsStringSync();
    final shell = File('lib/features/home/game_shell.dart').readAsStringSync();

    expect(app, contains('GlobalNoticeHost('));
    expect(host, contains('Positioned(\n          top: 0'));
    expect(host, contains('const Offset(0, -1.15)'));
    expect(host, contains('notice.reward && _current?.reward != true'));
    expect(host, contains('Recompensas sempre interrompem avisos comuns'));
    expect(shell, isNot(contains('_IntegratedMessageCard')));
  });

  test('tipografia central possui hierarquia e não mantém texto estático abaixo de 10', () {
    final theme = File('lib/core/theme/app_theme.dart').readAsStringSync();
    expect(theme, contains('displayLarge: TextStyle(fontSize: 38'));
    expect(theme, contains('titleMedium: TextStyle(fontSize: 16'));
    expect(theme, contains('bodySmall: TextStyle(fontSize: 11'));

    final tooSmall = RegExp(r'fontSize:\s*([5-9](?:\.[0-9]+)?)\b');
    final offenders = <String>[];
    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      if (tooSmall.hasMatch(entity.readAsStringSync())) offenders.add(entity.path);
    }
    expect(offenders, isEmpty, reason: 'Fontes estáticas abaixo de 10: $offenders');
  });

  test('avanço do dia impede repetição e mantém transição visível', () {
    final home = File('lib/features/home/home_screen.dart').readAsStringSync();
    final controls = File('lib/features/home/home_dashboard_controls.dart')
        .readAsStringSync();
    final app = File('lib/app/tatica_manager_app.dart').readAsStringSync();

    expect(home, contains('_dayAdvanceBusyProvider'));
    expect(home, contains('Duration(milliseconds: 1500)'));
    expect(home, contains('minimumVisibleDuration - elapsed'));
    expect(controls, contains('onTap: enabled ?'));
    expect(app, isNot(contains('AudioNavigationObserver')));
  });

  test('dia de jogo usa composição fixa e responsiva sem rolagem', () {
    final screen = File('lib/features/home/match_day_presentation_screen.dart')
        .readAsStringSync();
    final components = File(
      'lib/features/home/match_day_presentation_components.dart',
    ).readAsStringSync();

    expect(screen, contains('body: LayoutBuilder('));
    expect(screen, contains('final compact = constraints.maxHeight < 940'));
    expect(screen, contains('Expanded('));
    expect(screen, isNot(contains('body: ListView')));
    expect(components, contains('NeverScrollableScrollPhysics'));
  });

  test('notícia persiste leitura sem transformar saves antigos em pendências', () {
    final event = CareerEvent(
      id: 'news-1',
      date: DateTime(2026, 9, 6),
      type: CareerEventType.info,
      title: 'Notícia',
      message: 'Conteúdo',
    );
    expect(event.read, isFalse);
    expect(CareerEvent.fromJson(event.toJson()).read, isFalse);

    final legacy = Map<String, dynamic>.from(event.toJson())..remove('read');
    expect(CareerEvent.fromJson(legacy).read, isTrue);
    expect(event.copyWith(read: true).read, isTrue);

    final screen = File('lib/features/home/news_highlights_screen.dart')
        .readAsStringSync();
    final controller =
        File('lib/app/state/game_controller.dart').readAsStringSync();
    expect(screen, contains("'NOVA'"));
    expect(screen, contains('markNewsRead(event.id)'));
    expect(controller, contains('Future<void> markNewsRead(String eventId)'));
  });
}
