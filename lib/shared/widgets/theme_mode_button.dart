import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms_transactions/features/settings/cubit/theme_cubit.dart';

class ThemeModeButton extends StatelessWidget {
  const ThemeModeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return PopupMenuButton<ThemeMode>(
          icon: const Icon(Icons.brightness_6_outlined),
          tooltip: 'Theme',
          onSelected: context.read<ThemeCubit>().setThemeMode,
          itemBuilder: (_) => [
            for (final mode in ThemeMode.values)
              CheckedPopupMenuItem(
                value: mode,
                checked: themeMode == mode,
                child: Text(_label(mode)),
              ),
          ],
        );
      },
    );
  }

  String _label(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }
}
