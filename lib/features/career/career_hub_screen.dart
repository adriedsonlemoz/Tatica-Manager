import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/career_controller.dart';
import '../../app/state/reward_controller.dart';
import '../../app/widgets/common.dart';
import '../../core/config/app_info.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/career/career_save_summary.dart';
import '../diagnostics/diagnostic_screen.dart';
import '../legal/game_information_screen.dart';
import '../rewards/reward_widgets.dart';
import '../rewards/rewards_screen.dart';
import '../settings/pre_career_settings_screen.dart';
import 'career_hub_info_links.dart';
import 'career_hub_save_cards.dart';
import 'club_editor_screen.dart';
import 'new_career_flow_screen.dart';

class CareerHubScreen extends ConsumerWidget {
  const CareerHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(careerControllerProvider);
    final pmBalance = ref.watch(rewardControllerProvider).snapshot.wallet.balance;

    return PremiumScaffold(
      safeBottom: true,
      body: RefreshIndicator(
        onRefresh: () => ref.read(careerControllerProvider.notifier).refresh(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
          children: [
            _BrandHeader(
              balance: pmBalance,
              onRewardsTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RewardsScreen()),
              ),
            ),
            const SizedBox(height: 22),
            if (state.message != null) ...[
              _MessageBanner(message: state.message!),
              const SizedBox(height: 12),
            ],
            if (state.loading && state.saves.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.saves.isEmpty)
              EmptyCareerState(onNewCareer: () => _openNewCareer(context))
            else ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'CARREIRAS SALVAS',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                  Text('${state.saves.length}', style: const TextStyle(color: AppColors.muted)),
                ],
              ),
              const SizedBox(height: 10),
              ...state.saves.map(
                (save) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: CareerSaveCard(
                    save: save,
                    loading: state.loading,
                    onOpen: () => ref.read(careerControllerProvider.notifier).openCareer(save.careerId),
                    onDelete: () => _confirmDelete(context, ref, save),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              FilledButton.icon(
                onPressed: state.loading ? null : () => _openNewCareer(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Nova carreira'),
              ),
            ],
            const SizedBox(height: 22),
            Text(
              'INFORMAÇÕES E OPÇÕES',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
            ),
            const SizedBox(height: 9),
            CareerHubInfoLinks(
              onAbout: () => _openInfo(context, GameInformationPage.about),
              onHowItWorks: () => _openInfo(context, GameInformationPage.howItWorks),
              onTerms: () => _openInfo(context, GameInformationPage.terms),
              onPrivacy: () => _openInfo(context, GameInformationPage.privacy),
              onEditor: state.loading ? null : () => _openGameDataEditor(context),
              onSettings: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PreCareerSettingsScreen()),
              ),
            ),
            const SizedBox(height: 26),
            _VersionFooter(onTap: () => _openDiagnostics(context)),
          ],
        ),
      ),
    );
  }

  static Future<void> _openNewCareer(BuildContext context) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NewCareerFlowScreen()));
  }

  static Future<void> _openInfo(BuildContext context, GameInformationPage page) =>
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => GameInformationScreen(page: page)),
      );

  static Future<void> _openGameDataEditor(BuildContext context) =>
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ClubEditorScreen()),
      );

  static Future<void> _openDiagnostics(BuildContext context) =>
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const DiagnosticScreen()),
      );

  static Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    CareerSaveSummary save,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => CareerDeleteDialog(save: save),
    );
    if (confirmed == true) {
      await ref.read(careerControllerProvider.notifier).deleteCareer(save.careerId);
    }
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.balance, required this.onRewardsTap});

  final int balance;
  final VoidCallback onRewardsTap;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(
              'assets/brand/tatica-manager-icon.png',
              width: 64,
              height: 64,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TÁTICA MANAGER',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                const Text('Carregar jogo salvo', style: TextStyle(color: AppColors.muted)),
              ],
            ),
          ),
          RewardBalanceChip(balance: balance, onTap: onRewardsTap),
        ],
      );
}

class _VersionFooter extends StatelessWidget {
  const _VersionFooter({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Center(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bug_report_outlined, size: 15, color: AppColors.muted),
                const SizedBox(width: 6),
                Text(
                  'Tática Manager Beta 2.0 • v${AppInfo.version}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
        ),
      );
}

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.danger.withValues(alpha: .35)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.danger),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      );
}
