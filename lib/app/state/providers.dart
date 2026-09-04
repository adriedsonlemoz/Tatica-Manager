import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/sqlite_career_repository.dart';
import '../../core/save/career_repository.dart';
import '../../core/save/reward_repository.dart';

final careerRepositoryProvider = Provider<CareerRepository>((ref) => SqliteCareerRepository());

final rewardRepositoryProvider = Provider<RewardRepository>((ref) {
  final careers = ref.watch(careerRepositoryProvider);
  if (careers is RewardRepository) return careers as RewardRepository;
  return MemoryRewardRepository(careers);
});
