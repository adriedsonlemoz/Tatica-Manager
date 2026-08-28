import 'package:flutter/material.dart';

import '../../app/widgets/player_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/club/club.dart';
import '../../domain/league/standing.dart';
import '../../domain/player/player.dart';
import 'home_overview_widgets.dart';

class HomeLeagueAndScorers extends StatelessWidget {
  const HomeLeagueAndScorers({
    super.key,
    required this.standings,
    required this.clubs,
    required this.userClubId,
    required this.scorers,
    required this.competitionName,
    required this.onClubTap,
    required this.onPlayerTap,
    required this.onStandingsTap,
    required this.onScorersTap,
  });

  final List<Standing> standings;
  final List<Club> clubs;
  final String userClubId;
  final List<HomeScorerEntry> scorers;
  final String competitionName;
  final ValueChanged<String> onClubTap;
  final ValueChanged<HomeScorerEntry> onPlayerTap;
  final VoidCallback onStandingsTap;
  final VoidCallback onScorersTap;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final canSplit = constraints.maxWidth >= 330;
          final dense = constraints.maxWidth < 440;
          final tableCard = _DashboardCard(
            accent: AppColors.green,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DashboardSectionHeader(
                  icon: Icons.bar_chart_rounded,
                  title: competitionName.toUpperCase(),
                  action: 'TABELA',
                  onAction: onStandingsTap,
                ),
                const SizedBox(height: 8),
                HomeCompactStandings(
                  standings: standings,
                  clubs: clubs,
                  userClubId: userClubId,
                  compactColumns: dense && canSplit,
                  onClubTap: onClubTap,
                ),
              ],
            ),
          );
          final scorersCard = _DashboardCard(
            accent: const Color(0xFFFFC857),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DashboardSectionHeader(
                  title: 'ARTILHEIROS',
                  action: dense ? null : 'VER TODOS',
                  onAction: onScorersTap,
                ),
                const SizedBox(height: 5),
                if (scorers.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: Text('Sem gols.', style: TextStyle(color: AppColors.muted, fontSize: 9)),
                  )
                else
                  for (var index = 0; index < scorers.length; index++)
                    _ScorerRow(
                      position: index + 1,
                      entry: scorers[index],
                      compact: dense && canSplit,
                      onTap: () => onPlayerTap(scorers[index]),
                    ),
                if (dense && canSplit) ...[
                  const SizedBox(height: 3),
                  InkWell(
                    onTap: onScorersTap,
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('RANKING', style: TextStyle(color: AppColors.green, fontSize: 7, fontWeight: FontWeight.w900)),
                          SizedBox(width: 2),
                          Icon(Icons.chevron_right_rounded, color: AppColors.green, size: 13),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
          if (!canSplit) {
            return Column(children: [tableCard, const SizedBox(height: 8), scorersCard]);
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 18, child: tableCard),
              const SizedBox(width: 7),
              Expanded(flex: 10, child: scorersCard),
            ],
          );
        },
      );
}

class HomeScorerEntry {
  const HomeScorerEntry({required this.player, required this.club});

  final Player player;
  final Club club;
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({required this.child, this.accent});

  final Widget child;
  final Color? accent;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              (accent ?? AppColors.green).withValues(alpha: .07),
              AppColors.surface,
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: (accent ?? AppColors.border).withValues(alpha: .20)),
          boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 12, offset: Offset(0, 5))],
        ),
        child: child,
      );
}

class _DashboardSectionHeader extends StatelessWidget {
  const _DashboardSectionHeader({required this.title, this.icon, this.action, this.onAction});

  final String title;
  final IconData? icon;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.green, size: 17),
            const SizedBox(width: 5),
          ],
          Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900))),
          if (action != null)
            InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                child: Row(
                  children: [
                    Text(action!, style: const TextStyle(color: AppColors.green, fontSize: 7, fontWeight: FontWeight.w900)),
                    const SizedBox(width: 1),
                    const Icon(Icons.arrow_forward_rounded, size: 12, color: AppColors.green),
                  ],
                ),
              ),
            ),
        ],
      );
}

class _ScorerRow extends StatelessWidget {
  const _ScorerRow({
    required this.position,
    required this.entry,
    required this.compact,
    required this.onTap,
  });

  final int position;
  final HomeScorerEntry entry;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: compact ? 5 : 7),
          child: Row(
            children: [
              SizedBox(width: compact ? 12 : 16, child: Text('$position', style: const TextStyle(fontSize: 8, color: AppColors.muted, fontWeight: FontWeight.w900))),
              PlayerAvatar(player: entry.player, size: compact ? 27 : 34, accentColor: Color(entry.club.colors.primaryHex)),
              SizedBox(width: compact ? 4 : 7),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.player.displayName, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: compact ? 8 : 9, fontWeight: FontWeight.w900)),
                    if (!compact)
                      Text(entry.club.shortName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 7, color: AppColors.muted)),
                  ],
                ),
              ),
              const SizedBox(width: 3),
              Text('${entry.player.stats.goals}', style: TextStyle(fontSize: compact ? 11 : 13, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      );
}
