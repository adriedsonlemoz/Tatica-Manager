import 'dart:math';

import '../../domain/club/club.dart';

class StadiumMatchdayRevenue {
  const StadiumMatchdayRevenue({
    required this.attendance,
    required this.ticketing,
    required this.hospitality,
    required this.retail,
    required this.food,
    required this.advertising,
    required this.parking,
    required this.museum,
  });

  final int attendance;
  final int ticketing;
  final int hospitality;
  final int retail;
  final int food;
  final int advertising;
  final int parking;
  final int museum;

  int get commercial =>
      hospitality + retail + food + advertising + parking + museum;
  int get total => ticketing + commercial;
}

enum StadiumFacility {
  stands,
  hospitality,
  retail,
  food,
  advertising,
  parking,
  museum,
}

extension StadiumFacilityX on StadiumFacility {
  String get label => switch (this) {
        StadiumFacility.stands => 'Arquibancadas',
        StadiumFacility.hospitality => 'Camarotes e hospitalidade',
        StadiumFacility.retail => 'Lojas e produtos oficiais',
        StadiumFacility.food => 'Alimentação',
        StadiumFacility.advertising => 'Publicidade',
        StadiumFacility.parking => 'Estacionamento',
        StadiumFacility.museum => 'Museu do clube',
      };

  String get description => switch (this) {
        StadiumFacility.stands => 'Amplia a capacidade e o potencial de bilheteria.',
        StadiumFacility.hospitality => 'Aumenta a receita dos setores premium.',
        StadiumFacility.retail => 'Melhora as vendas de produtos oficiais.',
        StadiumFacility.food => 'Expande os pontos de alimentação internos.',
        StadiumFacility.advertising => 'Valoriza placas, painéis e espaços comerciais.',
        StadiumFacility.parking => 'Nova área paga vinculada ao público da partida.',
        StadiumFacility.museum => 'Nova atração que gera receita em dias de jogo.',
      };
}


extension StadiumProjectKindX on StadiumProjectKind {
  String get label => switch (this) {
        StadiumProjectKind.stands => 'Arquibancadas',
        StadiumProjectKind.hospitality => 'Camarotes e hospitalidade',
        StadiumProjectKind.retail => 'Lojas e produtos oficiais',
        StadiumProjectKind.food => 'Alimentação',
        StadiumProjectKind.advertising => 'Publicidade',
        StadiumProjectKind.parking => 'Estacionamento',
        StadiumProjectKind.museum => 'Museu do clube',
        StadiumProjectKind.trainingCenter => 'Centro de treinamento',
      };
}

abstract final class StadiumEngine {
  static const int maxFacilityLevel = 5;

  static double ticketDemandFactor({
    required Club club,
    int? ticketPrice,
  }) {
    final price = ticketPrice ?? club.stadium.ticketPrice;
    final referencePrice = 34 + club.reputation * .46;
    final ratio = referencePrice <= 0 ? 1.0 : price / referencePrice;
    return (1.14 - (ratio - .72) * .48).clamp(.52, 1.14).toDouble();
  }

  static int attendanceFor({
    required Club club,
    required int tablePosition,
  }) {
    final performanceFactor =
        (1.08 - (tablePosition - 1) * .012).clamp(.82, 1.08).toDouble();
    final demand = (.34 + club.fanBase * .58).clamp(.35, .96).toDouble();
    final priceFactor = ticketDemandFactor(club: club);
    return min(
      club.stadium.capacity,
      (club.stadium.capacity * demand * performanceFactor * priceFactor)
          .round(),
    );
  }

  static String supporterImpact({
    required Club club,
    required int attendance,
  }) {
    final occupancy = club.stadium.capacity <= 0
        ? 0.0
        : attendance / club.stadium.capacity;
    final priceFactor = ticketDemandFactor(club: club);
    if (priceFactor >= 1.02 && occupancy >= .72) return 'Positivo';
    if (priceFactor < .82 || occupancy < .48) return 'Negativo';
    return 'Neutro';
  }

