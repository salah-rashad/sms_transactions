# Contract: PatternMatcher & pattern derivation (pure domain)

`lib/domain/sms/pattern_matcher.dart` — no data/plugin dependencies. Pure, unit-testable.

```dart
class PatternMatcher {
  /// Builds an SmsPattern from the user's chip selections in the teaching SMS.
  /// Captures the whitespace-delimited words around each selected value as
  /// before/after anchors (FR-031/032). Does NOT store indices (FR-016).
  SmsPattern derivePattern({
    required String senderId,
    required String exampleBody,
    required NumericToken amount,
    NumericToken? balance,
    TextToken? counterparty,
    required SmsDirection direction,
  });

  /// Applies [pattern] to [body]. Succeeds iff the amount anchor resolves;
  /// balance/counterparty are best-effort and may be null (FR-025).
  /// Anchors match with \s+ tolerance for whitespace/newline variation (FR-033).
  PatternMatch? match(SmsPattern pattern, String smsId, String body, DateTime receivedAt);

  /// Tries multiple patterns for one sender in createdAt-ascending order;
  /// returns the first successful match (FR-034).
  PatternMatch? matchAny(List<SmsPattern> patterns, String smsId, String body, DateTime receivedAt);
}
```

### Behavioral contract
| Scenario | Expected |
|----------|----------|
| pattern from `"مبلغ 5,000 جنية"`, new body `"مبلغ 7,250 جنية"` | match, amount=7250 |
| same pattern, new body with extra spaces/newline around amount | match (FR-033) |
| pattern expects balance anchor; new body lacks it | match, amount set, balance=null (FR-025) |
| new body where amount anchor absent | `null` (→ caller routes to unmatched, FR-025) |
| two patterns, only the 2nd (newer) resolves | `matchAny` returns 2nd's result |
| two patterns both resolve | `matchAny` returns the older (createdAt asc, FR-034) |

### Invariants
- Pure: no I/O. `receivedAt` is passed in (= transaction date, FR-015), never read from clock.
- `derivePattern` round-trips: `match(derivePattern(...), exampleBody)` MUST succeed on the example (drives FR-014 live preview + FR-015 immediate parse).
- Derived anchors are plain text; regex is built at match time, never persisted.
