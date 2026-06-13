import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/theme_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/export_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _exporting = false;

  Future<void> _export(List<Transaction> transactions) async {
    if (_exporting || transactions.isEmpty) return;
    setState(() => _exporting = true);
    try {
      await ExportService.exportTransactions(transactions);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _sectionHeader(context, 'Appearance'),
          Consumer<ThemeProvider>(
            builder: (context, provider, _) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    for (final mode in ThemeMode.values)
                      ListTile(
                        leading: Icon(_icon(mode)),
                        title: Text(_label(mode)),
                        trailing: provider.themeMode == mode
                            ? Icon(Icons.check,
                                color: Theme.of(context).colorScheme.primary)
                            : null,
                        onTap: () => provider.setThemeMode(mode),
                      ),
                  ],
                ),
              );
            },
          ),
          _sectionHeader(context, 'Data'),
          Consumer<TransactionProvider>(
            builder: (context, provider, _) {
              final exportable = provider.transactions
                  .where((t) => t.type != TransactionType.balanceCheck)
                  .toList();
              final hasData = exportable.isNotEmpty;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                child: ListTile(
                  leading: const Icon(Icons.file_download_outlined),
                  title: const Text('Export to Excel'),
                  subtitle: Text(hasData
                      ? '${exportable.length} transactions'
                      : 'No transactions to export'),
                  trailing: _exporting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
                  enabled: hasData && !_exporting,
                  onTap: () => _export(exportable),
                ),
              );
            },
         ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 16, 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
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

  IconData _icon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return Icons.brightness_auto_outlined;
      case ThemeMode.light:
        return Icons.light_mode_outlined;
      case ThemeMode.dark:
        return Icons.dark_mode_outlined;
    }
  }
}
