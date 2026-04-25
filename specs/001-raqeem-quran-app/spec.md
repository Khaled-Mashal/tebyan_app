# Feature Specification: Raqeem Interactive Quran App

**Feature Branch**: `001-raqeem-quran-app`  
**Created**: 2026-04-25  
**Status**: Draft  
**Input**: User description: "Analyze root plan.md and create professional, accurate specifications for the Raqeem interactive Quran application."

## Clarifications

### Session 2026-04-25

- Q: How should MVP retain local user data? → A: Local data is retained indefinitely with no explicit in-app reset/delete requirement.
- Q: What is the default khatma wird distribution unit? → A: Page-based distribution with ayah-level adjustment only for exact start/end boundaries.
- Q: How is the home dashboard active khatma selected? → A: Users manually choose the active khatma; new khatma creation offers to make it active.
- Q: What accessibility baseline is required for MVP? → A: Adjustable text, 44px minimum touch targets, meaningful labels for primary controls, and no text clipping at supported sizes.
- Q: What is the MVP offline behavior for audio playback? → A: Audio may stream online and reuse cached/downloaded audio when available; reading remains fully offline.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Start and Resume Daily Reading (Priority: P1)

As a daily reader, I want to open Raqeem, see my last reading position and today's wird, and continue reading immediately in a calm Quran-focused interface.

**Why this priority**: This is the core daily value of the app. Without reliable reading resume and daily guidance, the product does not meet its primary purpose.

**Independent Test**: A new user can complete onboarding, open the home screen, enter the reader, move to a Quran position, leave the app, and return to the same position with today's reading guidance visible.

**Acceptance Scenarios**:

1. **Given** a first-time user, **When** they complete onboarding with language and theme choices, **Then** the app opens the home dashboard using those preferences.
2. **Given** a returning user with a saved reading position, **When** they open the app, **Then** the home dashboard displays the last surah, ayah, page, and a clear continue action.
3. **Given** a user reading Quran pages, **When** they navigate away or close the app, **Then** the latest reading position is saved automatically.
4. **Given** a user has manually selected an active khatma, **When** they open the home dashboard, **Then** the dashboard shows today's wird range, completion state, and overall khatma progress.

---

### User Story 2 - Read and Navigate the Mushaf (Priority: P1)

As a Quran reader, I want to read pages with comfortable controls and navigate by surah, juz, hizb, rub, and page so I can reach any Quran location quickly.

**Why this priority**: Quran reading and navigation are the central product workflow and must be independently usable before secondary features.

**Independent Test**: A user can open the reader, navigate by each supported index type, hide and show controls, select an ayah, and continue reading without distracting UI.

**Acceptance Scenarios**:

1. **Given** the reader is open, **When** the user swipes or uses page navigation, **Then** the displayed Quran page changes smoothly and the new position is tracked.
2. **Given** the user opens the navigation selector, **When** they choose a surah, juz, hizb, rub, or page, **Then** the reader opens at the matching Quran position.
3. **Given** the user is reading, **When** they tap the reading area, **Then** controls toggle between visible and hidden states without changing the Quran position.
4. **Given** the user selects an ayah, **When** selection is active, **Then** the ayah is highlighted clearly and ayah actions become available.

---

### User Story 3 - Reflect on and Share Ayahs (Priority: P2)

As a student of Quran, I want to open tafsir and translation, copy or share ayahs, and save notes or bookmarks so I can study and revisit important places.

**Why this priority**: Reflection, bookmarking, and sharing turn reading into a complete learning and devotional workflow.

**Independent Test**: From a selected ayah, a user can view tafsir and translation, copy text, share text, generate a styled image, add a bookmark, add a note, and later reopen the same location from bookmarks.

**Acceptance Scenarios**:

1. **Given** an ayah is selected, **When** the user chooses tafsir or translation, **Then** the requested content opens with the ayah context visible.
2. **Given** an ayah is selected, **When** the user chooses share as text, **Then** the system share flow opens with the ayah reference included.
3. **Given** an ayah is selected, **When** the user chooses share as image, **Then** a preview allows format selection and produces a visually consistent image.
4. **Given** a user adds a bookmark or note, **When** they open the bookmarks screen, **Then** the saved item appears with surah, ayah, page, date, type, and available actions.

---

### User Story 4 - Listen to Recitation (Priority: P2)

As a listener, I want to choose a reciter, play ayahs, repeat a selected ayah or range, and keep the visible reader synchronized with playback.

