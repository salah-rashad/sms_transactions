---
description: "Task list for SMS Pattern Authoring & Unmatched SMS Triage"
---

# Tasks: SMS Pattern Authoring & Unmatched SMS Triage

**Input**: Design documents from `specs/001-sms-pattern-authoring/`

**Prerequisites**: plan.md, spec.md, research.md (incl. pass-3), data-model.md, contracts/

**Tests**: Only the two pure-logic suites named in plan.md/quickstart.md (tokenizer, matcher) are included. No broader test suite is generated (tests optional per spec).

**Organization**: Tasks grouped by user story. Priority order: US1, US2, US5 (all P1), then US3, US4 (P2).

**Pass-3 note**: This feature is **fully dynamic** — the hardcoded `SmsParser` and the `AccountSource` enum's parsing role are removed (FR-035); the learned-pattern engine is the sole parser and the persisted `PatternMatches` table is the entire ledger. The legacy-parser refactor lands in US5 (so the app is never left without a working ledger path mid-stream).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on incomplete tasks)
- **[Story]**: US1–US5 for story-phase tasks; setup/foundational/polish carry no story label

## Path Conventions

Single-project layered Flutter app. Paths are repo-relative, matching [plan.md](plan.md).

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Prepare directories and confirm codegen tooling for the Drift schema bump.

- [x] T001 Confirm `drift_dev` and `build_runner` are present under `dev_dependencies` in `pubspec.yaml` (needed to regenerate `app_database.g.dart` for schema v2); add if missing and run `flutter pub get`.
- [x] T002 [P] Create the new source/test directories: `lib/domain/sms/`, `lib/features/unmatched/cubit/`, `lib/features/unmatched/widgets/`, `lib/features/pattern_authoring/cubit/`, `lib/features/pattern_authoring/widgets/`, `lib/features/settings/cubit/`, `test/domain/sms/`.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: The shared SMS engine (models, tokenizer, matcher, persistence, scan, DI). Every user story depends on this. (The legacy-parser removal is deferred to US5 — see the pass-3 note.)

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

### Domain models (plain Dart)

- [x] T003 [P] Create `SmsToken` value objects (`NumericToken`, `TextToken`) in `lib/domain/models/sms_token.dart` per [data-model.md](data-model.md).
- [x] T004 [P] Create `SmsPattern`, `FieldLocator`, and `SmsDirection` enum in `lib/domain/models/sms_pattern.dart`.
- [x] T005 [P] Create `UnmatchedSms` (with transient `body`) and `SuppressedSender` in `lib/domain/models/unmatched_sms.dart`.
- [x] T006 [P] Create `PatternMatch` (extracted values, `smsId` key, `senderId`) in `lib/domain/models/pattern_match.dart`.

### Pure engine (domain) + its unit tests

- [x] T007 Implement `SmsTokenizer` (Latin + Arabic-Indic digits, separators, mixed LTR/RTL, non-transactional heuristic) in `lib/domain/sms/sms_tokenizer.dart` per [contracts/tokenizer.contract.md](contracts/tokenizer.contract.md) (depends on T003).
- [x] T008 [P] Write `SmsTokenizer` unit tests in `test/domain/sms/sms_tokenizer_test.dart` covering the contract's behavioral table (depends on T007).
- [x] T009 Implement `PatternMatcher` (`derivePattern`, `match`, `matchAny` with `\s+` tolerance and createdAt ordering) in `lib/domain/sms/pattern_matcher.dart` per [contracts/pattern-matcher.contract.md](contracts/pattern-matcher.contract.md) (depends on T004, T006, T007).
- [x] T010 [P] Write `PatternMatcher` unit tests in `test/domain/sms/pattern_matcher_test.dart`, including the derive→match round-trip on the example body (depends on T009).

### Persistence (Drift schema v2)

- [x] T011 Add `SmsPatterns`, `PatternMatches`, `UnmatchedSmsRecords`, `SuppressedSenders` tables, bump `schemaVersion` to 2, and add an additive `onUpgrade` migration in `lib/data/database/app_database.dart` per [data-model.md](data-model.md) (depends on T004–T006).
- [x] T012 Regenerate Drift code: run `dart run build_runner build --delete-conflicting-outputs` to update `lib/data/database/app_database.g.dart` (depends on T011).

