import 'dart:async';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/audio/audio_providers.dart';
import '../../app/state/game_controller.dart';
import '../../app/widgets/common.dart';
import '../../core/audio/audio_catalog.dart';
import '../../core/audio/audio_file_store.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/season/career_state.dart';
import '../../domain/settings/audio_settings.dart';
import 'menu_music_player_card.dart';

class AudioSettingsScreen extends ConsumerStatefulWidget {
  const AudioSettingsScreen({super.key});

  @override
  ConsumerState<AudioSettingsScreen> createState() => _AudioSettingsScreenState();
}

class _AudioSettingsScreenState extends ConsumerState<AudioSettingsScreen> {
  late GameSettings _settings;
  Timer? _saveTimer;
  bool _importing = false;
  late final GameController _gameController;

  @override
  void initState() {
    super.initState();
    _gameController = ref.read(gameControllerProvider.notifier);
    _settings = ref.read(gameControllerProvider).career!.settings;
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    unawaited(_gameController.updateSettings(_settings));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audio = _settings.audio;
    return PremiumScaffold(
      appBar: const GameTopBar(
        title: 'Áudio',
        subtitle: 'Música, interface, partida, narração e arquivos personalizados',
      ),
      safeBottom: true,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
        children: [
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _settings.sound,
                  title: const Text(
                    'Áudio do jogo',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: const Text(
                    'Chave geral. Desative para silenciar tudo sem perder suas configurações.',
                  ),
                  onChanged: (value) => _change(
                    _settings.copyWith(sound: value),
                    immediate: true,
                  ),
                ),
                _VolumeControl(
                  label: 'Volume geral',
                  value: audio.masterVolume,
                  enabled: _settings.sound,
                  onChanged: (value) => _changeAudio(
                    audio.copyWith(masterVolume: value),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _AudioCategoryCard(
            icon: Icons.music_note_rounded,
            title: 'MÚSICA DOS MENUS',
            subtitle: 'Playlist do Tática Manager com seleção manual e troca de faixa.',
            enabled: audio.musicEnabled,
            volume: audio.musicVolume,
            masterEnabled: _settings.sound,
            onEnabledChanged: (value) => _changeAudio(
              audio.copyWith(musicEnabled: value),
              immediate: true,
            ),
            onVolumeChanged: (value) => _changeAudio(
              audio.copyWith(musicVolume: value),
            ),
          ),
          const SizedBox(height: 10),
          MenuMusicPlayerCard(
            audioManager: ref.read(audioManagerProvider),
            enabled: _settings.sound && audio.musicEnabled,
          ),
          const SizedBox(height: 10),
          _AudioCategoryCard(
            icon: Icons.touch_app_rounded,
            title: 'INTERFACE',
            subtitle: 'Toques, navegação e confirmações discretas.',
            enabled: audio.interfaceEnabled,
            volume: audio.interfaceVolume,
            masterEnabled: _settings.sound,
            onEnabledChanged: (value) => _changeAudio(
              audio.copyWith(interfaceEnabled: value),
              immediate: true,
            ),
            onVolumeChanged: (value) => _changeAudio(
              audio.copyWith(interfaceVolume: value),
            ),
            onTest: () => ref
                .read(audioManagerProvider)
                .playUi(UiAudioCue.confirm),
          ),
          const SizedBox(height: 10),
          SectionCard(
            child: SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: audio.cleanAudio,
              title: const Text(
                'Áudio limpo',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: const Text(
                'Toca somente apitos, gols, chances, defesas, trave, cartões, pênaltis, lesões e substituições.',
              ),
              secondary: const Icon(
                Icons.hearing_rounded,
                color: AppColors.green,
              ),
              onChanged: (value) => _changeAudio(
                audio.copyWith(cleanAudio: value),
                immediate: true,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _AudioCategoryCard(
            icon: Icons.sports_soccer_rounded,
            title: 'PARTIDA',
            subtitle: 'Apitos, gols, cartões, faltas e lances importantes.',
            enabled: audio.matchEnabled,
            volume: audio.matchVolume,
            masterEnabled: _settings.sound,
            onEnabledChanged: (value) => _changeAudio(
              audio.copyWith(matchEnabled: value),
              immediate: true,
            ),
            onVolumeChanged: (value) => _changeAudio(
              audio.copyWith(matchVolume: value),
            ),
            onTest: () => ref
                .read(audioManagerProvider)
                .playMatchCue(MatchAudioCue.goal),
          ),
          const SizedBox(height: 10),
          _AudioCategoryCard(
            icon: Icons.record_voice_over_rounded,
            title: 'NARRAÇÃO',
            subtitle: 'Voz em português do aparelho para os lances principais.',
            enabled: audio.narrationEnabled,
            volume: audio.narrationVolume,
            masterEnabled: _settings.sound,
            onEnabledChanged: (value) => _changeAudio(
              audio.copyWith(narrationEnabled: value),
              immediate: true,
            ),
            onVolumeChanged: (value) => _changeAudio(
              audio.copyWith(narrationVolume: value),
            ),
            onTest: () => ref.read(audioManagerProvider).testNarration(),
          ),
          const SizedBox(height: 10),
          _buildCustomMusic(audio),
          const SizedBox(height: 10),
          _buildCustomMatchSounds(audio),
          const SizedBox(height: 10),
          SectionCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.verified_user_outlined, color: AppColors.green),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'O Tática Manager reproduz as faixas incluídas no pacote do jogo e também aceita arquivos escolhidos por você. Arquivos personalizados ficam na área privada do aplicativo e substituem apenas a playlist ou o evento configurado.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.muted,
                          height: 1.45,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomMusic(AudioSettings audio) => SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.queue_music_rounded, color: AppColors.green),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'PLAYLIST DO APARELHO',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              audio.customMenuTracks.isEmpty
                  ? 'Use as músicas do Tática Manager ou selecione faixas armazenadas no celular.'
                  : '${audio.customMenuTracks.length} faixa(s) personalizada(s) importada(s).',
              style: const TextStyle(color: AppColors.muted, height: 1.4),
            ),
            if (audio.customMenuTracks.isNotEmpty) ...[
              const SizedBox(height: 8),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: audio.useCustomMenuMusic,
                title: const Text('Usar minha playlist'),
                subtitle: const Text('Desative para voltar às 11 músicas incluídas no jogo sem apagar sua seleção.'),
                onChanged: (value) => _changeAudio(
                  audio.copyWith(useCustomMenuMusic: value),
                  immediate: true,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _importing ? null : _pickMenuTracks,
                    icon: const Icon(Icons.audio_file_rounded),
                    label: Text(
                      audio.customMenuTracks.isEmpty
                          ? 'Escolher músicas'
                          : 'Adicionar músicas',
                    ),
                  ),
                ),
                if (audio.customMenuTracks.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: 'Remover playlist personalizada',
                    onPressed: _importing ? null : _clearMenuTracks,
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                ],
              ],
            ),
          ],
        ),
      );

