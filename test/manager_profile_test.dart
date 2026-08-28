import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/domain/career/manager_appearance.dart';
import 'package:tatica_manager/domain/career/manager_profile.dart';

void main() {
  test('manager profile serializes appearance and omits repeated country in summary', () {
    const appearance = ManagerAppearance(
      skinTone: 4,
      hairStyle: 3,
      hairColor: 2,
      beardStyle: 1,
      moustacheStyle: 2,
      detailStyle: 4,
    );
    final profile = ManagerProfile.normalized(
      displayName: 'Adriedson Lemos',
      nickname: 'Drie',
      nationality: 'Brasil',
      ageAtStart: 35,
      careerStartSeason: 2026,
      birthCountry: 'Brasil',
      birthState: 'SP',
      birthCity: 'Santa Isabel',
      appearance: appearance,
    );

    final restored = ManagerProfile.fromJson(profile.toJson());

    expect(restored.displayName, 'Adriedson Lemos');
    expect(restored.nickname, 'Drie');
    expect(restored.birthPlaceSummary(omitCountry: true), 'Santa Isabel, SP');
    expect(restored.appearance.hairStyle, 3);
    expect(restored.appearance.hairColor, 2);
    expect(restored.appearance.moustacheStyle, 2);
  });


  test('manager avatar identity maps age style and keeps seed stable', () {
    const appearance = ManagerAppearance();

    final young = appearance.toAvatarIdentity('manager:test-seed', age: 24);
    final experienced = appearance.toAvatarIdentity('manager:test-seed', age: 31);
    final veteran = appearance.toAvatarIdentity('manager:test-seed', age: 40);

    expect(young.seed, experienced.seed);
    expect(experienced.seed, veteran.seed);
    expect(young.ageStyle, 0);
    expect(experienced.ageStyle, 1);
    expect(veteran.ageStyle, 2);
  });
}
