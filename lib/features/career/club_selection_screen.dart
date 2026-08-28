import 'package:flutter/material.dart';

import '../../app/widgets/common.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/club_seed.dart';
import '../../data/competition_catalog.dart';
import '../../data/country_catalog.dart';
import '../../domain/club/club.dart';
import '../../domain/club/club_identity.dart';
import '../../domain/player/player.dart';
import '../../game/club/club_identity_engine.dart';
import '../../game/club/club_rating_calculator.dart';
import 'competition_browser_widgets.dart';

class ClubSelectionStep extends StatefulWidget {
  const ClubSelectionStep({
    super.key,
    required this.selectedId,
    required this.onSelected,
    this.identityPack,
  });

  final String? selectedId;
  final ValueChanged<String> onSelected;
  final ClubIdentityPack? identityPack;

  @override
  State<ClubSelectionStep> createState() => _ClubSelectionStepState();
}

class _ClubSelectionStepState extends State<ClubSelectionStep> {
  CompetitionBrowserLevel _level = CompetitionBrowserLevel.country;

  @override
  Widget build(BuildContext context) {
    final country = CompetitionCatalog.brazil;
    final championship = country.championships.first;
    final series = championship.series.first;
    final identities = widget.identityPack == null
        ? const <String, ClubIdentity>{}
        : {for (final item in widget.identityPack!.clubs) item.clubId: item};
    final entries = clubSeeds
        .where((seed) => series.clubIds.contains(seed.id))
        .map((seed) {
          final base = seed.toClub();
          final identity = identities[base.id];
          final club = identity == null
              ? base
              : ClubIdentityEngine.applyIdentityToClub(base, identity);
          final overall = ClubRatingCalculator.squadOverall(
            identity?.players ?? const <Player>[],
            fallback: club.reputation,
          );
          return _ClubChoice(club: club, overall: overall);
        })
        .toList(growable: false);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _level == CompetitionBrowserLevel.clubs
                      ? 'Escolha o clube que você vai liderar'
                      : 'Escolha a competição',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  'País > Campeonato > Série > Clubes',
                  style: TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 12),
                CompetitionBreadcrumb(
                  level: _level,
                  country: country.name,
                  championship: championship.name,
                  series: series.name,
                  onNavigate: (level) => setState(() => _level = level),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        if (_level != CompetitionBrowserLevel.clubs)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
            sliver: SliverToBoxAdapter(
              child: switch (_level) {
                CompetitionBrowserLevel.country => CompetitionStageTile(
                    icon: Icons.public_rounded,
                    title: CountryCatalog.labelOf(country.name),
                    subtitle: 'País disponível',
                    onTap: () => setState(() => _level = CompetitionBrowserLevel.championship),
                  ),
                CompetitionBrowserLevel.championship => CompetitionStageTile(
                    icon: Icons.emoji_events_outlined,
                    title: championship.name,
                    subtitle: '${championship.series.length} série disponível',
                    onTap: () => setState(() => _level = CompetitionBrowserLevel.series),
                  ),
                CompetitionBrowserLevel.series => CompetitionStageTile(
                    icon: Icons.sports_soccer_rounded,
                    title: series.name,
                    subtitle: '${entries.length} clubes',
                    onTap: () => setState(() => _level = CompetitionBrowserLevel.clubs),
                  ),
                CompetitionBrowserLevel.clubs => const SizedBox.shrink(),
              },
            ),
          )
        else ...[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  const Icon(Icons.sports_soccer_rounded, size: 18, color: AppColors.green),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      '${series.name.toUpperCase()} • CLUBES',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  Text('${entries.length} equipes', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 9,
                mainAxisSpacing: 9,
                mainAxisExtent: 94,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final entry = entries[index];
                  final selected = widget.selectedId == entry.club.id;
                  return _ClubSelectionCard(
                    club: entry.club,
                    overall: entry.overall,
                    selected: selected,
                    onTap: () => widget.onSelected(entry.club.id),
                  );
                },
                childCount: entries.length,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ClubSelectionCard extends StatelessWidget {
  const _ClubSelectionCard({
    required this.club,
    required this.overall,
    required this.selected,
    required this.onTap,
  });

  final Club club;
  final int overall;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final stars = ClubRatingCalculator.starsForOverall(overall);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SectionCard(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 7),
        borderColor: selected ? AppColors.green : null,
        child: Column(
          children: [
            Row(
              children: [
                ClubBadge(club: club, size: 42),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    club.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 11.5,
                      height: 1.08,
                    ),
                  ),
                ),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.chevron_right_rounded,
                  size: 16,
                  color: selected ? AppColors.green : AppColors.muted,
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Text(
                  'OVR $overall',
                  style: const TextStyle(
                    color: AppColors.green,
                    fontWeight: FontWeight.w900,
                    fontSize: 10.5,
                  ),
                ),
                const SizedBox(width: 4),
                _RatingStars(stars: stars),
              ],
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                const Text(
                  'ORÇ.',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      formatMoney(club.transferBudget),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingStars extends StatelessWidget {
  const _RatingStars({required this.stars});

  final double stars;

  @override
  Widget build(BuildContext context) => Semantics(
        label: '${stars.toStringAsFixed(stars % 1 == 0 ? 0 : 1)} estrelas',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final position = index + 1;
            final icon = stars >= position
                ? Icons.star_rounded
                : stars >= position - .5
                    ? Icons.star_half_rounded
                    : Icons.star_border_rounded;
            return Icon(icon, size: 10.5, color: AppColors.warning);
          }),
        ),
      );
}

class _ClubChoice {
  const _ClubChoice({required this.club, required this.overall});

  final Club club;
  final int overall;
}
