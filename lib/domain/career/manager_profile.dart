import '../formation/formation.dart';
import '../tactic/tactic.dart';
import 'manager_appearance.dart';

class ManagerProfile {
  const ManagerProfile({
    required this.displayName,
    this.id = '',
    this.nickname = '',
    this.nationality = 'Brasil',
    this.ageAtStart = 35,
    this.careerStartSeason = 2026,
    this.birthPlace = '',
    this.birthCountry = 'Brasil',
    this.birthState = '',
    this.birthCity = '',
    this.appearance = const ManagerAppearance(),
    this.birthDate,
    this.currentClubId,
    this.contractUntilSeason,
    this.reputation = 50,
    this.style = 'Equilibrado',
    this.preferredFormation = FormationType.f433,
    this.preferredMentality = Mentality.balanced,
    this.experienceYears = 5,
    this.overall = 65,
    this.userCreated = false,
  });

  final String id;
  final String displayName;
  final String nickname;
  final String nationality;
  final int ageAtStart;
  final int careerStartSeason;
  final String birthPlace;
  final String birthCountry;
  final String birthState;
  final String birthCity;
  final ManagerAppearance appearance;
  final DateTime? birthDate;
  final String? currentClubId;
  final int? contractUntilSeason;
  final int reputation;
  final String style;
  final FormationType preferredFormation;
  final Mentality preferredMentality;
  final int experienceYears;
  final int overall;
  final bool userCreated;

  String get preferredName => nickname.trim().isEmpty ? displayName : nickname;

  String get avatarSeedSource =>
      'manager:$id|$displayName|$careerStartSeason|$birthCountry|$birthCity';

  int ageInSeason(int season) => birthDate != null
      ? (season - birthDate!.year).clamp(18, 100).toInt()
      : (ageAtStart + (season - careerStartSeason)).clamp(18, 100).toInt();

  String birthPlaceSummary({bool omitCountry = false}) {
    final values = <String>[
      if (birthCity.trim().isNotEmpty) birthCity.trim(),
      if (birthState.trim().isNotEmpty) birthState.trim(),
      if (!omitCountry && birthCountry.trim().isNotEmpty) birthCountry.trim(),
    ];
    if (values.isNotEmpty) return values.join(', ');
    return birthPlace.trim();
  }

  factory ManagerProfile.normalized({
    required String displayName,
    String id = '',
    String nickname = '',
    String nationality = 'Brasil',
    int ageAtStart = 35,
    int careerStartSeason = 2026,
    String birthPlace = '',
    String birthCountry = 'Brasil',
    String birthState = '',
    String birthCity = '',
    ManagerAppearance appearance = const ManagerAppearance(),
    DateTime? birthDate,
    String? currentClubId,
    int? contractUntilSeason,
    int reputation = 50,
    String style = 'Equilibrado',
    FormationType preferredFormation = FormationType.f433,
    Mentality preferredMentality = Mentality.balanced,
    int experienceYears = 5,
    int overall = 65,
    bool userCreated = false,
  }) {
    final cleanName = _clean(displayName);
    final cleanNickname = _clean(nickname);
    final cleanNationality = _clean(nationality);
    final cleanBirthCountry = _clean(birthCountry);
    final cleanBirthState = _clean(birthState);
    final cleanBirthCity = _clean(birthCity);
    final cleanBirthPlace = _clean(
      birthPlace.isNotEmpty
          ? birthPlace
          : [cleanBirthCity, cleanBirthState, cleanBirthCountry]
              .where((value) => value.isNotEmpty)
              .join(', '),
    );

    if (cleanName.length < 2 || cleanName.length > 50) {
      throw const FormatException('O nome do técnico deve ter entre 2 e 50 caracteres.');
    }
    if (cleanNickname.isNotEmpty &&
        (cleanNickname.length < 2 || cleanNickname.length > 24)) {
      throw const FormatException('O apelido deve ter entre 2 e 24 caracteres.');
    }
    if (cleanNationality.length < 2 || cleanNationality.length > 40) {
      throw const FormatException('A nacionalidade deve ter entre 2 e 40 caracteres.');
    }
    if (ageAtStart < 18 || ageAtStart > 80) {
      throw const FormatException('A idade do técnico deve ficar entre 18 e 80 anos.');
    }
    if (careerStartSeason < 1900 || careerStartSeason > 2200) {
      throw const FormatException('A temporada inicial do técnico é inválida.');
    }
    if (cleanBirthCountry.length > 40 || cleanBirthState.length > 40 || cleanBirthCity.length > 60) {
      throw const FormatException('Os dados do local de nascimento são grandes demais.');
    }
    if (cleanBirthPlace.length > 120) {
      throw const FormatException('O local de nascimento pode ter no máximo 120 caracteres.');
    }

    return ManagerProfile(
      id: _clean(id),
      displayName: cleanName,
      nickname: cleanNickname,
      nationality: cleanNationality,
      ageAtStart: ageAtStart,
      careerStartSeason: careerStartSeason,
      birthPlace: cleanBirthPlace,
      birthCountry: cleanBirthCountry.isEmpty ? 'Brasil' : cleanBirthCountry,
      birthState: cleanBirthState,
      birthCity: cleanBirthCity,
      appearance: appearance,
      birthDate: birthDate,
      currentClubId: currentClubId?.trim().isEmpty == true ? null : currentClubId?.trim(),
      contractUntilSeason: contractUntilSeason,
      reputation: reputation.clamp(0, 100).toInt(),
      style: _clean(style).isEmpty ? 'Equilibrado' : _clean(style),
      preferredFormation: preferredFormation,
      preferredMentality: preferredMentality,
      experienceYears: experienceYears.clamp(0, 60).toInt(),
      overall: overall.clamp(1, 99).toInt(),
      userCreated: userCreated,
    );
  }

