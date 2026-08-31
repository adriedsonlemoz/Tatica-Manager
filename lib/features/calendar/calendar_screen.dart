import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/widgets/common.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/competition_catalog.dart';
import '../../domain/club/club.dart';
import '../../domain/match/match_models.dart';
import '../../domain/season/career_event.dart';
import '../../domain/season/career_state.dart';
import '../shared/club_context_header.dart';

enum _CalendarTab { month, agenda, results }

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key, this.initialFixtureId});

  final String? initialFixtureId;

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime? _visibleMonth;
  DateTime? _selectedDate;
  String? _competitionId;
  _CalendarTab _tab = _CalendarTab.month;
  int _listPage = 0;
  bool _openedInitialFixture = false;

  @override
  Widget build(BuildContext context) {
    final career = ref.watch(gameControllerProvider).career!;
    final initialFixture = widget.initialFixtureId == null
        ? null
        : career.fixtures
            .where((fixture) => fixture.id == widget.initialFixtureId)
            .firstOrNull;
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

    final allUserFixtures = career.fixtures
        .where(
          (fixture) =>
              fixture.homeClubId == career.userClubId ||
              fixture.awayClubId == career.userClubId,
        )
        .toList();
    final competitionIds = allUserFixtures
        .map((fixture) => fixture.competitionId)
        .toSet()
        .toList()
      ..sort();
    final userFixtures = allUserFixtures
        .where(
          (fixture) =>
              _competitionId == null ||
              fixture.competitionId == _competitionId,
        )
        .toList();
    final club = career.clubs
        .where((candidate) => candidate.id == career.userClubId)
        .firstOrNull;

    return PremiumScaffold(
      appBar: GameTopBar(
        title: 'Calendário',
        actions: [
          if (competitionIds.length > 1)
            IconButton(
              tooltip: 'Filtrar competição',
              onPressed: () => _showCompetitionFilter(context, competitionIds),
              icon: Icon(
                Icons.filter_alt_outlined,
                color: _competitionId == null
                    ? AppColors.white
                    : AppColors.green,
              ),
            ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => Padding(
          padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: constraints.maxWidth - 20,
              height: 696,
              child: Column(
                children: [
                  ClubContextHeader(club: club, season: career.season),
                  const SizedBox(height: 8),
                  _CalendarTabs(
                    value: _tab,
                    onChanged: (value) => setState(() {
                      _tab = value;
                      _listPage = 0;
                    }),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: switch (_tab) {
                      _CalendarTab.month => _buildMonthView(
                          context,
                          career,
                          userFixtures,
                        ),
                      _CalendarTab.agenda => _buildFixtureBoard(
                          context,
                          career,
                          userFixtures
                              .where(
                                (fixture) =>
                                    !fixture.played &&
                                    !fixture.date.isBefore(career.currentDate),
                              )
                              .toList()
                            ..sort((a, b) => a.date.compareTo(b.date)),
                          emptyText: 'Nenhum compromisso futuro.',
                          title: 'PRÓXIMOS COMPROMISSOS',
                        ),
                      _CalendarTab.results => _buildFixtureBoard(
                          context,
                          career,
                          userFixtures.where((fixture) => fixture.played).toList()
                            ..sort((a, b) => b.date.compareTo(a.date)),
                          emptyText: 'Nenhum resultado registrado.',
                          title: 'RESULTADOS',
                        ),
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthView(
    BuildContext context,
    CareerState career,
    List<MatchFixture> userFixtures,
  ) {
    final month = _visibleMonth!;
    final monthFixtures = userFixtures
        .where(
          (fixture) =>
              fixture.date.year == month.year &&
              fixture.date.month == month.month,
        )
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final monthEvents = career.news
        .where(
          (event) =>
              event.date.year == month.year && event.date.month == month.month,
        )
        .toList();
    final selectedFixtures = userFixtures
        .where((fixture) => _sameDay(fixture.date, _selectedDate!))
        .toList();
    final selectedEvents = career.news
        .where((event) => _sameDay(event.date, _selectedDate!))
        .where((event) => event.type != CareerEventType.nextMatch)
        .toList();
    final nextFixtures = userFixtures
        .where(
          (fixture) =>
              !fixture.played && !fixture.date.isBefore(career.currentDate),
        )
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final showSelected = selectedFixtures.isNotEmpty || selectedEvents.isNotEmpty;

    return Column(
      children: [
        SectionCard(
          padding: const EdgeInsets.fromLTRB(8, 7, 8, 8),
          child: Column(
            children: [
              SizedBox(
                height: 34,
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Mês anterior',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _changeMonth(-1),
                      icon: const Icon(Icons.chevron_left_rounded),
                    ),
                    Expanded(
                      child: Text(
                        _monthTitle(month),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Próximo mês',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _changeMonth(1),
                      icon: const Icon(Icons.chevron_right_rounded),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              const SizedBox(height: 5),
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
              const SizedBox(height: 4),
              SizedBox(
                height: 214,
                child: _MonthGrid(
                  month: month,
                  currentDate: career.currentDate,
                  selectedDate: _selectedDate!,
                  fixtures: userFixtures,
                  events: career.news,
                  onSelected: (date) => setState(() {
                    _selectedDate = date;
                    if (date.month != month.month || date.year != month.year) {
                      _visibleMonth = DateTime(date.year, date.month);
                    }
                  }),
                ),
              ),
              const SizedBox(height: 6),
              const _CalendarLegend(),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: SectionCard(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  showSelected
                      ? 'COMPROMISSOS DE ${shortDate(_selectedDate!)}'
                      : 'PRÓXIMOS COMPROMISSOS',
                  style: const TextStyle(
                    color: AppColors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Expanded(
                  child: _CommitmentList(
                    career: career,
                    fixtures: showSelected
                        ? selectedFixtures
                        : nextFixtures.take(4).toList(),
                    events: showSelected ? selectedEvents : const [],
                    onFixtureTap: (fixture) =>
                        _showFixtureDetails(context, fixture),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 58,
          child: _MonthSummary(
            matches: monthFixtures.length,
            trainings: monthEvents
                .where((event) => event.type == CareerEventType.training)
                .length,
            events: monthEvents
                .where(
                  (event) =>
                      event.type != CareerEventType.training &&
                      event.type != CareerEventType.nextMatch,
                )
                .length,
          ),
        ),
      ],
    );
  }

  Widget _buildFixtureBoard(
    BuildContext context,
    CareerState career,
    List<MatchFixture> fixtures, {
    required String emptyText,
    required String title,
  }) {
    const pageSize = 6;
    final pageCount = fixtures.isEmpty ? 1 : ((fixtures.length - 1) ~/ pageSize) + 1;
    final page = _listPage.clamp(0, pageCount - 1).toInt();
    final start = page * pageSize;
    final visible = fixtures.skip(start).take(pageSize).toList();
    return SectionCard(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 9),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                title == 'RESULTADOS'
                    ? Icons.emoji_events_outlined
                    : Icons.event_available_outlined,
                size: 20,
                color: AppColors.green,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (pageCount > 1) ...[
                IconButton(
                  tooltip: 'Página anterior',
                  visualDensity: VisualDensity.compact,
                  onPressed: page == 0
                      ? null
                      : () => setState(() => _listPage = page - 1),
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Text('${page + 1}/$pageCount'),
                IconButton(
                  tooltip: 'Próxima página',
                  visualDensity: VisualDensity.compact,
                  onPressed: page + 1 >= pageCount
                      ? null
                      : () => setState(() => _listPage = page + 1),
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ],
          ),
          const Divider(height: 8),
          Expanded(
            child: visible.isEmpty
                ? Center(
                    child: Text(
                      emptyText,
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  )
                : Column(
                    children: [
                      for (final fixture in visible)
                        Expanded(
                          child: _FixtureCommitmentTile(
                            career: career,
                            fixture: fixture,
                            onTap: () =>
                                _showFixtureDetails(context, fixture),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  void _changeMonth(int delta) {
    final current = _visibleMonth!;
    final next = DateTime(current.year, current.month + delta);
    setState(() {
      _visibleMonth = next;
      _selectedDate = DateTime(next.year, next.month, 1);
    });
  }

  Future<void> _showCompetitionFilter(
    BuildContext context,
    List<String> competitionIds,
  ) async {
    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Filtrar competição'),
        contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                _competitionId == null
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: _competitionId == null
                    ? AppColors.green
                    : AppColors.muted,
              ),
              title: const Text('Todas as competições'),
              onTap: () => Navigator.pop(dialogContext, '__all__'),
            ),
            for (final id in competitionIds)
              ListTile(
                leading: Icon(
                  _competitionId == id
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: _competitionId == id
                      ? AppColors.green
                      : AppColors.muted,
                ),
                title: Text(CompetitionCatalog.displayNameForId(id)),
                onTap: () => Navigator.pop(dialogContext, id),
              ),
          ],
        ),
      ),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _competitionId = selected == '__all__' ? null : selected;
      _listPage = 0;
    });
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
            .where(
              (event) => {
                MatchEventType.goal,
                MatchEventType.ownGoal,
                MatchEventType.yellow,
                MatchEventType.red,
                MatchEventType.penalty,
                MatchEventType.penaltySaved,
                MatchEventType.injury,
              }.contains(event.type),
            )
            .take(6)
            .toList() ??
        const <MatchEvent>[];

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_rounded,
                      color: AppColors.green,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            CompetitionCatalog.displayNameForId(
                              fixture.competitionId,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          Text(
                            '${fullDate(fixture.date)} • ${fixture.kickoffLabel}',
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _DialogClub(club: home)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        fixture.score?.display ?? 'VS',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Expanded(child: _DialogClub(club: away)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${home.stadium.name} • Rodada ${fixture.round}',
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
                if (result != null) ...[
                  const Divider(height: 24),
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
                  if (importantEvents.isNotEmpty) ...[
                    const Divider(height: 20),
                    for (final event in importantEvents)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Icon(
                              _matchEventIcon(event.type),
                              size: 16,
                              color: AppColors.green,
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                "${event.minute}' • ${event.text}",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static IconData _matchEventIcon(MatchEventType type) => switch (type) {
        MatchEventType.goal || MatchEventType.ownGoal =>
          Icons.sports_soccer_rounded,
        MatchEventType.yellow || MatchEventType.red => Icons.style_rounded,
        MatchEventType.injury => Icons.healing_rounded,
        _ => Icons.circle,
      };

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

class _CalendarTabs extends StatelessWidget {
  const _CalendarTabs({required this.value, required this.onChanged});

  final _CalendarTab value;
  final ValueChanged<_CalendarTab> onChanged;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 42,
        child: Row(
          children: [
            for (final item in const [
              (_CalendarTab.month, 'Mês'),
              (_CalendarTab.agenda, 'Agenda'),
              (_CalendarTab.results, 'Resultados'),
            ])
              Expanded(
                child: InkWell(
                  onTap: () => onChanged(item.$1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Center(
                          child: Text(
                            item.$2,
                            style: TextStyle(
                              color: value == item.$1
                                  ? AppColors.green
                                  : AppColors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        height: 2,
                        color: value == item.$1
                            ? AppColors.green
                            : AppColors.border,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.currentDate,
    required this.selectedDate,
    required this.fixtures,
    required this.events,
    required this.onSelected,
  });

  final DateTime month;
  final DateTime currentDate;
  final DateTime selectedDate;
  final List<MatchFixture> fixtures;
  final List<CareerEvent> events;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final firstCell = first.subtract(Duration(days: first.weekday - 1));
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 3,
        crossAxisSpacing: 3,
        childAspectRatio: 1.55,
      ),
      itemCount: 42,
      itemBuilder: (context, index) {
        final date = firstCell.add(Duration(days: index));
        final inMonth = date.month == month.month && date.year == month.year;
        final selected = _sameDay(date, selectedDate);
        final current = _sameDay(date, currentDate);
        final hasMatch = fixtures.any((fixture) => _sameDay(fixture.date, date));
        final dayEvents = events.where((event) => _sameDay(event.date, date));
        final hasTraining = dayEvents.any(
          (event) => event.type == CareerEventType.training,
        );
        final hasOtherEvent = dayEvents.any(
          (event) =>
              event.type != CareerEventType.training &&
              event.type != CareerEventType.nextMatch,
        );
        return InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => onSelected(date),
          child: Container(
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.green.withValues(alpha: .22)
                  : current
                      ? AppColors.surfaceRaised
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: selected
                    ? AppColors.green
                    : AppColors.border.withValues(alpha: .7),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${date.day}',
                  style: TextStyle(
                    color: inMonth ? AppColors.white : AppColors.muted,
                    fontSize: 11,
                    fontWeight: selected || current
                        ? FontWeight.w900
                        : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                if (hasMatch)
                  const Icon(
                    Icons.sports_soccer_rounded,
                    size: 10,
                    color: AppColors.white,
                  )
                else if (hasTraining || hasOtherEvent)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: hasTraining ? AppColors.green : AppColors.info,
                    ),
                  )
                else
                  const SizedBox(height: 10),
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
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
}

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend();

  @override
  Widget build(BuildContext context) => const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _LegendDot(label: 'Partida', color: AppColors.green, ball: true),
          SizedBox(width: 16),
          _LegendDot(label: 'Treino', color: AppColors.green),
          SizedBox(width: 16),
          _LegendDot(label: 'Evento', color: AppColors.info),
        ],
      );
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.label,
    required this.color,
    this.ball = false,
  });

  final String label;
  final Color color;
  final bool ball;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (ball)
            Icon(Icons.sports_soccer_rounded, size: 11, color: color)
          else
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 9)),
        ],
      );
}

class _CommitmentList extends StatelessWidget {
  const _CommitmentList({
    required this.career,
    required this.fixtures,
    required this.events,
    required this.onFixtureTap,
  });

  final CareerState career;
  final List<MatchFixture> fixtures;
  final List<CareerEvent> events;
  final ValueChanged<MatchFixture> onFixtureTap;

  @override
  Widget build(BuildContext context) {
    if (fixtures.isEmpty && events.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum compromisso disponível.',
          style: TextStyle(color: AppColors.muted, fontSize: 11),
        ),
      );
    }
    final shownFixtures = fixtures.take(4).toList();
    final shownEvents = events.take(4 - shownFixtures.length).toList();
    return Column(
      children: [
        for (final fixture in shownFixtures)
          Expanded(
            child: _FixtureCommitmentTile(
              career: career,
              fixture: fixture,
              onTap: () => onFixtureTap(fixture),
            ),
          ),
        for (final event in shownEvents)
          Expanded(child: _EventCommitmentTile(event: event)),
      ],
    );
  }
}

class _FixtureCommitmentTile extends StatelessWidget {
  const _FixtureCommitmentTile({
    required this.career,
    required this.fixture,
    required this.onTap,
  });

  final CareerState career;
  final MatchFixture fixture;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final opponentId = fixture.homeClubId == career.userClubId
        ? fixture.awayClubId
        : fixture.homeClubId;
    final opponent = career.clubs.firstWhere((club) => club.id == opponentId);
    final stadium = fixture.homeClubId == career.userClubId
        ? career.userClub.stadium.name
        : opponent.stadium.name;
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 42,
            height: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: .11),
              border: Border(
                right: BorderSide(
                  color: AppColors.green.withValues(alpha: .20),
                ),
              ),
            ),
            child: Icon(
              fixture.played
                  ? Icons.emoji_events_outlined
                  : Icons.sports_soccer_rounded,
              color: AppColors.green,
              size: 23,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 43,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _shortWeekday(fixture.date),
                  style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800),
                ),
                Text(
                  '${fixture.date.day}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                Text(_shortMonth(fixture.date), style: const TextStyle(fontSize: 8)),
              ],
            ),
          ),
          const VerticalDivider(width: 8, indent: 6, endIndent: 6),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  CompetitionCatalog.displayNameForId(fixture.competitionId),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.green,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  fixture.played
                      ? '${opponent.name} • ${fixture.score?.display ?? '-'}'
                      : 'vs ${opponent.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                ),
                Text(
                  '$stadium • ${fixture.kickoffLabel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted, fontSize: 8),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
        ],
      ),
    );
  }

  static String _shortWeekday(DateTime date) => const [
        'SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB', 'DOM',
      ][date.weekday - 1];

  static String _shortMonth(DateTime date) => const [
        'JAN', 'FEV', 'MAR', 'ABR', 'MAI', 'JUN',
        'JUL', 'AGO', 'SET', 'OUT', 'NOV', 'DEZ',
      ][date.month - 1];
}

class _EventCommitmentTile extends StatelessWidget {
  const _EventCommitmentTile({required this.event});

  final CareerEvent event;

  @override
  Widget build(BuildContext context) {
    final training = event.type == CareerEventType.training;
    return Row(
      children: [
        Container(
          width: 42,
          height: double.infinity,
          alignment: Alignment.center,
          color: (training ? AppColors.green : AppColors.info)
              .withValues(alpha: .10),
          child: Icon(
            training ? Icons.sports_rounded : Icons.notifications_none_rounded,
            color: training ? AppColors.green : AppColors.info,
            size: 23,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                training ? 'Treino' : 'Evento',
                style: TextStyle(
                  color: training ? AppColors.green : AppColors.info,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                event.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
              ),
              Text(
                event.message,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.muted, fontSize: 8),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MonthSummary extends StatelessWidget {
  const _MonthSummary({
    required this.matches,
    required this.trainings,
    required this.events,
  });

  final int matches;
  final int trainings;
  final int events;

  @override
  Widget build(BuildContext context) => SectionCard(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          children: [
            _SummaryItem(
              icon: Icons.sports_soccer_rounded,
              value: matches,
              label: 'Partidas no mês',
              color: AppColors.green,
            ),
            const VerticalDivider(width: 14),
            _SummaryItem(
              icon: Icons.sports_rounded,
              value: trainings,
              label: 'Treinos realizados',
              color: AppColors.green,
            ),
            const VerticalDivider(width: 14),
            _SummaryItem(
              icon: Icons.notifications_none_rounded,
              value: events,
              label: 'Outros eventos',
              color: AppColors.info,
            ),
          ],
        ),
      );
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 23),
            const SizedBox(width: 7),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$value',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                Text(
                  label,
                  style: const TextStyle(color: AppColors.muted, fontSize: 7),
                ),
              ],
            ),
          ],
        ),
      );
}

class _DialogClub extends StatelessWidget {
  const _DialogClub({required this.club});

  final Club club;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          ClubBadge(club: club, size: 54),
          const SizedBox(height: 6),
          Text(
            club.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
          ),
        ],
      );
}

class _DetailStat extends StatelessWidget {
  const _DetailStat({required this.label, required this.home, required this.away});

  final String label;
  final String home;
  final String away;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            SizedBox(
              width: 54,
              child: Text(home, style: const TextStyle(fontWeight: FontWeight.w900)),
            ),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted, fontSize: 11),
              ),
            ),
            SizedBox(
              width: 54,
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
