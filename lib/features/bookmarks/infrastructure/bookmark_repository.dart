import 'package:sqflite/sqflite.dart';

import '../../../shared/errors/app_error.dart';
import '../../../shared/errors/result.dart';
import '../../quran/domain/quran_position.dart';
import '../domain/bookmark_annotation.dart';

abstract interface class BookmarkRepository {
  Future<Result<BookmarkAnnotation>> create(BookmarkAnnotation annotation);

  Future<Result<BookmarkAnnotation>> update(BookmarkAnnotation annotation);

  Future<Result<void>> archive(String id);

  Future<Result<void>> delete(String id);

  Future<Result<List<BookmarkAnnotation>>> list({
    bool includeArchived = false,
    String? searchQuery,
  });

  Future<Result<BookmarkAnnotation?>> findById(String id);
}

class SqliteBookmarkRepository implements BookmarkRepository {
  const SqliteBookmarkRepository(this._database);

  final DatabaseExecutor _database;

  @override
  Future<Result<BookmarkAnnotation>> create(BookmarkAnnotation annotation) {
    return guardResult(
      () async {
        await _database.insert('bookmark_annotations', _toRow(annotation));
        return annotation;
      },
      code: AppErrorCode.persistence,
      message: 'تعذر حفظ العلامة.',
    );
  }

  @override
  Future<Result<BookmarkAnnotation>> update(BookmarkAnnotation annotation) {
    return guardResult(
      () async {
        await _database.update(
          'bookmark_annotations',
          _toRow(annotation),
          where: 'id = ?',
          whereArgs: <Object?>[annotation.id],
        );
        return annotation;
      },
      code: AppErrorCode.persistence,
      message: 'تعذر تحديث العلامة.',
    );
  }

  @override
  Future<Result<void>> archive(String id) {
    return guardResult(
      () async {
        await _database.update(
          'bookmark_annotations',
          <String, Object?>{
            'is_archived': 1,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: <Object?>[id],
        );
      },
      code: AppErrorCode.persistence,
      message: 'تعذر أرشفة العلامة.',
    );
  }

  @override
  Future<Result<void>> delete(String id) {
    return guardResult(
      () async {
        await _database.delete(
          'bookmark_annotations',
          where: 'id = ?',
          whereArgs: <Object?>[id],
        );
      },
      code: AppErrorCode.persistence,
      message: 'تعذر حذف العلامة.',
    );
  }

  @override
  Future<Result<List<BookmarkAnnotation>>> list({
    bool includeArchived = false,
    String? searchQuery,
  }) {
    return guardResult(
      () async {
        String? where;
        List<Object?>? whereArgs;

        if (!includeArchived) {
          where = 'is_archived = 0';
        }

        if (searchQuery != null && searchQuery.isNotEmpty) {
          final searchClause = '(note LIKE ? OR display_surah_name LIKE ?)';
          final pattern = '%$searchQuery%';
          if (where == null) {
            where = searchClause;
            whereArgs = <Object?>[pattern, pattern];
          } else {
            where = '$where AND $searchClause';
            whereArgs = <Object?>[pattern, pattern];
          }
        }

        final rows = await _database.query(
          'bookmark_annotations',
          where: where,
          whereArgs: whereArgs,
          orderBy: 'updated_at DESC',
        );
        return rows.map(_fromRow).toList(growable: false);
      },
      code: AppErrorCode.persistence,
      message: 'تعذر تحميل العلامات.',
    );
  }

  @override
  Future<Result<BookmarkAnnotation?>> findById(String id) {
    return guardResult(
      () async {
        final rows = await _database.query(
          'bookmark_annotations',
          where: 'id = ?',
          whereArgs: <Object?>[id],
          limit: 1,
        );
        return rows.isEmpty ? null : _fromRow(rows.single);
      },
      code: AppErrorCode.persistence,
      message: 'تعذر العثور على العلامة.',
    );
  }

  Map<String, Object?> _toRow(BookmarkAnnotation annotation) {
    return <String, Object?>{
      'id': annotation.id,
      'quran_library_bookmark_id': annotation.quranLibraryBookmarkId,
      'surah_number': annotation.position.surahNumber,
      'ayah_number': annotation.position.ayahNumber,
      'ayah_unique_number': annotation.position.ayahUniqueNumber,
      'page': annotation.position.page,
      'juz': annotation.position.juz,
      'hizb': annotation.position.hizb,
      'rub': annotation.position.rub,
      'display_surah_name': annotation.position.displaySurahName,
      'display_ayah_label': annotation.position.displayAyahLabel,
      'type': annotation.type.name,
      'note': annotation.note,
      'color': annotation.color.name,
      'is_archived': annotation.isArchived ? 1 : 0,
      'created_at': annotation.createdAt.toUtc().toIso8601String(),
      'updated_at': annotation.updatedAt.toUtc().toIso8601String(),
      'last_opened_at': annotation.lastOpenedAt?.toUtc().toIso8601String(),
    };
  }

  BookmarkAnnotation _fromRow(Map<String, Object?> row) {
    return BookmarkAnnotation(
      id: row['id']! as String,
      quranLibraryBookmarkId: row['quran_library_bookmark_id'] as int?,
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
      type: BookmarkType.values.byName(row['type']! as String),
      note: row['note'] as String?,
      color: BookmarkColor.values.byName(row['color']! as String),
      isArchived: (row['is_archived']! as int) == 1,
      createdAt: DateTime.parse(row['created_at']! as String).toUtc(),
      updatedAt: DateTime.parse(row['updated_at']! as String).toUtc(),
      lastOpenedAt: row['last_opened_at'] != null
          ? DateTime.parse(row['last_opened_at']! as String).toUtc()
          : null,
    );
  }
}
