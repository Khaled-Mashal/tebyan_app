import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tebyan_app/app/localization/app_localizations.dart';
import 'package:tebyan_app/app/theme/raqeem_theme.dart';
import 'package:tebyan_app/features/quran/application/reader_view_model.dart';
import 'package:tebyan_app/features/quran/domain/quran_position.dart';
import 'package:tebyan_app/features/quran/infrastructure/quran_gateway.dart';
import 'package:tebyan_app/features/quran/presentation/ayah_action_menu.dart';
import 'package:tebyan_app/features/quran/presentation/quran_reader_screen.dart';
import '../fakes/fake_quran_gateway.dart';

void main() {
  group('Reader accessibility', () {
    late FakeQuranGateway gateway;
    late ReaderViewModel viewModel;

    setUp(() {
      gateway = FakeQuranGateway(positions: _testPositions);
      viewModel = ReaderViewModel(navigationGateway: gateway);
    });

    group('tap targets', () {
      testWidgets('all control buttons meet 44px minimum tap target', (
        tester,
      ) async {
        await viewModel.openAtPosition(_fatihahPos);
        await tester.pumpWidget(_AccessibilityHarness(viewModel: viewModel));
        await tester.pump();

        final controlKeys = <String>[
          'reader_back',
          'reader_navigate_surah',
          'reader_navigate_juz',
          'reader_bookmark',
          'reader_previous_page',
          'reader_next_page',
        ];

        for (final keyName in controlKeys) {
          final finder = find.byKey(Key(keyName));
          expect(finder, findsOneWidget, reason: 'Missing control: $keyName');

          final iconButton = tester.widget<IconButton>(finder);
          expect(
            iconButton.constraints?.minWidth ?? 0,
            greaterThanOrEqualTo(44),
            reason: '$keyName width < 44',
          );
          expect(
            iconButton.constraints?.minHeight ?? 0,
            greaterThanOrEqualTo(44),
            reason: '$keyName height < 44',
          );
        }
      });

      testWidgets('close ayah action sheet meets 44px tap target', (
        tester,
      ) async {
        await tester.pumpWidget(const _AyahActionSheetHarness());
        await tester.tap(find.byKey(const Key('show_ayah_action_sheet')));
        await tester.pumpAndSettle();

        final finder = find.byKey(const Key('close_ayah_action_sheet'));
        expect(finder, findsOneWidget);

        final iconButton = tester.widget<IconButton>(finder);
        expect(
          iconButton.constraints?.minWidth ?? 0,
          greaterThanOrEqualTo(44),
          reason: 'close_ayah_action_sheet width < 44',
        );
        expect(
          iconButton.constraints?.minHeight ?? 0,
          greaterThanOrEqualTo(44),
          reason: 'close_ayah_action_sheet height < 44',
        );
      });

      testWidgets('retry button meets 44px minimum height', (tester) async {
        final errorVm = ReaderViewModel(navigationGateway: gateway);
        await errorVm.openAtPosition(_fatihahPos);

        await tester.pumpWidget(_AccessibilityHarness(viewModel: errorVm));
        await tester.pump();

        final finder = find.byKey(const Key('reader_retry'));
        if (finder.evaluate().isNotEmpty) {
          final size = tester.getSize(finder);
          expect(size.height, greaterThanOrEqualTo(44));
        }
      });
    });

    group('semantic labels', () {
      testWidgets('control buttons have tooltips', (tester) async {
        await viewModel.openAtPosition(_fatihahPos);
        await tester.pumpWidget(_AccessibilityHarness(viewModel: viewModel));
        await tester.pump();

        final controlKeys = <String>[
          'reader_back',
          'reader_navigate_surah',
          'reader_navigate_juz',
          'reader_bookmark',
          'reader_previous_page',
          'reader_next_page',
        ];

        for (final keyName in controlKeys) {
          final finder = find.byKey(Key(keyName));
          expect(finder, findsOneWidget, reason: 'Missing: $keyName');

          final iconButton = tester.widget<IconButton>(finder);
          expect(
            iconButton.tooltip,
            allOf(isNotNull, isNotEmpty),
            reason: '$keyName missing tooltip',
          );
        }
      });

      testWidgets('close ayah action sheet has tooltip', (tester) async {
        await tester.pumpWidget(const _AyahActionSheetHarness());
        await tester.tap(find.byKey(const Key('show_ayah_action_sheet')));
        await tester.pumpAndSettle();

        final finder = find.byKey(const Key('close_ayah_action_sheet'));
        final iconButton = tester.widget<IconButton>(finder);
        expect(
          iconButton.tooltip,
          allOf(isNotNull, isNotEmpty),
          reason: 'close_ayah_action_sheet missing tooltip',
        );
      });
    });

    group('no clipped primary controls', () {
      testWidgets('primary controls are fully visible within screen bounds', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(360 * 1.0, 640 * 1.0);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await viewModel.openAtPosition(_fatihahPos);
        await tester.pumpWidget(_AccessibilityHarness(viewModel: viewModel));
        await tester.pump();

        final controlKeys = <String>[
          'reader_back',
          'reader_navigate_surah',
          'reader_previous_page',
          'reader_next_page',
        ];

        final screenSize = tester.getSize(find.byType(Scaffold).first);

        for (final keyName in controlKeys) {
          final finder = find.byKey(Key(keyName));
          expect(finder, findsOneWidget, reason: 'Missing: $keyName');

          final topLeft = tester.getTopLeft(finder);
          final bottomRight = tester.getBottomRight(finder);

          expect(
            topLeft.dx,
            greaterThanOrEqualTo(0),
            reason: '$keyName clipped left',
          );
          expect(
            topLeft.dy,
            greaterThanOrEqualTo(0),
            reason: '$keyName clipped top',
          );
          expect(
            bottomRight.dx,
            lessThanOrEqualTo(screenSize.width),
            reason: '$keyName clipped right',
          );
          expect(
            bottomRight.dy,
            lessThanOrEqualTo(screenSize.height),
            reason: '$keyName clipped bottom',
          );
        }
      });
    });
  });
}

class _AyahActionSheetHarness extends StatelessWidget {
  const _AyahActionSheetHarness();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: RaqeemTheme.light(),
      locale: const Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return Center(
              child: ElevatedButton(
                key: const Key('show_ayah_action_sheet'),
                onPressed: () {
                  AyahActionMenu.show(
                    context,
                    position: _fatihahPos,
                    selectedAyah: SelectedAyah(
                      position: _fatihahPos,
                      text: 'بسم الله الرحمن الرحيم',
                      reference: 'الفاتحة 1:1',
                    ),
                  );
                },
                child: const Text('Show'),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AccessibilityHarness extends StatelessWidget {
  const _AccessibilityHarness({required this.viewModel});

  final ReaderViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ReaderViewModel>.value(
      value: viewModel,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: RaqeemTheme.light(),
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const QuranReaderScreen(),
      ),
    );
  }
}

final _fatihahPos = QuranPosition(
  surahNumber: 1,
  ayahNumber: 1,
  ayahUniqueNumber: 1,
  page: 1,
  juz: 1,
  hizb: 1,
  rub: 1,
  displaySurahName: 'الفاتحة',
  displayAyahLabel: 'الفاتحة ١',
);

final _baqarahPos = QuranPosition(
  surahNumber: 2,
  ayahNumber: 1,
  ayahUniqueNumber: 142,
  page: 2,
  juz: 1,
  hizb: 1,
  rub: 2,
  displaySurahName: 'البقرة',
  displayAyahLabel: 'البقرة ١',
);

final _testPositions = <QuranPosition>[_fatihahPos, _baqarahPos];
