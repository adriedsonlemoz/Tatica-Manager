import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/domain/club/club_logo_pack.dart';
import 'package:tatica_manager/game/club/club_identity_engine.dart';
import 'package:tatica_manager/game/club/club_logo_pack_engine.dart';
import 'package:tatica_manager/game/club/club_logo_pack_importer.dart';

void main() {
  test('pack de escudos faz round-trip e aceita atualização parcial por ID', () {
    final base = ClubIdentityEngine.defaultPack();
    final icon = base64Encode(_fakePng(width: 64, height: 64));
    final source = ClubLogoPack(
      name: ' Escudos   Comunidade ',
      author: ' Editor ',
      logos: [
        ClubLogoEntry(
          clubId: base.clubs.first.clubId,
          label: 'Clube de referência',
          iconBase64: icon,
        ),
      ],
    );

    final decoded = ClubLogoPackImporter.decodeBytes(
      Uint8List.fromList(utf8.encode(source.encode())),
    );
    final normalized = ClubLogoPackEngine.normalizeAndValidate(
      decoded,
      expectedIds: base.clubs.map((club) => club.clubId),
    );
    final updated = ClubLogoPackEngine.applyToIdentityPack(base, normalized);

    expect(normalized.name, 'Escudos Comunidade');
    expect(normalized.author, 'Editor');
    expect(normalized.logos, hasLength(1));
    expect(updated.clubs.first.iconBase64, icon);
    expect(updated.clubs[1].iconBase64, base.clubs[1].iconBase64);
    expect(updated.clubs.first.name, base.clubs.first.name);
    expect(updated.clubs.first.players?.length, base.clubs.first.players?.length);
    expect(updated.managers?.length, base.managers?.length);
  });

  test('pack de escudos rejeita IDs desconhecidos e duplicados', () {
    final base = ClubIdentityEngine.defaultPack();
    final icon = base64Encode(_fakePng(width: 64, height: 64));
    final expectedIds = base.clubs.map((club) => club.clubId);

    expect(
      () => ClubLogoPackEngine.normalizeAndValidate(
        ClubLogoPack(
          logos: [
            ClubLogoEntry(clubId: 'br-club-999', iconBase64: icon),
          ],
        ),
        expectedIds: expectedIds,
      ),
      throwsFormatException,
    );

    expect(
      () => ClubLogoPackEngine.normalizeAndValidate(
        ClubLogoPack(
          logos: [
            ClubLogoEntry(clubId: base.clubs.first.clubId, iconBase64: icon),
            ClubLogoEntry(clubId: base.clubs.first.clubId, iconBase64: icon),
          ],
        ),
        expectedIds: expectedIds,
      ),
      throwsFormatException,
    );
  });

  test('pack de escudos reutiliza a validação de tamanho e dimensões do editor', () {
    final base = ClubIdentityEngine.defaultPack();
    final invalidIcon = base64Encode(_fakePng(width: 16, height: 16));

    expect(
      () => ClubLogoPackEngine.normalizeAndValidate(
        ClubLogoPack(
          logos: [
            ClubLogoEntry(
              clubId: base.clubs.first.clubId,
              iconBase64: invalidIcon,
            ),
          ],
        ),
        expectedIds: base.clubs.map((club) => club.clubId),
      ),
      throwsFormatException,
    );
  });
}

Uint8List _fakePng({required int width, required int height}) {
  final bytes = Uint8List(24);
  const signatureAndHeader = <int>[
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
    0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  ];
  bytes.setRange(0, signatureAndHeader.length, signatureAndHeader);
  bytes[16] = (width >> 24) & 0xFF;
  bytes[17] = (width >> 16) & 0xFF;
  bytes[18] = (width >> 8) & 0xFF;
  bytes[19] = width & 0xFF;
  bytes[20] = (height >> 24) & 0xFF;
  bytes[21] = (height >> 16) & 0xFF;
  bytes[22] = (height >> 8) & 0xFF;
  bytes[23] = height & 0xFF;
  return bytes;
}
