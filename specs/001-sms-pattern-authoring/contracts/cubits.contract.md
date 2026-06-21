# Contract: Cubits & routes (presentation layer)

BLoC/Cubit with immutable states + `copyWith` (Constitution II). Provided per existing conventions (app-scoped in `app.dart`, or route-scoped via `BlocProvider` for the wizard).

## UnmatchedCubit — `lib/features/unmatched/cubit/` (app-scoped, shared by dashboard card + list, R7)
```dart
class UnmatchedState {           // immutable + copyWith
  final List<UnmatchedSms> items;          // active, grouped by sender (FR-005)
  final int count;                         // drives dashboard card (FR-001..004)
  final UnmatchedStatus status;            // initial | scanning | ready | error
}

Future<void> loadCachedCount();            // R9: instant read of persisted activeCount (SC-005)
Future<void> runLaunchScan();              // FR-024 (called once on app start, after loadCachedCount)
Future<void> refresh();
Future<void> dismissSender(String senderId);   // US3 / FR-017
```
- Card visible iff `count > 0` (FR-001/003/004). Updates reactively after teach/dismiss.
- **R9 (resolves I2)**: on launch, `loadCachedCount()` emits the persisted queue count immediately (card renders within ~1s, SC-005); `runLaunchScan()` then refreshes it once the background scan completes (FR-024).

## PatternAuthoringCubit — `lib/features/pattern_authoring/cubit/` (route-scoped for `/unmatched/teach`)

**Construction (resolves U1)**: the cubit accepts the SMS body to teach plus an *optional* existing `SmsPattern` for **edit mode** (FR-021). In edit mode it pre-loads `exampleBody`, re-derives the token lists, and pre-selects amount/balance/direction/counterparty from the existing locators; on save it updates the existing pattern **preserving** `totalAttempts`/`successfulMatches` (FR-020). In create mode the existing-pattern argument is null.

```dart
class PatternAuthoringState {     // immutable + copyWith
  final UnmatchedSms source;               // sms being taught
  final SmsPattern? editing;               // non-null in edit mode (FR-021); counters preserved
  final List<NumericToken> numericTokens;  // FR-008 (de-emphasis flag included)
  final List<TextToken> textTokens;        // FR-029
  final int stepIndex;                     // 0..3 (+summary); back preserves later steps (FR-013)
  final NumericToken? amount;              // step 1 (FR-009)
  final NumericToken? balance;             // step 2, optional (FR-010)
  final SmsDirection? direction;           // step 3 (FR-011)
  final TextToken? counterparty;           // step 4, optional (FR-012)
  final PatternMatch? preview;             // summary live preview (FR-014)
}

void selectAmount(NumericToken t);
void selectBalance(NumericToken? t);       // null = skip
void selectDirection(SmsDirection d);
void selectCounterparty(TextToken? t);     // null = skip
void back();                               // decrement step, keep later selections (FR-013)
Future<void> save();                       // derive+persist pattern, parse example, return to list (FR-015)
```
- `save()` writes the SmsPattern + the example's PatternMatch, then signals the list to refresh and pop (FR-015, "return to unmatched list").

## SmsSourcesCubit — `lib/features/settings/cubit/` (route-scoped for `/settings/sms-sources`)
```dart
class SmsSourcesState {           // immutable + copyWith
  final List<SmsSourceView> learned;    // sender, matchCount, lastMatchedAt, confidence% (FR-019/020)
  final List<String> suppressed;        // FR-019
}

Future<void> load();
Future<void> deletePattern(String patternId);   // shows affected count first (FR-022)
Future<void> unsuppress(String senderId);       // FR-018 → historical SMS re-enter queue
Future<ScanResult> rescan({bool overwrite});    // FR-023 (overwrite after user confirms conflicts)
```

## Routes — `lib/router/app_router.dart`
| Path | Screen | Story |
|------|--------|-------|
| `/unmatched` | UnmatchedScreen | US1 (from dashboard card "Review") |
| `/unmatched/teach` | PatternAuthoringScreen | US2 (from list "Teach"; also edit entry, FR-021) |
| `/settings/sms-sources` | SmsSourcesScreen | US4 (from Settings) |

All navigation via GoRouter `context.push` (no `Navigator.push`, Constitution). The wizard route carries the selected `UnmatchedSms` (and, for edit, the `SmsPattern` id) via `extra`.

### Invariants
- States immutable; transitions via `emit(copyWith(...))`.
- Heavy scan delegated to `SmsScanService` (cubits stay thin).
- Quitting the wizard route discards in-progress state (edge case).
