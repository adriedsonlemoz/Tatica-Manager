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
                  fontSize: 13,
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
              fontSize: 14,
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
                            style: const TextStyle(fontSize: 13),
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

class HomeSeasonSummaryRow extends StatelessWidget {
  const HomeSeasonSummaryRow({
    super.key,
    required this.played,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.goalsFor,
    required this.goalsAgainst,
  });

  final int played;
  final int wins;
  final int draws;
  final int losses;
  final int goalsFor;
  final int goalsAgainst;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF102536), Color(0xFF0D2130), Color(0xFF0B1C29)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border.withValues(alpha: .82)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                'RESUMO DA TEMPORADA',
                style: TextStyle(
                  color: AppColors.green,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .3,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _SummaryStat(
                    icon: Icons.emoji_events_rounded,
                    iconColor: AppColors.warning,
                    value: '$played',
                    label: 'Jogos',
                  ),
                ),
                const _SummaryDivider(),
                Expanded(
                  child: _SummaryStat(
                    icon: Icons.check_rounded,
                    iconColor: AppColors.green,
                    value: '$wins',
                    label: 'Vitórias',
                    filled: true,
                  ),
                ),
                const _SummaryDivider(),
                Expanded(
                  child: _SummaryStat(
                    icon: Icons.drag_handle_rounded,
                    iconColor: AppColors.textSecondary,
                    value: '$draws',
                    label: 'Empates',
                    filled: true,
                  ),
                ),
                const _SummaryDivider(),
                Expanded(
                  child: _SummaryStat(
                    icon: Icons.close_rounded,
                    iconColor: AppColors.danger,
                    value: '$losses',
                    label: 'Derrotas',
                    filled: true,
                  ),
                ),
                const _SummaryDivider(),
                Expanded(
                  child: _SummaryStat(
                    icon: Icons.stadium_rounded,
                    iconColor: AppColors.white,
                    value: '$goalsFor',
                    label: 'Gols marcados',
                  ),
                ),
                const _SummaryDivider(),
                Expanded(
                  child: _SummaryStat(
                    icon: Icons.shield_rounded,
                    iconColor: AppColors.white,
                    value: '$goalsAgainst',
                    label: 'Gols sofridos',
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    this.filled = false,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final bool filled;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          filled
              ? Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
                  child: Icon(icon, color: AppColors.background, size: 17),
                )
              : Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 7),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 9.2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      );
}


class _SummaryDivider extends StatelessWidget {
  const _SummaryDivider();

  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 62,
        color: AppColors.border.withValues(alpha: .62),
      );
}

class HomeCompactStandings extends StatelessWidget {
  const HomeCompactStandings({
    super.key,
    required this.standings,
    required this.clubs,
    required this.userClubId,
    this.onClubTap,
    this.compactColumns = false,
    this.ultraCompact = false,
    this.maxRows = 5,
    this.pinUser = true,
  });

  final List<Standing> standings;
  final List<Club> clubs;
  final String userClubId;
  final ValueChanged<String>? onClubTap;
  final bool compactColumns;
  final bool ultraCompact;
  final int maxRows;
  final bool pinUser;

