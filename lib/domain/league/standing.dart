class Standing {
  const Standing({
    required this.clubId,
    required this.clubName,
    this.played = 0,
    this.wins = 0,
    this.draws = 0,
    this.losses = 0,
    this.goalsFor = 0,
    this.goalsAgainst = 0,
    this.points = 0,
  });

  final String clubId;
  final String clubName;
  final int played;
  final int wins;
  final int draws;
  final int losses;
  final int goalsFor;
  final int goalsAgainst;
  final int points;

  int get goalDifference => goalsFor - goalsAgainst;

  Standing copyWith({
    int? played,
    int? wins,
    int? draws,
    int? losses,
    int? goalsFor,
    int? goalsAgainst,
    int? points,
  }) =>
      Standing(
        clubId: clubId,
        clubName: clubName,
        played: played ?? this.played,
        wins: wins ?? this.wins,
        draws: draws ?? this.draws,
        losses: losses ?? this.losses,
        goalsFor: goalsFor ?? this.goalsFor,
        goalsAgainst: goalsAgainst ?? this.goalsAgainst,
        points: points ?? this.points,
      );

  Map<String, dynamic> toJson() => {
        'clubId': clubId,
        'clubName': clubName,
        'played': played,
        'wins': wins,
        'draws': draws,
        'losses': losses,
        'goalsFor': goalsFor,
        'goalsAgainst': goalsAgainst,
        'points': points,
      };

  factory Standing.fromJson(Map<String, dynamic> json) => Standing(
        clubId: json['clubId'] as String,
        clubName: json['clubName'] as String,
        played: json['played'] as int? ?? 0,
        wins: json['wins'] as int? ?? 0,
        draws: json['draws'] as int? ?? 0,
        losses: json['losses'] as int? ?? 0,
        goalsFor: json['goalsFor'] as int? ?? 0,
        goalsAgainst: json['goalsAgainst'] as int? ?? 0,
        points: json['points'] as int? ?? 0,
      );
}
