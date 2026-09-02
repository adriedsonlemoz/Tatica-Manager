import 'dart:math';

import '../../data/club_seed.dart';
import '../../domain/career/manager_profile.dart';
import '../../domain/club/club.dart';
import '../../domain/club/club_identity.dart';
import '../../domain/league/standing.dart';
import '../../domain/player/player.dart';
import '../../domain/player/player_attributes.dart';
import '../../domain/season/career_state.dart';
import '../lineup/lineup_engine.dart';
import '../career/manager_factory.dart';
import '../player/player_factory.dart';
import 'club_icon_validator.dart';
import 'club_identity_migration_engine.dart';

abstract final class ClubIdentityEngine {
  static const int _defaultPackSeed = 20260824;
  static const int maxIconBytes = ClubIconValidator.maxBytes;

  static const Map<String, String> legacyIdMap =
      ClubIdentityMigrationEngine.legacyIdMap;


  static List<String> get defaultClubIds =>
      clubSeeds.map((seed) => seed.id).toList(growable: false);

  static ClubIdentityPack _rawDefaultPack() {
    final playerFactory = PlayerFactory(random: Random(_defaultPackSeed));
    final clubs = <ClubIdentity>[];
    for (final seed in clubSeeds) {
      final club = seed.toClub();
      clubs.add(
        ClubIdentity(
          clubId: club.id,
          name: club.name,
          nickname: club.nickname,
          shortName: club.shortName,
          stadium: club.stadium,
          colors: club.colors,
          homeKit: club.homeKit,
          awayKit: club.awayKit,
          thirdKit: club.thirdKit,
          players: playerFactory.generateSquad(
            clubId: club.id,
            clubReputation: club.reputation,
            season: 2026,
          ),
        ),
      );
    }
    final managers = <ManagerProfile>[];
    for (var index = 0; index < clubs.length; index++) {
      final identity = clubs[index];
      final club =
          clubSeeds.firstWhere((seed) => seed.id == identity.clubId).toClub();
      managers.add(ManagerFactory.forClub(
        clubId: identity.clubId,
        clubReputation: club.reputation,
        season: 2026,
      ));
    }
    return ClubIdentityPack(
      name: 'Banco padrão do Tática Manager',
      clubs: clubs,
      managers: managers,
      freeAgents: playerFactory.generateFreeAgents(
        count: 28,
        season: 2026,
        baseOverall: 69,
      ),
    );
  }

  static ClubIdentityPack defaultPack() => _rawDefaultPack();

  static Club applyIdentityToClub(Club base, ClubIdentity identity) {
    final homeKit = identity.homeKit ?? base.homeKit;
    return base.copyWith(
      name: identity.name,
      nickname: identity.nickname,
      shortName: identity.shortName,
      stadium: identity.stadium ?? base.stadium,
      colors: ClubColors(
        primaryHex: homeKit.primaryHex,
        secondaryHex: homeKit.secondaryHex,
      ),
      iconBase64: identity.iconBase64,
      clearIcon: identity.iconBase64 == null || identity.iconBase64!.isEmpty,
      homeKit: homeKit,
      awayKit: identity.awayKit ?? base.awayKit,
      thirdKit: identity.thirdKit ?? base.thirdKit,
    );
  }

  static ClubIdentityPack packFromCareer(CareerState state) => ClubIdentityPack(
        name: 'Banco de ${state.careerName}',
        clubs: state.clubs
            .map(
              (club) => ClubIdentity(
                clubId: club.id,
                name: club.name,
                nickname: club.nickname,
                shortName: club.shortName,
                stadium: club.stadium,
                colors: club.colors,
                iconBase64: club.iconBase64,
                homeKit: club.homeKit,
                awayKit: club.awayKit,
                thirdKit: club.thirdKit,
                players: club.squad,
              ),
            )
            .toList(growable: false),
        freeAgents: state.freeAgents,
        managers: state.managers.isNotEmpty
            ? state.managers
            : [
                for (final club in state.clubs)
                  club.id == state.userClubId
                      ? state.manager.copyWith(currentClubId: club.id)
                      : ManagerFactory.forClub(
                          clubId: club.id,
                          clubReputation: club.reputation,
                          season: state.season,
                        ),
              ],
      );

