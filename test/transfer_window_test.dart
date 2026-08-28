import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/game/transfer/transfer_window_engine.dart';

void main() {
  test('janelas de transferências respeitam abertura e fechamento', () {
    expect(TransferWindowEngine.isOpen(DateTime(2026, 1, 1)), isTrue);
    expect(TransferWindowEngine.isOpen(DateTime(2026, 4, 30)), isTrue);
    expect(TransferWindowEngine.isOpen(DateTime(2026, 5, 1)), isFalse);
    expect(TransferWindowEngine.isOpen(DateTime(2026, 7, 1)), isTrue);
    expect(TransferWindowEngine.isOpen(DateTime(2026, 9, 30)), isTrue);
    expect(TransferWindowEngine.isOpen(DateTime(2026, 10, 1)), isFalse);
  });

  test('controlador bloqueia compra e venda quando a janela está fechada', () {
    final controller =
        File('lib/app/state/transfer_controller.dart').readAsStringSync();

    expect(
      RegExp(r'TransferWindowEngine\.isOpen\(career\.currentDate\)')
          .allMatches(controller)
          .length,
      greaterThanOrEqualTo(3),
    );
    expect(controller, contains('A janela de transferências está fechada'));
  });
}
