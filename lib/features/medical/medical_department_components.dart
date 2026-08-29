import 'package:flutter/material.dart';

import '../../app/widgets/common.dart';
import '../../app/widgets/management_dashboard_widgets.dart';
import '../../app/widgets/player_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/player/player.dart';
import '../../game/medical/medical_engine.dart';

class MedicalSummaryGrid extends StatelessWidget {
  const MedicalSummaryGrid({
    super.key,
    required this.injured,
    required this.highRisk,
    required this.averageCondition,
    required this.nextReturnDays,
  });

  final int injured;
  final int highRisk;
  final int averageCondition;
  final int? nextReturnDays;

  @override
  Widget build(BuildContext context) => GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.85,
        children: [
          DashboardStatTile(
            icon: Icons.healing_rounded,
            label: 'Lesionados',
            value: '$injured',
            caption: injured == 0 ? 'Excelente cenário' : 'Baixas ativas',
            color: injured == 0 ? AppColors.green : AppColors.danger,
            compact: true,
          ),
          DashboardStatTile(
            icon: Icons.warning_amber_rounded,
            label: 'Em observação',
            value: '$highRisk',
            caption: highRisk == 0 ? 'Risco baixo' : 'Exige atenção',
            color: highRisk == 0 ? AppColors.green : AppColors.warning,
            compact: true,
          ),
          DashboardStatTile(
            icon: Icons.favorite_rounded,
            label: 'Condição média',
            value: '$averageCondition%',
            caption: averageCondition >= 90 ? 'Grupo bem preparado' : 'Monitorar carga',
            color: averageCondition >= 80 ? AppColors.green : AppColors.warning,
            compact: true,
          ),
          DashboardStatTile(
            icon: Icons.event_available_rounded,
            label: 'Próximo retorno',
            value: nextReturnDays == null ? '—' : '$nextReturnDays d',
            caption: nextReturnDays == null ? 'Sem retorno pendente' : 'Estimativa médica',
            compact: true,
          ),
        ],
      );
}

class MedicalStatusBanner extends StatelessWidget {
  const MedicalStatusBanner({
    super.key,
    required this.injured,
    required this.highRisk,
  });

  final int injured;
  final int highRisk;

  @override
  Widget build(BuildContext context) {
    final healthy = injured == 0;
    final color = healthy ? AppColors.green : AppColors.warning;
    final title = healthy ? 'Excelente notícia!' : 'Departamento em atenção';
    final text = healthy
        ? highRisk == 0
            ? 'Não há lesões ativas e o elenco está em ótimo cenário físico.'
            : 'Não há lesões ativas, mas $highRisk atleta(s) exigem controle de carga.'
        : '$injured atleta(s) estão lesionados. Acompanhe os retornos e o risco físico do elenco.';
    return SectionCard(
      borderColor: color.withValues(alpha: .45),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: .10),
              border: Border.all(color: color.withValues(alpha: .45)),
            ),
            child: Icon(
              healthy ? Icons.verified_user_rounded : Icons.monitor_heart_rounded,
              color: color,
              size: 35,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: color, fontSize: 17, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style:  TextStyle(color: AppColors.muted, fontSize: 10.5, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MedicalPlayerRow extends StatelessWidget {
  const MedicalPlayerRow({
    super.key,
    required this.player,
    required this.accentColor,
    required this.onTap,
  });

  final Player player;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final assessment = MedicalEngine.assess(player);
    final risk = assessment.risk;
    final riskColor = risk >= 70
        ? AppColors.danger
        : risk >= 45
            ? AppColors.warning
            : AppColors.green;
    final status = player.injury != null
        ? 'Lesionado'
        : risk >= 55
            ? 'Atenção'
            : player.condition < 75
                ? 'Recuperação'
                : 'Apto';
    final statusColor = player.injury != null
        ? AppColors.danger
        : status == 'Atenção'
            ? AppColors.warning
            : status == 'Recuperação'
                ? AppColors.info
                : AppColors.green;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            PlayerAvatar(player: player, size: 42, accentColor: accentColor),
            const SizedBox(width: 9),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    player.injury?.name ?? player.primaryPosition.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:  TextStyle(color: AppColors.muted, fontSize: 9.3),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              flex: 3,
              child: _MiniBar(label: '${player.condition}%', value: player.condition / 100, color: AppColors.green),
            ),
            const SizedBox(width: 7),
            Expanded(
              flex: 3,
              child: _MiniBar(label: '$risk%', value: risk / 100, color: riskColor),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 76,
              child: DashboardStatusPill(label: status, color: statusColor),
            ),
          ],
        ),
      ),
    );
  }
}

class MedicalDistributionCard extends StatelessWidget {
  const MedicalDistributionCard({super.key, required this.players});

  final List<Player> players;

  @override
  Widget build(BuildContext context) {
    final excellent = players.where((p) => p.condition >= 90).length;
    final good = players.where((p) => p.condition >= 80 && p.condition < 90).length;
    final regular = players.where((p) => p.condition >= 70 && p.condition < 80).length;
    final attention = players.where((p) => p.condition < 70).length;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardSectionHeader(
            title: 'Distribuição da condição física',
            subtitle: 'Leitura do elenco profissional',
          ),
          const SizedBox(height: 12),
          _DistributionRow(label: 'Ótima (≥ 90%)', count: excellent, total: players.length, color: AppColors.green),
          _DistributionRow(label: 'Boa (80–89%)', count: good, total: players.length, color: AppColors.info),
          _DistributionRow(label: 'Regular (70–79%)', count: regular, total: players.length, color: AppColors.warning),
          _DistributionRow(label: 'Atenção (< 70%)', count: attention, total: players.length, color: AppColors.danger),
        ],
      ),
    );
  }
}

class _MiniBar extends StatelessWidget {
  const _MiniBar({required this.label, required this.value, required this.color});

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 9.5, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          DashboardProgress(value: value, color: color, height: 5),
        ],
      );
}

class _DistributionRow extends StatelessWidget {
  const _DistributionRow({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  final String label;
  final int count;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style:  TextStyle(color: AppColors.muted, fontSize: 10))),
            Text(
              '$count',
              style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 10.5),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 70,
              child: DashboardProgress(
                value: total == 0 ? 0 : count / total,
                color: color,
                height: 5,
              ),
            ),
          ],
        ),
      );
}
