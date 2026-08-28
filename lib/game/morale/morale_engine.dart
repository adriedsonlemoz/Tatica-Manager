import '../../domain/club/club.dart';

abstract final class MoraleEngine {
  static int teamMorale(Club club) {
    if (club.recentForm.isEmpty) return 60;
    final lastFive = club.recentForm.take(5).toList();
    final points = lastFive.fold<int>(0, (sum, result) => sum + ((result == 'W' || result == 'V') ? 3 : (result == 'D' || result == 'E') ? 1 : 0));
    final maxPoints = lastFive.length * 3;
    return (40 + (points / maxPoints) * 60).round().clamp(10, 100).toInt();
  }

  static int moraleFromRecentForm(List<String> form) {
    if (form.isEmpty) return 60;
    final lastFive = form.take(5).toList();
    final points = lastFive.fold<int>(0, (sum, result) => sum + ((result == 'W' || result == 'V') ? 3 : (result == 'D' || result == 'E') ? 1 : 0));
    return (40 + (points / (lastFive.length * 3)) * 60).round().clamp(10, 100).toInt();
  }

  static List<String> addResult(List<String> form, String result) => [result, ...form].take(5).toList();
}
