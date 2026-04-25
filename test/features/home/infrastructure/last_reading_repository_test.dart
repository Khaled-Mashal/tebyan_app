import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tebyan_app/features/home/domain/last_reading_entry.dart';
import 'package:tebyan_app/features/home/infrastructure/last_reading_repository.dart';
import 'package:tebyan_app/features/quran/domain/quran_position.dart';
import 'package:tebyan_app/shared/errors/result.dart';

import '../../../shared/persistence/test_database_factory.dart';

void main() {
  sqfliteFfiInit();

  group('SqliteLastReadingRepository', () {
    late Database database;
    late LastReadingRepository repository;

    setUp(() async {
      database = await TestRaqeemDatabaseFactory(
        databaseFactoryFfi,
      ).openInMemory();
      repository = SqliteLastReadingRepository(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('inserts a reading entry and returns newest first', () async {
      final older = readingEntry(
        id: 'older',
        page: 1,
        savedAt: DateTime.utc(2026, 4, 25, 9),
      );
      final newer = readingEntry(
        id: 'newer',
        page: 2,
        savedAt: DateTime.utc(2026, 4, 25, 10),
      );

      await repository.saveEntry(older);
      await repository.saveEntry(newer);

      final entries = successValue(await repository.recentEntries());

      expect(entries.map((entry) => entry.id), <String>['newer', 'older']);
    });

    test(
      'deduplicates the same surah ayah and page by updating savedAt',
      () async {
        final first = readingEntry(
          id: 'first',
          page: 42,
          savedAt: DateTime.utc(2026, 4, 25, 9),
        );
        final duplicate = readingEntry(
          id: 'second',
          page: 42,
          savedAt: DateTime.utc(2026, 4, 25, 11),
          source: LastReadingSource.search,
        );

        await repository.saveEntry(first);
        await repository.saveEntry(duplicate);

        final entries = successValue(await repository.recentEntries());

        expect(entries, hasLength(1));
        expect(entries.single.id, 'second');
        expect(entries.single.source, LastReadingSource.search);
        expect(entries.single.savedAt, DateTime.utc(2026, 4, 25, 11));
      },
    );

    test('trims history to the newest five entries', () async {
      for (var page = 1; page <= 7; page += 1) {
        await repository.saveEntry(
          readingEntry(
            id: 'page-$page',
            page: page,
            savedAt: DateTime.utc(2026, 4, 25, page),
          ),
        );
      }

      final entries = successValue(await repository.recentEntries());

      expect(entries, hasLength(5));
      expect(entries.map((entry) => entry.id), <String>[
        'page-7',
        'page-6',
        'page-5',
        'page-4',
        'page-3',
      ]);
    });

    test(
      'returns the newest entry as the dashboard continue position',
      () async {
        await repository.saveEntry(
          readingEntry(
            id: 'older',
            page: 10,
            savedAt: DateTime.utc(2026, 4, 25, 9),
          ),
        );
        await repository.saveEntry(
          readingEntry(
            id: 'newest',
            page: 12,
            savedAt: DateTime.utc(2026, 4, 25, 13),
          ),
        );

        final latest = successValue(await repository.latestEntry());

        expect(latest?.id, 'newest');
        expect(latest?.position.page, 12);
      },
    );
  });
}

LastReadingEntry readingEntry({
  required String id,
  required int page,
  required DateTime savedAt,
  LastReadingSource source = LastReadingSource.reader,
}) {
  return LastReadingEntry(
    id: id,
    position: QuranPosition(
      surahNumber: 2,
      ayahNumber: page,
      page: page,
      displaySurahName: 'Al-Baqarah',
      displayAyahLabel: '2:$page',
    ),
    source: source,
    savedAt: savedAt,
    displayTitle: 'Al-Baqarah',
    displaySubtitle: '2:$page',
  );
}

T successValue<T>(Result<T> result) {
  return switch (result) {
    Success<T>(:final value) => value,
    Failure<T>(:final error) => fail('Expected success, got $error'),
  };
}
