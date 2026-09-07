import 'package:flutter/material.dart';

import '../../app/widgets/common.dart';
import '../../app/widgets/manager_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../data/competition_catalog.dart';
import '../../domain/season/career_state.dart';

class CareerArrivalScreen extends StatelessWidget {
  const CareerArrivalScreen({
    super.key,
    required this.career,
    required this.onContinue,
  });

  final CareerState career;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final club = career.userClub;
    final manager = career.manager;
    final competition = CompetitionCatalog.displayNameFor(
      CompetitionCatalog.primarySeriesForClub(club.id),
    );
    final clubAccent = AppColors.readableAccent(
      Color(club.colors.primaryHex),
    );

    return PremiumScaffold(
      safeBottom: true,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF172831), AppColors.background],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final minHeight = constraints.maxHeight.isFinite
                ? (constraints.maxHeight - 32)
                    .clamp(0.0, double.infinity)
                    .toDouble()
                : 0.0;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: minHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const _PresentationKicker(),
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.surfaceRaised,
                                AppColors.surface,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: clubAccent.withValues(alpha: .48),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: clubAccent.withValues(alpha: .10),
                                blurRadius: 28,
                                offset: const Offset(0, 14),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              ClubBadge(club: club, size: 86),
                              const SizedBox(height: 12),
                              const Text(
                                'NOVO DESAFIO',
                                style: TextStyle(
                                  color: AppColors.green,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                club.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 24,
                                  height: 1.08,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '$competition • Temporada ${career.season}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(height: 1, color: AppColors.border),
                              const SizedBox(height: 16),
                              ManagerAvatar(manager: manager, size: 96),
                              const SizedBox(height: 10),
                              Text(
                                manager.preferredName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 3),
                              const Text(
                                'Novo treinador do clube',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.green,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 13),
                              Text(
                                '${manager.preferredName} inicia sua trajetória no ${club.name}. A temporada começa com o objetivo de conduzir o clube no $competition.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                  height: 1.42,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 11,
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.green.withValues(alpha: .08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.green
                                        .withValues(alpha: .22),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.verified_rounded,
                                      color: AppColors.green,
                                      size: 18,
                                    ),
                                    SizedBox(width: 7),
                                    Flexible(
                                      child: Text(
                                        'Apresentação exibida somente na primeira entrada desta carreira.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 11,
                                          height: 1.25,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: onContinue,
                            icon: const Icon(Icons.sports_soccer_rounded),
                            label: const Text('Começar carreira'),
                          ),
                        ),
                        const SizedBox(height: 7),
                        const Text(
                          'A partir daqui, a temporada começa oficialmente.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PresentationKicker extends StatelessWidget {
  const _PresentationKicker();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.green.withValues(alpha: .09),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.green.withValues(alpha: .28)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_rounded, color: AppColors.green, size: 18),
            SizedBox(width: 6),
            Text(
              'APRESENTAÇÃO OFICIAL',
              style: TextStyle(
                color: AppColors.green,
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      );
}
