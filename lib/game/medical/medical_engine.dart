import 'dart:math';

import '../../domain/player/player.dart';

class MedicalAssessment {
  const MedicalAssessment({
    required this.risk,
    required this.severity,
    required this.estimatedDays,
    required this.recoveryProgress,
  });

  final int risk;
  final String severity;
  final int estimatedDays;
  final int recoveryProgress;
}

abstract final class MedicalEngine {
  static MedicalAssessment assess(Player player) {
    final injury = player.injury;
    final risk = reinjuryRisk(player);
    final severity = injury == null
        ? 'Monitorar'
        : injury.roundsRemaining >= 4
            ? 'Grave'
            : injury.roundsRemaining >= 2
                ? 'Moderada'
                : 'Leve';
    final estimatedDays = injury == null ? 0 : max(3, injury.roundsRemaining * 6);
    final progress = injury == null
        ? 100 - risk
        : 100 - injury.roundsRemaining * 18 + (player.condition - 50) ~/ 2;
    return MedicalAssessment(
      risk: risk,
      severity: severity,
      estimatedDays: estimatedDays,
      recoveryProgress: progress.clamp(injury == null ? 0 : 5, injury == null ? 100 : 95).toInt(),
    );
  }

  static int reinjuryRisk(Player player) {
    var risk = player.fatigue * .65 + (100 - player.condition) * .45;
    if (player.injury != null) {
      risk += 28 + player.injury!.roundsRemaining * 5;
    }
    if (player.age >= 31) risk += 6;
    return risk.round().clamp(0, 100).toInt();
  }
}
