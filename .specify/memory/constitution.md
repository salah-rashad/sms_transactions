<!--
  SYNC IMPACT REPORT
  ==================
  Version change: 1.0.0 -> 2.0.0
  Bump rationale: MAJOR — Principle IV redefinition. The normative clause
    "Rule-based parsing remains the fallback; it is not replaced but augmented
    by learned patterns" is inverted to mandate fully-dynamic, user-authored
    parsing with NO developer-hardcoded per-sender parsers. This is
    backward-incompatible: a design relying on the old hardcoded fallback is
    now non-compliant. Driven by feature 001-sms-pattern-authoring (FR-035).
  Modified principles:
    - IV. Intelligence Through Learning (clause redefined; title unchanged)
  Added sections: None
  Removed sections: None
  Templates requiring updates:
    - plan-template.md: ✅ aligned (Constitution Check section is generic)
    - spec-template.md: ✅ aligned (no principle-specific mandatory sections)
    - tasks-template.md: ✅ aligned (phased delivery unaffected)
  Dependent artifacts requiring manual follow-up:
    - specs/001-sms-pattern-authoring/plan.md: ⚠ update Constitution Check row IV
      (now compliant — remove "reinterpretation" caveat) and the stale
      "consulting the legacy parser first" line.
    - specs/001-sms-pattern-authoring/research.md: ⚠ R8 Constitution IV note now
      reflects the amended principle (no longer a reinterpretation).
  Follow-up TODOs: None
-->

# SMS Transactions Constitution

## Core Principles

### I. Offline-First & On-Device Privacy

All data processing, storage, and inference MUST remain on-device.
Financial SMS data MUST never leave the device or be transmitted
to external services. No network calls are permitted for core
functionality (transaction parsing, analytics, learning).

- SMS content, parsed transactions, embeddings, and user
  confirmations MUST be stored exclusively in local SQLite
  (via Drift) or local file storage.
- Any future cloud feature MUST be opt-in and MUST NOT gate
  core functionality behind network availability.

**Rationale**: Users trust the app with sensitive financial data.
On-device processing is a non-negotiable privacy guarantee.

### II. BLoC-Driven State Management

All feature state MUST use the BLoC/Cubit pattern with immutable
state classes and `copyWith` semantics.

- HydratedBloc/HydratedCubit MUST be used for state that
  persists across app sessions (e.g., theme preference).
- No ad-hoc state management (setState, ChangeNotifier,
  ValueNotifier) is permitted in feature code.
- Each feature MUST encapsulate its cubit within its own
  feature directory under `lib/features/<feature>/cubit/`.
- BLoC observation via `AppBlocObserver` MUST remain active
  for diagnostics.

**Rationale**: BLoC provides predictable, testable state
transitions and clear separation of business logic from UI.

### III. Layered Architecture

The codebase MUST maintain strict separation into three layers:

- **Data** (`lib/data/`): Repositories, services, database
  definitions. Owns persistence and external data access (SMS).
- **Domain** (`lib/domain/`): Models, analytics, business rules.
  MUST NOT depend on data-layer implementations or presentation.
- **Presentation** (`lib/features/`, `lib/shared/`): Screens,
  widgets, cubits. MUST access data only through repositories
  or services injected via GetIt.

Cross-layer import violations:
- Presentation MUST NOT import `lib/data/database/` directly.
- Domain MUST NOT import presentation or data implementation.
- Shared widgets MUST NOT depend on feature-specific cubits.

**Rationale**: Layered architecture enables independent testing,
replacement of data sources, and clear ownership boundaries.

### IV. Intelligence Through Learning

The system MUST evolve from deterministic pattern matching toward
embedding-based similarity search and user-driven learning.

- Show intelligence before asking for user input.
- Reduce required user interaction over time as the knowledge
  base grows.
- Ask for confirmation only on low-confidence classifications.
- User corrections MUST feed back into the learning layer
  (merchant profiles, similarity clusters, pattern confidence).
- Parsing MUST be fully dynamic and user-authored: the app MUST
  NOT ship developer-hardcoded, per-sender parsers. User-taught
  deterministic patterns (anchor/regex rules) ARE the rule-based
  base layer and serve as the deterministic fallback beneath any
  future embedding/similarity learning. New senders are learned
  through user teaching, never pre-coded.

**Rationale**: The app's long-term value is proportional to its
ability to classify transactions autonomously across an open,
unbounded set of senders. Hardcoded per-sender parsers do not
scale and create maintenance debt; a user-authored deterministic
pattern layer beneath the learning layer is both extensible and
the path to autonomy.

### V. Simplicity & YAGNI

Implement the minimum complexity needed for the current task.

- Avoid premature abstractions, unnecessary design patterns,
  and speculative features.
- Three similar lines of code are preferable to a premature
  helper function.
- Every architectural addition MUST justify its complexity
  against a simpler alternative.
- No feature flags or backward-compatibility shims when
  direct code changes suffice.

**Rationale**: Complexity is the primary long-term cost in a
solo-maintained project. Simplicity preserves velocity.

## Technology Stack & Constraints

- **Language**: Dart (SDK ^3.12.2) with Flutter framework
- **State Management**: flutter_bloc / hydrated_bloc
- **Navigation**: GoRouter (declarative, index-based shell)
- **Database**: Drift ORM over SQLite
  (sqlite3_flutter_libs)
- **Dependency Injection**: GetIt (lazy singletons)
- **SMS Access**: flutter_sms_inbox + permission_handler
- **Export**: excel + share_plus
- **Target Platform**: Android (primary); iOS feasible but
  SMS inbox access is platform-limited
- **Performance**: SMS parsing MUST handle 10,000+ messages
  without UI jank; heavy work MUST run off the main isolate
- **Storage**: All persistent data in a single Drift database
  instance registered via GetIt

## Development Workflow

- **Routing**: All navigation MUST use GoRouter; no imperative
  `Navigator.push` calls.
- **Dependency Registration**: All services and repositories
  MUST be registered in `lib/di/injection.dart` via GetIt.
- **Commit Discipline**: Each commit MUST represent a single
  logical change with a conventional commit message
  (`feat:`, `fix:`, `refactor:`, `docs:`, `chore:`).
- **Testing**: Tests are encouraged but not gate-blocking.
  When written, tests MUST follow the Arrange-Act-Assert
  pattern and reside under `test/` mirroring `lib/` structure.
- **Logging**: Use the custom `Logger` utility for all
  diagnostic output; no raw `print()` calls.

## Governance

This constitution is the highest-authority document for
architectural and process decisions in this project. It
supersedes ad-hoc conventions and implicit patterns.

- **Amendments** require: (1) a documented rationale,
  (2) an updated version number following SemVer, and
  (3) a Sync Impact Report verifying template alignment.
- **Compliance**: All spec, plan, and task documents produced
  by Spec Kit commands MUST pass a Constitution Check gate
  before implementation begins.
- **Complexity Justification**: Any violation of Principle V
  (Simplicity) MUST be recorded in the plan's Complexity
  Tracking table with a rejected simpler alternative.
- **Runtime Guidance**: Use `CLAUDE.md` for agent-specific
  development guidance that complements this constitution.

**Version**: 2.0.0 | **Ratified**: 2026-06-21 | **Last Amended**: 2026-06-21
