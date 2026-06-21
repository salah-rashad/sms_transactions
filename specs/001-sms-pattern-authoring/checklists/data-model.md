# Data Model & Pattern Engine Checklist: SMS Pattern Authoring

**Purpose**: Validate completeness, clarity, and consistency of data model and pattern engine requirements before planning
**Created**: 2026-06-21
**Feature**: [spec.md](../spec.md)
**Depth**: Deep
**Audience**: Author (self-review)

## Requirement Completeness — SmsPattern Entity

- [x] CHK001 - Are all attributes of SmsPattern enumerated with their data types and constraints (nullable, required, default)? [Completeness, Spec §Key Entities]
- [x] CHK002 - Is "anchor tokens" defined — what constitutes an anchor, how many are stored, and how they relate to the original SMS structure? [Clarity, Spec §Key Entities]
- [x] CHK003 - Is "amount field locator" defined — is it a positional offset, a regex capture group, or a token-relative reference? [Clarity, Spec §Key Entities]
- [x] CHK004 - Is "balance field locator" defined with the same precision as amount field locator? [Consistency, Spec §Key Entities]
- [x] CHK005 - Is "counterparty locator" defined — how is a text span reference stored persistently when the text itself varies per SMS? [Clarity, Spec §Key Entities]
- [x] CHK006 - Is "direction rule" defined — is it a static enum value (Income/Expense/BalanceCheck) or a derived rule from SMS content? [Clarity, Spec §Key Entities]
- [x] CHK007 - Are the relationships between SmsPattern and other entities (UnmatchedSms, PatternMatch, Transaction) explicitly documented? [Completeness, Gap]
- [x] CHK008 - Is the uniqueness constraint for SmsPattern specified — can two patterns share the same sender identifier? [Completeness, Spec §Edge Cases]
- [x] CHK009 - Is the SmsPattern lifecycle defined — states from creation through active use to deletion? [Gap]

## Requirement Completeness — Supporting Entities

- [x] CHK010 - Does the UnmatchedSms entity define how "dismiss status" interacts with SuppressedSender — is dismiss per-message or does it always escalate to sender-level? [Clarity, Spec §FR-017]
- [x] CHK011 - Is the relationship between UnmatchedSms and the raw SMS inbox source defined — is UnmatchedSms a copy or a reference to the inbox record? [Gap]
- [x] CHK012 - Does SuppressedSender specify whether suppression applies to the exact sender string or includes variations (e.g., "BANQUE-MISR" vs "BanqueMisr")? [Clarity, Spec §Key Entities]
- [x] CHK013 - Does PatternMatch define what happens to the match result when the source SmsPattern is later edited or deleted? [Completeness, Spec §Clarifications]
- [x] CHK014 - Is the cardinality between PatternMatch and Transaction defined — is each successful match exactly one transaction? [Gap]

## Requirement Clarity — Tokenization

- [x] CHK015 - Is "numeric token" defined with explicit rules — what qualifies as a number boundary (whitespace, currency symbol, parentheses)? [Clarity, Spec §FR-026]
- [x] CHK016 - Are the supported number formats enumerated (comma-thousands, period-decimal, Arabic-Indic digits ٠١٢٣٤٥٦٧٨٩, no-separator)? [Completeness, Spec §FR-027]
- [x] CHK017 - Is the handling of ambiguous formats specified — e.g., "1,500" could be 1500 or 1.5 depending on locale? [Edge Case, Spec §FR-028]
- [x] CHK018 - Are "non-numeric text tokens" defined for counterparty selection — how is text segmented (word boundaries, whitespace, punctuation)? [Clarity, Spec §FR-029]
- [x] CHK019 - Is tokenization behavior specified for mixed LTR/RTL content within a single SMS (e.g., English bank name in Arabic sentence)? [Clarity, Spec §FR-030]
- [x] CHK020 - Are tokens that look numeric but aren't transaction-relevant addressed — e.g., phone numbers, OTP codes, dates, reference numbers? [Coverage, Spec §FR-008]

## Requirement Clarity — Pattern Derivation

- [x] CHK021 - Is the algorithm or strategy for deriving a "regex or structural anchor pattern" from chip selections specified at a requirements level? [Clarity, Spec §FR-031]
- [x] CHK022 - Is it defined what "structural anchor" means — fixed text surrounding the selected chip, positional order, or keyword proximity? [Clarity, Spec §FR-031]
- [x] CHK023 - Is it specified how much surrounding context is captured as anchors — full words, N characters, or until the next token? [Gap, Spec §FR-032]
- [x] CHK024 - Is it defined whether the derived pattern is order-dependent (amount must appear before balance) or position-independent? [Gap, Spec §FR-031]
- [x] CHK025 - Are requirements specified for how the pattern handles minor sender format variations — e.g., extra whitespace, line breaks, slight wording changes? [Coverage, Spec §FR-033]

