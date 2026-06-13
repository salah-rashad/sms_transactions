import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ThemeModeButton extends StatelessWidget {
  const ThemeModeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, provider, _) {
        return PopupMenuButton<ThemeMode>(
          icon: const Icon(Icons.brightness_6_outlined),
          tooltip: 'Theme',
          onSelected: provider.setThemeMode,
          itemBuilder: (_) => [
            for (final mode in ThemeMode.values)
              CheckedPopupMenuItem(
                value: mode,
                checked: provider.themeMode == mode,
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
