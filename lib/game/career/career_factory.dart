import 'dart:math';

import '../../data/club_seed.dart';
import '../../data/competition_catalog.dart';
import '../../domain/career/manager_career.dart';
import '../../domain/career/manager_profile.dart';
import '../../domain/club/club.dart';
import '../../domain/club/club_identity.dart';
import '../../domain/formation/formation.dart';
import '../../domain/season/career_state.dart';
import '../../domain/season/league_loading.dart';
import '../../domain/tactic/tactic.dart';
import '../club/club_identity_engine.dart';
import '../finance/club_administration_engine.dart';
import '../league/league_engine.dart';
import '../lineup/lineup_engine.dart';
import '../player/player_factory.dart';
import '../season/calendar_engine.dart';
import '../youth/youth_academy_engine.dart';
import 'career_league_planner.dart';

abstract final class CareerFactory {
  static CareerState create({
    required String careerId,
    required String careerName,
    required ManagerProfile manager,
    required String userClubId,
    FormationType formation = FormationType.f433,
    Tactic tactic = const Tactic(),
    int season = 2026,
    int seed = 20260824,
    ClubIdentityPack? clubIdentityPack,
    bool clubIdentityPackIsValidated = false,
    CareerLeagueSetup? leagueSetup,
    GameSettings settings = const GameSettings(),
  }) {
    final effectiveLeagueSetup = CareerLeaguePlanner.normalize(
      setup: leagueSetup ??
          CareerLeaguePlanner.forPreset(
            userClubId: userClubId,
            preset: CareerWorldPreset.balanced,
          ),
      userClubId: userClubId,
    );
    final activeClubIds = CareerLeaguePlanner.activeClubIds(effectiveLeagueSetup);
    final primarySeries = CompetitionCatalog.primarySeriesForClub(userClubId);
    final primaryClubIds = primarySeries.clubIds.toSet();

    final careerManager = manager.copyWith(
      careerStartSeason: season,
      currentClubId: userClubId,
    );
    final previousManagerClubId = manager.currentClubId;
    final normalizedPack = clubIdentityPack == null
        ? null
        : clubIdentityPackIsValidated
            ? clubIdentityPack
            : ClubIdentityEngine.normalizeAndValidatePack(clubIdentityPack);
    final identities = normalizedPack == null
        ? const <String, ClubIdentity>{}
        : {for (final identity in normalizedPack.clubs) identity.clubId: identity};
    final managersByClub = normalizedPack == null
        ? const <String, ManagerProfile>{}
        : {
            for (final manager
                in normalizedPack.managers ?? const <ManagerProfile>[])
              if (manager.currentClubId != null &&
                  activeClubIds.contains(manager.currentClubId))
                manager.currentClubId!: manager,
          };
    final playerFactory = PlayerFactory(random: Random(seed));
    final clubs = <Club>[];
    for (final seedClub in clubSeeds.where(
      (seedClub) => activeClubIds.contains(seedClub.id),
    )) {
      final seedBase = seedClub.toClub();
      final identity = identities[seedBase.id];
      final roster = identity?.players
              ?.map(
                (player) =>
                    player.copyWith(clubId: seedBase.id, listed: false),
              )
              .toList(growable: false) ??
          playerFactory.generateSquad(
            clubId: seedBase.id,
            clubReputation: seedBase.reputation,
            season: season,
          );
      final base = identity == null
          ? seedBase
          : ClubIdentityEngine.applyIdentityToClub(seedBase, identity);
      clubs.add(
        base.copyWith(
          managerName: base.id == userClubId
              ? careerManager.displayName
              : (previousManagerClubId != null &&
                      previousManagerClubId != userClubId &&
                      base.id == previousManagerClubId
                  ? 'Técnico interino'
                  : (managersByClub[base.id]?.displayName ?? base.managerName)),
          squad: roster,
        ),
      );
    }
    if (!clubs.any((club) => club.id == userClubId)) {
      throw ArgumentError('Clube não encontrado: $userClubId');
    }

    final primaryClubs = clubs
        .where((club) => primaryClubIds.contains(club.id))
        .toList(growable: false);
    if (!primaryClubs.any((club) => club.id == userClubId)) {
      throw ArgumentError(
        'A competição principal não contém o clube escolhido: $userClubId',
      );
    }

    final userClub = clubs.firstWhere((club) => club.id == userClubId);
    final starters = LineupEngine.autoSelect(userClub.squad, formation);
    final fixtures = LeagueEngine.generateDoubleRoundRobin(
      primaryClubs,
      season: season,
      competitionId: primarySeries.id,
    );
    final initialDate = CareerCalendarEngine.initialDateFor(
      fixtures: fixtures,
      userClubId: userClubId,
      season: season,
    );

    final importedManagers = normalizedPack?.managers;
    final sourceManagers = importedManagers != null
        ? importedManagers
            .where(
              (item) =>
                  item.currentClubId == null ||
                  activeClubIds.contains(item.currentClubId),
            )
            .toList(growable: false)
        : clubs
            .map(
              (club) => ManagerProfile(
                id: 'manager-${club.id}',
                displayName: club.managerName,
                nationality: 'Brasil',
                ageAtStart: 42,
                careerStartSeason: season,
                currentClubId: club.id,
                reputation: club.reputation.clamp(1, 100).toInt(),
                overall: club.reputation.clamp(1, 99).toInt(),
              ),
            )
            .toList(growable: false);
    final careerManagers = <ManagerProfile>[
      for (final item in sourceManagers)
        if (item.id != careerManager.id)
          item.currentClubId == userClubId
              ? item.copyWith(clearCurrentClub: true)
              : item,
      if (previousManagerClubId != null &&
          previousManagerClubId != userClubId &&
          activeClubIds.contains(previousManagerClubId) &&
          !sourceManagers.any(
            (item) =>
                item.id != careerManager.id &&
                item.currentClubId == previousManagerClubId,
          ))
        ManagerProfile(
          id: 'manager-interim-$previousManagerClubId-$careerId',
          displayName: 'Técnico interino',
          nationality: 'Brasil',
          ageAtStart: 45,
          careerStartSeason: season,
          currentClubId: previousManagerClubId,
          reputation: 45,
          overall: 55,
          style: 'Equilibrado',
        ),
      careerManager,
    ];

    final career = YouthAcademyEngine.ensureAcademy(
      CareerState(
        schemaVersion: CareerState.currentSchemaVersion,
        careerId: careerId,
        careerName: careerName,
        manager: careerManager,
        managerCareer: ManagerCareerState.initial(
          clubId: userClubId,
          season: season,
          startedAt: initialDate,
        ),
        managers: careerManagers,
        createdAt: DateTime.now(),
        season: season,
        roundIndex: 0,
        currentDate: initialDate,
        userClubId: userClubId,
        clubs: clubs,
        freeAgents: normalizedPack?.freeAgents
                ?.map(
                  (player) => player.copyWith(
                    clearClubId: true,
                    listed: true,
                    shirtNumber: 0,
                  ),
                )
                .toList(growable: false) ??
            playerFactory.generateFreeAgents(
              count: 28,
              season: season,
              baseOverall: 69,
            ),
        fixtures: fixtures,
        standings: LeagueEngine.initialStandings(primaryClubs),
        formation: formation,
        tactic: tactic,
        starterIds: starters,
        finances: const [],
        seasonHistory: const [],
        managerHistory: [
          ManagerCareerHistoryEntry.fromProfile(
            careerManager,
            season: season,
            clubId: userClubId,
          ),
        ],
        news: const [],
        matchHistory: const [],
        settings: settings,
        leagueSetup: effectiveLeagueSetup,
      ),
    );
    return ClubAdministrationEngine.ensureInitialized(career);
  }
}
