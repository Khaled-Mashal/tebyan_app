import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/bookmarks/application/bookmarks_view_model.dart';
import '../../features/bookmarks/infrastructure/bookmark_repository.dart';
import '../../features/bookmarks/presentation/bookmarks_screen.dart';
import '../../features/home/application/home_view_model.dart';
import '../../features/home/domain/last_reading_entry.dart';
import '../../features/home/infrastructure/last_reading_repository.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/khatma/application/active_khatma_summary.dart';
import '../../features/onboarding/application/onboarding_view_model.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/quran/application/reader_position_service.dart';
import '../../features/quran/application/reader_state.dart';
import '../../features/quran/application/reader_view_model.dart';
import '../../features/quran/domain/quran_position.dart';
import '../../features/quran/infrastructure/quran_gateway.dart';
import '../../features/quran/infrastructure/quran_reader_widget_factory.dart';
import '../../features/quran/presentation/quran_reader_screen.dart';
import '../../features/settings/infrastructure/preferences_repository.dart';
import '../../shared/errors/result.dart';
import '../localization/app_localizations.dart';
import '../theme/raqeem_theme.dart';

class AppRouter {
  const AppRouter._();

  static const onboarding = '/onboarding';
  static const home = '/';
  static const reader = '/reader';
  static const bookmarks = '/bookmarks';
  static const audio = '/audio';
  static const khatma = '/khatma';
  static const search = '/search';
  static const settings = '/settings';
  static const sharing = '/sharing';

  static Map<String, WidgetBuilder> get routes {
    return {
      onboarding: (_) {
        return _builderWithPreferences((context, repo) {
          return ChangeNotifierProvider<OnboardingViewModel>(
            create: (_) => OnboardingViewModel(repo)..loadPreferences(),
            child: const OnboardingScreen(),
          );
        });
      },
      home: (_) {
        return _builderWithRepositories((
          context,
          preferencesRepo,
          lastReadingRepo,
          khatmaReader,
        ) {
          return ChangeNotifierProvider<HomeViewModel>(
            create: (_) => HomeViewModel(
              preferencesRepository: preferencesRepo,
              lastReadingRepository: lastReadingRepo,
              activeKhatmaReader: khatmaReader,
            )..load(),
            child: const HomeScreen(),
          );
        });
      },
      reader: (_) {
        return Builder(
          builder: (context) {
            final gateway = context.read<QuranGateway>();
            final lastReadingRepo = context.read<LastReadingRepository>();
            final positionService = ReaderPositionService(
              repository: lastReadingRepo,
            )..attach();

            final args = ModalRoute.of(context)?.settings.arguments;
            QuranPosition? initialPosition;
            if (args is QuranPosition) {
              initialPosition = args;
            }

            final viewModel = ReaderViewModel(
              navigationGateway: gateway,
              positionService: positionService,
            );

            if (initialPosition != null) {
              viewModel.openAtPosition(initialPosition);
            } else {
              lastReadingRepo.latestEntry().then((result) {
                if (viewModel.state.status == ReaderStatus.loading) {
                  switch (result) {
                    case Success<LastReadingEntry?>(:final value):
                      if (value != null) {
                        viewModel.openAtPosition(value.position);
                      } else {
                        viewModel.openAtPage(1);
                      }
                    case Failure():
                      viewModel.openAtPage(1);
                  }
                }
              });
            }

            return MultiProvider(
              providers: [
                ChangeNotifierProvider<ReaderViewModel>.value(value: viewModel),
                ChangeNotifierProvider<ReaderPositionService>.value(
                  value: positionService,
                ),
                Provider<QuranReaderWidgetFactory>.value(
                  value: QuranLibraryReaderWidgetFactory(),
                ),
              ],
              child: Theme(
                data: RaqeemTheme.quranReaderTheme(Brightness.light),
                child: const QuranReaderScreen(),
              ),
            );
          },
        );
      },
      bookmarks: (_) {
        return Builder(
          builder: (context) {
            final bookmarkRepo = context.read<BookmarkRepository>();
            return ChangeNotifierProvider<BookmarksViewModel>(
              create: (_) =>
                  BookmarksViewModel(repository: bookmarkRepo)..loadBookmarks(),
              child: BookmarksScreen(
                onOpenLocation: (bookmark) {
                  navigateToReader(context, bookmark.position);
                },
              ),
            );
          },
        );
      },
      audio: (_) => const RaqeemRouteShell(route: RaqeemRoute.audio),
      khatma: (_) => const RaqeemRouteShell(route: RaqeemRoute.khatma),
      search: (_) => const RaqeemRouteShell(route: RaqeemRoute.search),
      settings: (_) => const RaqeemRouteShell(route: RaqeemRoute.settings),
      sharing: (_) => const RaqeemRouteShell(route: RaqeemRoute.sharing),
    };
  }

  static Widget _builderWithPreferences(
    Widget Function(BuildContext, PreferencesRepository) builder,
  ) {
    return Builder(
      builder: (context) {
        return builder(context, context.read<PreferencesRepository>());
      },
    );
  }

  static Widget _builderWithRepositories(
    Widget Function(
      BuildContext,
      PreferencesRepository,
      LastReadingRepository,
      ActiveKhatmaReader,
    )
    builder,
  ) {
    return Builder(
      builder: (context) {
        return builder(
          context,
          context.read<PreferencesRepository>(),
          context.read<LastReadingRepository>(),
          context.read<ActiveKhatmaReader>(),
        );
      },
    );
  }

  static void navigateToReader(BuildContext context, QuranPosition position) {
    Navigator.of(context).pushNamed(reader, arguments: position);
  }
}

enum RaqeemRoute {
  onboarding,
  home,
  reader,
  bookmarks,
  audio,
  khatma,
  search,
  settings,
  sharing,
}

class RaqeemRouteShell extends StatelessWidget {
  const RaqeemRouteShell({RaqeemRoute? route, String? title, super.key})
    : route = route ?? RaqeemRoute.onboarding,
      _fallbackTitle = title;

  final RaqeemRoute route;
  final String? _fallbackTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = _fallbackTitle ?? _titleFor(context, route);
    final subtitle = AppLocalizations.of(context).foundationReady;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            subtitle,
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  String _titleFor(BuildContext context, RaqeemRoute route) {
    final l10n = AppLocalizations.of(context);
    return switch (route) {
      RaqeemRoute.onboarding => l10n.onboarding,
      RaqeemRoute.home => l10n.appName,
      RaqeemRoute.reader => l10n.reader,
      RaqeemRoute.bookmarks => l10n.bookmarks,
      RaqeemRoute.audio => l10n.audio,
      RaqeemRoute.khatma => l10n.khatma,
      RaqeemRoute.search => l10n.search,
      RaqeemRoute.settings => l10n.settings,
      RaqeemRoute.sharing => l10n.sharing,
    };
  }
}
