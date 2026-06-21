# Phase 1 Data Model: SMS Pattern Authoring & Unmatched SMS Triage

Derived from the spec's Key Entities and clarifications. Persistence is Drift/SQLite; plain domain models map to Drift rows inside repositories (existing convention: `Transaction` ↔ `PoolContributionRow`). Schema version bumps **1 → 2** with an additive migration (create the four new tables; existing tables untouched).

Privacy invariant (Constitution I): **no raw SMS body is persisted.** Bodies live only in memory during a session. Persisted records reference SMS by inbox message ID and store extracted values.

---

## Domain models (plain Dart — `lib/domain/models/`)

### SmsDirection (enum)
`income | expense | balanceCheck` — maps 1:1 to the existing `TransactionType`.

### FieldLocator (value object)
| Field | Type | Notes |
|-------|------|-------|
| beforeAnchor | String | whitespace-delimited word immediately preceding the selected value (may be empty if value is at start) |
| afterAnchor | String | whitespace-delimited word immediately following (may be empty if at end) |

At least one of `beforeAnchor` / `afterAnchor` MUST be non-empty (FR-032).

### SmsToken (value objects — `sms_token.dart`)
- **NumericToken**: `{ rawText, normalizedValue (double), startIndex, endIndex, beforeWord, afterWord, isLikelyNonTransactional (bool) }`
- **TextToken**: `{ rawText, startIndex, endIndex }`

Transient — produced by the tokenizer, never persisted.

### SmsPattern (`sms_pattern.dart`)
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| id | String | ✓ | uuid |
| senderId | String | ✓ | exact inbox sender string |
| amountLocator | FieldLocator | ✓ | FR-009 |
| balanceLocator | FieldLocator? | – | FR-010, optional |
| counterpartyLocator | FieldLocator? | – | FR-012, optional |
| direction | SmsDirection | ✓ | FR-011 |
| exampleBody | String | ✓ | the teaching SMS (kept to re-open in edit, FR-021) |
| createdAt | DateTime | ✓ | |
| lastMatchedAt | DateTime? | – | |
| totalAttempts | int | ✓ | default 0 |
| successfulMatches | int | ✓ | default 0 |

- **confidence** (derived, not stored): `successfulMatches / totalAttempts`, shown as %, 100% for a brand-new pattern (FR-020).
- **Uniqueness**: multiple patterns MAY share `senderId` (distinct formats). No unique constraint on `senderId`.
- **Edit** preserves `totalAttempts`/`successfulMatches` (FR-020). **Delete** cascades to nothing in the ledger (matches/transactions stay).

> Note: `exampleBody` is the one place a body is stored — but only for the explicitly user-taught example, required to re-enter the edit flow (FR-021). This is user-authored content the user chose to teach, not silently harvested inbox data; it stays on-device. All *other* SMS bodies remain unpersisted.

### UnmatchedSms (`unmatched_sms.dart`)
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| smsId | String | ✓ | inbox message ID (primary key) |
| senderId | String | ✓ | |
| receivedAt | DateTime | ✓ | |
| dismissed | bool | ✓ | default false |
| body | String? | – | **transient** — populated from the in-memory scan for display; NOT a DB column |

State transitions (spec §Key Entities): Unmatched → Matched (record deleted on pattern save) · Unmatched → Dismissed (record deleted, `SuppressedSender` created) · Matched → Unmatched (pattern deleted) · Dismissed → Unmatched (suppression removed).

### PatternMatch (`pattern_match.dart`)
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| smsId | String | ✓ | inbox message ID (primary key) |
| patternId | String | ✓ | FK → SmsPattern.id (nullable after pattern delete) |
| senderId | String | ✓ | retained so the match survives pattern deletion |
| amount | double | ✓ | required (FR-025) |
| balance | double? | – | best-effort |
| counterparty | String? | – | best-effort |
| direction | SmsDirection | ✓ | |
| receivedAt | DateTime | ✓ | = transaction date (FR-015) |
| matchedAt | DateTime | ✓ | |

