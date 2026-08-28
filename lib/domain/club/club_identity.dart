import 'dart:convert';

import '../career/manager_profile.dart';
import '../player/player.dart';
import 'club.dart';

class ClubIdentity {
  const ClubIdentity({
    required this.clubId,
    required this.name,
    required this.nickname,
    required this.shortName,
    this.stadium,
    this.colors,
    this.iconBase64,
    this.homeKit,
    this.awayKit,
    this.thirdKit,
    this.players,
  });

  final String clubId;
  final String name;
  final String nickname;
  final String shortName;
  final Stadium? stadium;
  final ClubColors? colors;
  final String? iconBase64;
  final ClubKit? homeKit;
  final ClubKit? awayKit;
  final ClubKit? thirdKit;
  final List<Player>? players;

  ClubIdentity copyWith({
    String? clubId,
    String? name,
    String? nickname,
    String? shortName,
    Stadium? stadium,
    ClubColors? colors,
    String? iconBase64,
    bool clearIcon = false,
    ClubKit? homeKit,
    ClubKit? awayKit,
    ClubKit? thirdKit,
    List<Player>? players,
  }) =>
      ClubIdentity(
        clubId: clubId ?? this.clubId,
        name: name ?? this.name,
        nickname: nickname ?? this.nickname,
        shortName: shortName ?? this.shortName,
        stadium: stadium ?? this.stadium,
        colors: colors ?? this.colors,
        iconBase64: clearIcon ? '' : (iconBase64 ?? this.iconBase64),
        homeKit: homeKit ?? this.homeKit,
        awayKit: awayKit ?? this.awayKit,
        thirdKit: thirdKit ?? this.thirdKit,
        players: players ?? this.players,
      );

  Map<String, dynamic> toJson() => {
        'id': clubId,
        'name': name,
        'nickname': nickname,
        'shortName': shortName,
        if (stadium != null) 'stadium': stadium!.toJson(),
        if (colors != null) 'colors': colors!.toJson(),
        if (iconBase64 != null) 'iconBase64': iconBase64,
        if (homeKit != null) 'homeKit': homeKit!.toJson(),
        if (awayKit != null) 'awayKit': awayKit!.toJson(),
        if (thirdKit != null) 'thirdKit': thirdKit!.toJson(),
        if (players != null) 'players': players!.map((player) => player.toJson()).toList(),
      };

  factory ClubIdentity.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['clubId'];
    final rawName = json['name'];
    final rawNickname = json['nickname'] ?? rawName;
    final rawShortName = json['shortName'];
    if (rawId is! String ||
        rawName is! String ||
        rawNickname is! String ||
        rawShortName is! String) {
      throw const FormatException(
        'Cada clube precisa ter id, name, nickname e shortName em texto.',
      );
    }

    List<Player>? players;
    final rawPlayers = json['players'];
    if (rawPlayers != null) {
      if (rawPlayers is! List) {
        throw FormatException('A lista de jogadores de $rawId é inválida.');
      }
      players = rawPlayers.map((item) {
        if (item is! Map) {
          throw FormatException('Cada jogador de $rawId precisa ser um objeto JSON.');
        }
        return Player.fromJson(Map<String, dynamic>.from(item));
      }).toList(growable: false);
    }

    return ClubIdentity(
      clubId: rawId,
      name: rawName,
      nickname: rawNickname,
      shortName: rawShortName,
      stadium: json['stadium'] is Map
          ? Stadium.fromJson(Map<String, dynamic>.from(json['stadium'] as Map))
          : null,
      colors: json['colors'] is Map
          ? ClubColors.fromJson(Map<String, dynamic>.from(json['colors'] as Map))
          : null,
      iconBase64: json['iconBase64'] is String ? json['iconBase64'] as String : null,
      homeKit: json['homeKit'] is Map
          ? ClubKit.fromJson(Map<String, dynamic>.from(json['homeKit'] as Map))
          : null,
      awayKit: json['awayKit'] is Map
          ? ClubKit.fromJson(Map<String, dynamic>.from(json['awayKit'] as Map))
          : null,
      thirdKit: json['thirdKit'] is Map
          ? ClubKit.fromJson(Map<String, dynamic>.from(json['thirdKit'] as Map))
          : null,
      players: players,
    );
  }
}

