import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/widgets/common.dart';
import '../../app/widgets/player_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/formation/formation.dart';
import '../../domain/player/player.dart';
import '../../game/lineup/lineup_engine.dart';
import '../player/player_profile_screen.dart';
import '../shared/club_context_header.dart';
import '../shared/compact_formation_pitch.dart';
import '../shared/player_discipline_indicator.dart';
import '../tactics/tactics_screen.dart';
import 'widgets/lineup_candidate_sheet.dart';

class LineupScreen extends ConsumerStatefulWidget {
  const LineupScreen({super.key, this.showBackButton = false});

  final bool showBackButton;

  @override
  ConsumerState<LineupScreen> createState() => _LineupScreenState();
}

class _LineupScreenState extends ConsumerState<LineupScreen> {
  int _benchPage = 0;

  @override
  Widget build(BuildContext context) {
    final career = ref.watch(gameControllerProvider).career!;
    final fixture = career.nextUserFixture;
    final competitionId =
        fixture?.competitionId ?? career.primaryCompetitionId;
    final disciplineByPlayer = <String, PlayerDiscipline>{
      for (final player in career.userClub.squad)
        player.id: career.playerDisciplineForCompetition(
          competitionId,
          player.id,
        ),
    };
    final suspended =
        career.suspendedPlayerIdsForCompetition(competitionId);
    final validation = LineupEngine.validate(
      career.userClub.squad,
      career.starterIds,
      career.formation,
      competitionSuspendedPlayerIds: suspended,
    );
    final assignments = validation.assignments;
    final reserves = career.userClub.squad
        .where((player) => !career.starterIds.contains(player.id))
        .toList();
    bool availableForNextMatch(Player player) =>
        career.isPlayerAvailableForCompetition(player, competitionId);
    final availableBench = reserves.where(availableForNextMatch).toList()
      ..sort(_compareBenchPlayers);
    final unavailable = reserves
        .where((player) => !availableForNextMatch(player))
        .toList()
      ..sort((a, b) => b.overall.compareTo(a.overall));
    final benchPlayers = [...availableBench, ...unavailable];
    final accent = AppColors.readableAccent(
      Color(career.userClub.colors.primaryHex),
    );
    final improvised = assignments
        .where((assignment) => assignment.outOfPosition)
        .length;
    final suspendedCount = disciplineByPlayer.values
        .where((discipline) => discipline.isSuspended)
        .length;
    final atRiskCount = disciplineByPlayer.values
        .where((discipline) => discipline.isAtRisk)
        .length;

    return PremiumScaffold(
      appBar: GameTopBar(
        title: 'Escalação',
        leading: widget.showBackButton
            ? IconButton(
                tooltip: 'Voltar ao pré-jogo',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              )
            : null,
        subtitle:
            'Força ${validation.averageStrength} • ${validation.isValid ? 'Pronta para jogar' : validation.message}',
        actions: [
          IconButton(
            tooltip: 'Táticas',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TacticsScreen()),
            ),
            icon: const Icon(Icons.tune_rounded),
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
              height: 710,
              child: Column(
                children: [
                  ClubContextHeader(
                    club: career.userClub,
                    season: career.season,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SectionCard(
                      padding: const EdgeInsets.fromLTRB(9, 8, 9, 9),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'FORMAÇÃO ATUAL',
                                      style: TextStyle(
                                        color: AppColors.muted,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      career.formation.label,
                                      style: const TextStyle(
                                        color: AppColors.green,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _LineupActionButton(
                                icon: Icons.auto_awesome_rounded,
                                label: 'Padrões',
                                onTap: () => ref
                                    .read(gameControllerProvider.notifier)
                                    .autoSelectLineup(),
                              ),
                              const SizedBox(width: 7),
                              _LineupActionButton(
                                icon: Icons.edit_outlined,
                                label: 'Editar',
                                onTap: () => _showFormationPicker(
                                  context,
                                  career.formation,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              _SummaryPill(
                                icon: Icons.groups_2_rounded,
                                label: '${assignments.length}/11',
                              ),
                              const SizedBox(width: 6),
                              _SummaryPill(
                                icon: Icons.swap_horiz_rounded,
                                label: improvised == 0
                                    ? 'Posições naturais'
                                    : '$improvised improvisado${improvised == 1 ? '' : 's'}',
                                warning: improvised > 0,
                              ),
                              if (suspendedCount > 0 || atRiskCount > 0) ...[
                                const SizedBox(width: 6),
                                _SummaryPill(
                                  icon: suspendedCount > 0
                                      ? Icons.gavel_rounded
                                      : Icons.style_rounded,
                                  label: suspendedCount > 0
                                      ? '$suspendedCount suspenso${suspendedCount == 1 ? '' : 's'}'
                                      : '$atRiskCount pendurado${atRiskCount == 1 ? '' : 's'}',
                                  warning: true,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: CompactFormationPitch(
                              assignments: assignments,
                              accent: accent,
                              disciplines: disciplineByPlayer,
                              onPlayerTap: (assignment) => _chooseReplacement(
                                context,
                                career.userClub.squad,
                                career.starterIds,
                                assignment,
                                accent,
                                suspended,
                              ),
                              onPlayerLongPress: (assignment) =>
                                  Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PlayerProfileScreen(
                                    playerId: assignment.player.id,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const SizedBox(
                    height: 18,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Toque para trocar • segure para abrir o perfil.',
                        style: TextStyle(color: AppColors.muted, fontSize: 8.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 150,
                    child: _BenchPager(
                      players: benchPlayers,
                      availableIds:
                          availableBench.map((player) => player.id).toSet(),
                      availableCount: availableBench.length,
                      disciplines: disciplineByPlayer,
                      formationLabel: career.formation.label,
                      page: _benchPage,
                      onPageChanged: (value) =>
                          setState(() => _benchPage = value),
                      onPlayerTap: (player) => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PlayerProfileScreen(
                            playerId: player.id,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static int _compareBenchPlayers(Player a, Player b) {
    final sector = _sectorOrder(a).compareTo(_sectorOrder(b));
    return sector != 0 ? sector : b.overall.compareTo(a.overall);
  }

  static int _sectorOrder(Player player) => switch (player.primaryPosition) {
        PlayerPosition.gol => 0,
        PlayerPosition.ld || PlayerPosition.le || PlayerPosition.zag => 1,
        PlayerPosition.vol || PlayerPosition.mc || PlayerPosition.mei => 2,
        PlayerPosition.pe ||
        PlayerPosition.pd ||
        PlayerPosition.sa ||
        PlayerPosition.ca => 3,
      };

  Future<void> _showFormationPicker(
    BuildContext context,
    FormationType selected,
  ) async {
    final value = await showModalBottomSheet<FormationType>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ESCOLHER FORMAÇÃO',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final formation in FormationType.values)
                    ChoiceChip(
                      selected: formation == selected,
                      label: SizedBox(
                        width: 64,
                        child: Text(
                          formation.label,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      onSelected: (_) => Navigator.pop(sheetContext, formation),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (value != null) {
      await ref.read(gameControllerProvider.notifier).setFormation(value);
      if (mounted) setState(() => _benchPage = 0);
    }
  }

  Future<void> _chooseReplacement(
    BuildContext context,
    List<Player> squad,
    List<String> starters,
    AssignedPlayer outgoing,
    Color accent,
    Set<String> suspendedIds,
  ) async {
    final candidates = LineupEngine.candidatesForRole(
      squad,
      outgoing.slot.role,
      excludedIds: starters.toSet(),
      competitionSuspendedPlayerIds: suspendedIds,
    );
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => LineupCandidateSheet(
        outgoing: outgoing.player,
        role: outgoing.slot.role,
        candidates: candidates,
        accentColor: accent,
        onSelected: (incoming) async {
          await ref
              .read(gameControllerProvider.notifier)
              .replaceStarter(outgoing.player.id, incoming.id);
          if (sheetContext.mounted) Navigator.of(sheetContext).pop();
          if (mounted) setState(() => _benchPage = 0);
        },
      ),
    );
  }
}

class _LineupActionButton extends StatelessWidget {
  const _LineupActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(92, 39),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        ),
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontSize: 11)),
      );
}

class _BenchPager extends StatelessWidget {
  const _BenchPager({
    required this.players,
    required this.availableIds,
    required this.availableCount,
    required this.disciplines,
    required this.formationLabel,
    required this.page,
    required this.onPageChanged,
    required this.onPlayerTap,
  });

  static const int pageSize = 5;

  final List<Player> players;
  final Set<String> availableIds;
  final int availableCount;
  final Map<String, PlayerDiscipline> disciplines;
  final String formationLabel;
  final int page;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<Player> onPlayerTap;

  @override
  Widget build(BuildContext context) {
    final pageCount = players.isEmpty ? 1 : ((players.length - 1) ~/ pageSize) + 1;
    final safePage = page.clamp(0, pageCount - 1).toInt();
    final visible = players.skip(safePage * pageSize).take(pageSize).toList();
    return SectionCard(
      padding: const EdgeInsets.fromLTRB(9, 7, 9, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 27,
            child: Row(
              children: [
                const Text(
                  'BANCO E ELENCO',
                  style: TextStyle(
                    color: AppColors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                Text(
                  '$formationLabel • $availableCount disponíveis',
                  style: const TextStyle(color: AppColors.muted, fontSize: 8.5),
                ),
                if (pageCount > 1) ...[
                  const SizedBox(width: 5),
                  _PageButton(
                    icon: Icons.chevron_left_rounded,
                    enabled: safePage > 0,
                    onTap: () => onPageChanged(safePage - 1),
                  ),
                  SizedBox(
                    width: 28,
                    child: Text(
                      '${safePage + 1}/$pageCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 8),
                    ),
                  ),
                  _PageButton(
                    icon: Icons.chevron_right_rounded,
                    enabled: safePage + 1 < pageCount,
                    onTap: () => onPageChanged(safePage + 1),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: visible.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum jogador no banco.',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  )
                : Row(
                    children: [
                      for (var index = 0; index < visible.length; index++) ...[
                        if (index > 0) const SizedBox(width: 5),
                        Expanded(
                          child: _BenchPlayerCard(
                            player: visible[index],
                            available: availableIds.contains(visible[index].id),
                            discipline: disciplines[visible[index].id] ??
                                const PlayerDiscipline(),
                            onTap: () => onPlayerTap(visible[index]),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(6),
        child: Icon(
          icon,
          size: 19,
          color: enabled ? AppColors.white : AppColors.muted.withValues(alpha: .35),
        ),
      );
}

class _BenchPlayerCard extends StatelessWidget {
  const _BenchPlayerCard({
    required this.player,
    required this.available,
    required this.discipline,
    required this.onTap,
  });

  final Player player;
  final bool available;
  final PlayerDiscipline discipline;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surfaceRaised,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: available
                  ? AppColors.border
                  : AppColors.warning.withValues(alpha: .55),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  PlayerAvatar(player: player, size: 35),
                  Positioned(
                    top: -3,
                    left: -3,
                    child: Container(
                      width: 17,
                      height: 17,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.greenDark,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${player.shirtNumber}',
                        style: const TextStyle(
                          fontSize: 6.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  if (!available)
                    const Positioned(
                      right: -3,
                      top: -3,
                      child: Icon(
                        Icons.warning_amber_rounded,
                        size: 15,
                        color: AppColors.warning,
                      ),
                    ),
                  if (available &&
                      (discipline.yellowCards > 0 ||
                          discipline.redCards > 0 ||
                          discipline.isSuspended))
                    Positioned(
                      right: -5,
                      top: -4,
                      child: PlayerDisciplineIndicator(
                        discipline: discipline,
                        compact: true,
                        showClear: false,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                player.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 7.5, fontWeight: FontWeight.w800),
              ),
              Text(
                '${player.primaryPosition.label} • ${player.overall}',
                style: TextStyle(
                  color: available ? AppColors.green : AppColors.warning,
                  fontSize: 7,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                available
                    ? _sectorLabel(player)
                    : playerAvailabilityReason(player, discipline),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.muted, fontSize: 5.8),
              ),
              Text(
                'Cond. ${player.condition}%',
                style: const TextStyle(color: AppColors.muted, fontSize: 6.5),
              ),
            ],
          ),
        ),
      );

  static String _sectorLabel(Player player) {
    return switch (player.primaryPosition) {
      PlayerPosition.gol => 'GOLEIROS',
      PlayerPosition.ld || PlayerPosition.le || PlayerPosition.zag =>
        'DEFENSORES',
      PlayerPosition.vol || PlayerPosition.mc || PlayerPosition.mei =>
        'MEIO-CAMPISTAS',
      PlayerPosition.pe ||
      PlayerPosition.pd ||
      PlayerPosition.sa ||
      PlayerPosition.ca => 'ATACANTES',
    };
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.icon,
    required this.label,
    this.warning = false,
  });

  final IconData icon;
  final String label;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final color = warning ? AppColors.warning : AppColors.green;
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: .24)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
