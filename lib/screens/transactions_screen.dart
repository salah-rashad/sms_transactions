import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../services/export_service.dart';
import '../widgets/transaction_card.dart';

enum _Filter { all, income, expense }

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  _Filter _filter = _Filter.all;
  bool _exporting = false;

  Future<void> _export(List<Transaction> transactions) async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      await ExportService.exportTransactions(transactions);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          Consumer<TransactionProvider>(
            builder: (context, provider, _) {
              final exportable = provider.transactions
                  .where((t) => t.type != TransactionType.balanceCheck)
                  .toList();
              return _exporting
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                    )
                  : IconButton(
                      icon: const Icon(Icons.file_download_outlined),
                      tooltip: 'Export to Excel',
                      onPressed: exportable.isEmpty ? null : () => _export(exportable),
                    );
            },
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          if (provider.transactions.isEmpty) {
            return const Center(child: Text('No transactions found'));
          }

          final filtered = provider.transactions.where((t) {
            if (t.type == TransactionType.balanceCheck) return false;
            switch (_filter) {
              case _Filter.all:
                return true;
              case _Filter.income:
                return t.type == TransactionType.income;
              case _Filter.expense:
                return t.type == TransactionType.expense;
            }
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                child: SegmentedButton<_Filter>(
                  segments: const [
                    ButtonSegment(value: _Filter.all, label: Text('All')),
                    ButtonSegment(
                      value: _Filter.income,
                      icon: Icon(Icons.arrow_downward, size: 16),
                      label: Text('Income'),
                    ),
                    ButtonSegment(
                      value: _Filter.expense,
                      icon: Icon(Icons.arrow_upward, size: 16),
                      label: Text('Expense'),
                    ),
                  ],
                  selected: {_filter},
                  onSelectionChanged: (v) => setState(() => _filter = v.first),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('No matching transactions'))
                    : RefreshIndicator(
                        onRefresh: provider.loadTransactions,
                        child: ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final txn = filtered[index];
                            final prevTxn = index > 0 ? filtered[index - 1] : null;
                            final newMonth = prevTxn == null ||
                                !_sameMonth(txn.date, prevTxn.date);
                            final newDay = prevTxn == null ||
                                !_sameDay(txn.date, prevTxn.date);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (newMonth)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 16, 16, 0),
                                    child: Text(
                                      DateFormat.yMMMM().format(txn.date),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                if (newDay)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 10, 16, 2),
                                    child: Text(
                                      _formatDateHeader(txn.date),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                TransactionCard(
                                  transaction: txn,
                                  onToggleSalary: () =>
                                      provider.toggleSalaryMark(txn.id),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _sameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    if (target == today) return 'Today';
    if (target == today.subtract(const Duration(days: 1))) return 'Yesterday';

    return '${date.day}/${date.month}/${date.year}';
  }
}
