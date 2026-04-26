import 'package:sqflite/sqflite.dart';

import '../../../shared/errors/app_error.dart';
import '../../../shared/errors/result.dart';
import '../../quran/domain/quran_position.dart';
import '../domain/ayah_share_draft.dart';

abstract interface class AyahShareDraftRepository {
  Future<Result<AyahShareDraft>> save(AyahShareDraft draft);

  Future<Result<AyahShareDraft?>> findById(String id);

  Future<Result<List<AyahShareDraft>>> listForPosition(
    int surahNumber,
    int ayahNumber,
  );

  Future<Result<void>> delete(String id);
}

class SqliteAyahShareDraftRepository implements AyahShareDraftRepository {
  const SqliteAyahShareDraftRepository(this._database);

  final DatabaseExecutor _database;

  @override
  Future<Result<AyahShareDraft>> save(AyahShareDraft draft) {
    return guardResult(
      () async {
        await _database.insert(
          'ayah_share_drafts',
          _toRow(draft),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        return draft;
      },
      code: AppErrorCode.persistence,
      message: 'تعذر حفظ مسودة المشاركة.',
    );
  }

  @override
  Future<Result<AyahShareDraft?>> findById(String id) {
    return guardResult(
      () async {
        final rows = await _database.query(
          'ayah_share_drafts',
          where: 'id = ?',
          whereArgs: <Object?>[id],
          limit: 1,
        );
        return rows.isEmpty ? null : _fromRow(rows.single);
      },
      code: AppErrorCode.persistence,
      message: 'تعذر العثور على مسودة المشاركة.',
    );
  }

  @override
  Future<Result<List<AyahShareDraft>>> listForPosition(
    int surahNumber,
    int ayahNumber,
  ) {
    return guardResult(
      () async {
        final rows = await _database.query(
          'ayah_share_drafts',
          where: 'surah_number = ? AND ayah_number = ?',
          whereArgs: <Object?>[surahNumber, ayahNumber],
          orderBy: 'updated_at DESC',
        );
        return rows.map(_fromRow).toList(growable: false);
      },
      code: AppErrorCode.persistence,
      message: 'تعذر تحميل مسودات المشاركة.',
    );
  }

  @override
  Future<Result<void>> delete(String id) {
    return guardResult(
      () async {
        await _database.delete(
          'ayah_share_drafts',
          where: 'id = ?',
          whereArgs: <Object?>[id],
        );
      },
      code: AppErrorCode.persistence,
      message: 'تعذر حذف مسودة المشاركة.',
    );
  }

  Map<String, Object?> _toRow(AyahShareDraft draft) {
    return <String, Object?>{
      'id': draft.id,
      'surah_number': draft.position.surahNumber,
      'ayah_number': draft.position.ayahNumber,
      'ayah_unique_number': draft.position.ayahUniqueNumber,
      'page': draft.position.page,
      'format': draft.format.name,
      'include_translation': draft.includeTranslation ? 1 : 0,
      'include_tafsir': draft.includeTafsir ? 1 : 0,
      'theme': draft.theme.name,
      'brand_placement': draft.brandPlacement.name,
      'last_generated_path_or_uri': draft.lastGeneratedPathOrUri,
      'created_at': draft.createdAt.toUtc().toIso8601String(),
      'updated_at': draft.updatedAt.toUtc().toIso8601String(),
    };
  }

  QuranPosition _positionFromRow(Map<String, Object?> row) {
    return QuranPosition(
      surahNumber: row['surah_number']! as int,
      ayahNumber: row['ayah_number']! as int,
      ayahUniqueNumber: row['ayah_unique_number'] as int?,
      page: row['page']! as int,
    );
  }

  AyahShareDraft _fromRow(Map<String, Object?> row) {
    return AyahShareDraft(
      id: row['id']! as String,
      position: _positionFromRow(row),
      format: ShareFormat.values.byName(row['format']! as String),
      includeTranslation: (row['include_translation']! as int) == 1,
      includeTafsir: (row['include_tafsir']! as int) == 1,
      theme: ShareTheme.values.byName(row['theme']! as String),
      brandPlacement: BrandPlacement.values.byName(
        row['brand_placement']! as String,
      ),
      lastGeneratedPathOrUri: row['last_generated_path_or_uri'] as String?,
      createdAt: DateTime.parse(row['created_at']! as String),
      updatedAt: DateTime.parse(row['updated_at']! as String),
    );
  }
}
