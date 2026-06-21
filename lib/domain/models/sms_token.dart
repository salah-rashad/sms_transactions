/// Transient value objects produced by the tokenizer, never persisted.
/// See specs/001-sms-pattern-authoring/data-model.md.
library;

/// A numeric run detected in an SMS body.
///
/// [startIndex]/[endIndex] are character offsets valid for the source [body].
/// [normalizedValue] is the canonical double after separator/digit normalization.
/// [beforeWord]/[afterWord] are the whitespace-delimited words immediately
/// adjacent to the token (may be empty at body boundaries) — used as pattern
/// anchors (FR-031/032).
/// [isLikelyNonTransactional] flags tokens that look like OTPs, reference codes,
/// phone numbers, or dates so the authoring UI can de-emphasize them (FR-008).
class NumericToken {
  final String rawText;
  final double normalizedValue;
  final int startIndex;
  final int endIndex;
  final String beforeWord;
  final String afterWord;
  final bool isLikelyNonTransactional;

  const NumericToken({
    required this.rawText,
    required this.normalizedValue,
    required this.startIndex,
    required this.endIndex,
    required this.beforeWord,
    required this.afterWord,
    required this.isLikelyNonTransactional,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NumericToken &&
          runtimeType == other.runtimeType &&
          rawText == other.rawText &&
          normalizedValue == other.normalizedValue &&
          startIndex == other.startIndex &&
          endIndex == other.endIndex &&
          beforeWord == other.beforeWord &&
          afterWord == other.afterWord &&
          isLikelyNonTransactional == other.isLikelyNonTransactional;

  @override
  int get hashCode => Object.hash(
        rawText,
        normalizedValue,
        startIndex,
        endIndex,
        beforeWord,
        afterWord,
        isLikelyNonTransactional,
      );

  @override
  String toString() =>
      'NumericToken($rawText @[$startIndex,$endIndex)=$normalizedValue '
      'before="$beforeWord" after="$afterWord" nonTxn=$isLikelyNonTransactional)';
}

/// A whitespace-delimited text word in an SMS body (FR-029).
class TextToken {
  final String rawText;
  final int startIndex;
  final int endIndex;

  const TextToken({
    required this.rawText,
    required this.startIndex,
    required this.endIndex,
  });

  static TextToken merge(List<TextToken> tokens) {
    assert(tokens.isNotEmpty);
    final sorted = [...tokens]
      ..sort((a, b) => a.startIndex.compareTo(b.startIndex));
    return TextToken(
      rawText: sorted.map((t) => t.rawText).join(' '),
      startIndex: sorted.first.startIndex,
      endIndex: sorted.last.endIndex,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextToken &&
          runtimeType == other.runtimeType &&
          rawText == other.rawText &&
          startIndex == other.startIndex &&
          endIndex == other.endIndex;

  @override
  int get hashCode => Object.hash(rawText, startIndex, endIndex);

  @override
  String toString() => 'TextToken($rawText @[$startIndex,$endIndex))';
}
