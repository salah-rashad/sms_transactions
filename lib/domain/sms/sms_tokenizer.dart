import 'package:sms_transactions/domain/models/sms_token.dart';

/// Locale hint for resolving ambiguous numeric separators (FR-028).
///
/// `1,500` is ambiguous: comma-as-thousands (→ 1500) under [commaThousands]
/// (the default), or comma-as-decimal (→ 1.5) under [periodThousands] (EU).
enum NumberLocale { commaThousands, periodThousands }

/// Pure body→tokens. No I/O, no `DateTime.now()` — same input always yields the
/// same output. See `contracts/tokenizer.contract.md`.
///
/// Detects numeric tokens in Latin (0-9) and Arabic-Indic (٠-٩) digits with
/// optional grouping/decimal separators (',' '.' '٬' '٫'), plus whitespace-split
/// text tokens for counterparty selection (FR-026..030).
class SmsTokenizer {
  const SmsTokenizer({this.defaultLocale});

  final NumberLocale? defaultLocale;
  // A numeric run: starts with a digit, optionally contains internal digits and
  // separators (',' '.' Arabic ٬ ٫), ends with a digit. Whitespace is NOT part
  // of a token (word boundary).
  static final RegExp _numberRegex = RegExp(
    r'[\u0660-\u06690-9](?:[\u0660-\u06690-9.,\u066B\u066C])*[\u0660-\u06690-9]'
    r'|[\u0660-\u06690-9]',
  );

  static final RegExp _wordRegex = RegExp(r'\S+');

  // Arabic-Indic digit map (٠..٩ → 0..9).
  static const Map<int, String> _arabicIndicDigits = {
    0x0660: '0',
    0x0661: '1',
    0x0662: '2',
    0x0663: '3',
    0x0664: '4',
    0x0665: '5',
    0x0666: '6',
    0x0667: '7',
    0x0668: '8',
    0x0669: '9',
  };

  static const int _arabicDecimal = 0x066B; // ٫
  static const int _arabicThousands = 0x066C; // ٬

  /// Detects every numeric token in [body] (FR-026/027). Each token carries its
  /// normalized double value, char span, adjacent words, and a heuristic flag
  /// for likely non-transactional numbers (FR-008).
  List<NumericToken> numericTokens(String body, {NumberLocale? localeHint}) {
    if (body.isEmpty) return const [];
    final locale = localeHint ?? defaultLocale ?? NumberLocale.commaThousands;

    final results = <NumericToken>[];
    for (final match in _numberRegex.allMatches(body)) {
      final raw = match.group(0)!;
      final start = match.start;
      final end = match.end;
      final normalized = normalize(raw, localeHint: locale);
      if (normalized == null) continue;
      results.add(NumericToken(
        rawText: raw,
        normalizedValue: normalized,
        startIndex: start,
        endIndex: end,
        beforeWord: _wordBefore(body, start),
        afterWord: _wordAfter(body, end),
        isLikelyNonTransactional: _looksNonTransactional(raw, body, start, end),
      ));
    }

    results.sort((a, b) => a.startIndex.compareTo(b.startIndex));
    return results;
  }

  /// Whitespace-delimited word tokens for counterparty selection (FR-029).
  List<TextToken> textTokens(String body) {
    if (body.isEmpty) return const [];
    return [
      for (final match in _wordRegex.allMatches(body))
        TextToken(
          rawText: match.group(0)!,
          startIndex: match.start,
          endIndex: match.end,
        ),
    ];
  }

