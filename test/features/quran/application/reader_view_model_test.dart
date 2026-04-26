import 'package:flutter_test/flutter_test.dart';
import 'package:tebyan_app/features/home/domain/last_reading_entry.dart';
import 'package:tebyan_app/features/home/infrastructure/last_reading_repository.dart';
import 'package:tebyan_app/features/quran/application/reader_position_service.dart';
import 'package:tebyan_app/features/quran/application/reader_state.dart';
import 'package:tebyan_app/features/quran/application/reader_view_model.dart';
import 'package:tebyan_app/features/quran/domain/quran_position.dart';
import 'package:tebyan_app/shared/errors/app_error.dart';
import 'package:tebyan_app/shared/errors/result.dart';
import '../../../shared/fakes/fake_quran_gateway.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ReaderViewModel', () {
    late FakeQuranGateway gateway;
    late List<ReaderCommand> commands;

    setUp(() {
      gateway = FakeQuranGateway(positions: _testPositions);
      commands = <ReaderCommand>[];
    });

    test('initial state is loading with controls visible', () {
      final viewModel = ReaderViewModel(
        navigationGateway: gateway,
        onCommand: commands.add,
      );

      expect(viewModel.state.status, ReaderStatus.loading);
      expect(viewModel.state.areControlsVisible, isTrue);
      expect(viewModel.state.position, isNull);
      expect(viewModel.state.selectedAyahPosition, isNull);
      expect(viewModel.state.error, isNull);
    });

    group('openAtPosition', () {
      test('transitions to ready with the given position', () async {
        final viewModel = ReaderViewModel(
          navigationGateway: gateway,
          onCommand: commands.add,
        );

        await viewModel.openAtPosition(_baqarahPos);

        expect(viewModel.state.status, ReaderStatus.ready);
        expect(viewModel.state.position, _baqarahPos);
        expect(viewModel.state.error, isNull);
      });
    });

    group('openAtPage', () {
      test('resolves page and transitions to ready', () async {
        final viewModel = ReaderViewModel(
          navigationGateway: gateway,
          onCommand: commands.add,
        );

        await viewModel.openAtPage(1);

        expect(viewModel.state.status, ReaderStatus.ready);
        expect(viewModel.state.position, isNotNull);
        expect(viewModel.state.position!.page, 1);
      });

      test('surfaces error when page resolution fails', () async {
        final emptyGateway = FakeQuranGateway(positions: []);
        final viewModel = ReaderViewModel(
          navigationGateway: emptyGateway,
          onCommand: commands.add,
        );

        await viewModel.openAtPage(999);

        expect(viewModel.state.status, ReaderStatus.error);
        expect(viewModel.state.error, isNotNull);
      });
    });

    group('navigation commands', () {
      test('navigateBySurah resolves and jumps to surah', () async {
        final viewModel = ReaderViewModel(
          navigationGateway: gateway,
          onCommand: commands.add,
        );

        await viewModel.navigateBySurah(1);

        expect(viewModel.state.status, ReaderStatus.ready);
        expect(viewModel.state.position!.surahNumber, 1);
        expect(gateway.jumps, hasLength(1));
        expect(gateway.jumps.single.surahNumber, 1);
      });

      test('navigateByJuz resolves and jumps to juz', () async {
        final viewModel = ReaderViewModel(
          navigationGateway: gateway,
          onCommand: commands.add,
        );

        await viewModel.navigateByJuz(2);

        expect(viewModel.state.status, ReaderStatus.ready);
        expect(viewModel.state.position!.juz, 2);
        expect(gateway.jumps, hasLength(1));
      });

      test('navigateByHizb resolves and jumps to hizb', () async {
        final viewModel = ReaderViewModel(
          navigationGateway: gateway,
          onCommand: commands.add,
        );

        await viewModel.navigateByHizb(4);

        expect(viewModel.state.status, ReaderStatus.ready);
        expect(viewModel.state.position!.hizb, 4);
        expect(gateway.jumps, hasLength(1));
      });

      test('navigateByRub resolves and jumps to rub', () async {
        final viewModel = ReaderViewModel(
          navigationGateway: gateway,
          onCommand: commands.add,
        );

        await viewModel.navigateByRub(7);

        expect(viewModel.state.status, ReaderStatus.ready);
        expect(viewModel.state.position!.rub, 7);
        expect(gateway.jumps, hasLength(1));
      });

      test('navigation error transitions to error state', () async {
        final emptyGateway = FakeQuranGateway(positions: []);
        final viewModel = ReaderViewModel(
          navigationGateway: emptyGateway,
          onCommand: commands.add,
        );
        await viewModel.openAtPosition(_fatihahPos);

        await viewModel.navigateBySurah(999);

        expect(viewModel.state.status, ReaderStatus.error);
        expect(viewModel.state.error, isNotNull);
      });
    });

    group('toggleControls', () {
      test('hides controls when currently visible', () async {
        final viewModel = ReaderViewModel(
          navigationGateway: gateway,
          onCommand: commands.add,
        );
        await viewModel.openAtPosition(_fatihahPos);
        expect(viewModel.state.areControlsVisible, isTrue);

        viewModel.toggleControls();

        expect(viewModel.state.areControlsVisible, isFalse);
      });

      test('shows controls when currently hidden', () async {
        final viewModel = ReaderViewModel(
          navigationGateway: gateway,
          onCommand: commands.add,
        );
        await viewModel.openAtPosition(_fatihahPos);
        viewModel.toggleControls();
        expect(viewModel.state.areControlsVisible, isFalse);

        viewModel.toggleControls();

        expect(viewModel.state.areControlsVisible, isTrue);
      });

      test('toggle does not change reader position', () async {
        final viewModel = ReaderViewModel(
          navigationGateway: gateway,
          onCommand: commands.add,
        );
        await viewModel.openAtPosition(_fatihahPos);

        viewModel.toggleControls();
        viewModel.toggleControls();

        expect(viewModel.state.position, _fatihahPos);
        expect(viewModel.state.status, ReaderStatus.ready);
      });
    });

    group('selectAyah', () {
      test('sets the selected ayah position', () async {
        final viewModel = ReaderViewModel(
          navigationGateway: gateway,
          onCommand: commands.add,
        );
        await viewModel.openAtPosition(_fatihahPos);

        viewModel.selectAyah(_baqarahPos);

        expect(viewModel.state.isAyahSelected, isTrue);
        expect(viewModel.state.selectedAyahPosition, _baqarahPos);
      });

      test('does not alter current reader position', () async {
        final viewModel = ReaderViewModel(
          navigationGateway: gateway,
          onCommand: commands.add,
        );
        await viewModel.openAtPosition(_fatihahPos);

        viewModel.selectAyah(_baqarahPos);

        expect(viewModel.state.position, _fatihahPos);
      });

      test('clearAyahSelection removes the selection', () async {
        final viewModel = ReaderViewModel(
          navigationGateway: gateway,
          onCommand: commands.add,
        );
        await viewModel.openAtPosition(_fatihahPos);
        viewModel.selectAyah(_baqarahPos);
        expect(viewModel.state.isAyahSelected, isTrue);

        viewModel.clearAyahSelection();

        expect(viewModel.state.isAyahSelected, isFalse);
        expect(viewModel.state.selectedAyahPosition, isNull);
      });
    });

    group('saveLastPosition', () {
      test('delegates to position service and returns success', () async {
        final repo = _RecordingLastReadingRepository();
        final service = ReaderPositionService(repository: repo);
        final viewModel = ReaderViewModel(
          navigationGateway: gateway,
          positionService: service,
          onCommand: commands.add,
        );
        await viewModel.openAtPosition(_fatihahPos);

        final result = await viewModel.saveLastPosition();

        expect(result.isSuccess, isTrue);
        expect(repo.savedEntries, hasLength(1));
        expect(repo.savedEntries.first.position, _fatihahPos);
        service.dispose();
      });

      test('returns success when no position service is provided', () async {
        final viewModel = ReaderViewModel(
          navigationGateway: gateway,
          onCommand: commands.add,
        );
        await viewModel.openAtPosition(_fatihahPos);

        final result = await viewModel.saveLastPosition();

        expect(result.isSuccess, isTrue);
      });

      test('returns success when no position has been opened', () async {
        final repo = _RecordingLastReadingRepository();
        final service = ReaderPositionService(repository: repo);
        final viewModel = ReaderViewModel(
          navigationGateway: gateway,
          positionService: service,
          onCommand: commands.add,
        );

        final result = await viewModel.saveLastPosition();

        expect(result.isSuccess, isTrue);
        expect(repo.savedEntries, isEmpty);
        service.dispose();
      });

      test('surfaces persistence failure from position service', () async {
        final repo = _RecordingLastReadingRepository(
          saveError: const AppError(
            code: AppErrorCode.persistence,
            message: 'فشل حفظ الموقع.',
          ),
        );
        final service = ReaderPositionService(repository: repo);
        final viewModel = ReaderViewModel(
          navigationGateway: gateway,
          positionService: service,
          onCommand: commands.add,
        );
        await viewModel.openAtPosition(_fatihahPos);

        final result = await viewModel.saveLastPosition();

        expect(result.isFailure, isTrue);
        result.fold(
          onSuccess: (_) => fail('Expected failure'),
          onFailure: (error) {
            expect(error.code, AppErrorCode.persistence);
          },
        );
        service.dispose();
      });
    });
  });
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

