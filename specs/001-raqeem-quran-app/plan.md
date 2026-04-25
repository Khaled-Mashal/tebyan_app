# Implementation Plan: Raqeem Interactive Quran App

**Branch**: `001-raqeem-quran-app` | **Date**: 2026-04-25 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `C:\dev_Projects\tebyan_app\specs\001-raqeem-quran-app\spec.md`

**Note**: This plan is filled by the `/speckit.plan` workflow and stops before task generation.

## Summary

Build the Raqeem MVP as an offline-first Flutter Quran reading application for Android and iOS phones. The implementation composes `quran_library: 4.0.1` for Quran rendering, canonical Quran metadata, navigation, selection, tafsir, translations, search, bookmarks, and audio. Raqeem-owned logic is limited to app experience, navigation shell, onboarding, preferences, last reading history, khatma planning/progress, reminder scheduling, share-image composition, accessibility, and visual identity.

The app will replace the starter counter screen with a feature-oriented Flutter structure. Presentation widgets remain thin; state and workflows live in `ChangeNotifier` view models exposed by `provider`; Quran capability access is isolated behind a `QuranGateway` adaptor; durable app data is stored in SQLite through `sqflite`; native share and local reminder behavior use focused platform plugins. No Quran text, ordering, mushaf rendering, search index, tafsir corpus, translation corpus, or audio catalog is duplicated.

## Technical Context

**Language/Version**: Flutter 3.41.0 stable, Dart 3.11.0, SDK constraint `^3.11.0`  
**Primary Dependencies**: Existing `quran_library: 4.0.1`; planned additions: `provider: ^6.1.5+1`, `sqflite: ^2.4.2+1`, `path: ^1.9.1`, `share_plus: ^13.1.0`, `flutter_local_notifications: ^21.0.0`, `timezone: ^0.11.0`  
**Storage**: App-owned SQLite database via `sqflite` for preferences, recent reading entries, bookmark annotations, khatma plans, daily wird entries, reminder metadata, and share drafts. `quran_library` remains responsible for Quran data/cache/storage it owns.  
**Testing**: `flutter test`, domain/application unit tests, repository tests with an injectable database factory, quran_library adaptor contract tests using fakes, widget tests for primary flows, Flutter accessibility guideline tests, and documented manual Android/iOS checks for audio, sharing, and notifications.  
**Target Platform**: MVP release-blocking scope is Android and iOS phones. Web, Windows, macOS, and Linux remain compatible Flutter targets but are not MVP release blockers unless separately enabled.
**Project Type**: Flutter interactive Quran application  
**Performance Goals**: Returning user reaches continue action within 10 seconds after launch; page navigation and selector jumps feel immediate on supported phones; saving last position completes asynchronously without blocking reading; khatma generation for a full Quran date range completes before returning to the creation result screen; share image generation completes or reports failure within 30 seconds from ayah selection.  
**Constraints**: `quran_library: 4.0.1` is the Quran platform; `QuranLibrary.init()` runs before Quran screens; Material 3 is disabled for Quran screens because the package README warns it can cause rendering/formation problems; Quran text is read-only; reading remains offline; uncached audio, tafsir, translations, fonts, or word info may require connectivity according to quran_library availability; Android audio controls require `MainActivity` to extend `AudioServiceActivity`; iOS background audio requires `UIBackgroundModes/audio`.  
**Scale/Scope**: MVP covers onboarding, home dashboard, Quran reader, navigation selectors, ayah action menu, tafsir/translation, text/image sharing, bookmarks/notes, audio playback/repeat orchestration, khatma planning/progress/missed-day handling, reminders, search, settings, Arabic/English localization, light/night visual modes, and accessibility baseline.

## Visual Identity & Design Acceptance

The feature inherits the approved Raqeem identity from the repository root `plan.md` and applies it to every MVP screen. The palette is mandatory unless a calm success, warning, or error color is required for understandable feedback:

