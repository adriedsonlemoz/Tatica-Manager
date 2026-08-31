import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/career_controller.dart';
import '../../app/state/game_controller.dart';
import '../../app/widgets/common.dart';
import '../../core/config/app_info.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/match_ball_styles.dart';
import '../../domain/season/career_state.dart';
import '../../domain/settings/match_presentation_settings.dart';
import '../career/manager_appearance_editor.dart';
import '../career/manager_profile_screen.dart';
import '../diagnostics/diagnostic_screen.dart';
import 'audio_settings_screen.dart';
import 'match_ball_picker.dart';

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
    final audio = settings.audio;

    return PremiumScaffold(
      appBar: const GameTopBar(title: 'Configurações'),
      safeBottom: true,
      body: LayoutBuilder(
        builder: (context, constraints) => Padding(
          padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: constraints.maxWidth - 20,
              height: 710,
              child: Column(
                children: [
                  _SettingsSection(
                    icon: Icons.settings_rounded,
                    title: 'JOGO',
                    children: [
                      _SwitchSettingRow(
                        icon: Icons.mic_none_rounded,
                        title: 'Narração',
                        subtitle: 'Voz nos principais lances da partida',
                        value: audio.narrationEnabled,
                        onChanged: (value) => _update(
                          settings.copyWith(
                            audio: audio.copyWith(narrationEnabled: value),
                          ),
                        ),
                      ),
                      _SwitchSettingRow(
                        icon: Icons.gamepad_outlined,
                        title: 'Sons da interface',
                        subtitle: 'Toques, navegação e confirmações',
                        value: audio.interfaceEnabled,
                        onChanged: settings.sound
                            ? (value) => _update(
                                  settings.copyWith(
                                    audio: audio.copyWith(
                                      interfaceEnabled: value,
                                    ),
                                  ),
                                )
                            : null,
                      ),
                      _SwitchSettingRow(
                        icon: Icons.music_note_rounded,
                        title: 'Música dos menus',
                        subtitle: 'Trilhas durante a navegação',
                        value: audio.musicEnabled,
                        onChanged: settings.sound
                            ? (value) => _update(
                                  settings.copyWith(
                                    audio: audio.copyWith(musicEnabled: value),
                                  ),
                                )
                            : null,
                      ),
                      _SwitchSettingRow(
                        icon: Icons.vibration_rounded,
                        title: 'Vibração',
                        subtitle: 'Feedback tátil somente em gols',
                        value: settings.haptics,
                        onChanged: (value) =>
                            _update(settings.copyWith(haptics: value)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  _SettingsSection(
                    icon: Icons.volume_up_rounded,
                    title: 'ÁUDIO',
                    trailing: Switch.adaptive(
                      value: settings.sound,
                      onChanged: (value) =>
                          _update(settings.copyWith(sound: value)),
                    ),
                    children: [
                      _VolumeSettingRow(
                        icon: Icons.volume_up_rounded,
                        title: 'Volume geral',
                        value: audio.masterVolume,
                        enabled: settings.sound,
                        onChanged: (value) => _update(
                          settings.copyWith(
                            audio: audio.copyWith(masterVolume: value),
                          ),
                        ),
                      ),
                      _VolumeSettingRow(
                        icon: Icons.music_note_rounded,
                        title: 'Volume da música',
                        value: audio.musicVolume,
                        enabled: settings.sound && audio.musicEnabled,
                        onChanged: (value) => _update(
                          settings.copyWith(
                            audio: audio.copyWith(musicVolume: value),
                          ),
                        ),
                      ),
                      _NavigationSettingRow(
                        icon: Icons.tune_rounded,
                        title: 'Controles avançados de áudio',
                        subtitle: 'Partida, narração, playlist e sons próprios',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AudioSettingsScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  _SettingsSection(
                    icon: Icons.sports_soccer_rounded,
                    title: 'PARTIDA',
                    children: [
                      _SegmentSettingRow<int>(
                        icon: Icons.speed_rounded,
                        title: 'Velocidade da partida',
                        values: const [1, 2, 4],
                        selected: settings.matchSpeed,
                        label: (value) => '${value}x',
                        onSelected: (value) =>
                            _update(settings.copyWith(matchSpeed: value)),
                      ),
                      _SegmentSettingRow<int>(
                        icon: Icons.timer_outlined,
                        title: 'Duração por tempo',
                        values: MatchDurationPreset.values
                            .map((preset) => preset.minutes)
                            .toList(),
                        selected: settings.matchDurationMinutes,
                        label: (value) => '$value min',
                        onSelected: (value) => _update(
                          settings.copyWith(matchDurationMinutes: value),
                        ),
                      ),
                      _NavigationSettingRow(
                        icon: Icons.sports_soccer_rounded,
                        title: 'Bola da partida',
                        subtitle: MatchBallStyleSpec.resolve(
                          settings.matchBallStyle,
                        ).label,
                        valueColor: AppColors.green,
                        onTap: () => _showBallPicker(settings),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  _SettingsSection(
                    icon: Icons.person_outline_rounded,
                    title: 'CONTA E DADOS',
                    children: [
                      _NavigationSettingRow(
                        icon: Icons.person_outline_rounded,
                        title: 'Perfil do treinador',
                        subtitle: career.manager.preferredName,
                        onTap: _showManagerOptions,
                      ),
                      _NavigationSettingRow(
                        icon: Icons.save_outlined,
                        title: 'Carreira atual',
                        subtitle: career.careerName,
                        onTap: () => _showCareerActions(career),
                      ),
                      _NavigationSettingRow(
                        icon: Icons.info_outline_rounded,
                        title: 'Sobre o jogo',
                        subtitle: 'Novidades, contato e apoio',
                        onTap: () => _showNews(context),
                        onLongPress: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const DiagnosticScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _SettingsFooter(version: AppInfo.version),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _update(GameSettings value) {
    unawaited(ref.read(gameControllerProvider.notifier).updateSettings(value));
  }

  Future<void> _showBallPicker(GameSettings settings) async {
    var selected = settings.matchBallStyle;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Bola da partida'),
          content: SizedBox(
            width: 390,
            child: MatchBallPicker(
              value: selected,
              onChanged: (value) {
                setDialogState(() => selected = value);
                _update(settings.copyWith(matchBallStyle: value));
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Concluir'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showManagerOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.badge_outlined, color: AppColors.green),
                title: const Text(
                  'Ver perfil',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ManagerProfileScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.face_retouching_natural_rounded,
                  color: AppColors.green,
                ),
                title: const Text(
                  'Editar aparência',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _editManagerAppearance();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCareerActions(CareerState career) async {
    final clubName = career.managerUnemployed
        ? 'Sem clube'
        : career.userClub.name;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Carreira atual'),
        content: Text(
          '${career.careerName}\n$clubName • Temporada ${career.season}',
        ),
        actions: [
          TextButton.icon(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref
                  .read(careerControllerProvider.notifier)
                  .closeActiveCareer();
              if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: const Icon(Icons.home_rounded),
            label: const Text('Voltar às carreiras'),
          ),
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _confirmDeleteCareer(career);
            },
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Apagar carreira'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteCareer(CareerState career) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apagar carreira?'),
        content: Text(
          '“${career.careerName}” será removida deste aparelho e não poderá ser recuperada.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref
        .read(careerControllerProvider.notifier)
        .deleteCareer(career.careerId);
    if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _editManagerAppearance() async {
    final currentCareer = ref.read(gameControllerProvider).career;
    if (currentCareer == null) return;
    final updated = await showManagerAppearanceEditor(
      context,
      previewManager: currentCareer.manager,
    );
    if (updated == null || !mounted) return;
    await ref.read(gameControllerProvider.notifier).updateManagerProfile(
          currentCareer.manager.copyWith(appearance: updated),
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

  static Future<void> _showNews(BuildContext context) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (context) => SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * .76,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 8, 8),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/brand/tatica-manager-icon.png',
                        width: 42,
                        height: 42,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tática Manager',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'Versão ${AppInfo.version}',
                              style: const TextStyle(color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(10, 4, 10, 16),
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.mail_outline_rounded,
                          color: AppColors.green,
                        ),
                        title: const Text('Contato'),
                        subtitle: const Text(AppInfo.contactEmail),
                        trailing: const Icon(Icons.copy_rounded),
                        onTap: () => _copyValue(
                          context,
                          AppInfo.contactEmail,
                          'Contato copiado.',
                        ),
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.volunteer_activism_outlined,
                          color: AppColors.green,
                        ),
                        title: const Text('Apoiar via Pix'),
                        subtitle: Text(AppInfo.pixKey),
                        trailing: const Icon(Icons.copy_rounded),
                        onTap: () => _copyValue(
                          context,
                          AppInfo.pixKey,
                          'Chave Pix copiada.',
                        ),
                      ),
                      const Divider(),
                      for (final release in AppInfo.recentReleases)
                        ExpansionTile(
                          leading: const Icon(
                            Icons.update_rounded,
                            color: AppColors.green,
                          ),
                          title: Text(
                            'Versão ${release.version}',
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          subtitle: Text(release.title),
                          childrenPadding:
                              const EdgeInsets.fromLTRB(18, 0, 18, 12),
                          children: [
                            for (final change in release.changes)
                              Padding(
                                padding: const EdgeInsets.only(top: 7),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 6),
                                      child: Icon(
                                        Icons.circle,
                                        size: 6,
                                        color: AppColors.green,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(change)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.icon,
    required this.title,
    required this.children,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withValues(alpha: .7)),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 30,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.greenSoft,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: AppColors.green, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.green,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    if (trailing != null)
                      SizedBox(height: 30, child: FittedBox(child: trailing!)),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(8, 0, 8, 7),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised.withValues(alpha: .62),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: AppColors.border.withValues(alpha: .55)),
              ),
              child: Column(
                children: [
                  for (var index = 0; index < children.length; index++) ...[
                    if (index > 0) const Divider(height: 1),
                    children[index],
                  ],
                ],
              ),
            ),
          ],
        ),
      );
}

class _SettingRowShell extends StatelessWidget {
  const _SettingRowShell({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.trailing,
    this.onTap,
    this.onLongPress,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: SizedBox(
          height: 38,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Icon(icon, color: AppColors.green, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 8.5,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 7),
                trailing,
              ],
            ),
          ),
        ),
      );
}

class _SwitchSettingRow extends StatelessWidget {
  const _SwitchSettingRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => _SettingRowShell(
        icon: icon,
        title: title,
        subtitle: subtitle,
        trailing: SizedBox(
          width: 44,
          child: FittedBox(
            child: Switch.adaptive(value: value, onChanged: onChanged),
          ),
        ),
      );
}

class _VolumeSettingRow extends StatelessWidget {
  const _VolumeSettingRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final double value;
  final bool enabled;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => _SettingRowShell(
        icon: icon,
        title: title,
        trailing: SizedBox(
          width: 180,
          child: Row(
            children: [
              Expanded(
                child: Slider(
                  value: value,
                  onChanged: enabled ? onChanged : null,
                ),
              ),
              SizedBox(
                width: 34,
                child: Text(
                  '${(value * 100).round()}%',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: enabled ? AppColors.green : AppColors.muted,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _SegmentSettingRow<T> extends StatelessWidget {
  const _SegmentSettingRow({
    required this.icon,
    required this.title,
    required this.values,
    required this.selected,
    required this.label,
    required this.onSelected,
  });

  final IconData icon;
  final String title;
  final List<T> values;
  final T selected;
  final String Function(T) label;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) => _SettingRowShell(
        icon: icon,
        title: title,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < values.length; index++) ...[
              if (index > 0) const SizedBox(width: 4),
              InkWell(
                onTap: () => onSelected(values[index]),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: values[index] == selected
                        ? AppColors.green.withValues(alpha: .16)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: values[index] == selected
                          ? AppColors.green
                          : AppColors.border,
                    ),
                  ),
                  child: Text(
                    label(values[index]),
                    style: TextStyle(
                      color: values[index] == selected
                          ? AppColors.green
                          : AppColors.muted,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
}

class _NavigationSettingRow extends StatelessWidget {
  const _NavigationSettingRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.valueColor,
    this.onLongPress,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? valueColor;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) => _SettingRowShell(
        icon: icon,
        title: title,
        subtitle: subtitle,
        onTap: onTap,
        onLongPress: onLongPress,
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: valueColor ?? AppColors.muted,
          size: 20,
        ),
      );
}

class _SettingsFooter extends StatelessWidget {
  const _SettingsFooter({required this.version});

  final String version;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 38,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/brand/tatica-manager-icon.png',
              width: 33,
              height: 33,
            ),
            const SizedBox(width: 8),
            const Text('Tática Manager', style: TextStyle(fontSize: 11)),
            const SizedBox(width: 6),
            Text(
              version,
              style: const TextStyle(color: AppColors.green, fontSize: 10),
            ),
          ],
        ),
      );
}