  static ClubIdentityPack normalizeAndValidatePack(
    ClubIdentityPack pack, {
    Iterable<String>? expectedIds,
    ClubIdentityPack? fallbackPack,
  }) {
    final expected = (expectedIds ?? defaultClubIds).toList(growable: false);
    final expectedSet = expected.toSet();
    final defaults = fallbackPack ?? _rawDefaultPack();
    final fallbackById = {for (final item in defaults.clubs) item.clubId: item};
    final seenIds = <String>{};
    final seenNames = <String>{};
    final seenShortNames = <String>{};
    final seenPlayerIds = <String>{};
    final normalized = <ClubIdentity>[];

    if (pack.clubs.length != expected.length) {
      throw FormatException(
        'O pacote precisa conter exatamente ${expected.length} clubes.',
      );
    }

    for (final identity in pack.clubs) {
      final id = identity.clubId.trim();
      final fallback = fallbackById[id];
      if (!expectedSet.contains(id)) {
        throw FormatException('ID de clube desconhecido: $id.');
      }
      if (!seenIds.add(id)) {
        throw FormatException('ID de clube duplicado: $id.');
      }
      if (fallback == null) {
        throw FormatException('Não existe base segura para o clube $id.');
      }

      final name = _cleanText(identity.name);
      final nickname = _cleanText(identity.nickname);
      final shortName = identity.shortName.trim().toUpperCase();
      if (name.length < 3 || name.length > 42) {
        throw FormatException('O nome de $id deve ter entre 3 e 42 caracteres.');
      }
      if (nickname.length < 2 || nickname.length > 24) {
        throw FormatException('O apelido de $id deve ter entre 2 e 24 caracteres.');
      }
      if (!RegExp(r'^[A-Z0-9]{2,4}$').hasMatch(shortName)) {
        throw FormatException('A sigla de $id deve ter de 2 a 4 letras ou números.');
      }
      final nameKey = name.toLowerCase();
      if (!seenNames.add(nameKey)) {
        throw FormatException('Nome de clube duplicado: $name.');
      }
      if (!seenShortNames.add(shortName)) {
        throw FormatException('Sigla de clube duplicada: $shortName.');
      }

      final stadium = _normalizeStadium(identity.stadium ?? fallback.stadium!);
      final homeKit = _normalizeKit(identity.homeKit ?? fallback.homeKit!);
      final awayKit = _normalizeKit(identity.awayKit ?? fallback.awayKit!);
      final thirdKit = _normalizeKit(identity.thirdKit ?? fallback.thirdKit!);
      final colors = identity.colors ?? ClubColors(
        primaryHex: homeKit.primaryHex,
        secondaryHex: homeKit.secondaryHex,
      );
      _validateColor(colors.primaryHex, '$id/cor principal');
      _validateColor(colors.secondaryHex, '$id/cor secundária');
      final iconBase64 = identity.iconBase64 == null
          ? _normalizeIcon(fallback.iconBase64)
          : _normalizeIcon(identity.iconBase64);
      final rawPlayers = identity.players ?? fallback.players ?? const <Player>[];
      if (rawPlayers.length < 20 || rawPlayers.length > 30) {
        throw FormatException('$name precisa ter entre 20 e 30 jogadores.');
      }
      final players = <Player>[];
      for (final player in rawPlayers) {
        final normalizedPlayer = _normalizePlayer(player, clubId: id, freeAgent: false);
        if (!seenPlayerIds.add(normalizedPlayer.id)) {
          throw FormatException('ID de jogador duplicado: ${normalizedPlayer.id}.');
        }
        players.add(normalizedPlayer);
      }

      normalized.add(
        ClubIdentity(
          clubId: id,
          name: name,
          nickname: nickname,
          shortName: shortName,
          stadium: stadium,
          colors: ClubColors(
            primaryHex: homeKit.primaryHex,
            secondaryHex: homeKit.secondaryHex,
          ),
          iconBase64: iconBase64,
          homeKit: homeKit,
          awayKit: awayKit,
          thirdKit: thirdKit,
          players: players,
        ),
      );
    }

    final missing = expectedSet.difference(seenIds);
    if (missing.isNotEmpty) {
      throw const FormatException('O pacote não contém todos os clubes esperados.');
    }

    final fallbackFree = defaults.freeAgents ?? const <Player>[];
    final rawFreeAgents = pack.freeAgents ?? fallbackFree;
    if (rawFreeAgents.length > 150) {
      throw const FormatException('O banco pode ter no máximo 150 jogadores livres.');
    }
    final freeAgents = <Player>[];
    for (final player in rawFreeAgents) {
      final normalizedPlayer = _normalizePlayer(player, freeAgent: true);
      if (!seenPlayerIds.add(normalizedPlayer.id)) {
        throw FormatException('ID de jogador duplicado: ${normalizedPlayer.id}.');
      }
      freeAgents.add(normalizedPlayer);
    }

    normalized.sort(
      (a, b) => expected.indexOf(a.clubId).compareTo(expected.indexOf(b.clubId)),
    );
    final packName = _cleanText(pack.name);
    final author = pack.author == null ? null : _cleanText(pack.author!);
    if (packName.length > 60) {
      throw const FormatException('O nome do pacote pode ter no máximo 60 caracteres.');
    }
    if (author != null && author.length > 60) {
      throw const FormatException('O autor do pacote pode ter no máximo 60 caracteres.');
    }
    final rawManagers = pack.managers ?? defaults.managers ?? const <ManagerProfile>[];
    if (rawManagers.length > 200) {
      throw const FormatException('O banco pode ter no máximo 200 técnicos.');
    }
    final managerIds = <String>{};
    final managerClubIds = <String>{};
    final managers = <ManagerProfile>[];
    final replaceLegacyDefaultManagers =
        rawManagers.length == expected.length &&
            rawManagers.every(ManagerFactory.isLegacyPlaceholder);
    for (var index = 0; index < rawManagers.length; index++) {
      final manager = rawManagers[index];
      final id = manager.id.trim().isEmpty ? 'manager-imported-$index' : manager.id.trim();
      if (!managerIds.add(id)) {
        throw FormatException('ID de técnico duplicado: $id.');
      }
      if (manager.currentClubId != null && !expectedSet.contains(manager.currentClubId)) {
        throw FormatException('Clube desconhecido no técnico ${manager.displayName}.');
      }
      if (manager.currentClubId != null && !managerClubIds.add(manager.currentClubId!)) {
        throw FormatException('Há mais de um técnico associado ao clube ${manager.currentClubId}.');
      }
      if (replaceLegacyDefaultManagers && manager.currentClubId != null) {
        final seed = clubSeeds.firstWhere(
          (item) => item.id == manager.currentClubId,
        );
        managers.add(
          ManagerFactory.forClub(
            clubId: manager.currentClubId!,
            clubReputation: seed.reputation,
            season: manager.careerStartSeason,
          ).copyWith(id: id),
        );
      } else {
        managers.add(manager.copyWith(id: id));
      }
    }
    return ClubIdentityPack(
      name: packName.isEmpty ? 'Banco personalizado' : packName,
      author: author?.isEmpty == true ? null : author,
      clubs: normalized,
      freeAgents: freeAgents,
      managers: managers,
    );
  }

