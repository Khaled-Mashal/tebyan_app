import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:quran_library/quran_library.dart';

import '../../../shared/errors/app_error.dart';
import '../domain/quran_position.dart';
import 'quran_gateway.dart';

class QuranLibraryGateway extends QuranGateway {
  QuranLibraryGateway({QuranLibrary? library})
    : _library = library ?? QuranLibrary();

  final QuranLibrary _library;
  bool _isInitialized = false;

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize({
    required String languageCode,
    required bool enableWordAudio,
    Map<int, List<Object>>? initialBookmarkAnchors,
  }) async {
    try {
      await QuranLibrary.init();
      if (enableWordAudio) {
        QuranLibrary.initWordAudio();
      }
      _isInitialized = true;
    } catch (error, stackTrace) {
      throw AppError.fromException(
        error,
        stackTrace,
        code: AppErrorCode.startup,
        message: 'تعذر تهيئة مكتبة القرآن.',
      );
    }
  }

  @override
  Future<QuranPosition> resolvePageStart(int page) async {
    _validatePage(page);
    final ayah = QuranLibrary.quranCtrl.getPageAyahsByIndex(page - 1).first;
    return _positionFromAyah(ayah);
  }

  @override
  Future<QuranPosition> resolveSurahStart(int surahNumber) async {
    _validateSurah(surahNumber);
    final ayah = QuranLibrary.quranCtrl.surahs[surahNumber - 1].ayahs.first;
    return _positionFromAyah(ayah);
  }

  @override
  Future<QuranPosition> resolveJuzStart(int juzNumber) async {
    _validateRange('juzNumber', juzNumber, 1, 30);
    return _positionFromAyah(QuranLibrary.quranCtrl.getJuzStartPage(juzNumber));
  }

  @override
  Future<QuranPosition> resolveHizbStart(int hizbNumber) async {
    _validateRange('hizbNumber', hizbNumber, 1, 60);
    return _positionFromAyah(
      QuranLibrary.quranCtrl.getHizbStartPage(hizbNumber * 4 - 3),
    );
  }

  @override
  Future<QuranPosition> resolveRubStart(int rubNumber) async {
    _validateRange('rubNumber', rubNumber, 1, 240);
    return _positionFromAyah(
      QuranLibrary.quranCtrl.getHizbStartPage(rubNumber),
    );
  }

  @override
  Future<int> comparePositions(QuranPosition a, QuranPosition b) async {
    final aUnique = a.ayahUniqueNumber;
    final bUnique = b.ayahUniqueNumber;
    if (aUnique != null && bUnique != null && aUnique != bUnique) {
      return aUnique.compareTo(bUnique);
    }
    final pageComparison = a.page.compareTo(b.page);
    if (pageComparison != 0) {
      return pageComparison;
    }
    final surahComparison = a.surahNumber.compareTo(b.surahNumber);
    if (surahComparison != 0) {
      return surahComparison;
    }
    return a.ayahNumber.compareTo(b.ayahNumber);
  }

  @override
  void jumpToPosition(QuranPosition position) {
    _validatePage(position.page);
    if (position.ayahUniqueNumber != null) {
      _library.jumpToAyah(position.page, position.ayahUniqueNumber!);
      return;
    }
    _library.jumpToPage(position.page);
  }

  @override
  void jumpToPage(int page) {
    _validatePage(page);
    _library.jumpToPage(page);
  }

  @override
  void jumpToSurah(int surahNumber) {
    _validateSurah(surahNumber);
    _library.jumpToSurah(surahNumber);
  }

  @override
  void jumpToJuz(int juzNumber) {
    _validateRange('juzNumber', juzNumber, 1, 30);
    _library.jumpToJoz(juzNumber);
  }

  @override
  void jumpToHizb(int hizbNumber) {
    _validateRange('hizbNumber', hizbNumber, 1, 60);
    _library.jumpToHizb(hizbNumber);
  }

  @override
  Future<SelectedAyah> getSelectedAyah(QuranPosition position) async {
    final ayah = _findAyah(position);
    final reference = _referenceFor(position, ayah);
    return SelectedAyah(
      position: _positionFromAyah(ayah),
      text: ayah.text,
      reference: reference,
    );
  }

  @override
  Future<String> buildShareText(
    QuranPosition position, {
    String? translationId,
  }) async {
    final selected = await getSelectedAyah(position);
    return '${selected.text}\n${selected.reference}';
  }

  @override
  Future<void> copyAyah(QuranPosition position) async {
    await Clipboard.setData(
      ClipboardData(text: await buildShareText(position)),
    );
  }

  @override
  Future<List<TafsirSourceSummary>> listTafsirSources() async {
    return const <TafsirSourceSummary>[];
  }

