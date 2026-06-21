# Feature Specification: SMS Pattern Authoring & Unmatched SMS Triage

**Feature Branch**: `001-sms-pattern-authoring`

**Created**: 2026-06-21

**Status**: Draft

**Input**: User description: "Guided step-by-step UX for teaching the app how to parse new SMS senders (Option A: number chip selection for amount/balance/type/counterparty), plus dashboard card + settings fallback for unmatched SMS (Option Z)."

---

## Clarifications

### Session 2026-06-21

- Q: When a user deletes or edits a pattern, what happens to previously parsed transactions? → A: Existing transactions are kept as-is in the ledger; only future parsing behavior changes.
- Q: What date should parsed transactions use? → A: Always use the SMS received timestamp as the transaction date.
- Q: When does the app first populate the unmatched SMS queue? → A: Automatically on app launch (background), with the dashboard card appearing once the scan completes.
- Q: Where does the user land after saving a new pattern? → A: Return to the unmatched SMS list to continue triaging.
- Q: What does the "confidence score" on SmsPattern represent in v1? → A: Historical match rate (matched SMS / total SMS from that sender since pattern was saved).

### Session 2026-06-21 (pass 2)

- Q: How does re-scan handle SMS that already have a matching transaction? → A: Re-parse all SMS but prompt the user to confirm before overwriting existing transactions.
- Q: What constitutes a successful pattern match when optional anchors are missing? → A: Amount anchor is required; balance and counterparty are best-effort (extracted if found, null if not).
- Q: When a pattern is deleted, do that sender's original SMS re-enter the unmatched queue? → A: Yes — SMS re-enter the unmatched queue for re-teaching; transactions stay in the ledger.
- Q: Should non-transactional numbers (phone numbers, OTPs, dates) be filtered from chip selection? → A: Show all tokens but visually de-emphasize likely non-transactional numbers using heuristic hints.
- Q: When suppression is removed from a sender, do historical SMS re-enter the unmatched queue? → A: Yes — historical SMS re-enter the unmatched queue, consistent with pattern deletion behavior.

### Session 2026-06-21 (pass 3) — Fully dynamic parsing

- Q: Should the app ship with hardcoded parsers for known senders (BanK-AlAhly, VF-Cash)? → A: No. Remove all hardcoded per-sender parsing. The app is fully dynamic — every sender, including ones previously hardcoded, is learned via the authoring wizard. Previously hardcoded senders re-enter the unmatched queue until the user teaches them (no migration, no pre-seeding).

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Review Unmatched SMS from Dashboard (Priority: P1)

The user opens the app and sees a card on the dashboard notifying them that one or more SMS messages could not be automatically parsed. They tap "Review" to begin triaging the backlog.

**Why this priority**: Without this entry point, the user has no discoverable path to teach the app new patterns. It is the triggering surface for all downstream authoring flows.

**Independent Test**: An unmatched SMS exists in the queue. The dashboard card appears. Tapping "Review" navigates to the unmatched SMS list. Delivers value: user is aware of and can act on unrecognized messages.

**Acceptance Scenarios**:

1. **Given** at least one SMS in the unmatched queue, **When** the user opens the dashboard, **Then** a card appears summarizing how many messages need review, with a "Review" action.
2. **Given** the unmatched queue is empty, **When** the user opens the dashboard, **Then** no card is shown and the dashboard layout is unaffected.
3. **Given** the user dismisses/resolves all items in the unmatched queue, **When** they return to the dashboard, **Then** the card disappears automatically.

---

### User Story 2 - Teach the App a New SMS Pattern (Priority: P1)

The user selects an unmatched SMS and is guided step-by-step to annotate it: first identifying the transaction amount, then the running balance, then the transaction direction (income/expense), and optionally a counterparty name. At the end, the app confirms the learned pattern with a live preview of how it will parse future messages from that sender.

**Why this priority**: This is the core value of the feature — turning an unknown sender into a reliably parsed one without requiring the user to understand regular expressions.

**Independent Test**: Given one unmatched SMS, the user completes all guided steps and saves the pattern. Subsequent simulated SMS from the same sender produce correctly parsed transactions. Delivers value: the sender is now understood and requires no future manual effort.

**Acceptance Scenarios**:

