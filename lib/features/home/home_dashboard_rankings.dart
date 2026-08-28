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
          final tableCard = _DashboardCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DashboardSectionHeader(
                  icon: Icons.bar_chart_rounded,
                  title: competitionName.toUpperCase(),
                  action: 'VER TABELA',
                  onAction: onStandingsTap,
                ),
                const SizedBox(height: 8),
                HomeCompactStandings(
                  standings: standings,
                  clubs: clubs,
                  userClubId: userClubId,
                  onClubTap: onClubTap,
                ),
              ],
            ),
          );
          final scorersCard = _DashboardCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DashboardSectionHeader(title: 'ARTILHEIROS', action: 'VER TODOS', onAction: onScorersTap),
                const SizedBox(height: 6),
                if (scorers.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: Text('Ainda não há gols registrados.', style: TextStyle(color: AppColors.muted, fontSize: 10)),
                  )
                else
                  for (var index = 0; index < scorers.length; index++)
                    _ScorerRow(
                      position: index + 1,
                      entry: scorers[index],
                      onTap: () => onPlayerTap(scorers[index]),
                    ),
              ],
            ),
          );
          if (constraints.maxWidth < 380) {
            return Column(children: [tableCard, const SizedBox(height: 8), scorersCard]);
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 17, child: tableCard),
              const SizedBox(width: 8),
              Expanded(flex: 11, child: scorersCard),
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
  const _DashboardCard({required this.child, this.padding = const EdgeInsets.all(12)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: const Color(0xFF091110),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF25302F)),
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
            Icon(icon, color: AppColors.green, size: 18),
            const SizedBox(width: 6),
          ],
          Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900))),
          if (action != null)
            InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                child: Row(
                  children: [
                    Text(action!, style: const TextStyle(color: AppColors.green, fontSize: 8, fontWeight: FontWeight.w900)),
                    const SizedBox(width: 2),
                    const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.green),
                  ],
                ),
              ),
            ),
        ],
      );
}


class _ScorerRow extends StatelessWidget {
  const _ScorerRow({required this.position, required this.entry, required this.onTap});

  final int position;
  final HomeScorerEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            children: [
              SizedBox(width: 16, child: Text('$position', style: const TextStyle(fontSize: 9, color: AppColors.muted, fontWeight: FontWeight.w900))),
              PlayerAvatar(player: entry.player, size: 34, accentColor: Color(entry.club.colors.primaryHex)),
              const SizedBox(width: 7),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.player.displayName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900)),
                    Text(entry.club.shortName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 7, color: AppColors.muted)),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${entry.player.stats.goals}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                  const Text('GOLS', style: TextStyle(fontSize: 6, color: AppColors.muted, fontWeight: FontWeight.w800)),
                ],
              ),
            ],
          ),
        ),
      );
}

