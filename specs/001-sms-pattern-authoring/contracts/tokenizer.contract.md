# Contract: SmsTokenizer (pure domain)

`lib/domain/sms/sms_tokenizer.dart` — no data/plugin dependencies. Pure, unit-testable.

```dart
class SmsTokenizer {
  /// Detects every numeric token in [body], Latin (0-9) and Arabic-Indic (٠-٩),
  /// with optional thousands/decimal separators (',' '.' '٬' '٫').
  /// Each token carries its normalized double value, char span, adjacent words,
  /// and a heuristic flag for likely non-transactional numbers (FR-008/026/027).
  List<NumericToken> numericTokens(String body);

  /// Whitespace-delimited word tokens for counterparty selection (FR-029).
  List<TextToken> textTokens(String body);

  /// Normalizes a raw numeric token to a double, mapping Arabic-Indic digits and
  /// resolving separators. [localeHint] disambiguates '1,500' style tokens;
  /// defaults to comma-as-thousands when null (FR-028).
  double normalize(String rawToken, {NumberLocale? localeHint});
}
```

### Behavioral contract
| Input | Expected |
|-------|----------|
| `"مبلغ 5,000.00 جنية"` | one NumericToken value=5000.0, beforeWord="مبلغ", afterWord="جنية" |
| `"رصيد ٥٬٠٠٠٫٥٠ جنيه"` | one NumericToken value=5000.5 (Arabic-Indic normalized) |
| `"5.000,00 EGP"` (eu-style) | value=5000.0 when localeHint=periodThousands |
| `"OTP 123456"` | NumericToken with isLikelyNonTransactional=true |
| body with mixed LTR/RTL | tokens returned in logical order; spans correct (FR-030) |
| `""` / no digits | empty list |

### Invariants
- Pure: same input → same output; no I/O, no `DateTime.now()`.
- Token `startIndex`/`endIndex` are valid ranges into `body`.
- `normalize` never throws on a token previously emitted by `numericTokens` (must round-trip).
