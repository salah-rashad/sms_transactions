# Implementation Plan: SMS Pattern Authoring & Unmatched SMS Triage

**Branch**: `001-sms-pattern-authoring` | **Date**: 2026-06-21 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/001-sms-pattern-authoring/spec.md`

## Summary

Enable users to teach the app how to parse SMS from previously-unknown senders through a guided, no-regex wizard (tap numeric chips to mark amount/balance, pick direction, optionally tap counterparty), surface unrecognized SMS via a dashboard card and a Settings → SMS Sources management screen, and automatically apply learned patterns to all future and historical messages on-device.

Technical approach: introduce a pure-Dart tokenizer and anchor-based pattern matcher in the domain layer as the **sole** parser — the hardcoded `SmsParser` is removed and the app becomes fully dynamic (FR-035, research R8 pass 3). Persist learned patterns + match results + unmatched markers + suppressed senders in the existing Drift database (schema v2), make the persisted matches the entire ledger, orchestrate the inbox scan/match off the main isolate, refactor `Transaction.source` from the `AccountSource` enum to a sender string, and expose the workflow through three new BLoC cubits and GoRouter routes.

## Technical Context

**Language/Version**: Dart SDK ^3.12.2, Flutter (stable channel)

**Primary Dependencies**: flutter_bloc 9.1, drift 2.34, get_it 9.2, go_router 17.3, flutter_sms_inbox 1.0.5, permission_handler 12.0, intl 0.20 (all already in pubspec — no new dependencies required)

**Storage**: Drift over SQLite (single `AppDatabase` instance via GetIt). New tables: `SmsPatterns`, `PatternMatches`, `UnmatchedSmsRecords`, `SuppressedSenders`. Schema bumped 1 → 2 with an additive migration.

**Testing**: flutter_test (unit tests for tokenizer + matcher under `test/domain/sms/`, Arrange-Act-Assert). Tests encouraged, not gate-blocking (Constitution Development Workflow).

**Target Platform**: Android (primary). SMS inbox read only.

**Project Type**: Single Flutter mobile application (layered: data / domain / presentation).

**Performance Goals**: Scan + match 10,000+ historical SMS with no visible UI jank (SC-007); dashboard card visible within 1s of launch (SC-005); first-time pattern authoring completable in under 60s (SC-001).

**Constraints**: Fully offline / on-device (Constitution I) — zero network calls. Heavy scan/match work MUST run off the main isolate. No raw SMS bodies persisted to the database (privacy); bodies are held transiently in memory only during a session.

**Scale/Scope**: Typically <50 learned patterns; PatternMatch/Transaction rows grow linearly with SMS volume but are lightweight (no body stored). 5 user stories, ~34 functional requirements, 4 new entities, 3 new cubits, ~3 new routes.

## Constitution Check

*GATE: evaluated against Constitution v1.0.0. Must pass before Phase 0 and re-checked after Phase 1.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Offline-First & On-Device Privacy | ✅ PASS | No network calls. Patterns, matches, unmatched markers, suppressions all in local Drift. Raw SMS bodies NEVER persisted — only inbox message ID references + extracted values; bodies held in-memory transiently for the active session. |
| II. BLoC-Driven State Management | ✅ PASS | Three new cubits (`UnmatchedCubit`, `PatternAuthoringCubit`, `SmsSourcesCubit`) with immutable states + `copyWith`. No `setState` for feature logic (the existing dashboard `setState` for a local view toggle is untouched). |
| III. Layered Architecture | ✅ PASS | Tokenizer + matcher are pure domain logic (no data deps). Plain domain models map to Drift rows inside repositories (mirrors existing `Transaction` vs `PoolContributionRow` convention). Presentation accesses data only via repositories/services injected through GetIt. |
| IV. Intelligence Through Learning | ⚠️ PASS (with documented reinterpretation) | Pass-3 decision (FR-035) **removes** the hardcoded `SmsParser`; the learned-pattern engine becomes the sole, fully-dynamic parser. Principle IV says rule-based parsing "is not replaced but augmented." Interpreted at the level of *approach*, it holds: the pattern engine **is** the deterministic rule-based tier (anchor/regex rules) that sits beneath any future embedding/similarity layer — what changed is rule *authorship* (developer → user), not the existence of a rule-based fallback. No silent dilution: this reinterpretation is recorded here and in research R8. If the project owner considers this a true departure from Principle IV, it warrants a separate constitution amendment; functionally the app still "evolves toward learning with rules as the deterministic base." |
| V. Simplicity & YAGNI | ✅ PASS | No new dependencies. Multi-step wizard is ONE route driven by cubit state (not sub-routes) to satisfy back-preserves-state (FR-013) simply. Hardcoded parsers are NOT migrated (YAGNI). The one notable addition — a persisted match/ledger store — is required by the clarified spec and is minimal. See Complexity Tracking. |

**Result**: PASS — no unjustified violations. Proceed to Phase 0.

### Post-analysis revisions (after `/speckit-analyze`, re-checked 2026-06-21)

`/speckit-analyze` surfaced four cross-artifact findings; the design was revised to resolve them. Constitution re-check after these revisions: still **PASS** (R8 strengthens Principle IV by consulting the legacy parser first).

| Finding | Severity | Resolution | Where |
|---------|----------|------------|-------|
| I1 — scan ignored the legacy `SmsParser`, risking duplicate transactions + queuing already-handled senders | HIGH | **Closed by the pass-3 pivot**: the hardcoded `SmsParser` is removed entirely (FR-035), so there is no legacy path to reconcile and no duplicate risk — the pattern engine is the only parser. See R8 (revised) below. | research.md R8, data-model.md, contracts/repositories.contract.md |
| I2 — SC-005 (card <1s) vs FR-024 (card after scan) conflict on large inboxes | MEDIUM | **R9**: card renders the cached persisted-queue count instantly, then refreshes after the background scan. | research.md R9, data-model.md, contracts/cubits.contract.md |
| I3 — `balanceCheck` "not a ledger entry" vs PatternMatch 1:1 Transaction | MEDIUM | `balanceCheck` still maps 1:1 to a balance-snapshot Transaction (as the existing app does); "not a ledger entry" = excluded from income/expense aggregation. | data-model.md (PatternMatch) |
| U1 — edit-pattern path needed the authoring cubit/screen to accept an existing pattern | MEDIUM | `PatternAuthoringCubit` takes an optional `SmsPattern` (edit mode): pre-loads `exampleBody` + selections, preserves match counters on save. | contracts/cubits.contract.md |

### Pass-3 revision — fully dynamic parsing (2026-06-21)

Per an explicit project-owner directive, the hardcoded `SmsParser` and the `AccountSource` enum's parsing role are **removed**; the app parses solely via user-authored patterns (FR-035). This supersedes the earlier R8 legacy-reconciliation approach and closes analyze finding I1 by elimination. Notable existing-code changes: delete `sms_parser.dart`, refactor `Transaction.source` to a sender string, update analytics and `TransactionCubit` to load the ledger from `PatternMatchRepository`, and replace `SmsService.getFinancialSms` with `getCandidateSms`. Constitution Principle IV is preserved by reinterpretation (see Constitution Check, row IV).

> **tasks.md impact**: `tasks.md` predates the pass-3 pivot. Re-run `/speckit-tasks` (or manually amend) to: remove the hardcoded `SmsParser` and `AccountSource` parsing role; refactor `Transaction.source` to a sender string + update analytics/widgets; load the ledger entirely from `PatternMatchRepository` (drop the hybrid union in T036–T038); add `UnmatchedCubit.loadCachedCount()` (R9); add edit-mode inputs on T028/T033 (U1); and add a `balanceCheck` aggregation note (I3).

## Project Structure

### Documentation (this feature)

```text
specs/001-sms-pattern-authoring/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output (Dart interface contracts)
│   ├── tokenizer.contract.md
│   ├── pattern-matcher.contract.md
│   ├── repositories.contract.md
│   └── cubits.contract.md
├── checklists/
│   ├── requirements.md  # from /speckit-specify + /speckit-clarify
│   └── data-model.md    # from /speckit-checklist (45/45 passing)
└── tasks.md             # Phase 2 output (/speckit-tasks — NOT created here)
```

### Source Code (repository root)

```text
lib/
├── domain/
│   ├── models/
│   │   ├── sms_pattern.dart          # NEW: plain model + FieldLocator, SmsDirection enum
│   │   ├── unmatched_sms.dart        # NEW: plain model (id, sender, ts, dismissed); body transient
│   │   ├── pattern_match.dart        # NEW: plain model (extracted values)
│   │   └── sms_token.dart            # NEW: NumericToken / TextToken value objects
│   └── sms/
│       ├── sms_tokenizer.dart        # NEW: pure body→tokens (FR-026..030)
│       └── pattern_matcher.dart      # NEW: pure (pattern, body)→PatternMatch? (FR-031..034, FR-025)
├── data/
│   ├── database/
│   │   └── app_database.dart         # EDIT: +4 tables, schemaVersion 2, additive migration
│   ├── repositories/
│   │   ├── pattern_repository.dart            # NEW
│   │   ├── unmatched_sms_repository.dart       # NEW
│   │   └── suppressed_sender_repository.dart   # NEW
│   └── services/
│       ├── sms_parser.dart           # DELETE: hardcoded per-sender parser removed (R8 pass 3, FR-035)
│       ├── sms_service.dart          # EDIT: getFinancialSms → getCandidateSms() (alphanumeric senders)
│       └── sms_scan_service.dart     # NEW: learned-pattern-only scan/match off main isolate (R8)
├── features/
│   ├── dashboard/
│   │   └── widgets/unmatched_card.dart         # NEW (FR-001..004)
│   ├── unmatched/                              # NEW feature (US1, US3)
│   │   ├── unmatched_screen.dart
│   │   ├── cubit/unmatched_cubit.dart
│   │   ├── cubit/unmatched_state.dart
│   │   └── widgets/unmatched_sender_group.dart
│   ├── pattern_authoring/                      # NEW feature (US2)
│   │   ├── pattern_authoring_screen.dart       # single route, cubit-driven stepper
│   │   ├── cubit/pattern_authoring_cubit.dart
│   │   ├── cubit/pattern_authoring_state.dart
│   │   └── widgets/{token_chip.dart, step_amount.dart, step_balance.dart,
│   │                step_direction.dart, step_counterparty.dart, authoring_summary.dart}
│   └── settings/
│       ├── settings_screen.dart                # EDIT: add "SMS Sources" entry
│       ├── sms_sources_screen.dart             # NEW (US4)
│       └── cubit/{sms_sources_cubit.dart, sms_sources_state.dart}  # NEW
├── domain/models/transaction.dart    # EDIT: source: AccountSource enum → sender String (R8 pass 3)
├── domain/analytics/*.dart           # EDIT: drop AccountSource usage; key by sender string
├── data/services/sms_parser.dart     # DELETE (listed above)
├── features/transactions/cubit/transaction_cubit.dart  # EDIT: load ledger from PatternMatchRepository, drop SmsParser
├── di/injection.dart                 # EDIT: register new repos + scan service
└── router/app_router.dart            # EDIT: + /unmatched, /unmatched/teach, /settings/sms-sources

test/
└── domain/sms/
    ├── sms_tokenizer_test.dart       # NEW
    └── pattern_matcher_test.dart     # NEW
```

**Structure Decision**: Single-project layered Flutter app — the established structure. New pure logic (tokenizer, matcher) lives in `lib/domain/sms/`; persistence in `lib/data/`; UI + cubits in `lib/features/<feature>/` each owning its `cubit/` directory per Constitution II. This mirrors the existing `money_pool` and `transactions` features exactly.

## Complexity Tracking

> Only the one item below is a notable addition beyond the simplest possible approach; it is required by an explicit (clarified) spec decision, so it is documented rather than rejected.

| Addition | Why Needed | Simpler Alternative Rejected Because |
|----------|------------|--------------------------------------|
| Persisted `PatternMatches` store as the **entire** ledger (materialized learned-pattern results) | Spec clarifications require parsed transactions to **persist** after a pattern is edited or deleted (FR-022) and re-scan to detect already-parsed SMS (FR-023). With pass-3 (FR-035) removing all hardcoded parsing, the persisted matches are now the sole source of transactions. | Keeping transactions ephemeral was rejected (deleting a pattern would erase history, contradicting FR-022). The hybrid "ephemeral hardcoded ∪ persisted learned" was rejected by the project owner's fully-dynamic directive. The store stays minimal (lightweight rows keyed by inbox message ID; no SMS bodies). |
| Removal of hardcoded `SmsParser` + `AccountSource` parsing role (existing-code refactor) | Project-owner directive (FR-035): no built-in sender knowledge; everything is taught. Removes per-sender code branches and the fixed account enumeration. | Keeping the hardcoded parser as a fallback (prior R8) was explicitly rejected by the owner. Dynamic discovery via sender string is required for an arbitrary number of senders. |
