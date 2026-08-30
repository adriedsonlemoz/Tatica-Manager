import '../finance/sponsorship.dart';
import '../player/player.dart';

class ClubColors {
  const ClubColors({required this.primaryHex, required this.secondaryHex});
  final int primaryHex;
  final int secondaryHex;

  ClubColors copyWith({int? primaryHex, int? secondaryHex}) => ClubColors(
        primaryHex: primaryHex ?? this.primaryHex,
        secondaryHex: secondaryHex ?? this.secondaryHex,
      );

  Map<String, dynamic> toJson() => {'primaryHex': primaryHex, 'secondaryHex': secondaryHex};
  factory ClubColors.fromJson(Map<String, dynamic> json) => ClubColors(
        primaryHex: json['primaryHex'] as int? ?? 0xFF1E7A2B,
        secondaryHex: json['secondaryHex'] as int? ?? 0xFFFFFFFF,
      );
}

enum ClubKitPattern { solid, verticalStripes, horizontalStripes, sash, halves, gradient }

extension ClubKitPatternX on ClubKitPattern {
  String get label => switch (this) {
        ClubKitPattern.solid => 'Lisa',
        ClubKitPattern.verticalStripes => 'Listras verticais',
        ClubKitPattern.horizontalStripes => 'Listras horizontais',
        ClubKitPattern.sash => 'Faixa diagonal',
        ClubKitPattern.halves => 'Metade a metade',
        ClubKitPattern.gradient => 'Degradê',
      };

  static ClubKitPattern fromName(String? value) => ClubKitPattern.values.firstWhere(
        (pattern) => pattern.name == value,
        orElse: () => ClubKitPattern.solid,
      );
}

class ClubKit {
  const ClubKit({
    required this.primaryHex,
    required this.secondaryHex,
    required this.shortsHex,
    required this.socksHex,
    this.accentHex = 0xFFFFFFFF,
    this.pattern = ClubKitPattern.solid,
  });

  final int primaryHex;
  final int secondaryHex;
  final int accentHex;
  final int shortsHex;
  final int socksHex;
  final ClubKitPattern pattern;

  ClubKit copyWith({
    int? primaryHex,
    int? secondaryHex,
    int? accentHex,
    int? shortsHex,
    int? socksHex,
    ClubKitPattern? pattern,
  }) =>
      ClubKit(
        primaryHex: primaryHex ?? this.primaryHex,
        secondaryHex: secondaryHex ?? this.secondaryHex,
        accentHex: accentHex ?? this.accentHex,
        shortsHex: shortsHex ?? this.shortsHex,
        socksHex: socksHex ?? this.socksHex,
        pattern: pattern ?? this.pattern,
      );

  Map<String, dynamic> toJson() => {
        'primaryHex': primaryHex,
        'secondaryHex': secondaryHex,
        'accentHex': accentHex,
        'shortsHex': shortsHex,
        'socksHex': socksHex,
        'pattern': pattern.name,
      };

  factory ClubKit.fromJson(Map<String, dynamic> json, {ClubKit? fallback}) {
    final base = fallback ?? const ClubKit(
      primaryHex: 0xFF1E7A2B,
      secondaryHex: 0xFFFFFFFF,
      accentHex: 0xFFFFFFFF,
      shortsHex: 0xFF1E7A2B,
      socksHex: 0xFFFFFFFF,
    );
    return ClubKit(
      primaryHex: json['primaryHex'] as int? ?? base.primaryHex,
      secondaryHex: json['secondaryHex'] as int? ?? base.secondaryHex,
      accentHex: json['accentHex'] as int? ?? base.accentHex,
      shortsHex: json['shortsHex'] as int? ?? base.shortsHex,
      socksHex: json['socksHex'] as int? ?? base.socksHex,
      pattern: ClubKitPatternX.fromName(json['pattern'] as String?),
    );
  }
}

enum StadiumProjectKind {
  stands,
  hospitality,
  retail,
  food,
  advertising,
  parking,
  museum,
  trainingCenter,
}

enum StadiumProjectStatus { planned, inProgress, completed }

class StadiumProject {
  const StadiumProject({
    required this.id,
    required this.kind,
    required this.targetLevel,
    required this.cost,
    required this.startedAt,
    required this.completesAt,
    this.status = StadiumProjectStatus.inProgress,
  });

  final String id;
  final StadiumProjectKind kind;
  final int targetLevel;
  final int cost;
  final DateTime startedAt;
  final DateTime completesAt;
  final StadiumProjectStatus status;

  bool get isActive => status == StadiumProjectStatus.inProgress;

