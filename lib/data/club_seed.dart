import '../domain/club/club.dart';
import '../domain/club/club_identity.dart';

class ClubSeed {
  const ClubSeed({
    required this.id,
    required this.name,
    required this.nickname,
    required this.shortName,
    required this.reputation,
    required this.money,
    required this.budget,
    required this.fanBase,
    required this.primaryColor,
    required this.secondaryColor,
    required this.stadium,
    required this.capacity,
  });

  final String id;
  final String name;
  final String nickname;
  final String shortName;
  final int reputation;
  final int money;
  final int budget;
  final double fanBase;
  final int primaryColor;
  final int secondaryColor;
  final String stadium;
  final int capacity;

  ClubIdentity get identity => ClubIdentity(
        clubId: id,
        name: name,
        nickname: nickname,
        shortName: shortName,
      );

  Club toClub() => Club(
        id: id,
        name: name,
        nickname: nickname,
        shortName: shortName,
        colors: ClubColors(primaryHex: primaryColor, secondaryHex: secondaryColor),
        homeKit: ClubKit(
          primaryHex: primaryColor,
          secondaryHex: secondaryColor,
          accentHex: secondaryColor,
          shortsHex: primaryColor,
          socksHex: secondaryColor,
        ),
        awayKit: ClubKit(
          primaryHex: secondaryColor,
          secondaryHex: primaryColor,
          accentHex: primaryColor,
          shortsHex: secondaryColor,
          socksHex: secondaryColor,
        ),
        thirdKit: ClubKit(
          primaryHex: 0xFF202020,
          secondaryHex: primaryColor,
          accentHex: secondaryColor,
          shortsHex: 0xFF202020,
          socksHex: 0xFF202020,
        ),
        reputation: reputation,
        money: money,
        transferBudget: budget,
        stadium: Stadium(name: stadium, capacity: capacity, ticketPrice: 50),
        managerName: 'Técnico CPU',
        fanBase: fanBase,
        squad: const [],
      );
}

