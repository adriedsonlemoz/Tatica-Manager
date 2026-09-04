import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../domain/career/career_save_summary.dart';
import '../../domain/career/manager_profile.dart';
import '../../domain/club/club.dart';
import '../../domain/club/club_identity.dart';
import '../../domain/reward/reward_models.dart';
import '../../domain/season/career_state.dart';
import '../../game/league/league_engine.dart';
import '../../game/reward/reward_calculator.dart';
import '../save/career_repository.dart';
import '../save/reward_repository.dart';

class SqliteCareerRepository implements CareerRepository, RewardRepository {
  Database? _database;

  Future<Database> _db() async {
    if (_database != null) return _database!;
    final root = await getDatabasesPath();
    _database = await openDatabase(
      '$root/tatica_manager.db',
      version: 5,
      onCreate: (db, version) async => _createSchema(db),
      onUpgrade: (db, oldVersion, newVersion) async {
        var migratedVersion = oldVersion;
        if (migratedVersion < 2) {
          await _migrateV1ToV2(db);
          // A migração V1 recria a tabela já no formato V3.
          migratedVersion = 3;
        }
        if (migratedVersion < 3) {
          await _migrateV2ToV3(db);
          migratedVersion = 3;
        }
        if (migratedVersion < 4) {
          await _migrateV3ToV4(db);
          migratedVersion = 4;
        }
        if (migratedVersion < 5) {
          await _migrateV4ToV5(db);
        }
      },
    );
    return _database!;
  }