## Requirement Completeness — Pattern Matching

- [x] CHK026 - Is "match confidence" on PatternMatch defined — is it binary (matched/not) or a graded score, and if graded, what determines the grade? [Clarity, Spec §Key Entities - PatternMatch]
- [x] CHK027 - Is the threshold for "does not match the saved pattern" (FR-025) defined — what constitutes a failed match vs. a low-confidence match? [Clarity, Spec §FR-025]
- [x] CHK028 - Is it specified what happens when a pattern matches partially — e.g., amount extracted but balance anchor not found? [Edge Case, Spec §FR-025]
- [x] CHK029 - Is the matching order defined when multiple patterns exist for the same sender? [Gap, Spec §FR-034]
- [x] CHK030 - Are requirements defined for pattern matching performance — time per SMS, batch throughput for re-scan of 10,000+ messages? [Measurability, Spec §SC-007]

## Requirement Consistency — Confidence Score

- [x] CHK031 - Is the confidence score computation (matched/total) consistent between entity definition (Key Entities) and display requirement (FR-020)? [Consistency]
- [x] CHK032 - Is "total SMS from sender since pattern was saved" unambiguous — does it count suppressed-then-reactivated senders, edited patterns with reset counters? [Clarity, Spec §FR-020]
- [x] CHK033 - Is the initial confidence value defined — what does confidence show for a brand-new pattern with only the teaching SMS? [Edge Case, Spec §FR-020]
- [x] CHK034 - Are requirements defined for how confidence is displayed to the user — percentage, fraction, color indicator, descriptive label? [Gap, Spec §FR-020]

## Scenario Coverage — State Transitions

- [x] CHK035 - Is the state transition from "unmatched" to "matched" defined — what happens to the UnmatchedSms record when a pattern is saved and the SMS is re-parsed? [Coverage, Spec §Key Entities - UnmatchedSms]
- [x] CHK036 - Is the reverse transition defined — when a pattern is deleted, do its previously matched SMS return to the unmatched queue? [Coverage, Spec §FR-022]
- [x] CHK037 - Is the state transition from "suppressed" to "active" defined — when suppression is removed, do historical SMS from that sender enter the unmatched queue? [Coverage, Spec §FR-018]
- [x] CHK038 - Is it specified whether the teaching SMS itself becomes a transaction upon pattern save, or only future SMS are parsed? [Clarity, Spec §FR-015]

## Edge Case Coverage — Data Integrity

- [x] CHK039 - Are requirements defined for duplicate detection — what if the same SMS is scanned twice (e.g., after re-scan)? [Edge Case, Spec §FR-023]
- [x] CHK040 - Is it specified whether re-scan (FR-023) can create duplicate transactions from SMS already parsed by the same pattern? [Edge Case, Spec §FR-023]
- [x] CHK041 - Are requirements defined for handling SMS that arrive while a re-scan is in progress? [Edge Case, Spec §Edge Cases]
- [x] CHK042 - Is it specified what happens when the SMS inbox itself changes (messages deleted by user or carrier) between scans? [Edge Case, Spec §Edge Cases / Key Entities - UnmatchedSms]
- [x] CHK043 - Are currency handling requirements defined — does the pattern store or infer currency, and how are multi-currency senders handled? [Gap, Spec §Edge Cases / Assumptions]

## Non-Functional Requirements — Data Layer

- [x] CHK044 - Are data retention requirements specified for UnmatchedSms — are dismissed/matched items kept indefinitely or pruned? [Gap, Spec §Assumptions]
- [x] CHK045 - Are storage growth projections addressed — what is the expected data volume for patterns, matches, and unmatched records over time? [Gap, Spec §Assumptions]

## Notes

- Check items off as completed: `[x]`
- All 45/45 items resolved after spec update on 2026-06-21.
- Key additions: expanded Key Entities with attributes/relationships/lifecycle/cardinality, added FR-026 through FR-034 (tokenization, pattern derivation, matching order), clarified confidence display format and initial value, added edge cases for concurrent scan, inbox changes, and currency, added data retention and storage growth assumptions.
