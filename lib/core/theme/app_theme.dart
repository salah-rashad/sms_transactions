import 'package:flutter/material.dart';
import 'package:sms_transactions/core/theme/app_colors.dart';

class AppTheme {
  AppTheme._();

  static const _seed = Color(0xFF3F51B5);

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      extensions: [brightness == Brightness.light ? AppColors.light : AppColors.dark],
    );
  }
}