  Widget _buildCustomMatchSounds(AudioSettings audio) => SectionCard(
        padding: EdgeInsets.zero,
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          leading: const Icon(Icons.tune_rounded, color: AppColors.green),
          title: const Text(
            'SONS PERSONALIZADOS DA PARTIDA',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          subtitle: Text(
            audio.customMatchSounds.isEmpty
                ? 'Opcional • usando sons originais'
                : '${audio.customMatchSounds.length} evento(s) personalizado(s)',
          ),
          children: [
            for (final cue in MatchAudioCue.values)
              _CustomSoundTile(
                cue: cue,
                customized: audio.customMatchSounds.containsKey(cue.name),
                onPick: () => _pickMatchSound(cue),
                onReset: () => _resetMatchSound(cue),
                onTest: () => ref.read(audioManagerProvider).playMatchCue(cue),
              ),
            if (audio.customMatchSounds.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: _clearAllMatchSounds,
                    icon: const Icon(Icons.restore_rounded),
                    label: const Text('Restaurar todos os sons padrão'),
                  ),
                ),
              ),
          ],
        ),
      );

  void _changeAudio(AudioSettings audio, {bool immediate = false}) =>
      _change(_settings.copyWith(audio: audio), immediate: immediate);

  void _change(GameSettings next, {bool immediate = false}) {
    setState(() => _settings = next);
    unawaited(ref.read(audioManagerProvider).applySettings(next));
    if (immediate) {
      unawaited(_persist());
      return;
    }
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 280), () {
      unawaited(_persist());
    });
  }

  Future<void> _persist() async {
    _saveTimer?.cancel();
    await _gameController.updateSettings(_settings);
  }

  Future<void> _pickMenuTracks() async {
    final files = await openFiles(
      acceptedTypeGroups: const [AudioFileStore.audioTypes],
      confirmButtonText: 'Adicionar ao Tática Manager',
    );
    if (files.isEmpty || !mounted) return;
    setState(() => _importing = true);
    try {
      final store = ref.read(audioFileStoreProvider);
      final imported = await store.importMenuTracks(files);
      if (!mounted) return;
      final tracks = [..._settings.audio.customMenuTracks, ...imported];
      _changeAudio(
        _settings.audio.copyWith(
          customMenuTracks: tracks,
          useCustomMenuMusic: true,
        ),
        immediate: true,
      );
      _message('${imported.length} música(s) adicionada(s) à playlist.');
    } catch (_) {
      _message('Não foi possível importar uma ou mais músicas.');
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<void> _clearMenuTracks() async {
    final store = ref.read(audioFileStoreProvider);
    for (final path in _settings.audio.customMenuTracks) {
      await store.deleteManagedFile(path);
    }
    if (!mounted) return;
    _changeAudio(
      _settings.audio.copyWith(
        customMenuTracks: const [],
        useCustomMenuMusic: false,
      ),
      immediate: true,
    );
    _message('Playlist personalizada removida.');
  }

  Future<void> _pickMatchSound(MatchAudioCue cue) async {
    final file = await openFile(
      acceptedTypeGroups: const [AudioFileStore.audioTypes],
      confirmButtonText: 'Usar neste evento',
    );
    if (file == null || !mounted) return;
    setState(() => _importing = true);
    try {
      final store = ref.read(audioFileStoreProvider);
      final oldPath = _settings.audio.customMatchSounds[cue.name];
      final imported = await store.importMatchSound(file, cue.name);
      final overrides = Map<String, String>.from(
        _settings.audio.customMatchSounds,
      )..[cue.name] = imported;
      if (oldPath != null) await store.deleteManagedFile(oldPath);
      if (!mounted) return;
      _changeAudio(
        _settings.audio.copyWith(customMatchSounds: overrides),
        immediate: true,
      );
      _message('${cue.label}: som personalizado aplicado.');
      unawaited(ref.read(audioManagerProvider).playMatchCue(cue));
    } catch (_) {
      _message('Não foi possível importar esse arquivo de áudio.');
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<void> _resetMatchSound(MatchAudioCue cue) async {
    final overrides = Map<String, String>.from(_settings.audio.customMatchSounds);
    final path = overrides.remove(cue.name);
    if (path != null) {
      await ref.read(audioFileStoreProvider).deleteManagedFile(path);
    }
    if (!mounted) return;
    _changeAudio(
      _settings.audio.copyWith(customMatchSounds: overrides),
      immediate: true,
    );
    _message('${cue.label}: som padrão restaurado.');
  }

  Future<void> _clearAllMatchSounds() async {
    final store = ref.read(audioFileStoreProvider);
    for (final path in _settings.audio.customMatchSounds.values) {
      await store.deleteManagedFile(path);
    }
    if (!mounted) return;
    _changeAudio(
      _settings.audio.copyWith(customMatchSounds: const {}),
      immediate: true,
    );
    _message('Todos os sons da partida voltaram ao padrão.');
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }
}

class _AudioCategoryCard extends StatelessWidget {
  const _AudioCategoryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.volume,
    required this.masterEnabled,
    required this.onEnabledChanged,
    required this.onVolumeChanged,
    this.onTest,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final double volume;
  final bool masterEnabled;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<double> onVolumeChanged;
  final Future<void> Function()? onTest;

  @override
  Widget build(BuildContext context) => SectionCard(
        child: Column(
          children: [
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              secondary: Icon(icon, color: AppColors.green),
              value: enabled,
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
              subtitle: Text(subtitle),
              onChanged: masterEnabled ? onEnabledChanged : null,
            ),
            _VolumeControl(
              label: 'Volume',
              value: volume,
              enabled: masterEnabled && enabled,
              onChanged: onVolumeChanged,
            ),
            if (onTest != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: masterEnabled && enabled && onTest != null
                      ? () => unawaited(onTest!())
                      : null,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Testar'),
                ),
              ),
          ],
        ),
      );
}

class _VolumeControl extends StatelessWidget {
  const _VolumeControl({
    required this.label,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final double value;
  final bool enabled;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(
              '$label ${(value * 100).round()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: enabled ? AppColors.muted : AppColors.muted.withValues(alpha: .45),
                  ),
            ),
          ),
          Expanded(
            child: Slider(
              value: value,
              onChanged: enabled ? onChanged : null,
            ),
          ),
        ],
      );
}

class _CustomSoundTile extends StatelessWidget {
  const _CustomSoundTile({
    required this.cue,
    required this.customized,
    required this.onPick,
    required this.onReset,
    required this.onTest,
  });

  final MatchAudioCue cue;
  final bool customized;
  final VoidCallback onPick;
  final VoidCallback onReset;
  final Future<void> Function() onTest;

  @override
  Widget build(BuildContext context) => ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        title: Text(cue.label, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
          customized ? 'Personalizado' : 'Padrão do Tática Manager',
          style: TextStyle(color: customized ? AppColors.green : AppColors.muted),
        ),
        trailing: Wrap(
          spacing: 0,
          children: [
            IconButton(
              tooltip: 'Ouvir',
              onPressed: () => unawaited(onTest()),
              icon: const Icon(Icons.play_circle_outline_rounded),
            ),
            IconButton(
              tooltip: 'Escolher arquivo',
              onPressed: onPick,
              icon: const Icon(Icons.folder_open_rounded),
            ),
            if (customized)
              IconButton(
                tooltip: 'Restaurar padrão',
                onPressed: onReset,
                icon: const Icon(Icons.restore_rounded),
              ),
          ],
        ),
      );
}
