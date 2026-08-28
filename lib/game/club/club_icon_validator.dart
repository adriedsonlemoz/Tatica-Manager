import 'dart:convert';

class ClubIconDimensions {
  const ClubIconDimensions(this.width, this.height);

  final int width;
  final int height;
}

abstract final class ClubIconValidator {
  static const int maxBytes = 256 * 1024;
  static const int minDimension = 32;
  static const int maxDimension = 1024;
  static const double maxAspectRatio = 2.0;

  static String? normalizeBase64(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) return null;
    try {
      final bytes = base64Decode(normalized);
      validateBytes(bytes);
      return base64Encode(bytes);
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException('O ícone do clube não está em Base64 válido.');
    }
  }

  static ClubIconDimensions validateBytes(List<int> bytes) {
    if (bytes.length > maxBytes) {
      throw const FormatException('O ícone do clube pode ter no máximo 256 KiB.');
    }
    if (bytes.length < 16) {
      throw const FormatException('O ícone precisa ser uma imagem PNG, JPG ou WebP válida.');
    }

    final dimensions = _pngDimensions(bytes) ??
        _jpegDimensions(bytes) ??
        _webpDimensions(bytes);
    if (dimensions == null) {
      throw const FormatException('O ícone precisa ser uma imagem PNG, JPG ou WebP válida.');
    }
    if (dimensions.width < minDimension || dimensions.height < minDimension) {
      throw const FormatException('O ícone precisa ter pelo menos 32 × 32 pixels.');
    }
    if (dimensions.width > maxDimension || dimensions.height > maxDimension) {
      throw const FormatException('O ícone pode ter no máximo 1024 × 1024 pixels.');
    }
    final ratio = dimensions.width / dimensions.height;
    if (ratio > maxAspectRatio || ratio < 1 / maxAspectRatio) {
      throw const FormatException(
        'O ícone deve usar proporção de escudo, sem ser mais largo ou alto que 2:1.',
      );
    }
    return dimensions;
  }

  static ClubIconDimensions? _pngDimensions(List<int> bytes) {
    if (bytes.length < 24 ||
        bytes[0] != 0x89 ||
        bytes[1] != 0x50 ||
        bytes[2] != 0x4E ||
        bytes[3] != 0x47 ||
        bytes[4] != 0x0D ||
        bytes[5] != 0x0A ||
        bytes[6] != 0x1A ||
        bytes[7] != 0x0A ||
        bytes[8] != 0x00 ||
        bytes[9] != 0x00 ||
        bytes[10] != 0x00 ||
        bytes[11] != 0x0D ||
        bytes[12] != 0x49 ||
        bytes[13] != 0x48 ||
        bytes[14] != 0x44 ||
        bytes[15] != 0x52) {
      return null;
    }
    final width = _u32be(bytes, 16);
    final height = _u32be(bytes, 20);
    if (width <= 0 || height <= 0) return null;
    return ClubIconDimensions(width, height);
  }

  static ClubIconDimensions? _jpegDimensions(List<int> bytes) {
    if (bytes.length < 4 || bytes[0] != 0xFF || bytes[1] != 0xD8) return null;
    var index = 2;
    while (index + 8 < bytes.length) {
      while (index < bytes.length && bytes[index] != 0xFF) {
        index++;
      }
      while (index < bytes.length && bytes[index] == 0xFF) {
        index++;
      }
      if (index >= bytes.length) return null;
      final marker = bytes[index++];
      if (marker == 0xD9 || marker == 0xDA) return null;
      if (marker == 0x01 || (marker >= 0xD0 && marker <= 0xD7)) continue;
      if (index + 1 >= bytes.length) return null;
      final length = (bytes[index] << 8) | bytes[index + 1];
      if (length < 2 || index + length > bytes.length) return null;
      final isSof = marker == 0xC0 ||
          marker == 0xC1 ||
          marker == 0xC2 ||
          marker == 0xC3 ||
          marker == 0xC5 ||
          marker == 0xC6 ||
          marker == 0xC7 ||
          marker == 0xC9 ||
          marker == 0xCA ||
          marker == 0xCB ||
          marker == 0xCD ||
          marker == 0xCE ||
          marker == 0xCF;
      if (isSof && length >= 7) {
        final height = (bytes[index + 3] << 8) | bytes[index + 4];
        final width = (bytes[index + 5] << 8) | bytes[index + 6];
        if (width <= 0 || height <= 0) return null;
        return ClubIconDimensions(width, height);
      }
      index += length;
    }
    return null;
  }

  static ClubIconDimensions? _webpDimensions(List<int> bytes) {
    if (bytes.length < 25 ||
        bytes[0] != 0x52 ||
        bytes[1] != 0x49 ||
        bytes[2] != 0x46 ||
        bytes[3] != 0x46 ||
        bytes[8] != 0x57 ||
        bytes[9] != 0x45 ||
        bytes[10] != 0x42 ||
        bytes[11] != 0x50) {
      return null;
    }
    final chunk = String.fromCharCodes(bytes.sublist(12, 16));
    if (chunk == 'VP8X' && bytes.length >= 30) {
      final width = 1 + bytes[24] + (bytes[25] << 8) + (bytes[26] << 16);
      final height = 1 + bytes[27] + (bytes[28] << 8) + (bytes[29] << 16);
      return ClubIconDimensions(width, height);
    }
    if (chunk == 'VP8L' && bytes.length >= 25 && bytes[20] == 0x2F) {
      final b1 = bytes[21];
      final b2 = bytes[22];
      final b3 = bytes[23];
      final b4 = bytes[24];
      final width = 1 + (b1 | ((b2 & 0x3F) << 8));
      final height = 1 + ((b2 >> 6) | (b3 << 2) | ((b4 & 0x0F) << 10));
      return ClubIconDimensions(width, height);
    }
    if (chunk == 'VP8 ' &&
        bytes.length >= 30 &&
        bytes[23] == 0x9D &&
        bytes[24] == 0x01 &&
        bytes[25] == 0x2A) {
      final width = (bytes[26] | (bytes[27] << 8)) & 0x3FFF;
      final height = (bytes[28] | (bytes[29] << 8)) & 0x3FFF;
      if (width <= 0 || height <= 0) return null;
      return ClubIconDimensions(width, height);
    }
    return null;
  }

  static int _u32be(List<int> bytes, int offset) =>
      (bytes[offset] << 24) |
      (bytes[offset + 1] << 16) |
      (bytes[offset + 2] << 8) |
      bytes[offset + 3];
}
