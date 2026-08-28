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

    return PremiumScaffold(
      safeBottom: true,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF162932), AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, color: AppColors.warning, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'APRESENTAÇÃO OFICIAL',
                        style: TextStyle(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 470),
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8E1D2),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFBAAE93)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x55000000),
                              blurRadius: 26,
                              offset: Offset(0, 14),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _NewspaperHeader(),
                            const SizedBox(height: 10),
                            Text(
                              'NOVO COMANDANTE:\n${manager.preferredName.toUpperCase()} É APRESENTADO PELO ${club.name.toUpperCase()}',
                              style: const TextStyle(
                                color: Color(0xFF171A18),
                                fontSize: 23,
                                height: 1.02,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -.4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDED5C4),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  ManagerAvatar(manager: manager, size: 104),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClubBadge(club: club, size: 62),
                                        const SizedBox(height: 8),
                                        Text(
                                          club.name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Color(0xFF171A18),
                                            fontSize: 15,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          competition,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Color(0xFF5B5B54),
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            _NewsMetadata(
                              date: career.currentDate,
                              competition: competition,
                            ),
                            const SizedBox(height: 11),
                            Container(height: 1, color: const Color(0xFFB8AD98)),
                            const SizedBox(height: 11),
                            Text(
                              '${manager.preferredName} inicia sua trajetória no ${club.name} e se prepara para disputar o $competition na temporada ${career.season}. Esta apresentação marca o início da nova carreira.',
                              style: const TextStyle(
                                color: Color(0xFF2F322F),
                                fontSize: 13,
                                height: 1.45,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 13),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF22323A),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.campaign_outlined,
                                    color: AppColors.warning,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Esta apresentação aparece somente na primeira entrada desta carreira.',
                                      style: TextStyle(
                                        color: AppColors.white,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onContinue,
                    icon: const Icon(Icons.sports_soccer_rounded),
                    label: const Text('Começar carreira'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NewspaperHeader extends StatelessWidget {
  const _NewspaperHeader();

  @override
  Widget build(BuildContext context) => Column(
        children: [
          const Row(
            children: [
              Icon(Icons.sports_soccer_rounded, color: Color(0xFF171A18)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'DESTAQUE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF171A18),
                    fontSize: 31,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.8,
                  ),
                ),
              ),
              Icon(Icons.menu_rounded, color: Color(0xFF171A18)),
            ],
          ),
          const SizedBox(height: 5),
          Container(height: 2, color: const Color(0xFF171A18)),
          const SizedBox(height: 4),
          const Text(
            'NOTÍCIAS DO FUTEBOL  •  PLANEJAMENTO  •  NOVA ERA',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF8A493F),
              fontSize: 8.5,
              fontWeight: FontWeight.w900,
              letterSpacing: .6,
            ),
          ),
          const SizedBox(height: 4),
          Container(height: 1, color: const Color(0xFF746F64)),
        ],
      );
}

class _NewsMetadata extends StatelessWidget {
  const _NewsMetadata({required this.date, required this.competition});

  final DateTime date;
  final String competition;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          const Icon(Icons.calendar_month_rounded, size: 15, color: Color(0xFF2E302D)),
          const SizedBox(width: 5),
          Text(
            _formatDate(date),
            style: const TextStyle(
              color: Color(0xFF2E302D),
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 8),
          Container(width: 1, height: 18, color: const Color(0xFF958D7C)),
          const SizedBox(width: 8),
          const Icon(Icons.emoji_events_rounded, size: 15, color: Color(0xFF2E302D)),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              competition,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF2E302D),
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      );

  static String _formatDate(DateTime date) {
    const months = [
      'JAN',
      'FEV',
      'MAR',
      'ABR',
      'MAI',
      'JUN',
      'JUL',
      'AGO',
      'SET',
      'OUT',
      'NOV',
      'DEZ',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }
}
