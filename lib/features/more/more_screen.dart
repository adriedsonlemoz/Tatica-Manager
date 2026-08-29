import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../app/widgets/common.dart';
import '../../core/theme/app_colors.dart';
import '../calendar/calendar_screen.dart';
import '../clubs/clubs_screen.dart';
import '../contracts/contracts_screen.dart';
import '../finances/finances_screen.dart';
import '../inbox/inbox_screen.dart';
import '../medical/medical_department_screen.dart';
import '../season/season_history_screen.dart';
import '../settings/settings_screen.dart';
import '../standings/standings_screen.dart';
import '../stadium/stadium_screen.dart';
import '../statistics/statistics_screen.dart';
import '../tactics/tactics_screen.dart';
import '../youth/youth_academy_screen.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final career = ref.watch(gameControllerProvider).career!;
    final items = <({IconData icon, String label, String subtitle, Widget page})>[
      (icon: Icons.shield_rounded, label: 'Clubes', subtitle: 'Elencos, estádios e jogadores', page: const ClubsScreen()),
      (icon: Icons.calendar_month_rounded, label: 'Calendário', subtitle: 'Datas, rodadas e resultados', page: const CalendarScreen()),
      (icon: Icons.leaderboard_rounded, label: 'Classificação', subtitle: 'Tabela completa da competição', page: const StandingsScreen()),
      if (career.managerEmployed)
        (icon: Icons.tune_rounded, label: 'Táticas', subtitle: 'Mentalidade, pressão e ritmo', page: const TacticsScreen()),
      if (career.managerEmployed)
        (icon: Icons.description_rounded, label: 'Contratos', subtitle: 'Renovações e salários', page: const ContractsScreen()),
      if (career.managerEmployed)
        (icon: Icons.account_balance_wallet_rounded, label: 'Finanças', subtitle: 'Receitas e despesas', page: const FinancesScreen()),
      if (career.managerEmployed)
        (icon: Icons.stadium_rounded, label: 'Estádio', subtitle: 'Setores, receitas e áreas comerciais', page: const StadiumScreen()),
      if (career.managerEmployed)
        (icon: Icons.school_rounded, label: 'Categoria de base', subtitle: 'Jovens, potencial e promoção', page: const YouthAcademyScreen()),
      if (career.managerEmployed)
        (icon: Icons.medical_services_rounded, label: 'Departamento médico', subtitle: 'Lesões, recuperação, fadiga e risco', page: const MedicalDepartmentScreen()),
      (icon: Icons.mail_rounded, label: 'Caixa de entrada', subtitle: 'Mensagens, propostas e avisos', page: const InboxScreen()),
      (icon: Icons.query_stats_rounded, label: 'Estatísticas', subtitle: 'Gols, assistências e desempenho', page: const StatisticsScreen()),
      (icon: Icons.history_rounded, label: 'Carreira do técnico', subtitle: 'Trajetória, clubes, vagas e propostas', page: const SeasonHistoryScreen()),
      (icon: Icons.settings_rounded, label: 'Configurações', subtitle: 'Save e preferências', page: const SettingsScreen()),
    ];
    return PremiumScaffold(
      body: ListView(padding: const EdgeInsets.fromLTRB(14, 18, 14, 110), children: [
        Text('MAIS', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
        Text(
          career.managerEmployed
              ? '${career.userClub.name} • temporada ${career.season}'
              : '${career.manager.preferredName} • sem clube • temporada ${career.season}',
          style:  TextStyle(color: AppColors.muted),
        ),
        const SizedBox(height: 14),
        SectionCard(child: Row(children: [
          Image.asset('assets/brand/tatica-manager-icon.png', width: 52, height: 52),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Tática Manager', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), Text('Gerencie. Escala. Vence.', style: TextStyle(color: AppColors.green))])),
        ])),
        const SizedBox(height: 12),
        ...items.map((item) => SectionCard(
          margin: const EdgeInsets.only(bottom: 8),
          padding: EdgeInsets.zero,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            leading: Container(width: 42, height: 42, alignment: Alignment.center, decoration: BoxDecoration(color: AppColors.green.withValues(alpha: .10), borderRadius: BorderRadius.circular(12)), child: Icon(item.icon, color: AppColors.green)),
            title: Text(item.label, style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text(item.subtitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => item.page)),
          ),
        )),
      ]),
    );
  }
}
