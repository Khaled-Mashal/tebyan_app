import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tebyan_app/features/bookmarks/domain/bookmark_annotation.dart';
import 'package:tebyan_app/features/bookmarks/infrastructure/bookmark_repository.dart';
import 'package:tebyan_app/features/quran/domain/quran_position.dart';
import 'package:tebyan_app/shared/errors/result.dart';

import '../../../shared/persistence/test_database_factory.dart';

void main() {
  sqfliteFfiInit();

  group('SqliteBookmarkRepository', () {
    late Database database;
    late SqliteBookmarkRepository repository;

    setUp(() async {
      database = await TestRaqeemDatabaseFactory(
        databaseFactoryFfi,
      ).openInMemory();
      repository = SqliteBookmarkRepository(database);
    });

    tearDown(() async {
      await database.close();
    });

    group('create', () {
      test('creates a bookmark annotation and retrieves it', () async {
        final annotation = _fatihahBookmark();
        final created = successValue(await repository.create(annotation));

        expect(created.id, annotation.id);
        expect(created.position.surahNumber, 1);
        expect(created.position.page, 1);

        final found = successValue(await repository.findById(annotation.id));
        expect(found, isNotNull);
        expect(found!.id, annotation.id);
        expect(found.position.displaySurahName, 'الفاتحة');
      });

      test('creates multiple annotations with different types', () async {
        final bookmark = _fatihahBookmark();
        final note = _baqarahNote();

        await repository.create(bookmark);
        await repository.create(note);

        final all = successValue(await repository.list());
        expect(all, hasLength(2));
      });
    });

    group('update', () {
      test('updates an existing bookmark annotation', () async {
        final original = _fatihahBookmark();
        await repository.create(original);

        final updated = original.copyWith(
          note: 'ملاحظة محدثة',
          type: BookmarkType.note,
          color: BookmarkColor.green,
          updatedAt: DateTime.utc(2026, 4, 26),
        );
        final result = successValue(await repository.update(updated));

        expect(result.note, 'ملاحظة محدثة');
        expect(result.type, BookmarkType.note);
        expect(result.color, BookmarkColor.green);

        final found = successValue(await repository.findById(original.id));
        expect(found!.note, 'ملاحظة محدثة');
        expect(found.type, BookmarkType.note);
      });
    });

    group('archive', () {
      test('archives a bookmark so it is excluded from default list', () async {
        final annotation = _fatihahBookmark();
        await repository.create(annotation);

        successValue(await repository.archive(annotation.id));

        final active = successValue(await repository.list());
        expect(active, isEmpty);

        final found = successValue(await repository.findById(annotation.id));
        expect(found, isNotNull);
        expect(found!.isArchived, isTrue);
      });

      test('includes archived bookmarks when requested', () async {
        final annotation = _fatihahBookmark();
        await repository.create(annotation);
        successValue(await repository.archive(annotation.id));

        final all = successValue(await repository.list(includeArchived: true));

        expect(all, hasLength(1));
        expect(all.single.isArchived, isTrue);
      });
    });

    group('delete', () {
      test('deletes a bookmark permanently', () async {
        final annotation = _fatihahBookmark();
        await repository.create(annotation);

        successValue(await repository.delete(annotation.id));

        final found = successValue(await repository.findById(annotation.id));
        expect(found, isNull);
      });

      test('delete removes bookmark from list results', () async {
        final a = _fatihahBookmark();
        final b = _baqarahNote();
        await repository.create(a);
        await repository.create(b);

        successValue(await repository.delete(a.id));

        final remaining = successValue(await repository.list());
        expect(remaining, hasLength(1));
        expect(remaining.single.id, b.id);
      });
    });

    group('sort', () {
      test('lists bookmarks sorted by updated_at descending', () async {
        final older = _annotation(
          id: 'older',
          surahNumber: 1,
          ayahNumber: 1,
          page: 1,
          updatedAt: DateTime.utc(2026, 4, 24),
        );
        final newer = _annotation(
          id: 'newer',
          surahNumber: 2,
          ayahNumber: 1,
          page: 2,
          updatedAt: DateTime.utc(2026, 4, 26),
        );

        await repository.create(older);
        await repository.create(newer);

        final list = successValue(await repository.list());

        expect(list.first.id, 'newer');
        expect(list.last.id, 'older');
      });
    });

    group('anchor mapping', () {
      test('stores and retrieves quran_library_bookmark_id', () async {
        final annotation = _fatihahBookmark().copyWith(
          quranLibraryBookmarkId: 42,
        );
        await repository.create(annotation);

        final found = successValue(await repository.findById(annotation.id));

        expect(found!.quranLibraryBookmarkId, 42);
      });

      test('stores null quran_library_bookmark_id when not set', () async {
        final annotation = _fatihahBookmark();
        await repository.create(annotation);

        final found = successValue(await repository.findById(annotation.id));

        expect(found!.quranLibraryBookmarkId, isNull);
      });
    });

    group('search fields', () {
      test('searches bookmarks by note content', () async {
        await repository.create(_fatihahBookmark(note: 'تأمل في الفاتحة'));
        await repository.create(_baqarahNote());

        final results = successValue(
          await repository.list(searchQuery: 'الفاتحة'),
        );

        expect(results, hasLength(1));
        expect(results.single.note, contains('الفاتحة'));
      });

      test('searches bookmarks by surah display name', () async {
        await repository.create(_fatihahBookmark());
        await repository.create(_baqarahNote());

        final results = successValue(
          await repository.list(searchQuery: 'البقرة'),
        );

        expect(results, hasLength(1));
        expect(results.single.position.displaySurahName, contains('البقرة'));
      });

      test('returns empty list when search has no matches', () async {
        await repository.create(_fatihahBookmark());

        final results = successValue(await repository.list(searchQuery: 'يس'));

        expect(results, isEmpty);
      });
    });

    group('findById', () {
      test('returns null when bookmark id does not exist', () async {
        final found = successValue(await repository.findById('missing'));

        expect(found, isNull);
      });
    });
  });
}

