import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('metadados oficiais da release permanecem sincronizados', () {
    final manifest = jsonDecode(File('al-sistemas.json').readAsStringSync())
        as Map<String, dynamic>;
    final app = jsonDecode(File('app.json').readAsStringSync())
        as Map<String, dynamic>;
    final visible = manifest['version'] as String;
    final flutter = manifest['flutter'] as Map<String, dynamic>;
    final android = manifest['android'] as Map<String, dynamic>;
    final pubspecVersion = flutter['pubspecVersion'] as String;
    final versionCode = android['versionCode'] as int;

    expect(visible, matches(RegExp(r'^\d+\.\d+\.\d+\.\d+$')));
    expect(versionCode, greaterThan(0));
    expect(File('VERSION').readAsStringSync().trim(), visible);
    expect(app['version'], visible);
    expect(app['type'], 'flutter');
    expect(android['versionName'], visible);

    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('version: $pubspecVersion'));

    final appInfo = File('lib/core/config/app_info.dart').readAsStringSync();
    expect(appInfo, contains("static const String version = '$visible'"));
  });
}
