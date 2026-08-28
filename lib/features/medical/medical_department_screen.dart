import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/widgets/common.dart';
import '../../app/widgets/player_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/player/player.dart';
import '../../game/medical/medical_engine.dart';
import '../player/player_profile_screen.dart';

class MedicalDepartmentScreen extends ConsumerWidget {
  const MedicalDepartmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final career = ref.watch(gameControllerProvider).career!;
    final squad = [...career.userClub.squad]
      ..sort((a, b) {
        final injury = (b.injury != null ? 1 : 0).compareTo(a.injury != null ? 1 : 0);
        if (injury != 0) return injury;
        return MedicalEngine.reinjuryRisk(b).compareTo(MedicalEngine.reinjuryRisk(a));
      });
    final injured = squad.where((player) => player.injury != null).toList();
    final highRisk = squad
        .where((player) =>
            player.injury == null && MedicalEngine.reinjuryRisk(player) >= 55)
        .toList();
    return PremiumScaffold(
      safeBottom: true,
      appBar: GameTopBar(
        title: 'Departamento médico',
        subtitle: '${injured.length} lesionado(s) • ${highRisk.length} em atenção',
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
        children: [
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  icon: Icons.healing_rounded,
                  label: 'Lesionados',
                  value: '${injured.length}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.battery_alert_rounded,
                  label: 'Alto risco',
                  value: '${highRisk.length}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.favorite_rounded,
                  label: 'Cond. média',
                  value: '${_averageCondition(squad)}%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (injured.isEmpty)
            const SectionCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.check_circle_rounded, color: AppColors.green),
                title: Text('Nenhum jogador lesionado'),
                subtitle: Text('O departamento médico não possui baixas ativas.'),
              ),
            )
          else ...[
            const Text('LESIONADOS', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            ...injured.map(
              (player) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _MedicalPlayerCard(player: player),
              ),
            ),
          ],
          if (highRisk.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text('ATENÇÃO / RISCO', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            ...highRisk.map(
              (player) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _MedicalPlayerCard(player: player),
              ),
            ),
          ],
          const SizedBox(height: 4),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('PROTOCOLOS MÉDICOS', style: TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 7),
                Text(
                  'A estrutura usa lesão, condição e fadiga reais do jogador. Está preparada para receber futuramente fisioterapia, recuperação acelerada e qualidade da equipe médica sem duplicar a lógica de disponibilidade do elenco.',
                  style: TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static int _averageCondition(List<Player> players) {
    if (players.isEmpty) return 0;
    return (players.fold<int>(0, (sum, player) => sum + player.condition) /
            players.length)
        .round();
  }
}

class _MedicalPlayerCard extends ConsumerWidget {
  const _MedicalPlayerCard({required this.player});

  final Player player;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final career = ref.watch(gameControllerProvider).career!;
    final injury = player.injury;
    final assessment = MedicalEngine.assess(player);
    final severity = assessment.severity;
    final estimatedDays = assessment.estimatedDays;
    final progress = assessment.recoveryProgress;
    final risk = assessment.risk;
    return SectionCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PlayerProfileScreen(
              playerId: player.id,
              clubId: career.userClubId,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  PlayerAvatar(
                    player: player,
                    size: 48,
                    accentColor: Color(career.userClub.colors.primaryHex),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(player.displayName,
                            style: const TextStyle(fontWeight: FontWeight.w900)),
                        Text(
                          injury == null
                              ? '${player.primaryPosition.label} • carga física elevada'
                              : '${injury.name} • $severity',
                          style: TextStyle(
                            color: injury == null ? AppColors.warning : AppColors.danger,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text('$risk%',
                      style: const TextStyle(fontWeight: FontWeight.w900)),
                ],
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  Expanded(child: _MedicalMetric('Condição', '${player.condition}%')),
                  Expanded(child: _MedicalMetric('Fadiga', '${player.fatigue}%')),
                  Expanded(child: _MedicalMetric('Risco', '$risk%')),
                ],
              ),
              if (injury != null) ...[
                const SizedBox(height: 9),
                Text(
                  'Retorno estimado: ${injury.roundsRemaining} rodada(s) • aproximadamente $estimatedDays dias',
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: progress / 100,
                  minHeight: 7,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(height: 4),
                Text(
                  'Progresso estimado da recuperação: $progress%',
                  style: const TextStyle(color: AppColors.muted, fontSize: 10),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MedicalMetric extends StatelessWidget {
  const _MedicalMetric(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 9)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      );
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => SectionCard(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Icon(icon, color: AppColors.green, size: 20),
            const SizedBox(height: 5),
            Text(value,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, fontSize: 9),
            ),
          ],
        ),
      );
}
