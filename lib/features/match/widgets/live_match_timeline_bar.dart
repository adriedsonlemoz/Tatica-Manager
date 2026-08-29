import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/match/match_models.dart';
import '../match_event_presentation.dart';

class LiveMatchTimelineBar extends StatelessWidget {
  const LiveMatchTimelineBar({
    super.key,
    required this.events,
    required this.minute,
    this.throughSequence,
  });

  final List<MatchEvent> events;
  final int minute;
  final int? throughSequence;

  @override
  Widget build(BuildContext context) {
    final visible = events.where(_isVisible).toList(growable: false);
    return SizedBox(
      height: 34,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 30,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Text(
              "$minute'",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final progress = (minute.clamp(0, 90) / 90).toDouble();
                return Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.green.withValues(alpha: .68),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    for (final event in visible)
                      Positioned(
                        left: ((event.minute.clamp(0, 90) / 90) *
                                (constraints.maxWidth - 7))
                            .toDouble(),
                        child: Container(
                          width: MatchEventPresentation.isMajor(event.type) ? 9 : 6,
                          height: MatchEventPresentation.isMajor(event.type) ? 9 : 6,
                          decoration: BoxDecoration(
                            color: _eventColor(event.type),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.surface,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _isVisible(MatchEvent event) =>
      event.minute < minute ||
      (event.minute == minute &&
          (throughSequence == null || event.sequence <= throughSequence!));

  static Color _eventColor(MatchEventType type) => switch (type) {
        MatchEventType.goal || MatchEventType.ownGoal => AppColors.green,
        MatchEventType.yellow => AppColors.warning,
        MatchEventType.red => AppColors.danger,
        MatchEventType.woodwork || MatchEventType.penalty => const Color(0xFFE6C755),
        MatchEventType.substitution => const Color(0xFF65AFFF),
        _ => AppColors.textSecondary,
      };
}
