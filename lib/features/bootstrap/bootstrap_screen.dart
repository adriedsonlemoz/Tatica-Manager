import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/career_controller.dart';
import '../../app/state/game_controller.dart';
import '../../app/state/providers.dart';
import '../../core/config/app_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/season/career_state.dart';
import '../career/career_arrival_screen.dart';
import '../career/career_hub_screen.dart';
import '../home/game_shell.dart';
import '../legal/first_run_terms_gate.dart';

class BootstrapScreen extends ConsumerStatefulWidget {
  const BootstrapScreen({super.key});

  @override
  ConsumerState<BootstrapScreen> createState() => _BootstrapScreenState();
}

class _BootstrapScreenState extends ConsumerState<BootstrapScreen> {
  bool _termsLoaded = false;
  bool _termsAccepted = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_bootstrap);
  }

  Future<void> _bootstrap() async {
    await ref.read(careerControllerProvider.notifier).bootstrap();
    final repository = ref.read(careerRepositoryProvider);
    final accepted = await repository.loadAppValue(
      AppPreferences.termsAcceptedKey,
    );
    if (!mounted) return;
    setState(() {
      _termsLoaded = true;
      _termsAccepted = accepted == AppPreferences.termsVersion;
    });
  }

  Future<void> _acceptTerms() async {
    await ref.read(careerRepositoryProvider).saveAppValue(
          AppPreferences.termsAcceptedKey,
          AppPreferences.termsVersion,
        );
    if (!mounted) return;
    setState(() => _termsAccepted = true);
  }

  @override
  Widget build(BuildContext context) {
    final careers = ref.watch(careerControllerProvider);
    final game = ref.watch(gameControllerProvider);

    if (!careers.bootstrapped || !_termsLoaded) {
      return const Scaffold(body: _SplashBody());
    }
    if (!_termsAccepted) {
      return FirstRunTermsGate(onAccept: _acceptTerms);
    }
    final career = game.career;
    if (career != null) {
      return _CareerEntryGate(
        key: ValueKey(career.careerId),
        career: career,
      );
    }
    return const CareerHubScreen();
  }
}

class _CareerEntryGate extends ConsumerStatefulWidget {
  const _CareerEntryGate({super.key, required this.career});

  final CareerState career;

  @override
  ConsumerState<_CareerEntryGate> createState() => _CareerEntryGateState();
}

class _CareerEntryGateState extends ConsumerState<_CareerEntryGate> {
  bool _loading = true;
  bool _showArrival = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final pending = await ref.read(careerRepositoryProvider).loadAppValue(
          AppPreferences.careerIntroPendingKey(widget.career.careerId),
        );
    if (!mounted) return;
    setState(() {
      _showArrival = pending == 'true';
      _loading = false;
    });
  }

  Future<void> _finishArrival() async {
    await ref.read(careerRepositoryProvider).saveAppValue(
          AppPreferences.careerIntroPendingKey(widget.career.careerId),
          null,
        );
    if (!mounted) return;
    setState(() => _showArrival = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: _SplashBody());
    if (_showArrival) {
      return CareerArrivalScreen(
        career: widget.career,
        onContinue: _finishArrival,
      );
    }
    return const GameShell();
  }
}

class _SplashBody extends StatelessWidget {
  const _SplashBody();

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.surfaceRaised, AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/brand/tatica-manager-icon.png',
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 22),
              Text(
                'TÁTICA',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
              ),
              Text(
                'MANAGER',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.green,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                'GERENCIE. ESCALA. VENCE.',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      letterSpacing: 2,
                      color: AppColors.muted,
                    ),
              ),
              const SizedBox(height: 40),
              const SizedBox(
                width: 34,
                height: 34,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            ],
          ),
        ),
      );
}
