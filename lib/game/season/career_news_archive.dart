import '../../domain/season/career_event.dart';
import '../../domain/season/career_state.dart';

class CareerNewsRetention {
  const CareerNewsRetention({required this.recent, required this.archive});

  final List<CareerEvent> recent;
  final List<CareerEvent> archive;
}

/// Mantém o feed rápido enxuto sem apagar a memória jornalística da carreira.
abstract final class CareerNewsArchive {
  static CareerNewsRetention append({
    required List<CareerEvent> recent,
    required List<CareerEvent> archive,
    required Iterable<CareerEvent> events,
  }) {
    final byId = <String, CareerEvent>{
      for (final event in recent) event.id: event,
      for (final event in events) event.id: event,
    };
    final merged = byId.values.toList(growable: false)
      ..sort((a, b) => a.date.compareTo(b.date));
    final overflow = merged.length <= CareerState.maxStoredNews
        ? const <CareerEvent>[]
        : merged.sublist(0, merged.length - CareerState.maxStoredNews);
    final kept = merged.length <= CareerState.maxStoredNews
        ? merged
        : merged.sublist(merged.length - CareerState.maxStoredNews);
    final archivedById = <String, CareerEvent>{
      for (final event in archive) event.id: event,
      for (final event in overflow) event.id: event,
    };
    final nextArchive = archivedById.values.toList(growable: false)
      ..sort((a, b) => a.date.compareTo(b.date));
    return CareerNewsRetention(
      recent: kept,
      archive: nextArchive.length <= CareerState.maxArchivedNews
          ? nextArchive
          : nextArchive.sublist(nextArchive.length - CareerState.maxArchivedNews),
    );
  }
}
