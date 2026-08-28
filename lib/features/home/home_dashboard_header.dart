import 'package:flutter/material.dart';

import '../../app/widgets/common.dart';
import '../../app/widgets/manager_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/career/manager_profile.dart';
import '../../domain/club/club.dart';
import '../../domain/match/match_models.dart';

class HomeClubHeader extends StatelessWidget {
  const HomeClubHeader({
    super.key,
    required this.club,
    required this.manager,
    required this.season,
    required this.competitionName,
    required this.nextMatchLabel,
    required this.unreadMessages,
    required this.onNotificationsTap,
    required this.onInboxTap,
    required this.onManagerTap,
  });

  final Club club;
  final ManagerProfile manager;
  final int season;
  final String competitionName;
  final String nextMatchLabel;
  final int unreadMessages;
  final VoidCallback onNotificationsTap;
  final VoidCallback onInboxTap;
  final VoidCallback onManagerTap;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 14, 16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF050A0D), Color(0xFF08120F), Color(0xFF030607)],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: IgnorePointer(child: _HomeStadiumGlow())),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClubBadge(club: club, size: 64),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          club.name.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: .4,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Temporada $season • $competitionName',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.muted, fontSize: 11),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          nextMatchLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.green,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _HeaderIconButton(
                  icon: Icons.notifications_none_rounded,
                  showDot: unreadMessages > 0,
                  onTap: onNotificationsTap,
                ),
                const SizedBox(width: 4),
                _HeaderIconButton(
                  icon: Icons.mail_outline_rounded,
                  showDot: unreadMessages > 0,
                  badgeText: unreadMessages > 9 ? '9+' : unreadMessages > 0 ? '$unreadMessages' : null,
                  onTap: onInboxTap,
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: onManagerTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 58,
                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF08100E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.green.withValues(alpha: .65)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ManagerAvatar(manager: manager, size: 42),
                        const SizedBox(height: 3),
                        const Text(
                          'TÉCNICO',
                          style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

class HomeStatusGrid extends StatelessWidget {
  const HomeStatusGrid({
    super.key,
    required this.position,
    required this.points,
    required this.nextFixture,
    required this.competitionLabel,
    required this.performanceLabel,
    required this.performanceProgress,
    this.onPositionTap,
    this.onNextMatchTap,
    this.onCompetitionTap,
    this.onPerformanceTap,
  });

  final int position;
  final int points;
  final MatchFixture? nextFixture;
  final String competitionLabel;
  final String performanceLabel;
  final double performanceProgress;
  final VoidCallback? onPositionTap;
  final VoidCallback? onNextMatchTap;
  final VoidCallback? onCompetitionTap;
  final VoidCallback? onPerformanceTap;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _StatusCard(
              icon: Icons.stadium_outlined,
              label: 'POSIÇÃO NA LIGA',
              value: position > 0 ? '$positionº LUGAR' : '—',
              footer: '$points PTS',
              onTap: onPositionTap,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: _StatusCard(
              icon: Icons.calendar_month_rounded,
              label: 'PRÓXIMO JOGO',
              value: nextFixture == null ? 'SEM JOGO' : shortDate(nextFixture!.date),
              footer: nextFixture?.kickoffLabel ?? '—',
              footerAccent: false,
              onTap: onNextMatchTap,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: _StatusCard(
              icon: Icons.emoji_events_outlined,
              label: 'COMPETIÇÃO',
              value: competitionLabel,
              footer: nextFixture == null ? '—' : '${nextFixture!.round}ª ROD.',
              footerAccent: false,
              onTap: onCompetitionTap,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: _StatusCard(
              icon: Icons.trending_up_rounded,
              label: 'DESEMPENHO',
              value: performanceLabel,
              progress: performanceProgress,
              onTap: onPerformanceTap,
            ),
          ),
        ],
      );
}


class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.showDot, required this.onTap, this.badgeText});

  final IconData icon;
  final bool showDot;
  final String? badgeText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 34,
          height: 42,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, size: 25, color: AppColors.white),
              if (showDot)
                Positioned(
                  top: 4,
                  right: 2,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 10, minHeight: 10),
                    padding: badgeText == null ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 3),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: AppColors.green, borderRadius: BorderRadius.circular(8)),
                    child: badgeText == null
                        ? null
                        : Text(badgeText!, style: const TextStyle(color: Colors.black, fontSize: 6, fontWeight: FontWeight.w900)),
                  ),
                ),
            ],
          ),
        ),
      );
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.icon,
    required this.label,
    required this.value,
    this.footer,
    this.footerAccent = true,
    this.progress,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? footer;
  final bool footerAccent;
  final double? progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 100,
          padding: const EdgeInsets.fromLTRB(9, 10, 9, 9),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1515),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: AppColors.green, size: 17),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(label, maxLines: 2, style: const TextStyle(fontSize: 7.5, color: AppColors.muted, fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
              const Spacer(),
              Text(value, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
              if (footer != null) ...[
                const SizedBox(height: 2),
                Text(footer!, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 8, color: footerAccent ? AppColors.green : AppColors.muted, fontWeight: FontWeight.w900)),
              ],
              if (progress != null) ...[
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress!.clamp(0.0, 1.0).toDouble(),
                    minHeight: 6,
                    backgroundColor: const Color(0xFF505958),
                    color: AppColors.green,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
}


class _HomeStadiumGlow extends StatelessWidget {
  const _HomeStadiumGlow();

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _StadiumGlowPainter());
}

class _StadiumGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white.withValues(alpha: .18), Colors.transparent],
      ).createShader(Rect.fromCircle(center: Offset(size.width * .78, size.height * .72), radius: size.width * .28));
    canvas.drawCircle(Offset(size.width * .78, size.height * .72), size.width * .28, glow);
    final line = Paint()..color = Colors.white.withValues(alpha: .05)..strokeWidth = 1;
    for (var index = 0; index < 5; index++) {
      final y = size.height * (.67 + index * .045);
      canvas.drawLine(Offset(size.width * .58, y), Offset(size.width, y - 12), line);
    }
  }

  @override
  bool shouldRepaint(covariant _StadiumGlowPainter oldDelegate) => false;
}

