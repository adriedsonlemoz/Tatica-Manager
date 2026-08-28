import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';

class PlayerPhotoException implements Exception {
  const PlayerPhotoException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Importa fotos escolhidas pelo editor e mantém uma cópia pequena no
/// armazenamento privado do aplicativo. O save guarda somente o caminho.
class PlayerPhotoStore {
  const PlayerPhotoStore();

  static const int maxSourceBytes = 8 * 1024 * 1024;
  static const int minDimension = 128;
  static const int maxDimension = 6000;
  static const int targetDimension = 512;
  static const int maxNormalizedBytes = 900 * 1024;

  static const XTypeGroup acceptedImages = XTypeGroup(
    label: 'Fotos do jogador',
    extensions: <String>['jpg', 'jpeg', 'png', 'webp'],
  );

  Future<String> importPhoto({
    required String playerId,
    required XFile source,
    double cropAlignmentX = 0,
    double cropAlignmentY = 0,
    double cropZoom = 1,
  }) async {
    final sourceLength = await source.length();
    if (sourceLength <= 0) {
      throw const PlayerPhotoException('A imagem selecionada está vazia.');
    }
    if (sourceLength > maxSourceBytes) {
      throw const PlayerPhotoException(
        'A imagem é muito pesada. Escolha um arquivo de até 8 MB.',
      );
    }

    final bytes = await source.readAsBytes();
    if (!_isSupportedImage(bytes)) {
      throw const PlayerPhotoException(
        'Formato inválido. Use PNG, JPG/JPEG ou WebP.',
      );
    }

    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    if (image.width < minDimension || image.height < minDimension) {
      throw const PlayerPhotoException(
        'A foto precisa ter pelo menos 128 × 128 pixels.',
      );
    }
    if (image.width > maxDimension || image.height > maxDimension) {
      throw const PlayerPhotoException(
        'A foto excede 6000 pixels. Reduza a imagem antes de importar.',
      );
    }

    final alignmentX = cropAlignmentX.clamp(-1.0, 1.0).toDouble();
    final alignmentY = cropAlignmentY.clamp(-1.0, 1.0).toDouble();
    final zoom = cropZoom.clamp(1.0, 2.5).toDouble();
    var normalized = await _squarePng(
      image,
      targetDimension,
      alignmentX: alignmentX,
      alignmentY: alignmentY,
      zoom: zoom,
    );
    if (normalized.length > maxNormalizedBytes) {
      normalized = await _squarePng(
        image,
        384,
        alignmentX: alignmentX,
        alignmentY: alignmentY,
        zoom: zoom,
      );
    }

    final directory = await _photoDirectory();
    final safeId = playerId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final path = '${directory.path}/$safeId-${DateTime.now().microsecondsSinceEpoch}.png';
    final file = File(path);
    await file.writeAsBytes(normalized, flush: true);
    return file.path;
  }

  Future<void> deleteManagedPhoto(String? path) async {
    if (path == null || path.trim().isEmpty) return;
    final directory = await _photoDirectory();
    final candidate = File(path);
    final root = '${directory.absolute.path}${Platform.pathSeparator}';
    if (!candidate.absolute.path.startsWith(root)) return;
    if (await candidate.exists()) await candidate.delete();
  }

  Future<Directory> _photoDirectory() async {
    final support = await getApplicationSupportDirectory();
    final directory = Directory('${support.path}/player_photos');
    if (!await directory.exists()) await directory.create(recursive: true);
    return directory;
  }

  bool _isSupportedImage(Uint8List bytes) {
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return true;
    }
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return true;
    }
    if (bytes.length >= 12) {
      final riff = String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF';
      final webp = String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP';
      if (riff && webp) return true;
    }
    return false;
  }

  Future<Uint8List> _squarePng(
    ui.Image image,
    int dimension, {
    required double alignmentX,
    required double alignmentY,
    required double zoom,
  }) async {
    final baseSide = image.width < image.height ? image.width : image.height;
    final side = (baseSide / zoom).clamp(1.0, baseSide.toDouble()).toDouble();
    final maxLeft = (image.width - side).clamp(0.0, image.width.toDouble()).toDouble();
    final maxTop = (image.height - side).clamp(0.0, image.height.toDouble()).toDouble();
    final left = (maxLeft * ((alignmentX + 1) / 2)).toDouble();
    final top = (maxTop * ((alignmentY + 1) / 2)).toDouble();
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.drawImageRect(
      image,
      ui.Rect.fromLTWH(left, top, side, side),
      ui.Rect.fromLTWH(0, 0, dimension.toDouble(), dimension.toDouble()),
      ui.Paint()..filterQuality = ui.FilterQuality.high,
    );
    final picture = recorder.endRecording();
    final normalized = await picture.toImage(dimension, dimension);
    final byteData = await normalized.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw const PlayerPhotoException('Não foi possível processar a foto.');
    }
    return byteData.buffer.asUint8List();
  }
}
