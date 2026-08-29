import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('modo claro é padrão e modo escuro é persistido fora do save', () {
    final app = File('lib/app/tatica_manager_app.dart').readAsStringSync();
    final controller = File(
      'lib/app/state/app_appearance_controller.dart',
    ).readAsStringSync();
    final preferences =
        File('lib/core/config/app_preferences.dart').readAsStringSync();
    final settings =
        File('lib/features/settings/settings_screen.dart').readAsStringSync();
    final preCareer = File(
      'lib/features/settings/pre_career_settings_screen.dart',
    ).readAsStringSync();

    expect(app, contains('theme: AppTheme.light'));
    expect(app, contains('darkTheme: AppTheme.dark'));
    expect(app, contains('themeMode: themeMode'));
    expect(app, contains('AppColors.useDarkMode'));

    expect(controller, contains('return ThemeMode.light'));
    expect(controller, contains("raw == 'dark' ? ThemeMode.dark : ThemeMode.light"));
    expect(controller, contains('saveAppValue'));
    expect(preferences, contains("themeModeKey = 'ui_theme_mode'"));

    expect(settings, contains("title: const Text('Modo escuro'"));
    expect(settings, contains('appAppearanceProvider.notifier'));
    expect(preCareer, contains("title: const Text('Modo escuro'"));
    expect(preCareer, contains('appAppearanceProvider.notifier'));
  });

  test('paleta neutra troca branco e grafite sem criar um segundo tema paralelo', () {
    final colors = File('lib/core/theme/app_colors.dart').readAsStringSync();
    final theme = File('lib/core/theme/app_theme.dart').readAsStringSync();

    expect(colors, contains('static bool _darkMode = false'));
    expect(colors, contains('static void useDarkMode(bool enabled)'));
    expect(colors, contains('0xFFF3F7F6'));
    expect(colors, contains('0xFFFFFFFF'));
    expect(colors, contains('0xFF101820'));
    expect(colors, contains('0xFF162229'));
    expect(theme, contains('Brightness.light'));
    expect(theme, contains('Brightness.dark'));
    expect(colors, contains('panelGradient'));
    expect(colors, contains('broadcastGradient'));

    final match = File('lib/features/match/match_screen.dart').readAsStringSync();
    final preMatch =
        File('lib/features/match/pre_match_screen.dart').readAsStringSync();
    final scoreboard = File(
      'lib/features/match/widgets/live_match_scoreboard.dart',
    ).readAsStringSync();
    final controls = File(
      'lib/features/match/widgets/live_match_controls.dart',
    ).readAsStringSync();

    expect(match, contains('AppColors.broadcastGradient'));
    expect(preMatch, contains('AppColors.broadcastGradient'));
    expect(scoreboard, contains('AppColors.panelGradient'));
    expect(controls, contains('AppColors.panelGradient'));
  });
}
