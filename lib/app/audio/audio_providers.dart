import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/audio/audio_file_store.dart';
import 'audio_manager.dart';

final audioManagerProvider = Provider<AudioManager>((ref) {
  final manager = AudioManager();
  ref.onDispose(() => unawaited(manager.dispose()));
  return manager;
});

final audioFileStoreProvider =
    Provider<AudioFileStore>((ref) => const AudioFileStore());