**Why this priority**: Audio is a major Quran interaction mode and supports memorization, review, and reflection.

**Independent Test**: A user can choose a reciter, start playback from an ayah, repeat a single ayah or range, move to next and previous ayahs, and see the current playback ayah highlighted.

**Acceptance Scenarios**:

1. **Given** a selected reciter, **When** the user starts playback from an ayah, **Then** recitation begins from that ayah and the current ayah is visibly identified.
2. **Given** playback is active, **When** the user chooses repeat ayah, range, page, surah, or today's wird, **Then** playback follows the selected repeat scope.
3. **Given** audio resources are unavailable or not cached, **When** the user attempts playback without connectivity, **Then** the app explains the issue and preserves reading functionality.

---

### User Story 5 - Plan and Track a Khatma (Priority: P2)

As a khatma user, I want to create a khatma with a date range, Quran range, reminder time, reading days, and distribution mode so the app gives me a precise daily wird and tracks progress.

**Why this priority**: The khatma planner is a defining feature of Raqeem and differentiates it from a basic Quran reader.

**Independent Test**: A user can create a khatma, receive daily wird ranges, complete today's wird, see progress update, and handle missed or edited days predictably.

**Acceptance Scenarios**:

1. **Given** the user enters a valid khatma range and schedule, **When** they create the khatma, **Then** the app generates daily wird entries covering the selected Quran range.
2. **Given** a daily wird is in progress, **When** the user marks it complete, **Then** the daily and overall khatma progress update immediately.
3. **Given** the user changes an active khatma, **When** there are completed days, **Then** completed days remain unchanged unless the user explicitly confirms recalculation.
4. **Given** the user misses a day, **When** they review the missed wird, **Then** they can carry it forward, redistribute the remaining wird, or keep it marked as missed.
5. **Given** the user creates a new khatma, **When** creation succeeds, **Then** the app offers to make it the active home dashboard khatma without changing any existing active khatma silently.

---

### User Story 6 - Personalize Reading and App Behavior (Priority: P3)

As a Raqeem user, I want to adjust reading, audio, khatma, language, and visual preferences so the app remains comfortable for my age, device, and reading habits.

**Why this priority**: Personalization improves long-term usability but depends on the core reading and khatma flows.

**Independent Test**: A user can change language, theme, reading display, audio default, reminder defaults, and accessibility-related preferences, then close and reopen the app with those choices preserved.

**Acceptance Scenarios**:

1. **Given** the user changes reading settings, **When** they return to the reader, **Then** the reading experience reflects the new preferences without losing position.
2. **Given** the user changes language, **When** they navigate through primary screens, **Then** labels and controls appear in the selected language where supported.
3. **Given** the user changes default reminder settings, **When** they create a new khatma, **Then** the new khatma starts with those defaults.
4. **Given** the user increases supported text size settings, **When** they use primary MVP screens, **Then** Quran reading text, labels, and controls remain readable without clipping.

### Edge Cases

