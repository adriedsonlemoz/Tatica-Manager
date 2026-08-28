import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/data/club_seed.dart';
import 'package:tatica_manager/domain/match/match_models.dart';
import 'package:tatica_manager/game/league/league_engine.dart';

void main() {
  test('movimento da classificação compara rodada atual com a anterior', () {
    final clubs = clubSeeds.take(4).map((seed) => seed.toClub()).toList();
    final fixtures = [
      MatchFixture(
        id: 'r1-a',
        round: 1,
        homeClubId: clubs[0].id,
        awayClubId: clubs[1].id,
        date: DateTime(2026, 4, 1),
        played: true,
        score: const MatchScore(1, 0),
      ),
      MatchFixture(
        id: 'r1-b',
        round: 1,
        homeClubId: clubs[2].id,
        awayClubId: clubs[3].id,
        date: DateTime(2026, 4, 1),
        played: true,
        score: const MatchScore(3, 0),
      ),
      MatchFixture(
        id: 'r2-a',
        round: 2,
        homeClubId: clubs[0].id,
        awayClubId: clubs[2].id,
        date: DateTime(2026, 4, 8),
        played: true,
        score: const MatchScore(4, 0),
      ),
      MatchFixture(
        id: 'r2-b',
        round: 2,
        homeClubId: clubs[1].id,
        awayClubId: clubs[3].id,
        date: DateTime(2026, 4, 8),
        played: true,
        score: const MatchScore(2, 0),
      ),
    ];

    final movement = LeagueEngine.positionMovement(clubs, fixtures);

    expect(movement[clubs[0].id], 1);
    expect(movement[clubs[1].id], 1);
    expect(movement[clubs[2].id], -2);
    expect(movement[clubs[3].id], 0);
  });

  test('primeira rodada não inventa subida ou queda', () {
    final clubs = clubSeeds.take(2).map((seed) => seed.toClub()).toList();
    final fixtures = [
      MatchFixture(
        id: 'r1',
        round: 1,
        homeClubId: clubs[0].id,
        awayClubId: clubs[1].id,
        date: DateTime(2026, 4, 1),
        played: true,
        score: const MatchScore(2, 0),
      ),
    ];

    expect(
      LeagueEngine.positionMovement(clubs, fixtures).values,
      everyElement(0),
    );
  });
}
