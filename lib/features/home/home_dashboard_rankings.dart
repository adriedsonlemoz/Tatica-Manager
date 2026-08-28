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
          final dense = forceCompact || constraints.maxWidth < 440;
          final tableCard = _DashboardCard(
            accent: AppColors.green,
            compact: forceCompact,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DashboardSectionHeader(
                  icon: Icons.bar_chart_rounded,
                  title: competitionName.toUpperCase(),
                  action: 'TABELA',
                  onAction: onStandingsTap,
                  compact: forceCompact,
                ),
                SizedBox(height: forceCompact ? 4 : 8),
                HomeCompactStandings(
                  standings: standings,
                  clubs: clubs,
                  userClubId: userClubId,
                  compactColumns: dense && canSplit,
                  ultraCompact: forceCompact,
                  onClubTap: onClubTap,
                ),
                SizedBox(height: forceCompact ? 3 : 6),
                _FooterLink(
                  label: forceCompact
                      ? 'VER TABELA'
                      : dense && canSplit
                          ? 'VER TABELA'
                          : 'VER TABELA COMPLETA',
                  onTap: onStandingsTap,
                  compact: forceCompact,
                ),
              ],
            ),
          );
          final scorersCard = _DashboardCard(
            accent: const Color(0xFFE4A92E),
            compact: forceCompact,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DashboardSectionHeader(
                  title: 'ARTILHEIROS',
                  action: forceCompact || dense ? null : 'RANKING',
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
                        fontSize: forceCompact ? 6 : 9,
                      ),
                    ),
                  )
                else
                  for (var index = 0; index < scorers.length; index++)
                    _ScorerRow(
                      position: index + 1,
                      entry: scorers[index],
                      compact: dense && canSplit,
                      ultraCompact: forceCompact,
                      onTap: () => onPlayerTap(scorers[index]),
                    ),
                SizedBox(height: forceCompact ? 2 : 6),
                _FooterLink(
                  label: forceCompact
                      ? 'VER RANKING'
                      : dense && canSplit
                          ? 'VER RANKING'
                          : 'VER RANKING COMPLETO',
                  onTap: onScorersTap,
                  compact: forceCompact,
                ),
              ],
            ),
          );
          if (!canSplit) {
            return Column(children: [tableCard, const SizedBox(height: 8), scorersCard]);
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: forceCompact ? 16 : 18, child: tableCard),
              SizedBox(width: forceCompact ? 5 : 7),
              Expanded(flex: 10, child: scorersCard),
            ],
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
  });

  final Widget child;
  final Color? accent;
  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.all(compact ? 7 : 10),
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
          borderRadius: BorderRadius.circular(compact ? 14 : 18),
          border: Border.all(color: (accent ?? AppColors.border).withValues(alpha: .21)),
          boxShadow: const [
            BoxShadow(color: Color(0x1E000000), blurRadius: 9, offset: Offset(0, 4)),
          ],
        ),
        child: child,
      );
}

class _DashboardSectionHeader extends StatelessWidget {
  const _DashboardSectionHeader({
    required this.title,
    required this.compact,
    this.icon,
    this.action,
    this.onAction,
  });

  final String title;
  final IconData? icon;
  final String? action;
  final VoidCallback? onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.green, size: compact ? 10 : 17),
            SizedBox(width: compact ? 3 : 5),
          ],
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: compact ? 6.3 : 9,
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
                        fontSize: compact ? 5.1 : 7,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 1),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: compact ? 8 : 12,
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
          padding: EdgeInsets.symmetric(vertical: ultraCompact ? 2.5 : compact ? 5 : 7),
          child: Row(
            children: [
              SizedBox(
                width: ultraCompact ? 9 : compact ? 12 : 16,
                child: Text(
                  '$position',
                  style: TextStyle(
                    fontSize: ultraCompact ? 5.8 : 8,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              PlayerAvatar(
                player: entry.player,
                size: ultraCompact ? 20 : compact ? 27 : 34,
                accentColor: Color(entry.club.colors.primaryHex),
              ),
              SizedBox(width: ultraCompact ? 3 : compact ? 4 : 7),
              Expanded(
                child: Text(
                  entry.player.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: ultraCompact ? 5.8 : compact ? 8 : 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 2),
              Text(
                '${entry.stats.goals}',
                style: TextStyle(
                  fontSize: ultraCompact ? 7 : compact ? 11 : 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      );
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({
    required this.label,
    required this.onTap,
    required this.compact,
  });

  final String label;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: compact ? 2 : 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppColors.green,
                  fontSize: compact ? 5.2 : 7.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 1),
              Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.green,
                size: compact ? 8 : 14,
              ),
            ],
          ),
        ),
      );
}
