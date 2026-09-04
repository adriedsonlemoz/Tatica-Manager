import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/audio/audio_providers.dart';
import '../../app/state/game_controller.dart';
import '../../app/state/reward_controller.dart';
import '../../core/audio/audio_catalog.dart';
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
  String? _visibleMessage;
  String _visibleTitle = 'Atualização do clube';
  bool _rewardMessage = false;
  String? _visibleRewardEventKey;
  Timer? _messageTimer;

  static const screens = [
    HomeScreen(),
    SquadScreen(),
    LineupScreen(),
    MarketScreen(),
    MoreScreen(),
  ];

  @override
  void dispose() {
    _messageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameControllerProvider);
    ref.listen<RewardState>(rewardControllerProvider, (previous, next) {
      final notice = next.notice;
      if (notice == null || notice.eventKey == _visibleRewardEventKey) return;
      _showMessage(
        notice.message,
        title: notice.title,
        reward: true,
        rewardEventKey: notice.eventKey,
      );
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final message = game.message;
      if (!mounted || message == null || message == _visibleMessage) return;
      if (ref.read(rewardControllerProvider).notice != null) return;
      _showMessage(message);
      ref.read(gameControllerProvider.notifier).clearMessage();
    });
    return Scaffold(
      extendBody: false,
      body: Stack(
        children: [
          IndexedStack(index: index, children: screens),
          Positioned(
            bottom: 12,
            left: 14,
            right: 14,
            child: IgnorePointer(
              ignoring: _visibleMessage == null,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                offset: _visibleMessage == null
                    ? const Offset(0, 0.35)
                    : Offset.zero,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 220),
                  opacity: _visibleMessage == null ? 0 : 1,
                  child: _IntegratedMessageCard(
                    title: _visibleTitle,
                    message: _visibleMessage,
                    reward: _rewardMessage,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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

  void _showMessage(
    String message, {
    String title = 'Atualização do clube',
    bool reward = false,
    String? rewardEventKey,
  }) {
    _messageTimer?.cancel();
    unawaited(ref.read(audioManagerProvider).playUi(UiAudioCue.confirm));
    setState(() {
      _visibleMessage = message;
      _visibleTitle = title;
      _rewardMessage = reward;
      _visibleRewardEventKey = rewardEventKey;
    });
    _messageTimer = Timer(const Duration(milliseconds: 3200), () {
      if (!mounted) return;
      final eventKey = _visibleRewardEventKey;
      setState(() {
        _visibleMessage = null;
        _rewardMessage = false;
        _visibleRewardEventKey = null;
      });
      if (eventKey != null) {
        ref.read(rewardControllerProvider.notifier).consumeNotice(eventKey);
      }
    });
  }
}

class _IntegratedMessageCard extends StatelessWidget {
  const _IntegratedMessageCard({
    required this.title,
    required this.message,
    required this.reward,
  });

  final String title;
  final String? message;
  final bool reward;

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();
    return Material(
      elevation: 8,
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised.withValues(alpha: .97),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.green.withValues(alpha: .35)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: .14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.notifications_active_rounded,
                color: AppColors.green,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: reward ? AppColors.green : AppColors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    message!,
                    style: const TextStyle(color: AppColors.muted, height: 1.35),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
