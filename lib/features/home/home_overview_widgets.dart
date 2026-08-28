import 'package:flutter/material.dart';

import '../../app/widgets/common.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/club/club.dart';
import '../../domain/league/standing.dart';

class HomeDailyAdvancePanel extends StatelessWidget {
  const HomeDailyAdvancePanel({
    super.key,
    required this.currentDate,
    required this.daysUntilMatch,
    required this.onAdvance,
  });

  final DateTime currentDate;
  final int daysUntilMatch;
  final VoidCallback onAdvance;

  @override
  Widget build(BuildContext context) {
    final nextDate = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
    ).add(const Duration(days: 1));
    final afterAdvance = daysUntilMatch > 0 ? daysUntilMatch - 1 : 0;
    final matchStatus = afterAdvance == 0
        ? 'o próximo dia será dia de jogo'
        : afterAdvance == 1
            ? 'faltará 1 dia para a partida'
            : 'faltarão $afterAdvance dias para a partida';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.green.withValues(alpha: .32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.event_available_rounded, color: AppColors.green),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'PREPARAÇÃO DIÁRIA',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                '+1 DIA',
                style: TextStyle(
                  color: AppColors.green,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            'Ao avançar, o jogo processa recuperação, contratos, mercado, notícias e a preparação até a próxima partida.',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 11,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onAdvance,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    const Icon(Icons.skip_next_rounded),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Avançar dia',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          Text(
                            '${shortDate(nextDate)} • $matchStatus',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeCompactStandings extends StatelessWidget {
  const HomeCompactStandings({
    super.key,
    required this.standings,
    required this.clubs,
    required this.userClubId,
    this.onClubTap,
  });

  final List<Standing> standings;
  final List<Club> clubs;
  final String userClubId;
  final ValueChanged<String>? onClubTap;

  @override
  Widget build(BuildContext context) {
    final topRows = standings.take(5).toList(growable: false);
    final userIndex = standings.indexWhere((row) => row.clubId == userClubId);
    final showUserSeparately = userIndex >= 5;

    return Column(
      children: [
        const _CompactStandingsHeader(),
        const SizedBox(height: 4),
        for (var index = 0; index < topRows.length; index++)
          _CompactStandingRow(
            position: index + 1,
            row: topRows[index],
            club: _clubFor(topRows[index].clubId),
            highlighted: topRows[index].clubId == userClubId,
            onTap: onClubTap == null ? null : () => onClubTap!(topRows[index].clubId),
          ),
        if (showUserSeparately) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Divider(height: 1, color: AppColors.border),
          ),
          _CompactStandingRow(
            position: userIndex + 1,
            row: standings[userIndex],
            club: _clubFor(standings[userIndex].clubId),
            highlighted: true,
            onTap: onClubTap == null ? null : () => onClubTap!(standings[userIndex].clubId),
          ),
        ],
      ],
    );
  }

  Club _clubFor(String clubId) =>
      clubs.firstWhere((club) => club.id == clubId);
}

class _CompactStandingsHeader extends StatelessWidget {
  const _CompactStandingsHeader();

  static const _headerStyle = TextStyle(
    color: AppColors.muted,
    fontSize: 8,
    fontWeight: FontWeight.w900,
  );

  @override
  Widget build(BuildContext context) => const Row(
        children: [
          SizedBox(width: 20, child: Text('#', style: _headerStyle)),
          SizedBox(width: 26),
          SizedBox(width: 5),
          Expanded(child: Text('CLUBE', style: _headerStyle)),
          _StandingCell('J', header: true),
          _StandingCell('V', header: true),
          _StandingCell('E', header: true),
          _StandingCell('D', header: true),
          _StandingCell('SG', width: 28, header: true),
          _StandingCell('PTS', width: 30, header: true),
        ],
      );
}

class _CompactStandingRow extends StatelessWidget {
  const _CompactStandingRow({
    required this.position,
    required this.row,
    required this.club,
    required this.highlighted,
    this.onTap,
  });

  final int position;
  final Standing row;
  final Club club;
  final bool highlighted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: highlighted
              ? AppColors.green.withValues(alpha: .08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              child: Text(
                '$position',
                style: TextStyle(
                  color: position == 1 ? AppColors.green : AppColors.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            ClubBadge(club: club, size: 26),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                club.shortName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight:
                      highlighted ? FontWeight.w900 : FontWeight.w700,
                ),
              ),
            ),
            _StandingCell('${row.played}'),
            _StandingCell('${row.wins}'),
            _StandingCell('${row.draws}'),
            _StandingCell('${row.losses}'),
            _StandingCell(
              row.goalDifference > 0
                  ? '+${row.goalDifference}'
                  : '${row.goalDifference}',
              width: 28,
            ),
            _StandingCell('${row.points}', width: 30, strong: true),
          ],
        ),
      ),
    );
}

class _StandingCell extends StatelessWidget {
  const _StandingCell(
    this.value, {
    this.width = 20,
    this.header = false,
    this.strong = false,
  });

  final String value;
  final double width;
  final bool header;
  final bool strong;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        child: Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: header ? AppColors.muted : null,
            fontSize: header ? 8 : 10,
            fontWeight:
                header || strong ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      );
}
