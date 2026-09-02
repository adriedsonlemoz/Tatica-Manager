enum BoardObjectiveStatus { onTrack, attention, risk }

class BoardObjective {
  const BoardObjective({
    required this.season,
    required this.clubId,
    required this.targetPosition,
    this.initialConfidence = 70,
    this.currentConfidence = 70,
    this.lastEvaluatedAt,
  });

  final int season;
  final String clubId;
  final int targetPosition;
  final int initialConfidence;
  final int currentConfidence;
  final DateTime? lastEvaluatedAt;

  BoardObjectiveStatus get status => currentConfidence >= 60
      ? BoardObjectiveStatus.onTrack
      : currentConfidence >= 40
          ? BoardObjectiveStatus.attention
          : BoardObjectiveStatus.risk;

  String get targetLabel => targetPosition == 1
      ? 'Disputar o título'
      : 'Terminar entre os $targetPosition primeiros';

  BoardObjective copyWith({
    int? season,
    String? clubId,
    int? targetPosition,
    int? initialConfidence,
    int? currentConfidence,
    DateTime? lastEvaluatedAt,
  }) =>
      BoardObjective(
        season: season ?? this.season,
        clubId: clubId ?? this.clubId,
        targetPosition: targetPosition ?? this.targetPosition,
        initialConfidence: initialConfidence ?? this.initialConfidence,
        currentConfidence: (currentConfidence ?? this.currentConfidence)
            .clamp(0, 100)
            .toInt(),
        lastEvaluatedAt: lastEvaluatedAt ?? this.lastEvaluatedAt,
      );

  Map<String, dynamic> toJson() => {
        'season': season,
        'clubId': clubId,
        'targetPosition': targetPosition,
        'initialConfidence': initialConfidence,
        'currentConfidence': currentConfidence,
        if (lastEvaluatedAt != null)
          'lastEvaluatedAt': lastEvaluatedAt!.toIso8601String(),
      };

  factory BoardObjective.fromJson(Map<String, dynamic> json) {
    int bounded(String key, int fallback, int min, int max) =>
        ((json[key] as num?)?.toInt() ?? fallback).clamp(min, max).toInt();
    return BoardObjective(
      season: (json['season'] as num?)?.toInt() ?? 2026,
      clubId: json['clubId'] as String? ?? '',
      targetPosition: bounded('targetPosition', 10, 1, 99),
      initialConfidence: bounded('initialConfidence', 70, 0, 100),
      currentConfidence: bounded('currentConfidence', 70, 0, 100),
      lastEvaluatedAt: DateTime.tryParse(json['lastEvaluatedAt'] as String? ?? ''),
    );
  }
}
