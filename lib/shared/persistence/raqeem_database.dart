import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'migrations/v1_schema.dart';

class RaqeemDatabase {
  RaqeemDatabase({DatabaseFactory? databaseFactory})
    : _databaseFactory = databaseFactory ?? databaseFactorySqflitePlugin;

  static const fileName = 'raqeem.db';
  static const schemaVersion = 1;

  final DatabaseFactory _databaseFactory;
  Database? _database;

  Future<Database> open() async {
    final existing = _database;
    if (existing != null && existing.isOpen) {
      return existing;
    }

    final databasePath = await _databaseFactory.getDatabasesPath();
    final path = p.join(databasePath, fileName);

    _database = await _databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: schemaVersion,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: (db, version) async {
          await RaqeemV1Schema.create(db);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < schemaVersion) {
            throw StateError(
              'No destructive or implicit upgrade path is defined for '
              'قاعدة بيانات رقيم $oldVersion -> $newVersion.',
            );
          }
        },
      ),
    );

    return _database!;
  }

  Future<void> close() async {
    final existing = _database;
    _database = null;
    if (existing != null && existing.isOpen) {
      await existing.close();
    }
  }
}
