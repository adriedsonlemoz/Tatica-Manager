import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/data/club_seed.dart';
import 'package:tatica_manager/domain/career/manager_profile.dart';
import 'package:tatica_manager/domain/season/career_event.dart';
import 'package:tatica_manager/game/career/career_factory.dart';
import 'package:tatica_manager/game/club/club_identity_engine.dart';
import 'package:tatica_manager/game/season/daily_career_engine.dart';

void main() {
  test('banco padrão cria técnicos fictícios distintos e completos', () {
    final managers = ClubIdentityEngine.defaultPack().managers!;

    expect(managers, hasLength(clubSeeds.length));
    expect(managers.map((item) => item.displayName).toSet(), hasLength(clubSeeds.length));
    expect(managers.any((item) => item.displayName == 'Técnico CPU'), isFalse);
    expect(managers.every((item) => item.birthPlaceSummary().isNotEmpty), isTrue);
    expect(managers.every((item) => item.contractUntilSeason != null), isTrue);
  });

  test('avanço diário adiciona prévia baseada na próxima partida real', () {
    final career = CareerFactory.create(
      careerId: 'news-preview',
      careerName: 'Notícias',
      manager: const ManagerProfile(displayName: 'Técnico Teste'),
      userClubId: clubSeeds.first.id,
      seed: 20260824,
    );

    final advance = DailyCareerEngine.advance(career);
    final preview = advance.events.where(
      (event) => event.id.startsWith('match-preview-'),
    );

    expect(preview, hasLength(1));
    expect(preview.single.type, CareerEventType.nextMatch);
    expect(preview.single.fixtureId, career.nextUserFixture!.id);
  });
}
