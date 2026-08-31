import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/audio/audio_providers.dart';
import '../../app/state/providers.dart';
import '../../app/widgets/common.dart';
import '../../core/config/app_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/season/career_state.dart';
import '../../domain/settings/match_presentation_settings.dart';
import 'match_ball_picker.dart';

class PreCareerSettingsScreen extends ConsumerStatefulWidget {
  const PreCareerSettingsScreen({super.key});

  @override
  ConsumerState<PreCareerSettingsScreen> createState() =>
      _PreCareerSettingsScreenState();
}

class _PreCareerSettingsScreenState
    extends ConsumerState<PreCareerSettingsScreen> {
  GameSettings _settings = const GameSettings();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final repository = ref.read(careerRepositoryProvider);
    final raw = await repository.loadAppValue(
      AppPreferences.defaultGameSettingsKey,
    );
    if (!mounted) return;
    setState(() {
      _settings = AppPreferences.decodeGameSettings(raw);
      _loading = false;
    });
  }

  Future<void> _change(GameSettings value) async {
    setState(() => _settings = value);
    final repository = ref.read(careerRepositoryProvider);
    await repository.saveAppValue(
      AppPreferences.defaultGameSettingsKey,
      AppPreferences.encodeGameSettings(value),
    );
    await ref.read(audioManagerProvider).applySettings(value);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const PremiumScaffold(
        appBar: GameTopBar(
          title: 'Configurações',
          subtitle: 'Preferências para novas carreiras',
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final audio = _settings.audio;
    return PremiumScaffold(
      appBar: const GameTopBar(
        title: 'Configurações',
        subtitle: 'Preferências para novas carreiras',
      ),
      safeBottom: true,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
        children: [
          SectionCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.green),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Estas opções serão usadas como padrão ao criar uma nova carreira. Saves existentes continuam com as próprias configurações.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.muted,
                          height: 1.4,
                        ),
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
                const Text(
                  'PARTIDA',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Velocidade da partida',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment<int>(value: 1, label: Text('1x')),
                    ButtonSegment<int>(value: 2, label: Text('2x')),
                    ButtonSegment<int>(value: 4, label: Text('4x')),
                  ],
                  selected: {_settings.matchSpeed},
                  onSelectionChanged: (selection) => unawaited(
                    _change(
                      _settings.copyWith(matchSpeed: selection.first),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Duração por tempo',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                SegmentedButton<int>(
                  segments: [
                    for (final preset in MatchDurationPreset.values)
                      ButtonSegment<int>(
                        value: preset.minutes,
                        label: Text(preset.shortLabel),
                      ),
                  ],
                  selected: {_settings.matchDurationMinutes},
                  onSelectionChanged: (selection) => unawaited(
                    _change(
                      _settings.copyWith(
                        matchDurationMinutes: selection.first,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Bola da partida',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                MatchBallPicker(
                  value: _settings.matchBallStyle,
                  onChanged: (value) => unawaited(
                    _change(_settings.copyWith(matchBallStyle: value)),
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
                SwitchListTile.adaptive(
                  value: _settings.haptics,
                  title: const Text('Feedback tátil'),
                  subtitle: const Text('Vibração somente em gols.'),
                  onChanged: (value) => unawaited(
                    _change(_settings.copyWith(haptics: value)),
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile.adaptive(
                  value: _settings.sound,
                  title: const Text('Áudio do jogo'),
                  subtitle: const Text('Chave geral de música e efeitos.'),
                  onChanged: (value) => unawaited(
                    _change(_settings.copyWith(sound: value)),
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
                _AudioToggle(
                  icon: Icons.music_note_rounded,
                  title: 'Música dos menus',
                  value: audio.musicEnabled,
                  onChanged: (value) => unawaited(
                    _change(
                      _settings.copyWith(
                        audio: audio.copyWith(musicEnabled: value),
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                _AudioToggle(
                  icon: Icons.touch_app_rounded,
                  title: 'Sons da interface',
                  value: audio.interfaceEnabled,
                  onChanged: (value) => unawaited(
                    _change(
                      _settings.copyWith(
                        audio: audio.copyWith(interfaceEnabled: value),
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                _AudioToggle(
                  icon: Icons.stadium_outlined,
                  title: 'Sons da partida',
                  value: audio.matchEnabled,
                  onChanged: (value) => unawaited(
                    _change(
                      _settings.copyWith(
                        audio: audio.copyWith(matchEnabled: value),
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                _AudioToggle(
                  icon: Icons.record_voice_over_outlined,
                  title: 'Narração falada',
                  value: audio.narrationEnabled,
                  onChanged: (value) => unawaited(
                    _change(
                      _settings.copyWith(
                        audio: audio.copyWith(narrationEnabled: value),
                      ),
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
}

class _AudioToggle extends StatelessWidget {
  const _AudioToggle({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SwitchListTile.adaptive(
        value: value,
        secondary: Icon(icon, color: AppColors.green),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        onChanged: onChanged,
      );
}
