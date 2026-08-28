import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../config/app_info.dart';
import 'diagnostic_platform.dart';

class DiagnosticEntry {
  const DiagnosticEntry({required this.time, required this.type, required this.message, this.stack});
  final DateTime time;
  final String type;
  final String message;
  final String? stack;

  Map<String, dynamic> toJson() => {
        'time': time.toIso8601String(),
        'type': type,
        'message': message,
        if (stack != null && stack!.isNotEmpty) 'stack': stack,
      };

  factory DiagnosticEntry.fromJson(Map<String, dynamic> json) => DiagnosticEntry(
        time: DateTime.tryParse(json['time'] as String? ?? '') ?? DateTime.now(),
        type: json['type'] as String? ?? 'UNKNOWN',
        message: json['message'] as String? ?? '',
        stack: json['stack'] as String?,
      );
}

class DiagnosticService {
  DiagnosticService._();
  static final DiagnosticService instance = DiagnosticService._();
  static const int maxEntries = 80;
  static const int maxFileBytes = 256 * 1024;

  final DiagnosticPlatform _platform = const DiagnosticPlatform();
  final List<DiagnosticEntry> _entries = [];
  File? _file;
  bool _initialized = false;
  Future<void> _writeQueue = Future.value();

  List<DiagnosticEntry> get entries => List.unmodifiable(_entries.reversed);

  Future<void> initialize() async {
    if (_initialized) return;
    final root = await getApplicationSupportDirectory();
    _file = File('${root.path}${Platform.pathSeparator}diagnostics.jsonl');
    await _load();
    _initialized = true;
    await checkpoint('Inicialização do aplicativo');
  }

  Future<void> _load() async {
    final file = _file;
    if (file == null || !await file.exists()) return;
    try {
      final length = await file.length();
      if (length > maxFileBytes * 2) {
        await file.delete();
        return;
      }
      final lines = await file.readAsLines();
      for (final line in lines.skip(lines.length > maxEntries ? lines.length - maxEntries : 0)) {
        try {
          _entries.add(DiagnosticEntry.fromJson(jsonDecode(line) as Map<String, dynamic>));
        } catch (_) {}
      }
    } catch (_) {}
  }

  Future<void> record(String type, Object error, [StackTrace? stack]) => _append(
        DiagnosticEntry(time: DateTime.now(), type: type, message: error.toString(), stack: stack?.toString()),
      );

  Future<void> checkpoint(String message) => _append(
        DiagnosticEntry(time: DateTime.now(), type: 'CHECKPOINT', message: message),
      );

  Future<void> _append(DiagnosticEntry entry) async {
    if (!_initialized) return;
    _entries.add(entry);
    if (_entries.length > maxEntries) _entries.removeRange(0, _entries.length - maxEntries);
    _writeQueue = _writeQueue.then((_) => _rewrite());
    await _writeQueue;
  }

  Future<void> _rewrite() async {
    final file = _file;
    if (file == null) return;
    final data = _entries.map((entry) => jsonEncode(entry.toJson())).join('\n');
    await file.writeAsString(data.isEmpty ? '' : '$data\n', flush: true);
  }

  Future<void> clear() async {
    _entries.clear();
    await _rewrite();
    await _platform.clearNative();
  }

  Future<String> buildReport() async {
    final generated = DateTime.now();
    final device = await _platform.deviceInfo();
    final buffer = StringBuffer()
      ..writeln('TÁTICA MANAGER • DIAGNÓSTICO')
      ..writeln('Versão: ${AppInfo.version}')
      ..writeln('Gerado em: ${generated.toIso8601String()}')
      ..writeln('\n=== DISPOSITIVO / ÚLTIMA SAÍDA ===');
    const ordered = ['manufacturer', 'model', 'android', 'sdk', 'abis', 'lastExit', 'lastExitTimestamp', 'lastExitDescription', 'lastExitTrace', 'nativeCrash'];
    for (final key in ordered) {
      final value = device[key];
      if (value != null && value.toString().trim().isNotEmpty) buffer.writeln('${_label(key)}: $value');
    }
    if (device['platformError'] != null) buffer.writeln('erro_plataforma: ${device['platformError']}');
    buffer.writeln('\n=== REGISTROS FLUTTER / DART ===');
    if (_entries.isEmpty) {
      buffer.writeln('Nenhum registro persistido.');
    } else {
      for (final entry in entries) {
        buffer.writeln('[${entry.time.toIso8601String()}] ${entry.type}: ${entry.message}');
        if (entry.stack != null && entry.stack!.isNotEmpty) buffer.writeln(entry.stack);
        buffer.writeln();
      }
    }
    return buffer.toString();
  }

  Future<String?> exportReport() async {
    final report = await buildReport();
    final stamp = DateTime.now().toIso8601String().replaceAll(RegExp(r'[:.]'), '-');
    return _platform.exportTxt(report, 'tatica-manager-diagnostico-$stamp.txt');
  }

  static String _label(String key) => const {
        'manufacturer': 'fabricante', 'model': 'modelo', 'android': 'android', 'sdk': 'sdk', 'abis': 'abis',
        'lastExit': 'ultima_saida', 'lastExitTimestamp': 'ultima_saida_horario', 'lastExitDescription': 'ultima_saida_descricao',
        'lastExitTrace': 'rastro_ultima_saida', 'nativeCrash': 'excecao_android_anterior',
      }[key] ?? key;
}

void installGlobalDiagnostics() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    unawaited(DiagnosticService.instance.record('FLUTTER_ERROR', details.exception, details.stack));
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    unawaited(DiagnosticService.instance.record('DART_ASYNC_ERROR', error, stack));
    return false;
  };
}
