# Tebyan App

Tebyan App is an interactive Flutter Quran application governed by the project
constitution in `.specify/memory/constitution.md`.

## Architecture Rules

- Quran-specific rendering, navigation, metadata, audio, tafsir, translations,
  search, and bookmarks rely on `quran_library: 4.0.1`.
- Feature code is organized with clear presentation, state/application,
  domain-interface, infrastructure/adaptor, and test boundaries.
- Dependency and API decisions start with Context7 research. If Context7 cannot
  answer, use official documentation, pub.dev, or the upstream repository.
- New user-visible Quran behavior requires tests for state logic, quran_library
  adaptors, and critical widget flows, plus manual verification where automated
  tests cannot cover a platform behavior.

## Development Checks

Use the standard Flutter checks before treating a change as complete:

```powershell
dart format .
flutter analyze
flutter test
```
