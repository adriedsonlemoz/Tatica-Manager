import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/widgets/common.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/finance/club_administration.dart';
import '../../domain/finance/sponsorship.dart';
import '../../game/stadium/stadium_engine.dart';
import 'stadium_actions.dart';

class StadiumScreen extends ConsumerWidget {
  const StadiumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final career = ref.watch(gameControllerProvider).career!;
    final club = career.userClub;
    final stadium = club.stadium;
    final tablePosition = career.standings
            .indexWhere((standing) => standing.clubId == club.id) +
        1;
    final projection = StadiumEngine.settleMatchday(
      club: club,
      tablePosition: tablePosition <= 0 ? 10 : tablePosition,
    );
    final occupancy = stadium.capacity <= 0
        ? 0
        : (projection.attendance * 100 / stadium.capacity).round();
    final stadiumBudget = career.clubAdministration.budgetPlan
        .forDepartment(ClubDepartment.stadium);
    final namingContracts = club.sponsorships
        .where(
          (contract) =>
              contract.type == SponsorshipType.stadium &&
              contract.isActiveIn(career.season),
        )
        .toList(growable: false);
    final namingRights = namingContracts.isEmpty ? null : namingContracts.first;

    return PremiumScaffold(
      appBar: GameTopBar(
        title: 'Estádio',
        subtitle: stadium.name,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
        children: [
          SectionCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stadium.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${stadium.capacity} lugares • ingresso médio ${formatMoney(stadium.ticketPrice)}',
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Editar estádio e ingresso',
                      onPressed: () => showEditStadiumDialog(context, ref),
                      icon: const Icon(
                        Icons.edit_rounded,
                        color: AppColors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                AspectRatio(
                  aspectRatio: 1.72,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: CustomPaint(
                      painter: _StadiumPainter(
                        primary: Color(club.colors.primaryHex),
                        secondary: Color(club.colors.secondaryHex),
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  namingRights == null
                      ? 'Nome próprio do clube. Propostas de naming rights ficam em Finanças.'
                      : 'Naming rights ativo com ${namingRights.sponsorName}; o nome original continua preservado.',
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RESUMO E PROJEÇÃO',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 11),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2.25,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  children: [
                    _SummaryMetric(label: 'Capacidade', value: '${stadium.capacity}'),
                    _SummaryMetric(label: 'Público projetado', value: '${projection.attendance}'),
                    _SummaryMetric(label: 'Ocupação', value: '$occupancy%'),
                    _SummaryMetric(label: 'Ingresso', value: formatMoney(stadium.ticketPrice)),
                    _SummaryMetric(label: 'Receita / jogo', value: compactMoney(projection.total)),
                    _SummaryMetric(
                      label: 'Impacto na torcida',
                      value: StadiumEngine.supporterImpact(
                        club: club,
                        attendance: projection.attendance,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                Text(
                  StadiumEngine.ticketDemandFactor(club: club) >= .98
                      ? 'O preço atual favorece a procura e a ocupação.'
                      : 'O preço atual reduz a procura; diminua o ingresso para buscar maior lotação.',
                  style: const TextStyle(color: AppColors.muted, fontSize: 10.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _FacilityCard(
            facility: StadiumFacility.stands,
            icon: Icons.workspace_premium_rounded,
            level: stadium.standsLevel,
            value: projection.ticketing,
            stadiumBudget: stadiumBudget,
            onUpgrade: (negotiated) => showStadiumUpgradeDialog(
              context,
              ref,
              StadiumFacility.stands,
              negotiated: negotiated,
            ),
          ),
          _FacilityCard(
            facility: StadiumFacility.hospitality,
            icon: Icons.storefront_rounded,
            level: stadium.hospitalityLevel,
            value: projection.hospitality,
            stadiumBudget: stadiumBudget,
            onUpgrade: (negotiated) => showStadiumUpgradeDialog(
              context,
              ref,
              StadiumFacility.hospitality,
              negotiated: negotiated,
            ),
          ),
          _FacilityCard(
            facility: StadiumFacility.retail,
            icon: Icons.storefront_rounded,
            level: stadium.retailLevel,
            value: projection.retail,
            stadiumBudget: stadiumBudget,
            onUpgrade: (negotiated) => showStadiumUpgradeDialog(
              context,
              ref,
              StadiumFacility.retail,
              negotiated: negotiated,
            ),
          ),
          _FacilityCard(
            facility: StadiumFacility.food,
            icon: Icons.restaurant_rounded,
            level: stadium.foodLevel,
            value: projection.food,
            stadiumBudget: stadiumBudget,
            onUpgrade: (negotiated) => showStadiumUpgradeDialog(
              context,
              ref,
              StadiumFacility.food,
              negotiated: negotiated,
            ),
          ),
          _FacilityCard(
            facility: StadiumFacility.advertising,
            icon: Icons.campaign_rounded,
            level: stadium.advertisingLevel,
            value: projection.advertising,
            stadiumBudget: stadiumBudget,
            onUpgrade: (negotiated) => showStadiumUpgradeDialog(
              context,
              ref,
              StadiumFacility.advertising,
              negotiated: negotiated,
            ),
          ),
          _FacilityCard(
            facility: StadiumFacility.parking,
            icon: Icons.local_parking_rounded,
            level: stadium.parkingLevel,
            value: projection.parking,
            stadiumBudget: stadiumBudget,
            onUpgrade: (negotiated) => showStadiumUpgradeDialog(
              context,
              ref,
              StadiumFacility.parking,
              negotiated: negotiated,
            ),
          ),
          _FacilityCard(
            facility: StadiumFacility.museum,
            icon: Icons.museum_rounded,
            level: stadium.museumLevel,
            value: projection.museum,
            stadiumBudget: stadiumBudget,
            onUpgrade: (negotiated) => showStadiumUpgradeDialog(
              context,
              ref,
              StadiumFacility.museum,
              negotiated: negotiated,
            ),
          ),
        ],
      ),
    );
  }
}

class _FacilityCard extends StatelessWidget {
  const _FacilityCard({
    required this.facility,
    required this.icon,
    required this.level,
    required this.value,
    required this.stadiumBudget,
    required this.onUpgrade,
  });

  final StadiumFacility facility;
  final IconData icon;
  final int level;
  final int value;
  final int stadiumBudget;
  final ValueChanged<bool> onUpgrade;

  @override
  Widget build(BuildContext context) => SectionCard(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: .11),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: AppColors.green),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          facility.label,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      Text(
                        level == 0 ? 'BLOQUEADO' : 'Nível $level',
                        style: const TextStyle(
                          color: AppColors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    facility.description,
                    style: const TextStyle(color: AppColors.muted, fontSize: 10.5),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Receita projetada: ${formatMoney(value)} / jogo em casa',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Orçamento disponível: ${formatMoney(stadiumBudget)}',
                    style: const TextStyle(color: AppColors.muted, fontSize: 10),
                  ),
                  if (level < StadiumEngine.maxFacilityLevel) ...[
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 7,
                      runSpacing: 6,
                      children: [
                        FilledButton.tonal(
                          onPressed: () => onUpgrade(false),
                          child: Text(level == 0 ? 'Desbloquear' : 'Melhorar'),
                        ),
                        OutlinedButton(
                          onPressed: () => onUpgrade(true),
                          child: const Text('Negociar obra'),
                        ),
                      ],
                    ),
                  ] else
                    const Padding(
                      padding: EdgeInsets.only(top: 7),
                      child: Text(
                        'Estrutura no nível máximo.',
                        style: TextStyle(color: AppColors.green, fontSize: 10),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.muted, fontSize: 9.5),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      );
}

class _StadiumPainter extends CustomPainter {
  const _StadiumPainter({required this.primary, required this.secondary});

  final Color primary;
  final Color secondary;

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = AppColors.surfaceSoft;
    canvas.drawRect(Offset.zero & size, background);

    final outer = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * .05, size.height * .05, size.width * .90, size.height * .90),
      Radius.circular(size.shortestSide * .10),
    );
    canvas.drawRRect(
      outer,
      Paint()..color = primary.withValues(alpha: .55),
    );

    final inner = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * .13, size.height * .15, size.width * .74, size.height * .70),
      Radius.circular(size.shortestSide * .075),
    );
    canvas.drawRRect(inner, Paint()..color = AppColors.background);

    final pitch = Rect.fromLTWH(
      size.width * .22,
      size.height * .24,
      size.width * .56,
      size.height * .52,
    );
    canvas.drawRect(pitch, Paint()..color = AppColors.pitch);

    final line = Paint()
      ..color = Colors.white.withValues(alpha: .75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRect(pitch, line);
    canvas.drawLine(
      Offset(pitch.center.dx, pitch.top),
      Offset(pitch.center.dx, pitch.bottom),
      line,
    );
    canvas.drawCircle(pitch.center, pitch.height * .11, line);

    final aisle = Paint()..color = secondary.withValues(alpha: .45);
    canvas.drawRect(
      Rect.fromLTWH(size.width * .07, size.height * .43, size.width * .08, size.height * .14),
      aisle,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * .85, size.height * .43, size.width * .08, size.height * .14),
      aisle,
    );
  }

  @override
  bool shouldRepaint(covariant _StadiumPainter oldDelegate) =>
      oldDelegate.primary != primary || oldDelegate.secondary != secondary;
}
