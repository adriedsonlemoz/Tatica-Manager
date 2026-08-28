import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('GitHub Actions publica somente o APK', () {
    final workflow =
        File('.github/workflows/flutter-ci.yml').readAsStringSync();

    expect(workflow, contains('Upload somente do APK'));
    expect(workflow, contains(r'tatica-manager-${{ steps.version.outputs.release }}.apk'));
    expect(workflow, isNot(contains('-pubspec.lock')));
    expect(workflow, isNot(contains('Upload lockfile')));
  });
}