  static CareerState applyPack(CareerState state, ClubIdentityPack rawPack) {
    final currentPack = packFromCareer(state);
    final pack = normalizeAndValidatePack(
      rawPack,
      expectedIds: state.clubs.map((club) => club.id),
      fallbackPack: currentPack,
    );
    final currentPlayerIds = <String>{
      for (final club in state.clubs)
        for (final player in club.squad) player.id,
      for (final player in state.freeAgents) player.id,
    };
    final importedPlayerIds = <String>{
      for (final identity in pack.clubs)
        for (final player in identity.players ?? const <Player>[]) player.id,
      for (final player in pack.freeAgents ?? const <Player>[]) player.id,
    };
    if (currentPlayerIds.length != importedPlayerIds.length ||
        !currentPlayerIds.every(importedPlayerIds.contains)) {
      throw const FormatException(
        'Em uma carreira existente, o editor deve preservar os IDs dos jogadores. '
        'Mudanças na quantidade/IDs de atletas devem ser feitas no banco padrão antes de criar a carreira.',
      );
    }

    final identities = {for (final item in pack.clubs) item.clubId: item};
    ManagerProfile? importedUserManager;
    for (final manager in pack.managers ?? const <ManagerProfile>[]) {
      if (manager.id == state.manager.id ||
          manager.currentClubId == state.userClubId) {
        importedUserManager = manager;
        break;
      }
    }
    final nextUserManager = (importedUserManager ?? state.manager).copyWith(
      currentClubId: state.userClubId,
    );
    final managersByClub = {
      for (final manager in pack.managers ?? const <ManagerProfile>[])
        if (manager.currentClubId != null) manager.currentClubId!: manager,
    };
    final oldNames = {for (final club in state.clubs) club.id: club.name};
    final newNames = {for (final item in pack.clubs) item.clubId: item.name};
    final renameHistory = <String, String>{};
    for (final club in state.clubs) {
      final next = identities[club.id];
      if (next != null && club.name != next.name) {
        renameHistory[club.name] = next.name;
      }
    }

    final existingPlayers = <String, Player>{
      for (final club in state.clubs)
        for (final player in club.squad) player.id: player,
      for (final player in state.freeAgents) player.id: player,
    };

    final clubs = state.clubs.map((club) {
      final identity = identities[club.id];
      if (identity == null) return club;
      final roster = (identity.players ?? const <Player>[])
          .map((template) => _mergePlayerForCareer(
                template,
                existingPlayers[template.id],
                clubId: club.id,
                renameHistory: renameHistory,
              ))
          .toList(growable: false);
      final managerName = club.id == state.userClubId
          ? nextUserManager.displayName
          : (managersByClub[club.id]?.displayName ?? club.managerName);
      return applyIdentityToClub(club, identity).copyWith(
        squad: roster,
        managerName: managerName,
      );
    }).toList(growable: false);
    final namesById = {for (final club in clubs) club.id: club.name};

    final freeAgents = (pack.freeAgents ?? const <Player>[])
        .map((template) => _mergePlayerForCareer(
              template,
              existingPlayers[template.id],
              freeAgent: true,
              renameHistory: renameHistory,
            ))
        .toList(growable: false);

    final userClub = clubs.firstWhere((club) => club.id == state.userClubId);
    final currentStarterSet = state.starterIds.toSet();
    final userIds = userClub.squad.map((player) => player.id).toSet();
    final startersStillValid = currentStarterSet.length == 11 && currentStarterSet.every(userIds.contains);
    final starterIds = startersStillValid
        ? state.starterIds
        : LineupEngine.autoSelect(userClub.squad, state.formation);

    final importedManagers = <ManagerProfile>[
      for (final manager in pack.managers ?? const <ManagerProfile>[])
        if (manager.currentClubId != state.userClubId &&
            manager.id != nextUserManager.id)
          manager,
      nextUserManager,
    ];

    return state.copyWith(
      manager: nextUserManager,
      clubs: clubs,
      freeAgents: freeAgents,
      managers: importedManagers,
      starterIds: starterIds,
      standings: state.standings
          .map(
            (standing) => Standing(
              clubId: standing.clubId,
              clubName: namesById[standing.clubId] ?? standing.clubName,
              played: standing.played,
              wins: standing.wins,
              draws: standing.draws,
              losses: standing.losses,
              goalsFor: standing.goalsFor,
              goalsAgainst: standing.goalsAgainst,
              points: standing.points,
            ),
          )
          .toList(growable: false),
      competitionStates: state.competitionStates
          .map(
            (competition) => competition.copyWith(
              standings: competition.standings
                  .map(
                    (standing) => _renameStanding(
                      standing,
                      namesById: namesById,
                    ),
                  )
                  .toList(growable: false),
              stages: competition.stages
                  .map(
                    (stage) => stage.copyWith(
                      standingsByGroup: {
                        for (final entry in stage.standingsByGroup.entries)
                          entry.key: entry.value
                              .map(
                                (standing) => _renameStanding(
                                  standing,
                                  namesById: namesById,
                                ),
                              )
                              .toList(growable: false),
                      },
                    ),
                  )
                  .toList(growable: false),
            ),
          )
          .toList(growable: false),
      finances: state.finances
          .map(
            (transaction) => ClubIdentityMigrationEngine.renameFinanceTransaction(
              transaction,
              oldNamesById: oldNames,
              newNamesById: newNames,
            ),
          )
          .toList(growable: false),
      news: state.news
          .map(
            (event) => ClubIdentityMigrationEngine.renameEvent(
              event,
              oldNamesById: oldNames,
              newNamesById: newNames,
            ),
          )
          .toList(growable: false),
      matchHistory: state.matchHistory
          .map(
            (result) => ClubIdentityMigrationEngine.renameMatchResult(
              result,
              oldNamesById: oldNames,
              newNamesById: newNames,
            ),
          )
          .toList(growable: false),
      lastMatch: state.lastMatch == null
          ? null
          : ClubIdentityMigrationEngine.renameMatchResult(
              state.lastMatch!,
              oldNamesById: oldNames,
              newNamesById: newNames,
            ),
    );
  }

