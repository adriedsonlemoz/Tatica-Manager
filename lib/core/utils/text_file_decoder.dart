import 'dart:convert';
import 'dart:typed_data';

abstract final class TextFileDecoder {
  static String decode(Uint8List bytes) {
    var data = bytes;
    if (data.length >= 3 && data[0] == 0xEF && data[1] == 0xBB && data[2] == 0xBF) {
      data = Uint8List.sublistView(data, 3);
    }
    if (data.length >= 2 && data[0] == 0xFF && data[1] == 0xFE) {
      return const Utf16LittleEndianDecoder().convert(data.sublist(2));
    }
    if (data.length >= 2 && data[0] == 0xFE && data[1] == 0xFF) {
      return const Utf16BigEndianDecoder().convert(data.sublist(2));
    }

    final probeLength = data.length < 240 ? data.length : 240;
    final probe = latin1.decode(data.sublist(0, probeLength), allowInvalid: true).toLowerCase();
    final declared = RegExp(r'''encoding\s*=\s*["']([^"']+)["']''').firstMatch(probe)?.group(1);
    if (declared != null) {
      if (declared.contains('1252')) return _windows1252(data);
      if (declared.contains('8859-1') || declared.contains('latin1') || declared.contains('latin-1')) {
        return latin1.decode(data, allowInvalid: true);
      }
      if (declared.contains('utf-16le')) return const Utf16LittleEndianDecoder().convert(data);
      if (declared.contains('utf-16be')) return const Utf16BigEndianDecoder().convert(data);
    }

    try {
      return utf8.decode(data, allowMalformed: false);
    } on FormatException {
      return _windows1252(data);
    }
  }

  static String _windows1252(Uint8List bytes) {
    const replacements = <int, int>{
      0x80: 0x20AC, 0x82: 0x201A, 0x83: 0x0192, 0x84: 0x201E,
      0x85: 0x2026, 0x86: 0x2020, 0x87: 0x2021, 0x88: 0x02C6,
      0x89: 0x2030, 0x8A: 0x0160, 0x8B: 0x2039, 0x8C: 0x0152,
      0x8E: 0x017D, 0x91: 0x2018, 0x92: 0x2019, 0x93: 0x201C,
      0x94: 0x201D, 0x95: 0x2022, 0x96: 0x2013, 0x97: 0x2014,
      0x98: 0x02DC, 0x99: 0x2122, 0x9A: 0x0161, 0x9B: 0x203A,
      0x9C: 0x0153, 0x9E: 0x017E, 0x9F: 0x0178,
    };
    final codes = bytes.map((byte) => replacements[byte] ?? byte).toList(growable: false);
    return String.fromCharCodes(codes);
  }
}

class Utf16LittleEndianDecoder extends Converter<List<int>, String> {
  const Utf16LittleEndianDecoder();
  @override
  String convert(List<int> input) {
    final codes = <int>[];
    for (var i = 0; i + 1 < input.length; i += 2) {
      codes.add(input[i] | (input[i + 1] << 8));
    }
    return String.fromCharCodes(codes);
  }
}

class Utf16BigEndianDecoder extends Converter<List<int>, String> {
  const Utf16BigEndianDecoder();
  @override
  String convert(List<int> input) {
    final codes = <int>[];
    for (var i = 0; i + 1 < input.length; i += 2) {
      codes.add((input[i] << 8) | input[i + 1]);
    }
    return String.fromCharCodes(codes);
  }
}