1. **Given** an unmatched SMS is selected, **When** the guided flow starts, **Then** Step 1 highlights all detected numeric tokens as tappable chips and asks the user to select the transaction amount.
2. **Given** the user selects an amount chip, **When** Step 2 loads, **Then** remaining numeric chips are shown and the user is asked to select the running balance (or skip if not present).
3. **Given** amount and balance are identified, **When** Step 3 loads, **Then** the user is presented with [Income / Expense / Balance Check] options to classify the transaction direction.
4. **Given** the transaction direction is set, **When** Step 4 loads, **Then** the user can optionally tap a name/text token to mark it as the counterparty, or skip.
5. **Given** all steps are complete, **When** the summary screen is shown, **Then** a live preview renders the SMS with all annotated fields highlighted and their extracted values listed.
6. **Given** the user confirms the summary, **When** "Save Pattern" is tapped, **Then** the pattern is persisted, the SMS is re-parsed against it, the resulting transaction is added to the ledger, and the user is returned to the unmatched SMS list to continue triaging.
7. **Given** a chip is selected in error, **When** the user taps the back arrow, **Then** they return to the previous step without losing other annotations.

---

### User Story 3 - Dismiss an Unmatched SMS (Priority: P2)

The user reviews an unmatched SMS and decides it is not a financial transaction (e.g., a marketing message or OTP). They dismiss it permanently so it stops appearing in the review queue.

**Why this priority**: Without a dismiss path, the queue becomes noisy and the user loses confidence in the review flow.

**Independent Test**: User opens an unmatched SMS and selects "Not a transaction". The item disappears from the queue and never resurfaces.

**Acceptance Scenarios**:

1. **Given** an unmatched SMS is open in the review flow, **When** the user selects "Not a transaction / Ignore", **Then** the SMS is flagged as dismissed and removed from the unmatched queue.
2. **Given** a dismissed SMS sender sends a new message with the same format, **When** it arrives, **Then** it is also silently dismissed (sender-level suppression, not message-level).

---

### User Story 4 - Manage Known Patterns in Settings (Priority: P2)

The user navigates to Settings → SMS Sources to view all senders the app has learned, edit or delete patterns, and manually re-trigger a scan of historical SMS.

**Why this priority**: Without a management view, patterns are invisible and irreversible, eroding user trust.

**Independent Test**: Settings screen lists all learned senders with their pattern confidence. User can delete one pattern; after deletion, that sender's messages return to the unmatched queue.

**Acceptance Scenarios**:

1. **Given** the user opens Settings → SMS Sources, **When** the screen loads, **Then** all known senders are listed with sender name, number of matched transactions, and a confidence indicator.
2. **Given** a sender entry is shown, **When** the user taps "Edit Pattern", **Then** they re-enter the guided authoring flow pre-populated with the existing pattern's example SMS.
3. **Given** a sender entry is shown, **When** the user taps "Delete", **Then** the pattern is removed and a count of affected transactions is shown before confirmation.
4. **Given** the user taps "Re-scan SMS Inbox", **When** the scan completes, **Then** any historical unmatched SMS from known senders are re-processed and the transaction count updates.

---

### User Story 5 - Pattern Applies to Future Messages Automatically (Priority: P1)

Once a pattern is saved, all new incoming SMS from the same sender are parsed automatically without any user interaction.

**Why this priority**: Automation is the payoff for the teaching investment. Without it, the feature has no compound value.

**Independent Test**: Save a pattern for sender X. Simulate a new SMS from X with a different amount. Verify it appears as a parsed transaction in the ledger with no user prompt.

**Acceptance Scenarios**:

1. **Given** a saved pattern for sender "BANQUE-MISR", **When** a new SMS from "BANQUE-MISR" arrives, **Then** it is parsed and stored as a transaction without any user action.
2. **Given** a new SMS from a known sender that does not match the saved pattern (format changed), **When** it arrives, **Then** it is placed in the unmatched queue rather than silently failing.

---

### Edge Cases

