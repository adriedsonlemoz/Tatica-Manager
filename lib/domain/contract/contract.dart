class PlayerContract {
  const PlayerContract({
    required this.salary,
    required this.endSeason,
  });

  final int salary;
  final int endSeason;

  int seasonsRemaining(int currentSeason) => endSeason - currentSeason;

  Map<String, dynamic> toJson() => {
        'salary': salary,
        'endSeason': endSeason,
      };

  factory PlayerContract.fromJson(Map<String, dynamic> json) => PlayerContract(
        salary: json['salary'] as int? ?? 2000,
        endSeason: json['endSeason'] as int? ?? 2027,
      );

  PlayerContract copyWith({int? salary, int? endSeason}) => PlayerContract(
        salary: salary ?? this.salary,
        endSeason: endSeason ?? this.endSeason,
      );
}
