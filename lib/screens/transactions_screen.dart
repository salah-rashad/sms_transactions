import 'package:shadcn_flutter/shadcn_flutter.dart';
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
        showToast(
          context: context,
          builder: (context, overlay) {
            return SurfaceCard(
              child: Basic(
                title: const Text('Export failed'),
                subtitle: Text('$e'),
                trailing: OutlineButton(
                  size: ButtonSize.small,
                  onPressed: () => overlay.close(),
                  child: const Text('Dismiss'),
                ),
                trailingAlignment: Alignment.center,
              ),
            );
          },
          location: ToastLocation.bottomCenter,
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Transactions'),
          trailing: [
            Consumer<TransactionProvider>(
              builder: (context, provider, _) {
                final exportable = provider.transactions
                    .where((t) => t.type != TransactionType.balanceCheck)
                    .toList();
                return _exporting
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator())),
                      )
                    : IconButton.ghost(
                        onPressed: exportable.isEmpty ? null : () => _export(exportable),
                        icon: const Icon(Icons.file_download_outlined),
                        density: ButtonDensity.icon,
                      );
              },
            ),
          ],
        ),
        const Divider(),
      ],
      child: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text(provider.error!).muted);
          }

          if (provider.transactions.isEmpty) {
            return Center(child: const Text('No transactions found').muted);
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
                child: Tabs(
                  index: _filter.index,
                  onChanged: (i) => setState(() => _filter = _Filter.values[i]),
                  children: const [
                    TabItem(child: Text('All')),
                    TabItem(child: Text('Income')),
                    TabItem(child: Text('Expense')),
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(child: const Text('No matching transactions').muted)
                    : RefreshTrigger(
                        onRefresh: () async {
                          await provider.loadTransactions();
                        },
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
                                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                    child: Text(
                                      DateFormat.yMMMM().format(txn.date),
                                    ).semiBold.large.primaryForeground,
                                  ),
                                if (newDay)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
                                    child: Text(_formatDateHeader(txn.date)).muted.small,
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
