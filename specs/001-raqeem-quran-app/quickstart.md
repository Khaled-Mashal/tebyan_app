# Quickstart: Raqeem Interactive Quran App

**Feature**: `001-raqeem-quran-app`  
**Repo**: `C:\dev_Projects\tebyan_app`

## 1. Verify Toolchain

```powershell
flutter --version
dart --version
```

Expected planning baseline:

- Flutter 3.41.0 stable
- Dart 3.11.0

## 2. Add Planned Dependencies

Do not change the quran_library pin without amending the constitution.

```powershell
dart pub add provider sqflite path share_plus flutter_local_notifications timezone
```

Expected compatible versions from the planning dry run on 2026-04-25:

- `quran_library: 4.0.1`
- `provider: ^6.1.5+1`
- `sqflite: ^2.4.2+1`
- `path: ^1.9.1`
- `share_plus: ^13.1.0`
- `flutter_local_notifications: ^21.0.0`
- `timezone: ^0.11.0`

## 3. Bootstrap Requirements

`lib/main.dart` must initialize Flutter bindings, quran_library, local database, notifications, and app providers before rendering Quran screens.

Required Quran initialization shape:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await QuranLibrary.init();
  runApp(const RaqeemApp());
}
```

Use `QuranLibrary.initWordAudio()` only if word audio becomes an enabled feature.

## 4. Theme Requirement

Because quran_library 4.0.1 warns that Material 3 can cause formation problems, Quran reader routes must be wrapped in a theme where:

```dart
useMaterial3: false
```

The rest of the app should still use the Raqeem palette and avoid starter Flutter purple/default screens.

## 5. Android Audio Setup

Update Android `MainActivity` for quran_library system audio controls:

```kotlin
import com.ryanheise.audioservice.AudioServiceActivity

class MainActivity: AudioServiceActivity()
```

If this is not configured, local playback may still work, but system controls can fail.

## 6. iOS Audio Setup

Add background audio mode to `ios/Runner/Info.plist` if background playback is in scope for the build:

```xml
<key>UIBackgroundModes</key>
<array>
  <string>audio</string>
