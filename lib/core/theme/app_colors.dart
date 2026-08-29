import 'package:flutter/material.dart';

abstract final class AppColors {
  static bool _darkMode = false;

  static void useDarkMode(bool enabled) {
    _darkMode = enabled;
  }

  static bool get isDarkMode => _darkMode;

  // Paleta neutra adaptativa. O modo claro é o padrão visual do aplicativo;
  // o modo escuro preserva a base azul-grafite já usada nas releases anteriores.
  static Color get background =>
      _darkMode ? const Color(0xFF101820) : const Color(0xFFF3F7F6);
  static Color get surface =>
      _darkMode ? const Color(0xFF162229) : const Color(0xFFFFFFFF);
  static Color get surfaceRaised =>
      _darkMode ? const Color(0xFF1C2B32) : const Color(0xFFF8FAF9);
  static Color get surfaceSoft =>
      _darkMode ? const Color(0xFF23353D) : const Color(0xFFEDF3F1);
  static Color get navigation =>
      _darkMode ? const Color(0xFF132027) : const Color(0xFFFFFFFF);
  static Color get textSecondary =>
      _darkMode ? const Color(0xFFAAB5B6) : const Color(0xFF607078);
  static Color get muted => textSecondary;
  static Color get border =>
      _darkMode ? const Color(0xFF32454B) : const Color(0xFFD8E2DF);
  static Color get greenSoft =>
      _darkMode ? const Color(0xFF263D2C) : const Color(0xFFE6F4E9);

  /// Superfícies de painéis especiais (pré-jogo, transmissão e onboarding).
  /// No modo claro elas acompanham a base branca; no escuro preservam o
  /// contraste grafite usado nas versões anteriores.
  static List<Color> get panelGradient => _darkMode
      ? const [Color(0xFF13232B), Color(0xFF101B22), Color(0xFF0F181E)]
      : const [Color(0xFFFFFFFF), Color(0xFFF8FAF9), Color(0xFFEDF3F1)];

  static List<Color> get broadcastGradient => _darkMode
      ? const [Color(0xFF091117), Color(0xFF0D171C), Color(0xFF101A20)]
      : const [Color(0xFFF8FAF9), Color(0xFFF3F7F6), Color(0xFFFFFFFF)];

  static Color get insetSurface =>
      _darkMode ? const Color(0xFF0B151B) : const Color(0xFFF1F5F4);

  static Color get contrastSurface =>
      _darkMode ? const Color(0xFF142128) : const Color(0xFFFFFFFF);

  // Cores de identidade permanecem estáveis entre os temas para preservar
  // significado semântico e contraste de eventos/estados.
  static const green = Color(0xFF35A94B);
  static const greenDark = Color(0xFF176B3A);
  static const white = Color(0xFFF8FAF8);
  static const danger = Color(0xFFE24D4D);
  static const warning = Color(0xFFD5A626);
  static const info = Color(0xFF388BE8);
  static const pitch = Color(0xFF1F5E21);
  static const pitchDark = Color(0xFF174D1A);

  static Color get textPrimary =>
      _darkMode ? const Color(0xFFF4F5F2) : const Color(0xFF102435);

  /// Mantém a identidade do clube legível tanto sobre superfícies claras
  /// quanto escuras sem descaracterizar a cor cadastrada.
  static Color readableAccent(Color color) {
    final luminance = color.computeLuminance();
    if (_darkMode) {
      if (luminance < 0.07) {
        return Color.lerp(color, green, 0.68)!;
      }
      if (luminance < 0.14) {
        return Color.lerp(color, white, 0.26)!;
      }
      return color;
    }
    if (luminance > 0.82) {
      return Color.lerp(color, const Color(0xFF163D2C), 0.42)!;
    }
    if (luminance < 0.045) {
      return Color.lerp(color, green, 0.42)!;
    }
    return color;
  }

  static Color foregroundOn(Color background) =>
      background.computeLuminance() > 0.55 ? Colors.black : white;
}
