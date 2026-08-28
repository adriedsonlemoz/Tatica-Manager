import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/state/live_match_controller.dart';
import '../../app/widgets/common.dart';
import '../../app/widgets/player_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/competition_catalog.dart';
import '../../domain/formation/formation.dart';
import '../../domain/player/player.dart';
import '../../domain/settings/match_presentation_settings.dart';
import '../../game/lineup/lineup_engine.dart';
import '../lineup/lineup_screen.dart';
import '../tactics/tactics_screen.dart';
import 'match_screen.dart';

class PreMatchScreen extends ConsumerWidget {
  const PreMatchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final career = ref.watch(gameControllerProvider).career!;
    final fixture = career.nextUserFixture;
    if (fixture == null) {
      return const PremiumScaffold(
        appBar: GameTopBar(title: 'Pré-jogo'),
        body: EmptyState(
          icon: Icons.event_busy_rounded,
          title: 'Nenhuma partida pendente',
          text: 'Volte ao clube para continuar a carreira.',
        ),
      );
    }

    final home = career.clubs.firstWhere((club) => club.id == fixture.homeClubId);
    final away = career.clubs.firstWhere((club) => club.id == fixture.awayClubId);
    final validation = LineupEngine.validate(
      career.userClub.squad,
      career.starterIds,
      career.formation,
    );
    final unavailable = [...career.unavailableUserPlayers]
      ..sort((a, b) => a.displayName.compareTo(b.displayName));
    final suggestedIds = LineupEngine.autoSelect(
      career.userClub.squad,
      career.formation,
    );
    final suggestedDiffers = suggestedIds.join('|') != career.starterIds.join('|');
    final competitionName = CompetitionCatalog.displayNameForId(fixture.competitionId);
    final ready = career.isMatchDay && validation.valid;