  int daysRemaining(DateTime currentDate) {
    if (!isActive || !currentDate.isBefore(completesAt)) return 0;
    return completesAt.difference(currentDate).inDays;
  }

  StadiumProject copyWith({
    StadiumProjectStatus? status,
    DateTime? completesAt,
  }) =>
      StadiumProject(
        id: id,
        kind: kind,
        targetLevel: targetLevel,
        cost: cost,
        startedAt: startedAt,
        completesAt: completesAt ?? this.completesAt,
        status: status ?? this.status,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'targetLevel': targetLevel,
        'cost': cost,
        'startedAt': startedAt.toIso8601String(),
        'completesAt': completesAt.toIso8601String(),
        'status': status.name,
      };

  factory StadiumProject.fromJson(Map<String, dynamic> json) => StadiumProject(
        id: json['id'] as String? ?? '',
        kind: StadiumProjectKind.values.firstWhere(
          (value) => value.name == json['kind'],
          orElse: () => StadiumProjectKind.stands,
        ),
        targetLevel: json['targetLevel'] as int? ?? 1,
        cost: json['cost'] as int? ?? 0,
        startedAt: DateTime.tryParse(json['startedAt'] as String? ?? '') ??
            DateTime(2000),
        completesAt: DateTime.tryParse(json['completesAt'] as String? ?? '') ??
            DateTime(2000),
        status: StadiumProjectStatus.values.firstWhere(
          (value) => value.name == json['status'],
          orElse: () => StadiumProjectStatus.completed,
        ),
      );
}

class Stadium {
  const Stadium({
    required this.name,
    required this.capacity,
    required this.ticketPrice,
    this.baseName,
    this.standsLevel = 1,
    this.hospitalityLevel = 1,
    this.retailLevel = 1,
    this.foodLevel = 1,
    this.advertisingLevel = 1,
    this.parkingLevel = 0,
    this.museumLevel = 0,
    this.pitchCondition = 88,
    this.structureCondition = 85,
    this.securityCondition = 90,
    this.comfortCondition = 86,
    this.trainingCenterLevel = 1,
    this.projects = const [],
  });

  final String name;
  final int capacity;
  final int ticketPrice;
  final String? baseName;
  final int standsLevel;

  /// Níveis comerciais persistidos no próprio estádio. São intencadamente
  /// simples para permitir expansão posterior sem criar um segundo modelo.
  final int hospitalityLevel;
  final int retailLevel;
  final int foodLevel;
  final int advertisingLevel;
  final int parkingLevel;
  final int museumLevel;

  /// Condição persistente das quatro áreas exibidas no painel de manutenção.
  /// Os valores variam de 0 a 100 e sofrem desgaste gradual no avanço de dias.
  final int pitchCondition;
  final int structureCondition;
  final int securityCondition;
  final int comfortCondition;

  /// Centro de treinamento é uma infraestrutura própria, mas fica persistido
  /// junto ao estádio para manter retrocompatibilidade simples dos saves.
  final int trainingCenterLevel;

  /// Histórico de obras. Obras em andamento só aplicam o nível quando chegam
  /// à data de conclusão; concluídas permanecem no histórico da carreira.
  final List<StadiumProject> projects;

  String get originalName => baseName?.trim().isNotEmpty == true
      ? baseName!.trim()
      : name;

  int get commercialLevel =>
      hospitalityLevel +
      retailLevel +
      foodLevel +
      advertisingLevel +
      parkingLevel +
      museumLevel;

