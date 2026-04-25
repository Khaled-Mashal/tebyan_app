# Research: Raqeem Interactive Quran App

**Feature**: `001-raqeem-quran-app`  
**Date**: 2026-04-25  
**Research Rule**: Context7 first for quran_library, Flutter architecture, and every added or changed dependency. Official pub.dev or upstream documentation is used only when Context7 cannot resolve a package.

## Decision: Use `quran_library: 4.0.1` As the Quran Platform

**Rationale**: Context7 resolved `/alheekmahlib/quran_library` and documented a comprehensive Flutter Quran package with Medina mushaf display, page widgets, navigation, bookmarks, advanced search, tafsir, translations, audio playback, and download support. Local inspection of `quran_library-4.0.1` confirmed:

- Startup requires `WidgetsFlutterBinding.ensureInitialized()` followed by `QuranLibrary.init()`.
- Optional word audio is enabled by `QuranLibrary.initWordAudio()` after initialization.
- Full Quran display is available through `QuranLibraryScreen(parentContext: context, ...)`.
- Partial page/range display and highlighting are available through `QuranPagesScreen`.
- Programmatic navigation exists for page, ayah, surah, juz/jozz, hizb, and bookmark.
- Search exists through `QuranLibrary().search(text)` and surah search through `surahSearch`.
- Bookmarks can be initialized, set, retrieved, removed, and used for navigation.
- Tafsir and translation APIs expose list/download/fetch/change operations.
- Audio APIs cover ayah playback, next/previous ayah, surah playback, next/previous surah, surah downloads, cancel download, last-position playback, and current/last surah state.

**Important constraints recorded**:

- The README instructs apps to set `useMaterial3: false` to avoid Quran formation/rendering problems.
- Android background/system controls require `MainActivity` to extend `AudioServiceActivity`.
- iOS background audio requires `UIBackgroundModes` with `audio`.
- The library can stream audio and use downloaded/cached files when available; the app must display an unavailable state if uncached audio is requested offline.
- Repeat scopes beyond built-in controls, such as page/wird/range, must be orchestration around quran_library play/seek APIs, not a separate audio engine or catalog.

**Alternatives considered**:

- Custom mushaf rendering: rejected by constitution and Quran text integrity requirements.
- Bundled Quran JSON/search/audio metadata: rejected because it duplicates quran_library and creates text-integrity risk.
- External Quran APIs: rejected for MVP because reading must be offline-first and quran_library already supplies core Quran capability.

**Sources**:

- Context7 `/alheekmahlib/quran_library`
- https://github.com/alheekmahlib/quran_library
- https://pub.dev/packages/quran_library

## Decision: Use Feature-Layered Flutter Architecture With Provider View Models

**Rationale**: Context7 resolved official Flutter architecture guidance and Provider docs. The app needs many workflows but no evidence yet that a larger state framework is necessary. `provider` with `ChangeNotifier` view models is sufficient for onboarding state, home dashboard state, reader shell state, khatma creation, bookmark annotations, settings, reminder scheduling, sharing, and search. It also keeps tests simple: view models can be constructed with fake repositories and fake `QuranGateway` implementations.

**Chosen boundaries**:

- Presentation: Flutter widgets only; no persistence, quran_library singleton calls, scheduling, or SQL.
- Application/state: `ChangeNotifier` view models and application services coordinate flows.
- Domain: immutable app-owned entities, value objects, validation, and khatma calculation rules.
- Infrastructure: quran_library adaptor, SQLite repositories, notification scheduler, share gateway.

**Alternatives considered**:

- Direct `setState` across screens: rejected because it would bury persistence and quran_library decisions in widgets.
- Riverpod/BLoC: deferred because the MVP can meet complexity and testability goals with fewer new dependencies.
- GetX for app state because quran_library uses it internally: rejected to avoid coupling Raqeem app architecture to quran_library internals.

**Sources**:

- Context7 `/websites/flutter_dev`
- Context7 `/websites/pub_dev_packages_provider`
- https://docs.flutter.dev/app-architecture
- https://pub.dev/packages/provider

## Decision: Use Sqflite for App-Owned Offline Data

**Rationale**: The MVP stores structured records indefinitely: user preferences, five recent reading entries, bookmark annotations, khatma plans, daily wird entries, reminder metadata, missed-day decisions, and share drafts. Context7 sqflite docs show versioned `openDatabase`, `onCreate`, `onUpgrade`, transactions, batches, and data-provider patterns. This matches the need for atomic khatma creation and daily wird generation.

`shared_preferences` was also researched through Context7. It is appropriate for simple key-value settings, but its documentation says persistence is asynchronous and not guaranteed immediately after writes. For Raqeem, losing a khatma completion, bookmark note, or last reading entry is unacceptable, so app-owned records use SQLite. Preferences are stored in a small SQLite settings table for a single persistence boundary.

**Implementation notes**:

- Use `sqflite: ^2.4.2+1` and `path: ^1.9.1`.
- Use schema version `1` for MVP.
- All khatma creation and recalculation writes must run inside a transaction.
- Batch insert generated daily wird rows.
- Repositories expose domain entities and never leak raw SQL maps to view models.

**Alternatives considered**:

- `shared_preferences` only: rejected for critical and relational data.
- JSON files: rejected because migration, indexing, and atomic updates are weaker for khatma/wird records.
- Cloud database: rejected because MVP is accountless and offline-first.

**Sources**:

- Context7 `/tekartik/sqflite`
- Context7 `/websites/pub_dev_packages_shared_preferences`
- https://pub.dev/packages/sqflite
- https://pub.dev/packages/path
- https://pub.dev/packages/shared_preferences

## Decision: Use quran_library Bookmark Anchors Plus App Bookmark Annotations