    return PremiumScaffold(
      appBar: GameTopBar(
        title: 'Preparação da partida',
        subtitle: 'Rodada ${fixture.round} • ${fullDate(fixture.date)}',
      ),
      safeBottom: true,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
        children: [
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: (career.isMatchDay ? AppColors.green : AppColors.surfaceRaised)
                            .withValues(alpha: .16),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        career.isMatchDay ? 'HOJE É DIA DE JOGO' : 'PREPARE SUA EQUIPE',
                        style: TextStyle(
                          color: career.isMatchDay ? AppColors.green : AppColors.muted,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .7,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      career.isMatchDay ? 'PRONTO PARA ENTRAR EM CAMPO' : 'PRÓXIMO COMPROMISSO',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          ClubBadge(club: home, size: 72),
                          const SizedBox(height: 8),
                          Text(home.name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceRaised,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text('VS', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          ClubBadge(club: away, size: 72),
                          const SizedBox(height: 8),
                          Text(away.name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoPill(icon: Icons.emoji_events_outlined, label: competitionName),
                    _InfoPill(icon: Icons.calendar_today_rounded, label: calendarDate(fixture.date)),
                    _InfoPill(icon: Icons.schedule_rounded, label: fixture.kickoffLabel),
                    _InfoPill(icon: Icons.stadium_rounded, label: home.stadium.name),
                    _InfoPill(
                      icon: Icons.home_work_rounded,
                      label: fixture.homeClubId == career.userClubId ? 'Mando de campo' : 'Visitante',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.timer_outlined, color: AppColors.green),
                    SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'DURAÇÃO DA TRANSMISSÃO',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                const Text(
                  'Cada opção indica minutos reais por tempo. O Match Engine continua simulando os mesmos 90 minutos.',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 10.5,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                SegmentedButton<int>(
                  segments: [
                    for (final preset in MatchDurationPreset.values)
                      ButtonSegment(
                        value: preset.minutes,
                        label: Text(preset.shortLabel),
                        tooltip: preset.label,
                      ),
                  ],
                  selected: {career.settings.matchDurationMinutes},
                  onSelectionChanged: (selection) => ref
                      .read(gameControllerProvider.notifier)
                      .updateSettings(
                        career.settings.copyWith(
                          matchDurationMinutes: selection.first,
                        ),
                      ),
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
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'PLANO DE JOGO',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: (validation.valid ? AppColors.green : AppColors.warning).withValues(alpha: .14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        validation.valid ? 'PRONTA' : 'REVISAR',
                        style: TextStyle(
                          color: validation.valid ? AppColors.green : AppColors.warning,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Metric(label: 'Formação', value: career.formation.label),
                    const SizedBox(width: 10),
                    Metric(label: 'Titulares', value: '${validation.assignments.length}/11'),
                    const SizedBox(width: 10),
                    Metric(label: 'Força', value: '${validation.averageStrength}'),
                  ],
                ),
                if (!validation.valid) ...[
                  const SizedBox(height: 12),
                  Text(validation.message, style: const TextStyle(color: AppColors.warning)),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LineupScreen(showBackButton: true)),
                        ),
                        icon: const Icon(Icons.groups_2_rounded),
                        label: const Text('Escalação'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const TacticsScreen()),
                        ),
                        icon: const Icon(Icons.tune_rounded),
                        label: const Text('Tática'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: suggestedDiffers || !validation.valid
                        ? () => ref.read(gameControllerProvider.notifier).autoSelectLineup()
                        : null,
                    icon: Icon(
                      suggestedDiffers || !validation.valid
                          ? Icons.auto_fix_high_rounded
                          : Icons.check_circle_rounded,
                    ),
                    label: Text(
                      suggestedDiffers || !validation.valid
                          ? 'Aplicar melhor escalação disponível'
                          : 'Melhor escalação disponível já selecionada',
                    ),
                  ),
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
                    const Icon(Icons.groups_2_rounded, color: AppColors.green),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'QUEM VAI A CAMPO',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ),
                    Text(
                      '${validation.assignments.length}/11',
                      style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                const Text(
                  'Titulares na ordem da formação. OVR em destaque considera a posição ocupada e a condição atual.',
                  style: TextStyle(color: AppColors.muted, fontSize: 10.5, height: 1.3),
                ),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 7,
                    mainAxisSpacing: 7,
                    childAspectRatio: 2.75,
                  ),
                  itemCount: validation.assignments.length,
                  itemBuilder: (context, index) {
                    final assignment = validation.assignments[index];
                    return _StarterPreview(
                      assignment: assignment,
                      accentColor: Color(career.userClub.colors.primaryHex),
                    );
                  },
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
                    const Icon(Icons.medical_information_outlined, color: AppColors.warning),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'INDISPONÍVEIS',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ),
                    Text('${unavailable.length}', style: const TextStyle(fontWeight: FontWeight.w900)),
                  ],
                ),
                const SizedBox(height: 10),
                if (unavailable.isEmpty)
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppColors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Todo o elenco está disponível para a partida.',
                          style: const TextStyle(color: AppColors.muted),
                        ),
                      ),
                    ],
                  )
                else
                  ...unavailable.map(
                    (player) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          PlayerAvatar(
                            player: player,
                            size: 34,
                            accentColor: AppColors.warning,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(player.displayName, style: const TextStyle(fontWeight: FontWeight.w800)),
                                Text(
                                  _availabilityText(player),
                                  style: const TextStyle(color: AppColors.warning, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          OverallShield(value: player.overall, compact: true),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: ready
                  ? () {
                      final live = ref.read(liveMatchControllerProvider.notifier).prepareMatch();
                      if (live != null && context.mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const MatchScreen()),
                        );
                      }
                    }
                  : null,
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(
                !career.isMatchDay
                    ? 'A partida ainda não chegou'
                    : validation.valid
                        ? 'Começar partida'
                        : 'Corrija a escalação para jogar',
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _availabilityText(Player player) => switch (player.availabilityStatus) {
        PlayerAvailabilityStatus.injured =>
          '${player.injury?.name ?? 'Lesão'} • ${player.injury?.roundsRemaining ?? 1} rodada(s)',
        PlayerAvailabilityStatus.suspended =>
          'Suspenso • ${player.discipline.suspendedRounds} rodada(s)',
        PlayerAvailabilityStatus.lowCondition => 'Afastado • condição física ${player.condition}%',
        PlayerAvailabilityStatus.available => 'Disponível',
      };
}

class _StarterPreview extends StatelessWidget {
  const _StarterPreview({required this.assignment, required this.accentColor});

  final AssignedPlayer assignment;
  final Color accentColor;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: assignment.outOfPosition
                ? AppColors.warning.withValues(alpha: .45)
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            PlayerAvatar(
              player: assignment.player,
              size: 32,
              accentColor: accentColor,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assignment.player.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    '${assignment.slot.role.label} • Efetivo ${assignment.effectiveOverall}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: assignment.outOfPosition ? AppColors.warning : AppColors.muted,
                      fontSize: 8.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.green),
            const SizedBox(width: 7),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      );
}
