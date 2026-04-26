# Tasks: Raqeem Interactive Quran App

**Input**: Design documents from `C:\dev_Projects\tebyan_app\specs\001-raqeem-quran-app\`
**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/`, `quickstart.md`

**Tests**: Required by the implementation plan and template for user-visible behavior, quran_library adaptors, state logic, persistence, critical widget flows, accessibility, and platform behavior that cannot be automated.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing. Setup and foundational phases must complete before user story work starts.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel because it touches different files and has no dependency on an incomplete task.
- **[Story]**: Required only for user story phases, using `[US1]`, `[US2]`, `[US3]`, `[US4]`, `[US5]`, or `[US6]`.
- **File paths**: Every task includes exact repository-relative paths.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Add required dependencies, platform configuration, and app skeleton needed before shared infrastructure work.

- [X] T001 Update `pubspec.yaml` to declare `provider: ^6.1.5+1`, `sqflite: ^2.4.2+1`, `path: ^1.9.1`, `share_plus: ^13.1.0`, `flutter_local_notifications: ^21.0.0`, `timezone: ^0.11.0`, and keep `quran_library: 4.0.1`
- [X] T002 Replace the starter counter entry point with Raqeem bootstrap wiring in `lib/main.dart`
- [X] T003 [P] Create the app shell files in `lib/app/app.dart`, `lib/app/bootstrap.dart`, `lib/app/navigation/app_router.dart`, and `lib/app/theme/raqeem_theme.dart`
- [X] T004 [P] Create the planned feature and shared package structure in `lib/features/` and `lib/shared/`
- [X] T005 [P] Configure Android quran_library audio controls by updating `android/app/src/main/kotlin/com/tebyan/quran/tebyan_app/MainActivity.kt`
- [X] T006 [P] Configure iOS background audio capability by updating `ios/Runner/Info.plist`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Shared contracts, persistence, platform boundaries, theme, localization, and test fakes that all user stories depend on.

**Critical**: No user story work should begin until this phase is complete.

- [X] T007 Define Quran value objects and validation types in `lib/features/quran/domain/quran_position.dart` and `lib/features/quran/domain/quran_range.dart`
- [X] T008 [P] Define shared application error/result types in `lib/shared/errors/app_error.dart` and `lib/shared/errors/result.dart`
- [X] T009 Create SQLite database opener and schema version constant for `raqeem.db` in `lib/shared/persistence/raqeem_database.dart`
- [X] T010 Implement SQLite schema version 1 migrations for settings, last reading, bookmarks, khatma, wird, reminders, and share drafts in `lib/shared/persistence/migrations/v1_schema.dart`
- [X] T011 [P] Add injectable database factory and in-memory test helper in `test/shared/persistence/test_database_factory.dart`
- [X] T012 Define quran_library-facing contracts in `lib/features/quran/infrastructure/quran_gateway.dart`
- [X] T013 Implement quran_library initialization boundary with recoverable startup errors in `lib/features/quran/infrastructure/quran_library_gateway.dart`
- [X] T014 [P] Add fake Quran gateway implementations for unit and widget tests in `test/shared/fakes/fake_quran_gateway.dart`
- [X] T015 Define Raqeem light and night theme tokens with Quran screen `useMaterial3: false` support in `lib/app/theme/raqeem_theme.dart`
- [X] T016 [P] Add Arabic and English localization delegates and string lookup scaffolding in `lib/app/localization/app_localizations.dart`
- [X] T017 Configure app routes for onboarding, home, reader, bookmarks, audio, khatma, search, settings, and sharing in `lib/app/navigation/app_router.dart`
- [X] T018 Wire root `MultiProvider` dependencies for repositories, gateways, schedulers, and view models in `lib/app/bootstrap.dart`
- [X] T019 [P] Implement local notification scheduler abstraction with timezone initialization in `lib/shared/platform/local_notification_scheduler.dart`
- [X] T020 [P] Implement native share gateway abstraction for text and file sharing in `lib/shared/platform/share_gateway.dart`

**Checkpoint**: Foundation ready. User stories can now be implemented in priority order or in parallel by separate owners.

---

## Phase 3: User Story 1 - Start and Resume Daily Reading (Priority: P1) - MVP

**Goal**: A first-time user completes onboarding, reaches a Raqeem home dashboard, sees last reading and today's active wird when available, and resumes reading immediately.

