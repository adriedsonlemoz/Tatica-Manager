import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/career_controller.dart';
import '../../app/state/game_controller.dart';
import '../../core/theme/app_colors.dart';
import '../career/career_hub_screen.dart';
import '../home/game_shell.dart';

class BootstrapScreen extends ConsumerStatefulWidget {
  const BootstrapScreen({super.key});

  @override
  ConsumerState<BootstrapScreen> createState() => _BootstrapScreenState();
}

class _BootstrapScreenState extends ConsumerState<BootstrapScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(careerControllerProvider.notifier).bootstrap());
  }

  @override
  Widget build(BuildContext context) {
    final careers = ref.watch(careerControllerProvider);
    final game = ref.watch(gameControllerProvider);

    if (!careers.bootstrapped) return const Scaffold(body: _SplashBody());
    if (game.career != null) return const GameShell();
    return const CareerHubScreen();
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
            colors: [Color(0xFF0A130D), Color(0xFF040706)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/brand/tatica-manager-icon.png', width: 120, height: 120),
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
              const SizedBox(width: 34, height: 34, child: CircularProgressIndicator(strokeWidth: 3)),
            ],
          ),
        ),
      );
}
