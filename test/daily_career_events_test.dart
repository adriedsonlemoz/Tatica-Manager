import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/data/club_seed.dart';
import 'package:tatica_manager/domain/career/manager_profile.dart';
import 'package:tatica_manager/domain/player/player.dart';
import 'package:tatica_manager/domain/season/career_event.dart';
import 'package:tatica_manager/domain/season/career_state.dart';
import 'package:tatica_manager/game/career/career_factory.dart';
import 'package:tatica_manager/game/player/player_development_engine.dart';
import 'package:tatica_manager/game/season/daily_career_engine.dart';

void main() {
  test('avanço diário gera treino e alerta da próxima partida', () {
    var career = CareerFactory.create(
      careerId: 'daily-events',
      careerName: 'Eventos diários',
      manager: const ManagerProfile(displayName: 'Técnico Teste'),
      userClubId: clubSeeds.first.id,
      seed: 20260824,
    );

    final first = DailyCareerEngine.advance(career);
    career = first.state;
    expect(
      first.events.any((event) => event.type == CareerEventType.training),
      isTrue,
    );
    expect(career.daysUntilNextMatch, 2);

    final second = DailyCareerEngine.advance(career);
    career = second.state;
    expect(career.daysUntilNextMatch, 1);
    expect(
      second.events.any((event) => event.type == CareerEventType.nextMatch),
      isTrue,
    );
    expect(career.news, isNotEmpty);
  });

  test('recuperação diária considera fadiga alta e lesão', () {
    final career = CareerFactory.create(
      careerId: 'recovery-rules',
      careerName: 'Recuperação',
      manager: const ManagerProfile(displayName: 'Técnico Teste'),
      userClubId: clubSeeds.first.id,
      seed: 20260824,
    );
    final base = career.userClub.squad.first;
    final tired = base.copyWith(condition: 60, fatigue: 60);
    final injured = base.copyWith(
      condition: 60,
      fatigue: 60,
      injury: const PlayerInjury(name: 'Contusão', roundsRemaining: 2),
    );

    final recovered = PlayerDevelopmentEngine.recoverDay([tired, injured]);

    expect(recovered[0].condition, 64);
    expect(recovered[0].fatigue, 54);
    expect(recovered[1].condition, 61);
    expect(recovered[1].fatigue, 58);
    expect(recovered[1].injury, isNotNull);
  });
  test('notícias persistentes têm limite para evitar save crescente', () {
    var career = CareerFactory.create(
      careerId: 'news-cap',
      careerName: 'Limite de notícias',
      manager: const ManagerProfile(displayName: 'Técnico Teste'),
      userClubId: clubSeeds.first.id,
      seed: 20260824,
    );
    career = career.copyWith(
      news: List.generate(
        CareerState.maxStoredNews,
        (index) => CareerEvent(
          id: 'old-$index',
          date: career.currentDate,
          type: CareerEventType.info,
          title: 'Antiga',
          message: 'Evento $index',
        ),
      ),
    );

    final next = DailyCareerEngine.advance(career).state;

    expect(next.news, hasLength(CareerState.maxStoredNews));
    expect(next.news.last.type, CareerEventType.training);
  });
}
