import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.green,
      brightness: Brightness.dark,
      surface: AppColors.surface,
    ).copyWith(
      primary: AppColors.green,
      secondary: AppColors.green,
      surface: AppColors.surface,
      error: AppColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      cardColor: AppColors.surface,
      dividerColor: AppColors.border,
      splashColor: AppColors.green.withValues(alpha: 0.12),
      highlightColor: AppColors.green.withValues(alpha: 0.06),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 38, fontWeight: FontWeight.w900),
        displayMedium: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
        displaySmall: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
        headlineLarge: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -0.8),
        headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.4),
        headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.35),
        bodyMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.32),
        bodySmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, height: 1.28),
        labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        labelMedium: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          side: BorderSide(color: AppColors.border),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: AppColors.navigation,
        indicatorColor: AppColors.greenSoft,
        height: 72,
        labelTextStyle: WidgetStatePropertyAll(TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.green,
          foregroundColor: Colors.black,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceRaised,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.green, width: 1.5),
        ),
      ),
    );
  }
}
