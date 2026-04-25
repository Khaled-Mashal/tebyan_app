import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/navigation/app_router.dart';
import '../../../app/theme/raqeem_theme.dart';
import '../../settings/domain/user_preferences.dart';
import '../application/onboarding_view_model.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingViewModel>(
      builder: (context, viewModel, _) {
        final state = viewModel.state;
        final labels = _OnboardingLabels.forLanguage(state.languageCode);

        if (state.status == OnboardingStatus.completed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (ModalRoute.of(context)?.settings.name != AppRouter.home) {
              Navigator.of(context).pushReplacementNamed(AppRouter.home);
            }
          });
        }

        return Directionality(
          textDirection: state.textDirection,
          child: Scaffold(
            appBar: AppBar(title: Text(labels.title)),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      labels.language,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: const <ButtonSegment<String>>[
                        ButtonSegment<String>(
                          value: 'ar',
                          label: Text('العربية'),
                        ),
                        ButtonSegment<String>(
                          value: 'en',
                          label: Text('English'),
                        ),
                      ],
                      selected: <String>{state.languageCode},
                      onSelectionChanged: (selection) {
                        viewModel.selectLanguage(selection.single);
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      labels.visualMode,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<RaqeemVisualMode>(
                      segments: <ButtonSegment<RaqeemVisualMode>>[
                        ButtonSegment<RaqeemVisualMode>(
                          value: RaqeemVisualMode.light,
                          label: Text(labels.light),
                        ),
                        ButtonSegment<RaqeemVisualMode>(
                          value: RaqeemVisualMode.night,
                          label: Text(labels.night),
                        ),
                        ButtonSegment<RaqeemVisualMode>(
                          value: RaqeemVisualMode.system,
                          label: Text(labels.system),
                        ),
                      ],
                      selected: <RaqeemVisualMode>{state.visualMode},
                      onSelectionChanged: (selection) {
                        viewModel.selectVisualMode(selection.single);
                      },
                    ),
                    if (state.error != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        labels.error,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const Spacer(),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: RaqeemColors.primary,
                        foregroundColor: RaqeemColors.softWhite,
                      ),
                      onPressed: state.status == OnboardingStatus.saving
                          ? null
                          : viewModel.completeOnboarding,
                      child: Text(labels.startReading),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OnboardingLabels {
  const _OnboardingLabels({
    required this.title,
    required this.language,
    required this.visualMode,
    required this.light,
    required this.night,
    required this.system,
    required this.startReading,
    required this.error,
  });

  final String title;
  final String language;
  final String visualMode;
  final String light;
  final String night;
  final String system;
  final String startReading;
  final String error;

  static _OnboardingLabels forLanguage(String languageCode) {
    if (languageCode == 'en') {
      return const _OnboardingLabels(
        title: 'Onboarding',
        language: 'Language',
        visualMode: 'Visual mode',
        light: 'Light',
        night: 'Night',
        system: 'System',
        startReading: 'Start reading',
        error: 'Unable to save preferences. Try again.',
      );
    }
    return const _OnboardingLabels(
      title: 'التهيئة',
      language: 'اللغة',
      visualMode: 'نمط العرض',
      light: 'فاتح',
      night: 'ليلي',
      system: 'النظام',
      startReading: 'ابدأ القراءة',
      error: 'تعذر حفظ التفضيلات. حاول مرة أخرى.',
    );
  }
}
