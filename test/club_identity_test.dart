import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/data/club_seed.dart';
import 'package:tatica_manager/domain/career/manager_profile.dart';
import 'package:tatica_manager/domain/club/club.dart';
import 'package:tatica_manager/domain/club/club_identity.dart';
import 'package:tatica_manager/domain/finance/finance.dart';
import 'package:tatica_manager/domain/league/standing.dart';
import 'package:tatica_manager/domain/match/match_models.dart';
import 'package:tatica_manager/domain/player/player.dart';
import 'package:tatica_manager/domain/player/player_attributes.dart';
import 'package:tatica_manager/domain/player/player_data_pack.dart';
import 'package:tatica_manager/domain/season/career_event.dart';
import 'package:tatica_manager/domain/season/career_state.dart';
import 'package:tatica_manager/game/career/career_factory.dart';
import 'package:tatica_manager/game/club/club_icon_validator.dart';
import 'package:tatica_manager/game/club/club_identity_engine.dart';
import 'package:tatica_manager/game/match/engine/match_engine.dart';

void main() {
  test('clubes padrão usam IDs neutros permanentes e únicos', () {
    expect(clubSeeds, hasLength(20));
    expect(
      clubSeeds.map((club) => club.id).toSet(),
      hasLength(clubSeeds.length),
    );
    for (var index = 0; index < clubSeeds.length; index++) {
      expect(
        clubSeeds[index].id,
        'br-club-${(index + 1).toString().padLeft(3, '0')}',
      );
    }
    expect(
      clubSeeds.any((club) => ClubIdentityEngine.legacyIdMap.containsKey(club.id)),
      isFalse,
    );
  });

  test('save anterior sem apelido continua compatível', () {
    final json = clubSeeds.first.toClub().toJson()..remove('nickname');

    final restored = Club.fromJson(json);

    expect(restored.nickname, restored.name);
    expect(restored.id, clubSeeds.first.id);
  });

  test('pacote comunitário faz round-trip e normaliza identidade', () {
    final base = ClubIdentityEngine.defaultPack();
    final custom = ClubIdentityPack(
      name: '  Comunidade   Tática  ',
      author: '  Editor Teste  ',
      clubs: [
        base.clubs.first.copyWith(
          name: '  Clube   Comunitário  ',
          nickname: '  Comunidade  ',
          shortName: 'cm1',
        ),
        ...base.clubs.skip(1),
      ],
    );

    final decoded = ClubIdentityPack.decode(custom.encode());
    final normalized = ClubIdentityEngine.normalizeAndValidatePack(decoded);

    expect(normalized.name, 'Comunidade Tática');
    expect(normalized.author, 'Editor Teste');
    expect(normalized.clubs.first.clubId, clubSeeds.first.id);
    expect(normalized.clubs.first.name, 'Clube Comunitário');
    expect(normalized.clubs.first.nickname, 'Comunidade');
    expect(normalized.clubs.first.shortName, 'CM1');
  });

  test('pacote comunitário não pode injetar, remover ou duplicar clube', () {
    final base = ClubIdentityEngine.defaultPack();
    final unknown = ClubIdentityPack(
      clubs: [
        base.clubs.first.copyWith(clubId: 'br-club-999'),
        ...base.clubs.skip(1),
      ],
    );
    final missing = ClubIdentityPack(clubs: base.clubs.take(19).toList());
    final duplicate = ClubIdentityPack(
      clubs: [
        base.clubs.first,
        base.clubs.first.copyWith(name: 'Outro Clube', shortName: 'OTR'),
        ...base.clubs.skip(2),
      ],
    );

    expect(
      () => ClubIdentityEngine.normalizeAndValidatePack(unknown),
      throwsFormatException,
    );
    expect(
      () => ClubIdentityEngine.normalizeAndValidatePack(missing),
      throwsFormatException,
    );
    expect(
      () => ClubIdentityEngine.normalizeAndValidatePack(duplicate),
      throwsFormatException,
    );
  });

  test('pacote comunitário rejeita tipos inválidos e versão fracionária', () {
    final base = ClubIdentityEngine.defaultPack().toJson();
    final invalidType = Map<String, dynamic>.from(base);
    final invalidClubs = (base['clubs'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
    invalidClubs.first['name'] = 123;
    invalidType['clubs'] = invalidClubs;

    final fractionalVersion = Map<String, dynamic>.from(base)
      ..['version'] = 1.5;

    expect(
      () => ClubIdentityPack.fromJson(invalidType),
      throwsFormatException,
    );
    expect(
      () => ClubIdentityPack.fromJson(fractionalVersion),
      throwsFormatException,
    );
  });

  test('aplicar identidade preserva dados esportivos, financeiros e IDs', () {
    final baseCareer = _career('identity-apply');
    final firstClub = baseCareer.clubs.first;
    final original = baseCareer.copyWith(
      finances: [
        FinanceTransaction(
          id: 'sale-to-first-club',
          season: baseCareer.season,
          round: 1,
          kind: FinanceKind.playerSale,
          description: 'Venda de Jogador Teste para ${firstClub.name}',
          amount: 1000000,
          createdAt: baseCareer.currentDate,
        ),
      ],
    );
    final firstPlayerId = firstClub.squad.first.id;
    final pack = ClubIdentityPack(
      name: 'Minha liga',
      clubs: [
        ClubIdentity(
          clubId: firstClub.id,
          name: 'Atlético Horizonte',
          nickname: 'Horizonte',
          shortName: 'AHZ',
        ),
        ...ClubIdentityEngine.packFromCareer(original).clubs.skip(1),
      ],
    );

    final updated = ClubIdentityEngine.applyPack(original, pack);
    final renamed = updated.clubs.first;

    expect(renamed.id, firstClub.id);
    expect(renamed.name, 'Atlético Horizonte');
    expect(renamed.nickname, 'Horizonte');
    expect(renamed.shortName, 'AHZ');
    expect(renamed.money, firstClub.money);
    expect(renamed.transferBudget, firstClub.transferBudget);
    expect(renamed.reputation, firstClub.reputation);
    expect(renamed.squad.first.id, firstPlayerId);
    expect(updated.fixtures.first.id, original.fixtures.first.id);
    expect(updated.standings.first.clubName, 'Atlético Horizonte');
    expect(
      updated.finances.single.description,
      'Venda de Jogador Teste para Atlético Horizonte',
    );
  });

  test('renomear clube não altera sobrenome igual ao nome antigo fora de contexto', () {
    final original = _career('identity-safe-text');
    final base = ClubIdentityEngine.packFromCareer(original);
    final withShortName = ClubIdentityEngine.applyPack(
      original,
      ClubIdentityPack(
        clubs: [
          base.clubs.first.copyWith(
            name: 'Santos',
            nickname: 'Santos',
            shortName: 'STS',
          ),
          ...base.clubs.skip(1),
        ],
      ),
    );
    final fixture = withShortName.fixtures.first;
    final home = withShortName.clubs.firstWhere((club) => club.id == fixture.homeClubId);
    final away = withShortName.clubs.firstWhere((club) => club.id == fixture.awayClubId);
    final sample = MatchEngine.simulate(
      fixture: fixture,
      home: home,
      away: away,
      seed: 77,
    );
    final historic = MatchResult(
      fixtureId: fixture.id,
      homeClubId: home.id,
      awayClubId: away.id,
      score: sample.score,
      statistics: sample.statistics,
      seed: sample.seed,
      events: [
        MatchEvent(
          minute: 10,
          sequence: 1,
          type: MatchEventType.shot,
          teamId: home.id,
          text: 'João Santos finaliza!',
        ),
        MatchEvent(
          minute: 11,
          sequence: 2,
          type: MatchEventType.possession,
          teamId: home.id,
          text: 'Santos trabalha a posse no campo adversário.',
        ),
      ],
    );
    final stateWithHistory = withShortName.copyWith(
      matchHistory: [historic],
      lastMatch: historic,
    );
    final currentPack = ClubIdentityEngine.packFromCareer(stateWithHistory);
    final renamed = ClubIdentityEngine.applyPack(
      stateWithHistory,
      ClubIdentityPack(
        clubs: [
          currentPack.clubs.first.copyWith(
            name: 'Atlético Horizonte',
            nickname: 'Horizonte',
            shortName: 'AHZ',
          ),
          ...currentPack.clubs.skip(1),
        ],
      ),
    );

    expect(renamed.matchHistory.single.events.first.text, 'João Santos finaliza!');
    expect(
      renamed.matchHistory.single.events.last.text,
      'Atlético Horizonte trabalha a posse no campo adversário.',
    );
  });

  test('nova carreira usa pacote padrão personalizado sem mudar IDs', () {
    final base = ClubIdentityEngine.defaultPack();
    final pack = ClubIdentityPack(
      name: 'Pacote teste',
      clubs: [
        base.clubs.first.copyWith(
          name: 'Esporte Horizonte FC',
          nickname: 'Horizonte',
          shortName: 'EHF',
        ),
        ...base.clubs.skip(1),
      ],
    );

    final career = CareerFactory.create(
      careerId: 'custom-default-pack',
      careerName: 'Personalizada',
      manager: const ManagerProfile(displayName: 'Técnico Teste'),
      userClubId: clubSeeds.first.id,
      clubIdentityPack: pack,
      seed: 20260824,
    );

    expect(career.userClub.id, 'br-club-001');
    expect(career.userClub.name, 'Esporte Horizonte FC');
    expect(career.userClub.nickname, 'Horizonte');
    expect(career.userClub.shortName, 'EHF');
    expect(career.userClub.squad.every((player) => player.clubId == 'br-club-001'), isTrue);
  });

  test('migração de save 0.1.1.12 troca IDs uma vez e preserva jogador', () {
    final legacy = _legacyCareer();
    final playerIdBefore = legacy.userClub.squad.first.id;
    final legacyUserId = legacy.userClubId;
    final legacyUserName = legacy.userClub.name;

    final first = ClubIdentityEngine.migrateLegacyIds(legacy);
    final migrated = first.state;
    final second = ClubIdentityEngine.migrateLegacyIds(migrated);

    expect(first.changed, isTrue);
    expect(second.changed, isFalse);
    expect(ClubIdentityEngine.legacyIdMap[legacyUserId], migrated.userClubId);
    expect(migrated.userClub.id, 'br-club-001');
    expect(migrated.userClub.name, clubSeeds.first.name);
    expect(migrated.userClub.stadium.name, clubSeeds.first.stadium);
    expect(migrated.userClub.squad.first.id, playerIdBefore);
    expect(migrated.userClub.squad.first.clubId, migrated.userClubId);
    expect(migrated.userClub.squad.first.history.single.clubName, clubSeeds.first.name);
    expect(
      migrated.clubs.expand((club) => club.squad).any(
            (player) => player.clubId != null &&
                ClubIdentityEngine.legacyIdMap.containsKey(player.clubId),
          ),
      isFalse,
    );
    expect(
      migrated.fixtures.any(
        (fixture) =>
            ClubIdentityEngine.legacyIdMap.containsKey(fixture.homeClubId) ||
            ClubIdentityEngine.legacyIdMap.containsKey(fixture.awayClubId),
      ),
      isFalse,
    );
    expect(
      migrated.standings.any(
        (standing) => ClubIdentityEngine.legacyIdMap.containsKey(standing.clubId),
      ),
      isFalse,
    );
    expect(migrated.seasonHistory.single.clubId, migrated.userClubId);
    expect(migrated.managerHistory.single.clubId, migrated.userClubId);
    expect(migrated.news.single.clubId, migrated.userClubId);
    expect(migrated.news.single.message, isNot(contains(legacyUserName)));
    expect(
      migrated.matchHistory.single.events.any(
        (event) => event.text.contains(legacyUserName),
      ),
      isFalse,
    );
  });

  test('save/load preserva apelido e identidade editada', () {
    final original = _career('identity-save-load');
    final base = ClubIdentityEngine.packFromCareer(original);
    final edited = ClubIdentityEngine.applyPack(
      original,
      ClubIdentityPack(
        clubs: [
          base.clubs.first.copyWith(
            name: 'União Horizonte FC',
            nickname: 'Horizonte',
            shortName: 'UHF',
          ),
          ...base.clubs.skip(1),
        ],
      ),
    );

    final restored = CareerState.fromJson(edited.toJson());

    expect(restored.userClub.id, original.userClub.id);
    expect(restored.userClub.name, 'União Horizonte FC');
    expect(restored.userClub.nickname, 'Horizonte');
    expect(restored.userClub.shortName, 'UHF');
  });

  test('banco padrão inclui estádio, uniformes e jogadores editáveis com IDs estáveis', () {
    final first = ClubIdentityEngine.defaultPack().clubs.first;

    expect(first.stadium, isNotNull);
    expect(first.homeKit, isNotNull);
    expect(first.awayKit, isNotNull);
    expect(first.thirdKit, isNotNull);
    expect(first.players, hasLength(24));
    expect(first.players!.map((player) => player.id).toSet(), hasLength(24));
    expect(first.players!.map((player) => player.shirtNumber).toSet(), hasLength(24));
    expect(first.players!.every((player) => player.clubId == first.clubId), isTrue);
  });

  test('pacote mínimo preserva ícone existente por fallback e permite remoção explícita', () {
    final base = ClubIdentityEngine.defaultPack();
    final icon = _validPngBase64();
    final withIcon = ClubIdentityPack(
      clubs: [base.clubs.first.copyWith(iconBase64: icon), ...base.clubs.skip(1)],
      freeAgents: base.freeAgents,
    );
    final minimal = ClubIdentityPack(
      clubs: [
        ClubIdentity(
          clubId: base.clubs.first.clubId,
          name: 'Clube Renomeado',
          nickname: 'Renomeado',
          shortName: 'CRN',
        ),
        ...base.clubs.skip(1),
      ],
    );

    final preserved = ClubIdentityEngine.normalizeAndValidatePack(minimal, fallbackPack: withIcon);
    expect(preserved.clubs.first.iconBase64, icon);

    final removed = ClubIdentityEngine.normalizeAndValidatePack(
      ClubIdentityPack(
        clubs: [withIcon.clubs.first.copyWith(clearIcon: true), ...withIcon.clubs.skip(1)],
        freeAgents: withIcon.freeAgents,
      ),
      fallbackPack: withIcon,
    );
    expect(removed.clubs.first.iconBase64, isNull);

    final explicitClear = ClubIdentityPack(
      clubs: [withIcon.clubs.first.copyWith(clearIcon: true), ...withIcon.clubs.skip(1)],
      freeAgents: withIcon.freeAgents,
    );
    final decodedClear = ClubIdentityPack.decode(explicitClear.encode());
    expect(decodedClear.clubs.first.iconBase64, '');
    final removedAfterRoundTrip = ClubIdentityEngine.normalizeAndValidatePack(
      decodedClear,
      fallbackPack: withIcon,
    );
    expect(removedAfterRoundTrip.clubs.first.iconBase64, isNull);
  });

  test('pacote separado de jogadores faz round-trip para importação de elenco', () {
    final players = ClubIdentityEngine.defaultPack().clubs.first.players!;
    final pack = PlayerDataPack(
      name: 'Elenco da comunidade',
      author: 'Teste',
      players: players,
    );

    final decoded = PlayerDataPack.decode(pack.encode());

    expect(decoded.name, 'Elenco da comunidade');
    expect(decoded.author, 'Teste');
    expect(decoded.players, hasLength(players.length));
    expect(decoded.players.first.id, players.first.id);
    expect(decoded.players.first.shirtNumber, players.first.shirtNumber);
  });

  test('pacote v2 preserva estádio, uniformes, ícone e dados de jogador', () {
    final base = ClubIdentityEngine.defaultPack();
    final first = base.clubs.first;
    final player = first.players!.first;
    final icon = _validPngBase64();
    final editedPlayer = player.copyWith(
      firstName: 'Jogador',
      lastName: 'Teste',
      displayName: 'Jogador Teste',
      shirtNumber: 77,
      overall: 91,
      potential: 94,
    );
    final pack = ClubIdentityPack(
      name: 'Banco completo',
      clubs: [
        first.copyWith(
          stadium: first.stadium!.copyWith(name: 'Arena Teste', capacity: 43210),
          iconBase64: icon,
          homeKit: first.homeKit!.copyWith(pattern: ClubKitPattern.verticalStripes),
          players: [editedPlayer, ...first.players!.skip(1)],
        ),
        ...base.clubs.skip(1),
      ],
      freeAgents: base.freeAgents,
    );

    final decoded = ClubIdentityPack.decode(pack.encode());
    final normalized = ClubIdentityEngine.normalizeAndValidatePack(decoded);
    final club = normalized.clubs.first;

    expect(club.stadium!.name, 'Arena Teste');
    expect(club.stadium!.capacity, 43210);
    expect(club.iconBase64, icon);
    expect(club.homeKit!.pattern, ClubKitPattern.verticalStripes);
    expect(club.players!.first.displayName, 'Jogador Teste');
    expect(club.players!.first.shirtNumber, 77);
    expect(club.players!.first.overall, 91);
  });

  test('editar jogador em carreira preserva estado transitório e altera dados-base', () {
    final original = _career('editor-player-runtime');
    final club = original.userClub;
    final current = club.squad.first.copyWith(
      fatigue: 55,
      condition: 61,
      morale: 44,
      injury: const PlayerInjury(name: 'Contusão', roundsRemaining: 2),
      stats: const PlayerSeasonStats(appearances: 8, goals: 3),
    );
    final state = original.copyWith(
      clubs: original.clubs
          .map((item) => item.id == club.id
              ? item.copyWith(
                  squad: item.squad
                      .map((player) => player.id == current.id ? current : player)
                      .toList(),
                )
              : item)
          .toList(),
    );
    final pack = ClubIdentityEngine.packFromCareer(state);
    final first = pack.clubs.first;
    final template = first.players!.first.copyWith(
      displayName: 'Craque Editado',
      shirtNumber: 88,
      overall: 90,
      potential: 95,
    );
    final updated = ClubIdentityEngine.applyPack(
      state,
      ClubIdentityPack(
        clubs: [
          first.copyWith(players: [template, ...first.players!.skip(1)]),
          ...pack.clubs.skip(1),
        ],
        freeAgents: pack.freeAgents,
      ),
    );
    final player = updated.userClub.squad.firstWhere((item) => item.id == current.id);

    expect(player.displayName, 'Craque Editado');
    expect(player.shirtNumber, 88);
    expect(player.overall, 90);
    expect(player.fatigue, 55);
    expect(player.condition, 61);
    expect(player.morale, 44);
    expect(player.injury?.roundsRemaining, 2);
    expect(player.stats.appearances, 8);
    expect(player.stats.goals, 3);
  });

  test('carreira existente rejeita banco que troca ID de jogador', () {
    final original = _career('editor-player-id-guard');
    final pack = ClubIdentityEngine.packFromCareer(original);
    final first = pack.clubs.first;
    final replacement = first.players!.first.copyWith(id: 'novo-id-invalido');
    final changed = ClubIdentityPack(
      clubs: [
        first.copyWith(players: [replacement, ...first.players!.skip(1)]),
        ...pack.clubs.skip(1),
      ],
      freeAgents: pack.freeAgents,
    );

    expect(() => ClubIdentityEngine.applyPack(original, changed), throwsFormatException);
  });

  test('pacote rejeita perfil visual fora da faixa usada pelo jogo', () {
    final base = ClubIdentityEngine.defaultPack();
    final first = base.clubs.first;
    final invalid = first.players!.first.copyWith(
      visual: VisualProfile(
        skinTone: 6,
        hairStyle: 0,
        hairColor: 0,
        bodyType: 0,
        visualHeight: 1,
        bootStyle: 0,
      ),
    );
    final pack = ClubIdentityPack(
      clubs: [
        first.copyWith(players: [invalid, ...first.players!.skip(1)]),
        ...base.clubs.skip(1),
      ],
      freeAgents: base.freeAgents,
    );

    expect(() => ClubIdentityEngine.normalizeAndValidatePack(pack), throwsFormatException);
  });

  test('save-load preserva número, estádio, kits e ícone do clube', () {
    final original = _career('editor-serialization-v2');
    final pack = ClubIdentityEngine.packFromCareer(original);
    final first = pack.clubs.first;
    final icon = _validPngBase64();
    final edited = ClubIdentityEngine.applyPack(
      original,
      ClubIdentityPack(
        clubs: [
          first.copyWith(
            iconBase64: icon,
            stadium: first.stadium!.copyWith(name: 'Arena Persistida'),
            homeKit: first.homeKit!.copyWith(pattern: ClubKitPattern.sash),
            players: [
              first.players!.first.copyWith(shirtNumber: 66),
              ...first.players!.skip(1),
            ],
          ),
          ...pack.clubs.skip(1),
        ],
        freeAgents: pack.freeAgents,
      ),
    );

    final restored = CareerState.fromJson(edited.toJson());

    expect(restored.userClub.iconBase64, icon);
    expect(restored.userClub.stadium.name, 'Arena Persistida');
    expect(restored.userClub.homeKit.pattern, ClubKitPattern.sash);
    expect(restored.userClub.squad.first.shirtNumber, 66);
  });

  test('validador de escudo aceita imagem dentro das regras visuais', () {
    final bytes = base64Decode(_validPngBase64(width: 256, height: 256));
    final dimensions = ClubIconValidator.validateBytes(bytes);

    expect(dimensions.width, 256);
    expect(dimensions.height, 256);
  });

  test('validador de escudo rejeita dimensões excessivas e proporção extrema', () {
    expect(
      () => ClubIconValidator.validateBytes(
        base64Decode(_validPngBase64(width: 2048, height: 2048)),
      ),
      throwsFormatException,
    );
    expect(
      () => ClubIconValidator.validateBytes(
        base64Decode(_validPngBase64(width: 512, height: 64)),
      ),
      throwsFormatException,
    );
  });

}

CareerState _career(String id) => CareerFactory.create(
      careerId: id,
      careerName: 'Identidades',
      manager: const ManagerProfile(displayName: 'Técnico Teste'),
      userClubId: clubSeeds.first.id,
      seed: 20260824,
    );

CareerState _legacyCareer() {
  final current = _career('legacy-club-identities');
  final inverseIds = {
    for (final entry in ClubIdentityEngine.legacyIdMap.entries) entry.value: entry.key,
  };
  final legacyNames = <String, String>{};
  for (var index = 0; index < current.clubs.length; index++) {
    legacyNames[current.clubs[index].id] = 'Clube Legado ${(index + 1).toString().padLeft(2, '0')}';
  }

  final clubs = current.clubs.map((club) {
    final legacyId = inverseIds[club.id]!;
    final legacyName = legacyNames[club.id]!;
    final squad = club.squad.map((player) {
      final history = club.id == current.userClubId && player.id == club.squad.first.id
          ? [
              PlayerHistoryEntry(
                season: current.season - 1,
                clubName: legacyName,
                overall: player.overall,
              ),
            ]
          : player.history;
      return player.copyWith(clubId: legacyId, history: history);
    }).toList(growable: false);
    return club.copyWith(
      id: legacyId,
      name: legacyName,
      nickname: 'Legado',
      stadium: club.stadium.copyWith(name: 'Estádio Legado ${club.shortName}'),
      squad: squad,
    );
  }).toList(growable: false);
  final clubsById = {for (final club in clubs) club.id: club};

  MatchFixture migrateFixture(MatchFixture fixture) => MatchFixture(
        id: fixture.id,
        round: fixture.round,
        homeClubId: inverseIds[fixture.homeClubId]!,
        awayClubId: inverseIds[fixture.awayClubId]!,
        date: fixture.date,
        played: fixture.played,
        score: fixture.score,
      );

  final fixtures = current.fixtures.map(migrateFixture).toList(growable: false);
  final sampleFixture = fixtures.first;
  final sampleResult = MatchEngine.simulate(
    fixture: sampleFixture,
    home: clubsById[sampleFixture.homeClubId]!,
    away: clubsById[sampleFixture.awayClubId]!,
    seed: 12345,
  );
  final legacyUserId = inverseIds[current.userClubId]!;
  final legacyUserName = legacyNames[current.userClubId]!;

  return current.copyWith(
    userClubId: legacyUserId,
    clubs: clubs,
    fixtures: fixtures,
    standings: current.standings
        .map(
          (standing) => Standing(
            clubId: inverseIds[standing.clubId]!,
            clubName: legacyNames[standing.clubId]!,
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
    seasonHistory: [
      SeasonSummary(
        season: current.season - 1,
        clubId: legacyUserId,
        position: 5,
        points: 60,
        wins: 17,
        draws: 9,
        losses: 12,
      ),
    ],
    managerHistory: [
      ManagerCareerHistoryEntry.fromProfile(
        current.manager,
        season: current.season,
        clubId: legacyUserId,
      ),
    ],
    news: [
      CareerEvent(
        id: 'legacy-club-news',
        date: current.currentDate,
        type: CareerEventType.info,
        title: 'Notícia do $legacyUserName',
        message: '$legacyUserName sinalizou uma proposta por Jogador Teste.',
        clubId: legacyUserId,
      ),
    ],
    matchHistory: [sampleResult],
    lastMatch: sampleResult,
  );
}

String _validPngBase64({int width = 128, int height = 128}) {
  final bytes = List<int>.filled(32, 0);
  const signature = <int>[0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
  bytes.setRange(0, signature.length, signature);
  bytes[11] = 0x0D;
  bytes[12] = 0x49;
  bytes[13] = 0x48;
  bytes[14] = 0x44;
  bytes[15] = 0x52;
  bytes[16] = (width >> 24) & 0xFF;
  bytes[17] = (width >> 16) & 0xFF;
  bytes[18] = (width >> 8) & 0xFF;
  bytes[19] = width & 0xFF;
  bytes[20] = (height >> 24) & 0xFF;
  bytes[21] = (height >> 16) & 0xFF;
  bytes[22] = (height >> 8) & 0xFF;
  bytes[23] = height & 0xFF;
  return base64Encode(bytes);
}
