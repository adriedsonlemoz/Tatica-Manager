import 'dart:convert';

import 'player.dart';

class PlayerDataPack {
  const PlayerDataPack({
    required this.players,
    this.name = 'Pacote de jogadores',
    this.author,
  });

  static const String format = 'tatica-manager-players';
  static const int formatVersion = 1;

  final String name;
  final String? author;
  final List<Player> players;

  Map<String, dynamic> toJson() => {
        'format': format,
        'version': formatVersion,
        'name': name,
        if (author?.trim().isNotEmpty == true) 'author': author!.trim(),
        'players': players.map((player) => player.toJson()).toList(),
      };

  String encode() => const JsonEncoder.withIndent('  ').convert(toJson());

  factory PlayerDataPack.fromJson(Map<String, dynamic> json) {
    if (json['format'] != format) {
      throw const FormatException('Formato de pacote de jogadores inválido.');
    }
    if (json['version'] != formatVersion) {
      throw FormatException('Versão de pacote de jogadores não suportada: ${json['version'] ?? 'ausente'}.');
    }
    final rawPlayers = json['players'];
    if (rawPlayers is! List) {
      throw const FormatException('O pacote não contém uma lista de jogadores.');
    }
    final players = rawPlayers.map((item) {
      if (item is! Map) {
        throw const FormatException('Cada jogador precisa ser um objeto JSON.');
      }
      return Player.fromJson(Map<String, dynamic>.from(item));
    }).toList(growable: false);
    final name = json['name'] is String && (json['name'] as String).trim().isNotEmpty
        ? (json['name'] as String).trim()
        : 'Pacote de jogadores';
    final author = json['author'] is String ? (json['author'] as String).trim() : null;
    return PlayerDataPack(players: players, name: name, author: author);
  }

  factory PlayerDataPack.decode(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map) {
      throw const FormatException('O arquivo precisa conter um objeto JSON.');
    }
    return PlayerDataPack.fromJson(Map<String, dynamic>.from(decoded));
  }
}
