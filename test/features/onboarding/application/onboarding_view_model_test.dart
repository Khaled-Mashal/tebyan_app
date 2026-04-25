import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tebyan_app/features/onboarding/application/onboarding_view_model.dart';
import 'package:tebyan_app/features/settings/domain/user_preferences.dart';
import 'package:tebyan_app/features/settings/infrastructure/preferences_repository.dart';
import 'package:tebyan_app/shared/errors/app_error.dart';
import 'package:tebyan_app/shared/errors/result.dart';

void main() {
  group('OnboardingViewModel', () {
    test(
      'first launch enters onboarding with Arabic, RTL, and light defaults',
      () async {
        final repository = _FakePreferencesRepository();
        final viewModel = OnboardingViewModel(repository);

        expect(viewModel.state.status, OnboardingStatus.loading);

        await viewModel.loadPreferences();

        expect(viewModel.state.status, OnboardingStatus.requiresOnboarding);
        expect(viewModel.state.languageCode, 'ar');
        expect(viewModel.state.textDirection, TextDirection.rtl);
        expect(viewModel.state.visualMode, RaqeemVisualMode.light);
        expect(viewModel.state.error, isNull);
      },
    );

    test('existing completed preferences skip onboarding', () async {
      final saved = UserPreferences.defaults(
        now: DateTime.utc(2026, 4, 25),
      ).copyWith(onboardingCompleted: true);
      final repository = _FakePreferencesRepository(saved: saved);
      final viewModel = OnboardingViewModel(repository);

      await viewModel.loadPreferences();

      expect(viewModel.state.status, OnboardingStatus.completed);
      expect(viewModel.state.preferences, saved);
    });

    test(
      'language selection derives RTL for Arabic and LTR for English',
      () async {
        final viewModel = OnboardingViewModel(_FakePreferencesRepository());
        await viewModel.loadPreferences();

        viewModel.selectLanguage('en');

        expect(viewModel.state.languageCode, 'en');
        expect(viewModel.state.textDirection, TextDirection.ltr);

        viewModel.selectLanguage('ar');

        expect(viewModel.state.languageCode, 'ar');
        expect(viewModel.state.textDirection, TextDirection.rtl);
      },
    );

    test(
      'visual mode selection is retained in the pending preferences',
      () async {
        final viewModel = OnboardingViewModel(_FakePreferencesRepository());
        await viewModel.loadPreferences();

        viewModel.selectVisualMode(RaqeemVisualMode.night);

        expect(viewModel.state.visualMode, RaqeemVisualMode.night);
        expect(viewModel.state.status, OnboardingStatus.requiresOnboarding);
      },
    );

    test(
      'completion persists preferences and exposes completed state',
      () async {
        final repository = _FakePreferencesRepository();
        final viewModel = OnboardingViewModel(repository);
        await viewModel.loadPreferences();

        viewModel
          ..selectLanguage('en')
          ..selectVisualMode(RaqeemVisualMode.system);

        await viewModel.completeOnboarding();

        expect(viewModel.state.status, OnboardingStatus.completed);
        expect(repository.savedPreferences, hasLength(1));
        expect(repository.savedPreferences.single.onboardingCompleted, isTrue);
        expect(repository.savedPreferences.single.languageCode, 'en');
        expect(
          repository.savedPreferences.single.visualMode,
          RaqeemVisualMode.system,
        );
      },
    );

    test(
      'save failure keeps selections and returns a recoverable retry state',
      () async {
        final repository = _FakePreferencesRepository(
          saveError: const AppError(
            code: AppErrorCode.persistence,
            message: 'database unavailable',
            isRecoverable: true,
          ),
        );
        final viewModel = OnboardingViewModel(repository);
        await viewModel.loadPreferences();

        viewModel
          ..selectLanguage('en')
          ..selectVisualMode(RaqeemVisualMode.night);

        await viewModel.completeOnboarding();

        expect(viewModel.state.status, OnboardingStatus.error);
        expect(viewModel.state.languageCode, 'en');
        expect(viewModel.state.visualMode, RaqeemVisualMode.night);
        expect(viewModel.state.error?.code, AppErrorCode.persistence);
        expect(viewModel.state.error?.isRecoverable, isTrue);
        expect(repository.savedPreferences, isEmpty);
      },
    );
  });
}

class _FakePreferencesRepository implements PreferencesRepository {
  _FakePreferencesRepository({this.saved, this.saveError});

  final UserPreferences? saved;
  final AppError? saveError;
  final savedPreferences = <UserPreferences>[];

  @override
  Future<Result<UserPreferences?>> loadUserPreferences() async {
    return Success<UserPreferences?>(saved);
  }

  @override
  Future<Result<void>> saveUserPreferences(UserPreferences preferences) async {
    final error = saveError;
    if (error != null) {
      return Failure<void>(error);
    }
    savedPreferences.add(preferences);
    return const Success<void>(null);
  }
}