BookmarkAnnotation _fatihahBookmark({String? note}) {
  return BookmarkAnnotation(
    id: 'bm-fatihah-1',
    position: QuranPosition(
      surahNumber: 1,
      ayahNumber: 1,
      ayahUniqueNumber: 1,
      page: 1,
      juz: 1,
      hizb: 1,
      rub: 1,
      displaySurahName: 'الفاتحة',
      displayAyahLabel: 'الفاتحة ١',
    ),
    type: BookmarkType.bookmark,
    note: note,
    color: BookmarkColor.gold,
    createdAt: DateTime.utc(2026, 4, 25),
    updatedAt: DateTime.utc(2026, 4, 25),
  );
}

BookmarkAnnotation _baqarahNote() {
  return BookmarkAnnotation(
    id: 'bm-baqarah-255',
    position: QuranPosition(
      surahNumber: 2,
      ayahNumber: 255,
      ayahUniqueNumber: 397,
      page: 23,
      juz: 3,
      hizb: 5,
      rub: 9,
      displaySurahName: 'البقرة',
      displayAyahLabel: 'البقرة ٢٥٥',
    ),
    type: BookmarkType.note,
    note: 'آية الكرسي',
    color: BookmarkColor.green,
    createdAt: DateTime.utc(2026, 4, 25, 10),
    updatedAt: DateTime.utc(2026, 4, 25, 10),
  );
}

BookmarkAnnotation _annotation({
  required String id,
  required int surahNumber,
  required int ayahNumber,
  required int page,
  required DateTime updatedAt,
}) {
  return BookmarkAnnotation(
    id: id,
    position: QuranPosition(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      page: page,
      displaySurahName: 'سورة $surahNumber',
      displayAyahLabel: '$surahNumber:$ayahNumber',
    ),
    createdAt: updatedAt,
    updatedAt: updatedAt,
  );
}

T successValue<T>(Result<T> result) {
  return switch (result) {
    Success<T>(:final value) => value,
    Failure<T>(:final error) => fail('Expected success, got $error'),
  };
}