| Element | Hex Code | Usage |
|---------|----------|-------|
| Primary Color | `0xFFB49464` | Main buttons, active icons, and primary branding |
| Background | `0xFFF5F0E5` | Main scaffold and page backgrounds |
| Surface/Card | `0xFFEFE6D5` | Lists, cards, and container backgrounds |
| Primary Text | `0xFF3E2723` | Headlines, surah names, and bold titles |
| Secondary Text | `0xFF7D6E5D` | Subtitles, tafsir text, and descriptions |
| Accent Gold | `0xFFD4B982` | Selection states and progress bars |
| Soft White | `0xFFFAF8F2` | Reading screens and modal bottom sheets |

Release-readiness design review must confirm: no starter Flutter/default-purple surfaces remain; Quran screens use the Raqeem visual language while preserving quran_library text integrity; light and night modes are readable; primary controls meet accessibility sizing; and Arabic/English layouts retain the same brand quality.

## Research Evidence

- **quran_library**: Context7 resolved `/alheekmahlib/quran_library` and documented `QuranLibrary.init()`, `QuranLibraryScreen`, `QuranPagesScreen`, `jumpToPage`, `jumpToJoz`, `jumpToHizb`, `jumpToSurah`, `jumpToBookmark`, `search`, bookmark APIs, tafsir/translation APIs, ayah and surah playback, surah download, and word audio APIs. Local package README/API inspection confirmed version 4.0.1 details, Android/iOS audio setup, and the `useMaterial3: false` warning. Source: https://github.com/alheekmahlib/quran_library and https://pub.dev/packages/quran_library
- **Flutter architecture**: Context7 resolved official Flutter docs `/websites/flutter_dev`, including architecture guidance, separation into layers, testing strategy, internationalization/RTL considerations, and accessibility guideline tests for labels, contrast, and 44/48px tap targets. Source: https://docs.flutter.dev/app-architecture and https://docs.flutter.dev/ui/accessibility/accessibility-testing
- **State management**: Context7 resolved Provider `/websites/pub_dev_packages_provider`; selected for small, explicit `ChangeNotifier` view models, `MultiProvider`, `Consumer`, and `Selector` without adopting a larger framework. Source: https://pub.dev/packages/provider
- **Local persistence**: Context7 resolved sqflite `/tekartik/sqflite`; selected for structured local records, schema versioning, transactions, batches, and repository-pattern tests. `shared_preferences` was researched and rejected for critical app data because its docs state persistence is asynchronous and not guaranteed immediately. Sources: https://pub.dev/packages/sqflite and https://pub.dev/packages/shared_preferences
- **Reminders**: Context7 resolved flutter_local_notifications `/maikub/flutter_local_notifications`; selected for daily/weekly scheduled local reminders using notification channels, permission requests, and `zonedSchedule`. `timezone` could not be resolved in Context7 and falls back to pub.dev. Sources: https://pub.dev/packages/flutter_local_notifications and https://pub.dev/packages/timezone
- **Sharing**: Context7 resolved `share_plus` `/websites/pub_dev_packages_share_plus`; selected for platform share sheets with text and generated image files through `SharePlus.instance.share` and `XFile`. Source: https://pub.dev/packages/share_plus
- **Path handling**: Context7 did not resolve the Dart `path` package directly; fallback is pub.dev. It is required with sqflite for deterministic database path composition. Source: https://pub.dev/packages/path
- **Version decisions**: `quran_library` remains pinned to `4.0.1` by constitution. `dart pub add --dry-run` on 2026-04-25 resolved latest compatible stable direct versions for planned additions: provider 6.1.5+1, sqflite 2.4.2+1, path 1.9.1, share_plus 13.1.0, flutter_local_notifications 21.0.0, timezone 0.11.0.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Quran Library Boundary**: Quran rendering, metadata, navigation, audio, tafsir,
  translations, search, and bookmarks use `quran_library: 4.0.1`; no duplicate
  Quran content or parallel Quran domain engine is introduced.
- **Clean Flutter Architecture**: Plan identifies presentation, state/application,
  quran_library adaptor, persistence, and test boundaries with real paths.
- **Context7-First Research**: Context7 evidence is recorded for quran_library,
  Flutter architecture, and each changed dependency; official fallback sources
  are cited only when Context7 cannot answer.
- **Testable Interactive Experience**: Plan defines state, adaptor, widget, and
  manual verification coverage for critical reading/navigation/playback flows.
- **Professional Quality Gates**: Plan lists commands for formatting, static
  analysis, tests, quickstart/manual verification, and any justified exceptions.