final _baqarah142Pos = QuranPosition(
  surahNumber: 2,
  ayahNumber: 142,
  ayahUniqueNumber: 283,
  page: 22,
  juz: 2,
  hizb: 4,
  rub: 7,
  displaySurahName: 'البقرة',
  displayAyahLabel: 'البقرة ١٤٢',
);

final _yaseenPos = QuranPosition(
  surahNumber: 36,
  ayahNumber: 1,
  ayahUniqueNumber: 4032,
  page: 440,
  juz: 22,
  hizb: 44,
  rub: 175,
  displaySurahName: 'يس',
  displayAyahLabel: 'يس ١',
);

final _nasPos = QuranPosition(
  surahNumber: 114,
  ayahNumber: 1,
  ayahUniqueNumber: 6236,
  page: 604,
  juz: 30,
  hizb: 60,
  rub: 240,
  displaySurahName: 'الناس',
  displayAyahLabel: 'الناس ١',
);

final _testPositions = <QuranPosition>[
  _fatihahPos,
  _baqarahPos,
  _baqarah142Pos,
  _yaseenPos,
  _nasPos,
];

class _RecordingLastReadingRepository implements LastReadingRepository {
  _RecordingLastReadingRepository({this.saveError});

  final AppError? saveError;
  final savedEntries = <LastReadingEntry>[];

  @override
  Future<Result<LastReadingEntry?>> latestEntry() async =>
      const Success<LastReadingEntry?>(null);

  @override
  Future<Result<List<LastReadingEntry>>> recentEntries() async =>
      const Success<List<LastReadingEntry>>(<LastReadingEntry>[]);

  @override
  Future<Result<void>> saveEntry(LastReadingEntry entry) async {
    final error = saveError;
    if (error != null) return Failure<void>(error);
    savedEntries.add(entry);
    return const Success<void>(null);
  }
}
