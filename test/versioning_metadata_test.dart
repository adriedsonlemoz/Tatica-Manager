import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('metadados oficiais da release permanecem sincronizados', () {
    final visible = File('VERSION').readAsStringSync().trim();
    final app = jsonDecode(File('app.json').readAsStringSync())
        as Map<String, dynamic>;
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final pubspecMatch = RegExp(r'^version:\s*(\d+\.\d+\.\d+)\+(\d+)\s*$', multiLine: true)
        .firstMatch(pubspec);

    expect(visible, matches(RegExp(r'^\d+\.\d+\.\d+\.\d+$')));
    expect(pubspecMatch, isNotNull);
    final versionCode = int.parse(pubspecMatch!.group(2)!);
    expect(versionCode, greaterThan(0));
    expect(app['version'], visible);
    expect(app['type'], 'flutter');

    final appInfo = File('lib/core/config/app_info.dart').readAsStringSync();
    expect(appInfo, contains("static const String version = '$visible'"));

    final android = File('android/app/build.gradle.kts').readAsStringSync();
    expect(android, contains('versionName = "$visible"'));
    expect(android, contains('versionCode = $versionCode'));
    expect(File('al-sistemas.json').existsSync(), isFalse);
  });
}
