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
    this.compactSingleRow = false,
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
  final bool compactSingleRow;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final forceCompact = compactSingleRow;
          final canSplit = forceCompact || constraints.maxWidth >= 330;
          final tableCard = _DashboardCard(
            accent: AppColors.green,
            compact: forceCompact,
            onTap: onStandingsTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DashboardSectionHeader(
                  title: 'CLASSIFICAÇÃO',
                  action: 'VER TABELA',
                  onAction: onStandingsTap,
                  compact: forceCompact,
                ),
                SizedBox(height: forceCompact ? 4 : 8),
                HomeCompactStandings(
                  standings: standings,
                  clubs: clubs,
                  userClubId: userClubId,
                  compactColumns: true,
                  ultraCompact: false,
                  onClubTap: onClubTap,
                ),
              ],
            ),
          );
          final scorersCard = _DashboardCard(
            accent: AppColors.green,
            compact: forceCompact,
            onTap: onScorersTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DashboardSectionHeader(
                  title: 'ARTILHARIA',
                  action: 'VER TODOS',
                  onAction: onScorersTap,
                  compact: forceCompact,
                ),
                SizedBox(height: forceCompact ? 3 : 5),
                if (scorers.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: forceCompact ? 10 : 18),
                    child: Text(
                      'Sem gols.',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: forceCompact ? 10 : 12,
                      ),
                    ),
                  )
                else
                  for (var index = 0; index < scorers.length; index++)
                    _ScorerRow(
                      position: index + 1,
                      entry: scorers[index],
                      compact: canSplit,
                      ultraCompact: forceCompact,
                      onTap: () => onPlayerTap(scorers[index]),
                    ),
              ],
            ),
          );
          if (!canSplit) {
            return Column(children: [tableCard, const SizedBox(height: 8), scorersCard]);
          }
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: forceCompact ? 14 : 18, child: tableCard),
                SizedBox(width: forceCompact ? 5 : 7),
                Expanded(flex: 10, child: scorersCard),
              ],
            ),
          );
        },
      );
}

class HomeScorerEntry {
  const HomeScorerEntry({
    required this.player,
    required this.club,
    required this.stats,
  });

  final Player player;
  final Club club;
  final PlayerSeasonStats stats;
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.child,
    required this.compact,
    this.accent,
    this.onTap,
  });

  final Widget child;
  final Color? accent;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(compact ? 14 : 18);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          padding: EdgeInsets.all(compact ? 8 : 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (accent ?? AppColors.green).withValues(alpha: compact ? .10 : .12),
                AppColors.surface,
                AppColors.background,
              ],
            ),
            borderRadius: radius,
            border: Border.all(color: (accent ?? AppColors.border).withValues(alpha: .21)),
            boxShadow: const [
              BoxShadow(color: Color(0x1E000000), blurRadius: 9, offset: Offset(0, 4)),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _DashboardSectionHeader extends StatelessWidget {
  const _DashboardSectionHeader({
    required this.title,
    required this.compact,
    this.action,
    this.onAction,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: compact ? 11.5 : 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          if (action != null)
            InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                child: Row(
                  children: [
                    Text(
                      action!,
                      style: TextStyle(
                        color: AppColors.green,
                        fontSize: compact ? 9.8 : 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 1),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: compact ? 10 : 12,
                      color: AppColors.green,
                    ),
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
    required this.ultraCompact,
    required this.onTap,
  });

  final int position;
  final HomeScorerEntry entry;
  final bool compact;
  final bool ultraCompact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: ultraCompact ? 4.5 : compact ? 5 : 7),
          child: Row(
            children: [
              SizedBox(
                width: ultraCompact ? 11 : compact ? 12 : 16,
                child: Text(
                  '$position',
                  style: TextStyle(
                    fontSize: ultraCompact ? 10.5 : 11,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              PlayerAvatar(
                player: entry.player,
                size: ultraCompact ? 27 : compact ? 27 : 34,
                accentColor: Color(entry.club.colors.primaryHex),
              ),
              SizedBox(width: ultraCompact ? 3 : compact ? 4 : 7),
              Expanded(
                child: Text(
                  entry.player.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: ultraCompact ? 10.8 : compact ? 11 : 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 2),
              Text(
                '${entry.stats.goals}',
                style: TextStyle(
                  fontSize: ultraCompact ? 12 : compact ? 14 : 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      );
}
