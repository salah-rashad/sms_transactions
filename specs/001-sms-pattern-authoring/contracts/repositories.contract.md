# Contract: Repositories & SmsScanService (data layer)

All registered in `lib/di/injection.dart` via GetIt (lazy singletons), following `SalaryRepository`/`MoneyPoolRepository` conventions. Repositories map Drift rows ↔ plain domain models.

## PatternRepository — `lib/data/repositories/pattern_repository.dart`
```dart
Future<List<SmsPattern>> getAll();
Future<List<SmsPattern>> getForSender(String senderId);   // createdAt asc (FR-034)
Future<void> upsert(SmsPattern pattern);                   // edit preserves counters (FR-020)
Future<void> delete(String patternId);                     // matches/transactions retained (FR-022)
Future<void> recordAttempt(String patternId, {required bool success, DateTime? matchedAt});
```

## PatternMatchRepository — `lib/data/repositories/pattern_repository.dart` (or own file)
```dart
Future<List<PatternMatch>> getAll();                       // merged into ledger at load
Future<PatternMatch?> getBySmsId(String smsId);            // duplicate check (FR-039/040)
Future<void> upsert(PatternMatch match);                   // smsId PK ⇒ idempotent
Future<int> countForSender(String senderId);               // affected-count on delete (FR-022)
Future<void> nullifyPatternRef(String patternId);          // on pattern delete, keep rows
```

## UnmatchedSmsRepository — `lib/data/repositories/unmatched_sms_repository.dart`
```dart
Future<List<UnmatchedSms>> getActive();                    // not dismissed, grouped by sender (FR-005)
Future<int> activeCount();                                 // dashboard card (FR-002)
Future<void> upsertAll(List<UnmatchedSms> records);        // from scan
Future<void> removeBySmsId(String smsId);                  // on match (FR-035)
Future<void> removeBySender(String senderId);              // on suppress
Future<void> pruneMissing(Set<String> presentSmsIds);      // orphan prune (FR-042)
```

## SuppressedSenderRepository — `lib/data/repositories/suppressed_sender_repository.dart`
```dart
Future<Set<String>> getAll();                              // exact-match suppression set (FR-017)
Future<void> suppress(String senderId);                    // dismiss (US3)
Future<void> unsuppress(String senderId);                  // re-activate (FR-018)
```

## SmsScanService — `lib/data/services/sms_scan_service.dart`
Orchestrates the launch/manual scan. Heavy matching runs in a `compute()` isolate (R3).
```dart
/// Reads candidate SMS (alphanumeric senders or already-patterned, R2),
/// matches each against learned patterns off the main isolate (R3/R8),
/// then persists:
///  - new PatternMatches (skipping smsIds already matched, unless [overwrite])
///  - UnmatchedSmsRecords when no learned pattern matches AND sender is not
///    suppressed (R8 pass 3 — no hardcoded-parser exception, FR-035)
///  - prunes orphaned unmatched records (FR-042)
/// Returns a summary (new matches, unmatched count, conflicts needing confirmation).
Future<ScanResult> scan({bool overwrite = false});

class ScanResult {
  final int newMatches;
  final int unmatchedCount;
  final List<PatternMatch> conflicts;   // smsIds already having a transaction (FR-023)
}
```

> **Fully dynamic (R8 pass 3, FR-035)**: there is no legacy `SmsParser`. The isolate worker tries only learned patterns (`PatternMatcher.matchAny`). An SMS with no matching pattern (and an alphanumeric, non-suppressed sender) becomes an `UnmatchedSmsRecord`. Since the pattern engine is the only parser, each `smsId` has at most one `PatternMatch` → no duplicates by construction.

### Behavioral contract
| Scenario | Expected |
|----------|----------|
| launch scan, 3 unknown alphanumeric senders | 3 UnmatchedSmsRecords; dashboard count=3 (FR-024) |
| sender has a pattern; new SMS matches | PatternMatch upserted; no unmatched record (FR-024) |
| re-scan, smsId already has a match | added to `conflicts`; not overwritten unless `overwrite:true` (FR-023) |
| suppressed sender sends new SMS | no unmatched record created (FR-017) |
| inbox SMS deleted since last scan | its UnmatchedSmsRecord pruned; PatternMatch retained (FR-042) |
| personal phone-number sender | excluded from candidates (R2) |
| previously hardcoded sender (BanK-AlAhly/VF-Cash), not yet taught | no learned pattern → routed to the unmatched queue like any new sender (FR-035) |
| same sender after the user teaches a pattern | auto-parsed into a single PatternMatch; no duplicate (one parser only) |

### Invariants
- Zero network calls (Constitution I). No raw body persisted (only ids + extracted values).
- Matching loop runs off the main isolate; Drift writes on main isolate (R3).
- Idempotent on `smsId`: re-running scan without `overwrite` never duplicates transactions.