### Repositories (data ↔ domain mapping)

- [x] T013 [P] Implement `PatternRepository` and `PatternMatchRepository` in `lib/data/repositories/pattern_repository.dart` per [contracts/repositories.contract.md](contracts/repositories.contract.md) — includes `recordAttempt`, `getBySmsId`, `getAll`, `countForSender`, `nullifyPatternRef` (depends on T012).
- [x] T014 [P] Implement `UnmatchedSmsRepository` in `lib/data/repositories/unmatched_sms_repository.dart` (`getActive`, `activeCount`, `upsertAll`, `removeBySmsId`, `removeBySender`, `pruneMissing`) (depends on T012).
- [x] T015 [P] Implement `SuppressedSenderRepository` in `lib/data/repositories/suppressed_sender_repository.dart` (`getAll`, `suppress`, `unsuppress`) (depends on T012).

### Scan orchestration (learned-pattern only)

- [x] T016 Replace `getFinancialSms()` with `getCandidateSms()` in `lib/data/services/sms_service.dart` — returns alphanumeric-sender SMS plus already-patterned senders (research R2); no hardcoded address list.
- [x] T017 Implement `SmsScanService.scan({overwrite})` in `lib/data/services/sms_scan_service.dart` — runs tokenize+`matchAny` in a `compute()` isolate, persists new `PatternMatches` (idempotent on `smsId`), upserts `UnmatchedSmsRecords` when no learned pattern matches and the sender is alphanumeric + not suppressed (no hardcoded-parser exception — FR-035, R8), prunes orphans, returns `ScanResult` with conflicts (research R3/R8; depends on T009, T013, T014, T015, T016).
- [x] T018 Register `PatternRepository`, `PatternMatchRepository`, `UnmatchedSmsRepository`, `SuppressedSenderRepository`, and `SmsScanService` as lazy singletons in `lib/di/injection.dart` (depends on T013–T017).

**Checkpoint**: Engine ready — user stories can begin.

---

## Phase 3: User Story 1 - Review Unmatched SMS from Dashboard (Priority: P1) 🎯 MVP

**Goal**: Surface unmatched SMS via an auto-appearing dashboard card and a grouped review list.

**Independent Test**: Seed an unmatched alphanumeric sender; launch app → card shows correct count within ~1s (cached); tap Review → grouped list appears; empty queue → no card (FR-001–007, SC-005).

- [x] T019 [P] [US1] Create `UnmatchedState` (items grouped by sender, count, status) in `lib/features/unmatched/cubit/unmatched_state.dart`.
- [x] T020 [US1] Implement `UnmatchedCubit` with `loadCachedCount()` (instant persisted `activeCount` for SC-005, research R9), `runLaunchScan()`, `refresh()`, `dismissSender()` in `lib/features/unmatched/cubit/unmatched_cubit.dart`, delegating to `SmsScanService` + repositories (depends on T019, T017, T014, T015).
- [x] T021 [P] [US1] Create `UnmatchedSenderGroup` list widget (sender header, message preview, timestamp, Teach/Dismiss actions) in `lib/features/unmatched/widgets/unmatched_sender_group.dart` (FR-005–007).
- [x] T022 [US1] Build `UnmatchedScreen` (lazy grouped list) in `lib/features/unmatched/unmatched_screen.dart` (depends on T020, T021).
- [x] T023 [P] [US1] Create `UnmatchedCard` (count + Review CTA, hidden when count==0) in `lib/features/dashboard/widgets/unmatched_card.dart` (FR-001–004).
- [x] T024 [US1] Insert `UnmatchedCard` at top of the dashboard list in `lib/features/dashboard/dashboard_screen.dart`, watching `UnmatchedCubit` (depends on T023, T020).
- [x] T025 [US1] Provide `UnmatchedCubit` app-scoped in `lib/app.dart`; on start call `loadCachedCount()` then `runLaunchScan()` (research R7/R9; depends on T020).
- [x] T026 [US1] Add `/unmatched` route (Review destination) in `lib/router/app_router.dart` and wire the card's Review CTA via `context.push` (depends on T022).

