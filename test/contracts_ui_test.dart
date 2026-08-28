import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('contratos destacam risco de saída e renovação próxima', () {
    final source = [
      File('lib/features/contracts/contracts_screen.dart').readAsStringSync(),
      File('lib/features/contracts/contracts_components.dart').readAsStringSync(),
    ].join('\n');

    expect(source, contains('RISCO DE SAÍDA'));
    expect(source, contains('RENOVAR EM BREVE'));
    expect(source, contains('CONTRATO ATIVO'));
    expect(source, contains('AppColors.danger'));
    expect(source, contains('AppColors.warning'));
  });
}
