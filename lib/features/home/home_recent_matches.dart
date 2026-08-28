import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/club/club.dart';
import '../../domain/match/match_models.dart';

class HomeRecentMatchEntry {
  const HomeRecentMatchEntry({
    required this.result,
    required this.opponent,
    required this.userClubId,
    this.date,
  });

  final MatchResult result;
  final Club opponent;
  final String userClubId;
  final DateTime? date;

  bool get userIsHome => result.homeClubId == userClubId;
  int get userGoals => userIsHome ? result.score.home : result.score.away;
  int get opponentGoals => userIsHome ? result.score.away : result.score.home;

  String get outcome {
    if (userGoals > opponentGoals) return 'V';
    if (userGoals < opponentGoals) return 'D';
    return 'E';
  }
}

class HomeRecentMatches extends StatelessWidget {
  const HomeRecentMatches({
    super.key,
    required this.entries,
    required this.onTap,
  });

  final List<HomeRecentMatchEntry> entries;
  final ValueChanged<HomeRecentMatchEntry> onTap;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.fromLTRB(9, 7, 9, 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF132229), Color(0xFF101B21)],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border.withValues(alpha: .72)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.history_rounded, color: AppColors.green, size: 14),
              SizedBox(width: 4),
              Text(
                'ÚLTIMAS PARTIDAS',
                style: TextStyle(fontSize: 8.8, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (context, constraints) {
              final tileWidth = ((constraints.maxWidth - 20) / 5)
                  .clamp(54.0, 72.0)
                  .toDouble();
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var index = 0; index < entries.length; index++) ...[
                      SizedBox(
                        width: tileWidth,
                        child: _RecentMatchTile(
                          entry: entries[index],
                          onTap: () => onTap(entries[index]),
                        ),
                      ),
                      if (index != entries.length - 1) const SizedBox(width: 5),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RecentMatchTile extends StatelessWidget {
  const _RecentMatchTile({required this.entry, required this.onTap});

  final HomeRecentMatchEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = switch (entry.outcome) {
      'V' => AppColors.green,
      'D' => AppColors.danger,
      _ => AppColors.warning,
    };
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: .07),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: accent.withValues(alpha: .20)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 13,
                    height: 13,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: .18),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      entry.outcome,
                      style: TextStyle(
                        color: accent,
                        fontSize: 7,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text(
                      entry.opponent.shortName.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 7.4, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${entry.userGoals} - ${entry.opponentGoals}',
                style: const TextStyle(fontSize: 10.2, fontWeight: FontWeight.w900, height: 1),
              ),
              if (entry.date != null) ...[
                const SizedBox(height: 2),
                Text(
                  shortDate(entry.date!),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 5.8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
