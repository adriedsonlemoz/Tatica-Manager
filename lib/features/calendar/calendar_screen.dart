import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/widgets/common.dart';
import '../../app/widgets/player_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/competition_catalog.dart';
import '../../domain/match/match_models.dart';
import '../player/player_profile_screen.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key, this.initialFixtureId});

  final String? initialFixtureId;

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime? _visibleMonth;
  DateTime? _selectedDate;
  bool _openedInitialFixture = false;

  @override
  Widget build(BuildContext context) {
    final career = ref.watch(gameControllerProvider).career!;
    final initialFixture = widget.initialFixtureId == null
        ? null
        : career.fixtures.where((item) => item.id == widget.initialFixtureId).firstOrNull;
    _visibleMonth ??= initialFixture == null
        ? DateTime(career.currentDate.year, career.currentDate.month)
        : DateTime(initialFixture.date.year, initialFixture.date.month);
    _selectedDate ??= initialFixture?.date ?? career.currentDate;
    if (initialFixture != null && !_openedInitialFixture) {
      _openedInitialFixture = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showFixtureDetails(context, initialFixture);
      });
    }
    final month = _visibleMonth!;
    final userFixtures = career.fixtures
        .where((fixture) =>
            fixture.homeClubId == career.userClubId ||
            fixture.awayClubId == career.userClubId)
        .toList();
    final monthFixtures = userFixtures
        .where((fixture) =>
            fixture.date.year == month.year && fixture.date.month == month.month)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final selectedFixtures = monthFixtures
        .where((fixture) => _sameDay(fixture.date, _selectedDate!))
        .toList();
    final displayedFixtures = selectedFixtures.isNotEmpty
        ? selectedFixtures
        : monthFixtures;

    return PremiumScaffold(
      appBar: GameTopBar(
        title: 'Calendário',
        subtitle: '${CompetitionCatalog.displayNameForId(userFixtures.firstOrNull?.competitionId ?? 'br-series-a')} • ${career.season}',
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
        children: [
          SectionCard(
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Mês anterior',
                      onPressed: () => setState(() {
                        _visibleMonth = DateTime(month.year, month.month - 1);
                        _selectedDate = DateTime(month.year, month.month - 1, 1);
                      }),
                      icon: const Icon(Icons.chevron_left_rounded),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            _monthTitle(month),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          Text(
                            'Hoje: ${fullDate(career.currentDate)}',
                            style: TextStyle(color: AppColors.muted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Próximo mês',
                      onPressed: () => setState(() {
                        _visibleMonth = DateTime(month.year, month.month + 1);
                        _selectedDate = DateTime(month.year, month.month + 1, 1);
                      }),
                      icon: const Icon(Icons.chevron_right_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    _Weekday('SEG'),
                    _Weekday('TER'),
                    _Weekday('QUA'),
                    _Weekday('QUI'),
                    _Weekday('SEX'),
                    _Weekday('SÁB'),
                    _Weekday('DOM'),
                  ],
                ),
                const SizedBox(height: 6),
                _MonthGrid(
                  month: month,
                  currentDate: career.currentDate,
                  selectedDate: _selectedDate!,
                  fixtures: monthFixtures,
                  onSelected: (date) => setState(() => _selectedDate = date),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.sports_soccer_rounded, color: AppColors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        selectedFixtures.isNotEmpty
                            ? 'PARTIDAS EM ${shortDate(_selectedDate!)}'
                            : 'PARTIDAS DE ${_monthTitle(month).toUpperCase()}',
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ),
                    Text(
                      '${displayedFixtures.length}',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (displayedFixtures.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Nenhuma partida do seu clube neste mês.',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  )
                else
                  ...displayedFixtures.map(
                    (fixture) => _FixtureTile(
                      fixture: fixture,
                      currentDate: career.currentDate,
                      homeName: career.clubs
                          .firstWhere((club) => club.id == fixture.homeClubId)
                          .name,
                      awayName: career.clubs
                          .firstWhere((club) => club.id == fixture.awayClubId)
                          .name,
                      onTap: () => _showFixtureDetails(context, fixture),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showFixtureDetails(
    BuildContext context,
    MatchFixture fixture,
  ) async {
    final career = ref.read(gameControllerProvider).career!;
    final home = career.clubs.firstWhere((club) => club.id == fixture.homeClubId);
    final away = career.clubs.firstWhere((club) => club.id == fixture.awayClubId);
    final result = career.matchHistory
        .where((match) => match.fixtureId == fixture.id)
        .firstOrNull;
    final importantEvents = result?.events
            .where((event) => {
                  MatchEventType.goal,
                  MatchEventType.ownGoal,
                  MatchEventType.woodwork,
                  MatchEventType.yellow,
                  MatchEventType.red,
                  MatchEventType.penalty,
                  MatchEventType.penaltySaved,
                  MatchEventType.injury,
                  MatchEventType.substitution,
                }.contains(event.type))
            .toList() ??
        const <MatchEvent>[];

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_month_rounded, color: AppColors.green),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rodada ${fixture.round}',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          Text(
                            '${CompetitionCatalog.displayNameForId(fixture.competitionId)} • ${calendarDate(fixture.date)} • ${fixture.kickoffLabel}',
                            style: TextStyle(color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          ClubBadge(club: home, size: 58),
                          const SizedBox(height: 7),
                          Text(
                            home.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        fixture.score?.display ?? 'VS',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          ClubBadge(club: away, size: 58),
                          const SizedBox(height: 7),
                          Text(
                            away.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  '${home.stadium.name} • ${fixture.played ? 'Partida finalizada' : _sameDay(fixture.date, career.currentDate) ? 'Jogo de hoje' : 'Partida agendada'}',
                  style: TextStyle(color: AppColors.muted),
                ),
                if (result != null) ...[
                  const SizedBox(height: 14),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'ESTATÍSTICAS',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  _DetailStat(
                    label: 'Posse',
                    home: '${result.statistics.homePossession}%',
                    away: '${result.statistics.awayPossession}%',
                  ),
                  _DetailStat(
                    label: 'Finalizações',
                    home: '${result.statistics.homeShots}',
                    away: '${result.statistics.awayShots}',
                  ),
                  _DetailStat(
                    label: 'No alvo',
                    home: '${result.statistics.homeShotsOnTarget}',
                    away: '${result.statistics.awayShotsOnTarget}',
                  ),
                  _DetailStat(
                    label: 'Escanteios',
                    home: '${result.statistics.homeCorners}',
                    away: '${result.statistics.awayCorners}',
                  ),
                  _DetailStat(
                    label: 'Faltas',
                    home: '${result.statistics.homeFouls}',
                    away: '${result.statistics.awayFouls}',
                  ),
                  _DetailStat(
                    label: 'Cartões',
                    home:
                        '${result.statistics.homeYellow}A / ${result.statistics.homeRed}V',
                    away:
                        '${result.statistics.awayYellow}A / ${result.statistics.awayRed}V',
                  ),
                  if (importantEvents.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'ACONTECIMENTOS',
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 7),
                    ...importantEvents.take(14).map((event) {
                      final club = event.teamId == home.id ? home : away;
                      final playerOwner = event.playerId == null
                          ? null
                          : career.clubs
                              .where(
                                (candidate) => candidate.squad.any(
                                  (item) => item.id == event.playerId,
                                ),
                              )
                              .firstOrNull;
                      final player = playerOwner?.squad
                          .where((item) => item.id == event.playerId)
                          .firstOrNull;
                      final assistOwner = event.assistPlayerId == null
                          ? null
                          : career.clubs
                              .where(
                                (candidate) => candidate.squad.any(
                                  (item) => item.id == event.assistPlayerId,
                                ),
                              )
                              .firstOrNull;
                      final assist = assistOwner?.squad
                          .where((item) => item.id == event.assistPlayerId)
                          .firstOrNull;
                      return InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: player == null
                            ? null
                            : () {
                                Navigator.of(dialogContext).pop();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => PlayerProfileScreen(
                                      playerId: player.id,
                                      clubId: playerOwner!.id,
                                    ),
                                  ),
                                );
                              },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (player != null)
                                PlayerAvatar(player: player, size: 36)
                              else
                                const SizedBox(
                                  width: 36,
                                  height: 36,
                                  child: Icon(Icons.sports_soccer_rounded, size: 20),
                                ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${event.minute}' • ${event.type.label} • ${club.name}",
                                      style: const TextStyle(fontWeight: FontWeight.w900),
                                    ),
                                    Text(
                                      player?.displayName ?? event.text,
                                      style: const TextStyle(fontWeight: FontWeight.w700),
                                    ),
                                    if (assist != null)
                                      Text(
                                        'Assistência: ${assist.displayName}',
                                        style: TextStyle(color: AppColors.muted, fontSize: 11),
                                      )
                                    else if (player != null && event.text.isNotEmpty)
                                      Text(
                                        event.text,
                                        style: TextStyle(color: AppColors.muted, fontSize: 11),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ] else if (fixture.played) ...[
                  const SizedBox(height: 12),
                  Text(
                    'O placar deste jogo está salvo. Detalhes avançados ficam disponíveis para partidas disputadas a partir desta versão.',
                    style: TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String _monthTitle(DateTime date) {
    const names = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return '${names[date.month - 1]} ${date.year}';
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.currentDate,
    required this.selectedDate,
    required this.fixtures,
    required this.onSelected,
  });

  final DateTime month;
  final DateTime currentDate;
  final DateTime selectedDate;
  final List<MatchFixture> fixtures;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final days = DateTime(month.year, month.month + 1, 0).day;
    final offset = first.weekday - 1;
    final cells = ((offset + days + 6) ~/ 7) * 7;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
        childAspectRatio: .9,
      ),
      itemCount: cells,
      itemBuilder: (context, index) {
        final dayNumber = index - offset + 1;
        if (dayNumber < 1 || dayNumber > days) return const SizedBox.shrink();
        final date = DateTime(month.year, month.month, dayNumber);
        final isCurrent = _sameDay(date, currentDate);
        final selected = _sameDay(date, selectedDate);
        final dayFixtures = fixtures.where((fixture) => _sameDay(fixture.date, date));
        final hasMatch = dayFixtures.isNotEmpty;
        final hasPlayed = dayFixtures.any((fixture) => fixture.played);
        return InkWell(
          borderRadius: BorderRadius.circular(11),
          onTap: () => onSelected(date),
          child: Container(
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.green.withValues(alpha: .18)
                  : isCurrent
                      ? AppColors.surfaceRaised
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: selected
                    ? AppColors.green
                    : isCurrent
                        ? AppColors.green.withValues(alpha: .45)
                        : AppColors.border.withValues(alpha: .55),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$dayNumber',
                  style: TextStyle(
                    fontWeight: selected || isCurrent
                        ? FontWeight.w900
                        : FontWeight.w600,
                    color: selected ? AppColors.green : Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                if (hasMatch)
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: hasPlayed ? AppColors.muted : AppColors.green,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _Weekday extends StatelessWidget {
  const _Weekday(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.muted,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
}

class _FixtureTile extends StatelessWidget {
  const _FixtureTile({
    required this.fixture,
    required this.currentDate,
    required this.homeName,
    required this.awayName,
    required this.onTap,
  });

  final MatchFixture fixture;
  final DateTime currentDate;
  final String homeName;
  final String awayName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final today = _sameDay(fixture.date, currentDate);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: today
                    ? AppColors.green.withValues(alpha: .16)
                    : AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${fixture.round}',
                style: TextStyle(
                  color: today ? AppColors.green : Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$homeName  ${fixture.score?.display ?? 'vs'}  $awayName',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${fullDate(fixture.date)} • ${fixture.kickoffLabel} • ${fixture.played ? 'Finalizado' : today ? 'Hoje' : 'Agendado'}',
                    style: TextStyle(
                      color: today ? AppColors.green : AppColors.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
             Icon(Icons.chevron_right_rounded, color: AppColors.muted),
          ],
        ),
      ),
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DetailStat extends StatelessWidget {
  const _DetailStat({required this.label, required this.home, required this.away});

  final String label;
  final String home;
  final String away;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(width: 58, child: Text(home, style: const TextStyle(fontWeight: FontWeight.w900))),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted),
              ),
            ),
            SizedBox(
              width: 58,
              child: Text(
                away,
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      );
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
