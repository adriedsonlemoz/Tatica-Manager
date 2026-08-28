import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/widgets/common.dart';
import '../../app/widgets/manager_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/competition_catalog.dart';
import '../../domain/player/player.dart';
import '../../domain/season/career_event.dart';
import '../../domain/season/career_state.dart';
import '../../game/career/manager_career_engine.dart';
import '../../game/cpu/cpu_user_offer_engine.dart';
import '../../game/season/season_engine.dart';
import '../calendar/calendar_screen.dart';
import '../clubs/club_profile_screen.dart';
import '../career/manager_job_market_screen.dart';
import '../career/manager_profile_screen.dart';
import '../finances/finances_screen.dart';
import '../inbox/inbox_screen.dart';
import '../market/incoming_transfer_offer_dialog.dart';
import '../market/market_screen.dart';
import '../medical/medical_department_screen.dart';
import '../player/player_profile_screen.dart';
import '../season/season_history_screen.dart';
import '../standings/standings_screen.dart';
import '../statistics/statistics_screen.dart';
import '../tactics/tactics_screen.dart';
import '../youth/youth_academy_screen.dart';
import 'home_dashboard_widgets.dart';
import 'match_day_presentation_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final career = ref.watch(gameControllerProvider).career!;
    if (career.managerUnemployed) {
      return _UnemployedHome(career: career);
    }
    final club = career.userClub;
    final position = career.standings.indexWhere((s) => s.clubId == club.id) + 1;
    final fixture = career.nextUserFixture;
    final opponent = fixture == null
        ? null
        : career.clubs.firstWhere(
            (c) => c.id == (fixture.homeClubId == club.id ? fixture.awayClubId : fixture.homeClubId),
          );
    final daysUntilMatch = career.daysUntilNextMatch;
    final totalRounds = career.fixtures.fold<int>(
      career.currentRound,
      (highest, item) => item.round > highest ? item.round : highest,
    );

    final primarySeries = CompetitionCatalog.primarySeriesForClub(club.id);
    final competitionName = fixture == null
        ? CompetitionCatalog.displayNameFor(primarySeries)
        : CompetitionCatalog.displayNameForId(fixture.competitionId);
    final standing = career.standings.where((row) => row.clubId == club.id).firstOrNull;
    final points = standing?.points ?? 0;
    final unreadMessages = career.inbox
        .where((message) => !message.read && !message.archived && !message.deleted)
        .length;
    final boardConfidence = ManagerCareerEngine.reputationFor(career);
    final performance = _performanceFor(club.recentForm);
    final scorers = <HomeScorerEntry>[
      for (final team in career.clubs)
        for (final player in team.squad)
          HomeScorerEntry(player: player, club: team),
    ]
      ..sort((a, b) {
        final goals = b.player.stats.goals.compareTo(a.player.stats.goals);
        if (goals != 0) return goals;
        return b.player.stats.assists.compareTo(a.player.stats.assists);
      });
    final topScorers = scorers.take(3).toList(growable: false);
    final recentNews = career.news.reversed.take(5).toList(growable: false);
    final nextMatchLabel = fixture == null
        ? 'Temporada concluída'
        : career.isMatchDay
            ? 'Próximo jogo • Hoje, ${fixture.kickoffLabel}'
            : daysUntilMatch == 1
                ? 'Próximo jogo • Amanhã, ${fixture.kickoffLabel}'
                : 'Próximo jogo • ${shortDate(fixture.date)}, ${fixture.kickoffLabel}';

    return PremiumScaffold(
      body: Container(
        color: const Color(0xFF030708),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: HomeClubHeader(
                club: club,
                manager: career.manager,
                season: career.season,
                competitionName: competitionName,
                nextMatchLabel: nextMatchLabel,
                unreadMessages: unreadMessages,
                onNotificationsTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const InboxScreen()),
                ),
                onInboxTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const InboxScreen()),
                ),
                onManagerTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ManagerProfileScreen()),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 110),
              sliver: SliverList.list(
                children: [
                  SizedBox(
                    height: 100,
                    child: HomeStatusGrid(
                      position: position,
                      points: points,
                      nextFixture: fixture,
                      competitionLabel: primarySeries.name,
                      performanceLabel: performance.label,
                      performanceProgress: performance.progress,
                      onPositionTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const StandingsScreen()),
                      ),
                      onNextMatchTap: fixture == null
                          ? null
                          : () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => CalendarScreen(initialFixtureId: fixture.id),
                                ),
                              ),
                      onCompetitionTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const StandingsScreen()),
                      ),
                      onPerformanceTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const StatisticsScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  HomeMainOverview(
                    club: club,
                    opponent: opponent,
                    fixture: fixture,
                    competitionName: competitionName,
                    boardConfidence: boardConfidence,
                    recentForm: club.recentForm,
                    position: position,
                    totalRounds: totalRounds,
                    currentRound: career.currentRound,
                    onMatchTap: fixture == null
                        ? null
                        : () {
                            if (career.isMatchDay) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const MatchDayPresentationScreen(),
                                ),
                              );
                              return;
                            }
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CalendarScreen(initialFixtureId: fixture.id),
                              ),
                            );
                          },
                  ),
                  const SizedBox(height: 8),
                  if (fixture != null)
                    HomeAdvanceStrip(
                      isMatchDay: career.isMatchDay,
                      currentDate: career.currentDate,
                      daysUntilMatch: daysUntilMatch ?? 0,
                      onAdvance: () => _advanceDayWithTransition(
                        context,
                        ref,
                        career.currentDate,
                      ),
                      onMatchDay: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MatchDayPresentationScreen(),
                        ),
                      ),
                    )
                  else
                    SectionCard(
                      borderColor: AppColors.green.withValues(alpha: .45),
                      child: Row(
                        children: [
                          const Icon(Icons.emoji_events_rounded, color: AppColors.green, size: 32),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('TEMPORADA CONCLUÍDA', style: TextStyle(fontWeight: FontWeight.w900)),
                                SizedBox(height: 2),
                                Text('Revise a temporada antes de iniciar a próxima.', style: TextStyle(color: AppColors.muted, fontSize: 10)),
                              ],
                            ),
                          ),
                          FilledButton(
                            onPressed: () => _showSeasonEndDialog(context, ref, career),
                            child: const Text('Revisar'),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  HomeQuickAccess(
                    items: [
                      HomeQuickAccessItem(
                        icon: Icons.sports_soccer_rounded,
                        label: 'Táticas',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const TacticsScreen()),
                        ),
                      ),
                      HomeQuickAccessItem(
                        icon: Icons.calendar_month_rounded,
                        label: 'Calendário',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CalendarScreen()),
                        ),
                      ),
                      HomeQuickAccessItem(
                        icon: Icons.account_balance_wallet_rounded,
                        label: 'Finanças',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const FinancesScreen()),
                        ),
                      ),
                      HomeQuickAccessItem(
                        icon: Icons.school_rounded,
                        label: 'Base',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const YouthAcademyScreen()),
                        ),
                      ),
                      HomeQuickAccessItem(
                        icon: Icons.medical_services_rounded,
                        label: 'Médico',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const MedicalDepartmentScreen()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  HomeNewsHighlights(
                    events: recentNews,
                    playerForEvent: (playerId) => _playerForEvent(career, playerId),
                    playerAccent: (player) => _playerAccent(career, player),
                    onEventTap: (event) => _openCareerEvent(
                      context,
                      ref,
                      career,
                      event,
                      transferActionable: CpuUserOfferEngine.isOfferActive(
                        state: career,
                        event: event,
                      ),
                    ),
                    onViewAll: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const InboxScreen()),
                    ),
                  ),
                  const SizedBox(height: 8),
                  HomeLeagueAndScorers(
                    standings: career.standings,
                    clubs: career.clubs,
                    userClubId: career.userClubId,
                    scorers: topScorers,
                    competitionName: primarySeries.name,
                    onClubTap: (clubId) => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ClubProfileScreen(clubId: clubId)),
                    ),
                    onPlayerTap: (entry) => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PlayerProfileScreen(
                          playerId: entry.player.id,
                          clubId: entry.club.id,
                        ),
                      ),
                    ),
                    onStandingsTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const StandingsScreen()),
                    ),
                    onScorersTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const StatisticsScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static ({String label, double progress}) _performanceFor(List<String> form) {
    if (form.isEmpty) return (label: 'SEM DADOS', progress: .15);
    final recent = form.take(5);
    var points = 0;
    var matches = 0;
    for (final result in recent) {
      if (result == 'V') {
        points += 3;
        matches++;
      } else if (result == 'E') {
        points += 1;
        matches++;
      } else if (result == 'D') {
        matches++;
      }
    }
    if (matches == 0) return (label: 'SEM DADOS', progress: .15);
    final progress = points / (matches * 3);
    final label = progress >= .8
        ? 'ÓTIMA'
        : progress >= .55
            ? 'BOA'
            : progress >= .3
                ? 'REGULAR'
                : 'ALERTA';
    return (label: label, progress: progress);
  }

  static Future<void> _advanceDayWithTransition(
    BuildContext context,
    WidgetRef ref,
    DateTime currentDate,
  ) async {
    final nextDate = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
    ).add(const Duration(days: 1));
    unawaited(
      showGeneralDialog<void>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withValues(alpha: .72),
        transitionDuration: const Duration(milliseconds: 160),
        pageBuilder: (dialogContext, _, _) => _DayAdvanceTransition(
          from: currentDate,
          to: nextDate,
        ),
        transitionBuilder: (context, animation, _, child) => FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 180));
    await ref.read(gameControllerProvider.notifier).advanceDay();
    await Future<void>.delayed(const Duration(milliseconds: 260));
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    final next = ref.read(gameControllerProvider).career;
    if (next?.isMatchDay == true && context.mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const MatchDayPresentationScreen()),
      );
    }
  }

  static void _openCareerEvent(
    BuildContext context,
    WidgetRef ref,
    CareerState career,
    CareerEvent event, {
    required bool transferActionable,
  }) {
    if (transferActionable) {
      showIncomingTransferOfferDialog(
        context,
        ref,
        eventId: event.id,
      );
      return;
    }
    if (event.type == CareerEventType.managerOffer) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ManagerJobMarketScreen()),
      );
      return;
    }
    if (event.negotiationId != null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const MarketScreen(initialTab: 2)),
      );
      return;
    }
    if (event.fixtureId != null || event.type == CareerEventType.nextMatch) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => CalendarScreen(initialFixtureId: event.fixtureId)),
      );
      return;
    }
    final playerId = event.playerId;
    if (playerId != null) {
      String? ownerId;
      for (final club in career.clubs) {
        if (club.squad.any((player) => player.id == playerId)) {
          ownerId = club.id;
          break;
        }
      }
      if (ownerId == null &&
          career.youthAcademy.any((player) => player.id == playerId)) {
        ownerId = career.userClubId;
      }
      if (ownerId != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PlayerProfileScreen(
              playerId: playerId,
              clubId: ownerId,
            ),
          ),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MarketScreen()),
        );
      }
      return;
    }
    if (event.clubId != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ClubProfileScreen(clubId: event.clubId!),
        ),
      );
    }
  }

  static Player? _playerForEvent(CareerState career, String? playerId) {
    if (playerId == null) return null;
    for (final club in career.clubs) {
      for (final player in club.squad) {
        if (player.id == playerId) return player;
      }
    }
    for (final player in career.freeAgents) {
      if (player.id == playerId) return player;
    }
    for (final player in career.youthAcademy) {
      if (player.id == playerId) return player;
    }
    return null;
  }

  static Color _playerAccent(CareerState career, Player player) {
    for (final club in career.clubs) {
      if (club.id == player.clubId) return Color(club.colors.primaryHex);
    }
    return AppColors.green;
  }

  static Future<void> _showSeasonEndDialog(
    BuildContext context,
    WidgetRef ref,
    CareerState career,
  ) async {
    final summary = SeasonEngine.summaryFor(career);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.green.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.emoji_events_outlined,
                        color: AppColors.green,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fim da temporada ${career.season}',
                            style: Theme.of(dialogContext)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          Text(
                            'Confira o desempenho antes de avançar.',
                            style: TextStyle(color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Metric(label: 'Posição', value: '${summary.position}º'),
                      Metric(label: 'Pontos', value: '${summary.points}'),
                      Metric(label: 'V', value: '${summary.wins}'),
                      Metric(label: 'E', value: '${summary.draws}'),
                      Metric(label: 'D', value: '${summary.losses}'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Ao continuar, contratos, evolução dos jogadores, elenco e calendário serão processados para ${career.season + 1}. O histórico desta temporada ficará salvo.',
                  style: TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: const Text('Agora não'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        icon: const Icon(Icons.skip_next_rounded),
                        label: Text('Iniciar ${career.season + 1}'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await ref.read(gameControllerProvider.notifier).advanceSeason();
  }

}

class _DayAdvanceTransition extends StatelessWidget {
  const _DayAdvanceTransition({required this.from, required this.to});

  final DateTime from;
  final DateTime to;

  @override
  Widget build(BuildContext context) => Center(
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: .92, end: 1),
            duration: const Duration(milliseconds: 360),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) => Transform.scale(
              scale: value,
              child: child,
            ),
            child: Container(
              width: 250,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.green.withValues(alpha: .4)),
                boxShadow: const [
                  BoxShadow(color: Color(0x66000000), blurRadius: 28, offset: Offset(0, 12)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_month_rounded, color: AppColors.green, size: 38),
                  const SizedBox(height: 10),
                  const Text(
                    'PASSAGEM DO TEMPO',
                    style: TextStyle(
                      color: AppColors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .8,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    '${shortDate(from)}  →  ${shortDate(to)}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  const LinearProgressIndicator(minHeight: 3),
                ],
              ),
            ),
          ),
        ),
      );
}

