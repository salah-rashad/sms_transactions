# Phase 0 Research: SMS Pattern Authoring & Unmatched SMS Triage

This document resolves the open technical decisions surfaced while mapping the spec onto the existing codebase. The spec itself had no remaining `[NEEDS CLARIFICATION]` markers (two clarify passes completed). The items below are *engineering* decisions, not requirement gaps.

---

## R1. The ledger: fully persisted, learned-only (revised pass 3)

**Decision**: The ledger is **entirely** the persisted `PatternMatches` Drift table. Every transaction originates from a learned pattern match (FR-035). The hardcoded `SmsParser` is removed; there is no ephemeral parse path. At load time, the transaction list = `PatternMatchRepository.getAll()` mapped to `Transaction` objects.

**Rationale**: The current app holds **no** transaction table — `TransactionCubit.loadTransactions()` re-derives every transaction from SMS on each launch via the hardcoded `SmsParser` (`lib/features/transactions/cubit/transaction_cubit.dart`). The clarified spec requires transactions to **survive deletion of their pattern** (FR-022) and re-scan to detect already-parsed SMS (FR-023) — both require persistence. With the pass-3 decision to remove all hardcoded parsing (FR-035), there is no longer a second ephemeral source to union in; the persisted matches ARE the ledger. This is simpler than the earlier hybrid (no union, single source of truth per `smsId`).

**Alternatives considered**:
- *Hybrid (hardcoded ephemeral ∪ persisted learned)*: superseded by the pass-3 "fully dynamic" decision — the user explicitly wants the hardcoded parsers gone.
- *Keep hardcoded as seed patterns*: rejected by the user ("delete entirely, re-teach") — no migration/seeding.

**Privacy note (Constitution I)**: `PatternMatches` stores only the inbox message ID, matched pattern ID, and *extracted values* (amount, balance, direction, counterparty) — never the raw SMS body.

---

## R2. Candidate-sender scope for the unmatched queue

**Decision**: The scan considers an SMS a *candidate* (eligible for the unmatched queue) only if its sender identifier is **alphanumeric / non-phone-number**, OR the sender already has a saved `SmsPattern`. Pure phone-number senders (personal contacts) are excluded unless the user has explicitly taught them.

**Rationale**: `flutter_sms_inbox` can return the entire inbox. FR-024 says "scan the SMS inbox," but funneling *every* personal text, OTP, and promo into the unmatched queue would flood it and create a privacy/noise problem. In Egypt (and generally), banks and wallets send from alphanumeric sender IDs ("BANQUE-MISR", "VF-Cash"), while people send from phone numbers. Gating on alphanumeric senders captures the financial set with very low noise, and still lets a user teach a numeric sender by adding a pattern (which then whitelists it). This refines the *scope* of FR-024 without changing its intent and is consistent with the spec's "financial SMS" framing.

**Alternatives considered**:
- *All SMS*: rejected — floods the queue, harms privacy and SC-003 ("queue reaches zero in one session").
- *Only currency-keyword SMS*: rejected as the primary gate — too fragile across banks/languages; kept instead as an optional secondary de-emphasis heuristic in the authoring chip view (FR-008).

**Revisitable**: this is a heuristic; a future iteration may add a manual "scan a specific number" affordance.

---

## R3. Off-main-isolate scan & match

**Decision**: Run the inbox query + tokenization + pattern matching inside a `compute()` isolate via a new `SmsScanService`. The isolate returns plain result objects (matches + unmatched markers); all Drift writes happen back on the main isolate in the repositories. The matcher and tokenizer are pure functions (no plugin/DB handles), so they are isolate-safe.

**Rationale**: SC-007 requires no jank across 10,000+ SMS, and the Constitution mandates heavy work off the main isolate. Pattern matching is CPU-bound pure Dart (regex over strings) — ideal for `compute()`. Keeping Drift and the `flutter_sms_inbox` plugin on the main isolate avoids the complexity of background isolate database connections (`drift` isolate setup) and platform-channel-in-isolate pitfalls. The plugin query itself is async I/O (fast); only the matching loop needs offloading.

