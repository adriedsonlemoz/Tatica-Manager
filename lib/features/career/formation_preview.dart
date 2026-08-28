import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/formation/formation.dart';

class FormationMiniPitch extends StatefulWidget {
  const FormationMiniPitch({
    super.key,
    required this.formation,
    this.height = 94,
  });

  final FormationType formation;
  final double height;

  @override
  State<FormationMiniPitch> createState() => _FormationMiniPitchState();
}

class _FormationMiniPitchState extends State<FormationMiniPitch>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slots = FormationCatalog.slots[widget.formation] ?? const <FormationSlot>[];
    return AspectRatio(
      aspectRatio: .75,
      child: LayoutBuilder(
        builder: (context, constraints) => AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => Container(
            height: widget.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.green.withValues(alpha: .18),
                  AppColors.green.withValues(alpha: .10),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.green.withValues(alpha: .45)),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 5,
                  right: 5,
                  top: 5,
                  bottom: 5,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withValues(alpha: .14)),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: constraints.maxHeight / 2,
                  child: Container(
                    height: 1,
                    color: Colors.white.withValues(alpha: .18),
                  ),
                ),
                Positioned(
                  left: constraints.maxWidth / 2 - 12,
                  top: constraints.maxHeight / 2 - 12,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: .18)),
                    ),
                  ),
                ),
                for (var index = 0; index < slots.length; index++)
                  Positioned(
                    left: slots[index].x * constraints.maxWidth - 4,
                    top: slots[index].y * constraints.maxHeight - 4 + _offset(index),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: slots[index].role.name == 'gol'
                            ? AppColors.warning
                            : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .25),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _offset(int index) {
    final base = math.sin((_controller.value * math.pi * 2) + index * .65);
    return base * .85;
  }
}
