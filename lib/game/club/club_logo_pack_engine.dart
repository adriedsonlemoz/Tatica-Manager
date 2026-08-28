import '../../domain/club/club_identity.dart';
import '../../domain/club/club_logo_pack.dart';
import 'club_icon_validator.dart';

abstract final class ClubLogoPackEngine {
  static ClubLogoPack normalizeAndValidate(
    ClubLogoPack pack, {
    required Iterable<String> expectedIds,
  }) {
    final expected = expectedIds.toSet();
    final name = _cleanText(pack.name);
    final author = pack.author == null ? null : _cleanText(pack.author!);
    if (name.length > 60) {
      throw const FormatException('O nome do pack de escudos pode ter no máximo 60 caracteres.');
    }
    if (author != null && author.length > 60) {
      throw const FormatException('O autor do pack de escudos pode ter no máximo 60 caracteres.');
    }
    if (pack.logos.isEmpty) {
      throw const FormatException('O pack precisa conter pelo menos um escudo.');
    }
    if (pack.logos.length > expected.length) {
      throw FormatException('O pack pode conter no máximo ${expected.length} escudos para este banco.');
    }

    final seen = <String>{};
    final normalized = <ClubLogoEntry>[];
    for (final entry in pack.logos) {
      final clubId = entry.clubId.trim();
      if (!expected.contains(clubId)) {
        throw FormatException('ID de clube desconhecido no pack de escudos: $clubId.');
      }
      if (!seen.add(clubId)) {
        throw FormatException('ID de clube duplicado no pack de escudos: $clubId.');
      }
      final icon = ClubIconValidator.normalizeBase64(entry.iconBase64);
      if (icon == null) {
        throw FormatException('O escudo de $clubId está vazio.');
      }
      final label = entry.label == null ? null : _cleanText(entry.label!);
      if (label != null && label.length > 80) {
        throw FormatException('O rótulo de $clubId pode ter no máximo 80 caracteres.');
      }
      normalized.add(
        ClubLogoEntry(
          clubId: clubId,
          iconBase64: icon,
          label: label?.isEmpty == true ? null : label,
        ),
      );
    }

    return ClubLogoPack(
      name: name.isEmpty ? 'Pack de escudos' : name,
      author: author?.isEmpty == true ? null : author,
      logos: normalized,
    );
  }

  static ClubIdentityPack applyToIdentityPack(
    ClubIdentityPack current,
    ClubLogoPack rawPack,
  ) {
    final pack = normalizeAndValidate(
      rawPack,
      expectedIds: current.clubs.map((club) => club.clubId),
    );
    final logosByClub = {
      for (final entry in pack.logos) entry.clubId: entry.iconBase64,
    };
    return ClubIdentityPack(
      name: current.name,
      author: current.author,
      clubs: current.clubs
          .map(
            (club) => logosByClub.containsKey(club.clubId)
                ? club.copyWith(iconBase64: logosByClub[club.clubId])
                : club,
          )
          .toList(growable: false),
      freeAgents: current.freeAgents,
      managers: current.managers,
    );
  }

  static String _cleanText(String value) =>
      value.trim().replaceAll(RegExp(r'\s+'), ' ');
}
