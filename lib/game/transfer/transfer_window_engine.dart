abstract final class TransferWindowEngine {
  /// Regras de mercado do universo atual do jogo. Como ainda existe apenas
  /// uma liga, usamos duas janelas simples e previsíveis por temporada.
  static bool isOpen(DateTime date) {
    final day = _dateOnly(date);
    return _inFirstWindow(day) || _inSecondWindow(day);
  }

  static String statusLabel(DateTime date) =>
      isOpen(date) ? 'Janela aberta' : 'Janela fechada';

  static String get rulesLabel => '1 jan – 30 abr • 1 jul – 30 set';

  /// Chave estável da janela corrente para engines que precisam manter uma
  /// estratégia coerente durante o mesmo período sem persistir estado extra.
  /// Regras futuras por competição devem continuar centralizadas aqui/catálogo
  /// de competições, e não ser duplicadas dentro dos engines da CPU.
  static String periodKey(DateTime date) {
    final day = _dateOnly(date);
    if (_inFirstWindow(day)) return '${day.year}-window-1';
    if (_inSecondWindow(day)) return '${day.year}-window-2';
    return '${day.year}-closed-${day.month}';
  }

  static DateTime? nextOpening(DateTime date) {
    final day = _dateOnly(date);
    final july = DateTime(date.year, 7, 1);
    if (day.isBefore(july)) return july;
    return DateTime(date.year + 1, 1, 1);
  }

  static bool _inFirstWindow(DateTime day) {
    final start = DateTime(day.year, 1, 1);
    final end = DateTime(day.year, 4, 30);
    return !day.isBefore(start) && !day.isAfter(end);
  }

  static bool _inSecondWindow(DateTime day) {
    final start = DateTime(day.year, 7, 1);
    final end = DateTime(day.year, 9, 30);
    return !day.isBefore(start) && !day.isAfter(end);
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
