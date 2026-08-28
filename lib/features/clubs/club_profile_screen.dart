import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/widgets/common.dart';
import '../../app/widgets/player_card.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/competition_catalog.dart';
import '../../domain/club/club.dart';
import '../../domain/match/match_models.dart';
import '../calendar/calendar_screen.dart';
import '../player/player_profile_screen.dart';

class ClubProfileScreen extends ConsumerWidget {
  const ClubProfileScreen({super.key, required this.clubId});
  final String clubId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final career = ref.watch(gameControllerProvider).career!;
    final club = career.clubs.firstWhere((item) => item.id == clubId);
    final squad = [...club.squad]..sort((a, b) => b.overall.compareTo(a.overall));
    final ordered = [...career.standings]
      ..sort((a, b) {
        final points = b.points.compareTo(a.points);
        if (points != 0) return points;
        final gd = b.goalDifference.compareTo(a.goalDifference);
        if (gd != 0) return gd;
        return b.goalsFor.compareTo(a.goalsFor);
      });
    final standingIndex = ordered.indexWhere((item) => item.clubId == club.id);
    final standing = standingIndex < 0 ? null : ordered[standingIndex];
    final fixtures = career.fixtures
        .where((item) => item.homeClubId == club.id || item.awayClubId == club.id)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final recent = fixtures.where((item) => item.played && item.score != null).toList().reversed.take(5).toList().reversed.toList();
    final next = fixtures.where((item) => !item.played && !item.date.isBefore(career.currentDate)).firstOrNull;

    return PremiumScaffold(
      safeBottom: true,
      appBar: GameTopBar(title: club.name, subtitle: club.nickname),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
        children: [
          SectionCard(
            child: Row(
              children: [
                ClubBadge(club: club, size: 72),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(club.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 5),
                      Text('Técnico: ${club.managerName}', style: const TextStyle(color: AppColors.muted)),
                      Text('${club.stadium.name} • ${club.stadium.capacity} lugares', style: const TextStyle(color: AppColors.muted)),
                      if (standing != null)
                        Text(
                          '${standingIndex + 1}º lugar • ${standing.points} pts • SG ${standing.goalDifference >= 0 ? '+' : ''}${standing.goalDifference}',
                          style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w800),
                        ),
                      Text('Caixa ${formatMoney(club.money)}', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SectionCard(
                  padding: const EdgeInsets.all(12),
                  child: _ClubMetric(label: 'Elenco', value: '${club.squad.length}'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SectionCard(
                  padding: const EdgeInsets.all(12),
                  child: _ClubMetric(
                    label: 'Média OVR',
                    value: club.squad.isEmpty
                        ? '—'
                        : '${(club.squad.fold<int>(0, (sum, p) => sum + p.overall) / club.squad.length).round()}',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SectionCard(
                  padding: const EdgeInsets.all(12),
                  child: _ClubMetric(label: 'Forma', value: _formLabel(recent, club.id)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('FORMA E AGENDA', style: TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 9),
                if (recent.isEmpty)
                  Text('Ainda sem partidas concluídas.', style: TextStyle(color: AppColors.muted))
                else
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: recent.map((fixture) => _FormChip(result: _resultLetter(fixture, club.id))).toList(),
                  ),
                const SizedBox(height: 10),
                if (next == null)
                  Text('Nenhuma próxima partida agendada.', style: TextStyle(color: AppColors.muted))
                else
                  InkWell(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CalendarScreen(initialFixtureId: next.id))),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          const Icon(Icons.event_rounded, size: 20, color: AppColors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Próximo: ${_opponentName(career.clubs, next, club.id)} • ${shortDate(next.date)} • ${CompetitionCatalog.displayNameForId(next.competitionId)}',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text('ELENCO', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          for (final player in squad) ...[
            PlayerCard(
              player: player,
              club: club,
              size: PlayerCardSize.compact,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PlayerProfileScreen(playerId: player.id, clubId: club.id),
                ),
              ),
            ),
            const SizedBox(height: 7),
          ],
        ],
      ),
    );
  }

  static String _opponentName(List<Club> clubs, MatchFixture fixture, String clubId) {
    final opponentId = fixture.homeClubId == clubId ? fixture.awayClubId : fixture.homeClubId;
    return clubs.firstWhere((club) => club.id == opponentId).name;
  }

  static String _resultLetter(MatchFixture fixture, String clubId) {
    final score = fixture.score;
    if (score == null) return '—';
    final home = fixture.homeClubId == clubId;
    final own = home ? score.home : score.away;
    final other = home ? score.away : score.home;
    if (own > other) return 'V';
    if (own < other) return 'D';
    return 'E';
  }

  static String _formLabel(List<MatchFixture> fixtures, String clubId) {
    if (fixtures.isEmpty) return '—';
    return fixtures.map((item) => _resultLetter(item, clubId)).join('');
  }
}


class _ClubMetric extends StatelessWidget {
  const _ClubMetric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: AppColors.muted, fontSize: 10)),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      );
}

class _FormChip extends StatelessWidget {
  const _FormChip({required this.result});
  final String result;

  @override
  Widget build(BuildContext context) => Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: result == 'V'
              ? AppColors.green.withValues(alpha: .18)
              : AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(result, style: const TextStyle(fontWeight: FontWeight.w900)),
      );
}
