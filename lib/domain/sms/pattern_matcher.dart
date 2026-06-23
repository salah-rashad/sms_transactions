import 'package:sms_transactions/domain/models/pattern_match.dart';
import 'package:sms_transactions/domain/models/sms_pattern.dart';
import 'package:sms_transactions/domain/models/sms_token.dart';
import 'package:sms_transactions/domain/sms/sms_tokenizer.dart';

/// Pure (pattern, body)→PatternMatch? logic. No I/O; `receivedAt` is passed in
/// (= transaction date, FR-015), never read from the clock. See
/// `contracts/pattern-matcher.contract.md`.
///
/// Patterns are stored as text anchor locators (FR-031/032); a regex per locator
/// is derived at match time with `\s+` tolerance (FR-033). `derivePattern`
/// round-trips: `match(derivePattern(...), exampleBody)` MUST succeed (FR-014).
class PatternMatcher {
  PatternMatcher({SmsTokenizer? tokenizer})
    : _tokenizer = tokenizer ?? SmsTokenizer();

  final SmsTokenizer _tokenizer;

  // A numeric capture grammar (raw pattern string) reused for both authoring
  // chips and match-time captures, so they stay consistent (R4/R5). Defined as
  // a string so it can be embedded into a larger regex without the RegExp
  // `/.../` delimiters leaking.
  static const String _numericCapturePattern =
      r'(?:[\u0660-\u06690-9][\u0660-\u06690-9.,\u066B\u066C]*[\u0660-\u06690-9]'
      r'|[\u0660-\u06690-9])';