class _UnemployedHome extends ConsumerWidget {
  const _UnemployedHome({required this.career});

  final CareerState career;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offers = career.managerCareer.offers
        .where((offer) => offer.isActiveOn(career.currentDate))
        .length;
    return PremiumScaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 110),
        children: [
          Row(
            children: [
              ManagerAvatar(manager: career.manager, size: 58),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      career.manager.preferredName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const Text('Técnico sem clube', style: TextStyle(color: AppColors.warning)),
                    Text(
                      calendarDate(career.currentDate),
                      style: const TextStyle(color: AppColors.green, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SectionCard(
            borderColor: AppColors.warning,
            child: Column(
              children: [
                const Icon(Icons.work_off_rounded, color: AppColors.warning, size: 44),
                const SizedBox(height: 10),
                const Text(
                  'EM BUSCA DE UM NOVO DESAFIO',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 7),
                Text(
                  offers > 0
                      ? 'Você possui $offers proposta(s) ativa(s). Avalie os projetos antes que expirem.'
                      : 'Consulte as vagas abertas ou avance os dias. Clubes podem entrar em contato de acordo com sua reputação e trajetória.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.muted, height: 1.4),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ManagerJobMarketScreen()),
                    ),
                    icon: const Icon(Icons.manage_search_rounded),
                    label: Text(offers > 0 ? 'Ver propostas e vagas' : 'Procurar vagas'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => HomeScreen._advanceDayWithTransition(
                      context,
                      ref,
                      career.currentDate,
                    ),
                    icon: const Icon(Icons.skip_next_rounded),
                    label: const Text('Avançar um dia no mercado'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.history_rounded, color: AppColors.green),
              title: const Text('Ver carreira do técnico', style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle: const Text('Clubes comandados, temporadas e histórico profissional'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SeasonHistoryScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
