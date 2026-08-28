import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/tatica_manager_app.dart';
import 'core/platform/system_ui.dart';
import 'core/diagnostics/diagnostic_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DiagnosticService.instance.initialize();
  installGlobalDiagnostics();
  await SystemUiController.apply();
  runApp(const ProviderScope(child: TaticaManagerApp()));
}
