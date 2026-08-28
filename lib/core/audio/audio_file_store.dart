import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';

class AudioFileStore {
  const AudioFileStore();

  static const audioTypes = XTypeGroup(
    label: 'Áudio',
    extensions: ['mp3', 'm4a', 'aac', 'wav', 'ogg', 'flac'],
    mimeTypes: ['audio/*'],
    uniformTypeIdentifiers: ['public.audio'],
  );

  Future<List<String>> importMenuTracks(List<XFile> files) async {
    final imported = <String>[];
    try {
      for (final file in files) {
        imported.add(await _copyIntoAppStorage(file, 'menu'));
      }
      return imported;
    } catch (_) {
      for (final path in imported) {
        await deleteManagedFile(path);
      }
      rethrow;
    }
  }

  Future<String> importMatchSound(XFile file, String cueKey) =>
      _copyIntoAppStorage(file, 'match_$cueKey');

  Future<void> deleteManagedFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {
      // A configuração continua válida mesmo se um arquivo antigo já tiver sumido.
    }
  }

  Future<String> _copyIntoAppStorage(XFile source, String bucket) async {
    final root = await getApplicationSupportDirectory();
    final folder = Directory('${root.path}${Platform.pathSeparator}custom_audio');
    if (!await folder.exists()) await folder.create(recursive: true);

    final originalName = _safeName(source.name);
    final extension = _extensionOf(originalName);
    final stamp = DateTime.now().microsecondsSinceEpoch;
    final destination = File(
      '${folder.path}${Platform.pathSeparator}${bucket}_$stamp$extension',
    );
    final temporary = File('${destination.path}.part');
    try {
      final sink = temporary.openWrite();
      try {
        await source.openRead().pipe(sink);
      } catch (_) {
        await sink.close();
        rethrow;
      }
      await temporary.rename(destination.path);
      return destination.path;
    } catch (_) {
      if (await temporary.exists()) await temporary.delete();
      rethrow;
    }
  }

  static String _safeName(String value) =>
      value.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');

  static String _extensionOf(String value) {
    final dot = value.lastIndexOf('.');
    if (dot < 0 || dot == value.length - 1) return '.audio';
    return value.substring(dot).toLowerCase();
  }

  static String displayName(String path) {
    final normalized = path.replaceAll('\\', '/');
    return normalized.split('/').last;
  }
}
