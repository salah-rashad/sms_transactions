import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sms_transactions/utils/extensions/BuildContext.ext.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_card.dart';

typedef _AccountOption = ({AccountSource source, String label});

enum _Filter { all, income, expense }

class _DateFilter {
  final String label;
  final DateTime start;
  final DateTime? end; // exclusive upper bound; null = open-ended

  const _DateFilter({
    required this.label,
    required this.start,
    this.end,
  });

  bool matches(DateTime date) {
    if (date.isBefore(start)) return false;
    if (end != null && !date.isBefore(end!)) return false;
    return true;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _DateFilter && start == other.start && end == other.end;

  @override
  int get hashCode => Object.hash(start, end);
}

String _formatPeriod(DateTime start, DateTime? end) {
  final fmt = DateFormat('d MMM yyyy');
  final s = fmt.format(start);
  final e =
      end != null ? fmt.format(end.subtract(const Duration(days: 1))) : 'Present';
  return '$s – $e';
}

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
  _Filter _typeFilter = _Filter.all;
  List<_DateFilter> _dateFilters = const [];
  Set<AccountSource> _accountFilters = const {};

  @override
  void initState() {
    super.initState();
    if (widget.initialRangeStart != null) {
      _dateFilters = [
        _DateFilter(
          label: widget.initialRangeLabel ??
              _formatPeriod(
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
      _typeFilter != _Filter.all ||
      _dateFilters.isNotEmpty ||
      _accountFilters.isNotEmpty;

  void _clearAll() => setState(() {
        _typeFilter = _Filter.all;
        _dateFilters = const [];
        _accountFilters = const {};
      });

  Future<void> _openFilterSheet(BuildContext context) async {
    final provider = context.read<TransactionProvider>();

    final cycleFilters = <_DateFilter>[];
    for (final entry in provider.salaryBasedBreakdown.entries) {
      final v = entry.value;
      cycleFilters.add(_DateFilter(
        label: _formatPeriod(v.cycleStart, v.cycleEnd),
        start: v.cycleStart,
        end: v.cycleEnd,
      ));
    }

    final monthFilters = <_DateFilter>[];
    for (final entry in provider.monthlyBreakdown.entries) {
      final parts = entry.key.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      monthFilters.add(_DateFilter(
        label: DateFormat.yMMMM().format(DateTime(year, month)),
        start: DateTime(year, month),
        end: DateTime(year, month + 1),
      ));
    }

    final accountOptions = <_AccountOption>[
      for (final a in provider.accounts)
        if (a.transactionCount > 0) (source: a.source, label: a.displayName),
    ];

    if (!context.mounted) return;
    final result = await showModalBottomSheet<_FilterSheetResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _FilterSheet(
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
            if (_typeFilter == _Filter.income &&
                t.type != TransactionType.income) {
              return false;
            }
            if (_typeFilter == _Filter.expense &&
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
          if (_typeFilter != _Filter.all)
            InputChip(
              avatar: Icon(
                _typeFilter == _Filter.income
                    ? Icons.arrow_downward
                    : Icons.arrow_upward,
                size: 16,
              ),
              label: Text(
                  _typeFilter == _Filter.income ? 'Income' : 'Expense'),
              onDeleted: () => setState(() => _typeFilter = _Filter.all),
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

class _FilterSheetResult {
  final _Filter typeFilter;
  final List<_DateFilter> dateFilters;
  final Set<AccountSource> accountFilters;
  const _FilterSheetResult(
      this.typeFilter, this.dateFilters, this.accountFilters);
}

class _FilterSheet extends StatefulWidget {
  final _Filter typeFilter;
  final List<_DateFilter> dateFilters;
  final List<_DateFilter> cycleFilters;
  final List<_DateFilter> monthFilters;
  final List<_AccountOption> accountOptions;
  final Set<AccountSource> accountFilters;

  const _FilterSheet({
    required this.typeFilter,
    required this.dateFilters,
    required this.cycleFilters,
    required this.monthFilters,
    required this.accountOptions,
    required this.accountFilters,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late _Filter _type;
  late List<_DateFilter> _dates;
  late Set<AccountSource> _accounts;

  @override
  void initState() {
    super.initState();
    _type = widget.typeFilter;
    _dates = List.of(widget.dateFilters);
    _accounts = Set.of(widget.accountFilters);
  }

  bool _isSelected(_DateFilter f) => _dates.any((d) => d == f);

  void _toggle(_DateFilter f) {
    setState(() {
      if (_isSelected(f)) {
        _dates = _dates.where((d) => d != f).toList();
      } else {
        _dates = [..._dates, f];
      }
    });
  }

  void _reset() => setState(() {
        _type = _Filter.all;
        _dates = const [];
        _accounts = {};
      });

  void _toggleAccount(AccountSource source) {
    setState(() {
      if (_accounts.contains(source)) {
        _accounts.remove(source);
      } else {
        _accounts.add(source);
      }
    });
  }

  int get _resultCount {
    final txns = context.read<TransactionProvider>().transactions;
    final dateRestricted = _dates.isNotEmpty;
    final accountRestricted = _accounts.isNotEmpty;
    var n = 0;
    for (final t in txns) {
      if (t.type == TransactionType.balanceCheck) continue;
      if (_type == _Filter.income && t.type != TransactionType.income) continue;
      if (_type == _Filter.expense && t.type != TransactionType.expense) {
        continue;
      }
      if (dateRestricted && !_dates.any((f) => f.matches(t.date))) continue;
      if (accountRestricted && !_accounts.contains(t.source)) continue;
      n++;
    }
    return n;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            decoration: BoxDecoration(
              color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Filters',
                  style: context.textTheme.titleLarge,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.restart_alt, size: 18),
                  label: const Text('Reset'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Type',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: context.colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
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
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
              showSelectedIcon: false,
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              children: [
                if (widget.accountOptions.isNotEmpty) ...[
                  _sectionHeader(context, 'Accounts'),
                  for (final opt in widget.accountOptions)
                    CheckboxListTile(
                      dense: true,
                      value: _accounts.contains(opt.source),
                      onChanged: (_) => _toggleAccount(opt.source),
                      title: Text(opt.label),
                    ),
                  const Divider(height: 1),
                ],
                if (widget.cycleFilters.isNotEmpty) ...[
                  _sectionHeader(context, 'Salary cycles'),
                  for (final f in widget.cycleFilters)
                    CheckboxListTile(
                      dense: true,
                      value: _isSelected(f),
                      onChanged: (_) => _toggle(f),
                      title: Text(f.label),
                    ),
                  const Divider(height: 1),
                ],
                if (widget.monthFilters.isNotEmpty) ...[
                  _sectionHeader(context, 'Calendar months'),
                  for (final f in widget.monthFilters)
                    CheckboxListTile(
                      dense: true,
                      value: _isSelected(f),
                      onChanged: (_) => _toggle(f),
                      title: Text(f.label),
                    ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(
                  context,
                  _FilterSheetResult(_type, _dates, Set.of(_accounts)),
                ),
                child: Text('Show $_resultCount transactions'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: context.colorScheme.onSurfaceVariant,
          fontSize: 13,
        ),
      ),
    );
  }
}
