# Data Model: Raqeem Interactive Quran App

**Feature**: `001-raqeem-quran-app`  
**Date**: 2026-04-25

## Design Rules

- Quran text, Quran ordering, mushaf rendering, tafsir corpora, translation corpora, Quran search indexes, and Quran audio catalogs are not app-owned entities.
- App entities may reference Quran positions returned by quran_library.
- App persistence stores workflow state, preferences, annotations, and generated khatma assignments only.
- All persisted timestamps use UTC ISO-8601 strings. User-facing date grouping uses the device locale/time zone.

## Entity: UserPreferences

Stores accountless user choices.

**Fields**:

- `id`: constant key, `default`
- `onboardingCompleted`: bool
- `languageCode`: enum `ar`, `en`
- `textDirection`: derived from `languageCode`
- `visualMode`: enum `light`, `night`, `system`
- `readerTextScale`: decimal, supported range decided by UI tests
- `readerDisplayMode`: enum `page`, `scroll`, `tafsirInline`, `tafsirSide` where quran_library supports it
- `showReaderControlsByDefault`: bool
- `selectedReciterId`: nullable string, value must map to quran_library available reciter/source if exposed
- `audioRepeatDefault`: enum `none`, `ayah`, `range`, `page`, `surah`, `wird`
- `defaultReminderTime`: nullable local `HH:mm`
- `defaultActiveWeekdays`: set of ISO weekday integers `1..7`
- `defaultKhatmaDistributionMode`: enum `pageBased`
- `createdAt`, `updatedAt`

**Validation**:

- `languageCode` must be one of MVP locales.
- Touch target and text scale support is verified in widget/accessibility tests, not stored as free-form UI values.
- `defaultActiveWeekdays` cannot be empty when used to create a khatma.

**Relationships**:

- Referenced when creating `KhatmaPlan`.
- Determines default `ReminderSetting`.

## Value Object: QuranPosition

Identifies a Quran location from quran_library metadata.

**Fields**:

- `surahNumber`: int `1..114`
- `ayahNumber`: int, valid within surah
- `ayahUniqueNumber`: nullable int, if quran_library exposes it for direct playback/highlight
- `page`: int `1..604`
- `juz`: nullable int `1..30`
- `hizb`: nullable int
- `rub`: nullable int
- `displaySurahName`: cached label only, never canonical text
- `displayAyahLabel`: cached reference label only

**Validation**:

- Must be created through `QuranGateway` metadata methods or from quran_library callback data.
- App must not normalize or generate Quran text.

**Relationships**:

- Used by `QuranRange`, `LastReadingEntry`, `BookmarkAnnotation`, `AyahShareDraft`, `PlaybackSession`, `KhatmaPlan`, `DailyWird`, and search results.

## Value Object: QuranRange

Ordered start/end Quran positions.

**Fields**:

- `start`: `QuranPosition`
- `end`: `QuranPosition`
- `unitHint`: enum `ayah`, `page`, `surah`, `wird`, `custom`

**Validation**:

- `start` must be before or equal to `end` by quran_library canonical order.
- Page ranges must stay within `1..604`.
- Khatma ranges may start/end inside a page; internal daily distribution remains page-based.

## Entity: LastReadingEntry

Recent reading history.

**Fields**:

- `id`: UUID/string
- `position`: `QuranPosition`
- `source`: enum `reader`, `bookmark`, `search`, `khatma`, `audio`
- `savedAt`
- `displayTitle`
- `displaySubtitle`

**Validation**:

- Keep only the latest five entries by `savedAt`.
- De-duplicate exact same `surahNumber`, `ayahNumber`, `page` by updating `savedAt`.

**Relationships**:

- Home dashboard reads the newest entry.
- Reader writes entries on page/ayah changes and app lifecycle pause.

## Entity: BookmarkAnnotation

Raqeem metadata around a quran_library bookmark anchor or Quran position.

**Fields**:

- `id`: UUID/string
- `quranLibraryBookmarkId`: nullable int
- `position`: `QuranPosition`
- `type`: enum `bookmark`, `note`, `reflection`, `memorization`, `custom`
- `note`: nullable string, max length defined by UI validation
- `color`: enum `gold`, `green`, `red`, `blue`, `neutral`
- `createdAt`, `updatedAt`
- `lastOpenedAt`: nullable
- `isArchived`: bool

**Validation**:

- Position required.
- Empty notes are allowed for plain bookmarks.
- Delete removes or detaches the corresponding quran_library bookmark anchor when one exists.

**Relationships**:

- Search queries may return bookmark/note matches.
- Home or bookmarks screens can jump by `QuranGateway.jumpToPosition`.

## Entity: AyahShareDraft

Temporary persisted draft for text/image sharing.

**Fields**:

- `id`: UUID/string
- `position`: `QuranPosition`
- `range`: nullable `QuranRange`
- `format`: enum `text`, `squareImage`, `storyImage`, `portraitImage`
- `includeTranslation`: bool
- `includeTafsir`: bool
- `theme`: enum `light`, `night`, `parchment`
- `brandPlacement`: enum `footer`, `minimal`
- `createdAt`, `updatedAt`
- `lastGeneratedPathOrUri`: nullable string

**Validation**:

