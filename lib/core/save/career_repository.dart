import '../../domain/career/career_save_summary.dart';
import '../../domain/club/club_identity.dart';
import '../../domain/season/career_state.dart';

abstract interface class CareerRepository {
  Future<List<CareerSaveSummary>> listSaves();
  Future<CareerState?> load(String careerId);
  Future<void> save(CareerState state);
  Future<void> delete(String careerId);
  Future<String?> loadLastActiveCareerId();
  Future<void> saveLastActiveCareerId(String? careerId);
  Future<ClubIdentityPack?> loadDefaultClubIdentityPack();
  Future<void> saveDefaultClubIdentityPack(ClubIdentityPack? pack);
}