  ManagerProfile copyWith({
    String? id,
    String? displayName,
    String? nickname,
    String? nationality,
    int? ageAtStart,
    int? careerStartSeason,
    String? birthPlace,
    String? birthCountry,
    String? birthState,
    String? birthCity,
    ManagerAppearance? appearance,
    DateTime? birthDate,
    String? currentClubId,
    bool clearCurrentClub = false,
    int? contractUntilSeason,
    int? reputation,
    String? style,
    FormationType? preferredFormation,
    Mentality? preferredMentality,
    int? experienceYears,
    int? overall,
    bool? userCreated,
  }) =>
      ManagerProfile(
        id: id ?? this.id,
        displayName: displayName ?? this.displayName,
        nickname: nickname ?? this.nickname,
        nationality: nationality ?? this.nationality,
        ageAtStart: ageAtStart ?? this.ageAtStart,
        careerStartSeason: careerStartSeason ?? this.careerStartSeason,
        birthPlace: birthPlace ?? this.birthPlace,
        birthCountry: birthCountry ?? this.birthCountry,
        birthState: birthState ?? this.birthState,
        birthCity: birthCity ?? this.birthCity,
        appearance: appearance ?? this.appearance,
        birthDate: birthDate ?? this.birthDate,
        currentClubId: clearCurrentClub ? null : (currentClubId ?? this.currentClubId),
        contractUntilSeason: contractUntilSeason ?? this.contractUntilSeason,
        reputation: reputation ?? this.reputation,
        style: style ?? this.style,
        preferredFormation: preferredFormation ?? this.preferredFormation,
        preferredMentality: preferredMentality ?? this.preferredMentality,
        experienceYears: experienceYears ?? this.experienceYears,
        overall: overall ?? this.overall,
        userCreated: userCreated ?? this.userCreated,
      );

  Map<String, dynamic> toJson() => {
        if (id.isNotEmpty) 'id': id,
        'displayName': displayName,
        'nickname': nickname,
        'nationality': nationality,
        'ageAtStart': ageAtStart,
        'careerStartSeason': careerStartSeason,
        'birthPlace': birthPlace,
        'birthCountry': birthCountry,
        'birthState': birthState,
        'birthCity': birthCity,
        'appearance': appearance.toJson(),
        if (birthDate != null) 'birthDate': birthDate!.toIso8601String(),
        if (currentClubId != null) 'currentClubId': currentClubId,
        if (contractUntilSeason != null) 'contractUntilSeason': contractUntilSeason,
        'reputation': reputation,
        'style': style,
        'preferredFormation': preferredFormation.name,
        'preferredMentality': preferredMentality.name,
        'experienceYears': experienceYears,
        'overall': overall,
        'userCreated': userCreated,
      };