**Independent Test**: A new user completes onboarding, opens home, enters reader, moves to a position, leaves the app, and returns to the same saved position with today's reading guidance visible when an active khatma exists.

### Tests for User Story 1

- [X] T021 [P] [US1] Add onboarding state tests for first launch, language selection, visual mode selection, RTL selection, and save failure in `test/features/onboarding/application/onboarding_view_model_test.dart`
- [X] T022 [P] [US1] Add preferences repository tests for settings persistence and recovery errors in `test/features/settings/infrastructure/preferences_repository_test.dart`
- [X] T023 [P] [US1] Add last-five reading repository tests for insert, dedupe, trim, and newest lookup in `test/features/home/infrastructure/last_reading_repository_test.dart`
- [X] T024 [P] [US1] Add home dashboard view model tests for latest position, active khatma summary, empty state, and shortcut commands in `test/features/home/application/home_view_model_test.dart`
- [X] T025 [P] [US1] Add onboarding-to-home widget journey test with Arabic and English variants in `test/features/onboarding/presentation/onboarding_flow_test.dart`

### Implementation for User Story 1

- [X] T026 [US1] Implement `UserPreferences` entity and JSON mapping in `lib/features/settings/domain/user_preferences.dart`
- [X] T027 [US1] Implement SQLite-backed preferences repository in `lib/features/settings/infrastructure/preferences_repository.dart`
- [X] T028 [US1] Implement onboarding view model state machine in `lib/features/onboarding/application/onboarding_view_model.dart`
- [X] T029 [US1] Build Raqeem onboarding screen with language and visual mode selection in `lib/features/onboarding/presentation/onboarding_screen.dart`
- [X] T030 [US1] Implement `LastReadingEntry` entity and SQLite repository in `lib/features/home/domain/last_reading_entry.dart` and `lib/features/home/infrastructure/last_reading_repository.dart`
- [X] T031 [US1] Implement home dashboard view model that loads preferences, latest reading, active khatma, and today's wird in `lib/features/home/application/home_view_model.dart`
- [X] T032 [US1] Build home dashboard with greeting, continue card, active khatma card, progress, empty states, and shortcuts in `lib/features/home/presentation/home_screen.dart`
- [X] T033 [US1] Add reader launch and recent-entry resume commands to routes in `lib/app/navigation/app_router.dart`
- [X] T034 [US1] Persist app lifecycle pause and reader exit position through `LastReadingRepository` in `lib/features/quran/application/reader_position_service.dart`
- [X] T035 [US1] Document US1 manual verification steps for first launch, resume under 10 seconds, and active wird display in `specs/001-raqeem-quran-app/quickstart.md`

**Checkpoint**: User Story 1 is independently functional and forms the MVP scope.

---

## Phase 4: User Story 2 - Read and Navigate the Mushaf (Priority: P1)

**Goal**: A reader can open Quran pages, navigate by surah, juz, hizb, rub, or page, toggle controls, select an ayah, and keep reading without distracting UI.

**Independent Test**: A user opens the reader, navigates by each supported index type, toggles controls, selects an ayah, and sees ayah actions while Quran text remains sourced from quran_library.

### Tests for User Story 2

- [X] T036 [P] [US2] Add Quran navigation gateway contract tests for page, surah, juz, hizb, rub, invalid input, and compare behavior in `test/features/quran/infrastructure/quran_navigation_gateway_test.dart`
- [X] T037 [P] [US2] Add reader view model tests for loading, ready, control visibility, ayah selection, and save-last-position commands in `test/features/quran/application/reader_view_model_test.dart`
- [X] T038 [P] [US2] Add navigation selector view model tests for supported index types and quick search filtering in `test/features/quran/application/navigation_selector_view_model_test.dart`
- [X] T039 [P] [US2] Add reader widget tests for controls, selection, and error states in `test/features/quran/presentation/quran_reader_screen_test.dart`
- [X] T040 [P] [US2] Add accessibility tests for reader controls, tap targets, labels, and no clipped primary controls in `test/shared/accessibility/reader_accessibility_test.dart`

### Implementation for User Story 2

