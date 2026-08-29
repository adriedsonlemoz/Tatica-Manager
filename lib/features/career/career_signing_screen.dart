import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/widgets/common.dart';
import '../../core/theme/app_colors.dart';
import '../../data/club_seed.dart';
import 'career_signing_components.dart';

class CareerSigningScreen extends ConsumerStatefulWidget {
  const CareerSigningScreen({
    super.key,
    required this.managerName,
    required this.clubId,
  });

  final String managerName;
  final String clubId;

  @override
  ConsumerState<CareerSigningScreen> createState() =>
      _CareerSigningScreenState();
}

class _CareerSigningScreenState extends ConsumerState<CareerSigningScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _finishTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..forward();
    _controller.addStatusListener((status) {
      if (status != AnimationStatus.completed) return;
      _finishTimer = Timer(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        Navigator.of(context).popUntil((route) => route.isFirst);
      });
    });
  }

  @override
  void dispose() {
    _finishTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final career = ref.watch(gameControllerProvider).career;
    final activeClub =
        career?.clubs.where((club) => club.id == widget.clubId).firstOrNull;
    final club = activeClub ??
        clubSeeds.firstWhere((seed) => seed.id == widget.clubId).toClub();
    final season = career?.season ?? DateTime.now().year;

    return PremiumScaffold(
      safeBottom: true,
      body: Container(
        width: double.infinity,
        decoration:  BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.surfaceSoft, AppColors.background],
          ),
        ),
        child: Stack(
          children: [
            const Positioned(
              top: -90,
              right: -70,
              child: CareerSigningGlowOrb(size: 240),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
                child: Column(
                  children: [
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.green.withValues(alpha: .10),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: AppColors.green.withValues(alpha: .28),
                        ),
                      ),
                      child: const Text(
                        'NOVO DESAFIO',
                        style: TextStyle(
                          color: AppColors.green,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Formalizando sua chegada',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${widget.managerName} • ${club.name}',
                      style:  TextStyle(color: AppColors.muted),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) => CareerSigningContractDocument(
                        managerName: widget.managerName,
                        clubName: club.name,
                        season: season,
                        club: club,
                        progress:
                            Curves.easeInOutCubic.transform(_controller.value),
                      ),
                    ),
                    const SizedBox(height: 14),
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        final done = _controller.value >= .98;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: done
                                ? AppColors.green.withValues(alpha: .10)
                                : AppColors.surfaceRaised,
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(
                              color: done
                                  ? AppColors.green.withValues(alpha: .35)
                                  : AppColors.border,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                done
                                    ? Icons.verified_rounded
                                    : Icons.edit_rounded,
                                color: AppColors.green,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                done
                                    ? 'Contrato assinado'
                                    : 'Assinando o documento...',
                                style: TextStyle(
                                  color:
                                      done ? AppColors.green : AppColors.muted,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const Spacer(flex: 2),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
