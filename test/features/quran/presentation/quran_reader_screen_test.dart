import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tebyan_app/app/localization/app_localizations.dart';
import 'package:tebyan_app/app/theme/raqeem_theme.dart';
import 'package:tebyan_app/features/quran/application/reader_state.dart';
import 'package:tebyan_app/features/quran/application/reader_view_model.dart';
import 'package:tebyan_app/features/quran/domain/quran_position.dart';
import 'package:tebyan_app/features/quran/presentation/quran_reader_screen.dart';
import '../../../shared/fakes/fake_quran_gateway.dart';

void main() {
  group('QuranReaderScreen', () {
    late FakeQuranGateway gateway;
    late ReaderViewModel viewModel;

    setUp(() {
      gateway = FakeQuranGateway(positions: _testPositions);
      viewModel = ReaderViewModel(navigationGateway: gateway);
    });

    group('loading state', () {
      testWidgets('shows loading indicator', (tester) async {
        await tester.pumpWidget(_ReaderHarness(viewModel: viewModel));
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('جارٍ تحميل القارئ…'), findsOneWidget);
      });
    });

    group('ready state', () {
      testWidgets('shows surah name and page after opening', (tester) async {
        await viewModel.openAtPosition(_fatihahPos);
        await tester.pumpWidget(_ReaderHarness(viewModel: viewModel));
        await tester.pump();

        expect(find.text('الفاتحة'), findsOneWidget);
        expect(find.textContaining('صفحة'), findsWidgets);
      });

      testWidgets('shows controls by default', (tester) async {
        await viewModel.openAtPosition(_fatihahPos);
        await tester.pumpWidget(_ReaderHarness(viewModel: viewModel));
        await tester.pump();

        expect(find.byKey(const Key('reader_back')), findsOneWidget);
        expect(find.byKey(const Key('reader_navigate_surah')), findsOneWidget);
        expect(find.byKey(const Key('reader_navigate_juz')), findsOneWidget);
        expect(find.byKey(const Key('reader_bookmark')), findsOneWidget);
        expect(find.byKey(const Key('reader_previous_page')), findsOneWidget);
        expect(find.byKey(const Key('reader_next_page')), findsOneWidget);
      });

      testWidgets('tapping reader area hides controls', (tester) async {
        await viewModel.openAtPosition(_fatihahPos);
        await tester.pumpWidget(_ReaderHarness(viewModel: viewModel));
        await tester.pump();

        expect(find.byKey(const Key('reader_back')), findsOneWidget);

        await tester.tapAt(const Offset(200, 400));
        await tester.pump();

        expect(find.byKey(const Key('reader_back')), findsNothing);
        expect(find.byKey(const Key('reader_navigate_surah')), findsNothing);
      });

      testWidgets('tapping reader area twice shows controls again', (
        tester,
      ) async {
        await viewModel.openAtPosition(_fatihahPos);
        await tester.pumpWidget(_ReaderHarness(viewModel: viewModel));
        await tester.pump();

        await tester.tapAt(const Offset(200, 400));
        await tester.pump();
        await tester.tapAt(const Offset(200, 400));
        await tester.pump();

        expect(find.byKey(const Key('reader_back')), findsOneWidget);
      });
    });

    group('ayah selection', () {
      testWidgets('keeps selected ayah in state without a floating banner', (
        tester,
      ) async {
        await viewModel.openAtPosition(_fatihahPos);
        await tester.pumpWidget(_ReaderHarness(viewModel: viewModel));
        await tester.pump();

        viewModel.selectAyah(_fatihahPos);
        await tester.pump();

        expect(viewModel.state.isAyahSelected, isTrue);
        expect(find.byKey(const Key('close_ayah_selection')), findsNothing);
      });

      testWidgets('clearing selection removes selected ayah state', (
        tester,
      ) async {
        await viewModel.openAtPosition(_fatihahPos);
        await tester.pumpWidget(_ReaderHarness(viewModel: viewModel));
        await tester.pump();

        viewModel.selectAyah(_fatihahPos);
        await tester.pump();

        viewModel.clearAyahSelection();
        await tester.pump();

        expect(viewModel.state.isAyahSelected, isFalse);
      });
    });

    group('error state', () {
      testWidgets('shows error message with retry button', (tester) async {
        final emptyGateway = FakeQuranGateway(positions: []);
        final errorViewModel = ReaderViewModel(navigationGateway: emptyGateway);
        await errorViewModel.openAtPage(999);

        await tester.pumpWidget(_ReaderHarness(viewModel: errorViewModel));
        await tester.pump();

        expect(errorViewModel.state.status, ReaderStatus.error);
        expect(find.byKey(const Key('reader_retry')), findsOneWidget);
      });

      testWidgets('retry recovers to ready state when position is preserved', (
        tester,
      ) async {
        final vm = ReaderViewModel(navigationGateway: gateway);
        await vm.openAtPosition(_fatihahPos);
        await vm.openAtPage(999);

        await tester.pumpWidget(_ReaderHarness(viewModel: vm));
        await tester.pump();

        expect(vm.state.status, ReaderStatus.error);
        expect(vm.state.position, _fatihahPos);
        expect(find.byKey(const Key('reader_retry')), findsOneWidget);

        await tester.tap(find.byKey(const Key('reader_retry')));
        await tester.pumpAndSettle();

        expect(vm.state.status, ReaderStatus.ready);
        expect(vm.state.error, isNull);
      });
    });
  });
}

class _ReaderHarness extends StatelessWidget {
  const _ReaderHarness({required this.viewModel});

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