- [X] T041 [US2] Implement navigation and metadata methods in `lib/features/quran/infrastructure/quran_library_gateway.dart`
- [X] T042 [US2] Implement quran_library reader widget factory for `QuranLibraryScreen` and `QuranPagesScreen` in `lib/features/quran/infrastructure/quran_reader_widget_factory.dart`
- [X] T043 [US2] Define reader state, ayah selection, and control visibility models in `lib/features/quran/application/reader_state.dart`
- [X] T044 [US2] Implement reader view model for open, navigate, toggle controls, select ayah, and save position in `lib/features/quran/application/reader_view_model.dart`
- [X] T045 [US2] Implement navigation selector view model for surah, juz, hizb, rub, and page selection in `lib/features/quran/application/navigation_selector_view_model.dart`
- [X] T046 [US2] Build distraction-free Quran reader screen that composes quran_library widgets in `lib/features/quran/presentation/quran_reader_screen.dart`
- [X] T047 [US2] Build surah, juz, hizb, rub, and page navigation selector UI in `lib/features/quran/presentation/navigation_selector_sheet.dart`
- [X] T048 [US2] Build base ayah action menu shell with audio, tafsir, translation, bookmark, note, copy, share, and wird boundary actions in `lib/features/quran/presentation/ayah_action_menu.dart`
- [X] T049 [US2] Add Raqeem reader style mapping without altering Quran text in `lib/features/quran/presentation/raqeem_reader_style.dart`
- [X] T050 [US2] Integrate last-position tracking from page and ayah changes in `lib/features/quran/application/reader_position_service.dart`
- [X] T051 [US2] Document US2 manual verification for all navigation selectors and control toggling in `specs/001-raqeem-quran-app/quickstart.md`

**Checkpoint**: User Story 2 is independently usable after the foundation and can be demoed as the core Quran reader.

---

## Phase 5: User Story 3 - Reflect on and Share Ayahs (Priority: P2)

**Goal**: A user can select an ayah, view tafsir or translation, copy/share text, generate a styled image, save a bookmark or note, and reopen saved locations.

**Independent Test**: From a selected ayah, a user opens tafsir and translation, shares text and image, saves a bookmark or note, edits/deletes it, and reopens the reader at the saved location.

### Tests for User Story 3

- [X] T052 [P] [US3] Add tafsir and translation gateway tests for source listing, availability, display, and unavailable states in `test/features/quran/infrastructure/quran_explanation_gateway_test.dart`
- [X] T053 [P] [US3] Add bookmark annotation repository tests for create, edit, archive/delete, sort, anchor mapping, and search fields in `test/features/bookmarks/infrastructure/bookmark_repository_test.dart`
- [X] T054 [P] [US3] Add sharing application tests for text reference generation, image draft options, generation failure, and share gateway calls in `test/features/sharing/application/ayah_sharing_service_test.dart`
- [X] T055 [P] [US3] Add ayah action menu widget tests for tafsir, translation, copy, share, bookmark, and note commands in `test/features/quran/presentation/ayah_action_menu_test.dart`
- [X] T056 [P] [US3] Add bookmarks screen widget tests for list, empty, edit, delete, and open-location actions in `test/features/bookmarks/presentation/bookmarks_screen_test.dart`

### Implementation for User Story 3

- [X] T057 [US3] Implement tafsir, translation, selection, copy, and share text methods in `lib/features/quran/infrastructure/quran_library_gateway.dart`
- [X] T058 [US3] Implement `BookmarkAnnotation` entity and validation in `lib/features/bookmarks/domain/bookmark_annotation.dart`
- [X] T059 [US3] Implement SQLite bookmark annotation repository and quran_library anchor coordination in `lib/features/bookmarks/infrastructure/bookmark_repository.dart`
- [X] T060 [US3] Implement bookmark list and editor view models in `lib/features/bookmarks/application/bookmarks_view_model.dart` and `lib/features/bookmarks/application/bookmark_editor_view_model.dart`
- [X] T061 [US3] Build bookmark list, filter/sort, edit, delete, and open-location UI in `lib/features/bookmarks/presentation/bookmarks_screen.dart`
- [X] T062 [US3] Implement `AyahShareDraft` entity and SQLite draft repository in `lib/features/sharing/domain/ayah_share_draft.dart` and `lib/features/sharing/infrastructure/ayah_share_draft_repository.dart`
- [X] T063 [US3] Implement ayah sharing service for copy, text share, preview options, image generation, and failure handling in `lib/features/sharing/application/ayah_sharing_service.dart`
- [X] T064 [US3] Build share image preview and format selection UI in `lib/features/sharing/presentation/share_preview_screen.dart`
- [X] T065 [US3] Build tafsir and translation launch surfaces preserving ayah context in `lib/features/quran/presentation/explanation_sheet.dart`
- [X] T066 [US3] Connect ayah action menu commands to tafsir, translation, bookmarks, notes, copy, text share, and image share in `lib/features/quran/presentation/ayah_action_menu.dart`
- [X] T067 [US3] Document US3 manual verification for native share sheets and generated image output in `specs/001-raqeem-quran-app/quickstart.md`