- What happens when the SMS contains only one number? (e.g., no balance — app should gracefully skip the balance step and mark it as absent in the pattern)
- What happens when the same phone number sends SMS in two different formats? (two separate patterns should be allowed per sender if formats are distinguishable)
- What happens when the user quits mid-authoring? (partial progress is discarded; the SMS remains in the unmatched queue)
- How does the system handle RTL text (Arabic) when tokenizing number chips? (chips must be positioned correctly in RTL layout)
- What if no numeric tokens are detected in the SMS? (the flow cannot proceed; the user is prompted to dismiss or skip)
- What if an unmatched SMS queue grows very large (100+ messages)? (list must be performant; lazy-loaded with sender grouping)
- What if new SMS arrive while a re-scan is in progress? (new SMS MUST be queued and processed after the current re-scan completes; they MUST NOT be skipped or lost)
- What if the SMS inbox changes between scans (messages deleted by user or carrier)? (UnmatchedSms records referencing deleted inbox messages MUST be pruned on the next scan; their linked transactions, if any, remain in the ledger)
- How is currency handled? (currency is not extracted from SMS in v1; all amounts are assumed to be in the user's primary currency, which is the local currency of the device locale)

---

## Requirements *(mandatory)*

### Functional Requirements

**Dashboard Integration**

- **FR-001**: The dashboard MUST display an "Unmatched Messages" card when one or more SMS messages are in the unmatched queue.
- **FR-002**: The card MUST show the count of unmatched messages and a single "Review" call-to-action.
- **FR-003**: The card MUST disappear automatically when the unmatched queue reaches zero.
- **FR-004**: The card MUST NOT appear when the queue is empty, and MUST NOT affect dashboard layout when absent.

**Unmatched SMS List**

- **FR-005**: The unmatched SMS list MUST group messages by sender.
- **FR-006**: Each item MUST show the sender identifier, message preview, and received timestamp.
- **FR-007**: Each item MUST offer two primary actions: "Teach" (enter authoring flow) and "Dismiss" (not a transaction).

**Pattern Authoring Flow (Guided Steps)**

- **FR-008**: Step 1 MUST scan the example SMS and present all detected numeric tokens as individually tappable chips, with surrounding context text visible. Tokens that heuristically appear non-transactional (e.g., phone numbers, OTP codes, short reference numbers) MUST still be shown but visually de-emphasized to guide the user toward likely amount/balance candidates.
- **FR-009**: The user MUST be able to select exactly one chip as the transaction amount in Step 1.
- **FR-010**: Step 2 MUST present remaining numeric chips and allow the user to select one as the running balance, or skip if none applies.
- **FR-011**: Step 3 MUST present three transaction-direction options: Income, Expense, Balance Check Only.
- **FR-012**: Step 4 MUST allow the user to tap any non-numeric text token to designate it as the counterparty name anchor, or skip.
- **FR-013**: Each step MUST display a step counter (e.g., "Step 2 of 4") and a back button that returns to the previous step without resetting later-step annotations.
- **FR-014**: The summary screen MUST render a live preview of the annotated SMS with all extracted field values and their assigned roles clearly labeled.
- **FR-015**: Saving the pattern MUST immediately re-parse the example SMS and add the resulting transaction to the ledger. The transaction date MUST be the SMS received timestamp.
- **FR-016**: The system MUST derive a regex or structural anchor pattern from the user's chip selections — not store chip index positions — to handle variable amounts in future messages.

**Tokenization & Number Detection**

- **FR-026**: A "numeric token" is any contiguous sequence of digits (0–9 and Arabic-Indic ٠–٩) optionally containing comma-thousands separators, period-decimal separators, or both. Token boundaries are whitespace, currency symbols, parentheses, or any non-digit non-separator character.
- **FR-027**: The tokenizer MUST support these number formats: plain integers (5000), comma-thousands with period-decimal (5,000.00), period-thousands with comma-decimal (5.000,00), Arabic-Indic digits (٥٬٠٠٠٫٠٠), and no-separator decimals (5000.00).
- **FR-028**: Ambiguous formats (e.g., "1,500" — could be 1500 or 1.5) MUST be resolved using the locale/currency context of the sender's previous patterns. If no prior context exists, assume comma-as-thousands (Egyptian banking convention).
- **FR-029**: For counterparty selection (Step 4), "text tokens" are segmented by whitespace boundaries. Each whitespace-delimited word is a selectable token. Punctuation attached to a word is included in the token.
- **FR-030**: Tokenization MUST handle mixed LTR/RTL content correctly — chips MUST be positioned following the logical text order of the SMS, not reversed. The visual layout MUST respect the base direction of the SMS content.

**Pattern Derivation & Matching Behavior**

- **FR-031**: The derived pattern MUST use surrounding anchor tokens (the fixed text before and after each selected chip) to locate variable values. The pattern MUST preserve the relative order of anchors as they appear in the teaching SMS.
- **FR-032**: Anchors MUST capture complete whitespace-delimited words adjacent to the selected chip. At minimum, one word before and one word after each chip MUST be captured as anchors.
- **FR-033**: The derived pattern MUST tolerate minor whitespace and line-break variations between the teaching SMS and future SMS. Extra spaces, tab characters, and newline differences MUST NOT cause a match failure.
- **FR-034**: When multiple patterns exist for the same sender, they MUST be tried in creation-date order (oldest first). The first pattern whose amount anchor resolves wins.

**Dismiss & Suppression**

- **FR-017**: Dismissing a message MUST suppress all future messages from the same sender from appearing in the unmatched queue.
- **FR-018**: Suppressed senders MUST be listed in Settings and MUST be re-activatable (remove suppression). When suppression is removed, all historical SMS from that sender MUST re-enter the unmatched queue.

**Settings — SMS Sources**

- **FR-019**: Settings MUST include an "SMS Sources" section listing all known (learned) senders and all suppressed senders.
- **FR-020**: Each learned sender entry MUST show: sender name, matched transaction count, last matched date, and a confidence level (historical match rate: successful matches divided by total SMS received from that sender since pattern creation). Confidence MUST be displayed as a percentage (e.g., "93%"). A newly created pattern with only the teaching SMS MUST show 100% confidence (1 match out of 1 attempt). When a pattern is edited, its match counters MUST be preserved (not reset).
- **FR-021**: Users MUST be able to edit a sender's pattern (re-enters authoring flow pre-loaded with the original example SMS).
- **FR-022**: Users MUST be able to delete a sender's pattern with a confirmation step that shows how many transactions will be affected. Deleting or editing a pattern MUST NOT modify or remove previously parsed transactions. Upon pattern deletion, all SMS from that sender MUST re-enter the unmatched queue so the user can re-teach the sender with a new pattern if desired.
- **FR-023**: Users MUST be able to manually trigger a re-scan of the SMS inbox to apply new or updated patterns to historical messages. When re-scan encounters SMS that already have a matching transaction in the ledger, the system MUST re-parse them and prompt the user for confirmation before overwriting existing transactions.

**Automatic Parsing**

- **FR-024**: The app MUST scan the SMS inbox automatically on each app launch in the background. All new SMS from senders with a saved pattern MUST be parsed automatically. Unmatched SMS MUST be added to the unmatched queue. The dashboard card MUST appear once the scan completes.
- **FR-025**: SMS from a known sender that does NOT match the saved pattern MUST be routed to the unmatched queue, not silently dropped. A match is considered successful when the amount anchor resolves; balance and counterparty anchors are best-effort (extracted if found, stored as null if not). A match fails only when the amount anchor cannot be resolved.
- **FR-035**: The app MUST NOT contain hardcoded, per-sender parsing logic. All SMS parsing MUST be performed exclusively through user-authored patterns. Every transaction in the ledger MUST originate from a learned pattern match. Senders that were previously handled by built-in parsing MUST appear in the unmatched queue until the user teaches a pattern for them (no migration or pre-seeding of built-in patterns).

### Key Entities

- **SmsPattern**: A learned parsing rule for one SMS format from one sender.
  - *Required attributes*: sender identifier, anchor tokens, amount field locator, direction rule (enum: Income | Expense | BalanceCheck), example SMS body (the original teaching SMS), creation date.
  - *Optional attributes*: balance field locator, counterparty locator, last-matched date.
  - *Derived attributes*: confidence score (successful matches ÷ total attempted matches since creation), total attempted matches, successful matches.
  - *Anchor tokens*: the fixed text fragments immediately surrounding each selected chip in the teaching SMS. They serve as landmarks for locating variable numeric values in future SMS. For example, if the user selects "5,000.00" in "مبلغ 5,000.00 جنية", the anchors are "مبلغ" (before) and "جنية" (after).
  - *Field locators* (amount, balance, counterparty): each locator is defined by its surrounding anchor tokens, not by character index or position. The locator identifies where to find the variable value relative to those anchors.
  - *Uniqueness*: multiple patterns MAY exist for the same sender identifier to handle distinct SMS formats. Patterns are distinguished by their anchor tokens.
  - *Lifecycle*: Created (saved from authoring flow) → Active (matching incoming SMS) → Edited (re-authored, counters preserved) → Deleted (SMS re-enter unmatched queue, transactions stay in ledger).
  - *Relationships*: one SmsPattern → many PatternMatches. One SmsPattern → one sender identifier (but a sender may have multiple SmsPatterns).

- **UnmatchedSms**: An SMS that could not be parsed against any known pattern.
  - *Required attributes*: SMS inbox message ID (reference to the device inbox record, not a copy of the raw body), sender identifier, received timestamp.
  - *Optional attributes*: dismiss status (boolean).
  - *Relationships*: references the device SMS inbox by message ID. If the inbox message is deleted by the user or carrier, the UnmatchedSms record becomes orphaned and MUST be pruned on the next scan.
  - *State transitions*: Unmatched → Matched (when a new pattern is saved and successfully parses this SMS; the UnmatchedSms record is removed). Unmatched → Dismissed (sender-level suppression; record removed, SuppressedSender created). Matched → Unmatched (when the matching pattern is deleted; record re-created from inbox). Dismissed → Unmatched (when suppression is removed; records re-created from inbox).

- **SuppressedSender**: A sender designated as non-financial.
  - *Required attributes*: sender identifier (exact string match as returned by the SMS inbox), suppressed date.
  - *Relationships*: one SuppressedSender suppresses all UnmatchedSms with the same sender identifier (exact match, case-sensitive).

- **PatternMatch**: The result of applying an SmsPattern to a single SMS.
  - *Required attributes*: extracted amount, direction, SMS inbox message ID, matched SmsPattern reference, match timestamp.
  - *Optional attributes*: extracted balance, counterparty name, match confidence.
  - *Match confidence*: binary — either the amount anchor resolved (successful match) or it did not (failed match). There is no graded confidence on individual matches; the graded confidence score lives on SmsPattern as an aggregate over time.
  - *Cardinality*: each successful PatternMatch produces exactly one Transaction in the ledger. The relationship is 1:1.
  - *On pattern deletion*: the PatternMatch record and its linked Transaction remain in the ledger unchanged.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A first-time user can teach the app a new SMS sender pattern in under 60 seconds, completing all guided steps without assistance.
- **SC-002**: After saving a pattern, 100% of subsequent SMS from that sender are automatically parsed without user interaction, assuming the SMS format is unchanged.
- **SC-003**: The unmatched queue reaches zero within one user session for a user who received their first batch of SMS at app install.
- **SC-004**: Users can find and delete a learned pattern from Settings in under 3 taps from the home screen.
- **SC-005**: The dashboard card appears within one second of app launch when the unmatched queue is non-empty.
- **SC-006**: The guided authoring flow handles SMS in Arabic, English, and mixed-language formats without layout or tokenization errors.
- **SC-007**: Pattern authoring and all on-device parsing produce no visible UI jank, even when processing a backlog of 10,000+ historical SMS.

---

## Assumptions

- The app already has SMS inbox read permission; this feature does not introduce a new permission grant flow.
- "Sender identifier" is the sender address/alphanumeric tag as returned by the SMS inbox (e.g., "BANQUE-MISR", "+20100…"). It also serves as the transaction's account/source label (there is no fixed enumeration of accounts — accounts are discovered dynamically as the user teaches senders).
- The app ships with NO built-in sender knowledge. On first run (or after upgrading from a build that had hardcoded parsing), all financial senders appear in the unmatched queue until taught. The previously hardcoded `SmsParser` is removed.
- A single sender maps to at most a small number of distinct pattern formats; edge-case multi-format support (FR-016) is deferred to a later iteration unless it surfaces naturally.
- The number tokenizer can reliably detect numeric tokens including comma-separated and period-decimal formats (e.g., "5,000.00") in both LTR and RTL strings.
- Counterparty identification is optional in all patterns; many Egyptian bank SMS do not include merchant names.
- "Balance Check Only" as a transaction direction means the SMS is informational (no debit/credit) and is stored as a balance snapshot, not a ledger entry.
- The re-scan feature operates on the local SMS inbox snapshot already loaded by the app, not a fresh inbox read, to avoid redundant permission prompts.
- All learned patterns and unmatched SMS are stored exclusively on-device in the local Drift database, consistent with Constitution Principle I.
- Data retention: UnmatchedSms records for dismissed senders are removed when SuppressedSender is created. UnmatchedSms records for matched SMS are removed when the PatternMatch is created. Orphaned records (inbox message deleted) are pruned on scan. No indefinite accumulation of stale records.
- Storage growth is bounded: SmsPattern records grow slowly (one per sender format, typically <50 total). PatternMatch and Transaction records grow linearly with SMS volume but are lightweight (no SMS body stored — only extracted values and inbox message ID reference).
- Currency is not stored on patterns or transactions in v1. All amounts are assumed to be in the device locale's primary currency.
