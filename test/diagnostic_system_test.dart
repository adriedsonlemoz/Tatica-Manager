import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('diagnóstico possui captura global, persistência limitada e relatório', () {
    final source = File('lib/core/diagnostics/diagnostic_service.dart').readAsStringSync();
    expect(source, contains('FlutterError.onError'));
    expect(source, contains('PlatformDispatcher.instance.onError'));
    expect(source, contains('maxEntries = 80'));
    expect(source, contains('maxFileBytes = 256 * 1024'));
    expect(source, contains('TÁTICA MANAGER • DIAGNÓSTICO'));
    expect(source, contains('=== REGISTROS FLUTTER / DART ==='));
    expect(source, contains('recordFlutterError'));
    expect(source, contains('details.context'));
    expect(source, contains("type: 'FLUTTER_ERROR'"));
  });

  test('Central de Diagnóstico oferece ações e acesso discreto em Sobre', () {
    final screen = File('lib/features/diagnostics/diagnostic_screen.dart').readAsStringSync();
    final settings = File('lib/features/settings/settings_screen.dart').readAsStringSync();
    final hub = File('lib/features/career/career_hub_screen.dart').readAsStringSync();
    final controller = File('lib/app/state/career_controller.dart').readAsStringSync();
    expect(screen, contains("Text('Atualizar')"));
    expect(screen, contains("Text('Copiar')"));
    expect(screen, contains("Text('Exportar TXT')"));
    expect(screen, contains("Text('Limpar')"));
    expect(settings, contains('onLongPress:'));
    expect(settings, contains('DiagnosticScreen'));
    expect(hub, contains('Tática Manager Beta 2.0'));
    expect(hub, contains('DiagnosticScreen'));
    expect(controller, contains("'CAREER_OPEN_ERROR'"));
    expect(controller, contains("'CAREER_CREATE_ERROR'"));
    expect(screen, contains('Erros registrados'));
    expect(screen, contains('Contexto / origem'));
  });

  test('Android coleta última saída e exporta em Downloads/TaticaManager', () {
    final native = File('android/app/src/main/kotlin/com/taticamanager/tatica_manager/MainActivity.kt').readAsStringSync();
    expect(native, contains('getHistoricalProcessExitReasons'));
    expect(native, contains('Thread.setDefaultUncaughtExceptionHandler'));
    expect(native, contains('MediaStore.Downloads'));
    expect(native, contains('TaticaManager'));
    expect(native, contains('CRASH_NATIVE'));
    expect(native, contains('ANR'));
    expect(native, contains('LOW_MEMORY'));
  });
}
