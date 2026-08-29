import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/audio/audio_manager.dart';
import '../../app/widgets/common.dart';
import '../../core/theme/app_colors.dart';

class MenuMusicPlayerCard extends StatelessWidget {
  const MenuMusicPlayerCard({
    super.key,
    required this.audioManager,
    required this.enabled,
  });

  final AudioManager audioManager;
  final bool enabled;

  @override
  Widget build(BuildContext context) => StreamBuilder<MenuPlaybackState>(
        stream: audioManager.menuPlaybackStream,
        initialData: audioManager.menuPlaybackState,
        builder: (context, snapshot) {
          final state = snapshot.data ?? audioManager.menuPlaybackState;
          final current = state.currentTrack;
          return SectionCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.green.withValues(alpha: .10),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: AppColors.green.withValues(alpha: .32),
                        ),
                      ),
                      child: Icon(
                        state.playing
                            ? Icons.graphic_eq_rounded
                            : Icons.music_note_rounded,
                        color: AppColors.green,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TOCANDO AGORA',
                            style: TextStyle(
                              color: AppColors.green,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: .8,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            current?.title ??
                                (enabled ? 'Preparando playlist…' : 'Música desativada'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          if (current != null && current.subtitle.isNotEmpty)
                            Text(
                              current.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:  TextStyle(
                                color: AppColors.muted,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      tooltip: 'Próxima música',
                      onPressed: enabled && state.tracks.length > 1
                          ? () => unawaited(audioManager.nextMenuTrack())
                          : null,
                      icon: const Icon(Icons.skip_next_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        state.usingCustomPlaylist
                            ? Icons.folder_special_outlined
                            : Icons.library_music_rounded,
                        size: 16,
                        color: AppColors.muted,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          state.usingCustomPlaylist
                              ? '${state.tracks.length} faixa(s) da sua playlist'
                              : '${state.tracks.length} músicas do Tática Manager',
                          style:  TextStyle(
                            color: AppColors.muted,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: EdgeInsets.zero,
                    dense: true,
                    leading: const Icon(
                      Icons.queue_music_rounded,
                      color: AppColors.green,
                    ),
                    title: const Text(
                      'Selecionar música',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: const Text('Toque em uma faixa para reproduzir agora.'),
                    children: [
                      for (final track in state.tracks)
                        _TrackTile(
                          track: track,
                          selected: track.index == state.currentIndex,
                          enabled: enabled,
                          onTap: () => unawaited(
                            audioManager.selectMenuTrack(track.index),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
}

class _TrackTile extends StatelessWidget {
  const _TrackTile({
    required this.track,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final MenuPlaybackTrack track;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: selected
            ? AppColors.green.withValues(alpha: .08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          dense: true,
          enabled: enabled,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onTap: enabled ? onTap : null,
          leading: SizedBox(
            width: 28,
            child: Center(
              child: selected
                  ? const Icon(
                      Icons.equalizer_rounded,
                      size: 18,
                      color: AppColors.green,
                    )
                  : Text(
                      '${track.index + 1}'.padLeft(2, '0'),
                      style:  TextStyle(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
          title: Text(
            track.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
              color: selected ? AppColors.white : null,
            ),
          ),
          subtitle: track.subtitle.isEmpty
              ? null
              : Text(
                  track.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
          trailing: selected
              ? const Icon(Icons.check_circle_rounded, color: AppColors.green)
              :  Icon(Icons.play_arrow_rounded, color: AppColors.muted),
        ),
      );
}