**Pre-Research Gate Result**: PASS. The initial plan commits to quran_library-first behavior, feature-layered Flutter architecture, Context7 research for each technical choice, testable state/adaptor/widget boundaries, and executable quality gates.

**Post-Design Gate Result**: PASS. `research.md`, `data-model.md`, `contracts/`, and `quickstart.md` preserve the constitution boundaries. No custom Quran renderer, Quran corpus, independent Quran search engine, or duplicate Quran audio catalog is introduced. The only app-owned persistence is Raqeem metadata and workflow state.

## Project Structure

### Documentation (this feature)

```text
specs/001-raqeem-quran-app/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/
│   ├── application-flows-contract.md
│   ├── local-storage-contract.md
│   └── quran-adapter-contract.md
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
lib/
├── app/
│   ├── app.dart
│   ├── bootstrap.dart
│   ├── localization/
│   ├── navigation/
│   └── theme/
├── features/
│   ├── audio/
│   │   ├── application/
│   │   ├── domain/
│   │   ├── infrastructure/
│   │   └── presentation/
│   ├── bookmarks/
│   │   ├── application/
│   │   ├── domain/
│   │   ├── infrastructure/
│   │   └── presentation/
│   ├── home/
│   │   ├── application/
│   │   └── presentation/
│   ├── khatma/
│   │   ├── application/
│   │   ├── domain/
│   │   ├── infrastructure/
│   │   └── presentation/
│   ├── onboarding/
│   │   ├── application/
│   │   └── presentation/
│   ├── quran/
│       ├── presentation/
│       ├── application/
│       ├── domain/
│       └── infrastructure/
│   ├── search/
│   │   ├── application/
│   │   ├── domain/
│   │   └── presentation/
│   ├── settings/
│   │   ├── application/
│   │   ├── domain/
│   │   └── presentation/
│   └── sharing/
│       ├── application/
│       ├── domain/
│       ├── infrastructure/
│       └── presentation/
├── shared/
│   ├── accessibility/
│   ├── errors/
│   ├── persistence/
│   ├── platform/
│   └── widgets/
└── main.dart

test/
├── features/
│   ├── audio/
│   ├── bookmarks/
│   ├── home/
│   ├── khatma/
│   ├── onboarding/
│   ├── quran/
│   ├── search/
│   ├── settings/
│   └── sharing/
└── shared/
    ├── accessibility/
    ├── fakes/
    └── persistence/
```

**Structure Decision**: Use one Flutter app with feature folders and clean boundaries. `lib/features/quran/infrastructure/` owns the quran_library adaptor. `lib/shared/persistence/` owns SQLite setup and migrations. Each feature owns its own presentation and application state; shared UI is added only after at least two real features need it.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | N/A | N/A |

## Phase 0 Output

Generated: `C:\dev_Projects\tebyan_app\specs\001-raqeem-quran-app\research.md`

All technical unknowns from the template are resolved. quran_library limitations and exact app-owned responsibilities are recorded before design.

## Phase 1 Output

Generated:

- `C:\dev_Projects\tebyan_app\specs\001-raqeem-quran-app\data-model.md`
- `C:\dev_Projects\tebyan_app\specs\001-raqeem-quran-app\quickstart.md`
- `C:\dev_Projects\tebyan_app\specs\001-raqeem-quran-app\contracts\application-flows-contract.md`
- `C:\dev_Projects\tebyan_app\specs\001-raqeem-quran-app\contracts\local-storage-contract.md`
- `C:\dev_Projects\tebyan_app\specs\001-raqeem-quran-app\contracts\quran-adapter-contract.md`

## Quality Gates

Implementation is not complete until these pass:

```powershell
dart format lib test
flutter analyze
flutter test
flutter test --coverage
flutter build apk --debug
```

Manual verification must cover:

- Android Quran library audio controls with `AudioServiceActivity`.
- iOS background audio with `UIBackgroundModes/audio`.
- Android/iOS notification permission denial and grant paths.
- Text and image sharing through native share sheets.
- Offline reading, offline app-owned data, and uncached-audio unavailable state.
- Arabic RTL and English LTR layout.
- Accessibility guideline checks and supported text-size review.