  factory ManagerProfile.fromJson(Map<String, dynamic> json) {
    final rawName = (json['displayName'] as String?)?.trim();
    final rawNickname = (json['nickname'] as String?)?.trim();
    final rawNationality = (json['nationality'] as String?)?.trim();
    final rawBirthPlace = (json['birthPlace'] as String?)?.trim();
    final rawBirthCountry = (json['birthCountry'] as String?)?.trim();
    final rawBirthState = (json['birthState'] as String?)?.trim();
    final rawBirthCity = (json['birthCity'] as String?)?.trim();
    final rawAge = json['ageAtStart'] ?? json['age'];
    final rawStartSeason = json['careerStartSeason'] ?? json['startSeason'];

    return ManagerProfile(
      id: (json['id'] as String?)?.trim() ?? '',
      displayName: rawName?.isNotEmpty == true ? rawName! : 'Técnico',
      nickname: rawNickname?.isNotEmpty == true ? rawNickname! : '',
      nationality: rawNationality?.isNotEmpty == true ? rawNationality! : 'Brasil',
      ageAtStart: rawAge is int ? rawAge.clamp(18, 80).toInt() : 35,
      careerStartSeason: rawStartSeason is int
          ? rawStartSeason.clamp(1900, 2200).toInt()
          : 2026,
      birthPlace: rawBirthPlace?.isNotEmpty == true
          ? rawBirthPlace!
          : [rawBirthCity, rawBirthState, rawBirthCountry]
              .where((value) => value?.isNotEmpty == true)
              .join(', '),
      birthCountry: rawBirthCountry?.isNotEmpty == true ? rawBirthCountry! : 'Brasil',
      birthState: rawBirthState?.isNotEmpty == true ? rawBirthState! : '',
      birthCity: rawBirthCity?.isNotEmpty == true ? rawBirthCity! : '',
      appearance: json['appearance'] is Map
          ? ManagerAppearance.fromJson(
              Map<String, dynamic>.from(json['appearance'] as Map),
            )
          : const ManagerAppearance(),
      birthDate: DateTime.tryParse(json['birthDate'] as String? ?? ''),
      currentClubId: (json['currentClubId'] as String?)?.trim().isEmpty == false
          ? (json['currentClubId'] as String).trim()
          : null,
      contractUntilSeason: (json['contractUntilSeason'] as num?)?.toInt(),
      reputation: (json['reputation'] as num?)?.toInt().clamp(0, 100).toInt() ?? 50,
      style: (json['style'] as String?)?.trim().isNotEmpty == true
          ? (json['style'] as String).trim()
          : 'Equilibrado',
      preferredFormation: FormationType.values.firstWhere(
        (value) => value.name == json['preferredFormation'],
        orElse: () => FormationType.f433,
      ),
      preferredMentality: Mentality.values.firstWhere(
        (value) => value.name == json['preferredMentality'],
        orElse: () => Mentality.balanced,
      ),
      experienceYears: (json['experienceYears'] as num?)?.toInt().clamp(0, 60).toInt() ?? 5,
      overall: (json['overall'] as num?)?.toInt().clamp(1, 99).toInt() ?? 65,
      userCreated: json['userCreated'] as bool? ?? false,
    );
  }

  static String _clean(String value) =>
      value.trim().replaceAll(RegExp(r'\s+'), ' ');
}

class ManagerCareerHistoryEntry {
  const ManagerCareerHistoryEntry({
    required this.season,
    required this.clubId,
    required this.displayName,
    required this.nickname,
    required this.age,
    required this.nationality,
    this.birthPlace = '',
    this.birthCountry = 'Brasil',
    this.birthState = '',
    this.birthCity = '',
  });

  final int season;
  final String clubId;
  final String displayName;
  final String nickname;
  final int age;
  final String nationality;
  final String birthPlace;
  final String birthCountry;
  final String birthState;
  final String birthCity;

  String get preferredName => nickname.trim().isEmpty ? displayName : nickname;

  String birthPlaceSummary({bool omitCountry = false}) {
    final values = <String>[
      if (birthCity.trim().isNotEmpty) birthCity.trim(),
      if (birthState.trim().isNotEmpty) birthState.trim(),
      if (!omitCountry && birthCountry.trim().isNotEmpty) birthCountry.trim(),
    ];
    if (values.isNotEmpty) return values.join(', ');
    return birthPlace.trim();
  }

  factory ManagerCareerHistoryEntry.fromProfile(
    ManagerProfile profile, {
    required int season,
    required String clubId,
  }) =>
      ManagerCareerHistoryEntry(
        season: season,
        clubId: clubId,
        displayName: profile.displayName,
        nickname: profile.nickname,
        age: profile.ageInSeason(season),
        nationality: profile.nationality,
        birthPlace: profile.birthPlace,
        birthCountry: profile.birthCountry,
        birthState: profile.birthState,
        birthCity: profile.birthCity,
      );

  Map<String, dynamic> toJson() => {
        'season': season,
        'clubId': clubId,
        'displayName': displayName,
        'nickname': nickname,
        'age': age,
        'nationality': nationality,
        'birthPlace': birthPlace,
        'birthCountry': birthCountry,
        'birthState': birthState,
        'birthCity': birthCity,
      };

  factory ManagerCareerHistoryEntry.fromJson(Map<String, dynamic> json) =>
      ManagerCareerHistoryEntry(
        season: json['season'] as int? ?? 2026,
        clubId: json['clubId'] as String? ?? '',
        displayName: (json['displayName'] as String?)?.trim().isNotEmpty == true
            ? (json['displayName'] as String).trim()
            : 'Técnico',
        nickname: (json['nickname'] as String?)?.trim() ?? '',
        age: (json['age'] as int? ?? 35).clamp(18, 100).toInt(),
        nationality: (json['nationality'] as String?)?.trim().isNotEmpty == true
            ? (json['nationality'] as String).trim()
            : 'Brasil',
        birthPlace: (json['birthPlace'] as String?)?.trim() ?? '',
        birthCountry: (json['birthCountry'] as String?)?.trim().isNotEmpty == true
            ? (json['birthCountry'] as String).trim()
            : 'Brasil',
        birthState: (json['birthState'] as String?)?.trim() ?? '',
        birthCity: (json['birthCity'] as String?)?.trim() ?? '',
      );
}
