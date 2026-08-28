import 'package:flutter/material.dart';

import '../../app/widgets/common.dart';
import '../../app/widgets/management_dashboard_widgets.dart';
import '../../app/widgets/player_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/club/club.dart';
import '../../domain/player/player.dart';
import '../../game/youth/youth_academy_engine.dart';

class YouthAcademyOverview extends StatelessWidget {
  const YouthAcademyOverview({
    super.key,
    required this.club,
    required this.players,
  });

  final Club club;
  final List<Player> players;

  @override
  Widget build(BuildContext context) {
    final averageAge = players.isEmpty
        ? 0.0
        : players.fold<int>(0, (sum, player) => sum + player.age) / players.length;
    final averageOverall = players.isEmpty
        ? 0.0
        : players.fold<int>(0, (sum, player) => sum + player.overall) / players.length;
    final averagePotential = players.isEmpty
        ? 0.0
        : players.fold<int>(0, (sum, player) => sum + player.potential) / players.length;
    return SectionCard(
      borderColor: AppColors.green.withValues(alpha: .34),
      child: Column(
        children: [
          Row(
            children: [
              ClubBadge(club: club, size: 56),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Academia ${club.shortName}',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      players.isEmpty
                          ? 'Nenhum jovem disponível no momento'
                          : 'Formação vinculada ao elenco de ${club.name}',
                      style: const TextStyle(color: AppColors.muted, fontSize: 10.5),
                    ),
                  ],
                ),
              ),
              DashboardStatusPill(
                label: '${players.length} jovens',
                color: AppColors.green,
                icon: Icons.school_outlined,
              ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.0,
            children: [
              DashboardStatTile(
                icon: Icons.groups_2_outlined,
                label: 'Jogadores da base',
                value: '${players.length}',
                compact: true,
              ),
              DashboardStatTile(
                icon: Icons.cake_outlined,
                label: 'Idade média',
                value: averageAge.toStringAsFixed(1),
                compact: true,
              ),
              DashboardStatTile(
                icon: Icons.speed_rounded,
                label: 'OVR médio',
                value: averageOverall.toStringAsFixed(1),
                compact: true,
              ),
              DashboardStatTile(
                icon: Icons.trending_up_rounded,
                label: 'Potencial médio',
                value: averagePotential.toStringAsFixed(1),
                compact: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class YouthProspectHighlight extends StatelessWidget {
  const YouthProspectHighlight({
    super.key,
    required this.player,
    required this.accentColor,
    required this.onOpen,
  });

  final Player player;
  final Color accentColor;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final low = YouthAcademyEngine.estimatedPotentialLow(player);
    final high = YouthAcademyEngine.estimatedPotentialHigh(player);
    return SectionCard(
      padding: const EdgeInsets.all(13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardSectionHeader(
            title: 'Destaque da base',
            subtitle: 'Maior potencial atual da academia',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 82,
                height: 92,
                alignment: Alignment.bottomCenter,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accentColor.withValues(alpha: .42),
                      AppColors.surfaceRaised,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: accentColor.withValues(alpha: .30)),
                ),
                child: PlayerAvatar(
                  player: player,
                  size: 70,
                  accentColor: accentColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            player.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                          ),
                        ),
                        OverallShield(value: player.overall, compact: true),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${player.primaryPosition.label} • ${player.age} anos • ${player.nationality}',
                      style: const TextStyle(color: AppColors.muted, fontSize: 10),
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        Expanded(
                          child: _ProspectMetric(label: 'Potencial', value: '$low–$high'),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: _ProspectMetric(label: 'Condição', value: '${player.condition}%'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onOpen,
              icon: const Icon(Icons.person_search_rounded, size: 17),
              label: const Text('Ver jogador'),
            ),
          ),
        ],
      ),
    );
  }
}

class YouthPlayerCard extends StatelessWidget {
  const YouthPlayerCard({
    super.key,
    required this.player,
    required this.accentColor,
    required this.onOpen,
    required this.onPromote,
  });

  final Player player;
  final Color accentColor;
  final VoidCallback onOpen;
  final VoidCallback onPromote;

  @override
  Widget build(BuildContext context) {
    final low = YouthAcademyEngine.estimatedPotentialLow(player);
    final high = YouthAcademyEngine.estimatedPotentialHigh(player);
    final progress = ((high - player.overall) / 35).clamp(0.12, 1.0).toDouble();
    return SectionCard(
      padding: const EdgeInsets.fromLTRB(11, 10, 10, 10),
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          PlayerAvatar(player: player, size: 48, accentColor: accentColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        player.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    Text(
                      '${player.overall}',
                      style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${player.age} anos • ${player.primaryPosition.label} • potencial est. $low–$high',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted, fontSize: 9.8),
                ),
                const SizedBox(height: 7),
                DashboardProgress(value: progress, color: accentColor),
                const SizedBox(height: 5),
                Text(
                  _report(player, low, high),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted, fontSize: 9.5, height: 1.25),
                ),
              ],
            ),
          ),
          const SizedBox(width: 7),
          Column(
            children: [
              IconButton(
                tooltip: 'Ver relatório',
                visualDensity: VisualDensity.compact,
                onPressed: onOpen,
                icon: const Icon(Icons.person_search_rounded, color: AppColors.muted),
              ),
              IconButton(
                tooltip: 'Promover ao profissional',
                visualDensity: VisualDensity.compact,
                onPressed: onPromote,
                icon: const Icon(Icons.arrow_upward_rounded, color: AppColors.green),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _report(Player player, int low, int high) {
    final gap = high - player.overall;
    if (gap >= 20) return 'Teto técnico muito interessante; vale acompanhar a evolução.';
    if (gap >= 12) return 'Bom espaço para evolução e desenvolvimento gradual.';
    return 'Potencial próximo do nível atual; pode compor o profissional.';
  }
}

class _ProspectMetric extends StatelessWidget {
  const _ProspectMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 8.5)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
          ],
        ),
      );
}
