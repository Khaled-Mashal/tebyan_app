import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tebyan_app/features/settings/domain/user_preferences.dart';
import 'package:tebyan_app/features/settings/infrastructure/preferences_repository.dart';
import 'package:tebyan_app/shared/errors/app_error.dart';
import 'package:tebyan_app/shared/errors/result.dart';

import '../../../shared/persistence/test_database_factory.dart';

void main() {
  sqfliteFfiInit();

  group('SqlitePreferencesRepository', () {
    late Database database;
    late PreferencesRepository repository;

    setUp(() async {
      database = await TestRaqeemDatabaseFactory(
        databaseFactoryFfi,
      ).openInMemory();
      repository = SqlitePreferencesRepository(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('returns null when no settings row exists on first launch', () async {
      final loaded = await repository.loadUserPreferences();

      expect(successValue(loaded), isNull);
    });

    test('persists onboarding settings and recovers them exactly', () async {
      final now = DateTime.utc(2026, 4, 25, 9, 30);
      final preferences = UserPreferences.defaults(now: now).copyWith(
        onboardingCompleted: true,
        languageCode: 'en',
        visualMode: RaqeemVisualMode.night,
      );

      expect(
        await repository.saveUserPreferences(preferences),
        isA<Success<void>>(),
      );

      final loaded = successValue(await repository.loadUserPreferences());

      expect(loaded, preferences);
      expect(loaded?.textDirectionName, 'ltr');
    });

    test(
      'updates the single user preferences row instead of duplicating it',
      () async {
        final first = UserPreferences.defaults(
          now: DateTime.utc(2026, 4, 25),
        ).copyWith(languageCode: 'ar');
        final second = first.copyWith(languageCode: 'en');

        await repository.saveUserPreferences(first);
        await repository.saveUserPreferences(second);

        final rows = await database.query('settings');
        final loaded = successValue(await repository.loadUserPreferences());

        expect(rows, hasLength(1));
        expect(rows.single['key'], PreferencesRepository.userPreferencesKey);
        expect(loaded?.languageCode, 'en');
      },
    );

    test('maps corrupt json to a recoverable persistence failure', () async {
      await database.insert('settings', <String, Object?>{
        'key': PreferencesRepository.userPreferencesKey,
        'value_json': '{not valid json',
        'updated_at': DateTime.utc(2026, 4, 25).toIso8601String(),
      });

      final loaded = await repository.loadUserPreferences();
      final error = failureError(loaded);

      expect(error.code, AppErrorCode.persistence);
      expect(error.isRecoverable, isTrue);
    });

    test(
      'maps unknown enum values to a recoverable persistence failure',
      () async {
        final json = UserPreferences.defaults(
          now: DateTime.utc(2026, 4, 25),
        ).toJson();
        json['visualMode'] = 'sepia';

        await database.insert('settings', <String, Object?>{
          'key': PreferencesRepository.userPreferencesKey,
          'value_json': jsonEncode(json),
          'updated_at': DateTime.utc(2026, 4, 25).toIso8601String(),
        });

        final loaded = await repository.loadUserPreferences();
        final error = failureError(loaded);

        expect(error.code, AppErrorCode.persistence);
        expect(error.message, contains('visualMode'));
        expect(error.isRecoverable, isTrue);
      },
    );
  });
}

T successValue<T>(Result<T> result) {
  return switch (result) {
    Success<T>(:final value) => value,
    Failure<T>(:final error) => fail('Expected success, got $error'),
  };
}

AppError failureError<T>(Result<T> result) {
  return switch (result) {
    Success<T>(:final value) => fail('Expected failure, got $value'),
    Failure<T>(:final error) => error,
  };
}