**Alternatives considered**:
- *drift background isolate / `computeWithDatabase`*: rejected for now (YAGNI) — adds isolate DB wiring for a workload that is dominated by pure matching, not DB I/O.
- *Run on main isolate with chunked `await Future.delayed`*: rejected — fragile, still risks jank on low-end devices.

---

## R4. Anchor-based pattern representation

**Decision**: Represent each `SmsPattern` as a set of **field locators**, where a locator = `{beforeAnchor, afterAnchor}` (the whitespace-delimited words immediately surrounding the user-selected chip). Matching builds a regex per locator at match time: `escape(beforeAnchor) + \s+ + (capture) + \s+ + escape(afterAnchor)`, with `\s+` tolerating whitespace/newline variation (FR-033). Anchors are stored as plain text; the regex is derived on demand, never persisted (FR-016 forbids storing index positions; we store text anchors instead).

**Rationale**: This directly implements FR-031/FR-032 and mirrors how the existing `SmsParser` already works (e.g. `RegExp(r'بمبلغ\s+([\d,]+\.?\d*)\s*جم')` in `sms_parser.dart`) — anchor word + amount + unit word. Reusing the proven shape lowers risk and keeps the derivation explainable. The capture group reuses the same numeric-token grammar defined by the tokenizer (R5), so authoring-time chips and match-time captures are guaranteed consistent.

**Alternatives considered**:
- *Store full regex strings*: rejected — opaque, hard to edit, and tempts storing positional/index data (FR-016 violation risk).
- *Token-index offsets*: rejected explicitly by FR-016 (breaks on variable-length amounts).

---

## R5. Numeric tokenizer grammar (Arabic + Latin)

**Decision**: A single tokenizer scans the body for numeric tokens using a Unicode-aware regex covering Latin digits `0-9` and Arabic-Indic digits `٠-٩`, optional grouping/decimal separators (`,` `.` and Arabic separators `٫` decimal / `٬` thousands). Normalization converts Arabic-Indic digits and separators to a canonical `double` (FR-026/FR-027). Ambiguous `1,500`-style tokens resolve via the sender's prior pattern locale, else default comma-as-thousands (FR-028). Text tokens for counterparty selection are whitespace-split words (FR-029).

**Rationale**: The existing parser already handles `[\d,]+\.?\d*` but only for Latin digits and only comma-thousands. Generalizing once, centrally, satisfies SC-006 (Arabic/English/mixed) and removes per-sender duplication. Putting it in `lib/domain/sms/sms_tokenizer.dart` keeps it pure and unit-testable.

**Alternatives considered**:
- *Per-format parsers*: rejected — duplication, inconsistent with a single chip grammar.
- *intl `NumberFormat` parsing*: considered for normalization; viable but heavier than a direct digit-map normalization for this constrained grammar. Kept as a fallback option during implementation, not a hard dependency.

---

## R6. Wizard navigation & state retention

**Decision**: Implement the 4-step authoring flow as a **single GoRoute** (`/unmatched/teach`) backed by `PatternAuthoringCubit`. Step index lives in cubit state; "back" decrements the index without clearing later-step selections (FR-013). A `PageView`/`AnimatedSwitcher` renders the current step. Quitting the route discards in-progress state (edge case: partial progress discarded).

