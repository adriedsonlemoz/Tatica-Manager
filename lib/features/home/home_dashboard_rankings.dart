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
            compact: forceCompact,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DashboardSectionHeader(
                  title: 'CLASSIFICAÇÃO',
                  compact: forceCompact,
                ),
                SizedBox(height: forceCompact ? 5 : 8),
                HomeCompactStandings(
                  standings: standings,
                  clubs: clubs,
                  userClubId: userClubId,
                  compactColumns: true,
                  ultraCompact: false,
                  maxRows: 4,
                  pinUser: false,
                  onClubTap: onClubTap,
                ),
                SizedBox(height: forceCompact ? 5 : 7),
                _DashboardFooter(
                  label: 'Ver tabela completa',
                  onTap: onStandingsTap,
                  compact: forceCompact,
                ),
              ],
            ),
          );
          final scorersCard = _DashboardCard(
            compact: forceCompact,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DashboardSectionHeader(
                  title: 'ARTILHARIA',
                  compact: forceCompact,
                ),
                SizedBox(height: forceCompact ? 4 : 6),
                if (scorers.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: forceCompact ? 12 : 18),
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
                      entry: scorers[index],
                      compact: forceCompact,
                      onTap: () => onPlayerTap(scorers[index]),
                    ),
                SizedBox(height: forceCompact ? 5 : 7),
                _DashboardFooter(
                  label: 'Ver artilharia completa',
                  onTap: onScorersTap,
                  compact: forceCompact,
                ),
              ],
            ),
          );
          if (!canSplit) {
            return Column(
              children: [
                tableCard,
                const SizedBox(height: 8),
                scorersCard,
              ],
            );
          }
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: tableCard),
                SizedBox(width: forceCompact ? 6 : 8),
                Expanded(child: scorersCard),
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
  });

  final Widget child;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(compact ? 14 : 16);
    return Container(
      padding: EdgeInsets.all(compact ? 8 : 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF102536), Color(0xFF0D2130), Color(0xFF0B1C29)],
        ),
        borderRadius: radius,
        border: Border.all(color: const Color(0xFF29414E)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1E000000),
            blurRadius: 9,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DashboardSectionHeader extends StatelessWidget {
  const _DashboardSectionHeader({
    required this.title,
    required this.compact,
  });

  final String title;
  final bool compact;

  @override
  Widget build(BuildContext context) => Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: AppColors.green,
          fontSize: compact ? 11.5 : 12.5,
          fontWeight: FontWeight.w900,
          letterSpacing: .2,
        ),
      );
}

class _DashboardFooter extends StatelessWidget {
  const _DashboardFooter({
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
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(top: compact ? 5 : 7, bottom: 1),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: AppColors.border.withValues(alpha: .72),
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: compact ? 10.2 : 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: compact ? 16 : 18,
              ),
            ],
          ),
        ),
      );
}

class _ScorerRow extends StatelessWidget {
  const _ScorerRow({
    required this.entry,
    required this.compact,
    required this.onTap,
  });

  final HomeScorerEntry entry;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: compact ? 4 : 6),
          child: Row(
            children: [
              PlayerAvatar(
                player: entry.player,
                size: compact ? 30 : 34,
                accentColor: Color(entry.club.colors.primaryHex),
              ),
              SizedBox(width: compact ? 5 : 7),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.player.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: compact ? 10.7 : 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      entry.club.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: compact ? 9.3 : 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${entry.stats.goals}',
                style: TextStyle(
                  color: AppColors.green,
                  fontSize: compact ? 14 : 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      );
}