**Checkpoint**: User Story 3 is independently complete and does not depend on audio or khatma implementation.

---

## Phase 6: User Story 4 - Listen to Recitation (Priority: P2)

**Goal**: A listener can choose a reciter, play ayahs, repeat ayah/range/page/surah/today's wird, navigate playback, and see reader synchronization.

**Independent Test**: A user selects a reciter, plays from an ayah, changes repeat scope, moves next/previous, sees current playback ayah highlighted, and receives clear unavailable guidance for uncached offline audio.

### Tests for User Story 4

- [ ] T068 [P] [US4] Add audio gateway tests for play ayah, play surah, next, previous, download, cancel, last position, and unavailable state mapping in `test/features/audio/infrastructure/quran_audio_gateway_test.dart`
- [ ] T069 [P] [US4] Add playback view model tests for idle, loading, playing, paused, buffering, unavailable, error, and reciter selection in `test/features/audio/application/playback_view_model_test.dart`
- [ ] T070 [P] [US4] Add repeat orchestration tests for ayah, range, page, surah, and today's wird sequencing in `test/features/audio/application/repeat_orchestrator_test.dart`
- [ ] T071 [P] [US4] Add audio controls widget tests for play, pause, next, previous, repeat scope, and offline guidance in `test/features/audio/presentation/audio_controls_test.dart`
- [ ] T072 [P] [US4] Add reader playback synchronization widget tests in `test/features/quran/presentation/reader_playback_sync_test.dart`

### Implementation for User Story 4

- [ ] T073 [US4] Implement `ReciterPreference` and `PlaybackSession` domain models in `lib/features/audio/domain/reciter_preference.dart` and `lib/features/audio/domain/playback_session.dart`
- [ ] T074 [US4] Implement quran_library audio methods and playback stream mapping in `lib/features/audio/infrastructure/quran_audio_gateway.dart`
- [ ] T075 [US4] Implement reciter preference persistence in `lib/features/audio/infrastructure/reciter_preference_repository.dart`
- [ ] T076 [US4] Implement repeat orchestration around quran_library playback in `lib/features/audio/application/repeat_orchestrator.dart`
- [ ] T077 [US4] Implement playback view model with reciter selection and repeat scope commands in `lib/features/audio/application/playback_view_model.dart`
- [ ] T078 [US4] Build compact reader audio controls and repeat scope selector in `lib/features/audio/presentation/audio_controls.dart`
- [ ] T079 [US4] Integrate playback ayah highlighting and auto-scroll option into reader state in `lib/features/quran/application/reader_view_model.dart`
- [ ] T080 [US4] Add audio unavailable, download, and connectivity guidance states in `lib/features/audio/presentation/audio_unavailable_view.dart`
- [ ] T081 [US4] Document Android and iOS manual audio verification for system controls, background audio, and offline uncached behavior in `specs/001-raqeem-quran-app/quickstart.md`

**Checkpoint**: User Story 4 is independently complete after the reader exists and introduces no custom audio catalog.

---

## Phase 7: User Story 5 - Plan and Track a Khatma (Priority: P2)

**Goal**: A user creates a khatma with range, end date or number of days, active days, reminder time, and page-based distribution, then tracks daily wird progress and handles missed days.

**Independent Test**: A user creates valid khatmas using both the end-date path and the number-of-days path, receives daily wird entries covering the selected range without gaps or overlaps, completes today's wird, sees progress update, and handles missed or edited days predictably.

### Tests for User Story 5