</array>
```

## 7. Implementation Verification Commands

Run before marking the feature complete:

```powershell
dart format lib test
flutter analyze
flutter test
flutter test --coverage
flutter build apk --debug
```

## 8. Manual Verification Checklist

### US1: Start and Resume Daily Reading

#### First Launch
- [ ] First launch shows the Raqeem splash screen with the app name "رقيم" and a loading indicator.
- [ ] When no saved preferences exist, the app routes to the onboarding screen.
- [ ] Onboarding presents Arabic and English language options with Arabic selected by default.
- [ ] Onboarding presents light, night, and system visual mode options with light selected by default.
- [ ] Selecting Arabic sets the entire onboarding layout to right-to-left.
- [ ] Selecting English sets the layout to left-to-right.
- [ ] Completing onboarding persists the selected language, visual mode, and RTL direction.
- [ ] After onboarding completion, the app navigates to the home dashboard.

#### Returning Launch
- [ ] Returning launch (with completed onboarding) skips onboarding and opens the home dashboard directly.
- [ ] The home dashboard displays the Raqeem visual identity: warm parchment background, gold accents, brown text.
- [ ] The home dashboard greeting shows "السلام عليكم ورحمة الله" in Arabic or "Peace be upon you" in English.
- [ ] The continue reading card shows the last surah name, page number, and ayah number.
- [ ] Tapping "استمرار" / "Resume" navigates to the reader route with the saved Quran position.

#### Resume Under 10 Seconds
- [ ] From app launch to continue-reading action takes 10 seconds or less on a typical supported phone.
- [ ] The continue reading button is immediately visible without scrolling on standard phone sizes.

#### Active Wird Display
- [ ] When an active khatma exists, the home dashboard shows the khatma card with name, today's wird title, and progress bar.
- [ ] When no active khatma exists, the khatma card is not shown (no empty placeholder).
- [ ] The progress bar uses the accent gold color and shows the correct percentage.

#### Empty State
- [ ] When no reading history exists, the home dashboard shows the "ابدأ رحلتك مع القرآن الكريم" / "Start Your Quran Journey" card.
- [ ] The empty state card has an "فتح القارئ" / "Open Reader" button that navigates to the reader.

#### Shortcuts
- [ ] The quick access shortcuts section shows reader, bookmarks, search, and khatma icons.
- [ ] Tapping each shortcut navigates to the corresponding route.

#### Error and Retry
- [ ] When dashboard data fails to load, a calm error view appears with a retry button.
- [ ] Tapping retry reloads the dashboard without losing the app context.

### General MVP Checks

- First launch opens onboarding, stores Arabic/English language and visual mode, and routes to home.
- Returning launch shows last reading entry and active khatma/today's wird when available.
- Reader opens via quran_library, changes pages, hides/shows controls, selects ayah, and saves latest position.
- Navigation works by surah, juz, hizb, rub, and page.
- Tafsir/translation opens from selected ayah and preserves reference context.
- Copy/share text includes ayah reference.
- Share image preview generates a Raqeem-branded image and opens native share sheet.
- Bookmark/note is saved, listed, edited, deleted, and can reopen reader at the saved position.
- Audio plays an ayah, moves next/previous, plays surah, and reports offline unavailable state for uncached audio.
- Repeat ayah/range/page/surah/today's wird is understandable and does not use a custom audio catalog.
- Khatma creation rejects invalid ranges and zero active days.
- Khatma creation succeeds with an explicit end date and generates the same date used in preview, reminders, and persisted daily wird rows.
- Khatma creation succeeds with a number of days and derives a final schedule date used consistently in preview, reminders, and persisted daily wird rows.
- Khatma generation covers the selected range with no gaps or overlaps.
- Completing today's wird updates daily and overall progress immediately.
- Missed wird decisions support carry forward, redistribute, and keep missed.
- Reminder permission grant/denial is handled on Android and iOS.
- Arabic RTL and English LTR primary screens are reviewed.
- Supported text sizes do not clip primary labels and primary touch targets meet at least 44px.

## 9. Offline Verification Matrix

Run this matrix with network disabled after at least one normal online launch and after app-owned records have been created.

| Flow | Expected Offline Result |
|------|-------------------------|
| Quran reader | Previously available core reading opens without account or internet and does not alter Quran text. |
| Last reading | Latest saved position and recent entries remain visible and resumable. |
| Bookmarks and notes | Saved annotations list, edit, delete, and reopen saved Quran positions. |
| Settings | Language, visual mode, reader text, audio defaults, khatma defaults, and reminder defaults remain persisted. |
| Khatma progress | Active khatma, today's wird, completion state, missed decisions, and progress remain usable. |
| Audio | Cached/downloaded audio can be reused when available; uncached audio shows unavailable/connectivity guidance without blocking reading. |
| Sharing | Text sharing remains available from selected ayah context; image generation reports a clear failure if platform resources are unavailable. |

## 10. Usability and Design Review Evidence

Before release readiness, record a usability pass with at least 10 representative participants or internal testers. For each tester, capture device/OS, locale, task completion, completion time where the success criterion specifies one, and whether assistance was required.

Required tasks:

- Navigate from home to a specific surah or page without assistance.
- Select an ayah and complete one ayah action within 20 seconds.
- Create a valid khatma plan and explain today's wird without external instructions.
- Add a bookmark and reopen the saved Quran position later.

Design review must confirm the approved Raqeem palette is applied consistently:

- Primary Color `0xFFB49464`
- Background `0xFFF5F0E5`
- Surface/Card `0xFFEFE6D5`
- Primary Text `0xFF3E2723`
- Secondary Text `0xFF7D6E5D`
- Accent Gold `0xFFD4B982`
- Soft White `0xFFFAF8F2`

Confirm no starter Flutter/default-purple screens remain, light and night reading modes remain comfortable, Arabic RTL and English LTR layouts retain brand quality, and primary controls meet the accessibility baseline.

## 11. Test Coverage Expectations

- Domain tests for Quran range ordering, khatma end-date and number-of-days scheduling, page distribution, active weekday generation, missed-day handling, and progress calculation.
- Repository tests for SQLite migrations, transactions, last-five reading retention, active khatma uniqueness, and cascade delete.
- Adaptor tests with fakes around quran_library boundary.
- Widget tests for onboarding, home, reader shell, ayah menu, khatma creation, bookmarks, settings, and search empty/results states.
- Accessibility tests using Flutter guideline matchers for tap target size, labels, and contrast.
