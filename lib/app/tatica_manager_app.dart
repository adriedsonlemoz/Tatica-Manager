import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/season/career_state.dart';
import '../features/bootstrap/bootstrap_screen.dart';
import 'audio/audio_manager.dart';
import 'audio/audio_providers.dart';
import 'state/game_controller.dart';
import 'state/providers.dart';
import 'widgets/audio_interaction_layer.dart';
import '../core/platform/system_ui.dart';
import '../core/theme/app_theme.dart';

class TaticaManagerApp extends ConsumerStatefulWidget {
  const TaticaManagerApp({super.key});

  @override
  ConsumerState<TaticaManagerApp> createState() => _TaticaManagerAppState();
}

class _TaticaManagerAppState extends ConsumerState<TaticaManagerApp>
    with WidgetsBindingObserver {
  Timer? _systemUiRestoreTimer;
  late final AudioManager _audioManager;
  late final AudioNavigationObserver _audioNavigationObserver;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _audioManager = ref.read(audioManagerProvider);
    _audioNavigationObserver = AudioNavigationObserver(_audioManager);
    unawaited(_primeAudio());
  }


  Future<void> _primeAudio() async {
    // Carrega a última preferência durante o splash, antes da primeira tela útil.
    // O AudioManager continua singleton e startMenuMusic é idempotente, evitando
    // a criação de um segundo player durante rebuilds.
    try {
      final repository = ref.read(careerRepositoryProvider);
      final lastId = await repository.loadLastActiveCareerId();
      final saved = lastId == null ? null : await repository.load(lastId);
      await _audioManager.applySettings(saved?.settings ?? const GameSettings());
    } catch (_) {
      await _audioManager.applySettings(const GameSettings());
    }
  }

  @override
  void dispose() {
    _systemUiRestoreTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(SystemUiController.apply());
      unawaited(_audioManager.resumeAfterLifecycle());
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      unawaited(_audioManager.pauseForLifecycle());
    }
  }

  @override
  void didChangeMetrics() {
    // O teclado do Android pode restaurar temporariamente as barras do sistema.
    // Reaplicamos o modo imersivo depois da animação de abertura/fechamento.
    _systemUiRestoreTimer?.cancel();
    _systemUiRestoreTimer = Timer(const Duration(milliseconds: 1200), () {
      unawaited(SystemUiController.apply());
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<GameState>(gameControllerProvider, (previous, next) {
      final settings = next.career?.settings;
      if (settings != null) unawaited(_audioManager.applySettings(settings));
    });

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tática Manager',
      theme: AppTheme.dark,
      navigatorObservers: [_audioNavigationObserver],
      builder: (context, child) => AudioInteractionLayer(
        audioManager: _audioManager,
        child: child ?? const SizedBox.shrink(),
      ),
      home: const BootstrapScreen(),
    );
  }
}
