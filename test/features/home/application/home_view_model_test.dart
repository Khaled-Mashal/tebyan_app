import 'package:flutter_test/flutter_test.dart';
import 'package:tebyan_app/features/home/application/home_view_model.dart';
import 'package:tebyan_app/features/home/domain/last_reading_entry.dart';
import 'package:tebyan_app/features/home/infrastructure/last_reading_repository.dart';
import 'package:tebyan_app/features/khatma/application/active_khatma_summary.dart';
import 'package:tebyan_app/features/quran/domain/quran_position.dart';
import 'package:tebyan_app/features/settings/domain/user_preferences.dart';
import 'package:tebyan_app/features/settings/infrastructure/preferences_repository.dart';
import 'package:tebyan_app/shared/errors/app_error.dart';
import 'package:tebyan_app/shared/errors/result.dart';

void main() {
  group('HomeViewModel', () {
    test(
      'loads latest reading and active khatma summary for the dashboard',
      () async {
        final latest = readingEntry(id: 'latest', page: 22);
        final khatma = ActiveKhatmaSummary(
          planId: 'ramadan',
          planName: 'Ramadan khatma',
          todayWirdTitle: 'Pages 22-24',
          completedAssignedPages: 20,
          totalAssignedPages: 604,
        );
        final viewModel = HomeViewModel(
          preferencesRepository: _FakePreferencesRepository(),
          lastReadingRepository: _FakeLastReadingRepository(latest: latest),
          activeKhatmaReader: _FakeActiveKhatmaReader(summary: khatma),
        );

        await viewModel.load();

        expect(viewModel.state.status, HomeDashboardStatus.ready);
        expect(viewModel.state.latestReading, latest);
        expect(viewModel.state.activeKhatma, khatma);
        expect(viewModel.state.isEmpty, isFalse);
      },
    );

    test('reports an empty state when no reading or khatma exists', () async {
      final viewModel = HomeViewModel(
        preferencesRepository: _FakePreferencesRepository(),
        lastReadingRepository: _FakeLastReadingRepository(),
        activeKhatmaReader: _FakeActiveKhatmaReader(),
      );

      await viewModel.load();

      expect(viewModel.state.status, HomeDashboardStatus.ready);
      expect(viewModel.state.latestReading, isNull);
      expect(viewModel.state.activeKhatma, isNull);
      expect(viewModel.state.isEmpty, isTrue);
    });

    test(
      'surfaces recoverable load errors without losing shortcut commands',
      () async {
        final viewModel = HomeViewModel(
          preferencesRepository: _FakePreferencesRepository(
            error: const AppError(
              code: AppErrorCode.persistence,
              message: 'settings unavailable',
            ),
          ),
          lastReadingRepository: _FakeLastReadingRepository(),
          activeKhatmaReader: _FakeActiveKhatmaReader(),
        );

        await viewModel.load();

        expect(viewModel.state.status, HomeDashboardStatus.error);
        expect(viewModel.state.error?.code, AppErrorCode.persistence);
        expect(viewModel.state.shortcuts, contains(HomeShortcut.reader));
        expect(viewModel.state.shortcuts, contains(HomeShortcut.search));
        expect(viewModel.state.shortcuts, contains(HomeShortcut.khatma));
      },
    );

    test(
      'continueReading emits an open-reader command for latest position',
      () async {
        final latest = readingEntry(id: 'latest', page: 44);
        final commands = <HomeCommand>[];
        final viewModel = HomeViewModel(
          preferencesRepository: _FakePreferencesRepository(),
          lastReadingRepository: _FakeLastReadingRepository(latest: latest),
          activeKhatmaReader: _FakeActiveKhatmaReader(),
          onCommand: commands.add,
        );
        await viewModel.load();

        viewModel.continueReading();

        expect(commands, hasLength(1));
        expect(commands.single, HomeCommand.openReader(latest.position));
      },
    );

    test('shortcut commands map to stable dashboard destinations', () async {
      final commands = <HomeCommand>[];
      final viewModel = HomeViewModel(
        preferencesRepository: _FakePreferencesRepository(),
        lastReadingRepository: _FakeLastReadingRepository(),
        activeKhatmaReader: _FakeActiveKhatmaReader(),
        onCommand: commands.add,
      );

      viewModel.openShortcut(HomeShortcut.bookmarks);
      viewModel.openShortcut(HomeShortcut.search);
      viewModel.openShortcut(HomeShortcut.khatma);

      expect(commands, <HomeCommand>[
        const HomeCommand.openRoute(HomeRouteDestination.bookmarks),
        const HomeCommand.openRoute(HomeRouteDestination.search),
        const HomeCommand.openRoute(HomeRouteDestination.khatma),
      ]);
    });
  });
}

class _FakePreferencesRepository implements PreferencesRepository {
  _FakePreferencesRepository({this.error});

  final AppError? error;

  @override
  Future<Result<UserPreferences?>> loadUserPreferences() async {
    final error = this.error;
    if (error != null) {
      return Failure<UserPreferences?>(error);
    }
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

class _FakeLastReadingRepository implements LastReadingRepository {
  _FakeLastReadingRepository({this.latest});

  final LastReadingEntry? latest;

  @override
  Future<Result<LastReadingEntry?>> latestEntry() async {
    return Success<LastReadingEntry?>(latest);
  }

  @override
  Future<Result<List<LastReadingEntry>>> recentEntries() async {
    return Success<List<LastReadingEntry>>(
      latest == null ? const <LastReadingEntry>[] : <LastReadingEntry>[latest!],
    );
  }

  @override
  Future<Result<void>> saveEntry(LastReadingEntry entry) async {
    return const Success<void>(null);
  }
}

class _FakeActiveKhatmaReader implements ActiveKhatmaReader {
  _FakeActiveKhatmaReader({this.summary});

  final ActiveKhatmaSummary? summary;

  @override
  Future<Result<ActiveKhatmaSummary?>> loadActiveSummary(DateTime date) async {
    return Success<ActiveKhatmaSummary?>(summary);
  }
}

LastReadingEntry readingEntry({required String id, required int page}) {
  return LastReadingEntry(
    id: id,
    position: QuranPosition(
      surahNumber: 2,
      ayahNumber: page,
      page: page,
      displaySurahName: 'Al-Baqarah',
      displayAyahLabel: '2:$page',
    ),
    source: LastReadingSource.reader,
    savedAt: DateTime.utc(2026, 4, 25, 12),
    displayTitle: 'Al-Baqarah',
    displaySubtitle: '2:$page',
  );
}
