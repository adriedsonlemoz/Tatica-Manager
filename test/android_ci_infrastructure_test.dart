import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android permanece versionado e alinhado ao CI', () {
    expect(File('android/settings.gradle.kts').existsSync(), isTrue);
    expect(File('android/app/build.gradle.kts').existsSync(), isTrue);
    expect(File('android/app/src/main/AndroidManifest.xml').existsSync(), isTrue);

    final manifest = jsonDecode(File('al-sistemas.json').readAsStringSync())
        as Map<String, dynamic>;
    final android = manifest['android'] as Map<String, dynamic>;
    final expectedVersionName = android['versionName'] as String;
    final expectedVersionCode = android['versionCode'] as int;

    final settings = File('android/settings.gradle.kts').readAsStringSync();
    final appGradle = File('android/app/build.gradle.kts').readAsStringSync();
    final gradleProperties = File('android/gradle.properties').readAsStringSync();
    final wrapperProperties =
        File('android/gradle/wrapper/gradle-wrapper.properties').readAsStringSync();
    final workflow =
        File('.github/workflows/flutter-ci.yml').readAsStringSync();

    expect(settings, contains('com.android.application") version "9.1.0"'));
    expect(settings, contains('org.jetbrains.kotlin.android") version "2.4.0"'));
    expect(wrapperProperties, contains('gradle-9.3.1-all.zip'));
    expect(gradleProperties, contains('android.builtInKotlin=false'));
    expect(gradleProperties, contains('android.newDsl=false'));
    expect(appGradle, contains('versionCode = $expectedVersionCode'));
    expect(appGradle, contains('versionName = "$expectedVersionName"'));
    expect(appGradle, contains('id("org.jetbrains.kotlin.android")'));
    expect(appGradle, contains('JvmTarget.JVM_17'));
    expect(workflow, contains("java-version: '17'"));
    expect(workflow, contains('python3 tool/verify_app_icons.py'));
    expect(workflow, contains("flutter-version: '3.47.1'"));
    expect(workflow, contains('cache: gradle'));
    expect(workflow, isNot(contains('flutter create')));
    expect(workflow, isNot(contains('flutter clean')));
    expect(workflow, contains('actions/checkout@v7.0.1'));
    expect(workflow, contains('actions/upload-artifact@v7.0.1'));
    expect(workflow, contains('flutter analyze --no-pub'));
    expect(workflow, contains('flutter test --no-pub'));
    expect(workflow, contains('flutter build apk --release --no-pub'));
    expect(workflow, contains('Validar configuração opcional da assinatura persistente'));
    expect(workflow, contains('esta build usará temporariamente a chave debug do runner'));
    expect(appGradle, contains('signingConfigs.getByName("debug")'));
    expect(workflow, contains('GRADLE_OPTS: -Dorg.gradle.vfs.watch=false'));
    expect(workflow, contains('Upload somente do APK'));
    expect(workflow, contains('archive: false'));
    expect(workflow, isNot(contains('-pubspec.lock')));
  });
}
