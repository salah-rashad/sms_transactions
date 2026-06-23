import 'package:flutter/foundation.dart';

import '../extensions/string.dart';

enum Logger {
  black(30),
  red(31),
  green(32),
  yellow(33),
  blue(34),
  magenta(35),
  cyan(36),
  white(37),
  gray(90);

  final int code;

  const Logger(this.code);

  String _(String input) => '\x1B[${code}m$input\x1B[0m';

  void call(dynamic text, {String? name, String? emoji}) {
    _log(name ?? runtimeType.toString(), _(text), emoji);
  }

  static void data(String key, dynamic value, {String? emoji}) {
    _log(cyan._(key), yellow._(value), emoji);
  }

  static void error(
    String key,
    dynamic error, [
    StackTrace? stackTrace,
    String? emoji,
  ]) {
    _log(red._(key), red._('\n    $error'), emoji);

    if (stackTrace != null) {
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  static void _log(String key, String value, String? emoji) {
    emoji ??= ' ';

    if (emoji.trim().isNotEmpty) {
      emoji = ' $emoji';
    }

    emoji = ' ${emoji.padRight(4)}';

    key = '$emoji[$key]:'.padRightVisible(22);
    final message = "$key $value";
    if (kDebugMode) {
      print(message);
    }
  }
}