  @override
  Widget build(BuildContext context) {
    final topRows = standings.take(maxRows).toList(growable: false);
    final userIndex = standings.indexWhere((row) => row.clubId == userClubId);
    final showUserSeparately = pinUser && userIndex >= maxRows;

    return Column(
      children: [
        _CompactStandingsHeader(
          compactColumns: compactColumns,
          ultraCompact: ultraCompact,
        ),
        SizedBox(height: ultraCompact ? 2 : 4),
        for (var index = 0; index < topRows.length; index++)
          _CompactStandingRow(
            position: index + 1,
            row: topRows[index],
            club: _clubFor(topRows[index].clubId),
            highlighted: topRows[index].clubId == userClubId,
            compactColumns: compactColumns,
            ultraCompact: ultraCompact,
            onTap: onClubTap == null ? null : () => onClubTap!(topRows[index].clubId),
          ),
        if (showUserSeparately) ...[
          Padding(
            padding: EdgeInsets.symmetric(vertical: ultraCompact ? 1 : 3),
            child: Divider(height: 1, color: AppColors.border),
          ),
          _CompactStandingRow(
            position: userIndex + 1,
            row: standings[userIndex],
            club: _clubFor(standings[userIndex].clubId),
            highlighted: true,
            compactColumns: compactColumns,
            ultraCompact: ultraCompact,
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
  const _CompactStandingsHeader({
    required this.compactColumns,
    required this.ultraCompact,
  });

  final bool compactColumns;
  final bool ultraCompact;

  @override
  Widget build(BuildContext context) {
    final positionWidth = ultraCompact ? 12.0 : 20.0;
    final badgeWidth = ultraCompact ? 0.0 : 26.0;
    final gap = ultraCompact ? 0.0 : 5.0;
    final cellWidth = ultraCompact ? 14.0 : 20.0;
    final pointsWidth = ultraCompact ? 20.0 : 30.0;
    final headerStyle = TextStyle(
      color: AppColors.muted,
      fontSize: ultraCompact ? 10.2 : 11,
      fontWeight: FontWeight.w900,
    );
    return Row(
      children: [
        SizedBox(width: positionWidth, child: Text('#', style: headerStyle)),
        SizedBox(width: badgeWidth),
        SizedBox(width: gap),
        Expanded(child: Text('CLUBE', style: headerStyle)),
        _StandingCell('J', width: cellWidth, header: true, compact: ultraCompact),
        if (!compactColumns) ...[
          _StandingCell('V', width: cellWidth, header: true, compact: ultraCompact),
          _StandingCell('E', width: cellWidth, header: true, compact: ultraCompact),
          _StandingCell('D', width: cellWidth, header: true, compact: ultraCompact),
          _StandingCell('SG', width: ultraCompact ? 20 : 28, header: true, compact: ultraCompact),
        ],
        _StandingCell('PTS', width: pointsWidth, header: true, compact: ultraCompact),
      ],
    );
  }
}

class _CompactStandingRow extends StatelessWidget {
  const _CompactStandingRow({
    required this.position,
    required this.row,
    required this.club,
    required this.highlighted,
    required this.compactColumns,
    required this.ultraCompact,
    this.onTap,
  });

  final int position;
  final Standing row;
  final Club club;
  final bool highlighted;
  final bool compactColumns;
  final bool ultraCompact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final positionWidth = ultraCompact ? 12.0 : 20.0;
    final badgeSize = ultraCompact ? 0.0 : 26.0;
    final gap = ultraCompact ? 0.0 : 5.0;
    final cellWidth = ultraCompact ? 14.0 : 20.0;
    final pointsWidth = ultraCompact ? 20.0 : 30.0;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: ultraCompact ? .5 : 2),
        padding: EdgeInsets.symmetric(vertical: ultraCompact ? 2.2 : 5),
        decoration: BoxDecoration(
          color: highlighted
              ? AppColors.green.withValues(alpha: .08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            SizedBox(
              width: positionWidth,
              child: Text(
                '$position',
                style: TextStyle(
                  color: position == 1 ? AppColors.green : AppColors.muted,
                  fontSize: ultraCompact ? 10.8 : 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (!ultraCompact) ...[
              ClubBadge(club: club, size: badgeSize),
              SizedBox(width: gap),
            ],
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  club.name,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: ultraCompact ? 11.2 : 13,
                    fontWeight: highlighted ? FontWeight.w900 : FontWeight.w700,
                  ),
                ),
              ),
            ),
            _StandingCell('${row.played}', width: cellWidth, compact: ultraCompact),
            if (!compactColumns) ...[
              _StandingCell('${row.wins}', width: cellWidth, compact: ultraCompact),
              _StandingCell('${row.draws}', width: cellWidth, compact: ultraCompact),
              _StandingCell('${row.losses}', width: cellWidth, compact: ultraCompact),
              _StandingCell(
                row.goalDifference > 0 ? '+${row.goalDifference}' : '${row.goalDifference}',
                width: ultraCompact ? 20 : 28,
                compact: ultraCompact,
              ),
            ],
            _StandingCell(
              '${row.points}',
              width: pointsWidth,
              strong: true,
              compact: ultraCompact,
            ),
          ],
        ),
      ),
    );
  }
}

class _StandingCell extends StatelessWidget {
  const _StandingCell(
    this.value, {
    this.width = 20,
    this.header = false,
    this.strong = false,
    this.compact = false,
  });

  final String value;
  final double width;
  final bool header;
  final bool strong;
  final bool compact;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        child: Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: header ? AppColors.muted : null,
            fontSize: compact ? (header ? 10 : 10.8) : (header ? 11 : 13),
            fontWeight:
                header || strong ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      );
}