  @override
  Future<List<TranslationSourceSummary>> listTranslationSources() async {
    return const <TranslationSourceSummary>[];
  }

  @override
  Future<AvailabilityState> ensureTafsirAvailable(String sourceId) async {
    return AvailabilityState.unsupported;
  }

  @override
  Future<AvailabilityState> ensureTranslationAvailable(String sourceId) async {
    return AvailabilityState.unsupported;
  }

  @override
  Future<void> showTafsir(BuildContext context, QuranPosition position) async {
    jumpToPosition(position);
  }

  @override
  Future<void> showTranslation(
    BuildContext context,
    QuranPosition position,
  ) async {
    jumpToPosition(position);
  }

  @override
  Future<int?> createOrUpdateAnchor(QuranBookmarkAnchorInput annotation) async {
    return annotation.existingAnchorId;
  }

  @override
  Future<void> removeAnchor(int quranLibraryBookmarkId) async {
    // quran_library bookmark removal is integrated in the US3 annotation task.
  }

  @override
  Future<void> jumpToAnchor(
    int quranLibraryBookmarkId,
    QuranPosition fallback,
  ) async {
    jumpToPosition(fallback);
  }

  @override
  Future<List<QuranSearchMatch>> searchAyahs(String query) async {
    final normalized = query.trim();
    if (normalized.isEmpty) {
      return const <QuranSearchMatch>[];
    }

    return _library
        .search(normalized)
        .map((ayah) {
          final position = _positionFromAyah(ayah);
          return QuranSearchMatch(
            id: 'ayah-${ayah.ayahUQNumber}',
            source: QuranSearchMatchSource.ayah,
            title: _referenceFor(position, ayah),
            snippet: ayah.text,
            position: position,
          );
        })
        .toList(growable: false);
  }

  @override
  Future<List<QuranSearchMatch>> searchSurahs(String query) async {
    final normalized = query.trim();
    if (normalized.isEmpty) {
      return const <QuranSearchMatch>[];
    }

    return _library
        .surahSearch(normalized)
        .map((surah) {
          final ayah = surah.ayahs.first;
          return QuranSearchMatch(
            id: 'surah-${surah.surahNumber}',
            source: QuranSearchMatchSource.surah,
            title: surah.arabicName,
            snippet: surah.englishName,
            position: _positionFromAyah(ayah),
          );
        })
        .toList(growable: false);
  }

  @override
  Future<List<QuranSearchMatch>> searchAvailableTafsir(String query) async {
    if (query.trim().isEmpty) {
      return const <QuranSearchMatch>[];
    }
    return const <QuranSearchMatch>[
      QuranSearchMatch(
        id: 'tafsir-unsupported',
        source: QuranSearchMatchSource.tafsir,
        title: 'البحث في التفسير غير متاح',
        availability: AvailabilityState.unsupported,
      ),
    ];
  }

  QuranPosition _positionFromAyah(AyahModel ayah) {
    final surahNumber = ayah.surahNumber ?? 1;
    final surahName = ayah.arabicName ?? ayah.englishName ?? '';
    return QuranPosition(
      surahNumber: surahNumber,
      ayahNumber: ayah.ayahNumber,
      ayahUniqueNumber: ayah.ayahUQNumber,
      page: ayah.page,
      juz: ayah.juz,
      hizb: ayah.hizb,
      rub: ayah.quarter,
      displaySurahName: surahName,
      displayAyahLabel: '$surahName ${ayah.ayahNumber}'.trim(),
    );
  }

  AyahModel _findAyah(QuranPosition position) {
    _validateSurah(position.surahNumber);
    final surah = QuranLibrary.quranCtrl.surahs[position.surahNumber - 1];
    return surah.ayahs.firstWhere(
      (ayah) => ayah.ayahNumber == position.ayahNumber,
      orElse: () => throw AppError(
        code: AppErrorCode.validation,
        message: 'تعذر العثور على الآية ${position.ayahNumber}.',
      ),
    );
  }

  String _referenceFor(QuranPosition position, AyahModel ayah) {
    final surahName = ayah.arabicName ?? ayah.englishName ?? '';
    return '$surahName ${position.surahNumber}:${position.ayahNumber}'.trim();
  }

  void _validateSurah(int surahNumber) {
    _validateRange('surahNumber', surahNumber, 1, 114);
  }

  void _validatePage(int page) {
    _validateRange('page', page, 1, 604);
  }

  void _validateRange(String name, int value, int min, int max) {
    if (value < min || value > max) {
      throw AppError(
        code: AppErrorCode.validation,
        message: 'قيمة $name يجب أن تكون بين $min و $max.',
      );
    }
  }
}
