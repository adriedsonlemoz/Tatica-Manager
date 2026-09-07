import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/game_controller.dart';
import '../../core/theme/app_colors.dart';
import '../lineup/lineup_screen.dart';
import '../market/market_screen.dart';
import '../more/more_screen.dart';
import '../squad/squad_screen.dart';
import 'home_screen.dart';

class GameShell extends ConsumerStatefulWidget {
  const GameShell({super.key});

  @override
  ConsumerState<GameShell> createState() => _GameShellState();
}

class _GameShellState extends ConsumerState<GameShell> {
  int index = 0;

  static const screens = [
    HomeScreen(),
    SquadScreen(),
    LineupScreen(),
    MarketScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      body: IndexedStack(index: index, children: screens),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.navigation,
            border: Border(
              top: BorderSide(color: AppColors.border),
            ),
          ),
          child: NavigationBar(
            height: 60,
            backgroundColor: AppColors.navigation,
            indicatorColor: Colors.transparent,
            selectedIndex: index,
            onDestinationSelected: (value) {
              final career = ref.read(gameControllerProvider).career;
              if (career?.managerUnemployed == true && value >= 1 && value <= 3) {
                ref.read(gameControllerProvider.notifier).showMessage(
                      'Você está sem clube. Assuma uma vaga para voltar a gerenciar elenco, escalação e mercado.',
                    );
                if (index != 0) setState(() => index = 0);
                return;
              }
              setState(() => index = value);
            },
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Início'),
              NavigationDestination(icon: Icon(Icons.groups_2_outlined), selectedIcon: Icon(Icons.groups_2_rounded), label: 'Elenco'),
              NavigationDestination(icon: Icon(Icons.sports_soccer_outlined), selectedIcon: Icon(Icons.sports_soccer_rounded), label: 'Escalação'),
              NavigationDestination(icon: Icon(Icons.search_rounded), selectedIcon: Icon(Icons.manage_search_rounded), label: 'Mercado'),
              NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: 'Mais'),
              ],
          ),
        ),
      ),
    );
  }

}
