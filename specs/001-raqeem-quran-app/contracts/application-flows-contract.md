# Contract: Application Flows

**Purpose**: Define user-visible flow contracts for view models and screens.

## Onboarding Flow

**Initial state**: `loading`

**States**:

- `loading`
- `requiresOnboarding`
- `saving`
- `completed`
- `error`

**Commands**:

- `loadPreferences()`
- `selectLanguage(languageCode)`
- `selectVisualMode(visualMode)`
- `completeOnboarding()`

**Acceptance**:

- First launch with no saved preferences enters `requiresOnboarding`.
- Completion persists `UserPreferences`, initializes app locale/theme, and routes to home.
- Arabic selection sets RTL layout.
- Failure keeps the user on onboarding with a retry state.

## Home Dashboard Flow

**Inputs**:

- `UserPreferences`
- latest `LastReadingEntry`
- user-selected active `KhatmaPlan`
- today's `DailyWird`

**Commands**:

- `continueReading()`
- `openRecentEntry(entryId)`
- `openTodayWird()`
- `chooseActiveKhatma(khatmaPlanId)`
- `openShortcut(shortcut)`

**Acceptance**:

- Returning user sees last surah/ayah/page and a continue action.
- Active khatma is selected manually; new khatma can offer to become active but cannot silently replace another active khatma.
- Empty dashboard states are Raqeem-designed, not starter/generic screens.

## Reader Flow

**States**:

- `loading`
- `ready`
- `controlsHidden`
- `controlsVisible`
- `ayahSelected`
- `error`

**Commands**:

- `openAtPosition(position)`
- `openAtPage(page)`
- `navigateBySurah(surahNumber)`
- `navigateByJuz(juzNumber)`
- `navigateByHizb(hizbNumber)`
- `navigateByRub(rubNumber)`
- `toggleControls()`
- `selectAyah(position)`
- `saveLastPosition(position)`

**Acceptance**:

- Reader composes quran_library widgets.
- Page changes update last reading without blocking swipes.
- Tapping reading area toggles controls without changing Quran position.
- Selected ayah exposes actions for audio, tafsir, translation, bookmark/note, copy, share, and wird boundary use.

## Ayah Action Flow

**Commands**:

- `playAyah(position)`
- `openTafsir(position)`
- `openTranslation(position)`
- `copyText(position)`
- `shareText(position)`
- `createImageDraft(position)`
- `saveBookmark(annotation)`
- `setWirdBoundary(position, boundaryKind)`

**Acceptance**:

- Actions preserve selected Quran position context.
- Failures in audio/share/image do not block reading.
- Copy/share text includes ayah reference.
- Image draft preview allows format selection before sharing.

## Audio Flow

**States**:

- `idle`
- `loading`
- `playing`
- `paused`
- `buffering`
- `unavailable`
- `error`

**Commands**:

- `selectReciter(reciterId)`
- `playFrom(position)`
- `pause()`
- `resume()`
- `stop()`
- `nextAyah()`
- `previousAyah()`
- `setRepeatScope(scope, range)`
- `downloadSurah(surahNumber)`

**Acceptance**:

- Current playback ayah is highlighted or otherwise clearly identified.
- Repeat scopes include ayah, range, page, surah, and today's wird.
- App orchestration can sequence ranges, but quran_library remains the playback source.
- Offline uncached playback shows connectivity/download guidance and preserves reading.

## Khatma Creation Flow

**States**:

- `editing`
- `validating`
- `warning`
- `saving`
- `created`
- `error`

**Commands**:

- `setName(name)`
- `setRange(start, end)`
- `setDates(startDate, endDate)`
- `setActiveWeekdays(weekdays)`
- `setReminderTime(time)`
- `setDistributionMode(pageBased)`
- `previewWirdDistribution()`
- `create()`
- `makeActive(khatmaPlanId)`

**Acceptance**:

- End before start is rejected.
- Zero active weekdays are rejected.
- Very large daily wird shows a warning but can proceed when valid.
- Created plan generates daily wird rows covering the full range with no gaps/overlap.
- User is asked whether to make a new khatma active.

## Khatma Progress Flow

**Commands**:

- `startOrContinue(khatmaPlanId)`
- `markTodayComplete()`
- `pausePlan(khatmaPlanId)`
- `resumePlan(khatmaPlanId)`
- `editPlan(khatmaPlanId, changes)`
- `handleMissedWird(wirdId, decision)`

**Acceptance**:

- Completing a daily wird updates daily and overall progress immediately.
- Completed days remain unchanged on edit unless user explicitly confirms recalculation.
- Missed decisions support carry forward, redistribute remaining, or keep missed.

## Search Flow

**Commands**:

- `updateQuery(query)`
- `setFilters(filters)`
- `submit()`
- `openResult(resultId)`

**Acceptance**:

- Quran ayah/surah results come from quran_library.
- Bookmark/note results come from SQLite.
- No-result state does not clear query.
- Tafsir result availability reflects quran_library support/download state.

## Settings Flow

**Commands**:

- `setLanguage(languageCode)`
- `setVisualMode(mode)`
- `setReaderTextScale(scale)`
- `setAudioDefaults(preference)`
- `setKhatmaDefaults(defaults)`
- `setReminderDefaults(defaults)`

**Acceptance**:

- Changes persist locally and survive app restart.
- Reader position is not lost when settings change.
- Arabic/English labels update where supported.
- Supported text sizes do not clip primary labels.

