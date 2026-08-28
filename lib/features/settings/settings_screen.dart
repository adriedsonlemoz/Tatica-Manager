import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/career_controller.dart';
import '../../app/state/game_controller.dart';
import '../../app/widgets/common.dart';
import '../../app/widgets/manager_avatar.dart';
import '../../core/config/app_info.dart';
import '../../core/theme/app_colors.dart';
import '../diagnostics/diagnostic_screen.dart';
import '../../data/country_catalog.dart';
import '../../domain/formation/formation.dart';
import '../../domain/settings/match_presentation_settings.dart';
import '../career/manager_appearance_editor.dart';
import '../career/manager_profile_screen.dart';
import 'audio_settings_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final career = ref.watch(gameControllerProvider).career!;
    final settings = career.settings;
    final manager = career.manager;
    final birthSummary = manager.birthPlaceSummary(
      omitCountry: manager.birthCountry == manager.nationality,
    );
    return PremiumScaffold(
      appBar: GameTopBar(
        title: 'Configurações',
        subtitle: 'Tática Manager ${AppInfo.version}',
      ),
      safeBottom: true,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
        children: [
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('CARREIRA ATUAL', style: TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ManagerAvatar(manager: manager, size: 74),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            career.careerName,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${manager.preferredName} • ${manager.ageInSeason(career.season)} anos',
                            style: const TextStyle(color: AppColors.muted),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${CountryCatalog.flagOf(manager.nationality)} ${manager.nationality} • ${career.userClub.name}',
                            style: const TextStyle(color: AppColors.muted),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Rep. ${manager.reputation} • ${manager.style} • ${manager.preferredFormation.label}',
                            style: const TextStyle(color: AppColors.muted, fontSize: 12),
                          ),
                          if (birthSummary.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Origem: $birthSummary',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.muted),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ManagerProfileScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.badge_outlined),
                        label: const Text('Ver perfil'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _editManagerAppearance,
                        icon: const Icon(Icons.face_retouching_natural_rounded),
                        label: const Text('Aparência'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BOLA DA PARTIDA',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Personalização apenas visual; não altera o Match Engine.',
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  initialValue: settings.matchBallStyle,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.sports_soccer_rounded),
                  ),
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('Clássica')), 
                    DropdownMenuItem(value: 1, child: Text('Branca e verde')),
                    DropdownMenuItem(value: 2, child: Text('Amarela')),
                    DropdownMenuItem(value: 3, child: Text('Retrô')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    ref.read(gameControllerProvider.notifier).updateSettings(
                          settings.copyWith(matchBallStyle: value),
                        );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SectionCard(
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  value: settings.haptics,
                  title: const Text('Feedback tátil'),
                  subtitle: const Text('Quando ativo, vibra somente em gols.'),
                  onChanged: (value) => ref
                      .read(gameControllerProvider.notifier)
                      .updateSettings(settings.copyWith(haptics: value)),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: const Icon(Icons.volume_up_rounded, color: AppColors.green),
                  title: const Text('Áudio', style: TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text(
                    settings.sound
                        ? 'Música, interface, partida e sons personalizados'
                        : 'Áudio geral desativado',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AudioSettingsScreen()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('DURAÇÃO PADRÃO DA PARTIDA', style: TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                const Text(
                  'Controla a cadência visual sem alterar o resultado ou as estatísticas do motor.',
                  style: TextStyle(color: AppColors.muted, fontSize: 11),
                ),
                const SizedBox(height: 10),
                SegmentedButton<int>(
                  segments: [
                    for (final preset in MatchDurationPreset.values)
                      ButtonSegment(
                        value: preset.minutes,
                        label: Text(preset.shortLabel),
                      ),
                  ],
                  selected: {settings.matchDurationMinutes},
                  onSelectionChanged: (selection) => ref
                      .read(gameControllerProvider.notifier)
                      .updateSettings(
                        settings.copyWith(
                          matchDurationMinutes: selection.first,
                        ),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SectionCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: const Icon(Icons.new_releases_outlined, color: AppColors.green),
                  title: const Text('Sobre / Novidades', style: TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: const Text('Veja as alterações das três versões mais recentes.'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showNews(context),
                  onLongPress: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DiagnosticScreen()),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: const Icon(Icons.mail_outline_rounded, color: AppColors.green),
                  title: const Text('Contato', style: TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: const Text(AppInfo.contactEmail),
                  trailing: const Icon(Icons.copy_rounded),
                  onTap: () => _copyValue(
                    context,
                    AppInfo.contactEmail,
                    'Contato copiado.',
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: const Icon(Icons.volunteer_activism_outlined, color: AppColors.green),
                  title: const Text('Apoiar o desenvolvimento via Pix', style: TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text('Chave: ${AppInfo.pixKey}'),
                  trailing: const Icon(Icons.copy_rounded),
                  onTap: () => _copyValue(
                    context,
                    AppInfo.pixKey,
                    'Chave Pix copiada.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SectionCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.screen_lock_portrait_rounded, color: AppColors.green),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'O jogo foi desenhado para retrato e edge-to-edge. A orientação é bloqueada em portrait no runtime e nas plataformas nativas.',
                    style: const TextStyle(color: AppColors.muted, height: 1.45),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () async {
              await ref.read(careerControllerProvider.notifier).closeActiveCareer();
              if (context.mounted) Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: const Icon(Icons.home_rounded),
            label: const Text('Voltar às carreiras'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Apagar carreira?'),
                  content: Text('“${career.careerName}” será removida deste aparelho e não poderá ser recuperada.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
                      child: const Text('Apagar'),
                    ),
                  ],
                ),
              );
              if (confirmed != true) return;
              await ref.read(careerControllerProvider.notifier).deleteCareer(career.careerId);
              if (context.mounted) Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Apagar esta carreira'),
          ),
        ],
      ),
    );
  }

  Future<void> _editManagerAppearance() async {
    final currentCareer = ref.read(gameControllerProvider).career;
    if (currentCareer == null) return;
    final updated = await showManagerAppearanceEditor(
      context,
      previewManager: currentCareer.manager,
    );
    if (updated == null || !mounted) return;
    final nextManager = currentCareer.manager.copyWith(appearance: updated);
    await ref.read(gameControllerProvider.notifier).updateManagerProfile(
          nextManager,
          message: 'A aparência do treinador foi atualizada.',
        );
  }

  static Future<void> _copyValue(
    BuildContext context,
    String value,
    String message,
  ) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  static Future<void> _showNews(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (context) => SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * .72,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 10, 8),
                  child: Row(
                    children: [
                      const Icon(Icons.sports_soccer_rounded, color: AppColors.green),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tática Manager',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            Text('Versão ${AppInfo.version}', style: const TextStyle(color: AppColors.muted)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(10, 6, 10, 20),
                    children: AppInfo.recentReleases
                        .map(
                          (release) => ExpansionTile(
                            initiallyExpanded: false,
                            leading: const Icon(Icons.update_rounded, color: AppColors.green),
                            title: Text(
                              'Versão ${release.version}',
                              style: const TextStyle(fontWeight: FontWeight.w900),
                            ),
                            subtitle: Text(release.title),
                            childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                            children: release.changes
                                .map(
                                  (change) => Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.only(top: 6),
                                          child: Icon(Icons.circle, size: 6, color: AppColors.green),
                                        ),
                                        const SizedBox(width: 9),
                                        Expanded(child: Text(change)),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
