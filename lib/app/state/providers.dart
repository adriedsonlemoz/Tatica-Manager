import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/sqlite_career_repository.dart';
import '../../core/save/career_repository.dart';

final careerRepositoryProvider = Provider<CareerRepository>((ref) => SqliteCareerRepository());
