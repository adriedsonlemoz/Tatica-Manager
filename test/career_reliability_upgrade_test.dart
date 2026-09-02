import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/data/club_seed.dart';
import 'package:tatica_manager/domain/career/manager_profile.dart';
import 'package:tatica_manager/domain/season/career_event.dart';
import 'package:tatica_manager/domain/season/career_state.dart';
import 'package:tatica_manager/game/career/board_objective_engine.dart';
import 'package:tatica_manager/game/career/career_factory.dart';
import 'package:tatica_manager/game/league/live_round_simulator.dart';
import 'package:tatica_manager/game/season/career_news_archive.dart';

void main() {
  test('meta da diretoria nasce vinculada ao clube e temporada da carreira', () {
    final career = CareerFactory.create(
      careerId: 'board-objective',
      careerName: 'Diretoria',
      manager: const ManagerProfile(displayName: 'Técnico Teste'),
      userClubId: clubSeeds.first.id,
    );

    final objective = BoardObjectiveEngine.create(career);

    expect(objective.clubId, career.userClubId);
    expect(objective.season, career.season);
    expect(objective.targetPosition, inInclusiveRange(1, 20));
  });

  test('perfil do técnico CPU define a formação usada na simulação', () {
    final career = CareerFactory.create(
      careerId: 'cpu-manager-style',
      careerName: 'CPU',
      manager: const ManagerProfile(displayName: 'Técnico Teste'),
      userClubId: clubSeeds.first.id,
    );
    final club = career.clubs.firstWhere((item) => item.id != career.userClubId);
    final manager = LiveRoundSimulator.managerFor(career, club.id)!;

    expect(
      LiveRoundSimulator.formationFor(club, manager: manager),
      manager.preferredFormation,
    );
    expect(LiveRoundSimulator.tacticFor(club, manager: manager), isNotNull);
  });

  test('notícias antigas migram para o arquivo sem sair da carreira', () {
    final events = List.generate(
      122,
      (index) => CareerEvent(
        id: 'news-$index',
        date: DateTime(2026, 1, 1).add(Duration(days: index)),
        type: CareerEventType.info,
        title: 'Notícia $index',
        message: 'Evento persistido.',
      ),
    );

    final retained = CareerNewsArchive.append(
      recent: const [],
      archive: const [],
      events: events,
    );

    expect(retained.recent, hasLength(120));
    expect(retained.archive, hasLength(2));
    expect(retained.archive.first.id, 'news-0');
    expect(retained.recent.first.id, 'news-2');
  });

  test('meta e arquivo de notícias sobrevivem ao save da carreira', () {
    final career = CareerFactory.create(
      careerId: 'reliability-save',
      careerName: 'Persistência',
      manager: const ManagerProfile(displayName: 'Técnico Teste'),
      userClubId: clubSeeds.first.id,
    ).copyWith(
      newsArchive: [
        CareerEvent(
          id: 'archived-event',
          date: DateTime(2026, 1, 1),
          type: CareerEventType.info,
          title: 'Arquivo',
          message: 'Notícia antiga.',
        ),
      ],
    );

    final restored = CareerState.fromJson(career.toJson());

    expect(restored.boardObjective.targetPosition, career.boardObjective.targetPosition);
    expect(restored.newsArchive.single.id, 'archived-event');
  });
}
