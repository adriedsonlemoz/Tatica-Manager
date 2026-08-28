import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/widgets/common.dart';
import '../../app/widgets/manager_avatar.dart';
import '../../app/widgets/player_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/player/player.dart';
import '../../domain/season/career_event.dart';
import '../../domain/season/career_state.dart';
import '../../game/cpu/cpu_user_offer_engine.dart';
import '../../game/season/season_engine.dart';
import '../calendar/calendar_screen.dart';
import '../clubs/club_profile_screen.dart';
import '../career/manager_job_market_screen.dart';
import '../finances/finances_screen.dart';
import '../inbox/inbox_screen.dart';
import '../market/incoming_transfer_offer_dialog.dart';
import '../market/market_screen.dart';
import '../medical/medical_department_screen.dart';
import '../player/player_profile_screen.dart';
import '../season/season_history_screen.dart';
import '../standings/standings_screen.dart';
import '../tactics/tactics_screen.dart';
import '../youth/youth_academy_screen.dart';
import 'home_overview_widgets.dart';
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

    return PremiumScaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
              child: Row(
                children: [
                  ClubBadge(club: club, size: 58),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          club.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        Text(
                          'Temporada ${career.season} • Rodada ${career.currentRound}/$totalRounds',
                          style: TextStyle(color: AppColors.muted),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          calendarDate(career.currentDate),
                          style: const TextStyle(color: AppColors.green, fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  OverallShield(value: club.reputation),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 110),
            sliver: SliverList.list(
              children: [
                SectionCard(
                  child: Row(
                    children: [
                      Metric(label: 'Orçamento', value: compactMoney(club.transferBudget), icon: Icons.account_balance_wallet_outlined),
                      const SizedBox(width: 12),
                      Metric(label: 'Folha/mês', value: compactMoney(club.payroll), icon: Icons.payments_outlined),
                      const SizedBox(width: 12),
                      Metric(label: 'Posição', value: position > 0 ? '$positionº' : '—', icon: Icons.emoji_events_outlined),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (fixture != null && opponent != null)
                  SectionCard(
                    borderColor: career.isMatchDay ? AppColors.green : null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'PRÓXIMA PARTIDA',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            Text(
                              career.isMatchDay
                                  ? 'HOJE • R${fixture.round}'
                                  : daysUntilMatch == 1
                                      ? 'AMANHÃ • R${fixture.round}'
                                      : 'EM ${daysUntilMatch ?? 0} DIAS • R${fixture.round}',
                              style: TextStyle(
                                color: career.isMatchDay ? AppColors.green : AppColors.muted,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClubBadge(club: club, size: 64),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 22),
                              child: Text('VS', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                            ),
                            ClubBadge(club: opponent, size: 64),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            '${calendarDate(fixture.date)} • ${fixture.homeClubId == club.id ? club.stadium.name : opponent.stadium.name}',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.muted),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (career.isMatchDay)
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const MatchDayPresentationScreen(),
                                ),
                              ),
                              icon: const Icon(Icons.sports_soccer_rounded),
                              label: const Text('Entrar no dia de jogo'),
                            ),
                          )
                        else
                          HomeDailyAdvancePanel(
                            currentDate: career.currentDate,
                            daysUntilMatch: daysUntilMatch ?? 0,
                            onAdvance: () => _advanceDayWithTransition(
                              context,
                              ref,
                              career.currentDate,
                            ),
                          ),
                      ],
                    ),
                  )
                else
                  SectionCard(
                    child: Column(
                      children: [
                        const Icon(Icons.emoji_events_rounded, color: AppColors.green, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          'Temporada concluída',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Finalize a virada de temporada para continuar sua carreira.',
                          style: TextStyle(color: AppColors.muted),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),
                        FilledButton.icon(
                          onPressed: () => _showSeasonEndDialog(
                            context,
                            ref,
                            career,
                          ),
                          icon: const Icon(Icons.fact_check_outlined),
                          label: const Text('Revisar temporada'),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.newspaper_rounded, color: AppColors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'NOTÍCIAS E EVENTOS',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (career.news.isEmpty)
                        Text(
                          'Avance os dias para acompanhar treinos, contratos, mercado e preparação das partidas.',
                          style: TextStyle(color: AppColors.muted),
                        )
                      else
                        ...career.news.reversed.take(4).map((event) {
                          final transferActionable = CpuUserOfferEngine.isOfferActive(
                            state: career,
                            event: event,
                          );
                          final managerActionable = event.type == CareerEventType.managerOffer;
                          final actionable = transferActionable ||
                              managerActionable ||
                              event.negotiationId != null ||
                              event.fixtureId != null ||
                              event.playerId != null ||
                              event.clubId != null;
                          final eventPlayer = _playerForEvent(career, event.playerId);
                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: actionable
                                ? () => _openCareerEvent(
                                      context,
                                      ref,
                                      career,
                                      event,
                                      transferActionable: transferActionable,
                                    )
                                : null,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (eventPlayer != null)
                                    PlayerAvatar(
                                      player: eventPlayer,
                                      size: 34,
                                      accentColor: _playerAccent(career, eventPlayer),
                                    )
                                  else
                                    Container(
                                      width: 34,
                                      height: 34,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: AppColors.green.withValues(
                                          alpha: .10,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        _newsIcon(event.type),
                                        size: 18,
                                        color: _newsColor(event.type),
                                      ),
                                    ),
                                  const SizedBox(width: 9),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          event.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          event.message,
                                          style: TextStyle(
                                            color: AppColors.muted,
                                            fontSize: 11,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Text(
                                              shortDate(event.date),
                                              style: const TextStyle(
                                                color: AppColors.green,
                                                fontSize: 10,
                                              ),
                                            ),
                                            if (actionable) ...[
                                              const SizedBox(width: 8),
                                              const Text(
                                                'ABRIR',
                                                style: TextStyle(
                                                  color: AppColors.green,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ],
                                          ],
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
                  ),
                ),
                const SizedBox(height: 12),
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CLASSIFICAÇÃO',
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 10),
                      HomeCompactStandings(
                        standings: career.standings,
                        clubs: career.clubs,
                        userClubId: career.userClubId,
                        onClubTap: (clubId) => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ClubProfileScreen(clubId: clubId),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const StandingsScreen(),
                          ),
                        ),
                        child: const Text('Ver tabela completa'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('FORMA RECENTE', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 12),
                      Row(
                        children: List.generate(5, (index) {
                          final value = index < club.recentForm.length ? club.recentForm[index] : '—';
                          final isWin = value == 'V';
                          final isDraw = value == 'E';
                          return Container(
                            width: 38,
                            height: 38,
                            margin: const EdgeInsets.only(right: 9),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isWin
                                  ? AppColors.greenDark
                                  : isDraw
                                      ? AppColors.surfaceRaised
                                      : value == 'D'
                                          ? AppColors.danger.withValues(alpha: .5)
                                          : AppColors.surfaceRaised,
                              shape: BoxShape.circle,
                            ),
                            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AÇÕES RÁPIDAS', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _Quick(
                            icon: Icons.sports_soccer_rounded,
                            label: 'Táticas',
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TacticsScreen())),
                          ),
                          _Quick(
                            icon: Icons.calendar_month_rounded,
                            label: 'Calendário',
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CalendarScreen())),
                          ),
                          _Quick(
                            icon: Icons.leaderboard_rounded,
                            label: 'Tabela',
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StandingsScreen())),
                          ),
                          _Quick(
                            icon: Icons.account_balance_wallet_rounded,
                            label: 'Finanças',
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FinancesScreen())),
                          ),
                          _Quick(
                            icon: Icons.mail_rounded,
                            label: 'E-mail',
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InboxScreen())),
                          ),
                          _Quick(
                            icon: Icons.school_rounded,
                            label: 'Base',
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const YouthAcademyScreen())),
                          ),
                          _Quick(
                            icon: Icons.medical_services_rounded,
                            label: 'Médico',
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MedicalDepartmentScreen())),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SectionCard(
                  child: Row(
                    children: [
                      const Icon(Icons.shield_outlined, color: AppColors.green),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Situação financeira', style: TextStyle(fontWeight: FontWeight.w800)),
                            Text(
                              club.money > club.payroll * 4 ? 'Segura' : 'Exige atenção',
                              style: TextStyle(
                                color: club.money > club.payroll * 4 ? AppColors.green : AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(formatMoney(club.money), style: const TextStyle(fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ],
            ),
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

  static IconData _newsIcon(CareerEventType type) => switch (type) {
        CareerEventType.playerRecovered || CareerEventType.injuryEnded => Icons.healing_rounded,
        CareerEventType.suspensionEnded => Icons.gavel_rounded,
        CareerEventType.contractExpiring => Icons.description_rounded,
        CareerEventType.transferOffer => Icons.swap_horiz_rounded,
        CareerEventType.managerOffer => Icons.business_center_rounded,
        CareerEventType.nextMatch => Icons.sports_soccer_rounded,
        CareerEventType.training => Icons.fitness_center_rounded,
        CareerEventType.seasonStarted => Icons.emoji_events_rounded,
        CareerEventType.info => Icons.info_outline_rounded,
      };

  static Color _newsColor(CareerEventType type) => switch (type) {
        CareerEventType.contractExpiring => AppColors.warning,
        CareerEventType.transferOffer ||
        CareerEventType.managerOffer ||
        CareerEventType.nextMatch => AppColors.green,
        _ => AppColors.muted,
      };

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

class _Quick extends StatelessWidget {
  const _Quick({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: 76,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceRaised,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.green),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            ],
          ),
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
