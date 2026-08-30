import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/core/config/app_info.dart';

void main() {
  test('Sobre / Novidades mantém três releases e canais de apoio', () {
    final manifest = jsonDecode(File('al-sistemas.json').readAsStringSync())
        as Map<String, dynamic>;
    final currentVersion = manifest['version'] as String;
    final releaseVersions =
        AppInfo.recentReleases.map((release) => release.version).toList();

    expect(AppInfo.version, currentVersion);
    expect(AppInfo.recentReleases, hasLength(3));
    expect(releaseVersions.first, currentVersion);
    expect(releaseVersions.toSet(), hasLength(releaseVersions.length));
    expect(
      AppInfo.recentReleases.every(
        (release) => release.title.isNotEmpty && release.changes.isNotEmpty,
      ),
      isTrue,
    );
    expect(AppInfo.contactEmail, 'adriedson@outlook.com');
    expect(AppInfo.pixKey, 'adriedson@outlook.com');
  });
}
