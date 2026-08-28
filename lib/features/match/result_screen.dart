import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/widgets/common.dart';
import '../../app/widgets/player_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/club/club.dart';
import '../../domain/match/match_models.dart';
import '../../domain/player/player.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key, required this.result});
  final MatchResult result;

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  int _stage = 0;

  @override
  Widget build(BuildContext context) {
    final career = ref.watch(gameControllerProvider).career!;
    final result = widget.result;
    final home = career.clubs.firstWhere((c) => c.id == result.homeClubId);
    final away = career.clubs.firstWhere((c) => c.id == result.awayClubId);
    final fixture = career.fixtures.firstWhere((f) => f.id == result.fixtureId);
    final halftimeScore = _scoreUntil(result.events, 45, home.id, away.id);
    final importantEvents = result.events
        .where(
          (event) => {
            MatchEventType.goal,
            MatchEventType.ownGoal,
            MatchEventType.woodwork,
            MatchEventType.penalty,
            MatchEventType.penaltySaved,
            MatchEventType.yellow,
            MatchEventType.red,
            MatchEventType.injury,
            MatchEventType.substitution,
          }.contains(event.type),
        )
        .toList();
    final unavailable = career.userClub.squad
        .where((player) => !player.isAvailable)
        .toList()
      ..sort((a, b) => a.displayName.compareTo(b.displayName));
    final position = career.standings.indexWhere((row) => row.clubId == career.userClubId) + 1;
    final outcome = _outcome(career.userClubId, result);
    final playersById = <String, Player>{
      for (final player in home.squad) player.id: player,
      for (final player in away.squad) player.id: player,
    };

    return PremiumScaffold(
      appBar: GameTopBar(
        title: 'Resumo da partida',
        subtitle: 'Rodada ${fixture.round} • ${fullDate(fixture.date)}',
      ),
      safeBottom: true,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
        children: [
          SectionCard(
            borderColor: outcome.$2,
            child: Column(
              children: [
                Text(
                  outcome.$1,
                  style: TextStyle(
                    color: outcome.$2,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .8,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          ClubBadge(club: home, size: 68),
                          const SizedBox(height: 8),
                          Text(home.name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                    Text(result.score.display, style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900)),
                    Expanded(
                      child: Column(
                        children: [
                          ClubBadge(club: away, size: 68),
                          const SizedBox(height: 8),
                          Text(away.name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Metric(label: 'Intervalo', value: halftimeScore.display),
                    const SizedBox(width: 10),
                    Metric(label: 'Final', value: result.score.display),
                    const SizedBox(width: 10),
                    Metric(label: 'Posição', value: position > 0 ? '$positionº' : '—'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Resultado')), 
                ButtonSegment(value: 1, label: Text('Estatísticas')),
              ],
              selected: {_stage},
              onSelectionChanged: (selection) => setState(() => _stage = selection.first),
            ),
          ),
          const SizedBox(height: 10),
          if (_stage == 0) ...[
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PRINCIPAIS MOMENTOS',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  if (importantEvents.isEmpty)
                    const Text(
                      'Partida sem grandes ocorrências registradas.',
                      style: TextStyle(color: AppColors.muted),
                    )
                  else
                    ...importantEvents.map(
                      (event) => _ResultMomentTile(
                        event: event,
                        club: event.teamId == home.id ? home : away,
                        player: playersById[event.playerId],
                        secondaryPlayer: playersById[event.secondaryPlayerId],
                      ),
                    ),
                ],
              ),
            ),
          ] else ...[
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ESTATÍSTICAS', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  _ResultStat(label: 'Posse', a: '${result.statistics.homePossession}%', b: '${result.statistics.awayPossession}%'),
                  _ResultStat(label: 'Finalizações', a: '${result.statistics.homeShots}', b: '${result.statistics.awayShots}'),
                  _ResultStat(label: 'No gol', a: '${result.statistics.homeShotsOnTarget}', b: '${result.statistics.awayShotsOnTarget}'),
                  _ResultStat(label: 'Escanteios', a: '${result.statistics.homeCorners}', b: '${result.statistics.awayCorners}'),
                  _ResultStat(label: 'Faltas', a: '${result.statistics.homeFouls}', b: '${result.statistics.awayFouls}'),
                  _ResultStat(label: 'Amarelos', a: '${result.statistics.homeYellow}', b: '${result.statistics.awayYellow}'),
                  _ResultStat(label: 'Vermelhos', a: '${result.statistics.homeRed}', b: '${result.statistics.awayRed}'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SITUAÇÃO DO ELENCO',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  if (unavailable.isEmpty)
                    Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: AppColors.green, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Nenhum jogador indisponível.', style: TextStyle(color: AppColors.muted))),
                      ],
                    )
                  else
                    ...unavailable.take(6).map(
                      (player) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            PlayerAvatar(player: player, size: 32, accentColor: AppColors.warning),
                            const SizedBox(width: 8),
                            Expanded(child: Text(player.displayName, style: const TextStyle(fontWeight: FontWeight.w700))),
                            Text(_availabilityText(player), style: const TextStyle(color: AppColors.warning, fontSize: 11)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.home_rounded),
            label: const Text('Voltar ao clube'),
          ),
          if (_stage == 0) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => setState(() => _stage = 1),
              icon: const Icon(Icons.analytics_rounded),
              label: const Text('Ver estatísticas e elenco'),
            ),
          ],
        ],
      ),
    );
  }

  static (String, Color) _outcome(String userClubId, MatchResult result) {
    final userHome = result.homeClubId == userClubId;
    final userGoals = userHome ? result.score.home : result.score.away;
    final opponentGoals = userHome ? result.score.away : result.score.home;
    if (userGoals > opponentGoals) return ('VITÓRIA', AppColors.green);
    if (userGoals < opponentGoals) return ('DERROTA', AppColors.danger);
    return ('EMPATE', AppColors.warning);
  }

  static MatchScore _scoreUntil(List<MatchEvent> events, int minute, String home, String away) {
    var homeGoals = 0;
    var awayGoals = 0;
    for (final event in events.where(
      (event) =>
          event.minute <= minute &&
          (event.type == MatchEventType.goal || event.type == MatchEventType.ownGoal),
    )) {
      if (event.teamId == home) homeGoals++;
      if (event.teamId == away) awayGoals++;
    }
    return MatchScore(homeGoals, awayGoals);
  }

  static String _availabilityText(Player player) => switch (player.availabilityStatus) {
        PlayerAvailabilityStatus.injured => '${player.injury?.roundsRemaining ?? 1} rod.',
        PlayerAvailabilityStatus.suspended => '${player.discipline.suspendedRounds} rod.',
        PlayerAvailabilityStatus.lowCondition => '${player.condition}% condição',
        PlayerAvailabilityStatus.available => 'Disponível',
      };
}

