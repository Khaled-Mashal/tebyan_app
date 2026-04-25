---

description: "Task list template for feature implementation"
---

# Tasks: [FEATURE NAME]

**Input**: Design documents from `/specs/[###-feature-name]/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Tests are REQUIRED for user-visible behavior, quran_library adaptors,
state logic, and critical widget flows. Manual verification tasks are REQUIRED
when automated Flutter tests cannot cover platform behavior.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Flutter app**: `lib/features/[feature]/`, `lib/shared/`, `test/features/[feature]/`
- **Quran library adaptors**: `lib/features/[feature]/infrastructure/` or shared adaptor path from plan.md
- **Widget/state tests**: `test/features/[feature]/`
- **Manual/integration evidence**: feature `quickstart.md` or documented verification notes
- **Single project**: `src/`, `tests/` at repository root
- **Web app**: `backend/src/`, `frontend/src/`
- **Mobile**: `api/src/`, `ios/src/` or `android/src/`
- Paths shown below assume single project - adjust based on plan.md structure

<!-- 
  ============================================================================
  IMPORTANT: The tasks below are SAMPLE TASKS for illustration purposes only.
  
  The /speckit.tasks command MUST replace these with actual tasks based on:
  - User stories from spec.md (with their priorities P1, P2, P3...)
  - Feature requirements from plan.md
  - Entities from data-model.md
  - Endpoints from contracts/
  
  Tasks MUST be organized by user story so each story can be:
  - Implemented independently
  - Tested independently
  - Delivered as an MVP increment
  
  DO NOT keep these sample tasks in the generated tasks.md file.
  ============================================================================
-->

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [ ] T001 Create project structure per implementation plan
- [ ] T002 Verify `pubspec.yaml` declares `quran_library: 4.0.1` for Quran features
- [ ] T003 [P] Record Context7 research evidence for quran_library, Flutter architecture, and changed dependencies
- [ ] T004 [P] Configure or verify Flutter linting, formatting, and analysis tools

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

Examples of foundational tasks (adjust based on your project):

- [ ] T005 Initialize quran_library at app startup before Quran screens are available
- [ ] T006 [P] Define quran_library adaptor/service boundary in planned feature path
- [ ] T007 [P] Define state/application boundary for reading, navigation, playback, or bookmarks
- [ ] T008 Configure error handling for async quran_library operations
- [ ] T009 Configure platform-specific permissions/assets required by the feature
- [ ] T010 Add shared test helpers or fakes for quran_library adaptor tests

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - [Title] (Priority: P1) 🎯 MVP

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 1

> **NOTE: Write these tests first when covering a bug fix or new contract. They
> should fail against the old behavior when practical.**

- [ ] T011 [P] [US1] State/application test for [flow] in test/features/[feature]/[name]_test.dart
- [ ] T012 [P] [US1] quran_library adaptor test for [capability] in test/features/[feature]/[name]_test.dart
- [ ] T013 [P] [US1] Widget test for [user journey] in test/features/[feature]/[name]_test.dart

### Implementation for User Story 1

- [ ] T014 [P] [US1] Create presentation widgets in lib/features/[feature]/presentation/
- [ ] T015 [P] [US1] Create state/application logic in lib/features/[feature]/application/
- [ ] T016 [US1] Implement quran_library adaptor usage in lib/features/[feature]/infrastructure/
- [ ] T017 [US1] Integrate feature route/screen without duplicating Quran content
- [ ] T018 [US1] Add validation, loading, empty, and error states
- [ ] T019 [US1] Document manual verification in quickstart.md if platform behavior is not automated

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - [Title] (Priority: P2)

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 2

- [ ] T020 [P] [US2] State/application test for [flow] in test/features/[feature]/[name]_test.dart
- [ ] T021 [P] [US2] Widget or adaptor test for [quran_library capability] in test/features/[feature]/[name]_test.dart

### Implementation for User Story 2

- [ ] T022 [P] [US2] Create or extend presentation widgets in lib/features/[feature]/presentation/
- [ ] T023 [US2] Implement state/application logic in lib/features/[feature]/application/
- [ ] T024 [US2] Integrate quran_library capability through approved adaptor/service boundary
- [ ] T025 [US2] Integrate with User Story 1 components if needed

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - [Title] (Priority: P3)

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 3

- [ ] T026 [P] [US3] State/application test for [flow] in test/features/[feature]/[name]_test.dart
- [ ] T027 [P] [US3] Widget or adaptor test for [quran_library capability] in test/features/[feature]/[name]_test.dart

### Implementation for User Story 3

- [ ] T028 [P] [US3] Create or extend presentation widgets in lib/features/[feature]/presentation/
- [ ] T029 [US3] Implement state/application logic in lib/features/[feature]/application/
- [ ] T030 [US3] Integrate quran_library capability through approved adaptor/service boundary

**Checkpoint**: All user stories should now be independently functional

---

[Add more user story phases as needed, following the same pattern]

---

## Phase N: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] TXXX [P] Documentation updates in docs/
- [ ] TXXX Code cleanup and refactoring
- [ ] TXXX Performance optimization across all stories
- [ ] TXXX [P] Additional Flutter/unit/widget tests for uncovered critical flows
- [ ] TXXX Accessibility and text-integrity review for Quran display states
- [ ] TXXX Run `dart format`, `flutter analyze`, and `flutter test`
- [ ] TXXX Run quickstart.md validation

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2 → P3)
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational (Phase 2) - May integrate with US1 but should be independently testable
- **User Story 3 (P3)**: Can start after Foundational (Phase 2) - May integrate with US1/US2 but should be independently testable

### Within Each User Story

- Required tests MUST cover state logic, quran_library adaptor behavior, and
  critical widget flows
- Tests for bug fixes or new contracts MUST be written first and fail against
  the old behavior when practical
- Models before services
- Services before endpoints
- Core implementation before integration
- Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel (within Phase 2)
- Once Foundational phase completes, all user stories can start in parallel (if team capacity allows)
- All tests for a user story marked [P] can run in parallel
- Models within a story marked [P] can run in parallel
- Different user stories can be worked on in parallel by different team members

---

## Parallel Example: User Story 1

```bash
# Launch all tests for User Story 1 together (if tests requested):
Task: "Contract test for [endpoint] in tests/contract/test_[name].py"
Task: "Integration test for [user journey] in tests/integration/test_[name].py"

# Launch all models for User Story 1 together:
Task: "Create [Entity1] model in src/models/[entity1].py"
Task: "Create [Entity2] model in src/models/[entity2].py"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Test User Story 1 independently
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → Deploy/Demo (MVP!)
3. Add User Story 2 → Test independently → Deploy/Demo
4. Add User Story 3 → Test independently → Deploy/Demo
5. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1
   - Developer B: User Story 2
   - Developer C: User Story 3
3. Stories complete and integrate independently

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Verify tests fail before implementing
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence
