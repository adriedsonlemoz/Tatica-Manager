import '../../domain/player/player.dart';

abstract final class ClubRatingCalculator {
  static int squadOverall(
    Iterable<Player> players, {
    required int fallback,
  }) {
    final sorted = players.toList()
      ..sort((a, b) => b.overall.compareTo(a.overall));
    if (sorted.isEmpty) return fallback.clamp(1, 99).toInt();

    // Os melhores 18 representam a força geral sem deixar reservas muito jovens
    // distorcerem a leitura do clube na tela de escolha.
    final sample = sorted.take(18).toList(growable: false);
    final total = sample.fold<int>(0, (sum, player) => sum + player.overall);
    return (total / sample.length).round().clamp(1, 99).toInt();
  }

  static double starsForOverall(int overall) {
    if (overall >= 90) return 5;
    if (overall >= 85) return 4.5;
    if (overall >= 80) return 4;
    if (overall >= 75) return 3.5;
    if (overall >= 70) return 3;
    if (overall >= 65) return 2.5;
    if (overall >= 60) return 2;
    if (overall >= 55) return 1.5;
    return 1;
  }
}
