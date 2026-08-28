import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/data/club_seed.dart';
import 'package:tatica_manager/domain/career/manager_profile.dart';
import 'package:tatica_manager/domain/formation/formation.dart';
import 'package:tatica_manager/domain/tactic/tactic.dart';
import 'package:tatica_manager/game/career/career_factory.dart';
import 'package:tatica_manager/game/club/club_rating_calculator.dart';

void main() {
  test('nova carreira aplica perfil completo do técnico, formação e tática', () {
    const manager = ManagerProfile(
      displayName: 'Técnico Novo',
      nickname: 'Professor',
      nationality: 'Brasil',
      ageAtStart: 36,
      birthPlace: 'São Paulo, SP, Brasil',
      birthCountry: 'Brasil',
      birthState: 'SP',
      birthCity: 'São Paulo',
    );
    const tactic = Tactic(
      mentality: Mentality.attacking,
      pressing: Pressing.high,
      tempo: MatchTempo.fast,
    );

    final career = CareerFactory.create(
      careerId: 'career-setup',
      careerName: 'Projeto Campeão',
      manager: manager,
      userClubId: clubSeeds[1].id,
      formation: FormationType.f4231,
      tactic: tactic,
    );

    expect(career.careerName, 'Projeto Campeão');
    expect(career.manager.displayName, 'Técnico Novo');
    expect(career.manager.nickname, 'Professor');
    expect(career.manager.preferredName, 'Professor');
    expect(career.manager.ageInSeason(2026), 36);
    expect(career.manager.nationality, 'Brasil');
    expect(career.manager.birthPlace, 'São Paulo, SP, Brasil');
    expect(career.manager.birthState, 'SP');
    expect(career.manager.birthCity, 'São Paulo');
    expect(career.userClub.managerName, 'Técnico Novo');
    expect(career.managerHistory, hasLength(1));
    expect(career.managerHistory.single.season, 2026);
    expect(career.managerHistory.single.age, 36);
    expect(career.managerHistory.single.clubId, career.userClubId);
    expect(career.formation, FormationType.f4231);
    expect(career.tactic.mentality, Mentality.attacking);
    expect(career.starterIds, hasLength(11));
  });

  test('perfil do técnico normaliza dados e idade evolui por temporada', () {
    final manager = ManagerProfile.normalized(
      displayName: '  Maria   Souza ',
      nickname: '  Mari ',
      nationality: ' Brasil ',
      ageAtStart: 28,
      careerStartSeason: 2026,
      birthPlace: ' Recife ',
    );

    expect(manager.displayName, 'Maria Souza');
    expect(manager.nickname, 'Mari');
    expect(manager.ageInSeason(2026), 28);
    expect(manager.ageInSeason(2030), 32);
    expect(manager.birthPlace, 'Recife');
  });

  test('perfil estruturado deriva local de nascimento e preserva no histórico', () {
    final manager = ManagerProfile.normalized(
      displayName: 'Técnico Estruturado',
      nationality: 'Brasil',
      ageAtStart: 35,
      careerStartSeason: 2026,
      birthCountry: 'Brasil',
      birthState: 'MG',
      birthCity: 'Belo Horizonte',
    );
    final history = ManagerCareerHistoryEntry.fromProfile(
      manager,
      season: 2026,
      clubId: clubSeeds.first.id,
    );

    expect(manager.birthPlace, 'Belo Horizonte, MG, Brasil');
    expect(manager.birthCountry, 'Brasil');
    expect(manager.birthState, 'MG');
    expect(manager.birthCity, 'Belo Horizonte');
    expect(history.birthCity, 'Belo Horizonte');
    expect(history.birthState, 'MG');
  });

  test('overall de seleção usa os melhores jogadores e produz estrelas', () {
    final career = CareerFactory.create(
      careerId: 'career-rating',
      careerName: 'Rating',
      manager: const ManagerProfile(displayName: 'Técnico'),
      userClubId: clubSeeds.first.id,
      seed: 20260824,
    );
    final overall = ClubRatingCalculator.squadOverall(
      career.userClub.squad,
      fallback: career.userClub.reputation,
    );

    final sorted = career.userClub.squad.toList()
      ..sort((a, b) => b.overall.compareTo(a.overall));
    final expected = (sorted
                .take(18)
                .fold<int>(0, (sum, player) => sum + player.overall) /
            18)
        .round();

    expect(overall, expected);
    expect(overall, inInclusiveRange(1, 99));
    expect(ClubRatingCalculator.starsForOverall(overall), inInclusiveRange(1, 5));
  });

  test('perfil rejeita idade e nacionalidade inválidas', () {
    expect(
      () => ManagerProfile.normalized(
        displayName: 'Técnico Teste',
        nationality: 'Brasil',
        ageAtStart: 17,
      ),
      throwsFormatException,
    );
    expect(
      () => ManagerProfile.normalized(
        displayName: 'Técnico Teste',
        nationality: ' ',
        ageAtStart: 35,
      ),
      throwsFormatException,
    );
  });
}
