<!--
Sync Impact Report
Version change: template -> 1.0.0
Modified principles:
- PRINCIPLE_1_NAME placeholder -> I. Quran Library Is the Quran Platform
- PRINCIPLE_2_NAME placeholder -> II. Clean Flutter Architecture
- PRINCIPLE_3_NAME placeholder -> III. Context7-First Dependency Research
- PRINCIPLE_4_NAME placeholder -> IV. Testable Interactive Experience
- PRINCIPLE_5_NAME placeholder -> V. Professional Quality Gates
Added sections:
- Quran Application Constraints
- Development Workflow
Removed sections:
- None
Templates requiring updates:
- [updated] .specify/templates/plan-template.md
- [updated] .specify/templates/spec-template.md
- [updated] .specify/templates/tasks-template.md
- [not present] .specify/templates/commands/*.md
- [updated] README.md
Follow-up TODOs:
- None
-->
# Tebyan App Constitution

## Core Principles

### I. Quran Library Is the Quran Platform

All Quran-specific rendering, navigation, verse/page metadata, recitation audio,
tafsir, translations, search, bookmarks, and related Quran behavior MUST use
`quran_library: 4.0.1` as the source of truth. The application MUST NOT create a
parallel Quran data model, bundled Quran text, custom mushaf renderer, duplicate
audio catalog, or independent Quran search/indexing layer unless a documented
library limitation is proven during research and approved in the implementation
plan.

Rationale: the application's value is the interactive experience around the
Quran, while the canonical Quran domain capabilities belong to the dedicated
library.

### II. Clean Flutter Architecture

Features MUST be organized into presentation, application/state, domain
interface, and infrastructure/adaptor boundaries appropriate for Flutter.
Widgets MUST stay focused on rendering and interaction. State, navigation
decisions, persistence, and quran_library integration MUST live behind testable
view models, controllers, services, or repositories. Cross-feature code MUST be
introduced only when at least two real features need it or when it protects a
constitution rule.

Rationale: clean boundaries keep the interactive UI changeable without
duplicating Quran behavior or burying decisions in widgets.

### III. Context7-First Dependency Research

Every feature plan that adds or changes libraries, platform APIs, architecture
patterns, or quran_library usage MUST query Context7 first and record the result
in `research.md` or the plan. If Context7 cannot resolve the package, version,
or API guidance, the plan MUST use an authoritative web source such as official
documentation, pub.dev, or the upstream repository and cite that fallback.
Dependencies MUST use the latest compatible stable version unless this
constitution pins a version, an existing lockfile constrains it, or the plan
documents a compatibility reason.

Rationale: library behavior changes quickly; implementation decisions must be
based on current primary documentation rather than memory.

### IV. Testable Interactive Experience

Each user-visible feature MUST include focused tests for its state logic,
quran_library adaptor behavior, and critical widget flows. Tests that cover a
bug fix or a new contract MUST be written before or with the implementation and
MUST fail against the old behavior when practical. Manual verification MUST be
documented for platform behavior that automated Flutter tests cannot exercise.

Rationale: Quran navigation, reading state, playback, and bookmarks are
interactive workflows where regressions are user-facing and hard to detect by
inspection alone.

### V. Professional Quality Gates

No implementation is complete until formatting, static analysis, tests, and the
feature quickstart or equivalent manual verification pass. New code MUST avoid
unused abstractions, global mutable state, hardcoded Quran content, unhandled
async errors, and UI states that block reading, navigation, playback, or
accessibility. Any exception MUST be listed in the plan's Complexity Tracking
table with a bounded mitigation.

Rationale: professional delivery requires repeatable quality checks and visible
tradeoffs, not only working happy paths.

## Quran Application Constraints

- `pubspec.yaml` MUST declare `quran_library: 4.0.1` for Quran features unless
  the constitution is amended.
- App startup that depends on Quran functionality MUST initialize quran_library
  before exposing Quran screens.
- Quran screens SHOULD compose library widgets and APIs through local adaptors
  when doing so improves testability or isolates library-specific types.
- The app MUST preserve Islamic text integrity: no generated Quran text, no
  manual verse normalization, and no display transformations that can change
  Quran wording or ordering.
- Offline behavior, audio caching, translations, tafsir, search, and bookmarks
  MUST use quran_library capabilities before considering custom code.
- Platform support decisions MUST be explicit in the plan for Android, iOS, web,
  desktop, and any platform excluded from a feature.

## Development Workflow

1. Start each feature with a spec that names the Quran workflow, platform scope,
   success criteria, and any quran_library capability it depends on.
2. During planning, run Context7 research for quran_library and any added
   dependency, then record source, version, decision, and fallback if used.
3. Define the architecture boundary before implementation: presentation, state,
   application services, quran_library adaptors, persistence, and tests.
4. Generate tasks that include dependency checks, initialization, adaptor work,
   state tests, widget tests, static analysis, and quickstart validation.
5. Review every change against this constitution before merge. Constitution
   conflicts block the change until the implementation or constitution is
   amended.

## Governance

This constitution supersedes conflicting project practices, templates, and
informal instructions. Feature specs, plans, tasks, reviews, and implementation
work MUST comply with these principles.

Amendments require a written change to this file, a Sync Impact Report, an
explicit semantic version bump, and updates to dependent templates or runtime
guidance in the same change. A plan may request an amendment, but it MUST NOT
ignore the active constitution while waiting for that amendment.

Versioning policy:
- MAJOR: removes or redefines a core principle or changes the required Quran
  library platform boundary.
- MINOR: adds a principle, mandatory section, quality gate, or materially
  expands existing governance.
- PATCH: clarifies wording, fixes errors, or updates non-semantic guidance.

Compliance review expectations:
- `/speckit.plan` MUST fill Constitution Check with evidence for all principles.
- `/speckit.tasks` MUST include tasks that make the quality gates executable.
- Code review MUST treat constitution violations as blocking defects.
- Release readiness MUST include passing Flutter analysis, tests, and documented
  manual verification for unsupported automated checks.

**Version**: 1.0.0 | **Ratified**: 2026-04-25 | **Last Amended**: 2026-04-25