- First launch without saved preferences opens onboarding and does not expose incomplete setup states.
- Closing the app during reading, playback, khatma creation, or bookmark editing preserves the last committed user data.
- A khatma end position before its start position is rejected with a clear correction message.
- A khatma with zero active reading days is rejected before creation.
- A very large daily wird prompts a gentle warning while still allowing the user to continue if the schedule is valid.
- Editing an active khatma never silently changes completed days.
- Audio or share-image generation failure does not block reading, bookmarks, or khatma progress.
- Audio playback can require connectivity when the requested recitation is not cached or downloaded.
- Search results with no matches show helpful empty states and do not clear the query unexpectedly.
- RTL layout remains correct for Arabic and does not break English navigation labels.
- Quran text remains unchanged when highlighted, copied, translated, searched, or shared.
- Primary controls remain reachable with minimum 44px touch targets at supported text sizes.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST present a premium Islamic visual identity for Raqeem using the approved palette as the base visual language: primary gold, warm parchment background, soft card surfaces, dark brown primary text, muted secondary text, accent gold, and soft white reading surfaces.
- **FR-002**: The system MUST provide onboarding for first-time users to choose language and visual mode before reaching the main dashboard.
- **FR-003**: The system MUST provide a home dashboard with greeting, last reading card, active khatma or daily wird card, primary shortcuts, and visible progress where applicable.
- **FR-004**: The system MUST provide a Quran reader optimized for distraction-free reading, including page navigation, control visibility toggling, and automatic last-position saving.
- **FR-005**: Users MUST be able to navigate to Quran content by surah, juz, hizb, rub, and page.
- **FR-006**: Users MUST be able to select an ayah and open a contextual action menu for audio, tafsir, translation, bookmark, note, copy, share, and wird boundary actions.
- **FR-007**: The system MUST provide surah, juz, hizb, and rub selectors with search or quick navigation where applicable.
- **FR-008**: The system MUST provide tafsir and translation views that keep the selected ayah and reference visible.
- **FR-009**: Users MUST be able to choose a reciter, play ayah audio, move between ayahs, and repeat a single ayah, a range, a page, a surah, or today's wird.
- **FR-010**: The system MUST keep playback state and the visible current ayah understandable to the user during recitation.
- **FR-011**: The system MUST allow audio playback to stream online and reuse cached or downloaded recitation audio when available.
- **FR-012**: Users MUST be able to create bookmarks with type, optional note, color, Quran position, and creation date.
- **FR-013**: Users MUST be able to view, sort, open, edit, and delete bookmarks.
- **FR-014**: The system MUST keep the last five reading positions and allow users to resume from any listed position.
- **FR-015**: Users MUST be able to create a khatma by selecting a Quran range, start date, end date or number of days, reminder time, active reading days, and distribution mode.
- **FR-016**: The system MUST calculate daily wird entries that fully cover the selected khatma range without overlap or gaps.
- **FR-017**: The system MUST use page-based khatma distribution by default, using ayah-level adjustment only when needed to preserve exact selected start and end boundaries.
- **FR-018**: The system MUST distribute remainder pages predictably when the selected khatma range does not divide evenly across active reading days.
- **FR-019**: Users MUST be able to start, continue, complete, pause, edit, and review progress for a khatma.
- **FR-020**: The system MUST provide options to carry forward, redistribute, or keep missed wird entries.
- **FR-021**: The system MUST allow users to manually choose one active khatma for the home dashboard while allowing multiple khatma records.
- **FR-022**: The system MUST offer to make a newly created khatma active, and MUST NOT replace the current active khatma silently.
- **FR-023**: Users MUST be able to set daily wird reminders and manage default reminder preferences.
- **FR-024**: Users MUST be able to share an ayah as text with its reference.
- **FR-025**: Users MUST be able to generate and share an ayah image with selectable format, ayah reference, app branding, and optional tafsir or translation display.
- **FR-026**: The system MUST provide search across surah names, available ayah content, bookmarks, notes, and available tafsir content.
- **FR-027**: Users MUST be able to configure reading display, audio defaults, khatma defaults, language, visual mode, and accessibility-related text preferences.
- **FR-028**: The system MUST preserve user settings, bookmarks, last reading positions, khatma plans, daily progress, selected reciter, and language locally for offline-first use, retaining them indefinitely unless the app is uninstalled or the operating system clears app data.
- **FR-029**: The system MUST keep core Quran reading available without requiring an account, cloud sync, or internet connection.
- **FR-030**: The system MUST support Arabic and English for the first release and maintain full RTL usability for Arabic.
- **FR-031**: The system MUST provide an accessibility baseline with adjustable text, minimum 44px touch targets for primary controls, meaningful labels for primary controls, and no text clipping at supported text sizes.
- **FR-032**: The system MUST avoid default or generic screens for MVP flows; every user-facing screen in scope must follow the Raqeem visual identity.
- **FR-033**: The system MUST provide clear empty, loading, error, and unavailable states for reading, audio, tafsir, translation, search, reminders, and sharing flows.
- **FR-034**: The system MUST defer account creation, cloud synchronization, internal social features, advanced statistics, competitions, and community features beyond MVP.

### Quran Library Requirements *(mandatory for Quran features)*

- **QL-001**: The feature uses `quran_library: 4.0.1` capabilities for Quran page display, Quran navigation, Quran metadata, ayah selection support where available, audio capabilities where available, tafsir, translations, bookmarks, and search where those capabilities are exposed by the library.
- **QL-002**: The feature MUST NOT require custom Quran text, custom mushaf rendering, independent Quran metadata, or duplicated Quran search/audio/bookmark engines.
- **QL-003**: MVP platform scope covers Android and iOS phones first, with responsive behavior expected for common phone sizes. Web and desktop behavior are planned as compatible targets but are not release-blocking for MVP unless explicitly enabled during planning.
- **QL-004**: Quran text integrity is preserved by treating Quran text and Quran ordering as read-only source data from the Quran data layer; app features may highlight, reference, copy, translate, or share ayahs but MUST NOT generate, normalize, reorder, or alter Quran wording.
- **QL-005**: Any quran_library limitation affecting audio repeat behavior, word-by-word support, tafsir source selection, translation availability, search coverage, or bookmark customization MUST be recorded during planning and approved before custom fallback behavior is added.

