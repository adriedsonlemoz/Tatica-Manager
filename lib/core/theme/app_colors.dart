import 'package:flutter/material.dart';

abstract final class AppColors {
  // Base azul-grafite: mantém o jogo escuro, mas evita o preto absoluto e
  // cria separação visual suficiente entre fundo, cards e modais.
  static const background = Color(0xFF101820);
  static const surface = Color(0xFF162229);
  static const surfaceRaised = Color(0xFF1C2B32);
  static const surfaceSoft = Color(0xFF23353D);
  static const navigation = Color(0xFF132027);

  // O verde continua sendo a assinatura do Tática Manager, agora usado como
  // acento em vez de dominar todas as superfícies.
  static const green = Color(0xFF76D91B);
  static const greenDark = Color(0xFF4FAE32);
  static const greenSoft = Color(0xFF263D2C);

  static const white = Color(0xFFF4F5F2);
  static const textSecondary = Color(0xFFAAB5B6);
  static const muted = textSecondary;
  static const border = Color(0xFF32454B);
  static const danger = Color(0xFFE75A52);
  static const warning = Color(0xFFD6B65D);
  static const info = Color(0xFF65AFFF);
  static const pitch = Color(0xFF1F5E21);
  static const pitchDark = Color(0xFF174D1A);

  /// Mantém a identidade do clube sem deixar acentos muito escuros
  /// desaparecerem sobre as superfícies escuras do jogo.
  static Color readableAccent(Color color) {
    final luminance = color.computeLuminance();
    if (luminance < 0.07) {
      return Color.lerp(color, green, 0.68)!;
    }
    if (luminance < 0.14) {
      return Color.lerp(color, white, 0.26)!;
    }
    return color;
  }

  static Color foregroundOn(Color background) =>
      background.computeLuminance() > 0.55 ? Colors.black : white;
}