const clubSeeds2026 = <ClubSeed>[
  ClubSeed(id: 'br-club-001', name: 'Capital Paulista FC', nickname: 'Capital', shortName: 'CPT', reputation: 87, money: 157000000, budget: 125000000, fanBase: 1.00, primaryColor: 0xFFB5121B, secondaryColor: 0xFF252525, stadium: 'Estádio da Capital', capacity: 78838),
  ClubSeed(id: 'br-club-002', name: 'Rio Imperial EC', nickname: 'Imperial', shortName: 'IMP', reputation: 86, money: 146000000, budget: 116000000, fanBase: .92, primaryColor: 0xFF124E78, secondaryColor: 0xFFF4C95D, stadium: 'Arena Imperial', capacity: 43713),
  ClubSeed(id: 'br-club-003', name: 'Vale Bandeirante AC', nickname: 'Bandeirante', shortName: 'VBA', reputation: 84, money: 126000000, budget: 100000000, fanBase: .82, primaryColor: 0xFF244AA5, secondaryColor: 0xFFFFFFFF, stadium: 'Arena Vale Dourado', capacity: 61846),
  ClubSeed(id: 'br-club-004', name: 'União Carioca FC', nickname: 'União Carioca', shortName: 'UCR', reputation: 79, money: 73000000, budget: 58000000, fanBase: .50, primaryColor: 0xFFF5D323, secondaryColor: 0xFF1D7B3E, stadium: 'Estádio da União', capacity: 15000),
  ClubSeed(id: 'br-club-005', name: 'Mantiqueira Atlético', nickname: 'Mantiqueira', shortName: 'MNT', reputation: 82, money: 104000000, budget: 83000000, fanBase: .72, primaryColor: 0xFF7A1538, secondaryColor: 0xFF0B6B4F, stadium: 'Arena da Serra', capacity: 78838),
  ClubSeed(id: 'br-club-006', name: 'Porto Dourado EC', nickname: 'Dourado', shortName: 'PDO', reputation: 81, money: 94000000, budget: 75000000, fanBase: .70, primaryColor: 0xFF1451A3, secondaryColor: 0xFFE6B325, stadium: 'Estádio Porto Dourado', capacity: 47907),
  ClubSeed(id: 'br-club-007', name: 'Estrela Mineira FC', nickname: 'Estrela Mineira', shortName: 'EMI', reputation: 83, money: 115000000, budget: 92000000, fanBase: .78, primaryColor: 0xFF2C2C2C, secondaryColor: 0xFFE9E9E9, stadium: 'Arena das Minas', capacity: 46831),
  ClubSeed(id: 'br-club-008', name: 'Nacional do Cerrado', nickname: 'Cerrado', shortName: 'NCR', reputation: 82, money: 104000000, budget: 83000000, fanBase: .88, primaryColor: 0xFFF2F2F2, secondaryColor: 0xFFD64545, stadium: 'Estádio Central do Cerrado', capacity: 72000),
  ClubSeed(id: 'br-club-009', name: 'Guanabara Real FC', nickname: 'Guanabara', shortName: 'GNR', reputation: 79, money: 73000000, budget: 58000000, fanBase: .55, primaryColor: 0xFFF0F0F0, secondaryColor: 0xFFE35D6A, stadium: 'Arena Guanabara', capacity: 17000),
  ClubSeed(id: 'br-club-010', name: 'Aurora Paulista EC', nickname: 'Aurora', shortName: 'AUR', reputation: 81, money: 94000000, budget: 75000000, fanBase: .95, primaryColor: 0xFF353535, secondaryColor: 0xFFEAEAEA, stadium: 'Estádio Aurora', capacity: 47605),
  ClubSeed(id: 'br-club-011', name: 'Esportivo Sulano', nickname: 'Sulano', shortName: 'ESU', reputation: 80, money: 84000000, budget: 67000000, fanBase: .82, primaryColor: 0xFF21A4DF, secondaryColor: 0xFF23313F, stadium: 'Arena Sulana', capacity: 55000),
  ClubSeed(id: 'br-club-012', name: 'Metropolitano Cearense FC', nickname: 'Metrô Cearense', shortName: 'MCE', reputation: 79, money: 73000000, budget: 58000000, fanBase: .78, primaryColor: 0xFF202020, secondaryColor: 0xFFE6E6E6, stadium: 'Estádio Metropolitano', capacity: 21880),
  ClubSeed(id: 'br-club-013', name: 'Recife União FC', nickname: 'União Recife', shortName: 'RUF', reputation: 83, money: 115000000, budget: 92000000, fanBase: .85, primaryColor: 0xFF282828, secondaryColor: 0xFFF0C85A, stadium: 'Arena do Recife', capacity: 46000),
  ClubSeed(id: 'br-club-014', name: 'Salvador Imperial FC', nickname: 'Imperial Baiano', shortName: 'SIF', reputation: 79, money: 73000000, budget: 58000000, fanBase: .76, primaryColor: 0xFFF7F7F7, secondaryColor: 0xFF2C426B, stadium: 'Estádio da Baía', capacity: 16068),
  ClubSeed(id: 'br-club-015', name: 'Clube do Planalto', nickname: 'Planalto', shortName: 'PLA', reputation: 76, money: 42000000, budget: 33000000, fanBase: .62, primaryColor: 0xFFC74C4C, secondaryColor: 0xFF303030, stadium: 'Arena Planalto', capacity: 30000),
  ClubSeed(id: 'br-club-016', name: 'Serra Gaúcha EC', nickname: 'Serra Gaúcha', shortName: 'SGA', reputation: 81, money: 94000000, budget: 75000000, fanBase: .80, primaryColor: 0xFFC94A56, secondaryColor: 0xFFF4F4F4, stadium: 'Estádio das Serras', capacity: 50128),
  ClubSeed(id: 'br-club-017', name: 'Curitiba Central FC', nickname: 'Central', shortName: 'CTC', reputation: 74, money: 31000000, budget: 24000000, fanBase: .60, primaryColor: 0xFF277A50, secondaryColor: 0xFFEFEFEF, stadium: 'Arena Central', capacity: 32000),
  ClubSeed(id: 'br-club-018', name: 'Litoral Santista AC', nickname: 'Litoral', shortName: 'LSA', reputation: 80, money: 84000000, budget: 67000000, fanBase: .68, primaryColor: 0xFFD75A4A, secondaryColor: 0xFF252525, stadium: 'Estádio do Litoral', capacity: 32000),
  ClubSeed(id: 'br-club-019', name: 'Atlético Nordeste FC', nickname: 'Nordeste', shortName: 'ANE', reputation: 73, money: 25000000, budget: 19000000, fanBase: .52, primaryColor: 0xFF2C8A5E, secondaryColor: 0xFFF1F1F1, stadium: 'Arena Nordeste', capacity: 22600),
  ClubSeed(id: 'br-club-020', name: 'União das Araucárias', nickname: 'Araucárias', shortName: 'UAR', reputation: 72, money: 22000000, budget: 17000000, fanBase: .60, primaryColor: 0xFF314A78, secondaryColor: 0xFFF2F2F2, stadium: 'Estádio das Araucárias', capacity: 17000),
];

const clubSeeds = clubSeeds2026;