**Checkpoint**: US1 functions independently — dashboard card + review list driven by the launch scan.

---

## Phase 4: User Story 2 - Teach the App a New SMS Pattern (Priority: P1)

**Goal**: Guided 4-step wizard turning one unmatched SMS into a saved pattern + an immediate transaction.

**Independent Test**: From the list, Teach one SMS → amount chip → balance/skip → direction → counterparty/skip → summary → Save; a pattern persists, a transaction (dated to the SMS) appears, and you return to the list (FR-008–016, <60s).

- [ ] T027 [P] [US2] Create `PatternAuthoringState` (tokens, stepIndex, selections, `editing` pattern ref, preview) in `lib/features/pattern_authoring/cubit/pattern_authoring_state.dart` per [contracts/cubits.contract.md](contracts/cubits.contract.md).
- [ ] T028 [US2] Implement `PatternAuthoringCubit` accepting the SMS body **and an optional existing `SmsPattern` for edit mode** (FR-021, U1): `selectAmount/Balance/Direction/Counterparty`, `back`, `save`; uses `SmsTokenizer` + `PatternMatcher`; edit mode pre-selects from existing locators and preserves counters. In `lib/features/pattern_authoring/cubit/pattern_authoring_cubit.dart` (depends on T027, T009, T013).
- [ ] T029 [P] [US2] Create `TokenChip` widget (tappable, de-emphasis for likely-non-transactional, RTL-aware) in `lib/features/pattern_authoring/widgets/token_chip.dart` (FR-008, FR-030).
- [ ] T030 [P] [US2] Create `StepAmount` and `StepBalance` widgets in `lib/features/pattern_authoring/widgets/step_amount.dart` and `step_balance.dart` (FR-009, FR-010).
- [ ] T031 [P] [US2] Create `StepDirection` and `StepCounterparty` widgets in `lib/features/pattern_authoring/widgets/step_direction.dart` and `step_counterparty.dart` (FR-011, FR-012).
- [ ] T032 [P] [US2] Create `AuthoringSummary` widget (live preview with labeled extracted values) in `lib/features/pattern_authoring/widgets/authoring_summary.dart` (FR-014).
- [ ] T033 [US2] Build `PatternAuthoringScreen` (step counter, Back preserving later selections, cubit-driven stepper; accepts create- or edit-mode input via route `extra`) in `lib/features/pattern_authoring/pattern_authoring_screen.dart` (FR-013, U1; depends on T028, T029–T032).
- [ ] T034 [US2] Add `/unmatched/teach` route (carrying the selected `UnmatchedSms`, and optional `SmsPattern` for edit) in `lib/router/app_router.dart` and wire the list's Teach action to it (depends on T033, T022).
- [ ] T035 [US2] Implement `save()`: derive+persist the `SmsPattern` (or update in edit mode), parse the example into a `PatternMatch` (transaction dated to received timestamp), refresh `UnmatchedCubit`, and pop back to the list (FR-015; depends on T028, T020).

**Checkpoint**: US1 + US2 work — users can teach a sender and see the transaction appear.

---

## Phase 5: User Story 5 - Pattern Applies to Future Messages Automatically (Priority: P1)

**Goal**: Saved patterns auto-parse future/historical SMS into the ledger with no prompt; non-matches route to the queue. **This phase also performs the fully-dynamic refactor** (remove hardcoded parser, make the persisted matches the sole ledger).

**Independent Test**: Seed a saved pattern; relaunch → a transaction appears with no user action (SC-002); a format-changed SMS lands in the queue (FR-025); previously hardcoded senders (BanK-AlAhly/VF-Cash) appear in the queue until taught (FR-035).

