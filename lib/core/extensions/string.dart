extension StringExtension on String {
  String stripAnsi() {
    final ansiRegex = RegExp(
      [
        '[\\u001B\\u009B][[\\]()#;?]*(?:(?:(?:(?:;[-a-zA-Z\\d\\/#&.:=?%@~_]+)*|[a-zA-Z\\d]+(?:;[-a-zA-Z\\d\\/#&.:=?%@~_]*)*)?\\u0007)',
        '(?:(?:\\d{1,4}(?:;\\d{0,4})*)?[\\dA-PR-TZcf-nq-uy=><~]))',
      ].join('|'),
    );

    return replaceAll(ansiRegex, '');
  }

  String _calcPadding(int width, [String padding = ' ']) {
    final int currentVisibleLength = stripAnsi().length;

    // Calculate the number of characters needed for padding based on visible length.
    final int neededPadding = width - currentVisibleLength;

    if (neededPadding <= 0) {
      return ''; // Already at or past the desired width.
    }

    // Generate the required padding string.
    return padding * neededPadding;
  }

  /// Pads the string to [width] characters on the right, using only the
  /// visible characters to calculate the padding amount.
  String padRightVisible(int width, [String padding = ' ']) {
    final paddingString = _calcPadding(width, padding);

    // Append the padding to the original string (which includes the ANSI codes).
    return this + paddingString;
  }

  String padLeftVisible(int width, [String padding = ' ']) {
    final paddingString = _calcPadding(width, padding);

    // Append the padding to the original string (which includes the ANSI codes).
    return paddingString + this;
  }
}
