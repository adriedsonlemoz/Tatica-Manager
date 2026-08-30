import 'package:flutter/material.dart';

import '../../app/widgets/common.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/club/club.dart';
import '../../game/stadium/stadium_engine.dart';

class StadiumClubHeader extends StatelessWidget {
  const StadiumClubHeader({
    super.key,
    required this.club,
    required this.season,
  });

  final Club club;
  final int season;

  @override
  Widget build(BuildContext context) => SectionCard(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          children: [
            ClubBadge(club: club, size: 70),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    club.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Temporada $season',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Row(
                    children: [
                      Icon(Icons.public_rounded, color: AppColors.textSecondary, size: 16),
                      SizedBox(width: 5),
                      Text(
                        'Nível Mundial',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _HeaderMoney(
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: AppColors.green,
                  value: compactMoney(club.money),
                ),
                const SizedBox(height: 11),
                _HeaderMoney(
                  icon: Icons.monetization_on_rounded,
                  iconColor: AppColors.warning,
                  value: compactMoney(club.transferBudget),
                ),
              ],
            ),
          ],
        ),
      );
}

class StadiumRevenuePanel extends StatelessWidget {
  const StadiumRevenuePanel({
    super.key,
    required this.monthRevenue,
    required this.seasonRevenue,
    required this.occupancy,
    required this.monthDeltaPercent,
    required this.onDetails,
  });