- **Cardinality**: 1 PatternMatch ↔ 1 ledger Transaction (FR-015). `smsId` PK prevents duplicates (FR-039/FR-040).
- **On pattern delete**: row is retained; `patternId` may be nulled (transaction stays — FR-022).
- **`balanceCheck` direction** (resolves analyze finding I3): a `balanceCheck` PatternMatch **still** maps 1:1 to a Transaction record (a balance *snapshot*), consistent with the existing app where `TransactionType.balanceCheck` is a `Transaction` used for balance display. "Not a ledger entry" in the spec Assumptions means it is **excluded from income/expense aggregation**, not that the record is absent. The existing analytics already exclude `balanceCheck` from income/expense sums; the learned path reuses that behavior. No special storage shape needed.
- **Single source (pass 3, research R8/R1)**: every transaction in the ledger is a `PatternMatch`. There is no hardcoded/ephemeral parse path, so each `smsId` has at most one `PatternMatch` → no duplicates by construction. `Transaction.source` is derived from `PatternMatch.senderId` (the `AccountSource` enum's parsing role is removed; accounts are discovered dynamically).

### SuppressedSender (`unmatched_sms.dart` or own file)
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| senderId | String | ✓ | primary key, exact case-sensitive match |
| suppressedAt | DateTime | ✓ | |

---

## Drift tables (`lib/data/database/app_database.dart`)

```text
SmsPatterns          (id PK, senderId, amountBefore, amountAfter,
                      balanceBefore?, balanceAfter?, cpBefore?, cpAfter?,
                      direction int, exampleBody, createdAt int,
                      lastMatchedAt int?, totalAttempts int, successfulMatches int)

PatternMatches       (smsId PK, patternId?, senderId, amount real, balance real?,
                      counterparty text?, direction int, receivedAt int, matchedAt int)

UnmatchedSmsRecords  (smsId PK, senderId, receivedAt int, dismissed bool default false)

SuppressedSenders    (senderId PK, suppressedAt int)
```

`FieldLocator` is flattened into paired `*Before`/`*After` text columns (Drift has no nested types). Repositories map columns ↔ `FieldLocator`. Dates stored as epoch-millis `int`, matching the existing tables.

### Migration (schema v2)
```text
onUpgrade(from:1 → to:2): create the four tables above. No changes to
PoolContributions / PayoutStates / SalaryMarks. Purely additive → low risk.
```

---

## Relationships

```text
SmsPattern  1 ──< PatternMatch        (patternId; nullable after delete)
SmsPattern  *  ── 1 senderId          (a sender may own many patterns)
PatternMatch 1 ── 1 Transaction       (ledger; smsId is the stable key)
SuppressedSender 1 ──< (suppresses) UnmatchedSms by senderId (exact match)
UnmatchedSms ── references inbox message by smsId (no body stored)
```

## Validation rules (from requirements)

- `SmsPattern.amountLocator` required; `direction` required (FR-009, FR-011).
- A match succeeds iff the amount locator resolves; balance/counterparty are best-effort/null (FR-025).
- `PatternMatch.smsId` is unique → re-scan cannot create duplicates; overwrite requires user confirmation (FR-023, FR-039/40).
- Multi-pattern resolution: try patterns for a sender in `createdAt` ascending order; first amount-resolving pattern wins (FR-034).
- Orphan pruning: an `UnmatchedSmsRecord` whose `smsId` is absent from the current inbox scan is deleted (FR-042); its `PatternMatch`/Transaction, if any, is retained.
- Unmatched classification (R8, pass 3): an SMS becomes an `UnmatchedSmsRecord` when no learned pattern matches **and** the sender is alphanumeric (R2) **and** the sender is not suppressed. There is no hardcoded-parser exception — every financial sender must be taught.

## Dashboard count source (R9)
The dashboard card reads `UnmatchedSmsRepository.activeCount()` (persisted from the previous scan) on launch for instant render, then refreshes after the background scan completes. The count is never blocked on a full scan.

## Impact on the existing `Transaction` model (pass 3)
`lib/domain/models/transaction.dart` currently types `source` as the `AccountSource` enum (`bankAlAhly`, `vfCash`). Going fully dynamic, `source` becomes a `String` sender identifier (or a lightweight `{ senderId, displayName }`), since accounts are no longer a fixed enumeration. Consumers of `AccountSource` (analytics, `SmsService.getFinancialSms`, transaction widgets) must be updated to the sender-string model. The hardcoded `SmsParser` is deleted. This is the largest existing-code change introduced by the feature and is captured as explicit tasks.

## Retention & growth (spec §Assumptions)
- `UnmatchedSmsRecords` removed on match (→ PatternMatch) or dismiss (→ SuppressedSender); orphans pruned on scan. Bounded, no stale accumulation.
- `SmsPatterns` grow slowly (<~50). `PatternMatches` grow linearly with SMS volume but are lightweight (no body).