- [ ] T036 [P] [US5] Refactor `Transaction.source` from the `AccountSource` enum to a sender-identifier `String` (and remove the enum's parsing role) in `lib/domain/models/transaction.dart` (research R8 pass 3, data-model.md).
- [ ] T037 [US5] Update analytics and transaction widgets that reference `AccountSource` to key by the sender string: `lib/domain/analytics/account_calculator.dart`, `lib/domain/analytics/monthly_breakdown.dart`, `lib/domain/analytics/salary_cycle_breakdown.dart`, `lib/features/transactions/widgets/transaction_card.dart` (keep `balanceCheck` excluded from income/expense sums, I3) (depends on T036).
- [ ] T038 [P] [US5] Add a `PatternMatch → Transaction` mapper (`source` = `senderId`, date = `receivedAt`) in `lib/domain/models/pattern_match.dart` (depends on T036).
- [ ] T039 [US5] Rewrite `TransactionCubit.loadTransactions()` to build the ledger entirely from `PatternMatchRepository.getAll()` (mapped via T038) and remove all `SmsParser` usage in `lib/features/transactions/cubit/transaction_cubit.dart` (research R1 pass 3; depends on T038, T013).
- [ ] T040 [US5] Delete `lib/data/services/sms_parser.dart` and remove any remaining references to it and to `SmsService.getFinancialSms` (FR-035; depends on T039, T016).
- [ ] T041 [US5] Verify the launch-scan path: known-sender SMS auto-parse into `PatternMatches`, non-matching known-sender SMS create `UnmatchedSmsRecords`, and previously hardcoded senders appear in the queue until taught (FR-024, FR-025, FR-035; depends on T017, T039).

**Checkpoint**: All P1 stories complete — full MVP (teach → auto-parse → review) with no hardcoded parsing.

---

## Phase 6: User Story 3 - Dismiss an Unmatched SMS (Priority: P2)

**Goal**: Mark a sender non-financial; suppress its current and future SMS from the queue.

**Independent Test**: Dismiss an unmatched SMS → it leaves the queue; a new SMS from that sender does not reappear (FR-017); the sender is listed as suppressed in Settings.

- [ ] T042 [US3] Add the Dismiss / "Not a transaction" action to the review UI in `lib/features/unmatched/unmatched_screen.dart` (and/or `unmatched_sender_group.dart`) (depends on T022).
- [ ] T043 [US3] Finalize `UnmatchedCubit.dismissSender` to call `SuppressedSenderRepository.suppress` and `UnmatchedSmsRepository.removeBySender`, then refresh count, in `lib/features/unmatched/cubit/unmatched_cubit.dart` (depends on T020, T015).
- [ ] T044 [US3] Ensure `SmsScanService` excludes suppressed senders when building unmatched records in `lib/data/services/sms_scan_service.dart` (FR-017; depends on T017, T015).

**Checkpoint**: US1–US3 + US5 work independently.

---

## Phase 7: User Story 4 - Manage Known Patterns in Settings (Priority: P2)

**Goal**: View learned senders (with confidence %), edit/delete patterns, re-activate suppressed senders, and re-scan.

**Independent Test**: Settings → SMS Sources lists learned senders w/ confidence; deleting one (after affected-count confirm) keeps its transactions but re-queues its SMS; unsuppress re-queues historical SMS; re-scan prompts before overwriting (FR-018–023).

- [ ] T045 [P] [US4] Create `SmsSourcesState` (learned views w/ confidence %, suppressed list) in `lib/features/settings/cubit/sms_sources_state.dart`.
- [ ] T046 [US4] Implement `SmsSourcesCubit` (`load`, `deletePattern`, `unsuppress`, `rescan`) in `lib/features/settings/cubit/sms_sources_cubit.dart` (depends on T045, T013, T015, T017).
- [ ] T047 [US4] Build `SmsSourcesScreen` (learned list w/ sender, match count, last-matched, confidence %; suppressed list) in `lib/features/settings/sms_sources_screen.dart` (FR-019, FR-020; depends on T046).
- [ ] T048 [US4] Add an "SMS Sources" entry in `lib/features/settings/settings_screen.dart` and a `/settings/sms-sources` route in `lib/router/app_router.dart` (depends on T047).
- [ ] T049 [US4] Implement Delete with affected-count confirmation; on delete, retain `PatternMatches`/transactions and re-queue the sender's SMS into the unmatched queue (FR-022; depends on T046).
- [ ] T050 [US4] Implement Edit entry point: re-open the authoring wizard pre-loaded with the pattern's `exampleBody` and existing selections, preserving match counters (FR-021, U1; depends on T046, T033).
- [ ] T051 [US4] Implement Unsuppress (re-queue historical SMS) and Re-scan with a confirmation dialog for `ScanResult.conflicts` before overwrite (FR-018, FR-023; depends on T046, T017).

**Checkpoint**: All five user stories independently functional.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Validation, localization, performance, and cleanup across stories.

- [ ] T052 [P] Run the 12 manual scenarios in [quickstart.md](quickstart.md) on-device, including the offline check (no network — Constitution I) and the no-duplicate / instant-card scenarios (11, 12).
- [ ] T053 [P] Verify Arabic / mixed LTR-RTL tokenization and chip layout render correctly (SC-006).
- [ ] T054 Profile a 10,000+ SMS inbox scan to confirm no UI jank (matching runs off the main isolate) (SC-007).
- [ ] T055 [P] Replace any `print()` with the project `Logger`, remove dead code, and confirm no presentation layer imports `lib/data/database/` directly (Constitution III, logging).
- [ ] T056 Grep the codebase to confirm no remaining references to `SmsParser` or `AccountSource`'s parsing role; confirm the app builds and runs with the fully-dynamic ledger (FR-035).

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: no dependencies.
- **Foundational (Phase 2)**: depends on Setup — **blocks all user stories**.
- **US1 (Phase 3)**, **US2 (Phase 4)**, **US5 (Phase 5)**: all P1; depend only on Foundational. Implement US1 → US2 → US5 for a coherent MVP; each is independently testable by seeding data. **US5 contains the hardcoded-parser removal** — until US5, the legacy `TransactionCubit`/`SmsParser` path keeps the app running.
- **US3 (Phase 6)**, **US4 (Phase 7)**: P2; depend only on Foundational (US3 touches the US1 list UI; US4's Edit reuses the US2 wizard).
- **Polish (Phase 8)**: after the desired stories are complete.

### Critical Path

`T001 → T011 → T012 → T017 → T018` (engine + persistence + scan + DI), then US5's `T036 → T039 → T040` (the fully-dynamic ledger swap). All story-facing work hangs off T018.

### Within Each Story

- Cubit state before cubit; cubit before screens; widgets [P] alongside.
- Router/screen edits to shared files (`app_router.dart`, `dashboard_screen.dart`, `settings_screen.dart`) are sequential (same file → no [P]).

---

## Parallel Opportunities

```bash
# Foundational domain models (all different files):
T003 sms_token.dart   T004 sms_pattern.dart   T005 unmatched_sms.dart   T006 pattern_match.dart

# Foundational repositories (after T012):
T013 pattern_repository.dart   T014 unmatched_sms_repository.dart   T015 suppressed_sender_repository.dart

# US2 wizard widgets (after T028):
T029 token_chip.dart   T030 step_amount/step_balance   T031 step_direction/step_counterparty   T032 authoring_summary.dart

# Pure-logic tests run independently:
T008 sms_tokenizer_test.dart   T010 pattern_matcher_test.dart
```

---

## Implementation Strategy

### MVP (P1 stories)

1. Phase 1 Setup → Phase 2 Foundational (the spine).
2. Phase 3 US1 → validate the dashboard card + review list.
3. Phase 4 US2 → validate teaching a pattern.
4. Phase 5 US5 → swap to the fully-dynamic ledger and validate auto-parse.
5. **STOP & validate** the full teach→auto-parse→review loop with no hardcoded parsing. Shippable MVP.

### Incremental Delivery

- Add US3 (dismiss/suppress) → validate.
- Add US4 (settings management) → validate.
- Run Phase 8 polish (quickstart, RTL, 10k-perf, cleanup, no-`SmsParser` grep).

---

## Notes

- `[P]` = different files, no incomplete dependency.
- `[Story]` labels (US1–US5) map tasks to spec user stories for traceability.
- The hardcoded-parser removal is intentionally inside US5 so the app always has a working ledger path until the dynamic one replaces it.
- Only two test tasks (T008, T010) — the pure tokenizer/matcher suites named in the plan.
- 56 tasks total.
