import 'package:flutter/material.dart';

import '../../app/widgets/common.dart';
import '../../app/widgets/player_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/club/club.dart';
import '../../domain/league/standing.dart';
import '../../domain/match/match_models.dart';
import '../../domain/season/career_event.dart';
import 'home_dashboard_rankings.dart';

class HomeCleanNextMatch extends StatelessWidget {
  const HomeCleanNextMatch({
    super.key,
    required this.club,
    required this.opponent,
    required this.fixture,
    required this.competitionName,
    required this.onTap,
  });

  final Club club;
  final Club? opponent;
  final MatchFixture? fixture;
  final String competitionName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => _CleanSectionCard(
        title: 'PRÓXIMA PARTIDA',
        onTap: onTap,
        child: fixture == null || opponent == null
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Text('Temporada concluída', style: TextStyle(color: AppColors.muted)),
              )
            : Row(
                children: [
                  Expanded(child: _ClubSide(club: club)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('X', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
                  ),
                  Expanded(child: _ClubSide(club: opponent!)),
                  Container(width: 1, height: 94, color: AppColors.border, margin: const EdgeInsets.symmetric(horizontal: 12)),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoLine(icon: Icons.emoji_events_outlined, text: competitionName),
                        const SizedBox(height: 11),
                        _InfoLine(icon: Icons.calendar_month_outlined, text: '${shortDate(fixture!.date)} • ${fixture!.kickoffLabel}'),
                        const SizedBox(height: 11),
                        _InfoLine(icon: Icons.stadium_outlined, text: club.stadium.name),
                      ],
                    ),
                  ),
                ],
              ),
      );
}

class HomeCleanSeasonSummary extends StatelessWidget {
  const HomeCleanSeasonSummary({super.key, required this.standing});
  final Standing? standing;

  @override
  Widget build(BuildContext context) {
    final s = standing;
    final values = <({IconData icon, String value, String label, Color? color})>[
      (icon: Icons.emoji_events_outlined, value: '${s?.played ?? 0}', label: 'Jogos', color: null),
      (icon: Icons.check_circle_rounded, value: '${s?.wins ?? 0}', label: 'Vitórias', color: AppColors.green),
      (icon: Icons.remove_circle_rounded, value: '${s?.draws ?? 0}', label: 'Empates', color: AppColors.muted),
      (icon: Icons.cancel_rounded, value: '${s?.losses ?? 0}', label: 'Derrotas', color: AppColors.danger),
      (icon: Icons.sports_soccer_rounded, value: '${s?.goalsFor ?? 0}', label: 'Gols marcados', color: null),
      (icon: Icons.shield_outlined, value: '${s?.goalsAgainst ?? 0}', label: 'Gols sofridos', color: null),
    ];
    return _CleanSectionCard(
      title: 'RESUMO DA TEMPORADA',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < values.length; i++) ...[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 1),
                child: Column(
                  children: [
                    Icon(
                      values[i].icon,
                      color: values[i].color ?? AppColors.muted,
                      size: 20,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      values[i].value,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 1),
                    SizedBox(
                      height: 24,
                      child: Center(
                        child: Text(
                          values[i].label,
                          maxLines: 2,
                          overflow: TextOverflow.fade,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 8.4,
                            height: 1.05,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (i < values.length - 1)
              Container(width: 1, height: 70, color: AppColors.border),
          ],
        ],
      ),
    );
  }
}

class HomeCleanRankings extends StatelessWidget {
  const HomeCleanRankings({
    super.key,
    required this.standings,
    required this.clubs,
    required this.userClubId,
    required this.scorers,
    required this.onClubTap,
    required this.onPlayerTap,
    required this.onStandingsTap,
    required this.onScorersTap,
  });

  final List<Standing> standings;
  final List<Club> clubs;
  final String userClubId;
  final List<HomeScorerEntry> scorers;
  final ValueChanged<String> onClubTap;
  final ValueChanged<HomeScorerEntry> onPlayerTap;
  final VoidCallback onStandingsTap;
  final VoidCallback onScorersTap;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final split = constraints.maxWidth >= 315;
          final table = _RankingCard(
            title: 'CLASSIFICAÇÃO',
            action: 'Ver tabela completa',
            onAction: onStandingsTap,
            child: Column(
              children: [
                _StandingHeader(),
                for (var i = 0; i < standings.length && i < 4; i++)
                  _StandingRow(
                    position: i + 1,
                    standing: standings[i],
                    club: clubs.where((c) => c.id == standings[i].clubId).firstOrNull,
                    highlight: standings[i].clubId == userClubId,
                    onTap: () => onClubTap(standings[i].clubId),
                  ),
              ],
            ),
          );
          final scorer = _RankingCard(
            title: 'ARTILHARIA',
            action: 'Ver artilharia completa',
            onAction: onScorersTap,
            child: scorers.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text('Ainda não há gols.', style: TextStyle(color: AppColors.muted)),
                  )
                : Column(
                    children: [
                      for (var i = 0; i < scorers.length && i < 3; i++)
                        _ScorerRow(entry: scorers[i], onTap: () => onPlayerTap(scorers[i])),
                    ],
                  ),
          );
          if (!split) return Column(children: [table, const SizedBox(height: 12), scorer]);
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: table),
                const SizedBox(width: 12),
                Expanded(child: scorer),
              ],
            ),
          );
        },
      );
}

