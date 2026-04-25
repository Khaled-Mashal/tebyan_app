import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tebyan_app/app/localization/app_localizations.dart';
import 'package:tebyan_app/app/navigation/app_router.dart';
import 'package:tebyan_app/app/theme/raqeem_theme.dart';
import 'package:tebyan_app/features/onboarding/application/onboarding_view_model.dart';
import 'package:tebyan_app/features/onboarding/presentation/onboarding_screen.dart';
import 'package:tebyan_app/features/settings/domain/user_preferences.dart';
import 'package:tebyan_app/features/settings/infrastructure/preferences_repository.dart';
import 'package:tebyan_app/shared/errors/result.dart';

void main() {
  group('Onboarding flow', () {
    testWidgets('Arabic journey saves RTL preferences and routes home', (
      tester,
    ) async {
      final repository = _RecordingPreferencesRepository();

      await tester.pumpWidget(_OnboardingHarness(repository: repository));
      await tester.pumpAndSettle();

      expect(
        Directionality.of(tester.element(find.byType(OnboardingScreen))),
        TextDirection.rtl,
      );
      expect(find.text('العربية'), findsOneWidget);

      await tester.tap(find.text('ليلي'));
      await tester.tap(find.text('ابدأ القراءة'));
      await tester.pumpAndSettle();

      expect(repository.saved.single.languageCode, 'ar');
      expect(repository.saved.single.textDirectionName, 'rtl');
      expect(repository.saved.single.visualMode, RaqeemVisualMode.night);
      expect(find.text('رقيم'), findsWidgets);
    });

    testWidgets('English journey saves LTR preferences and routes home', (
      tester,
    ) async {
      final repository = _RecordingPreferencesRepository();

      await tester.pumpWidget(_OnboardingHarness(repository: repository));
      await tester.pumpAndSettle();

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Light'));
      await tester.tap(find.text('Start reading'));
      await tester.pumpAndSettle();

      expect(repository.saved.single.languageCode, 'en');
      expect(repository.saved.single.textDirectionName, 'ltr');
      expect(repository.saved.single.visualMode, RaqeemVisualMode.light);
      expect(find.byType(RaqeemRouteShell), findsOneWidget);
    });
  });
}

class _OnboardingHarness extends StatelessWidget {
  const _OnboardingHarness({required this.repository});

  final PreferencesRepository repository;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<OnboardingViewModel>(
      create: (_) => OnboardingViewModel(repository)..loadPreferences(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: RaqeemTheme.light(),
        darkTheme: RaqeemTheme.night(),
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        routes: <String, WidgetBuilder>{
          AppRouter.onboarding: (_) => const OnboardingScreen(),
          AppRouter.home: (_) =>
              const RaqeemRouteShell(route: RaqeemRoute.home),
        },
        initialRoute: AppRouter.onboarding,
      ),
    );
  }
}

class _RecordingPreferencesRepository implements PreferencesRepository {
  final saved = <UserPreferences>[];

  @override
  Future<Result<UserPreferences?>> loadUserPreferences() async {
    return const Success<UserPreferences?>(null);
  }

  @override
  Future<Result<void>> saveUserPreferences(UserPreferences preferences) async {
    saved.add(preferences);
    return const Success<void>(null);
  }
}