  final int monthRevenue;
  final int seasonRevenue;
  final int occupancy;
  final int monthDeltaPercent;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) => _DashboardCard(
        title: 'RECEITA DE BILHETERIA',
        child: Column(
          children: [
            Row(
              children: [
                const _RoundIcon(icon: Icons.local_activity_rounded),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Este mês', style: _smallMuted),
                      const SizedBox(height: 2),
                      Text(
                        compactMoney(monthRevenue),
                        style: const TextStyle(
                          color: AppColors.green,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '${monthDeltaPercent >= 0 ? '+' : ''}$monthDeltaPercent% vs mês anterior',
                        style: const TextStyle(
                          color: AppColors.green,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 10),
            _ValueRow(label: 'Receita na temporada', value: compactMoney(seasonRevenue)),
            const SizedBox(height: 8),
            _ValueRow(label: 'Ocupação projetada', value: '$occupancy%'),
            const SizedBox(height: 12),
            _DetailsButton(label: 'VER DETALHES', onTap: onDetails),
          ],
        ),
      );
}

class StadiumMaintenancePanel extends StatelessWidget {
  const StadiumMaintenancePanel({
    super.key,
    required this.stadium,
    required this.monthlyCost,
    required this.onDetails,
  });

  final Stadium stadium;
  final int monthlyCost;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    final score = StadiumEngine.maintenanceScore(stadium);
    return _DashboardCard(
      title: 'MANUTENÇÃO',
      child: Column(
        children: [
          Row(
            children: [
              const _RoundIcon(icon: Icons.home_repair_service_rounded),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Estado geral', style: _smallMuted),
                    Text(
                      StadiumEngine.conditionLabel(score),
                      style: const TextStyle(
                        color: AppColors.green,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text('Custo operacional', style: _smallMuted),
                    Text(
                      compactMoney(monthlyCost),
                      style: const TextStyle(
                        color: AppColors.green,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          _ConditionLine(label: 'Gramado', icon: Icons.grass_rounded, value: stadium.pitchCondition),
          _ConditionLine(label: 'Estrutura', icon: Icons.apartment_rounded, value: stadium.structureCondition),
          _ConditionLine(label: 'Segurança', icon: Icons.security_rounded, value: stadium.securityCondition),
          _ConditionLine(label: 'Conforto', icon: Icons.chair_alt_rounded, value: stadium.comfortCondition),
          const SizedBox(height: 10),
          _DetailsButton(label: 'VER DETALHES', onTap: onDetails),
        ],
      ),
    );
  }
}

class TrainingCenterPanel extends StatelessWidget {
  const TrainingCenterPanel({
    super.key,
    required this.stadium,
    required this.onDetails,
  });

  final Stadium stadium;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    final quality = StadiumEngine.trainingCenterQuality(stadium);
    final active = stadium.projects.any(
      (project) =>
          project.kind == StadiumProjectKind.trainingCenter && project.isActive,
    );
    return _DashboardCard(
      title: 'CENTRO DE TREINAMENTO',
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GradeCircle(level: stadium.trainingCenterLevel),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Nível atual', style: _smallMuted),
                    Text(
                      StadiumEngine.trainingCenterLabel(stadium),
                      style: const TextStyle(
                        color: AppColors.green,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      active
                          ? 'Há uma melhoria em construção.'
                          : 'Instalações usadas no desenvolvimento dos atletas.',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9.5,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              const Expanded(
                child: Text('Qualidade das instalações', style: _smallMuted),
              ),
              Text(
                '$quality%',
                style: const TextStyle(
                  color: AppColors.green,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: quality / 100,
              minHeight: 6,
              backgroundColor: AppColors.surfaceSoft,
              valueColor: const AlwaysStoppedAnimation(AppColors.green),
            ),
          ),
          const SizedBox(height: 12),
          _DetailsButton(label: 'VER DETALHES', onTap: onDetails),
        ],
      ),
    );
  }
}

class StadiumImprovementsPanel extends StatelessWidget {
  const StadiumImprovementsPanel({
    super.key,
    required this.invested,
    required this.completed,
    required this.inProgress,
    required this.planned,
    required this.onDetails,
  });

  final int invested;
  final int completed;
  final int inProgress;
  final int planned;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) => _DashboardCard(
        title: 'MELHORIAS',
        child: Column(
          children: [
            Row(
              children: [
                const _RoundIcon(icon: Icons.trending_up_rounded),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Investido', style: _smallMuted),
                      Text(
                        compactMoney(invested),
                        style: const TextStyle(
                          color: AppColors.green,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Text('Últimos 12 meses', style: _smallMuted),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _ValueRow(label: 'Melhorias concluídas', value: '$completed'),
            const SizedBox(height: 7),
            _ValueRow(label: 'Em andamento', value: '$inProgress', valueColor: AppColors.warning),
            const SizedBox(height: 7),
            _ValueRow(label: 'Planejadas', value: '$planned', valueColor: AppColors.info),
            const Spacer(),
            _DetailsButton(label: 'VER TODAS', onTap: onDetails),
          ],
        ),
      );
}

class SuggestedStadiumUpgradeCard extends StatelessWidget {
  const SuggestedStadiumUpgradeCard({
    super.key,
    required this.facility,
    required this.cost,
    required this.durationDays,
    required this.availableFunds,
    required this.onTap,
  });

  final StadiumFacility facility;
  final int cost;
  final int durationDays;
  final int availableFunds;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = facility == StadiumFacility.stands
        ? 'Cobertura das Arquibancadas'
        : facility.label;
    final description = facility == StadiumFacility.stands
        ? 'Amplia as arquibancadas e melhora a estrutura para os torcedores.'
        : facility.description;
    final affordable = cost <= availableFunds;
    return SectionCard(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'PRÓXIMA MELHORIA SUGERIDA',
                  style: TextStyle(
                    color: AppColors.green,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.green.withValues(alpha: .45)),
                ),
                child: const Text(
                  'RECOMENDADA',
                  style: TextStyle(
                    color: AppColors.green,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: affordable ? onTap : null,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: Image.asset(
                      'assets/images/stadium/covered_stands.webp',
                      width: 145,
                      height: 88,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.medium,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 9.2,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 9),
                        Row(
                          children: [
                            Expanded(
                              child: _SmallFact(
                                label: 'CUSTO ESTIMADO',
                                icon: Icons.account_balance_wallet_rounded,
                                value: compactMoney(cost),
                              ),
                            ),
                            Expanded(
                              child: _SmallFact(
                                label: 'TEMPO DE CONSTRUÇÃO',
                                icon: Icons.calendar_month_rounded,
                                value: '$durationDays dias',
                              ),
                            ),
                          ],
                        ),
                        if (!affordable) ...[
                          const SizedBox(height: 6),
                          const Text(
                            'Saldo/orçamento insuficiente',
                            style: TextStyle(
                              color: AppColors.warning,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.white, size: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StadiumFacilityGrid extends StatelessWidget {
  const StadiumFacilityGrid({
    super.key,
    required this.club,
    required this.availableFunds,
    required this.onUpgrade,
  });

  final Club club;
  final int availableFunds;
  final void Function(StadiumFacility facility, bool negotiated) onUpgrade;

  @override
  Widget build(BuildContext context) => Column(
        children: StadiumFacility.values.map((facility) {
          final level = StadiumEngine.facilityLevel(club.stadium, facility);
          final cost = StadiumEngine.upgradeCost(club.stadium, facility);
          final kind = StadiumEngine.projectKindForFacility(facility);
          final active = club.stadium.projects.where(
            (project) => project.kind == kind && project.isActive,
          );
          final hasActive = active.isNotEmpty;
          final maxed = level >= StadiumEngine.maxFacilityLevel;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(_facilityIcon(facility), color: AppColors.green, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          facility.label,
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11.5),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          hasActive
                              ? 'Obra em andamento • nível $level → ${level + 1}'
                              : maxed
                                  ? 'Nível máximo'
                                  : 'Nível $level • ${compactMoney(cost)} • ${StadiumEngine.projectDurationDays(kind)} dias',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                  if (!maxed && !hasActive)
                    FilledButton(
                      onPressed: cost <= availableFunds ? () => onUpgrade(facility, false) : null,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        minimumSize: const Size(44, 32),
                      ),
                      child: const Text('Melhorar', style: TextStyle(fontSize: 9)),
                    )
                  else
                    Icon(
                      hasActive ? Icons.schedule_rounded : Icons.check_circle_rounded,
                      color: hasActive ? AppColors.warning : AppColors.green,
                      size: 22,
                    ),
                ],
              ),
            ),
          );
        }).toList(growable: false),
      );
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => SectionCard(
        padding: const EdgeInsets.fromLTRB(12, 11, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.green,
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 11),
            Expanded(child: child),
          ],
        ),
      );
}

class _HeaderMoney extends StatelessWidget {
  const _HeaderMoney({required this.icon, required this.iconColor, required this.value});

  final IconData icon;
  final Color iconColor;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, color: iconColor, size: 19),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        width: 52,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.greenSoft.withValues(alpha: .45),
          border: Border.all(color: AppColors.greenDark, width: 2),
        ),
        child: Icon(icon, color: AppColors.green, size: 27),
      );
}

class _GradeCircle extends StatelessWidget {
  const _GradeCircle({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) => Container(
        width: 52,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.greenDark, width: 2),
        ),
        child: Text(
          '$level',
          style: const TextStyle(
            color: AppColors.green,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
      );
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({required this.label, required this.value, this.valueColor = AppColors.green});

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 9.5),
            ),
          ),
          Text(
            value,
            style: TextStyle(color: valueColor, fontSize: 10.5, fontWeight: FontWeight.w900),
          ),
        ],
      );
}

class _ConditionLine extends StatelessWidget {
  const _ConditionLine({required this.label, required this.icon, required this.value});

  final String label;
  final IconData icon;
  final int value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Icon(icon, color: AppColors.green, size: 14),
            const SizedBox(width: 5),
            SizedBox(
              width: 55,
              child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 8.5)),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: value / 100,
                  minHeight: 5,
                  backgroundColor: AppColors.surfaceSoft,
                  valueColor: const AlwaysStoppedAnimation(AppColors.greenDark),
                ),
              ),
            ),
            const SizedBox(width: 6),
            SizedBox(
              width: 28,
              child: Text(
                '$value%',
                textAlign: TextAlign.right,
                style: const TextStyle(color: AppColors.green, fontSize: 8.5, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      );
}

class _DetailsButton extends StatelessWidget {
  const _DetailsButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 34,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.border),
            foregroundColor: AppColors.textSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: const TextStyle(fontSize: 8.7, fontWeight: FontWeight.w700)),
              const Spacer(),
              const Icon(Icons.chevron_right_rounded, size: 17),
            ],
          ),
        ),
      );
}

class _SmallFact extends StatelessWidget {
  const _SmallFact({required this.label, required this.icon, required this.value});

  final String label;
  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 7.3, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Icon(icon, color: AppColors.green, size: 13),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.green, fontSize: 10.5, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ],
      );
}

IconData _facilityIcon(StadiumFacility facility) => switch (facility) {
      StadiumFacility.stands => Icons.stadium_rounded,
      StadiumFacility.hospitality => Icons.workspace_premium_rounded,
      StadiumFacility.retail => Icons.storefront_rounded,
      StadiumFacility.food => Icons.restaurant_rounded,
      StadiumFacility.advertising => Icons.campaign_rounded,
      StadiumFacility.parking => Icons.local_parking_rounded,
      StadiumFacility.museum => Icons.museum_rounded,
    };

const _smallMuted = TextStyle(
  color: AppColors.textSecondary,
  fontSize: 9,
);
