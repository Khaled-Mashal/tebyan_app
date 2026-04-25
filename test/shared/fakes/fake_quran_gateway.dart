import 'package:flutter/widgets.dart';
import 'package:tebyan_app/features/quran/domain/quran_position.dart';
import 'package:tebyan_app/features/quran/infrastructure/quran_gateway.dart';

class FakeQuranGateway extends QuranGateway {
  FakeQuranGateway({
    List<QuranPosition>? positions,
    List<QuranSearchMatch>? searchMatches,
  }) : _positions = positions ?? _defaultPositions,
       _searchMatches = searchMatches ?? const <QuranSearchMatch>[];

  final List<QuranPosition> _positions;
  final List<QuranSearchMatch> _searchMatches;
  final List<QuranPosition> jumps = <QuranPosition>[];
  bool _isInitialized = false;

  static final _defaultPositions = <QuranPosition>[
    QuranPosition(
      surahNumber: 1,
      ayahNumber: 1,
      ayahUniqueNumber: 1,
      page: 1,
      juz: 1,
      hizb: 1,
      rub: 1,
      displaySurahName: 'Al-Fatihah',
      displayAyahLabel: 'Al-Fatihah 1',
    ),
  ];

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize({
    required String languageCode,
    required bool enableWordAudio,
    Map<int, List<Object>>? initialBookmarkAnchors,
  }) async {
    _isInitialized = true;
  }

  @override
  Future<QuranPosition> resolvePageStart(int page) async {
    return _positions.firstWhere((position) => position.page == page);
  }

  @override
  Future<QuranPosition> resolveSurahStart(int surahNumber) async {
    return _positions.firstWhere(
      (position) => position.surahNumber == surahNumber,
    );
  }

  @override
  Future<QuranPosition> resolveJuzStart(int juzNumber) async {
    return _positions.firstWhere((position) => position.juz == juzNumber);
  }

  @override
  Future<QuranPosition> resolveHizbStart(int hizbNumber) async {
    return _positions.firstWhere((position) => position.hizb == hizbNumber);
  }

  @override
  Future<QuranPosition> resolveRubStart(int rubNumber) async {
    return _positions.firstWhere((position) => position.rub == rubNumber);
  }

  @override
  Future<int> comparePositions(QuranPosition a, QuranPosition b) async {
    return a.page == b.page
        ? a.ayahNumber.compareTo(b.ayahNumber)
        : a.page.compareTo(b.page);
  }

  @override
  void jumpToPosition(QuranPosition position) {
    jumps.add(position);
  }

  @override
  void jumpToPage(int page) {
    jumpToPosition(_positions.firstWhere((position) => position.page == page));
  }

  @override
  void jumpToSurah(int surahNumber) {
    jumpToPosition(
      _positions.firstWhere((position) => position.surahNumber == surahNumber),
    );
  }

  @override
  void jumpToJuz(int juzNumber) {
    jumpToPosition(
      _positions.firstWhere((position) => position.juz == juzNumber),
    );
  }

  @override
  void jumpToHizb(int hizbNumber) {
    jumpToPosition(
      _positions.firstWhere((position) => position.hizb == hizbNumber),
    );
  }

  @override
  Future<SelectedAyah> getSelectedAyah(QuranPosition position) async {
    return SelectedAyah(
      position: position,
      text: 'نص آية اختباري',
      reference: '${position.surahNumber}:${position.ayahNumber}',
    );
  }

  @override
  Future<String> buildShareText(
    QuranPosition position, {
    String? translationId,
  }) async {
    return 'نص آية اختباري\n${position.surahNumber}:${position.ayahNumber}';
  }

  @override
  Future<void> copyAyah(QuranPosition position) async {}

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
    return AvailabilityState.available;
  }

  @override
  Future<AvailabilityState> ensureTranslationAvailable(String sourceId) async {
    return AvailabilityState.available;
  }

  @override
  Future<void> showTafsir(BuildContext context, QuranPosition position) async {}

  @override
  Future<void> showTranslation(
    BuildContext context,
    QuranPosition position,
  ) async {}

  @override
  Future<int?> createOrUpdateAnchor(QuranBookmarkAnchorInput annotation) async {
    return annotation.existingAnchorId ?? annotation.id.hashCode;
  }

  @override
  Future<void> removeAnchor(int quranLibraryBookmarkId) async {}

  @override
  Future<void> jumpToAnchor(
    int quranLibraryBookmarkId,
    QuranPosition fallback,
  ) async {
    jumpToPosition(fallback);
  }

  @override
  Future<List<QuranSearchMatch>> searchAyahs(String query) async {
    return _searchMatches
        .where((match) => match.source == QuranSearchMatchSource.ayah)
        .toList(growable: false);
  }

  @override
  Future<List<QuranSearchMatch>> searchSurahs(String query) async {
    return _searchMatches
        .where((match) => match.source == QuranSearchMatchSource.surah)
        .toList(growable: false);
  }

  @override
  Future<List<QuranSearchMatch>> searchAvailableTafsir(String query) async {
    return _searchMatches
        .where((match) => match.source == QuranSearchMatchSource.tafsir)
        .toList(growable: false);
  }
}