- [ ] T082 [P] [US5] Add khatma domain tests for range validation, end-date and number-of-days schedule derivation, active weekday generation, page distribution, remainder pages, and ayah boundary adjustment in `test/features/khatma/domain/khatma_distribution_test.dart`
- [ ] T083 [P] [US5] Add khatma repository tests for transactional creation, active uniqueness, completed-day immutability, cascade delete, and missed-day decisions in `test/features/khatma/infrastructure/khatma_repository_test.dart`
- [ ] T084 [P] [US5] Add reminder repository and scheduler tests for permission states, schedule IDs, denied permission, and weekday validation in `test/features/khatma/infrastructure/reminder_repository_test.dart`
- [ ] T085 [P] [US5] Add khatma creation view model tests for end-date input, number-of-days input, validation, warning, preview, create, and make-active commands in `test/features/khatma/application/khatma_creation_view_model_test.dart`
- [ ] T086 [P] [US5] Add khatma progress view model tests for complete, pause, resume, edit, and missed-day handling in `test/features/khatma/application/khatma_progress_view_model_test.dart`
- [ ] T087 [P] [US5] Add khatma creation and progress widget tests for end-date and number-of-days flows in `test/features/khatma/presentation/khatma_flow_test.dart`

### Implementation for User Story 5

- [ ] T088 [US5] Implement `KhatmaPlan`, `DailyWird`, and `ReminderSetting` domain entities in `lib/features/khatma/domain/khatma_plan.dart`, `lib/features/khatma/domain/daily_wird.dart`, and `lib/features/khatma/domain/reminder_setting.dart`
- [ ] T089 [US5] Implement page-based khatma distribution, number-of-days schedule derivation, and boundary adjustment service in `lib/features/khatma/domain/khatma_distribution_service.dart`
- [ ] T090 [US5] Implement khatma progress calculation and missed-day decision rules in `lib/features/khatma/domain/khatma_progress_service.dart`
- [ ] T091 [US5] Implement transactional SQLite khatma repository in `lib/features/khatma/infrastructure/khatma_repository.dart`
- [ ] T092 [US5] Implement reminder repository and local notification scheduling bridge in `lib/features/khatma/infrastructure/reminder_repository.dart`
- [ ] T093 [US5] Implement khatma creation view model with end-date input, number-of-days input, validation, preview, large-wird warning, create, and make-active prompt in `lib/features/khatma/application/khatma_creation_view_model.dart`
- [ ] T094 [US5] Implement khatma progress view model for continue, complete, pause, resume, edit, and missed-day commands in `lib/features/khatma/application/khatma_progress_view_model.dart`
- [ ] T095 [US5] Build khatma creation screen with range, end-date or number-of-days controls, weekdays, distribution mode, and reminder controls in `lib/features/khatma/presentation/khatma_creation_screen.dart`
- [ ] T096 [US5] Build wird preview and validation feedback UI in `lib/features/khatma/presentation/wird_preview_panel.dart`
- [ ] T097 [US5] Build khatma progress screen with today's wird, completion, missed handling, and overall progress in `lib/features/khatma/presentation/khatma_progress_screen.dart`
- [ ] T098 [US5] Integrate active khatma selection and new-plan make-active prompt into home dashboard in `lib/features/home/application/home_view_model.dart`
- [ ] T099 [US5] Integrate wird boundary actions from selected ayahs into khatma creation state in `lib/features/quran/presentation/ayah_action_menu.dart`
- [ ] T100 [US5] Document US5 manual verification for end-date creation, number-of-days creation, reminder permission grant/denial, missed-day decisions, and distribution coverage in `specs/001-raqeem-quran-app/quickstart.md`

**Checkpoint**: User Story 5 is independently complete and updates the home dashboard only through the active khatma contract.

---

## Phase 8: User Story 6 - Personalize Reading and App Behavior (Priority: P3)

**Goal**: A user changes language, visual mode, reading display, audio defaults, khatma defaults, reminder defaults, accessibility text choices, and search behavior, then sees those choices persist.

**Independent Test**: A user changes settings, closes and reopens the app, sees persisted behavior in reader/home/audio/khatma defaults, searches across available Quran/app-owned sources, and verifies Arabic RTL and English LTR layouts.

### Tests for User Story 6

