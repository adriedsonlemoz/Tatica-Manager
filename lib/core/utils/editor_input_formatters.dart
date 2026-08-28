import 'package:flutter/services.dart';

String formatEditableMoney(int value) {
  final digits = value.abs().toString();
  final groups = <String>[];
  for (var end = digits.length; end > 0; end -= 3) {
    final start = (end - 3).clamp(0, digits.length);
    groups.insert(0, digits.substring(start, end));
  }
  return 'R\$ ${groups.join('.')}';
}

int parseEditableMoney(String source) {
  final digits = source.replaceAll(RegExp(r'[^0-9]'), '');
  return digits.isEmpty ? 0 : int.parse(digits);
}

class BrazilianMoneyInputFormatter extends TextInputFormatter {
  const BrazilianMoneyInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(
        text: 'R\$ 0',
        selection: TextSelection.collapsed(offset: 4),
      );
    }
    final normalized = digits.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    final value = int.tryParse(normalized) ?? 0;
    final text = formatEditableMoney(value);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class HexColorInputFormatter extends TextInputFormatter {
  const HexColorInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final clean = newValue.text
        .replaceAll('#', '')
        .replaceAll(RegExp(r'[^0-9a-fA-F]'), '')
        .toUpperCase();
    final limited = clean.length > 6 ? clean.substring(0, 6) : clean;
    return TextEditingValue(
      text: limited,
      selection: TextSelection.collapsed(offset: limited.length),
    );
  }
}