class _ResultMomentTile extends StatelessWidget {
  const _ResultMomentTile({
    required this.event,
    required this.club,
    this.player,
    this.secondaryPlayer,
  });

  final MatchEvent event;
  final Club club;
  final Player? player;
  final Player? secondaryPlayer;

  @override
  Widget build(BuildContext context) {
    final color = _eventColor(event.type);
    final isSubstitution = event.type == MatchEventType.substitution;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 38,
            child: Text(
              "${event.minute}'",
              style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w900),
            ),
          ),
          if (!isSubstitution)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: player == null
                  ? Icon(_eventIcon(event.type), size: 18, color: color)
                  : PlayerAvatar(player: player!, size: 34, accentColor: color),
            )
          else
            SizedBox(
              width: 42,
              child: Stack(
                children: [
                  if (secondaryPlayer != null)
                    PlayerAvatar(player: secondaryPlayer!, size: 28, accentColor: AppColors.warning),
                  if (player != null)
                    Positioned(
                      left: 14,
                      top: 10,
                      child: PlayerAvatar(player: player!, size: 28, accentColor: AppColors.green),
                    ),
                ],
              ),
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withValues(alpha: .22)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${event.type.label} • ${club.name}',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: color),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _headline,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    event.text,
                    style: const TextStyle(color: AppColors.muted, fontSize: 12, height: 1.3),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _headline {
    if (event.type == MatchEventType.substitution) {
      final enters = player?.displayName ?? 'Jogador';
      final exits = secondaryPlayer?.displayName ?? 'Jogador';
      return 'Entra $enters • sai $exits';
    }
    if (player != null) return player!.displayName;
    return event.type.label;
  }

  static IconData _eventIcon(MatchEventType type) => switch (type) {
        MatchEventType.goal || MatchEventType.ownGoal => Icons.sports_soccer_rounded,
        MatchEventType.woodwork => Icons.vertical_align_center_rounded,
        MatchEventType.yellow || MatchEventType.red => Icons.crop_portrait_rounded,
        MatchEventType.injury => Icons.healing_rounded,
        MatchEventType.penalty || MatchEventType.penaltySaved => Icons.adjust_rounded,
        MatchEventType.substitution => Icons.swap_horiz_rounded,
        _ => Icons.circle_outlined,
      };

  static Color _eventColor(MatchEventType type) => switch (type) {
        MatchEventType.goal || MatchEventType.ownGoal => AppColors.green,
        MatchEventType.woodwork => AppColors.warning,
        MatchEventType.yellow => AppColors.warning,
        MatchEventType.red => AppColors.danger,
        MatchEventType.injury => AppColors.warning,
        MatchEventType.substitution => AppColors.info,
        _ => AppColors.muted,
      };
}

class _ResultStat extends StatelessWidget {
  const _ResultStat({required this.label, required this.a, required this.b});
  final String label;
  final String a;
  final String b;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            SizedBox(width: 48, child: Text(a, style: const TextStyle(fontWeight: FontWeight.w900))),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted),
              ),
            ),
            SizedBox(
              width: 48,
              child: Text(b, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      );
}
