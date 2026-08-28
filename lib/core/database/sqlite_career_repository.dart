import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../domain/career/career_save_summary.dart';
import '../../domain/career/manager_profile.dart';
import '../../domain/club/club_identity.dart';
import '../../domain/season/career_state.dart';
import '../save/career_repository.dart';

class SqliteCareerRepository implements CareerRepository {
  Database? _database;

  Future<Database> _db() async {
    if (_database != null) return _database!;
    final root = await getDatabasesPath();
    _database = await openDatabase(
      '$root/tatica_manager.db',
      version: 2,
      onCreate: (db, version) async => _createSchema(db),
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) await _migrateV1ToV2(db);
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
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX idx_career_saves_updated_at ON career_saves(updated_at DESC)');
    await db.execute('CREATE TABLE app_meta(key TEXT PRIMARY KEY, value TEXT)');
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
      } catch (_) {
        // Um save legado corrompido não deve impedir a atualização do banco.
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
        'created_at': state.createdAt.millisecondsSinceEpoch,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<CareerSaveSummary>> listSaves() async {
    final rows = await (await _db()).query('career_saves', orderBy: 'updated_at DESC');
    return rows.map((row) => CareerSaveSummary(
          careerId: row['id'] as String,
          careerName: row['career_name'] as String? ?? 'Carreira',
          managerName: row['manager_name'] as String? ?? 'Técnico',
          userClubId: row['user_club_id'] as String? ?? '',
          userClubName: row['user_club_name'] as String? ?? 'Clube',
          season: row['season'] as int? ?? 2026,
          roundIndex: row['round_index'] as int? ?? 0,
          createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int? ?? 0),
          updatedAt: DateTime.fromMillisecondsSinceEpoch(row['updated_at'] as int? ?? 0),
        )).toList();
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
}