  static StadiumMatchdayRevenue settleMatchday({
    required Club club,
    required int tablePosition,
  }) {
    final stadium = club.stadium;
    final attendance = attendanceFor(
      club: club,
      tablePosition: tablePosition,
    );
    final occupancy = stadium.capacity <= 0
        ? 0.0
        : (attendance / stadium.capacity).clamp(0.0, 1.0).toDouble();
    final ticketing = attendance * stadium.ticketPrice;

    final hospitalitySeats = max(
      80,
      (stadium.capacity * (.008 + stadium.hospitalityLevel * .004)).round(),
    );
    final hospitality = ((hospitalitySeats * occupancy).round() *
            max(60, stadium.ticketPrice * 3 + stadium.hospitalityLevel * 18))
        .toInt();
    final retail =
        (attendance * (.70 + stadium.retailLevel * .42)).round();
    final food = (attendance * (1.15 + stadium.foodLevel * .58)).round();
    final advertising = 18000 +
        (stadium.capacity * .72).round() +
        stadium.advertisingLevel * 22000;
    final parking = stadium.parkingLevel <= 0
        ? 0
        : (attendance * (.12 + stadium.parkingLevel * .17)).round();
    final museum = stadium.museumLevel <= 0
        ? 0
        : (attendance * (.08 + stadium.museumLevel * .13)).round();

    return StadiumMatchdayRevenue(
      attendance: attendance,
      ticketing: ticketing,
      hospitality: hospitality,
      retail: retail,
      food: food,
      advertising: advertising,
      parking: parking,
      museum: museum,
    );
  }

  static int projectedCommercialRevenue({
    required Club club,
    int tablePosition = 10,
  }) =>
      settleMatchday(club: club, tablePosition: tablePosition).commercial;

  static int operatingCost(Stadium stadium) =>
      150000 + stadium.capacity * 5 + stadium.commercialLevel * 12000;

  static int facilityLevel(Stadium stadium, StadiumFacility facility) =>
      switch (facility) {
        StadiumFacility.stands => stadium.standsLevel,
        StadiumFacility.hospitality => stadium.hospitalityLevel,
        StadiumFacility.retail => stadium.retailLevel,
        StadiumFacility.food => stadium.foodLevel,
        StadiumFacility.advertising => stadium.advertisingLevel,
        StadiumFacility.parking => stadium.parkingLevel,
        StadiumFacility.museum => stadium.museumLevel,
      };

  static bool isLocked(Stadium stadium, StadiumFacility facility) =>
      (facility == StadiumFacility.parking ||
          facility == StadiumFacility.museum) &&
      facilityLevel(stadium, facility) == 0;

  static int upgradeCost(Stadium stadium, StadiumFacility facility) {
    final nextLevel = facilityLevel(stadium, facility) + 1;
    if (nextLevel > maxFacilityLevel) return 0;
    final base = switch (facility) {
      StadiumFacility.stands => 1800000 + stadium.capacity * 34,
      StadiumFacility.hospitality => 980000,
      StadiumFacility.retail => 650000,
      StadiumFacility.food => 520000,
      StadiumFacility.advertising => 580000,
      StadiumFacility.parking => 1250000,
      StadiumFacility.museum => 1650000,
    };
    return (base * (1 + (nextLevel - 1) * .48)).round();
  }

  static int negotiatedUpgradeCost({
    required Club club,
    required StadiumFacility facility,
  }) {
    final cost = upgradeCost(club.stadium, facility);
    if (cost <= 0) return 0;
    final level = facilityLevel(club.stadium, facility);
    final discount = (.035 + club.reputation / 1800 + level * .004)
        .clamp(.04, .10)
        .toDouble();
    return (cost * (1 - discount)).round();
  }

  static Stadium upgrade(Stadium stadium, StadiumFacility facility) {
    final current = facilityLevel(stadium, facility);
    if (current >= maxFacilityLevel) {
      throw StateError('${facility.label} já está no nível máximo.');
    }
    final next = current + 1;
    return switch (facility) {
      StadiumFacility.stands => stadium.copyWith(
          capacity: stadium.capacity + max(2000, (stadium.capacity * .06).round()),
          standsLevel: next,
        ),
      StadiumFacility.hospitality =>
        stadium.copyWith(hospitalityLevel: next),
      StadiumFacility.retail => stadium.copyWith(retailLevel: next),
      StadiumFacility.food => stadium.copyWith(foodLevel: next),
      StadiumFacility.advertising =>
        stadium.copyWith(advertisingLevel: next),
      StadiumFacility.parking => stadium.copyWith(parkingLevel: next),
      StadiumFacility.museum => stadium.copyWith(museumLevel: next),
    };
  }

