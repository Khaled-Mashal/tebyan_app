import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tebyan_app/app/localization/app_localizations.dart';
import 'package:tebyan_app/app/theme/raqeem_theme.dart';
import 'package:tebyan_app/features/bookmarks/application/bookmarks_view_model.dart';
import 'package:tebyan_app/features/bookmarks/domain/bookmark_annotation.dart';
import 'package:tebyan_app/features/bookmarks/infrastructure/bookmark_repository.dart';
import 'package:tebyan_app/features/bookmarks/presentation/bookmarks_screen.dart';
import 'package:tebyan_app/features/quran/domain/quran_position.dart';
import 'package:tebyan_app/shared/errors/app_error.dart';
import 'package:tebyan_app/shared/errors/result.dart';

void main() {
  group('BookmarksScreen', () {
    group('empty state', () {
      testWidgets('shows empty state when no bookmarks exist', (tester) async {
        final viewModel = BookmarksViewModel(
          repository: _EmptyBookmarkRepository(),
        );
        await viewModel.loadBookmarks();

        await tester.pumpWidget(_BookmarksHarness(viewModel: viewModel));
        await tester.pump();

        expect(find.byKey(const Key('bookmarks_empty')), findsOneWidget);
        expect(find.text('لا توجد علامات محفوظة'), findsOneWidget);
      });
    });

    group('loading state', () {
      testWidgets('shows loading indicator while loading', (tester) async {
        final viewModel = BookmarksViewModel(
          repository: _HangingBookmarkRepository(),
        );

        await tester.pumpWidget(_BookmarksHarness(viewModel: viewModel));
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('bookmark list', () {
      testWidgets('shows bookmark list after loading', (tester) async {
        final bookmarks = [_fatihahBookmark(), _baqarahBookmark()];
        final viewModel = BookmarksViewModel(
          repository: _PrefilledBookmarkRepository(bookmarks),
        );
        await viewModel.loadBookmarks();

        await tester.pumpWidget(_BookmarksHarness(viewModel: viewModel));
        await tester.pump();

        expect(find.byKey(const Key('bookmarks_list')), findsOneWidget);
        expect(
          find.byKey(const Key('bookmark_item_bm-fatihah')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('bookmark_item_bm-baqarah')),
          findsOneWidget,
        );
        expect(find.text('الفاتحة 1'), findsOneWidget);
        expect(find.text('البقرة 255'), findsOneWidget);
      });

      testWidgets('shows note text when bookmark has a note', (tester) async {
        final bookmarks = [_fatihahBookmark(note: 'تأمل في الفاتحة')];
        final viewModel = BookmarksViewModel(
          repository: _PrefilledBookmarkRepository(bookmarks),
        );
        await viewModel.loadBookmarks();

        await tester.pumpWidget(_BookmarksHarness(viewModel: viewModel));
        await tester.pump();

        expect(find.text('تأمل في الفاتحة'), findsOneWidget);
      });
    });

    group('open location', () {
      testWidgets('tapping bookmark item calls open location callback', (
        tester,
      ) async {
        BookmarkAnnotation? opened;
        final bookmarks = [_fatihahBookmark()];
        final viewModel = BookmarksViewModel(
          repository: _PrefilledBookmarkRepository(bookmarks),
        );
        await viewModel.loadBookmarks();

        await tester.pumpWidget(
          _BookmarksHarness(
            viewModel: viewModel,
            onOpenLocation: (b) => opened = b,
          ),
        );
        await tester.pump();

        await tester.tap(find.byKey(const Key('bookmark_item_bm-fatihah')));
        await tester.pump();

        expect(opened, isNotNull);
        expect(opened!.id, 'bm-fatihah');
        expect(opened!.position.surahNumber, 1);
      });
    });

    group('delete action', () {
      testWidgets('tapping delete removes bookmark from list', (tester) async {
        final bookmarks = [_fatihahBookmark(), _baqarahBookmark()];
        final viewModel = BookmarksViewModel(
          repository: _PrefilledBookmarkRepository(bookmarks),
        );
        await viewModel.loadBookmarks();

        await tester.pumpWidget(_BookmarksHarness(viewModel: viewModel));
        await tester.pump();

        expect(
          find.byKey(const Key('bookmark_item_bm-fatihah')),
          findsOneWidget,
        );

        await tester.tap(find.byKey(const Key('bookmark_delete_bm-fatihah')));
        await tester.pump();

        expect(find.byKey(const Key('bookmark_item_bm-fatihah')), findsNothing);
        expect(
          find.byKey(const Key('bookmark_item_bm-baqarah')),
          findsOneWidget,
        );
      });
    });

    group('error state', () {
      testWidgets('shows error state with retry on load failure', (
        tester,
      ) async {
        final viewModel = BookmarksViewModel(
          repository: _FailingBookmarkRepository(),
        );
        await viewModel.loadBookmarks();

        await tester.pumpWidget(_BookmarksHarness(viewModel: viewModel));
        await tester.pump();

        expect(
          find.text('تعذر تحميل العلامات. يرجى المحاولة مرة أخرى.'),
          findsOneWidget,
        );
        expect(find.byKey(const Key('bookmarks_retry')), findsOneWidget);
      });
    });
  });
}

BookmarkAnnotation _fatihahBookmark({String? note}) {
  return BookmarkAnnotation(
    id: 'bm-fatihah',
    position: QuranPosition(
      surahNumber: 1,
      ayahNumber: 1,
      ayahUniqueNumber: 1,
      page: 1,
      juz: 1,
      hizb: 1,
      rub: 1,
      displaySurahName: 'الفاتحة',
      displayAyahLabel: 'الفاتحة ١',
    ),
    type: BookmarkType.bookmark,
    note: note,
    color: BookmarkColor.gold,
    createdAt: DateTime.utc(2026, 4, 25),
    updatedAt: DateTime.utc(2026, 4, 25),
  );
}

BookmarkAnnotation _baqarahBookmark() {
  return BookmarkAnnotation(
    id: 'bm-baqarah',
    position: QuranPosition(
      surahNumber: 2,
      ayahNumber: 255,
      ayahUniqueNumber: 397,
      page: 23,
      juz: 3,
      hizb: 5,
      rub: 9,
      displaySurahName: 'البقرة',
      displayAyahLabel: 'البقرة ٢٥٥',
    ),
    type: BookmarkType.note,
    note: 'آية الكرسي',
    color: BookmarkColor.green,
    createdAt: DateTime.utc(2026, 4, 25, 10),
    updatedAt: DateTime.utc(2026, 4, 25, 10),
  );
}

class _BookmarksHarness extends StatelessWidget {
  const _BookmarksHarness({required this.viewModel, this.onOpenLocation});

  final BookmarksViewModel viewModel;
  final void Function(BookmarkAnnotation)? onOpenLocation;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BookmarksViewModel>.value(
      value: viewModel,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: RaqeemTheme.light(),
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: BookmarksScreen(onOpenLocation: onOpenLocation),
      ),
    );
  }
}

class _EmptyBookmarkRepository implements BookmarkRepository {
  @override
  Future<Result<BookmarkAnnotation>> create(BookmarkAnnotation a) async =>
      Success(a);

  @override
  Future<Result<BookmarkAnnotation>> update(BookmarkAnnotation a) async =>
      Success(a);

  @override
  Future<Result<void>> archive(String id) async => const Success(null);

  @override
  Future<Result<void>> delete(String id) async => const Success(null);

  @override
  Future<Result<List<BookmarkAnnotation>>> list({
    bool includeArchived = false,
    String? searchQuery,
  }) async => const Success([]);

  @override
  Future<Result<BookmarkAnnotation?>> findById(String id) async =>
      const Success(null);
}

class _PrefilledBookmarkRepository implements BookmarkRepository {
  _PrefilledBookmarkRepository(this._bookmarks);

  final List<BookmarkAnnotation> _bookmarks;

  @override
  Future<Result<BookmarkAnnotation>> create(BookmarkAnnotation a) async =>
      Success(a);

  @override
  Future<Result<BookmarkAnnotation>> update(BookmarkAnnotation a) async =>
      Success(a);

  @override
  Future<Result<void>> archive(String id) async => const Success(null);

  @override
  Future<Result<void>> delete(String id) async {
    _bookmarks.removeWhere((b) => b.id == id);
    return const Success(null);
  }

  @override
  Future<Result<List<BookmarkAnnotation>>> list({
    bool includeArchived = false,
    String? searchQuery,
  }) async => Success(List.of(_bookmarks));

  @override
  Future<Result<BookmarkAnnotation?>> findById(String id) async =>
      Success(_bookmarks.where((b) => b.id == id).firstOrNull);
}

class _HangingBookmarkRepository implements BookmarkRepository {
  @override
  Future<Result<BookmarkAnnotation>> create(BookmarkAnnotation a) async =>
      Success(a);

  @override
  Future<Result<BookmarkAnnotation>> update(BookmarkAnnotation a) async =>
      Success(a);

  @override
  Future<Result<void>> archive(String id) async => const Success(null);

  @override
  Future<Result<void>> delete(String id) async => const Success(null);

  @override
  Future<Result<List<BookmarkAnnotation>>> list({
    bool includeArchived = false,
    String? searchQuery,
  }) => Future.delayed(const Duration(seconds: 10), () => const Success([]));

  @override
  Future<Result<BookmarkAnnotation?>> findById(String id) async =>
      const Success(null);
}

class _FailingBookmarkRepository implements BookmarkRepository {
  @override
  Future<Result<BookmarkAnnotation>> create(BookmarkAnnotation a) async =>
      Success(a);

  @override
  Future<Result<BookmarkAnnotation>> update(BookmarkAnnotation a) async =>
      Success(a);

  @override
  Future<Result<void>> archive(String id) async => const Success(null);

  @override
  Future<Result<void>> delete(String id) async => const Success(null);

  @override
  Future<Result<List<BookmarkAnnotation>>> list({
    bool includeArchived = false,
    String? searchQuery,
  }) async => Failure(
    AppError(
      code: AppErrorCode.persistence,
      message: 'تعذر تحميل العلامات. يرجى المحاولة مرة أخرى.',
    ),
  );

  @override
  Future<Result<BookmarkAnnotation?>> findById(String id) async =>
      const Success(null);
}