  Stadium copyWith({
    String? name,
    int? capacity,
    int? ticketPrice,
    String? baseName,
    int? standsLevel,
    int? hospitalityLevel,
    int? retailLevel,
    int? foodLevel,
    int? advertisingLevel,
    int? parkingLevel,
    int? museumLevel,
    int? pitchCondition,
    int? structureCondition,
    int? securityCondition,
    int? comfortCondition,
    int? trainingCenterLevel,
    List<StadiumProject>? projects,
  }) =>
      Stadium(
        name: name ?? this.name,
        capacity: capacity ?? this.capacity,
        ticketPrice: ticketPrice ?? this.ticketPrice,
        baseName: baseName ?? name ?? this.baseName,
        standsLevel: standsLevel ?? this.standsLevel,
        hospitalityLevel: hospitalityLevel ?? this.hospitalityLevel,
        retailLevel: retailLevel ?? this.retailLevel,
        foodLevel: foodLevel ?? this.foodLevel,
        advertisingLevel: advertisingLevel ?? this.advertisingLevel,
        parkingLevel: parkingLevel ?? this.parkingLevel,
        museumLevel: museumLevel ?? this.museumLevel,
        pitchCondition: pitchCondition ?? this.pitchCondition,
        structureCondition: structureCondition ?? this.structureCondition,
        securityCondition: securityCondition ?? this.securityCondition,
        comfortCondition: comfortCondition ?? this.comfortCondition,
        trainingCenterLevel: trainingCenterLevel ?? this.trainingCenterLevel,
        projects: projects ?? this.projects,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'capacity': capacity,
        'ticketPrice': ticketPrice,
        'baseName': originalName,
        'standsLevel': standsLevel,
        'hospitalityLevel': hospitalityLevel,
        'retailLevel': retailLevel,
        'foodLevel': foodLevel,
        'advertisingLevel': advertisingLevel,
        'parkingLevel': parkingLevel,
        'museumLevel': museumLevel,
        'pitchCondition': pitchCondition,
        'structureCondition': structureCondition,
        'securityCondition': securityCondition,
        'comfortCondition': comfortCondition,
        'trainingCenterLevel': trainingCenterLevel,
        'projects': projects.map((project) => project.toJson()).toList(),
      };

  factory Stadium.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? 'Estádio';
    final rawProjects = json['projects'];
    final projects = rawProjects is List
        ? rawProjects
            .whereType<Map>()
            .map(
              (project) => StadiumProject.fromJson(
                Map<String, dynamic>.from(project),
              ),
            )
            .toList(growable: false)
        : const <StadiumProject>[];
    return Stadium(
      name: name,
      capacity: json['capacity'] as int? ?? 25000,
      ticketPrice: json['ticketPrice'] as int? ?? 50,
      baseName: json['baseName'] as String? ?? name,
      standsLevel: json['standsLevel'] as int? ?? 1,
      hospitalityLevel: json['hospitalityLevel'] as int? ?? 1,
      retailLevel: json['retailLevel'] as int? ?? 1,
      foodLevel: json['foodLevel'] as int? ?? 1,
      advertisingLevel: json['advertisingLevel'] as int? ?? 1,
      parkingLevel: json['parkingLevel'] as int? ?? 0,
      museumLevel: json['museumLevel'] as int? ?? 0,
      pitchCondition: (json['pitchCondition'] as int? ?? 88).clamp(0, 100).toInt(),
      structureCondition:
          (json['structureCondition'] as int? ?? 85).clamp(0, 100).toInt(),
      securityCondition:
          (json['securityCondition'] as int? ?? 90).clamp(0, 100).toInt(),
      comfortCondition:
          (json['comfortCondition'] as int? ?? 86).clamp(0, 100).toInt(),
      trainingCenterLevel:
          (json['trainingCenterLevel'] as int? ?? 1).clamp(1, 5).toInt(),
      projects: projects,
    );
  }
}

class Club {
  const Club({
    required this.id,
    required this.name,
    required this.shortName,
    required this.nickname,
    required this.colors,
    required this.reputation,
    required this.money,
    required this.transferBudget,
    required this.stadium,
    required this.managerName,
    required this.fanBase,
    required this.squad,
    this.iconBase64,
    this.homeKit = const ClubKit(
      primaryHex: 0xFF1E7A2B,
      secondaryHex: 0xFFFFFFFF,
      shortsHex: 0xFF1E7A2B,
      socksHex: 0xFFFFFFFF,
    ),
    this.awayKit = const ClubKit(
      primaryHex: 0xFFFFFFFF,
      secondaryHex: 0xFF1E7A2B,
      shortsHex: 0xFFFFFFFF,
      socksHex: 0xFFFFFFFF,
    ),
    this.thirdKit = const ClubKit(
      primaryHex: 0xFF202020,
      secondaryHex: 0xFFFFFFFF,
      shortsHex: 0xFF202020,
      socksHex: 0xFF202020,
    ),
    this.recentForm = const [],
    this.sponsorships = const [],
  });

  final String id;
  final String name;
  final String shortName;
  final String nickname;
  final ClubColors colors;
  final String? iconBase64;
  final ClubKit homeKit;
  final ClubKit awayKit;
  final ClubKit thirdKit;
  final int reputation;
  final int money;
  final int transferBudget;
  final Stadium stadium;
  final String managerName;
  final double fanBase;
  final List<Player> squad;
  final List<String> recentForm;
  final List<SponsorshipContract> sponsorships;

  int get payroll => squad.fold(0, (sum, player) => sum + player.salary);
  double get averageOverall => squad.isEmpty ? 0 : squad.fold<int>(0, (sum, p) => sum + p.overall) / squad.length;

