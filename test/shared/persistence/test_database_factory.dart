import 'package:sqflite/sqflite.dart';
import 'package:tebyan_app/shared/persistence/migrations/v1_schema.dart';
import 'package:tebyan_app/shared/persistence/raqeem_database.dart';

class TestRaqeemDatabaseFactory {
  const TestRaqeemDatabaseFactory(this.databaseFactory);

  final DatabaseFactory databaseFactory;

  RaqeemDatabase createAppDatabase() {
    return RaqeemDatabase(databaseFactory: databaseFactory);
  }

  Future<Database> openInMemory() {
    return databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: RaqeemDatabase.schemaVersion,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: (db, version) => RaqeemV1Schema.create(db),
      ),
    );
  }
}
