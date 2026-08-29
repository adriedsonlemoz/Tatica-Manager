import 'dart:convert';

import '../../domain/season/career_state.dart';

abstract final class AppPreferences {
  static const termsVersion = '1';
  static const termsAcceptedKey = 'legal_terms_accepted_version';
  static const defaultGameSettingsKey = 'default_game_settings';

  static String careerIntroPendingKey(String careerId) =>
      'career_intro_pending:$careerId';

  static GameSettings decodeGameSettings(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const GameSettings();
    try {
      final value = jsonDecode(raw);
      if (value is! Map) return const GameSettings();
      return GameSettings.fromJson(Map<String, dynamic>.from(value));
    } catch (_) {
      return const GameSettings();
    }
  }

  static String encodeGameSettings(GameSettings settings) =>
      jsonEncode(settings.toJson());
}