  Club copyWith({
    String? id,
    String? name,
    String? shortName,
    String? nickname,
    ClubColors? colors,
    String? iconBase64,
    bool clearIcon = false,
    ClubKit? homeKit,
    ClubKit? awayKit,
    ClubKit? thirdKit,
    int? reputation,
    int? money,
    int? transferBudget,
    Stadium? stadium,
    String? managerName,
    double? fanBase,
    List<Player>? squad,
    List<String>? recentForm,
    List<SponsorshipContract>? sponsorships,
  }) =>
      Club(
        id: id ?? this.id,
        name: name ?? this.name,
        shortName: shortName ?? this.shortName,
        nickname: nickname ?? this.nickname,
        colors: colors ?? this.colors,
        iconBase64: clearIcon ? null : (iconBase64 ?? this.iconBase64),
        homeKit: homeKit ?? this.homeKit,
        awayKit: awayKit ?? this.awayKit,
        thirdKit: thirdKit ?? this.thirdKit,
        reputation: reputation ?? this.reputation,
        money: money ?? this.money,
        transferBudget: transferBudget ?? this.transferBudget,
        stadium: stadium ?? this.stadium,
        managerName: managerName ?? this.managerName,
        fanBase: fanBase ?? this.fanBase,
        squad: squad ?? this.squad,
        recentForm: recentForm ?? this.recentForm,
        sponsorships: sponsorships ?? this.sponsorships,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'shortName': shortName,
        'nickname': nickname,
        'colors': colors.toJson(),
        if (iconBase64?.isNotEmpty == true) 'iconBase64': iconBase64,
        'homeKit': homeKit.toJson(),
        'awayKit': awayKit.toJson(),
        'thirdKit': thirdKit.toJson(),
        'reputation': reputation,
        'money': money,
        'transferBudget': transferBudget,
        'stadium': stadium.toJson(),
        'managerName': managerName,
        'fanBase': fanBase,
        'squad': squad.map((e) => e.toJson()).toList(),
        'recentForm': recentForm,
        'sponsorships': sponsorships.map((e) => e.toJson()).toList(),
      };

  factory Club.fromJson(Map<String, dynamic> json) {
    final colors = ClubColors.fromJson(Map<String, dynamic>.from(json['colors'] as Map? ?? const {}));
    final fallbackHome = ClubKit(
      primaryHex: colors.primaryHex,
      secondaryHex: colors.secondaryHex,
      accentHex: colors.secondaryHex,
      shortsHex: colors.primaryHex,
      socksHex: colors.secondaryHex,
    );
    final fallbackAway = ClubKit(
      primaryHex: colors.secondaryHex,
      secondaryHex: colors.primaryHex,
      accentHex: colors.primaryHex,
      shortsHex: colors.secondaryHex,
      socksHex: colors.secondaryHex,
    );
    return Club(
      id: json['id'] as String,
      name: json['name'] as String,
      shortName: json['shortName'] as String? ?? json['name'] as String,
      nickname: json['nickname'] as String? ?? json['name'] as String,
      colors: colors,
      iconBase64: json['iconBase64'] as String?,
      homeKit: ClubKit.fromJson(Map<String, dynamic>.from(json['homeKit'] as Map? ?? const {}), fallback: fallbackHome),
      awayKit: ClubKit.fromJson(Map<String, dynamic>.from(json['awayKit'] as Map? ?? const {}), fallback: fallbackAway),
      thirdKit: ClubKit.fromJson(
        Map<String, dynamic>.from(json['thirdKit'] as Map? ?? const {}),
        fallback: const ClubKit(
          primaryHex: 0xFF202020,
          secondaryHex: 0xFFFFFFFF,
          shortsHex: 0xFF202020,
          socksHex: 0xFF202020,
        ),
      ),
      reputation: json['reputation'] as int? ?? 70,
      money: json['money'] as int? ?? 0,
      transferBudget: json['transferBudget'] as int? ?? 0,
      stadium: Stadium.fromJson(Map<String, dynamic>.from(json['stadium'] as Map? ?? const {})),
      managerName: json['managerName'] as String? ?? 'Técnico',
      fanBase: (json['fanBase'] as num?)?.toDouble() ?? 0.5,
      squad: ((json['squad'] as List?) ?? const [])
          .map((e) => Player.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      recentForm: ((json['recentForm'] as List?) ?? const []).map((e) => e.toString()).toList(),
      sponsorships: ((json['sponsorships'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => SponsorshipContract.fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false),
    );
  }
}
