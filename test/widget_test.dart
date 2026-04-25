import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tebyan_app/app/app.dart';
import 'package:tebyan_app/features/home/domain/last_reading_entry.dart';
import 'package:tebyan_app/features/home/infrastructure/last_reading_repository.dart';
import 'package:tebyan_app/features/khatma/application/active_khatma_summary.dart';
import 'package:tebyan_app/features/settings/domain/user_preferences.dart';
import 'package:tebyan_app/features/settings/infrastructure/preferences_repository.dart';
import 'package:tebyan_app/shared/errors/result.dart';

void main() {
  testWidgets('Raqeem splash shows app name before routing', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<PreferencesRepository>.value(
            value: _StubPreferencesRepository(),
          ),
          Provider<LastReadingRepository>.value(
            value: _StubLastReadingRepository(),
          ),
          Provider<ActiveKhatmaReader>.value(
            value: const NoopActiveKhatmaReader(),
          ),
        ],
        child: const RaqeemApp(),
      ),
    );

    await tester.pump();

    expect(find.text('رقيم'), findsOneWidget);
  });
}

class _StubPreferencesRepository implements PreferencesRepository {
  @override
  Future<Result<UserPreferences?>> loadUserPreferences() async {
    return Success<UserPreferences?>(
      UserPreferences.defaults(
        now: DateTime.utc(2026, 4, 25),
      ).copyWith(onboardingCompleted: true),
    );
  }

  @override
  Future<Result<void>> saveUserPreferences(UserPreferences preferences) async {
    return const Success<void>(null);
  }
}

class _StubLastReadingRepository implements LastReadingRepository {
  @override
  Future<Result<void>> saveEntry(LastReadingEntry entry) async {
    return const Success<void>(null);
  }

  @override
  Future<Result<List<LastReadingEntry>>> recentEntries() async {
    return const Success<List<LastReadingEntry>>(<LastReadingEntry>[]);
  }

  @override
  Future<Result<LastReadingEntry?>> latestEntry() async {
    return const Success<LastReadingEntry?>(null);
  }
}