  static Stadium _normalizeStadium(Stadium stadium) {
    final name = _cleanText(stadium.name);
    if (name.length < 3 || name.length > 50) {
      throw const FormatException('O nome do estádio deve ter entre 3 e 50 caracteres.');
    }
    if (stadium.capacity < 1000 || stadium.capacity > 200000) {
      throw const FormatException('A capacidade do estádio deve ficar entre 1.000 e 200.000.');
    }
    if (stadium.ticketPrice < 0 || stadium.ticketPrice > 5000) {
      throw const FormatException('O preço do ingresso deve ficar entre 0 e 5.000.');
    }
    return stadium.copyWith(name: name);
  }

  static ClubKit _normalizeKit(ClubKit kit) {
    _validateColor(kit.primaryHex, 'uniforme/cor principal');
    _validateColor(kit.secondaryHex, 'uniforme/cor secundária');
    _validateColor(kit.accentHex, 'uniforme/cor de detalhe');
    _validateColor(kit.shortsHex, 'uniforme/calção');
    _validateColor(kit.socksHex, 'uniforme/meiões');
    return kit;
  }

  static void _validateColor(int value, String field) {
    if (value < 0 || value > 0xFFFFFFFF || (value & 0xFF000000) != 0xFF000000) {
      throw FormatException('Cor inválida em $field. Use uma cor opaca no formato ARGB 0xFFRRGGBB.');
    }
  }

