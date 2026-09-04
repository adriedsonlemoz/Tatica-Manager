import '../season/career_state.dart';

enum RewardOrigin {
  matchCompleted,
  matchWin,
  matchDraw,
  winStreak3,
  winStreak5,
  matches10,
  matches25,
  matches50,
  boardObjective,
  seasonCompleted,
  leagueChampion,
  cupChampion,
  promotion,
  achievement,
  purchase,
}

extension RewardOriginX on RewardOrigin {
  String get label => switch (this) {
        RewardOrigin.matchCompleted => 'Partida concluída',
        RewardOrigin.matchWin => 'Vitória',
        RewardOrigin.matchDraw => 'Empate',
        RewardOrigin.winStreak3 => '3 vitórias consecutivas',
        RewardOrigin.winStreak5 => '5 vitórias consecutivas',
        RewardOrigin.matches10 => '10 partidas concluídas',
        RewardOrigin.matches25 => '25 partidas concluídas',
        RewardOrigin.matches50 => '50 partidas concluídas',
        RewardOrigin.boardObjective => 'Objetivo da diretoria',
        RewardOrigin.seasonCompleted => 'Temporada concluída',
        RewardOrigin.leagueChampion => 'Campeão da liga',
        RewardOrigin.cupChampion => 'Campeão de copa',
        RewardOrigin.promotion => 'Subida de divisão',
        RewardOrigin.achievement => 'Conquista especial',
        RewardOrigin.purchase => 'Conteúdo desbloqueado',
      };
}

enum RewardMatchOutcome { win, draw, loss }

enum NonCompetitiveMatchRewardMode { none, baseOnly }

class RewardRules {
  const RewardRules._();

  static const int matchCompleted = 5;
  static const int win = 5;
  static const int draw = 2;
  static const int streak3 = 10;
  static const int streak5 = 20;
  static const Map<int, int> matchMilestones = {
    10: 25,
    25: 60,
    50: 120,
  };
  static const int boardObjective = 50;
  static const int promotion = 100;
  static const int seasonCompleted = 80;
  static const int leagueChampion = 150;
  static const int cupChampion = 120;
  static const int minimumAchievement = 20;
  static const int maximumAchievement = 200;
  static const NonCompetitiveMatchRewardMode nonCompetitiveMatchMode =
      NonCompetitiveMatchRewardMode.none;
}

class RewardWallet {
  const RewardWallet({
    this.balance = 0,
    this.lifetimeEarned = 0,
    this.lifetimeSpent = 0,
  });

  final int balance;
  final int lifetimeEarned;
  final int lifetimeSpent;
}

class RewardGlobalProgress {
  const RewardGlobalProgress({this.competitiveMatches = 0});

  final int competitiveMatches;
}

class RewardCareerProgress {
  const RewardCareerProgress({
    required this.careerId,
    this.winStreak = 0,
    this.streakSequence = 0,
  });

  final String careerId;
  final int winStreak;
  final int streakSequence;

  RewardCareerProgress copyWith({
    int? winStreak,
    int? streakSequence,
  }) =>
      RewardCareerProgress(
        careerId: careerId,
        winStreak: winStreak ?? this.winStreak,
        streakSequence: streakSequence ?? this.streakSequence,
      );
}

class PmTransaction {
  const PmTransaction({
    required this.id,
    required this.origin,
    required this.amount,
    required this.createdAt,
    required this.relatedId,
    required this.balanceAfter,
    required this.description,
    this.careerId,
  });

  final String id;
  final RewardOrigin origin;
  final int amount;
  final DateTime createdAt;
  final String relatedId;
  final int balanceAfter;
  final String description;
  final String? careerId;
}

class RewardSnapshot {
  const RewardSnapshot({
    this.wallet = const RewardWallet(),
    this.progress = const RewardGlobalProgress(),
    this.transactions = const [],
    this.careerProgress = const {},
  });

  final RewardWallet wallet;
  final RewardGlobalProgress progress;
  final List<PmTransaction> transactions;
  final Map<String, RewardCareerProgress> careerProgress;

  RewardCareerProgress progressForCareer(String careerId) =>
      careerProgress[careerId] ?? RewardCareerProgress(careerId: careerId);

  RewardSnapshot copyWith({
    RewardWallet? wallet,
    RewardGlobalProgress? progress,
    List<PmTransaction>? transactions,
    Map<String, RewardCareerProgress>? careerProgress,
  }) =>
      RewardSnapshot(
        wallet: wallet ?? this.wallet,
        progress: progress ?? this.progress,
        transactions: transactions ?? this.transactions,
        careerProgress: careerProgress ?? this.careerProgress,
      );
}

class RewardGrant {
  const RewardGrant({
    required this.id,
    required this.origin,
    required this.amount,
    required this.relatedId,
    required this.description,
    this.careerId,
  });

  final String id;
  final RewardOrigin origin;
  final int amount;
  final String relatedId;
  final String description;
  final String? careerId;
}

class RewardReceipt {
  const RewardReceipt({
    required this.eventKey,
    required this.transactions,
    required this.balanceAfter,
    this.duplicate = false,
  });

  final String eventKey;
  final List<PmTransaction> transactions;
  final int balanceAfter;
  final bool duplicate;

  int get total => transactions.fold(0, (sum, item) => sum + item.amount);
  bool get earned => total > 0 && !duplicate;
}

class RewardCommitResult {
  const RewardCommitResult({
    required this.snapshot,
    required this.receipt,
  });

  final RewardSnapshot snapshot;
  final RewardReceipt receipt;
}

class MatchRewardRequest {
  const MatchRewardRequest({
    required this.careerId,
    required this.fixtureId,
    required this.outcome,
    this.competitive = true,
  });

  final String careerId;
  final String fixtureId;
  final RewardMatchOutcome outcome;
  final bool competitive;

  String get eventKey => 'match:$careerId:$fixtureId';
}

class SeasonRewardRequest {
  const SeasonRewardRequest({
    required this.careerId,
    required this.season,
    required this.competitionId,
    required this.objectiveMet,
    required this.leagueChampion,
  });

  final String careerId;
  final int season;
  final String competitionId;
  final bool objectiveMet;
  final bool leagueChampion;

  String get eventKey => 'season:$careerId:$season';
}

class RewardMutation {
  const RewardMutation({
    required this.grants,
    required this.globalProgress,
    required this.careerProgress,
  });

  final List<RewardGrant> grants;
  final RewardGlobalProgress globalProgress;
  final RewardCareerProgress? careerProgress;
}

class RewardCareerCommit {
  const RewardCareerCommit({
    required this.nextCareer,
    required this.eventKey,
    required this.eventType,
    required this.relatedId,
    required this.mutation,
  });

  final CareerState nextCareer;
  final String eventKey;
  final String eventType;
  final String relatedId;
  final RewardMutation mutation;
}
