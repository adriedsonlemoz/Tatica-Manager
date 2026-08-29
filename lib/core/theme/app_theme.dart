import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final background = dark ? const Color(0xFF101820) : const Color(0xFFF3F7F6);
    final surface = dark ? const Color(0xFF162229) : const Color(0xFFFFFFFF);
    final raised = dark ? const Color(0xFF1C2B32) : const Color(0xFFF8FAF9);
    final border = dark ? const Color(0xFF32454B) : const Color(0xFFD8E2DF);
    final foreground = dark ? const Color(0xFFF4F5F2) : const Color(0xFF102435);
    final muted = dark ? const Color(0xFFAAB5B6) : const Color(0xFF607078);

    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.green,
      brightness: brightness,
      surface: surface,
    ).copyWith(
      primary: AppColors.green,
      secondary: AppColors.green,
      surface: surface,
      onSurface: foreground,
      onSurfaceVariant: muted,
      outline: border,
      error: AppColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      cardColor: surface,
      dividerColor: border,
      splashColor: AppColors.green.withValues(alpha: 0.12),
      highlightColor: AppColors.green.withValues(alpha: 0.06),
      textTheme: TextTheme(
        headlineLarge: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.8).copyWith(color: foreground),
        headlineMedium: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.4).copyWith(color: foreground),
        titleLarge: const TextStyle(fontWeight: FontWeight.w800).copyWith(color: foreground),
        titleMedium: const TextStyle(fontWeight: FontWeight.w800).copyWith(color: foreground),
        titleSmall: const TextStyle(fontWeight: FontWeight.w700).copyWith(color: foreground),
        bodyLarge: const TextStyle(fontWeight: FontWeight.w500).copyWith(color: foreground),
        bodyMedium: const TextStyle(fontWeight: FontWeight.w500).copyWith(color: foreground),
        bodySmall: TextStyle(color: muted),
        labelLarge: const TextStyle(fontWeight: FontWeight.w800).copyWith(color: foreground),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: foreground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(18)),
          side: BorderSide(color: border),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: dark ? const Color(0xFF263D2C) : const Color(0xFFE6F4E9),
        height: 72,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: foreground),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.green,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: foreground,
          minimumSize: const Size(48, 48),
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: raised,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.green, width: 1.5),
        ),
      ),
      dialogTheme: DialogThemeData(backgroundColor: surface),
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: surface),
    );
  }
}