  static String? _normalizeIcon(String? value) =>
      ClubIconValidator.normalizeBase64(value);

  static Standing _renameStanding(
    Standing standing, {
    required Map<String, String> namesById,
  }) =>
      Standing(
        clubId: standing.clubId,
        clubName: namesById[standing.clubId] ?? standing.clubName,
        played: standing.played,
        wins: standing.wins,
        draws: standing.draws,
        losses: standing.losses,
        goalsFor: standing.goalsFor,
        goalsAgainst: standing.goalsAgainst,
        points: standing.points,
      );

  static Player _normalizePlayer(
    Player player, {
    String? clubId,
    bool freeAgent = false,
  }) {
    final id = player.id.trim();
    final firstName = _cleanText(player.firstName);
    final lastName = _cleanText(player.lastName);
    final displayName = _cleanText(player.displayName);
    final nationality = _cleanText(player.nationality);
    if (id.length < 4 || id.length > 100) {
      throw const FormatException('O ID interno de jogador é inválido.');
    }
    if ((firstName.isEmpty && lastName.isEmpty) || firstName.length > 30 || lastName.length > 40) {
      throw FormatException('Nome inválido no jogador $id.');
    }
    if (displayName.isEmpty || displayName.length > 50) {
      throw FormatException('Nome de exibição inválido no jogador $id.');
    }
    if (nationality.isEmpty || nationality.length > 40) {
      throw FormatException('Nacionalidade inválida no jogador $id.');
    }
    if (player.age < 15 || player.age > 50) {
      throw FormatException('Idade inválida em $displayName.');
    }
    if (player.heightCm < 140 || player.heightCm > 220 || player.weightKg < 45 || player.weightKg > 150) {
      throw FormatException('Altura/peso inválidos em $displayName.');
    }
    if (!freeAgent && (player.shirtNumber < 1 || player.shirtNumber > 99)) {
      throw FormatException('O número da camisa de $displayName deve ficar entre 1 e 99.');
    }
    if (player.overall < 1 || player.overall > 99 || player.potential < player.overall || player.potential > 99) {
      throw FormatException('Overall/potencial inválidos em $displayName.');
    }
    if (player.marketValue < 0 || player.marketValue > 2000000000) {
      throw FormatException('Valor de mercado inválido em $displayName.');
    }
    if (player.contract.salary < 0 || player.contract.salary > 100000000) {
      throw FormatException('Salário inválido em $displayName.');
    }
    if (player.contract.endSeason < 1900 || player.contract.endSeason > 2200) {
      throw FormatException('Fim de contrato inválido em $displayName.');
    }
    _validateAttributes(player.technical.toJson(), displayName);
    _validateAttributes(player.physical.toJson(), displayName);
    _validateAttributes(player.mental.toJson(), displayName);
    _validateAttributes(player.goalkeeper.toJson(), displayName);
    _validateVisual(player.visual, displayName);
    if (player.birthDate.year < 1900 || player.birthDate.year > 2200) {
      throw FormatException('Data de nascimento inválida em $displayName.');
    }

    final normalized = player.copyWith(
      firstName: firstName,
      lastName: lastName,
      displayName: displayName,
      nationality: nationality,
      shirtNumber: freeAgent ? 0 : player.shirtNumber,
      clubId: clubId,
      clearClubId: freeAgent,
      listed: freeAgent ? true : false,
    );
    return normalized;
  }

