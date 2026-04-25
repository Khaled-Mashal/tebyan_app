# Contract: Quran Adapter

**Purpose**: Define the app-facing contract for all Quran capability access. The implementation must wrap `quran_library: 4.0.1` and prevent direct quran_library singleton calls from presentation widgets.

## Boundary Rules

- Implementations live under `lib/features/quran/infrastructure/`.
- Domain/application code depends on this contract, not on quran_library types.
- The adaptor may translate from quran_library models to Raqeem value objects.
- The adaptor must not generate Quran text, reorder Quran data, normalize Quran wording, or cache a Quran corpus.

## Initialization

```dart
abstract interface class QuranGateway {
  Future<void> initialize({
    required String languageCode,
    required bool enableWordAudio,
    Map<int, List<Object>>? initialBookmarkAnchors,
  });

  bool get isInitialized;
}
```

**Acceptance**:

- `initialize` calls `QuranLibrary.init()` before any Quran screen renders.
- If `enableWordAudio` is true, it calls `QuranLibrary.initWordAudio()` after init.
- Initialization failure is surfaced as a recoverable app startup error state.

## Metadata and Navigation

```dart
abstract interface class QuranNavigationGateway {
  Future<QuranPosition> resolvePageStart(int page);
  Future<QuranPosition> resolveSurahStart(int surahNumber);
  Future<QuranPosition> resolveJuzStart(int juzNumber);
  Future<QuranPosition> resolveHizbStart(int hizbNumber);
  Future<QuranPosition> resolveRubStart(int rubNumber);
  Future<int> comparePositions(QuranPosition a, QuranPosition b);

  void jumpToPosition(QuranPosition position);
  void jumpToPage(int page);
  void jumpToSurah(int surahNumber);
  void jumpToJuz(int juzNumber);
  void jumpToHizb(int hizbNumber);
}
```

**Acceptance**:

- Page inputs are validated against `1..604`.
- Surah inputs are validated against `1..114`.
- Invalid inputs return domain validation failures before calling quran_library.
- Rub navigation uses quran_library metadata where exposed; if not directly exposed, it is resolved through quran_library page/ayah metadata, not app-owned Quran tables.

## Reader Widgets

```dart
abstract interface class QuranReaderWidgetFactory {
  Widget buildFullReader({
    required BuildContext context,
    required RaqeemReaderStyle style,
    required String languageCode,
    required ValueChanged<QuranPosition> onPositionChanged,
    required void Function(QuranPosition position, Offset globalPosition) onAyahSelected,
  });

  Widget buildPageRange({
    required BuildContext context,
    required QuranRange range,
    required List<QuranPosition> highlightedPositions,
    required RaqeemReaderStyle style,
  });
}
```

**Acceptance**:

- Full reader composes `QuranLibraryScreen`.
- Page/range reader composes `QuranPagesScreen`.
- The app passes Raqeem theme colors/styles into quran_library style objects.
- Quran screens use `useMaterial3: false` in the surrounding theme.

## Selection and Ayah Actions

```dart
abstract interface class QuranSelectionGateway {
  Future<SelectedAyah> getSelectedAyah(QuranPosition position);
  Future<String> buildShareText(QuranPosition position, {String? translationId});
  Future<void> copyAyah(QuranPosition position);
}
```

**Acceptance**:

- Selected ayah text/reference comes from quran_library models/callbacks.
- Copy/share never mutate Quran text.
- Missing translation is reported as unavailable rather than filled by app-generated text.

## Tafsir and Translation

```dart
abstract interface class QuranExplanationGateway {
  Future<List<TafsirSourceSummary>> listTafsirSources();
  Future<List<TranslationSourceSummary>> listTranslationSources();
  Future<AvailabilityState> ensureTafsirAvailable(String sourceId);
  Future<AvailabilityState> ensureTranslationAvailable(String sourceId);
  Future<void> showTafsir(BuildContext context, QuranPosition position);
  Future<void> showTranslation(BuildContext context, QuranPosition position);
}
```

**Acceptance**:

- Source listing, download checks, and display use quran_library APIs.
- If source selection is limited by quran_library, the UI documents the unavailable state.

## Bookmarks

```dart
abstract interface class QuranBookmarkGateway {
  Future<int?> createOrUpdateAnchor(BookmarkAnnotation annotation);
  Future<void> removeAnchor(int quranLibraryBookmarkId);
  Future<void> jumpToAnchor(int quranLibraryBookmarkId, QuranPosition fallback);
}
```

**Acceptance**:

- quran_library bookmark APIs are used for anchor behavior.
- Raqeem stores note/type/color metadata separately.
- If quran_library supports only predefined bookmark groups/colors, the adaptor maps Raqeem colors to the closest supported anchor and preserves exact metadata in SQLite.

## Search

```dart
abstract interface class QuranSearchGateway {
  Future<List<SearchResult>> searchAyahs(String query);
  Future<List<SearchResult>> searchSurahs(String query);
  Future<List<SearchResult>> searchAvailableTafsir(String query);
}
```

**Acceptance**:

- Ayah and surah search use quran_library.
- Tafsir search is implemented only if quran_library exposes it for available/downloaded tafsir; otherwise return an unsupported availability result.

## Audio

```dart
abstract interface class QuranAudioGateway {
  Future<void> playAyah(QuranPosition position, {required bool singleAyah});
  Future<void> playSurah(int surahNumber);
  Future<void> seekNextAyah(QuranPosition current);
  Future<void> seekPreviousAyah(QuranPosition current);
  Future<void> seekNextSurah();
  Future<void> seekPreviousSurah();
  Future<void> downloadSurah(int surahNumber);
  Future<void> cancelDownload();
  Future<void> playLastPosition();

  Stream<PlaybackSession> watchPlayback();
}
```

**Acceptance**:

- Implementation uses quran_library audio APIs.
- Range/page/wird repeat is an application service that sequences quran_library ayah playback.
- Offline uncached audio returns `PlaybackSession.state = unavailable`.
- No custom audio URL catalog is introduced by the app.

