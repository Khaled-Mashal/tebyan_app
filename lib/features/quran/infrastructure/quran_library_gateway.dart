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
  bool _isWordAudioInitialized = false;

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
        _isWordAudioInitialized = true;
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
  Future<QuranPosition> resolveAyahPosition(int ayahUQNumber) async {
    for (final surah in QuranLibrary.quranCtrl.surahs) {
      for (final ayah in surah.ayahs) {
        if (ayah.ayahUQNumber == ayahUQNumber) {
          return _positionFromAyah(ayah);
        }
      }
    }
    throw AppError(
      code: AppErrorCode.validation,
      message: 'تعذر العثور على الآية.',
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
  Future<void> playAyahAudio(
    BuildContext context,
    QuranPosition position, {
    bool playSingleAyah = true,
  }) async {
    final ayah = _findAyah(position);
    await _library.playAyah(
      context: context,
      currentAyahUniqueNumber: ayah.ayahUQNumber,
      playSingleAyah: playSingleAyah,
      isDarkMode: false,
    );
  }

  @override
  Future<List<QuranAyahWord>> getAyahWords(QuranPosition position) async {
    final selected = await getSelectedAyah(position);
    final words = _splitAyahWords(selected.text);
    return <QuranAyahWord>[
      for (var i = 0; i < words.length; i++)
        QuranAyahWord(
          selection: QuranWordSelection(
            position: selected.position,
            wordNumber: i + 1,
          ),
          text: words[i],
        ),
    ];
  }

  @override
  Future<void> playWordAudio(QuranWordSelection selection) async {
    _ensureWordAudioInitialized();
    await _library.playWordAudioByNumbers(
      surahNumber: selection.position.surahNumber,
      ayahNumber: selection.position.ayahNumber,
      wordNumber: selection.wordNumber,
    );
  }

  @override
  Future<void> playAyahWordsAudio(QuranPosition position) async {
    _ensureWordAudioInitialized();
    await _library.playAyahWordsAudioByNumbers(
      surahNumber: position.surahNumber,
      ayahNumber: position.ayahNumber,
    );
  }

  @override
  Future<QuranWordInfoResult> getWordInfo(
    QuranWordSelection selection, {
    QuranWordInfoKind kind = QuranWordInfoKind.recitations,
  }) async {
    final mappedKind = _mapWordInfoKind(kind);
    if (!_library.isWordInfoKindDownloaded(mappedKind)) {
      return QuranWordInfoResult(
        kind: kind,
        availability: AvailabilityState.unavailable,
      );
    }

    final info = await WordInfoCtrl.instance.getWordInfo(
      kind: mappedKind,
      ref: WordRef(
        surahNumber: selection.position.surahNumber,
        ayahNumber: selection.position.ayahNumber,
        wordNumber: selection.wordNumber,
      ),
    );

    if (info == null || info.content.trim().isEmpty) {
      return QuranWordInfoResult(
        kind: kind,
        availability: AvailabilityState.available,
        word: info?.word,
      );
    }

    return QuranWordInfoResult(
      kind: kind,
      availability: AvailabilityState.available,
      word: info.word,
      content: info.content,
      hasKhilaf: info.hasKhilaf,
    );
  }

  @override
  Future<AvailabilityState> downloadWordInfoKind(QuranWordInfoKind kind) async {
    final mappedKind = _mapWordInfoKind(kind);
    try {
      await _library.downloadWordInfoKind(kind: mappedKind);
      return _library.isWordInfoKindDownloaded(mappedKind)
          ? AvailabilityState.available
          : AvailabilityState.unavailable;
    } catch (_) {
      return AvailabilityState.unavailable;
    }
  }

  @override
  Future<void> showWordInfo(
    BuildContext context,
    QuranWordSelection selection, {
    QuranWordInfoKind kind = QuranWordInfoKind.recitations,
  }) async {
    await getWordInfo(selection, kind: kind);
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
    try {
      final collection = _library.tafsirAndTraslationsCollection;
      final sources = <TafsirSourceSummary>[];
      for (var i = 0; i < collection.length; i++) {
        final item = collection[i];
        if (item.isTafsir && !item.isTranslation) {
          sources.add(
            TafsirSourceSummary(
              id: item.fileName,
              displayName: item.bookName.isNotEmpty ? item.bookName : item.name,
              availability: _library.getTafsirDownloaded(i)
                  ? AvailabilityState.available
                  : AvailabilityState.unavailable,
            ),
          );
        }
      }
      return sources;
    } catch (_) {
      return const <TafsirSourceSummary>[];
    }
  }

  @override
  Future<List<TranslationSourceSummary>> listTranslationSources() async {
    try {
      final collection = _library.tafsirAndTraslationsCollection;
      final sources = <TranslationSourceSummary>[];
      for (var i = 0; i < collection.length; i++) {
        final item = collection[i];
        if (item.isTranslation) {
          sources.add(
            TranslationSourceSummary(
              id: item.fileName,
              displayName: item.bookName.isNotEmpty ? item.bookName : item.name,
              availability: _library.getTafsirDownloaded(i)
                  ? AvailabilityState.available
                  : AvailabilityState.unavailable,
            ),
          );
        }
      }
      return sources;
    } catch (_) {
      return const <TranslationSourceSummary>[];
    }
  }

  @override
  Future<List<QuranExplanationText>> getTafsir(
    QuranPosition position, {
    String? sourceId,
  }) async {
    final ayah = _findAyah(position);
    final index = _resolveTafsirIndex(sourceId);
    if (index == null) return const <QuranExplanationText>[];

    final item = _library.tafsirAndTraslationsCollection[index];
    final sourceName = _sourceName(item);
    if (!_library.getTafsirDownloaded(index)) {
      return <QuranExplanationText>[
        QuranExplanationText(
          sourceId: item.fileName,
          sourceName: sourceName,
          text: '',
          availability: AvailabilityState.unavailable,
        ),
      ];
    }

    final previousIndex = TafsirCtrl.instance.radioValue.value;
    final previousDb = TafsirCtrl.instance.selectedDBName;
    try {
      TafsirCtrl.instance.radioValue.value = index;
      TafsirCtrl.instance.selectedDBName = item.databaseName;
      final rows = await _library.getTafsirOfPage(
        pageNumber: ayah.page,
        databaseName: item.databaseName,
      );
      return rows
          .where(
            (row) =>
                row.surahNum == ayah.surahNumber &&
                row.ayahNum == ayah.ayahNumber &&
                row.tafsirText.trim().isNotEmpty,
          )
          .map(
            (row) => QuranExplanationText(
              sourceId: item.fileName,
              sourceName: sourceName,
              text: row.tafsirText.trim(),
            ),
          )
          .toList(growable: false);
    } finally {
      TafsirCtrl.instance.radioValue.value = previousIndex;
      TafsirCtrl.instance.selectedDBName = previousDb;
    }
  }

  @override
  Future<List<QuranExplanationText>> getTranslation(
    QuranPosition position, {
    String? sourceId,
  }) async {
    final index = _resolveTranslationIndex(sourceId);
    if (index == null) return const <QuranExplanationText>[];

    final item = _library.tafsirAndTraslationsCollection[index];
    final sourceName = _sourceName(item);
    if (!_library.getTafsirDownloaded(index)) {
      return <QuranExplanationText>[
        QuranExplanationText(
          sourceId: item.fileName,
          sourceName: sourceName,
          text: '',
          availability: AvailabilityState.unavailable,
        ),
      ];
    }

    final previousIndex = TafsirCtrl.instance.radioValue.value;
    final previousLang = TafsirCtrl.instance.translationLangCode;
    try {
      TafsirCtrl.instance.radioValue.value = index;
      TafsirCtrl.instance.translationLangCode = item.fileName;
      await _library.fetchTranslation();

      final matches = _library.translationList.where(
        (translation) =>
            translation.surahNumber == position.surahNumber &&
            translation.ayahNumber == position.ayahNumber &&
            translation.cleanText.trim().isNotEmpty,
      );
      return matches
          .map(
            (translation) => QuranExplanationText(
              sourceId: item.fileName,
              sourceName: sourceName,
              text: translation.cleanText.trim(),
            ),
          )
          .toList(growable: false);
    } finally {
      TafsirCtrl.instance.radioValue.value = previousIndex;
      TafsirCtrl.instance.translationLangCode = previousLang;
    }
  }

  @override
  Future<AvailabilityState> ensureTafsirAvailable(String sourceId) async {
    return _checkAvailability(sourceId);
  }

  @override
  Future<AvailabilityState> ensureTranslationAvailable(String sourceId) async {
    return _checkAvailability(sourceId);
  }

  @override
  Future<void> showTafsir(BuildContext context, QuranPosition position) async {
    await getTafsir(position);
  }

  @override
  Future<void> showTranslation(
    BuildContext context,
    QuranPosition position,
  ) async {
    await getTranslation(position);
  }

  @override
  Future<int?> createOrUpdateAnchor(QuranBookmarkAnchorInput annotation) async {
    try {
      _library.setBookmark(
        surahName: annotation.displayName,
        ayahNumber: annotation.position.ayahNumber,
        ayahId:
            annotation.position.ayahUniqueNumber ??
            annotation.position.ayahNumber,
        page: annotation.position.page,
        bookmarkId: annotation.colorValue,
      );
      return annotation.colorValue;
    } catch (_) {
      return annotation.existingAnchorId;
    }
  }

  @override
  Future<void> removeAnchor(int quranLibraryBookmarkId) async {
    try {
      _library.removeBookmark(bookmarkId: quranLibraryBookmarkId);
    } catch (_) {}
  }

  @override
  Future<void> jumpToAnchor(
    int quranLibraryBookmarkId,
    QuranPosition fallback,
  ) async {
    try {
      final bookmarks = _library.allBookmarks;
      final match = bookmarks.where(
        (b) => b.id == quranLibraryBookmarkId && b.page != -1,
      );
      if (match.isNotEmpty) {
        _library.jumpToBookmark(match.first);
        return;
      }
    } catch (_) {}
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

  AvailabilityState _checkAvailability(String sourceId) {
    try {
      final collection = _library.tafsirAndTraslationsCollection;
      for (var i = 0; i < collection.length; i++) {
        if (collection[i].fileName == sourceId) {
          return _library.getTafsirDownloaded(i)
              ? AvailabilityState.available
              : AvailabilityState.unavailable;
        }
      }
      return AvailabilityState.unsupported;
    } catch (_) {
      return AvailabilityState.unsupported;
    }
  }

  int? _resolveTafsirIndex(String? sourceId) {
    final collection = _library.tafsirAndTraslationsCollection;
    if (sourceId != null) {
      for (var i = 0; i < collection.length; i++) {
        final item = collection[i];
        if (item.fileName == sourceId && item.isTafsir) return i;
      }
      return null;
    }

    for (var i = 0; i < collection.length; i++) {
      final item = collection[i];
      if (item.isTafsir && _library.getTafsirDownloaded(i)) return i;
    }
    for (var i = 0; i < collection.length; i++) {
      if (collection[i].isTafsir) return i;
    }
    return null;
  }

  int? _resolveTranslationIndex(String? sourceId) {
    final collection = _library.tafsirAndTraslationsCollection;
    if (sourceId != null) {
      for (var i = 0; i < collection.length; i++) {
        final item = collection[i];
        if (item.fileName == sourceId && item.isTranslation) return i;
      }
      return null;
    }

    for (var i = 0; i < collection.length; i++) {
      final item = collection[i];
      if (item.isTranslation && _library.getTafsirDownloaded(i)) return i;
    }
    for (var i = 0; i < collection.length; i++) {
      if (collection[i].isTranslation) return i;
    }
    return null;
  }

  String _sourceName(TafsirNameModel item) {
    return item.bookName.isNotEmpty ? item.bookName : item.name;
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

  List<String> _splitAyahWords(String text) {
    return text
        .replaceAll(RegExp(r'[\u06DD۝﴿﴾]'), ' ')
        .split(RegExp(r'\s+'))
        .map((word) => word.trim())
        .where((word) => word.isNotEmpty)
        .toList(growable: false);
  }

  void _ensureWordAudioInitialized() {
    if (_isWordAudioInitialized) return;
    QuranLibrary.initWordAudio();
    _isWordAudioInitialized = true;
  }

  WordInfoKind _mapWordInfoKind(QuranWordInfoKind kind) {
    return switch (kind) {
      QuranWordInfoKind.recitations => WordInfoKind.recitations,
      QuranWordInfoKind.morphology => WordInfoKind.tasreef,
      QuranWordInfoKind.grammar => WordInfoKind.eerab,
    };
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
