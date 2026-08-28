import 'dart:typed_data';

import '../../core/utils/text_file_decoder.dart';
import '../../domain/club/club_logo_pack.dart';

abstract final class ClubLogoPackImporter {
  static ClubLogoPack decodeBytes(Uint8List bytes) {
    final source = TextFileDecoder.decode(bytes).trim();
    return ClubLogoPack.decode(source);
  }
}