- [ ] T101 [P] [US6] Add settings view model tests for language, visual mode, reader text scale, audio defaults, khatma defaults, and reminder defaults in `test/features/settings/application/settings_view_model_test.dart`
- [ ] T102 [P] [US6] Add search gateway and repository tests for ayah, surah, bookmark, note, tafsir availability, blank query, and no-result preservation in `test/features/search/application/search_service_test.dart`
- [ ] T103 [P] [US6] Add settings screen widget tests for persistence, labels, text scale, and no reader position loss in `test/features/settings/presentation/settings_screen_test.dart`
- [ ] T104 [P] [US6] Add search screen widget tests for filters, grouped results, empty state, no-result state, and open-result commands in `test/features/search/presentation/search_screen_test.dart`
- [ ] T105 [P] [US6] Add RTL/LTR and supported text-size accessibility tests across primary screens in `test/shared/accessibility/localization_accessibility_test.dart`

### Implementation for User Story 6

- [ ] T106 [US6] Extend `UserPreferences` with reader display, audio defaults, khatma defaults, reminder defaults, and accessibility text fields in `lib/features/settings/domain/user_preferences.dart`
- [ ] T107 [US6] Implement settings view model with persisted language, visual mode, reader, audio, khatma, reminder, and accessibility commands in `lib/features/settings/application/settings_view_model.dart`
- [ ] T108 [US6] Build settings screen with language, visual mode, reader display, audio defaults, khatma defaults, reminder defaults, and text preference controls in `lib/features/settings/presentation/settings_screen.dart`
- [ ] T109 [US6] Apply settings changes to app locale, directionality, theme, and reader state without losing reader position in `lib/app/app.dart`
- [ ] T110 [US6] Implement search result domain model and filters in `lib/features/search/domain/search_result.dart` and `lib/features/search/domain/search_filter.dart`
- [ ] T111 [US6] Implement search service combining quran_library ayah/surah/tafsir results with SQLite bookmark/note results in `lib/features/search/application/search_service.dart`
- [ ] T112 [US6] Implement search view model with query preservation, filters, grouped results, unavailable states, and open-result commands in `lib/features/search/application/search_view_model.dart`
- [ ] T113 [US6] Build search screen with grouped results, filters, loading, empty, no-result, and unavailable states in `lib/features/search/presentation/search_screen.dart`
- [ ] T114 [US6] Add Arabic and English labels for MVP screens and primary controls in `lib/app/localization/app_localizations.dart`
- [ ] T115 [US6] Document US6 manual verification for settings persistence, search coverage, usability validation evidence, RTL/LTR layout, and supported text sizes in `specs/001-raqeem-quran-app/quickstart.md`

**Checkpoint**: User Story 6 is independently complete and finalizes P3 personalization and search requirements.

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Quality gates, accessibility, performance, and release readiness across all selected stories.

- [ ] T116 [P] Add shared loading, empty, error, and unavailable state widgets used by MVP screens in `lib/shared/widgets/async_state_views.dart`
- [ ] T117 [P] Add shared accessibility helpers for labels, tap target constraints, and text scale bounds in `lib/shared/accessibility/accessibility_helpers.dart`
- [ ] T118 Review and remove all starter counter UI and generic placeholder copy from `lib/main.dart`, `lib/app/`, and `lib/features/`
- [ ] T119 Verify Quran text integrity boundaries and direct quran_library access restrictions in `lib/features/quran/`
- [ ] T120 Optimize launch and resume paths for the 10-second continue-reading target in `lib/app/bootstrap.dart` and `lib/features/home/application/home_view_model.dart`
- [ ] T121 Add final manual verification notes for Android, iOS, offline verification matrix, sharing, notifications, Arabic, English, usability validation, design review, and accessibility in `specs/001-raqeem-quran-app/quickstart.md`
- [ ] T122 Run `dart format lib test` and fix formatting issues in `lib/` and `test/`
- [ ] T123 Run `flutter analyze`, `flutter test`, and `flutter test --coverage` and fix reported issues in `lib/` and `test/`
- [ ] T124 Run `flutter build apk --debug` and fix Android build issues in `android/` and `lib/`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 Setup**: No dependencies; can start immediately.
- **Phase 2 Foundational**: Depends on Phase 1; blocks every user story.
- **Phase 3 US1**: Depends on Phase 2; MVP scope.
- **Phase 4 US2**: Depends on Phase 2 and integrates with US1 last-position persistence, but remains independently testable with fakes.
- **Phase 5 US3**: Depends on Phase 2 and US2 ayah selection shell.
- **Phase 6 US4**: Depends on Phase 2 and US2 reader shell.
- **Phase 7 US5**: Depends on Phase 2; integrates with US1 home dashboard and US2 ayah boundary actions where available.
- **Phase 8 US6**: Depends on Phase 2; can proceed after US1/US2 basics exist for full UI verification.
- **Phase 9 Polish**: Depends on all stories selected for the implementation milestone.

