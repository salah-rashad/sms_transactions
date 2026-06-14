import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sms_transactions/core/extensions/build_context.dart';
import 'package:sms_transactions/domain/analytics/monthly_breakdown.dart';
import 'package:sms_transactions/domain/analytics/salary_cycle_breakdown.dart';
import 'package:sms_transactions/domain/models/transaction.dart';
import 'package:sms_transactions/features/transactions/providers/transaction_provider.dart';
import 'package:sms_transactions/features/transactions/widgets/filter_sheet.dart';
import 'package:sms_transactions/features/transactions/widgets/transaction_card.dart';

class TransactionsScreen extends StatefulWidget {
  final DateTime? initialRangeStart;
  final DateTime? initialRangeEnd;
  final String? initialRangeLabel;

  const TransactionsScreen({
    super.key,
    this.initialRangeStart,
    this.initialRangeEnd,
    this.initialRangeLabel,
  });

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  Filter _typeFilter = Filter.all;
  List<DateFilter> _dateFilters = const [];
  Set<AccountSource> _accountFilters = const {};

  @override
  void initState() {
    super.initState();
    if (widget.initialRangeStart != null) {
      _dateFilters = [
        DateFilter(
          label: widget.initialRangeLabel ??
              formatPeriod(
                widget.initialRangeStart!,
                widget.initialRangeEnd,
              ),
          start: widget.initialRangeStart!,
          end: widget.initialRangeEnd,
        ),
      ];
    }
  }

  bool get _hasActiveFilters =>
      _typeFilter != Filter.all ||
      _dateFilters.isNotEmpty ||
      _accountFilters.isNotEmpty;

  void _clearAll() => setState(() {
        _typeFilter = Filter.all;
        _dateFilters = const [];
        _accountFilters = const {};
      });

  Future<void> _openFilterSheet(BuildContext context) async {
    final provider = context.read<TransactionProvider>();

    final cycleFilters = <DateFilter>[];
    for (final range in SalaryCycleBreakdown.cycleRanges(provider.transactions)) {
      cycleFilters.add(DateFilter(
        label: formatPeriod(range.start, range.end),
        start: range.start,
        end: range.end,
      ));
    }

    final monthFilters = <DateFilter>[];
    for (final m in MonthlyBreakdown.activeMonths(provider.transactions)) {
      final date = DateTime(m.year, m.month);
      monthFilters.add(DateFilter(
        label: DateFormat.yMMMM().format(date),
        start: date,
        end: DateTime(m.year, m.month + 1),
      ));
    }

    final accountOptions = <AccountOption>[
      for (final a in provider.accounts)
        if (a.transactionCount > 0)
          (source: a.source, label: a.displayName),
    ];

    if (!context.mounted) return;
    final result = await showModalBottomSheet<FilterSheetResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => FilterSheet(
        typeFilter: _typeFilter,
        dateFilters: _dateFilters,
        cycleFilters: cycleFilters,
        monthFilters: monthFilters,
        accountOptions: accountOptions,
        accountFilters: _accountFilters,
      ),
    );

    if (result != null) {
      setState(() {
        _typeFilter = result.typeFilter;
        _dateFilters = result.dateFilters;
        _accountFilters = result.accountFilters;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: _hasActiveFilters,
              child: const Icon(Icons.filter_list),
            ),
            tooltip: 'Filter',
            onPressed: () => _openFilterSheet(context),
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

          final dateRestricted = _dateFilters.isNotEmpty;
          final filtered = provider.transactions.where((t) {
            if (t.type == TransactionType.balanceCheck) return false;
            if (_typeFilter == Filter.income &&
                t.type != TransactionType.income) {
              return false;
            }
            if (_typeFilter == Filter.expense &&
                t.type != TransactionType.expense) {
              return false;
            }
            if (dateRestricted && !_dateFilters.any((f) => f.matches(t.date))) {
              return false;
            }
            if (_accountFilters.isNotEmpty &&
                !_accountFilters.contains(t.source)) {
              return false;
            }
            return true;
          }).toList();

          return Column(
            children: [
              if (_hasActiveFilters) _buildActiveChips(),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('No matching transactions'))
                    : RefreshIndicator(
                        onRefresh: provider.loadTransactions,
                        child: ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final txn = filtered[index];
                            final prevTxn =
                                index > 0 ? filtered[index - 1] : null;
                            final newMonth = !dateRestricted &&
                                (prevTxn == null ||
                                    !_sameMonth(txn.date, prevTxn.date));
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
                                        color: context
                                            .colorScheme
                                            .primary,
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
                                      color: context
                                            .colorScheme
                                            .onSurfaceVariant,
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

  Widget _buildActiveChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        alignment: WrapAlignment.start,
        runAlignment: WrapAlignment.start,
        children: [
          if (_typeFilter != Filter.all)
            InputChip(
              avatar: Icon(
                _typeFilter == Filter.income
                    ? Icons.arrow_downward
                    : Icons.arrow_upward,
                size: 16,
              ),
              label: Text(
                  _typeFilter == Filter.income ? 'Income' : 'Expense'),
              onDeleted: () => setState(() => _typeFilter = Filter.all),
            ),
          for (final f in _dateFilters)
            InputChip(
              avatar:
                  const Icon(Icons.calendar_today_outlined, size: 14),
              label: Text(f.label),
              onDeleted: () => setState(
                () => _dateFilters =
                    _dateFilters.where((d) => d != f).toList(),
              ),
            ),
          for (final source in _accountFilters)
            InputChip(
              avatar: const Icon(Icons.account_balance_wallet_outlined,
                  size: 14),
              label: Text(_accountLabel(context, source)),
              onDeleted: () => setState(
                () => _accountFilters =
                    _accountFilters.where((s) => s != source).toSet(),
              ),
            ),
          TextButton(
            onPressed: _clearAll,
            child: const Text('Clear all'),
          ),
        ],
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _accountLabel(BuildContext context, AccountSource source) {
    final account =
        context.read<TransactionProvider>().accounts.firstWhere(
              (a) => a.source == source,
              orElse: () => throw StateError('Missing account'),
            );
    return account.displayName;
  }

  bool _sameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    if (target == today) return 'Today';
    if (target == today.subtract(const Duration(days: 1))) return 'Yesterday';

    return '${date.day}/${date.month}/${date.year}';
  }
}
