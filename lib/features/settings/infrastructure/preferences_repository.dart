import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../../shared/errors/app_error.dart';
import '../../../shared/errors/result.dart';
import '../domain/user_preferences.dart';

abstract interface class PreferencesRepository {
  static const userPreferencesKey = 'user_preferences';

  Future<Result<UserPreferences?>> loadUserPreferences();

  Future<Result<void>> saveUserPreferences(UserPreferences preferences);
}

class SqlitePreferencesRepository implements PreferencesRepository {
  const SqlitePreferencesRepository(this._database);

  final DatabaseExecutor _database;

  @override
  Future<Result<UserPreferences?>> loadUserPreferences() async {
    try {
      final rows = await _database.query(
        'settings',
        columns: const <String>['value_json'],
        where: 'key = ?',
        whereArgs: const <Object?>[PreferencesRepository.userPreferencesKey],
        limit: 1,
      );

      if (rows.isEmpty) {
        return const Success<UserPreferences?>(null);
      }

      final decoded = jsonDecode(rows.single['value_json']! as String);
      return Success<UserPreferences?>(
        UserPreferences.fromJson(Map<String, Object?>.from(decoded)),
      );
    } catch (error, stackTrace) {
      return Failure<UserPreferences?>(
        AppError.fromException(
          error,
          stackTrace,
          code: AppErrorCode.persistence,
          message: 'Unable to load user preferences: $error',
        ),
      );
    }
  }

  @override
  Future<Result<void>> saveUserPreferences(UserPreferences preferences) {
    return guardResult(
      () async {
        await _database.insert('settings', <String, Object?>{
          'key': PreferencesRepository.userPreferencesKey,
          'value_json': jsonEncode(preferences.toJson()),
          'updated_at': preferences.updatedAt.toUtc().toIso8601String(),
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      },
      code: AppErrorCode.persistence,
      message: 'Unable to save user preferences.',
    );
  }
}