  static StadiumProjectKind projectKindForFacility(
    StadiumFacility facility,
  ) =>
      StadiumProjectKind.values.firstWhere(
        (kind) => kind.name == facility.name,
      );

  static StadiumFacility? facilityForProject(StadiumProjectKind kind) {
    if (kind == StadiumProjectKind.trainingCenter) return null;
    return StadiumFacility.values.firstWhere(
      (facility) => facility.name == kind.name,
    );
  }

  static int projectDurationDays(StadiumProjectKind kind) => switch (kind) {
        StadiumProjectKind.stands => 120,
        StadiumProjectKind.hospitality => 75,
        StadiumProjectKind.retail => 60,
        StadiumProjectKind.food => 45,
        StadiumProjectKind.advertising => 40,
        StadiumProjectKind.parking => 90,
        StadiumProjectKind.museum => 120,
        StadiumProjectKind.trainingCenter => 100,
      };

  static bool hasActiveProject(Stadium stadium, StadiumProjectKind kind) =>
      stadium.projects.any(
        (project) => project.kind == kind && project.isActive,
      );

  static int maintenanceScore(Stadium stadium) =>
      ((stadium.pitchCondition +
                  stadium.structureCondition +
                  stadium.securityCondition +
                  stadium.comfortCondition) /
              4)
          .round();

  static String conditionLabel(int score) {
    if (score >= 90) return 'Excelente';
    if (score >= 82) return 'Muito Boa';
    if (score >= 72) return 'Boa';
    if (score >= 60) return 'Regular';
    return 'Ruim';
  }

  static int maintenanceCost(Stadium stadium) {
    final deficit = max(
      0,
      400 -
          stadium.pitchCondition -
          stadium.structureCondition -
          stadium.securityCondition -
          stadium.comfortCondition,
    );
    return 90000 + stadium.capacity * 2 + deficit * 2500;
  }

  static Stadium performMaintenance(Stadium stadium) => stadium.copyWith(
        pitchCondition: 100,
        structureCondition: 100,
        securityCondition: 100,
        comfortCondition: 100,
      );

  static int trainingCenterQuality(Stadium stadium) =>
      (70 + stadium.trainingCenterLevel * 6).clamp(0, 100).toInt();

  static String trainingCenterLabel(Stadium stadium) {
    final level = stadium.trainingCenterLevel;
    if (level >= 5) return 'Excelente';
    if (level == 4) return 'Muito Bom';
    if (level == 3) return 'Bom';
    if (level == 2) return 'Regular';
    return 'Básico';
  }

  static int trainingCenterUpgradeCost(Stadium stadium) {
    final nextLevel = stadium.trainingCenterLevel + 1;
    if (nextLevel > maxFacilityLevel) return 0;
    return (1050000 * (1 + (nextLevel - 1) * .55)).round();
  }

  static Stadium startFacilityProject({
    required Stadium stadium,
    required StadiumFacility facility,
    required int cost,
    required DateTime startedAt,
  }) {
    final kind = projectKindForFacility(facility);
    if (hasActiveProject(stadium, kind)) {
      throw StateError('Já existe uma obra de ${facility.label} em andamento.');
    }
    final targetLevel = facilityLevel(stadium, facility) + 1;
    if (targetLevel > maxFacilityLevel) {
      throw StateError('${facility.label} já está no nível máximo.');
    }
    final duration = projectDurationDays(kind);
    final project = StadiumProject(
      id: 'stadium-${startedAt.millisecondsSinceEpoch}-${kind.name}-$targetLevel',
      kind: kind,
      targetLevel: targetLevel,
      cost: cost,
      startedAt: startedAt,
      completesAt: startedAt.add(Duration(days: duration)),
    );
    return stadium.copyWith(projects: [...stadium.projects, project]);
  }

