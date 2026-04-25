import 'package:flutter/foundation.dart';

import '../../../shared/errors/app_error.dart';
import '../../../shared/errors/result.dart';
import '../../khatma/application/active_khatma_summary.dart';
import '../../quran/domain/quran_position.dart';
import '../../settings/domain/user_preferences.dart';
import '../../settings/infrastructure/preferences_repository.dart';
import '../domain/last_reading_entry.dart';
import '../infrastructure/last_reading_repository.dart';

enum HomeDashboardStatus { loading, ready, error }

enum HomeShortcut { reader, bookmarks, search, khatma, settings }

enum HomeRouteDestination { reader, bookmarks, search, khatma, settings }

@immutable
class HomeCommand {
  const HomeCommand._({this.position, this.destination});

  const HomeCommand.openReader(QuranPosition position)
    : this._(position: position);

  const HomeCommand.openRoute(HomeRouteDestination destination)
    : this._(destination: destination);

  final QuranPosition? position;
  final HomeRouteDestination? destination;

  @override
  bool operator ==(Object other) {
    return other is HomeCommand &&
        other.position == position &&
        other.destination == destination;
  }

  @override
  int get hashCode => Object.hash(position, destination);
}

@immutable
class HomeDashboardState {
  const HomeDashboardState({
    required this.status,
    required this.shortcuts,
    this.preferences,
    this.latestReading,
    this.activeKhatma,
    this.error,
  });

  factory HomeDashboardState.initial() {
    return const HomeDashboardState(
      status: HomeDashboardStatus.loading,
      shortcuts: <HomeShortcut>[
        HomeShortcut.reader,
        HomeShortcut.bookmarks,
        HomeShortcut.search,
        HomeShortcut.khatma,
        HomeShortcut.settings,
      ],
    );
  }

  final HomeDashboardStatus status;
  final UserPreferences? preferences;
  final LastReadingEntry? latestReading;
  final ActiveKhatmaSummary? activeKhatma;
  final List<HomeShortcut> shortcuts;
  final AppError? error;

  bool get isEmpty => latestReading == null && activeKhatma == null;

  HomeDashboardState copyWith({
    HomeDashboardStatus? status,
    UserPreferences? preferences,
    LastReadingEntry? latestReading,
    ActiveKhatmaSummary? activeKhatma,
    List<HomeShortcut>? shortcuts,
    AppError? error,
    bool clearError = false,
  }) {
    return HomeDashboardState(
      status: status ?? this.status,
      preferences: preferences ?? this.preferences,
      latestReading: latestReading ?? this.latestReading,
      activeKhatma: activeKhatma ?? this.activeKhatma,
      shortcuts: shortcuts ?? this.shortcuts,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required PreferencesRepository preferencesRepository,
    required LastReadingRepository lastReadingRepository,
    required ActiveKhatmaReader activeKhatmaReader,
    void Function(HomeCommand command)? onCommand,
    DateTime Function()? clock,
  }) : _preferencesRepository = preferencesRepository,
       _lastReadingRepository = lastReadingRepository,
       _activeKhatmaReader = activeKhatmaReader,
       _onCommand = onCommand,
       _clock = clock ?? DateTime.now;

  final PreferencesRepository _preferencesRepository;
  final LastReadingRepository _lastReadingRepository;
  final ActiveKhatmaReader _activeKhatmaReader;
  final void Function(HomeCommand command)? _onCommand;
  final DateTime Function() _clock;

  HomeDashboardState _state = HomeDashboardState.initial();

  HomeDashboardState get state => _state;

  Future<void> load() async {
    _setState(
      _state.copyWith(status: HomeDashboardStatus.loading, clearError: true),
    );

    final preferencesResult = await _preferencesRepository
        .loadUserPreferences();
    switch (preferencesResult) {
      case Failure<UserPreferences?>(:final error):
        _setState(
          _state.copyWith(status: HomeDashboardStatus.error, error: error),
        );
        return;
      case Success<UserPreferences?>(:final value):
        _setState(_state.copyWith(preferences: value, clearError: true));
    }

    final latestResult = await _lastReadingRepository.latestEntry();
    switch (latestResult) {
      case Failure<LastReadingEntry?>(:final error):
        _setState(
          _state.copyWith(status: HomeDashboardStatus.error, error: error),
        );
        return;
      case Success<LastReadingEntry?>(:final value):
        _setState(_state.copyWith(latestReading: value, clearError: true));
    }

    final khatmaResult = await _activeKhatmaReader.loadActiveSummary(_clock());
    switch (khatmaResult) {
      case Failure<ActiveKhatmaSummary?>(:final error):
        _setState(
          _state.copyWith(status: HomeDashboardStatus.error, error: error),
        );
      case Success<ActiveKhatmaSummary?>(:final value):
        _setState(
          _state.copyWith(
            status: HomeDashboardStatus.ready,
            activeKhatma: value,
            clearError: true,
          ),
        );
    }
  }

  void continueReading() {
    final position = _state.latestReading?.position;
    if (position != null) {
      _onCommand?.call(HomeCommand.openReader(position));
    }
  }

  void openShortcut(HomeShortcut shortcut) {
    _onCommand?.call(
      HomeCommand.openRoute(switch (shortcut) {
        HomeShortcut.reader => HomeRouteDestination.reader,
        HomeShortcut.bookmarks => HomeRouteDestination.bookmarks,
        HomeShortcut.search => HomeRouteDestination.search,
        HomeShortcut.khatma => HomeRouteDestination.khatma,
        HomeShortcut.settings => HomeRouteDestination.settings,
      }),
    );
  }

  void _setState(HomeDashboardState state) {
    _state = state;
    notifyListeners();
  }
}
