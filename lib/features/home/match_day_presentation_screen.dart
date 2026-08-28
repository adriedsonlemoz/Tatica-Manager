import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/widgets/common.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/competition_catalog.dart';
import '../../domain/club/club.dart';
import '../match/pre_match_screen.dart';

class MatchDayPresentationScreen extends ConsumerWidget {
  const MatchDayPresentationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final career = ref.watch(gameControllerProvider).career!;
    final fixture = career.nextUserFixture;
    if (fixture == null) {
      return const PremiumScaffold(
        body: Center(child: Text('Nenhuma partida pendente.')),
      );
    }
    final home = career.clubs.firstWhere((club) => club.id == fixture.homeClubId);
    final away = career.clubs.firstWhere((club) => club.id == fixture.awayClubId);
    final userAtHome = fixture.homeClubId == career.userClubId;
    final competition = CompetitionCatalog.displayNameForId(fixture.competitionId);

    return PopScope(
      canPop: true,
      child: PremiumScaffold(
        safeBottom: true,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
            children: [
              Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.green.withValues(alpha: .35)),
                    ),
                    child: Text(
                      'RODADA ${fixture.round}',
                      style: const TextStyle(
                        color: AppColors.green,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .7,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: .82, end: 1),
                duration: const Duration(milliseconds: 520),
                curve: Curves.easeOutBack,
                builder: (context, value, child) => Transform.scale(
                  scale: value,
                  child: child,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.green.withValues(alpha: .12),
                        border: Border.all(
                          color: AppColors.green.withValues(alpha: .48),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.sports_soccer_rounded,
                        color: AppColors.green,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'HOJE É DIA DE JOGO',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.green,
                        fontSize: 27,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .7,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      competition,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SectionCard(
                borderColor: AppColors.green,
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _ClubSide(
                            label: userAtHome ? 'SEU TIME • CASA' : 'MANDANTE',
                            club: home,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            children: [
                              Text(
                                fixture.kickoffLabel,
                                style: const TextStyle(
                                  color: AppColors.green,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceRaised,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Text(
                                  'VS',
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: _ClubSide(
                            label: userAtHome ? 'VISITANTE' : 'SEU TIME • FORA',
                            club: away,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Divider(height: 1),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _InfoChip(
                          icon: Icons.calendar_month_rounded,
                          text: fullDate(fixture.date),
                        ),
                        _InfoChip(
                          icon: Icons.schedule_rounded,
                          text: fixture.kickoffLabel,
                        ),
                        _InfoChip(
                          icon: Icons.stadium_rounded,
                          text: home.stadium.name,
                        ),
                        _InfoChip(
                          icon: Icons.home_work_rounded,
                          text: userAtHome ? 'Mando de campo' : 'Jogo fora de casa',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SectionCard(
                child: Row(
                  children: [
                    const Icon(Icons.tips_and_updates_rounded, color: AppColors.green),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        userAtHome
                            ? 'A torcida estará ao seu lado. Revise escalação, condição física e plano de jogo antes do apito inicial.'
                            : 'Jogo como visitante. Revise a equipe e prepare o plano para enfrentar a pressão fora de casa.',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const PreMatchScreen()),
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Ir para preparação da equipe'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClubSide extends StatelessWidget {
  const _ClubSide({required this.label, required this.club});

  final String label;
  final Club club;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 8.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          ClubBadge(club: club, size: 74),
          const SizedBox(height: 8),
          Text(
            club.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      );
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: AppColors.green),
            const SizedBox(width: 6),
            Text(text, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700)),
          ],
        ),
      );
}