  static Stadium startTrainingCenterProject({
    required Stadium stadium,
    required int cost,
    required DateTime startedAt,
  }) {
    const kind = StadiumProjectKind.trainingCenter;
    if (hasActiveProject(stadium, kind)) {
      throw StateError('Já existe uma obra do centro de treinamento em andamento.');
    }
    final targetLevel = stadium.trainingCenterLevel + 1;
    if (targetLevel > maxFacilityLevel) {
      throw StateError('O centro de treinamento já está no nível máximo.');
    }
    final project = StadiumProject(
      id: 'stadium-${startedAt.millisecondsSinceEpoch}-${kind.name}-$targetLevel',
      kind: kind,
      targetLevel: targetLevel,
      cost: cost,
      startedAt: startedAt,
      completesAt: startedAt.add(
        Duration(days: projectDurationDays(kind)),
      ),
    );
    return stadium.copyWith(projects: [...stadium.projects, project]);
  }

  static Stadium advanceDay({
    required Stadium stadium,
    required DateTime currentDate,
  }) {
    var next = stadium;
    final updatedProjects = <StadiumProject>[];
    for (final project in stadium.projects) {
      if (project.isActive && !currentDate.isBefore(project.completesAt)) {
        next = _completeProject(next, project);
        updatedProjects.add(
          project.copyWith(status: StadiumProjectStatus.completed),
        );
      } else {
        updatedProjects.add(project);
      }
    }
    next = next.copyWith(projects: updatedProjects);

    final dayOfYear = currentDate
            .difference(DateTime(currentDate.year, 1, 1))
            .inDays +
        1;
    return next.copyWith(
      pitchCondition: max(
        0,
        next.pitchCondition - (dayOfYear % 7 == 0 ? 1 : 0),
      ),
      structureCondition: max(
        0,
        next.structureCondition - (dayOfYear % 14 == 0 ? 1 : 0),
      ),
      securityCondition: max(
        0,
        next.securityCondition - (dayOfYear % 10 == 0 ? 1 : 0),
      ),
      comfortCondition: max(
        0,
        next.comfortCondition - (dayOfYear % 8 == 0 ? 1 : 0),
      ),
    );
  }

  static Stadium _completeProject(
    Stadium stadium,
    StadiumProject project,
  ) {
    if (project.kind == StadiumProjectKind.trainingCenter) {
      if (stadium.trainingCenterLevel >= project.targetLevel) return stadium;
      return stadium.copyWith(trainingCenterLevel: project.targetLevel);
    }
    final facility = facilityForProject(project.kind);
    if (facility == null) return stadium;
    if (facilityLevel(stadium, facility) >= project.targetLevel) return stadium;
    return upgrade(stadium, facility);
  }

  static Stadium updateProfile({
    required Stadium stadium,
    required String baseName,
    required int ticketPrice,
    String? namingSponsor,
  }) {
    final cleanName = baseName.trim();
    if (cleanName.length < 3 || cleanName.length > 48) {
      throw StateError('O nome do estádio deve ter entre 3 e 48 caracteres.');
    }
    if (ticketPrice < 10 || ticketPrice > 500) {
      throw StateError('O ingresso deve ficar entre R\$ 10 e R\$ 500.');
    }
    final visibleName = namingSponsor?.trim().isNotEmpty == true
        ? namingRightsName(namingSponsor!, cleanName)
        : cleanName;
    return stadium.copyWith(
      name: visibleName,
      baseName: cleanName,
      ticketPrice: ticketPrice,
    );
  }

  static Stadium applyNamingRights(Stadium stadium, String sponsorName) =>
      stadium.copyWith(
        name: namingRightsName(sponsorName, stadium.originalName),
        baseName: stadium.originalName,
      );

  static Stadium restoreOriginalName(Stadium stadium) => stadium.copyWith(
        name: stadium.originalName,
        baseName: stadium.originalName,
      );

  static String namingRightsName(String sponsorName, String baseName) {
    final combined = '${sponsorName.trim()} • $baseName';
    return combined.length <= 60 ? combined : '${sponsorName.trim()} Arena';
  }
}