### User Story Dependencies

- **US1 Start and Resume Daily Reading (P1)**: First MVP increment after foundational work.
- **US2 Read and Navigate the Mushaf (P1)**: Can start after foundational work; should be completed before deep ayah actions.
- **US3 Reflect on and Share Ayahs (P2)**: Requires ayah selection from US2.
- **US4 Listen to Recitation (P2)**: Requires reader integration from US2; can be developed in parallel with US3.
- **US5 Plan and Track a Khatma (P2)**: Can develop domain/persistence in parallel with US3/US4, including end-date and number-of-days schedule derivation, then integrate with US1/US2.
- **US6 Personalize Reading and App Behavior (P3)**: Best after core UI exists, but search/settings services can start once foundation is complete.

### Within Each User Story

- Write tests first for state logic, repositories, quran_library adaptor behavior, widget flows, and accessibility cases.
- Implement domain models before repositories and services.
- Implement repositories/gateways before view models.
- Implement view models before widgets.
- Complete and verify each story independently before relying on it from a later story.

---

## Parallel Opportunities

- Phase 1 tasks T003, T004, T005, and T006 can run in parallel after T001 is understood.
- Phase 2 tasks T008, T011, T014, T016, T019, and T020 can run in parallel with the database and quran gateway contract work.
- All test tasks marked `[P]` inside a story can run in parallel because they target separate files.
- US3, US4, and US5 can be split after US2 exposes the reader and ayah selection contract.
- US6 search service work can run in parallel with settings UI once shared preferences and search gateway contracts exist.

---

## Parallel Example: User Story 1

```text
Task: "T021 [P] [US1] Add onboarding state tests in test/features/onboarding/application/onboarding_view_model_test.dart"
Task: "T022 [P] [US1] Add preferences repository tests in test/features/settings/infrastructure/preferences_repository_test.dart"
Task: "T023 [P] [US1] Add last-five reading repository tests in test/features/home/infrastructure/last_reading_repository_test.dart"
Task: "T024 [P] [US1] Add home dashboard view model tests in test/features/home/application/home_view_model_test.dart"
Task: "T025 [P] [US1] Add onboarding-to-home widget journey test in test/features/onboarding/presentation/onboarding_flow_test.dart"
```

## Parallel Example: User Story 2

```text
Task: "T036 [P] [US2] Add Quran navigation gateway tests in test/features/quran/infrastructure/quran_navigation_gateway_test.dart"
Task: "T037 [P] [US2] Add reader view model tests in test/features/quran/application/reader_view_model_test.dart"
Task: "T038 [P] [US2] Add navigation selector view model tests in test/features/quran/application/navigation_selector_view_model_test.dart"
Task: "T039 [P] [US2] Add reader widget tests in test/features/quran/presentation/quran_reader_screen_test.dart"
Task: "T040 [P] [US2] Add accessibility tests in test/shared/accessibility/reader_accessibility_test.dart"
```

## Parallel Example: User Story 3

```text
Task: "T052 [P] [US3] Add tafsir and translation gateway tests in test/features/quran/infrastructure/quran_explanation_gateway_test.dart"
Task: "T053 [P] [US3] Add bookmark annotation repository tests in test/features/bookmarks/infrastructure/bookmark_repository_test.dart"
Task: "T054 [P] [US3] Add sharing application tests in test/features/sharing/application/ayah_sharing_service_test.dart"
Task: "T055 [P] [US3] Add ayah action menu widget tests in test/features/quran/presentation/ayah_action_menu_test.dart"
Task: "T056 [P] [US3] Add bookmarks screen widget tests in test/features/bookmarks/presentation/bookmarks_screen_test.dart"
```

## Parallel Example: User Story 4