- Selected text/reference must be retrieved through quran_library at generation time.
- Failure to generate image does not modify bookmarks or reading state.

## Entity: ReciterPreference

Current audio preference.

**Fields**:

- `selectedReciterId`: nullable string
- `selectedReciterDisplayName`: nullable string
- `repeatScopeDefault`: enum `none`, `ayah`, `range`, `page`, `surah`, `wird`
- `autoScrollWithPlayback`: bool
- `updatedAt`

**Validation**:

- Reciter values must map to quran_library audio options where exposed.
- If unavailable, app falls back to quran_library default and reports the unavailable preference.

## Entity: PlaybackSession

Ephemeral state for current playback UI.

**Fields**:

- `state`: enum `idle`, `loading`, `playing`, `paused`, `buffering`, `unavailable`, `error`
- `currentPosition`: nullable `QuranPosition`
- `repeatScope`: enum `none`, `ayah`, `range`, `page`, `surah`, `wird`
- `repeatRange`: nullable `QuranRange`
- `reciterId`: nullable string
- `lastErrorCode`: nullable string
- `updatedAt`

**Validation**:

- Playback commands call quran_library APIs only.
- Range/page/wird repeat is an app orchestration of quran_library ayah playback, not a custom audio source catalog.

**State Transitions**:

- `idle -> loading -> playing`
- `playing -> paused -> playing`
- `playing -> unavailable` when uncached audio is requested offline
- `loading|playing|paused -> error` on quran_library/platform failure
- `playing|paused|error|unavailable -> idle` on stop/reset

## Entity: KhatmaPlan

User-created Quran completion plan.

**Fields**:

- `id`: UUID/string
- `name`: string
- `range`: `QuranRange`
- `startDate`: local date
- `endDate`: local date
- `activeWeekdays`: set of ISO weekday integers `1..7`
- `distributionMode`: enum `pageBased`
- `reminderTime`: nullable local `HH:mm`
- `state`: enum `draft`, `active`, `paused`, `completed`, `archived`
- `isHomeActive`: bool
- `totalAssignedPages`: int
- `completedAssignedPages`: int
- `createdAt`, `updatedAt`

**Validation**:

- End date must be on or after start date.
- Range end must not be before range start.
- Active weekdays cannot be empty.
- Generated wird entries must cover the selected range with no gaps or overlaps.
- Only one plan may have `isHomeActive = true`.

**Relationships**:

- Owns many `DailyWird`.
- May own one active `ReminderSetting`.

**State Transitions**:

- `draft -> active` after valid creation and wird generation.
- `active -> paused`.
- `paused -> active`.
- `active -> completed` when all daily wird entries are complete.
- `active|paused|completed -> archived`.

## Entity: DailyWird

One assigned reading entry within a khatma.

**Fields**:

- `id`: UUID/string
- `khatmaPlanId`: foreign key
- `date`: local date
- `range`: `QuranRange`
- `assignedPageCount`: int
- `boundaryAdjustment`: enum `none`, `startAyah`, `endAyah`, `startAndEndAyah`
- `state`: enum `pending`, `inProgress`, `completed`, `missed`, `carriedForward`, `redistributed`
- `completedAt`: nullable UTC timestamp
- `missedDecision`: nullable enum `carryForward`, `redistributeRemaining`, `keepMissed`
- `createdAt`, `updatedAt`

**Validation**:

- `assignedPageCount` must be positive unless an exact one-page/ayah boundary exception is explicitly represented.
- Completed rows are immutable during recalculation unless user confirms changing completed days.
- A missed-day decision creates traceable updates to affected future wird entries.

**State Transitions**:

- `pending -> inProgress`
- `pending|inProgress -> completed`
- `pending|inProgress -> missed`
- `missed -> carriedForward`
- `missed -> redistributed`
- `missed -> pending` only if user manually reopens it before recalculation

## Entity: ReminderSetting

Device-local reminder intent.

**Fields**:

- `id`: UUID/string
- `khatmaPlanId`: nullable foreign key
- `time`: local `HH:mm`
- `weekdays`: set of ISO weekday integers
- `enabled`: bool
- `permissionState`: enum `unknown`, `granted`, `denied`, `limited`
- `platformScheduleIds`: list of int
- `createdAt`, `updatedAt`

**Validation**:

- Enabled reminders require at least one weekday and a valid time.
- Denied permission keeps the record but prevents platform scheduling.

## Entity: SearchQuery

Ephemeral or recent search state.

**Fields**:

- `query`: string
- `locale`: enum `ar`, `en`
- `filters`: set of enum `ayah`, `surah`, `bookmark`, `note`, `tafsir`
- `createdAt`

**Validation**:

- Blank query returns no results and preserves current search screen state.

## Value Object: SearchResult

Grouped search result displayed to the user.

**Fields**:

- `source`: enum `ayah`, `surah`, `bookmark`, `note`, `tafsir`
- `position`: nullable `QuranPosition`
- `title`: string
- `snippet`: nullable string
- `action`: enum `openReader`, `openBookmark`, `openTafsir`, `none`

**Validation**:

- Ayah/surah/tafsir results must originate from quran_library capability.
- Bookmark/note results originate from SQLite annotation metadata.

