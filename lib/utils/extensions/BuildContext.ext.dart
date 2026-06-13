import 'package:flutter/material.dart';
import 'package:sms_transactions/theme/app_colors.dart';

extension ThemeExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;

  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
