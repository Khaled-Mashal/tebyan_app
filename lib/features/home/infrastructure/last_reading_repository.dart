import 'package:sqflite/sqflite.dart';

import '../../../shared/errors/app_error.dart';
import '../../../shared/errors/result.dart';
import '../../quran/domain/quran_position.dart';
import '../domain/last_reading_entry.dart';

abstract interface class LastReadingRepository {
  Future<Result<void>> saveEntry(LastReadingEntry entry);

  Future<Result<List<LastReadingEntry>>> recentEntries();

  Future<Result<LastReadingEntry?>> latestEntry();
}

class SqliteLastReadingRepository implements LastReadingRepository {
  const SqliteLastReadingRepository(this._database);

  static const _maxEntries = 5;

  final DatabaseExecutor _database;

  @override
  Future<Result<void>> saveEntry(LastReadingEntry entry) {
    return guardResult(
      () async {
        final db = _database;
        if (db is Database) {
          await db.transaction((txn) => _saveEntry(txn, entry));
        } else {
          await _saveEntry(db, entry);
        }
      },
      code: AppErrorCode.persistence,
      message: 'Unable to save latest reading position.',
    );
  }

  @override
  Future<Result<List<LastReadingEntry>>> recentEntries() {
    return guardResult(
      () async {
        final rows = await _database.query(
          'last_reading_entries',
          orderBy: 'saved_at DESC',
          limit: _maxEntries,
        );
        return rows.map(_entryFromRow).toList(growable: false);
      },
      code: AppErrorCode.persistence,
      message: 'Unable to load recent reading positions.',
    );
  }

  @override
  Future<Result<LastReadingEntry?>> latestEntry() {
    return guardResult(
      () async {
        final rows = await _database.query(
          'last_reading_entries',
          orderBy: 'saved_at DESC',
          limit: 1,
        );
        return rows.isEmpty ? null : _entryFromRow(rows.single);
      },
      code: AppErrorCode.persistence,
      message: 'Unable to load latest reading position.',
    );
  }

  Future<void> _saveEntry(DatabaseExecutor db, LastReadingEntry entry) async {
    await db.delete(
      'last_reading_entries',
      where: 'surah_number = ? AND ayah_number = ? AND page = ?',
      whereArgs: <Object?>[
        entry.position.surahNumber,
        entry.position.ayahNumber,
        entry.position.page,
      ],
    );
    await db.insert('last_reading_entries', _entryToRow(entry));

    final overflowRows = await db.query(
      'last_reading_entries',
      columns: const <String>['id'],
      orderBy: 'saved_at DESC',
      limit: 1000,
      offset: _maxEntries,
    );
    for (final row in overflowRows) {
      await db.delete(
        'last_reading_entries',
        where: 'id = ?',
        whereArgs: <Object?>[row['id']],
      );
    }
  }

  Map<String, Object?> _entryToRow(LastReadingEntry entry) {
    final position = entry.position;
    return <String, Object?>{
      'id': entry.id,
      'surah_number': position.surahNumber,
      'ayah_number': position.ayahNumber,
      'ayah_unique_number': position.ayahUniqueNumber,
      'page': position.page,
      'juz': position.juz,
      'hizb': position.hizb,
      'rub': position.rub,
      'display_surah_name': position.displaySurahName,
      'display_ayah_label': position.displayAyahLabel,
      'source': entry.source.name,
      'saved_at': entry.savedAt.toUtc().toIso8601String(),
    };
  }

  LastReadingEntry _entryFromRow(Map<String, Object?> row) {
    return LastReadingEntry(
      id: row['id']! as String,
      position: QuranPosition(
        surahNumber: row['surah_number']! as int,
        ayahNumber: row['ayah_number']! as int,
        ayahUniqueNumber: row['ayah_unique_number'] as int?,
        page: row['page']! as int,
        juz: row['juz'] as int?,
        hizb: row['hizb'] as int?,
        rub: row['rub'] as int?,
        displaySurahName: row['display_surah_name']! as String,
        displayAyahLabel: row['display_ayah_label']! as String,
      ),
      source: LastReadingSource.values.byName(row['source']! as String),
      savedAt: DateTime.parse(row['saved_at']! as String).toUtc(),
      displayTitle: row['display_surah_name']! as String,
      displaySubtitle: row['display_ayah_label']! as String,
    );
  }
}