```text
Task: "T068 [P] [US4] Add audio gateway tests in test/features/audio/infrastructure/quran_audio_gateway_test.dart"
Task: "T069 [P] [US4] Add playback view model tests in test/features/audio/application/playback_view_model_test.dart"
Task: "T070 [P] [US4] Add repeat orchestration tests in test/features/audio/application/repeat_orchestrator_test.dart"
Task: "T071 [P] [US4] Add audio controls widget tests in test/features/audio/presentation/audio_controls_test.dart"
Task: "T072 [P] [US4] Add reader playback synchronization widget tests in test/features/quran/presentation/reader_playback_sync_test.dart"
```

## Parallel Example: User Story 5

```text
Task: "T082 [P] [US5] Add khatma domain tests in test/features/khatma/domain/khatma_distribution_test.dart"
Task: "T083 [P] [US5] Add khatma repository tests in test/features/khatma/infrastructure/khatma_repository_test.dart"
Task: "T084 [P] [US5] Add reminder repository and scheduler tests in test/features/khatma/infrastructure/reminder_repository_test.dart"
Task: "T085 [P] [US5] Add khatma creation view model tests in test/features/khatma/application/khatma_creation_view_model_test.dart"
Task: "T086 [P] [US5] Add khatma progress view model tests in test/features/khatma/application/khatma_progress_view_model_test.dart"
Task: "T087 [P] [US5] Add khatma creation and progress widget tests in test/features/khatma/presentation/khatma_flow_test.dart"
```

## Parallel Example: User Story 6

```text
Task: "T101 [P] [US6] Add settings view model tests in test/features/settings/application/settings_view_model_test.dart"
Task: "T102 [P] [US6] Add search gateway and repository tests in test/features/search/application/search_service_test.dart"
Task: "T103 [P] [US6] Add settings screen widget tests in test/features/settings/presentation/settings_screen_test.dart"
Task: "T104 [P] [US6] Add search screen widget tests in test/features/search/presentation/search_screen_test.dart"
Task: "T105 [P] [US6] Add RTL/LTR accessibility tests in test/shared/accessibility/localization_accessibility_test.dart"
```

---

## Implementation Strategy

### MVP First (US1 Only)

1. Complete Phase 1 setup.
2. Complete Phase 2 foundation.
3. Complete Phase 3 US1.
4. Stop and validate onboarding, home dashboard, last reading persistence, active khatma summary placeholder, and continue-reading path.

### Core Reading Increment

1. Complete US2 after US1.
2. Validate reader rendering through quran_library, navigation selectors, control toggling, ayah selection, and last-position updates.
3. Demo US1 plus US2 as the minimum Quran reading experience.

### P2 Feature Increments

1. Add US3 for tafsir, translation, bookmarks, notes, and sharing.
2. Add US4 for audio playback and repeat orchestration.
3. Add US5 for khatma planning, wird progress, reminders, and missed-day handling.
4. Validate each story independently before integrating the next one.

### P3 Completion

1. Add US6 settings, localization persistence, search, and accessibility coverage.
2. Complete Phase 9 polish and quality gates.
3. Run the full quickstart manual checklist before release readiness review.

---

## Independent Test Criteria Summary

- **US1**: First launch onboarding, home dashboard, resume position persistence, and active khatma/today's wird visibility work without relying on later stories.
- **US2**: Reader opens through quran_library, navigates by all required index types, toggles controls, selects ayahs, and persists position.
- **US3**: Selected ayah supports tafsir, translation, text share, image share, bookmark/note save, bookmark list management, and reopen-location.
- **US4**: Audio plays from ayah/surah, supports repeat scopes, synchronizes visible reader state, and handles uncached offline audio clearly.
- **US5**: Khatma creation validates end-date and number-of-days inputs, generates full coverage with no gaps/overlaps, updates progress, and handles missed days and reminders.
- **US6**: Settings persist across restart, primary screens respect Arabic/English and text-size choices, and search covers quran_library and app-owned data sources.

## Notes

- `[P]` tasks must not touch the same file or depend on incomplete work.
- No task may duplicate Quran text, Quran ordering, mushaf rendering, Quran search indexes, tafsir corpora, translation corpora, or audio catalogs.
- Platform-only behavior must be captured in `specs/001-raqeem-quran-app/quickstart.md` because automated Flutter tests cannot fully cover Android/iOS audio, notifications, and share sheets.
- Commit after each completed task or coherent group when using the optional git hook workflow.
