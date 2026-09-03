import '../../../domain/formation/formation.dart';
import '../../../domain/match/match_models.dart';

abstract final class MatchPitchFormation {
  static List<FieldPoint> points(
    FormationType formation, {
    required bool home,
  }) {
    final slots = FormationCatalog.slots[formation] ??
        FormationCatalog.slots[FormationType.f433]!;
    return slots
        .map(
          (slot) => FieldPoint(
            slot.x,
            home ? slot.y : 1 - slot.y,
          ),
        )
        .toList(growable: false);
  }
}
