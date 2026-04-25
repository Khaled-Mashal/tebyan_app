import 'package:flutter/widgets.dart';

import '../../../features/settings/domain/user_preferences.dart';
import '../../../features/settings/infrastructure/preferences_repository.dart';
import '../../../shared/errors/app_error.dart';
import '../../../shared/errors/result.dart';

enum OnboardingStatus { loading, requiresOnboarding, saving, completed, error }

@immutable
class OnboardingState {
  const OnboardingState({
    required this.status,
    required this.languageCode,
    required this.visualMode,
    this.preferences,
    this.error,
  });

  factory OnboardingState.initial() {
    final defaults = UserPreferences.defaults();
    return OnboardingState(
      status: OnboardingStatus.loading,
      languageCode: defaults.languageCode,
      visualMode: defaults.visualMode,
      preferences: defaults,
    );
  }

  final OnboardingStatus status;
  final String languageCode;
  final RaqeemVisualMode visualMode;
  final UserPreferences? preferences;
  final AppError? error;

  TextDirection get textDirection =>
      languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr;

  OnboardingState copyWith({
    OnboardingStatus? status,
    String? languageCode,
    RaqeemVisualMode? visualMode,
    UserPreferences? preferences,
    AppError? error,
    bool clearError = false,
  }) {
    return OnboardingState(
      status: status ?? this.status,
      languageCode: languageCode ?? this.languageCode,
      visualMode: visualMode ?? this.visualMode,
      preferences: preferences ?? this.preferences,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class OnboardingViewModel extends ChangeNotifier {
  OnboardingViewModel(this._preferencesRepository);

  final PreferencesRepository _preferencesRepository;
  OnboardingState _state = OnboardingState.initial();

  OnboardingState get state => _state;

  Future<void> loadPreferences() async {
    _setState(
      _state.copyWith(status: OnboardingStatus.loading, clearError: true),
    );

    final result = await _preferencesRepository.loadUserPreferences();
    switch (result) {
      case Success<UserPreferences?>(:final value):
        final preferences = value ?? UserPreferences.defaults();
        _setState(
          _state.copyWith(
            status: preferences.onboardingCompleted
                ? OnboardingStatus.completed
                : OnboardingStatus.requiresOnboarding,
            languageCode: preferences.languageCode,
            visualMode: preferences.visualMode,
            preferences: preferences,
            clearError: true,
          ),
        );
      case Failure<UserPreferences?>(:final error):
        _setState(
          _state.copyWith(status: OnboardingStatus.error, error: error),
        );
    }
  }

  void selectLanguage(String languageCode) {
    if (!UserPreferences.supportedLanguageCodes.contains(languageCode)) {
      _setState(
        _state.copyWith(
          status: OnboardingStatus.error,
          error: AppError(
            code: AppErrorCode.validation,
            message: 'Unsupported languageCode: $languageCode',
          ),
        ),
      );
      return;
    }

    _setState(
      _state.copyWith(
        status: OnboardingStatus.requiresOnboarding,
        languageCode: languageCode,
        clearError: true,
      ),
    );
  }

  void selectVisualMode(RaqeemVisualMode visualMode) {
    _setState(
      _state.copyWith(
        status: OnboardingStatus.requiresOnboarding,
        visualMode: visualMode,
        clearError: true,
      ),
    );
  }

  Future<void> completeOnboarding() async {
    final basePreferences = _state.preferences ?? UserPreferences.defaults();
    final now = DateTime.now().toUtc();
    final preferences = basePreferences.copyWith(
      onboardingCompleted: true,
      languageCode: _state.languageCode,
      visualMode: _state.visualMode,
      updatedAt: now,
    );

    _setState(
      _state.copyWith(
        status: OnboardingStatus.saving,
        preferences: preferences,
        clearError: true,
      ),
    );

    final result = await _preferencesRepository.saveUserPreferences(
      preferences,
    );
    switch (result) {
      case Success<void>():
        _setState(
          _state.copyWith(
            status: OnboardingStatus.completed,
            preferences: preferences,
            clearError: true,
          ),
        );
      case Failure<void>(:final error):
        _setState(
          _state.copyWith(status: OnboardingStatus.error, error: error),
        );
    }
  }

  void _setState(OnboardingState state) {
    _state = state;
    notifyListeners();
  }
}