  static Future<void> _createSchema(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE career_saves(
        id TEXT PRIMARY KEY,
        career_name TEXT NOT NULL,
        manager_name TEXT NOT NULL,
        user_club_id TEXT NOT NULL,
        user_club_name TEXT NOT NULL,
        season INTEGER NOT NULL,
        round_index INTEGER NOT NULL,
        schema_version INTEGER NOT NULL,
        payload TEXT NOT NULL,
        user_club_short_name TEXT,
        user_club_nickname TEXT,
        user_club_primary_color INTEGER,
        user_club_secondary_color INTEGER,
        user_club_icon TEXT,
        league_position INTEGER,
        next_opponent_name TEXT,
        next_match_date INTEGER,
        next_match_at_home INTEGER,
        total_rounds INTEGER NOT NULL DEFAULT 38,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX idx_career_saves_updated_at ON career_saves(updated_at DESC)');
    await db.execute('CREATE TABLE app_meta(key TEXT PRIMARY KEY, value TEXT)');
    await db.execute('''
      CREATE TABLE career_save_recovery(
        legacy_id TEXT,
        payload TEXT NOT NULL,
        reason TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
    await _createRewardSchema(db);
  }

  static Future<void> _createRewardSchema(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS pm_wallet(
        profile_id TEXT PRIMARY KEY,
        balance INTEGER NOT NULL DEFAULT 0 CHECK(balance >= 0),
        lifetime_earned INTEGER NOT NULL DEFAULT 0 CHECK(lifetime_earned >= 0),
        lifetime_spent INTEGER NOT NULL DEFAULT 0 CHECK(lifetime_spent >= 0),
        updated_at INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS reward_events(
        event_key TEXT PRIMARY KEY,
        event_type TEXT NOT NULL,
        related_id TEXT NOT NULL,
        career_id TEXT,
        processed_at INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS pm_transactions(
        id TEXT PRIMARY KEY,
        origin TEXT NOT NULL,
        amount INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        related_id TEXT NOT NULL,
        career_id TEXT,
        balance_after INTEGER NOT NULL CHECK(balance_after >= 0),
        description TEXT NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_pm_transactions_created_at '
      'ON pm_transactions(created_at DESC)',
    );
    await db.execute('''
      CREATE TABLE IF NOT EXISTS pm_progress(
        profile_id TEXT PRIMARY KEY,
        competitive_matches INTEGER NOT NULL DEFAULT 0 CHECK(competitive_matches >= 0),
        updated_at INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS pm_career_progress(
        career_id TEXT PRIMARY KEY,
        win_streak INTEGER NOT NULL DEFAULT 0 CHECK(win_streak >= 0),
        streak_sequence INTEGER NOT NULL DEFAULT 0 CHECK(streak_sequence >= 0),
        updated_at INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS pm_unlocks(
        item_id TEXT PRIMARY KEY,
        transaction_id TEXT NOT NULL,
        unlocked_at INTEGER NOT NULL
      )
    ''');
  }

  static Future<void> _migrateV4ToV5(Database db) =>
      _createRewardSchema(db);

  static Future<void> _migrateV3ToV4(Database db) => db.execute('''
    CREATE TABLE IF NOT EXISTS career_save_recovery(
      legacy_id TEXT,
      payload TEXT NOT NULL,
      reason TEXT NOT NULL,
      created_at INTEGER NOT NULL
    )
  ''');

  static Future<void> _migrateV2ToV3(Database db) async {
    const columns = <String>[
      'user_club_short_name TEXT',
      'user_club_nickname TEXT',
      'user_club_primary_color INTEGER',
      'user_club_secondary_color INTEGER',
      'user_club_icon TEXT',
      'league_position INTEGER',
      'next_opponent_name TEXT',
      'next_match_date INTEGER',
      'next_match_at_home INTEGER',
      'total_rounds INTEGER NOT NULL DEFAULT 38',
    ];
    for (final definition in columns) {
      await db.execute('ALTER TABLE career_saves ADD COLUMN $definition');
    }

    final rows = await db.query('career_saves', columns: ['id', 'payload']);
    for (final row in rows) {
      final payload = row['payload'] as String?;
      final id = row['id'] as String?;
      if (id == null || payload == null || payload.isEmpty) continue;
      try {
        final career = CareerState.fromJson(
          jsonDecode(payload) as Map<String, dynamic>,
        );
        await db.update(
          'career_saves',
          _summaryValues(career),
          where: 'id = ?',
          whereArgs: [id],
        );
      } catch (_) {
        // Um resumo antigo inválido não deve bloquear a migração. A abertura
        // do save continua validando o payload original normalmente.
      }
    }
  }

  static Future<void> _migrateV1ToV2(Database db) async {
    final legacyRows = await db.query('career_saves');
    await db.execute('ALTER TABLE career_saves RENAME TO career_saves_legacy');
    await _createSchema(db);

    for (final row in legacyRows) {
      final payload = row['payload'] as String?;
      if (payload == null || payload.isEmpty) continue;
      try {
        final decoded = jsonDecode(payload) as Map<String, dynamic>;
        final legacy = CareerState.fromJson(decoded);
        final careerId = 'legacy-${row['id'] ?? 1}-${legacy.userClubId}';
        final migrated = legacy.copyWith(
          schemaVersion: CareerState.currentSchemaVersion,
          careerId: careerId,
          careerName: legacy.careerName.trim().isEmpty ? 'Carreira ${legacy.season}' : legacy.careerName,
          manager: legacy.manager.displayName.trim().isEmpty
              ? const ManagerProfile(displayName: 'Técnico')
              : legacy.manager,
          createdAt: DateTime.fromMillisecondsSinceEpoch(
            row['updated_at'] as int? ?? DateTime.now().millisecondsSinceEpoch,
          ),
        );
        await _insert(db, migrated, updatedAt: row['updated_at'] as int?);
        await db.insert(
          'app_meta',
          {'key': 'last_active_career_id', 'value': careerId},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } catch (error) {
        await db.insert('career_save_recovery', {
          'legacy_id': row['id']?.toString(),
          'payload': payload,
          'reason': 'Migração V1 falhou: $error',
          'created_at': DateTime.now().millisecondsSinceEpoch,
        });
      }
    }

    await db.execute('DROP TABLE career_saves_legacy');
  }

  static Future<void> _insert(
    DatabaseExecutor db,
    CareerState state, {
    int? updatedAt,
  }) async {
    final now = updatedAt ?? DateTime.now().millisecondsSinceEpoch;
    await db.insert(
      'career_saves',
      {
        'id': state.careerId,
        'career_name': state.careerName,
        'manager_name': state.manager.preferredName,
        'user_club_id': state.userClubId,
        'user_club_name': state.userClub.name,
        'season': state.season,
        'round_index': state.roundIndex,
        'schema_version': state.schemaVersion,
        'payload': jsonEncode(state.toJson()),
        ..._summaryValues(state),
        'created_at': state.createdAt.millisecondsSinceEpoch,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<CareerSaveSummary>> listSaves() async {
    final rows = await (await _db()).query(
      'career_saves',
      columns: const [
        'id',
        'career_name',
        'manager_name',
        'user_club_id',
        'user_club_name',
        'season',
        'round_index',
        'user_club_short_name',
        'user_club_nickname',
        'user_club_primary_color',
        'user_club_secondary_color',
        'user_club_icon',
        'league_position',
        'next_opponent_name',
        'next_match_date',
        'next_match_at_home',
        'total_rounds',
        'created_at',
        'updated_at',
      ],
      orderBy: 'updated_at DESC',
    );
    return rows.map(_summaryFromRow).toList(growable: false);
  }

  static Map<String, Object?> _summaryValues(CareerState career) {
    final userClub = career.userClub;
    final standings = LeagueEngine.rebuildStandings(
      career.clubsForPrimaryCompetition(),
      career.primaryCompetitionFixtures,
    );
    final standingIndex = standings.indexWhere(
      (standing) => standing.clubId == career.userClubId,
    );
    final fixture = career.nextUserFixture;
    String? opponentName;
    bool? atHome;
    if (fixture != null) {
      atHome = fixture.homeClubId == career.userClubId;
      final opponentId = atHome ? fixture.awayClubId : fixture.homeClubId;
      for (final club in career.clubs) {
        if (club.id == opponentId) {
          opponentName = club.name;
          break;
        }
      }
    }
    return {
      'user_club_short_name': userClub.shortName,
      'user_club_nickname': userClub.nickname,
      'user_club_primary_color': userClub.colors.primaryHex,
      'user_club_secondary_color': userClub.colors.secondaryHex,
      'user_club_icon': userClub.iconBase64,
      'league_position': standingIndex >= 0 ? standingIndex + 1 : null,
      'next_opponent_name': opponentName,
      'next_match_date': fixture?.date.millisecondsSinceEpoch,
      'next_match_at_home': atHome == null ? null : (atHome ? 1 : 0),
      'total_rounds': career.totalUserRounds,
    };
  }

  static CareerSaveSummary _summaryFromRow(Map<String, Object?> row) {
    final shortName = row['user_club_short_name'] as String?;
    final primaryColor = row['user_club_primary_color'] as int?;
    final secondaryColor = row['user_club_secondary_color'] as int?;
    final visualClub = shortName == null || primaryColor == null || secondaryColor == null
        ? null
        : Club(
            id: row['user_club_id'] as String? ?? '',
            name: row['user_club_name'] as String? ?? 'Clube',
            shortName: shortName,
            nickname: row['user_club_nickname'] as String? ?? shortName,
            colors: ClubColors(
              primaryHex: primaryColor,
              secondaryHex: secondaryColor,
            ),
            iconBase64: row['user_club_icon'] as String?,
            reputation: 0,
            money: 0,
            transferBudget: 0,
            stadium: const Stadium(name: '', capacity: 0, ticketPrice: 0),
            managerName: '',
            fanBase: 0,
            squad: const [],
          );
    final nextMatchTimestamp = row['next_match_date'] as int?;
    final atHomeValue = row['next_match_at_home'] as int?;

    return CareerSaveSummary(
      careerId: row['id'] as String,
      careerName: row['career_name'] as String? ?? 'Carreira',
      managerName: row['manager_name'] as String? ?? 'Técnico',
      userClubId: row['user_club_id'] as String? ?? '',
      userClubName: row['user_club_name'] as String? ?? 'Clube',
      season: row['season'] as int? ?? 2026,
      roundIndex: row['round_index'] as int? ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int? ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(row['updated_at'] as int? ?? 0),
      userClub: visualClub,
      leaguePosition: row['league_position'] as int?,
      nextOpponentName: row['next_opponent_name'] as String?,
      nextMatchDate: nextMatchTimestamp == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(nextMatchTimestamp),
      nextMatchAtHome: atHomeValue == null ? null : atHomeValue == 1,
      totalRounds: row['total_rounds'] as int? ?? 38,
    );
  }

  @override
  Future<CareerState?> load(String careerId) async {
    final rows = await (await _db()).query(
      'career_saves',
      where: 'id = ?',
      whereArgs: [careerId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final payload = rows.first['payload'] as String?;
    if (payload == null || payload.isEmpty) return null;
    return CareerState.fromJson(jsonDecode(payload) as Map<String, dynamic>);
  }

  @override
  Future<void> save(CareerState state) async => _insert(await _db(), state);

  @override
  Future<void> delete(String careerId) async {
    final db = await _db();
    await db.delete('career_saves', where: 'id = ?', whereArgs: [careerId]);
    final active = await loadLastActiveCareerId();
    if (active == careerId) await saveLastActiveCareerId(null);
  }

  @override
  Future<String?> loadLastActiveCareerId() async {
    final rows = await (await _db()).query(
      'app_meta',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: ['last_active_career_id'],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final value = rows.first['value'] as String?;
    return value?.trim().isNotEmpty == true ? value : null;
  }

  @override
  Future<void> saveLastActiveCareerId(String? careerId) async {
    final db = await _db();
    if (careerId == null || careerId.trim().isEmpty) {
      await db.delete('app_meta', where: 'key = ?', whereArgs: ['last_active_career_id']);
      return;
    }
    await db.insert(
      'app_meta',
      {'key': 'last_active_career_id', 'value': careerId},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<ClubIdentityPack?> loadDefaultClubIdentityPack() async {
    final rows = await (await _db()).query(
      'app_meta',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: ['default_club_identity_pack'],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final value = rows.first['value'] as String?;
    if (value == null || value.trim().isEmpty) return null;
    try {
      return ClubIdentityPack.decode(value);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String?> loadAppValue(String key) async {
    final rows = await (await _db()).query(
      'app_meta',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final value = rows.first['value'] as String?;
    return value?.trim().isNotEmpty == true ? value : null;
  }

  @override
  Future<void> saveAppValue(String key, String? value) async {
    final db = await _db();
    if (value == null || value.trim().isEmpty) {
      await db.delete('app_meta', where: 'key = ?', whereArgs: [key]);
      return;
    }
    await db.insert(
      'app_meta',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> saveDefaultClubIdentityPack(ClubIdentityPack? pack) async {
    final db = await _db();
    const key = 'default_club_identity_pack';
    if (pack == null) {
      await db.delete('app_meta', where: 'key = ?', whereArgs: [key]);
      return;
    }
    await db.insert(
      'app_meta',
      {'key': key, 'value': pack.encode()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<RewardSnapshot> loadRewards({int transactionLimit = 100}) async =>
      _readRewardSnapshot(
        await _db(),
        transactionLimit: transactionLimit,
      );

  @override
  Future<RewardCommitResult> finalizeMatch({
    required CareerState nextCareer,
    required MatchRewardRequest request,
  }) async {
    final db = await _db();
    return db.transaction((transaction) async {
      if (await _rewardEventExists(transaction, request.eventKey)) {
        return _duplicateRewardResult(transaction, request.eventKey);
      }
      final snapshot = await _readRewardSnapshot(transaction);
      final mutation = RewardCalculator.forMatch(
        request: request,
        globalProgress: snapshot.progress,
        careerProgress: snapshot.progressForCareer(request.careerId),
        existingTransactionIds: await _transactionIds(transaction),
      );
      return _commitRewardMutation(
        transaction,
        RewardCareerCommit(
          nextCareer: nextCareer,
          eventKey: request.eventKey,
          eventType: 'match',
          relatedId: request.fixtureId,
          mutation: mutation,
        ),
      );
    });
  }

  @override
  Future<RewardCommitResult> finalizeSeason({
    required CareerState nextCareer,
    required SeasonRewardRequest request,
  }) async {
    final db = await _db();
    return db.transaction((transaction) async {
      if (await _rewardEventExists(transaction, request.eventKey)) {
        return _duplicateRewardResult(transaction, request.eventKey);
      }
      final snapshot = await _readRewardSnapshot(transaction);
      final mutation = RewardCalculator.forSeason(
        request: request,
        globalProgress: snapshot.progress,
        existingTransactionIds: await _transactionIds(transaction),
      );
      return _commitRewardMutation(
        transaction,
        RewardCareerCommit(
          nextCareer: nextCareer,
          eventKey: request.eventKey,
          eventType: 'season',
          relatedId: '${request.season}:${request.competitionId}',
          mutation: mutation,
        ),
      );
    });
  }

  static Future<RewardCommitResult> _commitRewardMutation(
    Transaction transaction,
    RewardCareerCommit commit,
  ) async {
    final now = DateTime.now();
    await _insert(transaction, commit.nextCareer);
    await transaction.insert('reward_events', {
      'event_key': commit.eventKey,
      'event_type': commit.eventType,
      'related_id': commit.relatedId,
      'career_id': commit.nextCareer.careerId,
      'processed_at': now.millisecondsSinceEpoch,
    });

    final wallet = await _readWallet(transaction);
    var balance = wallet.balance;
    var earned = wallet.lifetimeEarned;
    var spent = wallet.lifetimeSpent;
    final created = <PmTransaction>[];
    for (final grant in commit.mutation.grants) {
      final nextBalance = balance + grant.amount;
      if (nextBalance < 0) {
        throw StateError('Saldo de PM insuficiente.');
      }
      balance = nextBalance;
      if (grant.amount >= 0) {
        earned += grant.amount;
      } else {
        spent += grant.amount.abs();
      }
      await transaction.insert('pm_transactions', {
        'id': grant.id,
        'origin': grant.origin.name,
        'amount': grant.amount,
        'created_at': now.millisecondsSinceEpoch,
        'related_id': grant.relatedId,
        'career_id': grant.careerId,
        'balance_after': balance,
        'description': grant.description,
      });
      created.add(
        PmTransaction(
          id: grant.id,
          origin: grant.origin,
          amount: grant.amount,
          createdAt: now,
          relatedId: grant.relatedId,
          balanceAfter: balance,
          description: grant.description,
          careerId: grant.careerId,
        ),
      );
    }

    await transaction.insert(
      'pm_wallet',
      {
        'profile_id': 'local-player',
        'balance': balance,
        'lifetime_earned': earned,
        'lifetime_spent': spent,
        'updated_at': now.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await transaction.insert(
      'pm_progress',
      {
        'profile_id': 'local-player',
        'competitive_matches':
            commit.mutation.globalProgress.competitiveMatches,
        'updated_at': now.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    final careerProgress = commit.mutation.careerProgress;
    if (careerProgress != null) {
      await transaction.insert(
        'pm_career_progress',
        {
          'career_id': careerProgress.careerId,
          'win_streak': careerProgress.winStreak,
          'streak_sequence': careerProgress.streakSequence,
          'updated_at': now.millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    final snapshot = await _readRewardSnapshot(transaction);
    return RewardCommitResult(
      snapshot: snapshot,
      receipt: RewardReceipt(
        eventKey: commit.eventKey,
        transactions: created,
        balanceAfter: balance,
      ),
    );
  }

  static Future<RewardCommitResult> _duplicateRewardResult(
    DatabaseExecutor db,
    String eventKey,
  ) async {
    final snapshot = await _readRewardSnapshot(db);
    return RewardCommitResult(
      snapshot: snapshot,
      receipt: RewardReceipt(
        eventKey: eventKey,
        transactions: const [],
        balanceAfter: snapshot.wallet.balance,
        duplicate: true,
      ),
    );
  }

  static Future<bool> _rewardEventExists(
    DatabaseExecutor db,
    String eventKey,
  ) async {
    final rows = await db.query(
      'reward_events',
      columns: const ['event_key'],
      where: 'event_key = ?',
      whereArgs: [eventKey],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  static Future<Set<String>> _transactionIds(DatabaseExecutor db) async {
    final rows = await db.query('pm_transactions', columns: const ['id']);
    return rows.map((row) => row['id'] as String).toSet();
  }

  static Future<RewardWallet> _readWallet(DatabaseExecutor db) async {
    final rows = await db.query(
      'pm_wallet',
      where: 'profile_id = ?',
      whereArgs: const ['local-player'],
      limit: 1,
    );
    if (rows.isEmpty) return const RewardWallet();
    final row = rows.first;
    return RewardWallet(
      balance: row['balance'] as int? ?? 0,
      lifetimeEarned: row['lifetime_earned'] as int? ?? 0,
      lifetimeSpent: row['lifetime_spent'] as int? ?? 0,
    );
  }

  static Future<RewardSnapshot> _readRewardSnapshot(
    DatabaseExecutor db, {
    int transactionLimit = 100,
  }) async {
    final wallet = await _readWallet(db);
    final progressRows = await db.query(
      'pm_progress',
      where: 'profile_id = ?',
      whereArgs: const ['local-player'],
      limit: 1,
    );
    final progress = RewardGlobalProgress(
      competitiveMatches: progressRows.isEmpty
          ? 0
          : progressRows.first['competitive_matches'] as int? ?? 0,
    );
    final careerRows = await db.query('pm_career_progress');
    final careerProgress = <String, RewardCareerProgress>{};
    for (final row in careerRows) {
      final careerId = row['career_id'] as String? ?? '';
      if (careerId.isEmpty) continue;
      careerProgress[careerId] = RewardCareerProgress(
        careerId: careerId,
        winStreak: row['win_streak'] as int? ?? 0,
        streakSequence: row['streak_sequence'] as int? ?? 0,
      );
    }
    final transactionRows = await db.query(
      'pm_transactions',
      orderBy: 'created_at DESC, rowid DESC',
      limit: transactionLimit,
    );
    final transactions = transactionRows.map((row) {
      final originName = row['origin'] as String? ?? '';
      final origin = RewardOrigin.values.firstWhere(
        (item) => item.name == originName,
        orElse: () => RewardOrigin.achievement,
      );
      return PmTransaction(
        id: row['id'] as String? ?? '',
        origin: origin,
        amount: row['amount'] as int? ?? 0,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          row['created_at'] as int? ?? 0,
        ),
        relatedId: row['related_id'] as String? ?? '',
        balanceAfter: row['balance_after'] as int? ?? 0,
        description: row['description'] as String? ?? origin.label,
        careerId: row['career_id'] as String?,
      );
    }).toList(growable: false);
    return RewardSnapshot(
      wallet: wallet,
      progress: progress,
      transactions: transactions,
      careerProgress: careerProgress,
    );
  }
}
