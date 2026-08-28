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
import '../../game/lineup/lineup_engine.dart';
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
import '../stadium/stadium_screen.dart';
import '../tactics/tactics_screen.dart';
import '../youth/youth_academy_screen.dart';
import 'home_dashboard_widgets.dart';
import 'match_day_presentation_screen.dart';
import 'news_highlights_screen.dart';

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
    final unreadMessages = career.inbox
        .where((message) => !message.read && !message.archived && !message.deleted)
        .length;
    final monthTransactions = career.finances.where(
      (tx) => tx.createdAt.year == career.currentDate.year &&
          tx.createdAt.month == career.currentDate.month,
    );
    final monthIncome = monthTransactions
        .where((tx) => tx.amount > 0)
        .fold<int>(0, (sum, tx) => sum + tx.amount);
    final monthExpenses = monthTransactions
        .where((tx) => tx.amount < 0)
        .fold<int>(0, (sum, tx) => sum + tx.amount.abs());
    final boardConfidence = ManagerCareerEngine.reputationFor(career);
    final primaryCompetitionState =
        career.competitionStateFor(career.primaryCompetitionId);
    final primaryClubIds = primaryCompetitionState.participantClubIds.toSet();
    final scorers = <HomeScorerEntry>[
      for (final team in career.clubs)
        if (primaryClubIds.contains(team.id))
          for (final player in team.squad)
            HomeScorerEntry(
              player: player,
              club: team,
              stats: primaryCompetitionState.statsForPlayer(player.id),
            ),
    ]
      ..sort((a, b) {
        final goals = b.stats.goals.compareTo(a.stats.goals);
        if (goals != 0) return goals;
        return b.stats.assists.compareTo(a.stats.assists);
      });
    final topScorers = scorers.take(3).toList(growable: false);
    final recentNews = career.news.reversed.take(4).toList(growable: false);
    final lineupCompetitionId = fixture?.competitionId ?? career.primaryCompetitionId;
    final lineupNeedsAttention = !LineupEngine.validate(
      club.squad,
      career.starterIds,
      career.formation,
      competitionSuspendedPlayerIds:
          career.suspendedPlayerIdsForCompetition(lineupCompetitionId),
    ).isValid;
    final financeNeedsAttention = career.clubAdministration.sponsorshipProposals.any(
      (proposal) =>
          proposal.canRespond && !proposal.isExpiredAt(career.currentDate),
    );
    final medicalNeedsAttention = club.squad.any((player) => player.injury != null);
    final recentUserMatches = <HomeRecentMatchEntry>[];
    for (final result in career.matchHistory.reversed) {
      if (result.homeClubId != club.id && result.awayClubId != club.id) continue;
      final opponentId =
          result.homeClubId == club.id ? result.awayClubId : result.homeClubId;
      final recentOpponent = career.clubs
          .where((candidate) => candidate.id == opponentId)
          .firstOrNull;
      if (recentOpponent == null) continue;
      final relatedFixture = career.fixtures
          .where((candidate) => candidate.id == result.fixtureId)
          .firstOrNull;
      recentUserMatches.add(
        HomeRecentMatchEntry(
          result: result,
          opponent: recentOpponent,
          userClubId: club.id,
          date: relatedFixture?.date,
        ),
      );
      if (recentUserMatches.length == 5) break;
    }
    final showRecentMatches =
        recentUserMatches.isNotEmpty && MediaQuery.sizeOf(context).height >= 700;

    final nextMatchLabel = fixture == null
        ? 'Temporada concluída'
        : career.isMatchDay
            ? 'Próximo jogo • Hoje, ${fixture.kickoffLabel}'
            : daysUntilMatch == 1
                ? 'Próximo jogo • Amanhã, ${fixture.kickoffLabel}'
                : 'Próximo jogo • ${shortDate(fixture.date)}, ${fixture.kickoffLabel}';

    return PremiumScaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: IgnorePointer(child: _HomeBackdrop())),
          CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: HomeClubHeader(
                club: club,
                manager: career.manager,
                season: career.season,
                competitionName: competitionName,
                nextMatchLabel: nextMatchLabel,
                unreadMessages: unreadMessages,
                onInboxTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const InboxScreen()),
                ),
                onManagerTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ManagerProfileScreen()),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 12),
              sliver: SliverList.list(
                children: [
                  SizedBox(
                    height: 58,
                    child: HomeFinanceGrid(
                      balance: club.money,
                      transferBudget: club.transferBudget,
                      monthIncome: monthIncome,
                      monthExpenses: monthExpenses,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const FinancesScreen()),
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
                    position: position,
                    totalRounds: totalRounds,
                    currentRound: career.currentRound,
                    isMatchDay: career.isMatchDay,
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
                    onStadiumTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const StadiumScreen()),
                    ),
                    onSeasonTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const StandingsScreen()),
                    ),
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
                  if (fixture == null) ...[
                    const SizedBox(height: 6),
                    SectionCard(
                      padding: const EdgeInsets.all(10),
                      borderColor: AppColors.green.withValues(alpha: .45),
                      child: Row(
                        children: [
                          const Icon(Icons.emoji_events_rounded, color: AppColors.green, size: 24),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('TEMPORADA CONCLUÍDA', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900)),
                                SizedBox(height: 1),
                                Text('Revise a temporada antes de iniciar a próxima.', style: TextStyle(color: AppColors.muted, fontSize: 7)),
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
                  ],
                  const SizedBox(height: 6),

                  HomeQuickAccess(
                    items: [
                      HomeQuickAccessItem(
                        icon: Icons.sports_soccer_rounded,
                        label: 'Táticas',
                        accent: const Color(0xFF7B35E8),
                        showDot: lineupNeedsAttention,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const TacticsScreen()),
                        ),
                      ),
                      HomeQuickAccessItem(
                        icon: Icons.calendar_month_rounded,
                        label: 'Calendário',
                        accent: const Color(0xFFE28A1B),
                        showDot: career.isMatchDay,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CalendarScreen()),
                        ),
                      ),
                      HomeQuickAccessItem(
                        icon: Icons.account_balance_wallet_rounded,
                        label: 'Finanças',
                        accent: const Color(0xFF1ABEA1),
                        showDot: financeNeedsAttention,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const FinancesScreen()),
                        ),
                      ),
                      HomeQuickAccessItem(
                        icon: Icons.school_rounded,
                        label: 'Base',
                        accent: const Color(0xFF2F8BFF),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const YouthAcademyScreen()),
                        ),
                      ),
                      HomeQuickAccessItem(
                        icon: Icons.medical_services_rounded,
                        label: 'Departamento\nMédico',
                        accent: const Color(0xFFE24F87),
                        showDot: medicalNeedsAttention,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const MedicalDepartmentScreen()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final sameRow = constraints.maxWidth >= 315;
                      final newsCard = HomeNewsHighlights(
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
                          MaterialPageRoute(
                            builder: (_) => NewsHighlightsScreen(
                              events: career.news.reversed.toList(growable: false),
                              onEventTap: (newsContext, event) => _openCareerEvent(
                                newsContext,
                                ref,
                                career,
                                event,
                                transferActionable: CpuUserOfferEngine.isOfferActive(
                                  state: career,
                                  event: event,
                                ),
                              ),
                            ),
                          ),
                        ),
                        compact: sameRow,
                      );
                      final rankings = HomeLeagueAndScorers(
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
                        compactSingleRow: sameRow,
                      );
                      if (!sameRow) {
                        return Column(
                          children: [
                            newsCard,
                            const SizedBox(height: 6),
                            rankings,
                          ],
                        );
                      }
                      return IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(flex: 13, child: newsCard),
                            const SizedBox(width: 5),
                            Expanded(flex: 17, child: rankings),
                          ],
                        ),
                      );
                    },
                  ),
                  if (showRecentMatches) ...[
                    const SizedBox(height: 6),
                    HomeRecentMatches(
                      entries: recentUserMatches,
                      onTap: (entry) => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CalendarScreen(
                            initialFixtureId: entry.result.fixtureId,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
      ),
    );
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
        MaterialPageRoute(builder: (_) => const MarketScreen(initialTab: 2, showBackButton: true)),
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
          MaterialPageRoute(builder: (_) => const MarketScreen(showBackButton: true)),
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

class _HomeBackdrop extends StatelessWidget {
  const _HomeBackdrop();

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A1319), AppColors.background, Color(0xFF0B1419)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: -80,
              top: -40,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0xFF4A79FF).withValues(alpha: .12), Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              right: -90,
              top: 10,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [AppColors.green.withValues(alpha: .10), Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 220,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Color(0x99060A0D),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
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
