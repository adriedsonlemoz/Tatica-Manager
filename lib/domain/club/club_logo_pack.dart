import 'dart:convert';

class ClubLogoEntry {
  const ClubLogoEntry({
    required this.clubId,
    required this.iconBase64,
    this.label,
  });

  final String clubId;
  final String iconBase64;
  final String? label;

  Map<String, dynamic> toJson() => {
        'clubId': clubId,
        if (label?.trim().isNotEmpty == true) 'label': label!.trim(),
        'iconBase64': iconBase64,
      };

  factory ClubLogoEntry.fromJson(Map<String, dynamic> json) {
    final clubId = json['clubId'] ?? json['id'];
    final iconBase64 = json['iconBase64'] ?? json['logoBase64'];
    if (clubId is! String || iconBase64 is! String) {
      throw const FormatException(
        'Cada escudo precisa ter clubId e iconBase64 em texto.',
      );
    }
    final rawLabel = json['label'] ?? json['clubName'] ?? json['name'];
    return ClubLogoEntry(
      clubId: clubId,
      iconBase64: iconBase64,
      label: rawLabel is String ? rawLabel : null,
    );
  }
}

class ClubLogoPack {
  const ClubLogoPack({
    required this.logos,
    this.name = 'Pack de escudos',
    this.author,
  });

  static const String format = 'tatica-manager-logos';
  static const int formatVersion = 1;

  final String name;
  final String? author;
  final List<ClubLogoEntry> logos;

  Map<String, dynamic> toJson() => {
        'format': format,
        'version': formatVersion,
        'name': name,
        if (author?.trim().isNotEmpty == true) 'author': author!.trim(),
        'logos': logos.map((entry) => entry.toJson()).toList(growable: false),
      };

  String encode() => const JsonEncoder.withIndent('  ').convert(toJson());

  factory ClubLogoPack.decode(String source) {
    dynamic decoded;
    try {
      decoded = jsonDecode(source);
    } catch (error) {
      throw FormatException('JSON do pack de escudos inválido: $error');
    }
    if (decoded is! Map) {
      throw const FormatException('O pack de escudos precisa ser um objeto JSON.');
    }
    return ClubLogoPack.fromJson(Map<String, dynamic>.from(decoded));
  }

  factory ClubLogoPack.fromJson(Map<String, dynamic> json) {
    if (json['format'] != format) {
      throw const FormatException('Formato de pack de escudos inválido.');
    }
    final rawVersion = json['version'];
    if (rawVersion is! int || rawVersion < 1 || rawVersion > formatVersion) {
      throw FormatException(
        'Versão de pack de escudos não suportada: ${rawVersion ?? 'ausente'}.',
      );
    }
    final rawLogos = json['logos'];
    if (rawLogos is! List) {
      throw const FormatException('O pack não contém uma lista de escudos.');
    }
    final logos = <ClubLogoEntry>[];
    for (final item in rawLogos) {
      if (item is! Map) {
        throw const FormatException('Cada escudo do pack precisa ser um objeto JSON.');
      }
      logos.add(ClubLogoEntry.fromJson(Map<String, dynamic>.from(item)));
    }
    final rawName = json['name'];
    final rawAuthor = json['author'];
    if (rawName != null && rawName is! String) {
      throw const FormatException('O nome do pack de escudos precisa ser texto.');
    }
    if (rawAuthor != null && rawAuthor is! String) {
      throw const FormatException('O autor do pack de escudos precisa ser texto.');
    }
    return ClubLogoPack(
      name: rawName is String ? rawName : 'Pack de escudos',
      author: rawAuthor is String ? rawAuthor : null,
      logos: logos,
    );
  }
}
