import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

({int width, int height, int colorType}) _pngInfo(String path) {
  final bytes = File(path).readAsBytesSync();
  expect(bytes.length, greaterThanOrEqualTo(26), reason: path);
  expect(bytes.sublist(1, 4), [0x50, 0x4e, 0x47], reason: path);
  final data = ByteData.sublistView(Uint8List.fromList(bytes));
  return (
    width: data.getUint32(16),
    height: data.getUint32(20),
    colorType: bytes[25],
  );
}

void _expectPng(String path, int pixels, {bool? alpha}) {
  expect(File(path).existsSync(), isTrue, reason: path);
  final info = _pngInfo(path);
  expect(info.width, pixels, reason: path);
  expect(info.height, pixels, reason: path);
  final hasAlpha = info.colorType == 4 || info.colorType == 6;
  if (alpha != null) expect(hasAlpha, alpha, reason: path);
}

void main() {
  test('Android possui launcher legacy e Adaptive Icon com duas camadas', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    expect(manifest, contains('android:icon="@mipmap/ic_launcher"'));
    expect(manifest, contains('android:roundIcon="@mipmap/ic_launcher_round"'));

    for (final name in ['ic_launcher.xml', 'ic_launcher_round.xml']) {
      final xml = File('android/app/src/main/res/mipmap-anydpi-v26/$name').readAsStringSync();
      expect(xml, contains('@mipmap/ic_launcher_foreground'));
      expect(xml, contains('@mipmap/ic_launcher_background'));
    }

    const densities = <String, double>{
      'mdpi': 1,
      'hdpi': 1.5,
      'xhdpi': 2,
      'xxhdpi': 3,
      'xxxhdpi': 4,
    };
    for (final entry in densities.entries) {
      final dir = 'android/app/src/main/res/mipmap-${entry.key}';
      final legacy = (48 * entry.value).round();
      final adaptive = (108 * entry.value).round();
      _expectPng('$dir/ic_launcher.png', legacy);
      _expectPng('$dir/ic_launcher_round.png', legacy);
      _expectPng('$dir/ic_launcher_foreground.png', adaptive, alpha: true);
      _expectPng('$dir/ic_launcher_background.png', adaptive, alpha: false);
    }
  });

  test('iOS AppIcon contém tamanhos de iPhone, iPad e App Store sem alpha', () {
    const base = 'ios/Runner/Assets.xcassets/AppIcon.appiconset';
    final contents = jsonDecode(File('$base/Contents.json').readAsStringSync()) as Map<String, dynamic>;
    final images = (contents['images'] as List).cast<Map<String, dynamic>>();

    expect(images.any((item) => item['idiom'] == 'iphone'), isTrue);
    expect(images.any((item) => item['idiom'] == 'ipad'), isTrue);
    expect(images.any((item) => item['idiom'] == 'ios-marketing'), isTrue);

    for (final item in images) {
      final filename = item['filename'] as String;
      final logical = double.parse((item['size'] as String).split('x').first);
      final scale = double.parse((item['scale'] as String).replaceAll('x', ''));
      _expectPng('$base/$filename', (logical * scale).round(), alpha: false);
    }
  });

  test('artes-fonte oficiais permanecem preservadas no projeto', () {
    _expectPng('assets/brand/launcher/icon-full.png', 1254, alpha: false);
    _expectPng('assets/brand/launcher/icon-foreground.png', 1254, alpha: true);
    _expectPng('assets/brand/launcher/icon-background.png', 1254, alpha: false);
    _expectPng('assets/brand/tatica-manager-icon.png', 1024, alpha: false);
    expect(File('assets/brand/launcher/source-hashes.json').existsSync(), isTrue);
  });
}
