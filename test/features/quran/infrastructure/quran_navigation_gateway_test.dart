import 'package:flutter_test/flutter_test.dart';
import 'package:tebyan_app/features/quran/domain/quran_position.dart';
import 'package:tebyan_app/features/quran/infrastructure/quran_gateway.dart';
import 'package:tebyan_app/shared/errors/app_error.dart';
import '../../../shared/fakes/fake_quran_gateway.dart';

void main() {
  group('QuranNavigationGateway', () {
    late FakeQuranGateway gateway;

    setUp(() {
      gateway = FakeQuranGateway(positions: _testPositions);
    });

    group('resolvePageStart', () {
      test('resolves first page position', () async {
        final pos = await gateway.resolvePageStart(1);
        expect(pos.page, 1);
        expect(pos.surahNumber, 1);
        expect(pos.juz, 1);
      });

      test('resolves last page position', () async {
        final pos = await gateway.resolvePageStart(604);
        expect(pos.page, 604);
        expect(pos.surahNumber, 114);
        expect(pos.juz, 30);
      });

      test('resolves a middle page position', () async {
        final pos = await gateway.resolvePageStart(22);
        expect(pos.page, 22);
        expect(pos.surahNumber, 2);
      });
    });

    group('resolveSurahStart', () {
      test('resolves first surah position', () async {
        final pos = await gateway.resolveSurahStart(1);
        expect(pos.surahNumber, 1);
        expect(pos.page, 1);
      });

      test('resolves last surah position', () async {
        final pos = await gateway.resolveSurahStart(114);
        expect(pos.surahNumber, 114);
        expect(pos.page, 604);
      });

      test('resolves a middle surah position', () async {
        final pos = await gateway.resolveSurahStart(36);
        expect(pos.surahNumber, 36);
        expect(pos.page, 440);
      });
    });

    group('resolveJuzStart', () {
      test('resolves first juz position', () async {
        final pos = await gateway.resolveJuzStart(1);
        expect(pos.juz, 1);
        expect(pos.page, 1);
      });

      test('resolves last juz position', () async {
        final pos = await gateway.resolveJuzStart(30);
        expect(pos.juz, 30);
        expect(pos.page, 604);
      });

      test('resolves a middle juz position', () async {
        final pos = await gateway.resolveJuzStart(22);
        expect(pos.juz, 22);
        expect(pos.page, 440);
      });
    });

    group('resolveHizbStart', () {
      test('resolves first hizb position', () async {
        final pos = await gateway.resolveHizbStart(1);
        expect(pos.hizb, 1);
      });

      test('resolves last hizb position', () async {
        final pos = await gateway.resolveHizbStart(60);
        expect(pos.hizb, 60);
        expect(pos.page, 604);
      });

      test('resolves a middle hizb position', () async {
        final pos = await gateway.resolveHizbStart(4);
        expect(pos.hizb, 4);
        expect(pos.page, 22);
      });
    });

    group('resolveRubStart', () {
      test('resolves first rub position', () async {
        final pos = await gateway.resolveRubStart(1);
        expect(pos.rub, 1);
        expect(pos.page, 1);
      });

      test('resolves last rub position', () async {
        final pos = await gateway.resolveRubStart(240);
        expect(pos.rub, 240);
        expect(pos.page, 604);
      });

      test('resolves a middle rub position', () async {
        final pos = await gateway.resolveRubStart(7);
        expect(pos.rub, 7);
        expect(pos.page, 22);
      });
    });

    group('comparePositions', () {
      test('returns negative when first is before second by page', () async {
        final result = await gateway.comparePositions(_fatihahPos, _nasPos);
        expect(result, lessThan(0));
      });

      test('returns positive when first is after second by page', () async {
        final result = await gateway.comparePositions(_nasPos, _fatihahPos);
        expect(result, greaterThan(0));
      });

      test('returns zero when positions are identical', () async {
        final result = await gateway.comparePositions(_fatihahPos, _fatihahPos);
        expect(result, 0);
      });

      test('compares by ayah number when pages are equal', () async {
        final a = QuranPosition(
          surahNumber: 1,
          ayahNumber: 1,
          page: 1,
          displaySurahName: 'الفاتحة',
          displayAyahLabel: '١',
        );
        final b = QuranPosition(
          surahNumber: 1,
          ayahNumber: 7,
          page: 1,
          displaySurahName: 'الفاتحة',
          displayAyahLabel: '٧',
        );
        final result = await gateway.comparePositions(a, b);
        expect(result, lessThan(0));
      });
    });

    group('jump methods', () {
      test('jumpToPage records the target position', () {
        gateway.jumpToPage(1);
        expect(gateway.jumps, hasLength(1));
        expect(gateway.jumps.single.page, 1);
      });

      test('jumpToSurah records the target position', () {
        gateway.jumpToSurah(2);
        expect(gateway.jumps, hasLength(1));
        expect(gateway.jumps.single.surahNumber, 2);
      });

      test('jumpToJuz records the target position', () {
        gateway.jumpToJuz(1);
        expect(gateway.jumps, hasLength(1));
        expect(gateway.jumps.single.juz, 1);
      });

      test('jumpToHizb records the target position', () {
        gateway.jumpToHizb(1);
        expect(gateway.jumps, hasLength(1));
        expect(gateway.jumps.single.hizb, 1);
      });

      test('jumpToPosition records the exact position', () {
        gateway.jumpToPosition(_yaseenPos);
        expect(gateway.jumps, hasLength(1));
        expect(gateway.jumps.single, _yaseenPos);
      });
    });

    group('invalid input validation', () {
      late _ValidatingGateway validating;

      setUp(() {
        validating = _ValidatingGateway(gateway);
      });

      test('resolvePageStart throws for page zero', () {
        expect(() => validating.resolvePageStart(0), throwsA(isA<AppError>()));
      });

      test('resolvePageStart throws for page 605', () {
        expect(
          () => validating.resolvePageStart(605),
          throwsA(isA<AppError>()),
        );
      });

      test('resolveSurahStart throws for surah zero', () {
        expect(() => validating.resolveSurahStart(0), throwsA(isA<AppError>()));
      });

      test('resolveSurahStart throws for surah 115', () {
        expect(
          () => validating.resolveSurahStart(115),
          throwsA(isA<AppError>()),
        );
      });

      test('resolveJuzStart throws for juz zero', () {
        expect(() => validating.resolveJuzStart(0), throwsA(isA<AppError>()));
      });

      test('resolveJuzStart throws for juz 31', () {
        expect(() => validating.resolveJuzStart(31), throwsA(isA<AppError>()));
      });

      test('resolveHizbStart throws for hizb zero', () {
        expect(() => validating.resolveHizbStart(0), throwsA(isA<AppError>()));
      });

      test('resolveHizbStart throws for hizb 61', () {
        expect(() => validating.resolveHizbStart(61), throwsA(isA<AppError>()));
      });

      test('resolveRubStart throws for rub zero', () {
        expect(() => validating.resolveRubStart(0), throwsA(isA<AppError>()));
      });

      test('resolveRubStart throws for rub 241', () {
        expect(() => validating.resolveRubStart(241), throwsA(isA<AppError>()));
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

final _baqarahStart = QuranPosition(
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

final _baqarah142 = QuranPosition(
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
  _baqarahStart,
  _baqarah142,
  _yaseenPos,
  _nasPos,
];

class _ValidatingGateway implements QuranNavigationGateway {
  _ValidatingGateway(this._inner);

  final QuranNavigationGateway _inner;

  @override
  Future<QuranPosition> resolvePageStart(int page) async {
    _validate('page', page, 1, 604);
    return _inner.resolvePageStart(page);
  }

  @override
  Future<QuranPosition> resolveSurahStart(int surahNumber) async {
    _validate('surahNumber', surahNumber, 1, 114);
    return _inner.resolveSurahStart(surahNumber);
  }

  @override
  Future<QuranPosition> resolveJuzStart(int juzNumber) async {
    _validate('juzNumber', juzNumber, 1, 30);
    return _inner.resolveJuzStart(juzNumber);
  }

  @override
  Future<QuranPosition> resolveHizbStart(int hizbNumber) async {
    _validate('hizbNumber', hizbNumber, 1, 60);
    return _inner.resolveHizbStart(hizbNumber);
  }

  @override
  Future<QuranPosition> resolveRubStart(int rubNumber) async {
    _validate('rubNumber', rubNumber, 1, 240);
    return _inner.resolveRubStart(rubNumber);
  }

  @override
  Future<QuranPosition> resolveAyahPosition(int ayahUQNumber) =>
      _inner.resolveAyahPosition(ayahUQNumber);

  @override
  Future<int> comparePositions(QuranPosition a, QuranPosition b) =>
      _inner.comparePositions(a, b);

  @override
  void jumpToPosition(QuranPosition position) =>
      _inner.jumpToPosition(position);

  @override
  void jumpToPage(int page) => _inner.jumpToPage(page);

  @override
  void jumpToSurah(int surahNumber) => _inner.jumpToSurah(surahNumber);

  @override
  void jumpToJuz(int juzNumber) => _inner.jumpToJuz(juzNumber);

  @override
  void jumpToHizb(int hizbNumber) => _inner.jumpToHizb(hizbNumber);

  void _validate(String name, int value, int min, int max) {
    if (value < min || value > max) {
      throw AppError(
        code: AppErrorCode.validation,
        message: 'قيمة $name يجب أن تكون بين $min و $max.',
      );
    }
  }
}
