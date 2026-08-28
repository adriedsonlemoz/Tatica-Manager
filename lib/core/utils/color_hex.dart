abstract final class ColorHex {
  static String format(int value) =>
      (value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase();

  static int parse(String source) {
    final value = source.trim().replaceAll('#', '').toUpperCase();
    if (!RegExp(r'^[0-9A-F]{6}$').hasMatch(value)) {
      throw const FormatException('Informe seis caracteres hexadecimais, por exemplo FFCC00.');
    }
    return int.parse('FF$value', radix: 16);
  }
}