**Rationale**: quran_library supports bookmark initialization, setting, removal, retrieval, and jump-to-bookmark behavior. Raqeem still needs app-specific metadata: type, optional note, color, dates, sorting, editing, and dashboard/search presentation. The plan stores only Raqeem metadata and Quran position references in SQLite while delegating Quran navigation and bookmark anchor behavior to quran_library.

**Boundary**:

- quran_library owns Quran bookmark anchor behavior.
- Raqeem owns user-facing annotation metadata and list management.
- A bookmark annotation must contain enough Quran position data to recover if a quran_library bookmark anchor is missing, but it must not duplicate Quran text or ordering.

**Alternatives considered**:

- Only quran_library bookmarks: insufficient for note/type/color/sort requirements.
- Independent bookmark engine: rejected because jump/search/anchor behavior must use quran_library first.

**Sources**:

- Context7 `/alheekmahlib/quran_library`
- Local quran_library README and API inspection

## Decision: Use quran_library Search for Quran Results and App SQL for App Metadata Results

**Rationale**: The spec requires grouped results across surah names, available ayah content, bookmarks, notes, and available tafsir content. quran_library exposes ayah search and surah search. App-owned bookmarks and notes are in SQLite and can be queried locally. Tafsir search coverage depends on quran_library exposure and downloaded availability.

**Boundary**:

- Quran ayah and surah search: `QuranLibrary().search` and `surahSearch`.
- Bookmark/note search: SQLite query over Raqeem annotation metadata.
- Tafsir search: use quran_library where exposed; otherwise show "available after download/unsupported in MVP" state rather than building a tafsir index.

**Alternatives considered**:

- App-owned full-text Quran index: rejected by constitution.
- Remote search: rejected for offline-first reading.

## Decision: Khatma Distribution Uses Page Units With Ayah Boundary Adjustment

**Rationale**: The clarification states default khatma distribution is page-based, with ayah-level adjustment only for exact start/end boundaries. quran_library provides page and ayah metadata needed to map positions. The app can calculate assigned page ranges without owning Quran text.

**Algorithm contract**:

1. Normalize start and end `QuranPosition` by canonical ordering from quran_library metadata.
2. Reject end before start.
3. Build the list of active reading dates between start and end date inclusive, or from number of days.
4. Reject zero active days.
5. Determine page span from start.page through end.page inclusive.
6. Divide total pages by active day count.
7. Assign `basePages = totalPages ~/ activeDays`.
8. Distribute `remainder = totalPages % activeDays` by assigning one extra page to the earliest days.
9. First daily wird starts at exact selected start ayah if the start is inside its first page.
10. Last daily wird ends at exact selected end ayah if the end is inside its last page.
11. Intermediate boundaries remain page boundaries.
12. Persist generated wird entries in one transaction.

**Alternatives considered**:

- Pure ayah-count distribution: rejected by clarification.
- Juz-based distribution: not requested for MVP default.
- Silent recalculation of completed days: rejected by spec.

## Decision: Use flutter_local_notifications With timezone for Reminders

**Rationale**: Context7 resolved `flutter_local_notifications` and documented initialization, Android permission requests, iOS/Darwin permissions, notification response callbacks, and `zonedSchedule` for daily/weekly notifications. `timezone` was not resolved by Context7, so pub.dev is the fallback. Raqeem reminders are device-local and do not require a server.

**Implementation notes**:

- Use `flutter_local_notifications: ^21.0.0`.
- Use `timezone: ^0.11.0` to compute local scheduled times.
- Store reminder intent in SQLite regardless of permission state.
- If permission is denied, show in-app reminder state and keep khatma progress functional.
- Avoid requesting exact alarm permission unless implementation needs exact-to-the-minute reminders and product accepts Android 14 implications.

**Alternatives considered**:

- Server push notifications: rejected because MVP has no account/cloud sync.
- In-app reminders only: insufficient for daily reminder requirement.

**Sources**:

- Context7 `/maikub/flutter_local_notifications`
- https://pub.dev/packages/flutter_local_notifications
- https://pub.dev/packages/timezone

## Decision: Use share_plus for Text and Generated Image Sharing

**Rationale**: Context7 resolved `share_plus` and documented sharing text, files, and dynamically generated `XFile` data through native share sheets. Raqeem can compose share text from quran_library-provided selected ayah/reference and generate an image preview using Flutter rendering (`RepaintBoundary`), then share PNG bytes through `XFile.fromData`.

**Boundary**:

- Quran text/reference source: quran_library selected ayah data.
- Image layout: app-owned visual composition using Raqeem theme.
- Native share sheet: `share_plus`.

**Alternatives considered**:

- Platform channels written by hand: rejected because share_plus is mature and covers Android/iOS.
- Server-side image rendering: rejected because sharing should work locally.

**Sources**:

- Context7 `/websites/pub_dev_packages_share_plus`
- https://pub.dev/packages/share_plus

## Decision: Defer Word-by-Word Features Unless Product Explicitly Enables Them

**Rationale**: quran_library 4.0.1 exposes word info and word audio APIs, but the MVP specification centers on ayah selection, tafsir, translations, sharing, bookmarks, audio, and khatma. Word-by-word support is identified as library-supported but not required for MVP acceptance scenarios.

**Alternatives considered**:

- Enable word audio by default: deferred because it expands testing, download, and UI scope without a matching MVP requirement.

## Decision: Android and iOS Phones Are Release-Blocking; Other Flutter Targets Are Compatible Only

**Rationale**: The spec clarifies Android and iOS phone scope. quran_library advertises multiple platforms, but MVP manual verification, audio controls, notification behavior, and share flows will be validated on Android and iOS first.

**Alternatives considered**:

- Release-blocking desktop/web parity: rejected by MVP scope.