**Rationale**: Constitution requires GoRouter and forbids imperative `Navigator.push`. A single route with cubit-driven steps is simpler than 4 sub-routes (Constitution V) and makes "back preserves later annotations" trivial (it's just state). Matches the index-based shell already used in `app_router.dart`.

**Alternatives considered**:
- *Sub-route per step*: rejected — more routing boilerplate, harder to preserve cross-step state, no benefit.
- *Flutter `Stepper` widget*: usable for layout but the state model stays in the cubit regardless; decision is orthogonal and left to implementation.

---

## R7. Reacting to queue changes across screens

**Decision**: A single `UnmatchedCubit` (app-scoped, provided in `app.dart` alongside the existing providers) owns the unmatched queue and exposes its count. The dashboard card and the unmatched screen both watch it; authoring/dismiss/suppress actions call back into it so the count updates reactively (FR-003 card auto-hide, US1 scenario 3).

**Rationale**: The dashboard card and the unmatched list must stay in sync without manual refresh. One shared cubit is the BLoC-idiomatic way and matches how `TransactionCubit`/`MoneyPoolCubit` are already app-scoped in `app.dart`.

**Alternatives considered**:
- *Separate count cubit + list cubit*: rejected — two sources of truth to keep in sync; YAGNI.

---

## R8. Remove the hardcoded `SmsParser`; fully dynamic parsing (revised pass 3 — supersedes the earlier legacy-reconciliation decision; closes analyze finding I1)

**Decision**: Delete the hardcoded per-sender `SmsParser` logic (`_parseBankAlAhly*`, `_parseVfCash*`, the `AccountSource` enum's parsing role). The scan classifies an SMS as **matched** only when a learned `SmsPattern` matches; otherwise (and if the sender is alphanumeric and not suppressed) it goes to the unmatched queue. No legacy fallback path exists. No migration or pre-seeding — previously hardcoded senders simply appear in the unmatched queue until taught (user choice: "delete entirely, re-teach").

**Why this supersedes the earlier R8**: The previous R8 kept `SmsParser` as a first-pass fallback to avoid duplicates and preserve continuity. The user has since directed that the hardcoded accounts/patterns must no longer be used and the app be fully dynamic. With no legacy path, the duplicate/precedence concern (analyze finding I1) disappears entirely — there is only one parser (the pattern engine), so one source per `smsId` is automatic.

**Constitution IV note**: This decision drove an amendment to Principle IV (Constitution **v2.0.0**). The principle now mandates fully-dynamic, user-authored parsing with no developer-hardcoded per-sender parsers — user-taught deterministic patterns ARE the rule-based base layer beneath future embedding/similarity learning. The design is therefore directly compliant (no reinterpretation).

**Consequence**: `SmsScanService` depends only on `PatternMatcher` (+ tokenizer). `Transaction.source` changes from the `AccountSource` enum to the sender identifier string (accounts are discovered dynamically). `SmsService.getFinancialSms()` (which queried only the two hardcoded addresses) is replaced by `getCandidateSms()` (alphanumeric senders, R2). `TransactionCubit` loads the ledger entirely from `PatternMatchRepository`.

**Alternatives considered** (all rejected by the user's directive): keep parser as fallback; seed legacy rules as editable patterns; one-time importer.

---

## R9. Dashboard card latency vs. background scan (resolves analyze finding I2)

**Decision**: On launch, `UnmatchedCubit` first reads the **persisted** `UnmatchedSmsRecords` count (a fast indexed DB read) and emits it immediately so the dashboard card can render within ~1s (SC-005). It then runs the background scan (R3) and re-emits the refreshed count when the scan completes (FR-024). The card's count is "last known + updating," never blocked on the full scan.

**Rationale**: SC-005 ("card within 1s") and FR-024 ("card appears once scan completes") are only in tension if the card waits for a 10k-SMS scan. Serving the cached count first satisfies both: instant render from the previous session's persisted queue, eventual consistency after the new scan. No requirement change needed — this is the engineering reconciliation.

**Alternatives considered**:
- *Block the card on scan completion*: rejected — violates SC-005 on large inboxes.
- *Always show a spinner until scan done*: rejected — worse UX and still misses the 1s target.

---

## Summary of decisions

| # | Decision |
|---|----------|
| R1 | Ledger is entirely persisted `PatternMatches` (learned-only); no ephemeral parse path (pass 3) |
| R2 | Unmatched queue considers alphanumeric senders (or already-patterned senders); excludes personal phone numbers |
| R3 | Scan + tokenize + match in a `compute()` isolate; Drift/plugin stay on main isolate |
| R4 | Patterns stored as text anchor locators; regex derived at match time with `\s+` tolerance |
| R5 | One pure tokenizer for Latin + Arabic-Indic digits/separators; locale-based ambiguity resolution |
| R6 | 4-step wizard = one GoRoute + `PatternAuthoringCubit`; step index in state |
| R7 | One app-scoped `UnmatchedCubit` shared by dashboard card and unmatched screen |
| R8 | Remove the hardcoded `SmsParser`; fully dynamic — only learned patterns parse; `Transaction.source` becomes the sender string (pass 3) |
| R9 | Dashboard card renders the cached persisted-queue count instantly, then refreshes after the background scan |

All decisions are consistent with Constitution v1.0.0. No new dependencies introduced.
