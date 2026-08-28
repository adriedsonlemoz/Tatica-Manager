import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/match/match_models.dart';

enum LiveMatchPhaseTransition { halftime, fulltime }

class LiveMatchPhaseTransitionOverlay extends StatefulWidget {
  const LiveMatchPhaseTransitionOverlay({
    super.key,
    required this.phase,
    required this.score,
  });

  final LiveMatchPhaseTransition? phase;
  final MatchScore score;

  @override
  State<LiveMatchPhaseTransitionOverlay> createState() =>
      _LiveMatchPhaseTransitionOverlayState();
}

class _LiveMatchPhaseTransitionOverlayState
    extends State<LiveMatchPhaseTransitionOverlay> {
  Timer? _timer;
  bool _visible = false;
  LiveMatchPhaseTransition? _lastPhase;

  @override
  void initState() {
    super.initState();
    _lastPhase = widget.phase;
    _visible = widget.phase != null;
    if (_visible) _scheduleHide(widget.phase!);
  }

  @override
  void didUpdateWidget(covariant LiveMatchPhaseTransitionOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    final phase = widget.phase;
    if (phase == null || phase == _lastPhase) return;
    _lastPhase = phase;
    _timer?.cancel();
    setState(() => _visible = true);
    _scheduleHide(phase);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _scheduleHide(LiveMatchPhaseTransition phase) {
    _timer = Timer(
      Duration(
        milliseconds:
            phase == LiveMatchPhaseTransition.fulltime ? 2300 : 1900,
      ),
      () {
        if (mounted) setState(() => _visible = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final phase = widget.phase;
    return IgnorePointer(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: _visible && phase != null ? 1 : 0,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutBack,
          scale: _visible ? 1 : .90,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.black.withValues(alpha: .68),
                  Colors.black.withValues(alpha: .90),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  phase == LiveMatchPhaseTransition.fulltime
                      ? Icons.sports_score_rounded
                      : Icons.pause_circle_filled_rounded,
                  color: AppColors.green,
                  size: 30,
                ),
                const SizedBox(height: 8),
                Text(
                  phase == LiveMatchPhaseTransition.fulltime
                      ? 'FIM DE JOGO'
                      : 'INTERVALO',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.score.display,
                  style: const TextStyle(
                    color: AppColors.green,
                    fontWeight: FontWeight.w900,
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  phase == LiveMatchPhaseTransition.fulltime
                      ? 'Apito final. Confira o resumo da partida.'
                      : 'Hora de ajustar a equipe para o segundo tempo.',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