class HomeCleanNews extends StatelessWidget {
  const HomeCleanNews({
    super.key,
    required this.events,
    required this.onEventTap,
    required this.onViewAll,
  });

  final List<CareerEvent> events;
  final ValueChanged<CareerEvent> onEventTap;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) => _CleanSectionCard(
        title: 'NOTÍCIAS E DESTAQUES',
        actionLabel: 'Ver todas',
        onAction: onViewAll,
        child: events.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text('Nenhuma notícia recente.', style: TextStyle(color: AppColors.muted)),
              )
            : Column(
                children: [
                  for (var i = 0; i < events.length && i < 3; i++) ...[
                    InkWell(
                      onTap: () => onEventTap(events[i]),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        child: Row(
                          children: [
                            Icon(Icons.article_outlined, size: 20, color: AppColors.muted),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                events[i].message,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (i < events.length - 1 && i < 2) Divider(height: 1, color: AppColors.border),
                  ],
                ],
              ),
      );
}

class _CleanSectionCard extends StatelessWidget {
  const _CleanSectionCard({
    required this.title,
    required this.child,
    this.actionLabel,
    this.onAction,
    this.onTap,
  });
  final String title;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: AppColors.isDarkMode ? .16 : .055),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: const TextStyle(color: AppColors.green, fontSize: 13, fontWeight: FontWeight.w900)),
              ),
              if (actionLabel != null)
                TextButton(
                  onPressed: onAction,
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact, padding: const EdgeInsets.symmetric(horizontal: 6)),
                  child: Text(actionLabel!, style: const TextStyle(color: AppColors.green, fontSize: 10.5, fontWeight: FontWeight.w800)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(13), child: card),
    );
  }
}

class _ClubSide extends StatelessWidget {
  const _ClubSide({required this.club});
  final Club club;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          ClubBadge(club: club, size: 58),
          const SizedBox(height: 6),
          Text(
            club.shortName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
          ),
        ],
      );
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 18, color: AppColors.muted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
          ),
        ],
      );
}

class _RankingCard extends StatelessWidget {
  const _RankingCard({required this.title, required this.action, required this.onAction, required this.child});
  final String title;
  final String action;
  final VoidCallback onAction;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: AppColors.isDarkMode ? .16 : .05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 11, 12, 7),
              child: Text(title, style: const TextStyle(color: AppColors.green, fontSize: 13, fontWeight: FontWeight.w900)),
            ),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: child),
            const SizedBox(height: 6),
            Divider(height: 1, color: AppColors.border),
            InkWell(
              onTap: onAction,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 9, 8, 9),
                child: Row(
                  children: [
                    Expanded(child: Text(action, style: TextStyle(fontSize: 10.5, color: AppColors.muted))),
                    Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.muted),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}

class _StandingHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            SizedBox(width: 20, child: Text('#', style: TextStyle(fontSize: 9, color: AppColors.muted))),
            Expanded(child: Text('TIME', style: TextStyle(fontSize: 9, color: AppColors.muted))),
            SizedBox(width: 26, child: Text('J', textAlign: TextAlign.center, style: TextStyle(fontSize: 9, color: AppColors.muted))),
            SizedBox(width: 30, child: Text('PTS', textAlign: TextAlign.end, style: TextStyle(fontSize: 9, color: AppColors.muted))),
          ],
        ),
      );
}

class _StandingRow extends StatelessWidget {
  const _StandingRow({required this.position, required this.standing, required this.club, required this.highlight, required this.onTap});
  final int position;
  final Standing standing;
  final Club? club;
  final bool highlight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          color: highlight ? AppColors.green.withValues(alpha: .07) : Colors.transparent,
          child: Row(
            children: [
              SizedBox(width: 20, child: Text('$position', style: const TextStyle(fontSize: 10.5))),
              if (club != null) ...[
                ClubBadge(club: club!, size: 24),
                const SizedBox(width: 5),
              ],
              Expanded(
                child: Text(
                  standing.clubName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10.3, fontWeight: highlight ? FontWeight.w900 : FontWeight.w600),
                ),
              ),
              SizedBox(width: 26, child: Text('${standing.played}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 10))),
              SizedBox(width: 30, child: Text('${standing.points}', textAlign: TextAlign.end, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: highlight ? AppColors.green : null))),
            ],
          ),
        ),
      );
}

class _ScorerRow extends StatelessWidget {
  const _ScorerRow({required this.entry, required this.onTap});
  final HomeScorerEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              PlayerAvatar(player: entry.player, size: 38, accentColor: AppColors.readableAccent(Color(entry.club.colors.primaryHex))),
              const SizedBox(width: 7),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.player.displayName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10.8, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 1),
                    Text(entry.club.shortName, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9.5, color: AppColors.muted)),
                  ],
                ),
              ),
              Text('${entry.stats.goals}', style: const TextStyle(color: AppColors.green, fontSize: 18, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      );
}
