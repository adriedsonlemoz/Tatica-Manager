import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_preferences.dart';
import 'providers.dart';

final appAppearanceProvider =
    NotifierProvider<AppAppearanceController, ThemeMode>(
  AppAppearanceController.new,
);

class AppAppearanceController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    Future.microtask(_load);
    return ThemeMode.light;
  }

  Future<void> _load() async {
    final repository = ref.read(careerRepositoryProvider);
    final raw = await repository.loadAppValue(AppPreferences.themeModeKey);
    state = raw == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> setDarkMode(bool enabled) async {
    final next = enabled ? ThemeMode.dark : ThemeMode.light;
    if (state == next) return;
    state = next;
    final repository = ref.read(careerRepositoryProvider);
    await repository.saveAppValue(
      AppPreferences.themeModeKey,
      enabled ? 'dark' : 'light',
    );
  }
}