  /// Builds an SmsPattern from the user's chip selections in the teaching SMS.
  /// Captures the whitespace-delimited words around each selected value as
  /// before/after anchors (FR-031/032). Does NOT store indices (FR-016).
  SmsPattern derivePattern({
    required String senderId,
    required String exampleBody,
    NumericToken? amount,
    NumericToken? balance,
    TextToken? counterparty,
    required SmsDirection direction,
    String? patternId,
    DateTime? createdAt,
  }) {
    assert(
      amount != null || balance != null || counterparty != null,
      'At least one of amount/balance/counterparty must be provided',
    );
    return SmsPattern(
      id: patternId ?? '',
      senderId: senderId,
      amountLocator: amount == null
          ? null
          : FieldLocator(
              beforeAnchor: amount.beforeWord,
              afterAnchor: amount.afterWord,
            ),
      balanceLocator: balance == null
          ? null
          : FieldLocator(
              beforeAnchor: balance.beforeWord,
              afterAnchor: balance.afterWord,
            ),
      counterpartyLocator: counterparty == null
          ? null
          : FieldLocator(
              beforeAnchor: _wordAt(exampleBody, counterparty.startIndex,
                  before: true),
              afterAnchor: _wordAt(
                exampleBody,
                counterparty.endIndex,
                before: false,
              ),
            ),
      direction: direction,
      exampleBody: exampleBody,
      createdAt: createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  /// Applies [pattern] to [body]. The gate locator depends on direction:
  /// income/expense need amountLocator; balanceCheck needs balanceLocator;
  /// ignore needs counterpartyLocator. Other locators are best-effort
  /// (FR-025). Anchors match with `\s+` tolerance (FR-033). Returns null when
  /// the gate locator is absent or doesn't resolve (→ caller routes to
  /// unmatched, FR-025).
  PatternMatch? match(
    SmsPattern pattern,
    String smsId,
    String body,
    DateTime receivedAt,
  ) {
    final amount = _extractBestEffort(pattern.amountLocator, body);
    final balance = _extractBestEffort(pattern.balanceLocator, body);
    final counterparty = _extractText(pattern.counterpartyLocator, body);

    // Direction-aware gate: the locator that MUST resolve for a match.
    switch (pattern.direction) {
      case SmsDirection.income:
      case SmsDirection.expense:
        if (amount == null) return null;
      case SmsDirection.balanceCheck:
        if (balance == null) return null;
      case SmsDirection.ignore:
        if (counterparty == null) return null;
    }

    return PatternMatch(
      smsId: smsId,
      patternId: pattern.id.isEmpty ? null : pattern.id,
      senderId: pattern.senderId,
      amount: amount,
      balance: balance,
      counterparty: counterparty,
      direction: pattern.direction,
      receivedAt: receivedAt,
      matchedAt: DateTime.now(),
    );
  }

  /// Tries multiple patterns for one sender in createdAt-ascending order;
  /// returns the first successful match (FR-034). [patterns] is sorted ascending
  /// by createdAt before matching; the caller may pass them in any order.
  PatternMatch? matchAny(
    List<SmsPattern> patterns,
    String smsId,
    String body,
    DateTime receivedAt,
  ) {
    final ordered = [...patterns]..sort((a, b) {
      final byCreated = a.createdAt.compareTo(b.createdAt);
      if (byCreated != 0) return byCreated;
      return a.id.compareTo(b.id);
    });
    for (final pattern in ordered) {
      final result = match(pattern, smsId, body, receivedAt);
      if (result != null) return result;
    }
    return null;
  }

  double? _extractBestEffort(FieldLocator? locator, String body) {
    if (locator == null) return null;
    final regex = _buildLocatorRegex(locator, captureNumeric: true);
    if (regex == null) return null;
    final m = regex.firstMatch(body);
    if (m == null) return null;
    final captured = m.group(1);
    if (captured == null) return null;
    return _tokenizer.normalize(captured);
  }

  String? _extractText(FieldLocator? locator, String body) {
    if (locator == null) return null;
    final regex = _buildLocatorRegex(locator, captureNumeric: false);
    if (regex == null) return null;
    final m = regex.firstMatch(body);
    if (m == null) return null;
    final captured = m.group(1);
    return captured?.trim();
  }

  /// Builds a regex for a locator. When [captureNumeric] is true, the capture
  /// group matches the numeric grammar; otherwise it matches a word run.
  /// Returns null if the locator has no anchors (invalid per FR-032).
  RegExp? _buildLocatorRegex(FieldLocator locator, {required bool captureNumeric}) {
    final before = locator.beforeAnchor;
    final after = locator.afterAnchor;
    if (before.isEmpty && after.isEmpty) return null;

    final capture = captureNumeric
        ? '($_numericCapturePattern)'
        : r'(\S+(?:\s+\S+)*?)';

    final parts = <String>[];
    if (before.isNotEmpty) {
      parts.add(RegExp.escape(before));
      parts.add(r'\s+');
    }
    parts.add(capture);
    if (after.isNotEmpty) {
      parts.add(r'\s+');
      parts.add(RegExp.escape(after));
    }
    return RegExp(parts.join(), unicode: true);
  }

  String _wordAt(String body, int index, {required bool before}) {
    if (before) {
      return _wordBefore(body, index);
    }
    return _wordAfter(body, index);
  }

  String _wordBefore(String body, int tokenStart) {
    if (tokenStart == 0) return '';
    var i = tokenStart - 1;
    while (i >= 0 && _isWhitespace(body.codeUnitAt(i))) {
      i -= 1;
    }
    if (i < 0) return '';
    final end = i + 1;
    while (i >= 0 && !_isWhitespace(body.codeUnitAt(i))) {
      i -= 1;
    }
    return body.substring(i + 1, end);
  }

  String _wordAfter(String body, int tokenEnd) {
    if (tokenEnd >= body.length) return '';
    var i = tokenEnd;
    while (i < body.length && _isWhitespace(body.codeUnitAt(i))) {
      i += 1;
    }
    if (i >= body.length) return '';
    final start = i;
    while (i < body.length && !_isWhitespace(body.codeUnitAt(i))) {
      i += 1;
    }
    return body.substring(start, i);
  }

  bool _isWhitespace(int codeUnit) =>
      codeUnit == 0x20 ||
      codeUnit == 0x09 ||
      codeUnit == 0x0A ||
      codeUnit == 0x0D ||
      codeUnit == 0xA0;
}