  /// Normalizes a raw numeric token to a double, mapping Arabic-Indic digits and
  /// resolving separators. [localeHint] disambiguates '1,500'-style tokens;
  /// defaults to comma-as-thousands when null (FR-028). Returns null if the
  /// token cannot be parsed.
  double? normalize(String rawToken, {NumberLocale? localeHint}) {
    final locale = localeHint ?? defaultLocale ?? NumberLocale.commaThousands;

    var s = rawToken.trim();
    if (s.isEmpty) return null;

    // Map Arabic-Indic digits and separators to Latin equivalents.
    final buf = StringBuffer();
    for (final ch in s.runes) {
      if (_arabicIndicDigits.containsKey(ch)) {
        buf.write(_arabicIndicDigits[ch]);
      } else if (ch == _arabicDecimal) {
        buf.write('.');
      } else if (ch == _arabicThousands) {
        buf.write(',');
      } else {
        buf.writeCharCode(ch);
      }
    }
    var latin = buf.toString();

    final hasComma = latin.contains(',');
    final hasDot = latin.contains('.');

    if (hasComma && hasDot) {
      // The right-most separator is the decimal separator.
      final lastComma = latin.lastIndexOf(',');
      final lastDot = latin.lastIndexOf('.');
      if (lastDot > lastComma) {
        latin = latin.replaceAll(',', ''); // dots are decimal, commas thousands
      } else {
        latin = latin.replaceAll('.', '').replaceAll(',', '.');
      }
    } else if (hasComma) {
      final commaCount = ','.allMatches(latin).length;
      if (commaCount > 1) {
        latin = latin.replaceAll(',', ''); // multiple commas → thousands
      } else {
        // Single comma — ambiguous.
        if (locale == NumberLocale.periodThousands) {
          latin = latin.replaceAll(',', '.');
        } else {
          // comma = thousands iff exactly 3 trailing digits, else decimal.
          final parts = latin.split(',');
          if (parts.length == 2 && parts[1].length == 3) {
            latin = parts[0] + parts[1];
          } else {
            latin = latin.replaceAll(',', '.');
          }
        }
      }
    } else if (hasDot) {
      final dotCount = '.'.allMatches(latin).length;
      if (dotCount > 1) {
        latin = latin.replaceAll('.', ''); // multiple dots → thousands (EU)
      }
      // Single dot → decimal; leave as-is.
    }

    return double.tryParse(latin);
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
      codeUnit == 0x20 || // space
      codeUnit == 0x09 || // tab
      codeUnit == 0x0A || // newline
      codeUnit == 0x0D || // carriage return
      codeUnit == 0xA0; // non-breaking space

  /// Heuristic: OTP codes, reference numbers, and phone numbers look
  /// non-transactional (FR-008). A long pure-digit token with no separators and
  /// no adjacent currency context, or a token adjacent to an OTP/code keyword,
  /// is flagged.
  bool _looksNonTransactional(
    String raw,
    String body,
    int start,
    int end,
  ) {
    final stripped = raw.replaceAll(RegExp(r'[.,\u066B\u066C]'), '');
    if (stripped.length >= 6 &&
        !raw.contains(',') &&
        !raw.contains('.') &&
        !raw.contains('\u066B') &&
        !raw.contains('\u066C') &&
        !_hasCurrencyNearby(body, start, end)) {
      return true;
    }
    final nearby = _nearbyText(body, start, end).toLowerCase();
    const otpKeywords = <String>[
      'otp', 'code', 'verification', 'verify', 'pin', 'password',
      'reference', 'ref', 'confirmation', 'رمز', 'كود', 'تأكيد',
    ];
    for (final kw in otpKeywords) {
      if (nearby.contains(kw)) return true;
    }
    return false;
  }

  String _nearbyText(String body, int start, int end) {
    final from = (start - 20).clamp(0, body.length);
    final to = (end + 20).clamp(0, body.length);
    return body.substring(from, to);
  }

  bool _hasCurrencyNearby(String body, int start, int end) {
    final nearby = _nearbyText(body, start, end).toLowerCase();
    const currencies = <String>[
      'egp', 'le', 'جنية', 'جنيه', 'جم', 'جنيهات', 'pound',
      'رصيد', 'مبلغ', 'بمبلغ', 'خصم', 'balance', 'amount', 'rs', 'inr',
    ];
    return currencies.any(nearby.contains);
  }
}
