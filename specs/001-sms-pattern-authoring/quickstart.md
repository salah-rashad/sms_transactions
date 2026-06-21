# Quickstart: Validate SMS Pattern Authoring & Unmatched SMS Triage

A run/validation guide proving the feature works end-to-end. Implementation details live in the contracts, data-model, and `tasks.md`.

## Prerequisites
- Flutter SDK on PATH:
  ```bash
  export PATH="$PATH:/Users/salah/Library/flutter/bin"
  ```
- An Android device/emulator with SMS read permission grantable, and at least one bank/wallet SMS in the inbox from an **alphanumeric** sender the app does not yet know.
- No new packages needed (`flutter pub get` only if `app_database.g.dart` is regenerated).

## Build & run
```bash
export PATH="$PATH:/Users/salah/Library/flutter/bin"
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # regenerate Drift (schema v2)
flutter run
```

## Unit tests (pure logic — no device needed)
```bash
flutter test test/domain/sms/sms_tokenizer_test.dart
flutter test test/domain/sms/pattern_matcher_test.dart
```
Expected: tokenizer handles Latin + Arabic-Indic digits and mixed LTR/RTL (SC-006); matcher round-trips a derived pattern on its example and tolerates whitespace variation (FR-033). See [contracts/](contracts/) for the behavioral tables these tests encode.

## Manual validation scenarios

| # | Story | Steps | Expected outcome |
|---|-------|-------|------------------|
| 1 | US1 / FR-001..004 | Launch app with an unknown alphanumeric sender in inbox | Within ~1s, dashboard shows an "Unmatched Messages" card with the correct count and a **Review** action (SC-005). With an empty queue, no card appears. |
| 2 | US2 / FR-008..015 | Tap Review → Teach on one SMS → tap the amount chip → tap balance (or Skip) → pick Income/Expense → tap a name (or Skip) → confirm summary → Save | Live preview shows extracted values (FR-014); on Save a transaction appears in the ledger dated to the SMS timestamp (FR-015), and you return to the unmatched list. Whole flow doable in <60s (SC-001). |
| 3 | US2 / FR-013 | Mid-wizard, set amount+balance+direction, tap Back twice then forward | Later selections are preserved, not reset. |
| 4 | US5 / FR-024 | Simulate/receive a new SMS from the now-known sender, relaunch | It is parsed automatically into a transaction with no prompt (SC-002). |
| 5 | US5 / FR-025 | Receive an SMS from the known sender whose format lacks the amount anchor | It lands in the unmatched queue, not silently dropped. |
| 6 | US3 / FR-017 | On an unmatched SMS choose Dismiss / "Not a transaction" | It leaves the queue; future SMS from that sender are auto-suppressed (sender added to SuppressedSenders). |
| 7 | US4 / FR-019..022 | Settings → SMS Sources → see learned senders w/ confidence % → Delete one (confirm affected count) | Pattern removed; its past transactions remain in the ledger; that sender's SMS re-appear in the unmatched queue. |
| 8 | FR-018 | Settings → SMS Sources → Unsuppress a previously dismissed sender | Its historical SMS re-enter the unmatched queue. |
| 9 | FR-023 | Settings → SMS Sources → Re-scan when a matching transaction already exists | You are prompted to confirm before overwriting; declining leaves existing transactions intact; no duplicates created (FR-039/040). |
| 10 | SC-007 | Run on an inbox with 10,000+ SMS | Scan/match completes without visible UI jank (work runs off the main isolate, R3). |

## Definition of done (validation)
- Scenarios 1–10 pass on-device.
- Both unit-test files pass.
- No network traffic during any scenario (Constitution I) — verify with the device offline; everything still works.
- No raw SMS body written to `app.db` except the user-taught `exampleBody` on `SmsPatterns` (inspect the DB to confirm `PatternMatches`/`UnmatchedSmsRecords` hold no bodies).
