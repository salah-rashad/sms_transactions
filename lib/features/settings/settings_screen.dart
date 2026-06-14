import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sms_transactions/core/extensions/build_context.dart';
import 'package:sms_transactions/data/services/export_service.dart';
import 'package:sms_transactions/domain/models/transaction.dart';
import 'package:sms_transactions/features/settings/cubit/theme_cubit.dart';
import 'package:sms_transactions/features/transactions/cubit/transaction_cubit.dart';
import 'package:sms_transactions/features/transactions/cubit/transaction_state.dart';

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
      final context = this.context;
      final result = await ExportService.exportTransactions(
        context,
        transactions,
      );
      if (context.mounted) {
        final successSnackBar = SnackBar(
          content: Text("Export Success"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: context.appColors.successContainer,
        );

        final failedSnackBar = SnackBar(
          content: Text("Export Canceled"),
          behavior: SnackBarBehavior.floating,
        );
        switch (result.status) {
          case ShareResultStatus.success:
          case ShareResultStatus.unavailable:
            ScaffoldMessenger.maybeOf(context)?.showSnackBar(successSnackBar);
          case ShareResultStatus.dismissed:
            ScaffoldMessenger.maybeOf(context)?.showSnackBar(failedSnackBar);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Export failed: $e',
              style: TextStyle(color: context.colorScheme.error),
            ),
            backgroundColor: context.colorScheme.errorContainer,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _sectionHeader(context, 'Appearance'),
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    for (final mode in ThemeMode.values)
                      ListTile(
                        leading: Icon(_icon(mode)),
                        title: Text(_label(mode)),
                        trailing: themeMode == mode
                            ? Icon(
                                Icons.check,
                                color: context.colorScheme.primary,
                              )
                            : null,
                        onTap: () =>
                            context.read<ThemeCubit>().setThemeMode(mode),
                      ),
                  ],
                ),
              );
            },
          ),
          _sectionHeader(context, 'Data'),
          BlocBuilder<TransactionCubit, TransactionState>(
            builder: (context, state) {
              final exportable = state.transactions
                  .where((t) => t.type != TransactionType.balanceCheck)
                  .toList();
              final hasData = exportable.isNotEmpty;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                child: ListTile(
                  leading: const Icon(Icons.file_download_outlined),
                  title: const Text('Export to Excel'),
                  subtitle: Text(
                    hasData
                        ? '${exportable.length} transactions'
                        : 'No transactions to export',
                  ),
                  trailing: _exporting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          Icons.chevron_right,
                          color: scheme.onSurfaceVariant,
                        ),
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
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