  static void _validateAttributes(Map<String, dynamic> values, String playerName) {
    for (final entry in values.entries) {
      final value = entry.value;
      if (value is! int || value < 1 || value > 99) {
        throw FormatException('Atributo ${entry.key} inválido em $playerName.');
      }
    }
  }

  static void _validateVisual(VisualProfile visual, String playerName) {
    if (visual.skinTone < 0 || visual.skinTone > 5 ||
        visual.hairStyle < 0 || visual.hairStyle > 7 ||
        visual.hairColor < 0 || visual.hairColor > 4 ||
        visual.bodyType < 0 || visual.bodyType > 3 ||
        visual.bootStyle < 0 || visual.bootStyle > 5 ||
        visual.visualHeight < .5 || visual.visualHeight > 1.5) {
      throw FormatException('Perfil visual inválido em $playerName.');
    }
  }

  static Player _mergePlayerForCareer(
    Player template,
    Player? current, {
    String? clubId,
    bool freeAgent = false,
    required Map<String, String> renameHistory,
  }) {
    if (current == null) {
      final player = freeAgent
          ? template.copyWith(clearClubId: true, listed: true, shirtNumber: 0)
          : template.copyWith(clubId: clubId, listed: false);
      return ClubIdentityMigrationEngine.renamePlayerHistory(player, renameHistory);
    }
    final merged = current.copyWith(
      firstName: template.firstName,
      lastName: template.lastName,
      displayName: template.displayName,
      birthDate: template.birthDate,
      age: template.age,
      nationality: template.nationality,
      primaryPosition: template.primaryPosition,
      secondaryPositions: template.secondaryPositions,
      preferredFoot: template.preferredFoot,
      heightCm: template.heightCm,
      weightKg: template.weightKg,
      shirtNumber: freeAgent ? 0 : template.shirtNumber,
      overall: template.overall,
      potential: template.potential,
      technical: template.technical,
      physical: template.physical,
      mental: template.mental,
      goalkeeper: template.goalkeeper,
      marketValue: template.marketValue,
      contract: template.contract,
      clubId: clubId,
      clearClubId: freeAgent,
      listed: freeAgent ? true : false,
      visual: template.visual,
    );
    return ClubIdentityMigrationEngine.renamePlayerHistory(merged, renameHistory);
  }

  static ClubIdentityMigrationResult migrateLegacyIds(CareerState state) =>
      ClubIdentityMigrationEngine.migrateLegacyIds(state);

  static String _cleanText(String value) =>
      value.trim().replaceAll(RegExp(r'\s+'), ' ');
}