### Key Entities *(include if feature involves data)*

- **User Preferences**: Stores language, visual mode, reading display choices, audio defaults, khatma defaults, reminder defaults, and accessibility-related preferences.
- **Quran Position**: Identifies a Quran location by surah, ayah, page, juz, hizb, and rub where available.
- **Quran Range**: Represents an ordered start and end Quran position for playback, sharing, reading progress, or khatma planning.
- **Last Reading Entry**: Stores a recent reading position with timestamp and enough display metadata to resume quickly.
- **Bookmark**: Stores a Quran position, bookmark type, optional note, color, and creation date.
- **Ayah Share Draft**: Stores the selected ayah reference, selected output format, optional tafsir or translation inclusion, and presentation preferences for sharing.
- **Reciter Preference**: Stores the selected reciter and repeat behavior defaults.
- **Khatma Plan**: Stores the khatma name, Quran range, schedule, reminder time, active weekdays, distribution mode, progress, lifecycle state, and whether the user selected it as the home dashboard active khatma.
- **Daily Wird**: Stores the date, assigned Quran range, expected reading amount, completion state, and relationship to a khatma.
- **Search Query and Result**: Represents a user search term and grouped results across ayahs, surahs, bookmarks, notes, and tafsir where available.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A returning user can open the app and continue from the last reading position in 10 seconds or less after launch on a typical supported phone.
- **SC-002**: 95% of tested users can navigate from the home dashboard to a specific surah or page without assistance.
- **SC-003**: 95% of tested users can select an ayah and complete at least one action from the ayah menu within 20 seconds.
- **SC-004**: 90% of tested users can create a valid khatma plan and understand today's wird without external instructions.
- **SC-005**: Daily wird generation covers 100% of the selected khatma range with no duplicate or missing assigned reading pages, and preserves exact ayah boundaries where the selected range begins or ends inside a page.
- **SC-006**: Completing a daily wird updates visible daily and overall khatma progress immediately in all tested scenarios.
- **SC-007**: 95% of tested users can add a bookmark and reopen the saved Quran position later.
- **SC-008**: A user can share an ayah as text or image in 30 seconds or less after selecting the ayah.
- **SC-009**: Core Quran reading, last reading, bookmarks, settings, and khatma progress remain usable without internet access, while uncached audio clearly communicates connectivity requirements.
- **SC-010**: Arabic screens maintain correct RTL layout and readable Quran-focused presentation across all MVP flows.
- **SC-011**: Primary controls meet the 44px minimum touch target and primary labels do not clip at all supported text sizes in MVP screen review.
- **SC-012**: The reading interface maintains comfortable readability in light and night modes during stakeholder review.
- **SC-013**: No MVP screen remains in a generic starter or placeholder design state at release readiness review.

## Assumptions

- MVP is accountless and offline-first; cloud sync, authentication, and social features are out of scope.
- Android and iOS phones are the first release targets; larger screens, web, and desktop can be refined after MVP unless planning expands scope.
- Arabic and English are the first supported languages, with Arabic as the primary Quran-reading experience.
- The approved visual palette is the foundation for the app, with only calm success, warning, and error colors added when needed for understandable feedback.
- Quran reading data, mushaf display, ordering, and core Quran metadata come from the Quran data layer rather than custom bundled content.
- Word-by-word support, tafsir source selection, translation coverage, search coverage, and audio repeat capabilities depend on what the Quran data layer provides and will be verified during planning.
- Local persistence is sufficient for MVP user data such as preferences, bookmarks, last reading, and khatma progress; MVP does not include a global in-app reset or delete-all-data flow.
- Reminder behavior depends on user-granted device permissions; if permission is denied, the app still preserves khatma progress and shows in-app reminders.
- A single khatma appears as the user-selected active khatma on the home dashboard, while users may keep multiple khatma records.
- Audio recitation may require internet access unless the requested audio is already cached or downloaded.

## Research Expectations

- Context7 MUST be used during planning for quran_library, Flutter architecture,
  and every added or changed dependency.
- If Context7 cannot resolve a required package, version, or API, the plan MUST
  cite the official documentation, pub.dev, or upstream repository used instead.