class ClubIdentityPack {
  const ClubIdentityPack({
    required this.clubs,
    this.name = 'Banco personalizado',
    this.author,
    this.freeAgents,
    this.managers,
  });

  static const String format = 'tatica-manager-clubs';
  static const int formatVersion = 3;

  final String name;
  final String? author;
  final List<ClubIdentity> clubs;
  final List<Player>? freeAgents;
  final List<ManagerProfile>? managers;

  Map<String, dynamic> toJson() => {
        'format': format,
        'version': formatVersion,
        'name': name,
        if (author?.trim().isNotEmpty == true) 'author': author!.trim(),
        'clubs': clubs.map((club) => club.toJson()).toList(),
        if (freeAgents != null) 'freeAgents': freeAgents!.map((player) => player.toJson()).toList(),
        if (managers != null) 'managers': managers!.map((manager) => manager.toJson()).toList(),
      };

  String encode() => const JsonEncoder.withIndent('  ').convert(toJson());

  factory ClubIdentityPack.fromJson(Map<String, dynamic> json) {
    if (json['format'] != format) {
      throw const FormatException('Formato de pacote de clubes inválido.');
    }
    final rawVersion = json['version'];
    final version = rawVersion is int ? rawVersion : null;
    if (version == null || version < 1 || version > formatVersion) {
      throw FormatException(
        'Versão de pacote não suportada: ${version ?? 'ausente'}.',
      );
    }
    final rawClubs = json['clubs'];
    if (rawClubs is! List) {
      throw const FormatException('O pacote não contém uma lista de clubes.');
    }
    final clubs = <ClubIdentity>[];
    for (final item in rawClubs) {
      if (item is! Map) {
        throw const FormatException('Cada clube do pacote precisa ser um objeto JSON.');
      }
      clubs.add(ClubIdentity.fromJson(Map<String, dynamic>.from(item)));
    }

    List<ManagerProfile>? managers;
    final rawManagers = json['managers'] ?? json['coaches'];
    if (rawManagers != null) {
      if (rawManagers is! List) {
        throw const FormatException('A lista de técnicos é inválida.');
      }
      managers = rawManagers.map((item) {
        if (item is! Map) {
          throw const FormatException('Cada técnico precisa ser um objeto JSON.');
        }
        return ManagerProfile.fromJson(Map<String, dynamic>.from(item));
      }).toList(growable: false);
    }

    List<Player>? freeAgents;
    final rawFreeAgents = json['freeAgents'];
    if (rawFreeAgents != null) {
      if (rawFreeAgents is! List) {
        throw const FormatException('A lista de jogadores livres é inválida.');
      }
      freeAgents = rawFreeAgents.map((item) {
        if (item is! Map) {
          throw const FormatException('Cada jogador livre precisa ser um objeto JSON.');
        }
        return Player.fromJson(Map<String, dynamic>.from(item));
      }).toList(growable: false);
    }

    return ClubIdentityPack(
      name: json['name'] is String && (json['name'] as String).trim().isNotEmpty
          ? (json['name'] as String).trim()
          : 'Pacote importado',
      author: json['author'] is String ? (json['author'] as String).trim() : null,
      clubs: clubs,
      freeAgents: freeAgents,
      managers: managers,
    );
  }

  factory ClubIdentityPack.decode(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map) {
      throw const FormatException('O arquivo precisa conter um objeto JSON.');
    }
    return ClubIdentityPack.fromJson(Map<String, dynamic>.from(decoded));
  }
}
