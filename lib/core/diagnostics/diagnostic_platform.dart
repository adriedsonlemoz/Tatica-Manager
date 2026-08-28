import 'package:flutter/services.dart';

class DiagnosticPlatform {
  const DiagnosticPlatform();

  static const _channel = MethodChannel('tatica_manager/diagnostics');

  Future<Map<String, dynamic>> deviceInfo() async {
    try {
      final value = await _channel.invokeMapMethod<String, dynamic>('deviceInfo');
      return value ?? const {};
    } catch (error) {
      return {'platformError': error.toString()};
    }
  }

  Future<void> clearNative() async {
    try {
      await _channel.invokeMethod<void>('clearNative');
    } catch (_) {}
  }

  Future<String?> exportTxt(String contents, String fileName) =>
      exportTextFile(contents, fileName);

  Future<String?> exportTextFile(String contents, String fileName) async {
    try {
      return await _channel.invokeMethod<String>('exportTxt', {
        'contents': contents,
        'fileName': fileName,
      });
    } catch (_) {
      return null;
    }
  }
}
