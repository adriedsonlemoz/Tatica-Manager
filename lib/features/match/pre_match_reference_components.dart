import 'package:flutter/material.dart';

import '../../app/widgets/common.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/club/club.dart';
import '../../domain/formation/formation.dart';
import '../../domain/match/match_models.dart';
import '../../domain/player/player.dart';
import '../../domain/tactic/tactic.dart';
import '../../game/lineup/lineup_engine.dart';
import '../../game/match/engine/match_strength_calculator.dart';

class PreMatchReferenceHero extends StatelessWidget {
  const PreMatchReferenceHero({
    super.key,
    required this.home,
    required this.away,
    required this.fixture,
    required this.competitionName,
    required this.homeForm,
    required this.awayForm,
  });

  final Club home;
  final Club away;
  final MatchFixture fixture;
  final String competitionName;
  final List<String> homeForm;
  final List<String> awayForm;

  @override
  Widget build(BuildContext context) => _ReferencePanel(
        borderColor: AppColors.green.withValues(alpha: .42),
        padding: const EdgeInsets.fromLTRB(15, 13, 15, 15),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  color: AppColors.green,
                  size: 19,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    competitionName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.green,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: _HeroTeam(
                    club: home,
                    form: homeForm,
                  ),
                ),
                SizedBox(
                  width: 136,
                  child: Column(
                    children: [
                      const Text(
                        'VS',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 30,
                          height: 1,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _HeroInfoLine(
                        icon: Icons.calendar_month_rounded,
                        text: '${fullDate(fixture.date)} - ${fixture.kickoffLabel}',
                      ),
                      const SizedBox(height: 7),
                      _HeroInfoLine(
                        icon: Icons.stadium_rounded,
                        text: home.stadium.name,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _HeroTeam(
                    club: away,
                    form: awayForm,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

class _HeroTeam extends StatelessWidget {
  const _HeroTeam({required this.club, required this.form});

  final Club club;
  final List<String> form;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          SizedBox(
            height: 82,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: ClubBadge(club: club, size: 82),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            club.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              height: 1.08,
            ),
          ),
          const SizedBox(height: 8),
          _RecentFormRow(values: form),
        ],
      );
}

class _RecentFormRow extends StatelessWidget {
  const _RecentFormRow({required this.values});

  final List<String> values;

  @override
  Widget build(BuildContext context) => Wrap(
        alignment: WrapAlignment.center,
        spacing: 4,
        runSpacing: 4,
        children: [
          for (final value in values)
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: switch (value) {
                  'V' => AppColors.greenDark,
                  'E' => AppColors.warning,
                  'D' => AppColors.danger,
                  _ => AppColors.surfaceSoft,
                },
              ),
              child: Text(
                value,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
        ],
      );
}

class _HeroInfoLine extends StatelessWidget {
  const _HeroInfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 18),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10.2,
                height: 1.15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
}

class PreMatchTacticalComparison extends StatelessWidget {
  const PreMatchTacticalComparison({
    super.key,
    required this.userFormation,
    required this.opponentFormation,
    required this.userTactic,
    required this.opponentTactic,
    required this.userStrength,
    required this.opponentStrength,
  });

  final FormationType userFormation;
  final FormationType opponentFormation;
  final Tactic userTactic;
  final Tactic opponentTactic;
  final TeamMatchStrength userStrength;
  final TeamMatchStrength opponentStrength;

  @override
  Widget build(BuildContext context) => _ReferencePanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle('CONFRONTO TÁTICO'),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 10,
                  child: _FormationSide(
                    formation: userFormation,
                    tactic: userTactic,
                    dotColor: AppColors.green,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  flex: 13,
                  child: Column(
                    children: [
                      _StrengthComparison(
                        icon: Icons.sports_soccer_rounded,
                        label: 'ATAQUE',
                        left: userStrength.attack,
                        right: opponentStrength.attack,
                      ),
                      const SizedBox(height: 12),
                      _StrengthComparison(
                        icon: Icons.groups_2_rounded,
                        label: 'MEIO-CAMPO',
                        left: userStrength.midfield,
                        right: opponentStrength.midfield,
                      ),
                      const SizedBox(height: 12),
                      _StrengthComparison(
                        icon: Icons.shield_rounded,
                        label: 'DEFESA',
                        left: userStrength.defense,
                        right: opponentStrength.defense,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  flex: 10,
                  child: _FormationSide(
                    formation: opponentFormation,
                    tactic: opponentTactic,
                    dotColor: AppColors.info,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

class _FormationSide extends StatelessWidget {
  const _FormationSide({
    required this.formation,
    required this.tactic,
    required this.dotColor,
  });

  final FormationType formation;
  final Tactic tactic;
  final Color dotColor;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(
            formation.label,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            tactic.mentality.label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 9.6,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 7),
          _MiniFormationPitch(
            formation: formation,
            dotColor: dotColor,
          ),
        ],
      );
}

class _MiniFormationPitch extends StatelessWidget {
  const _MiniFormationPitch({
    required this.formation,
    required this.dotColor,
  });

  final FormationType formation;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    final slots = FormationCatalog.slots[formation] ?? const <FormationSlot>[];
    return AspectRatio(
      aspectRatio: 1.35,
      child: LayoutBuilder(
        builder: (context, constraints) => Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: const Color(0xFF0B171A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: dotColor.withValues(alpha: .32),
            ),
          ),
          child: Stack(
            children: [
              const Positioned.fill(child: CustomPaint(painter: _MiniPitchPainter())),
              for (final slot in slots)
                Positioned(
                  left: (slot.x * constraints.maxWidth - 4.5)
                      .clamp(1.5, constraints.maxWidth - 10)
                      .toDouble(),
                  top: (slot.y * constraints.maxHeight - 4.5)
                      .clamp(1.5, constraints.maxHeight - 10)
                      .toDouble(),
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: dotColor,
                      boxShadow: [
                        BoxShadow(
                          color: dotColor.withValues(alpha: .35),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniPitchPainter extends CustomPainter {
  const _MiniPitchPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: .18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final rect = Rect.fromLTWH(5, 5, size.width - 10, size.height - 10);
    canvas.drawRect(rect, paint);
    canvas.drawLine(
      Offset(size.width / 2, 5),
      Offset(size.width / 2, size.height - 5),
      paint,
    );
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 11, paint);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(5, size.height / 2),
        width: 20,
        height: size.height * .42,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width - 5, size.height / 2),
        width: 20,
        height: size.height * .42,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StrengthComparison extends StatelessWidget {
  const _StrengthComparison({
    required this.icon,
    required this.label,
    required this.left,
    required this.right,
  });

  final IconData icon;
  final String label;
  final double left;
  final double right;

  @override
  Widget build(BuildContext context) {
    final leftFactor = (left / 105).clamp(.15, 1).toDouble();
    final rightFactor = (right / 105).clamp(.15, 1).toDouble();
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: AppColors.green),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 8.6,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: FractionallySizedBox(
                  widthFactor: leftFactor,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: rightFactor,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.info,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class PreMatchProbableLineups extends StatelessWidget {
  const PreMatchProbableLineups({
    super.key,
    required this.userClub,
    required this.opponent,
    required this.userAssignments,
    required this.opponentAssignments,
  });

  final Club userClub;
  final Club opponent;
  final List<AssignedPlayer> userAssignments;
  final List<AssignedPlayer> opponentAssignments;

  @override
  Widget build(BuildContext context) => _ReferencePanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle('ESCALAÇÃO PROVÁVEL'),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _LineupColumn(
                    club: userClub,
                    assignments: userAssignments,
                    numberColor: AppColors.green,
                  ),
                ),
                Container(
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 9),
                  height: 222,
                  color: AppColors.border.withValues(alpha: .65),
                ),
                Expanded(
                  child: _LineupColumn(
                    club: opponent,
                    assignments: opponentAssignments,
                    numberColor: AppColors.info,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

class _LineupColumn extends StatelessWidget {
  const _LineupColumn({
    required this.club,
    required this.assignments,
    required this.numberColor,
  });

  final Club club;
  final List<AssignedPlayer> assignments;
  final Color numberColor;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Row(
            children: [
              ClubBadge(club: club, size: 27),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  club.shortName.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (var index = 0; index < assignments.length; index++)
            _LineupPlayerRow(
              assignment: assignments[index],
              fallbackNumber: index + 1,
              numberColor: numberColor,
            ),
        ],
      );
}

class _LineupPlayerRow extends StatelessWidget {
  const _LineupPlayerRow({
    required this.assignment,
    required this.fallbackNumber,
    required this.numberColor,
  });

  final AssignedPlayer assignment;
  final int fallbackNumber;
  final Color numberColor;

  @override
  Widget build(BuildContext context) {
    final shirt = assignment.player.shirtNumber > 0
        ? assignment.player.shirtNumber
        : fallbackNumber;
    return SizedBox(
      height: 17.2,
      child: Row(
        children: [
          SizedBox(
            width: 21,
            child: Text(
              '$shirt',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: numberColor,
                fontSize: 9.3,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 3),
          Expanded(
            child: Text(
              assignment.player.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 9.2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 3),
          Text(
            assignment.slot.role.label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 8.4,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class PreMatchAbsences extends StatelessWidget {
  const PreMatchAbsences({
    super.key,
    required this.userUnavailable,
    required this.opponentUnavailable,
    required this.competitionSuspendedPlayerIds,
  });

  final List<Player> userUnavailable;
  final List<Player> opponentUnavailable;
  final Set<String> competitionSuspendedPlayerIds;

  @override
  Widget build(BuildContext context) => _ReferencePanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle('DESFALQUES'),
            const SizedBox(height: 9),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _AbsenceColumn(
                    players: userUnavailable,
                    suspendedIds: competitionSuspendedPlayerIds,
                  ),
                ),
                Container(
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  constraints: const BoxConstraints(minHeight: 58),
                  color: AppColors.border.withValues(alpha: .65),
                ),
                Expanded(
                  child: _AbsenceColumn(
                    players: opponentUnavailable,
                    suspendedIds: competitionSuspendedPlayerIds,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

class _AbsenceColumn extends StatelessWidget {
  const _AbsenceColumn({required this.players, required this.suspendedIds});

  final List<Player> players;
  final Set<String> suspendedIds;

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: AppColors.green, size: 17),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                'Sem desfalques',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 9.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        for (final player in players)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: AppColors.danger, width: 1.3),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: AppColors.danger,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${player.displayName} (${player.primaryPosition.label})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 9.3,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        _absenceText(player, suspendedIds),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 8.4,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  static String _absenceText(Player player, Set<String> suspendedIds) {
    if (player.injury != null) {
      final rounds = player.injury!.roundsRemaining;
      return '${player.injury!.name} • fora por $rounds rodada(s)';
    }
    if (suspendedIds.contains(player.id)) return 'Suspenso nesta competição';
    if (player.condition < 35) return 'Condição física ${player.condition}%';
    return 'Indisponível';
  }
}

class PreMatchActionCards extends StatelessWidget {
  const PreMatchActionCards({
    super.key,
    required this.onLineup,
    required this.onTactics,
    required this.onKits,
  });

  final VoidCallback onLineup;
  final VoidCallback onTactics;
  final VoidCallback onKits;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: _PreMatchActionCard(
              label: 'ESCALAÇÃO',
              icon: const _LineupBoardGlyph(),
              onTap: onLineup,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _PreMatchActionCard(
              label: 'TÁTICA',
              icon: const _TacticClipboardGlyph(),
              onTap: onTactics,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _PreMatchActionCard(
              label: 'UNIFORMES',
              icon: const Icon(
                Icons.checkroom_rounded,
                color: AppColors.green,
                size: 42,
              ),
              onTap: onKits,
            ),
          ),
        ],
      );
}

class _PreMatchActionCard extends StatelessWidget {
  const _PreMatchActionCard({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Ink(
            height: 112,
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF11221C), Color(0xFF0F1A1B)],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: AppColors.green.withValues(alpha: .55),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.green.withValues(alpha: .07),
                  blurRadius: 14,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 47, child: Center(child: icon)),
                const SizedBox(height: 7),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 3),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.green,
                      size: 17,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}

class _LineupBoardGlyph extends StatelessWidget {
  const _LineupBoardGlyph();

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 43,
        height: 43,
        child: const CustomPaint(painter: _LineupBoardPainter()),
      );
}

class _LineupBoardPainter extends CustomPainter {
  const _LineupBoardPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = AppColors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7;
    final dot = Paint()..color = AppColors.green;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(3, 3, size.width - 6, size.height - 6),
      const Radius.circular(3),
    );
    canvas.drawRRect(rect, line);
    canvas.drawLine(
      Offset(size.width / 2, 3),
      Offset(size.width / 2, size.height - 3),
      line,
    );
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 5.5, line);
    const points = [
      Offset(.16, .50),
      Offset(.32, .25),
      Offset(.32, .73),
      Offset(.50, .35),
      Offset(.50, .65),
      Offset(.68, .25),
      Offset(.68, .73),
      Offset(.84, .50),
    ];
    for (final point in points) {
      canvas.drawCircle(
        Offset(point.dx * size.width, point.dy * size.height),
        2.3,
        dot,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TacticClipboardGlyph extends StatelessWidget {
  const _TacticClipboardGlyph();

  @override
  Widget build(BuildContext context) => Stack(
        alignment: Alignment.center,
        children: [
          const Icon(
            Icons.assignment_outlined,
            color: AppColors.green,
            size: 45,
          ),
          Positioned(
            top: 17,
            child: Row(
              children: [
                _glyphMark('×'),
                const SizedBox(width: 5),
                _glyphMark('○'),
              ],
            ),
          ),
          Positioned(
            bottom: 8,
            child: Container(
              width: 22,
              height: 1.5,
              color: AppColors.green,
            ),
          ),
        ],
      );

  static Widget _glyphMark(String value) => Text(
        value,
        style: const TextStyle(
          color: AppColors.green,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      );
}

class PreMatchBottomActions extends StatelessWidget {
  const PreMatchBottomActions({
    super.key,
    required this.enabled,
    required this.simulating,
    required this.onPlay,
    required this.onSimulate,
  });

  final bool enabled;
  final bool simulating;
  final VoidCallback onPlay;
  final VoidCallback onSimulate;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: enabled && !simulating ? onPlay : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: const Color(0xFF12200A),
                  disabledBackgroundColor: AppColors.surfaceSoft,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
                icon: const Icon(Icons.play_arrow_rounded, size: 23),
                label: const Text(
                  'JOGAR PARTIDA',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: enabled && !simulating ? onSimulate : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.green,
                  side: BorderSide(
                    color: enabled
                        ? AppColors.green
                        : AppColors.border,
                    width: 1.2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
                icon: simulating
                    ? const SizedBox(
                        width: 17,
                        height: 17,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.green,
                        ),
                      )
                    : const Icon(Icons.fast_forward_rounded, size: 23),
                label: Text(
                  simulating ? 'SIMULANDO...' : 'SIMULAR',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
}

class _ReferencePanel extends StatelessWidget {
  const _ReferencePanel({
    required this.child,
    this.padding = const EdgeInsets.all(13),
    this.borderColor,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF12232B), Color(0xFF0E1B22)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor ?? AppColors.border.withValues(alpha: .75),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x25000000),
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: child,
      );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: AppColors.green,
          fontSize: 12.5,
          fontWeight: FontWeight.w900,
          letterSpacing: .15,
        ),
      );
}
