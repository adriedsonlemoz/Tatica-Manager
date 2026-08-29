import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/widgets/common.dart';
import '../../core/theme/app_colors.dart';
import '../../data/competition_catalog.dart';
import '../../game/club/club_rating_calculator.dart';
import '../career/competition_browser_widgets.dart';
import 'club_profile_screen.dart';

class ClubsScreen extends ConsumerStatefulWidget {
  const ClubsScreen({super.key});

  @override
  ConsumerState<ClubsScreen> createState() => _ClubsScreenState();
}

class _ClubsScreenState extends ConsumerState<ClubsScreen> {
  CompetitionBrowserLevel level = CompetitionBrowserLevel.country;
  CountryCompetition? country;
  ChampionshipCompetition? championship;
  CompetitionSeries? series;

  @override
  Widget build(BuildContext context) {
    final career = ref.watch(gameControllerProvider).career!;
    return PremiumScaffold(
      safeBottom: true,
      appBar: const GameTopBar(
        title: 'Clubes',
        subtitle: 'País • campeonato • série • clubes',
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
        children: [
          CompetitionBreadcrumb(
            level: level,
            country: country?.name ?? 'Brasil',
            championship: championship?.name ?? 'Campeonato',
            series: series?.name ?? 'Série',
            onNavigate: _navigate,
          ),
          const SizedBox(height: 10),
          if (level == CompetitionBrowserLevel.country)
            for (final item in CompetitionCatalog.countries)
              CompetitionStageTile(
                icon: Icons.public_rounded,
                title: '${item.code == 'BR' ? '🇧🇷 ' : ''}${item.name}',
                subtitle: '${item.championships.length} campeonato(s)',
                onTap: () => setState(() {
                  country = item;
                  level = CompetitionBrowserLevel.championship;
                }),
              )
          else if (level == CompetitionBrowserLevel.championship)
            for (final item in country!.championships)
              CompetitionStageTile(
                icon: Icons.emoji_events_outlined,
                title: item.name,
                subtitle: '${item.series.length} série(s)',
                onTap: () => setState(() {
                  championship = item;
                  level = CompetitionBrowserLevel.series;
                }),
              )
          else if (level == CompetitionBrowserLevel.series)
            for (final item in championship!.series)
              CompetitionStageTile(
                icon: Icons.format_list_numbered_rounded,
                title: item.name,
                subtitle: '${item.clubIds.length} clubes',
                onTap: () => setState(() {
                  series = item;
                  level = CompetitionBrowserLevel.clubs;
                }),
              )
          else
            for (final club in career.clubs.where(
              (club) => series!.clubIds.contains(club.id),
            ))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SectionCard(
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    leading: ClubBadge(club: club, size: 42),
                    title: Text(
                      club.name,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text(
                      '${club.stadium.name} • elenco ${club.squad.length}',
                      style:  TextStyle(color: AppColors.muted),
                    ),
                    trailing: Text(
                      '${ClubRatingCalculator.squadOverall(club.squad, fallback: club.reputation)} OVR',
                      style: const TextStyle(
                        color: AppColors.green,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ClubProfileScreen(clubId: club.id),
                      ),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  void _navigate(CompetitionBrowserLevel target) {
    setState(() {
      level = target;
      if (target.index < CompetitionBrowserLevel.clubs.index) series = null;
      if (target.index < CompetitionBrowserLevel.series.index) {
        championship = null;
      }
      if (target.index < CompetitionBrowserLevel.championship.index) {
        country = null;
      }
    });
  }
}
