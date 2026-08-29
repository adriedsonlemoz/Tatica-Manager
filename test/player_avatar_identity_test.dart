import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/data/club_seed.dart';
import 'package:tatica_manager/domain/career/manager_appearance.dart';
import 'package:tatica_manager/domain/career/manager_profile.dart';
import 'package:tatica_manager/domain/player/player_attributes.dart';
import 'package:tatica_manager/domain/season/career_state.dart';
import 'package:tatica_manager/game/career/career_factory.dart';
import 'package:tatica_manager/game/player/player_avatar_identity.dart';

void main() {
  test('identidade do avatar é estável para o mesmo Player.id', () {
    final career = _career('avatar-stable');
    final player = career.userClub.squad.first;

    final first = PlayerAvatarIdentity.fromPlayer(player);
    final second = PlayerAvatarIdentity.fromPlayer(player);

    expect(second, first);
    expect(stablePlayerSeed(player.id), first.seed);
  });

  test('save/load não altera o rosto derivado do jogador', () {
    final original = _career('avatar-save-load');
    final player = original.userClub.squad[4];
    final before = PlayerAvatarIdentity.fromPlayer(player);

    final restored = CareerState.fromJson(original.toJson());
    final restoredPlayer = restored.userClub.squad
        .firstWhere((item) => item.id == player.id);
    final after = PlayerAvatarIdentity.fromPlayer(restoredPlayer);

    expect(after, before);
  });

  test('foto personalizada do técnico sobrevive ao save/load', () {
    const manager = ManagerProfile(
      displayName: 'Técnico Foto',
      appearance: ManagerAppearance(customPhotoPath: '/private/manager.png'),
    );
    final restored = ManagerProfile.fromJson(manager.toJson());
    expect(restored.appearance.customPhotoPath, '/private/manager.png');
  });

  test('atributos esportivos de carreira não alteram identidade facial', () {
    final career = _career('avatar-career-state');
    final player = career.userClub.squad[2];
    final before = PlayerAvatarIdentity.fromPlayer(player);
    final updated = player.copyWith(
      overall: (player.overall + 3).clamp(1, 99).toInt(),
      condition: 41,
      morale: 92,
    );

    expect(PlayerAvatarIdentity.fromPlayer(updated), before);
  });

  test('idade aparente evolui sem trocar os traços faciais permanentes', () {
    final career = _career('avatar-aging');
    final player = career.userClub.squad[2];
    final young = PlayerAvatarIdentity.fromPlayer(player.copyWith(age: 20));
    final veteran = PlayerAvatarIdentity.fromPlayer(player.copyWith(age: 35));

    expect(veteran.seed, young.seed);
    expect(veteran.skinTone, young.skinTone);
    expect(veteran.hairStyle, young.hairStyle);
    expect(veteran.hairColor, young.hairColor);
    expect(veteran.faceShape, young.faceShape);
    expect(veteran.eyeStyle, young.eyeStyle);
    expect(veteran.eyeColor, young.eyeColor);
    expect(veteran.eyebrowStyle, young.eyebrowStyle);
    expect(veteran.noseStyle, young.noseStyle);
    expect(veteran.mouthStyle, young.mouthStyle);
    expect(veteran.beardStyle, young.beardStyle);
    expect(veteran.moustacheStyle, young.moustacheStyle);
    expect(veteran.detailStyle, young.detailStyle);
    expect(young.ageStyle, 0);
    expect(veteran.ageStyle, 2);
  });

  test('perfil visual existente controla pele e cabelo sem trocar seed facial', () {
    final career = _career('avatar-editor-fields');
    final player = career.userClub.squad[1];
    final before = PlayerAvatarIdentity.fromPlayer(player);
    final edited = player.copyWith(
      visual: const VisualProfile(
        skinTone: 5,
        hairStyle: 7,
        hairColor: 4,
        bodyType: 1,
        visualHeight: 1,
        bootStyle: 2,
      ),
    );
    final after = PlayerAvatarIdentity.fromPlayer(edited);

    expect(after.seed, before.seed);
    expect(after.faceShape, before.faceShape);
    expect(after.eyeStyle, before.eyeStyle);
    expect(after.beardStyle, before.beardStyle);
    expect(after.skinTone, 5);
    expect(after.hairStyle, 7);
    expect(after.hairColor, 4);
  });

  test('centenas de IDs produzem seeds distintas e ampla variedade', () {
    final career = _career('avatar-variety');
    final base = career.userClub.squad.first;
    final identities = List.generate(
      600,
      (index) => PlayerAvatarIdentity.fromPlayer(
        base.copyWith(id: 'avatar-player-$index'),
      ),
    );

    expect(identities.map((item) => item.seed).toSet(), hasLength(600));
    expect(identities.toSet().length, greaterThan(500));
  });

  test('rostos estão ligados às telas visuais sem alterar lógica de mercado', () {
    final squad = File('lib/features/squad/squad_screen.dart').readAsStringSync();
    final playerCard = File('lib/app/widgets/player_card.dart').readAsStringSync();
    final profile = File('lib/features/player/player_profile_screen.dart')
        .readAsStringSync();
    final market = File('lib/features/market/market_screen.dart').readAsStringSync();
    final marketComponents = File(
      'lib/features/market/market_components.dart',
    ).readAsStringSync();
    final negotiation = File('lib/features/negotiation/negotiation_screen.dart')
        .readAsStringSync();
    final incoming = File(
      'lib/features/market/incoming_transfer_offer_dialog.dart',
    ).readAsStringSync();
    final home = File('lib/features/home/home_screen.dart').readAsStringSync();
    final homeClean = File('lib/features/home/home_clean_content.dart')
        .readAsStringSync();

    expect(squad, contains('PlayerCard('));
    expect(playerCard, contains('PlayerAvatar('));
    expect(playerCard, contains('this.showStatus = true'));
    expect(profile, contains('PlayerAvatar('));
    expect(profile, isNot(contains('ESPAÇO PREPARADO PARA PERSONAGEM 3D')));
    expect(market, contains("part 'market_components.dart';"));
    expect(marketComponents, contains('PlayerAvatar('));
    expect(negotiation, contains('PlayerAvatar('));
    expect(incoming, contains('PlayerAvatar('));
    expect(home, contains('HomeCleanRankings('));
    expect(home, contains('onPlayerTap: (entry) => Navigator.of(context).push('));
    expect(homeClean, contains('PlayerAvatar(player: entry.player'));
    expect('$market$marketComponents', isNot(contains('TransferEngine.buy')));
  });
}

CareerState _career(String id) => CareerFactory.create(
      careerId: id,
      careerName: 'Avatar Test',
      manager: const ManagerProfile(displayName: 'Técnico Avatar'),
      userClubId: clubSeeds.first.id,
      seed: 20260825,
    );
