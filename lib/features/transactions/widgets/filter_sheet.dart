import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sms_transactions/core/extensions/build_context.dart';
import 'package:sms_transactions/domain/models/transaction.dart';
import 'package:sms_transactions/features/transactions/providers/transaction_provider.dart';

typedef AccountOption = ({AccountSource source, String label});

enum Filter { all, income, expense }

class DateFilter {
  final String label;
  final DateTime start;
  final DateTime? end;

  const DateFilter({
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
      other is DateFilter && start == other.start && end == other.end;

  @override
  int get hashCode => Object.hash(start, end);
}

class FilterSheetResult {
  final Filter typeFilter;
  final List<DateFilter> dateFilters;
  final Set<AccountSource> accountFilters;

  const FilterSheetResult(
      this.typeFilter, this.dateFilters, this.accountFilters);
}

String formatPeriod(DateTime start, DateTime? end) {
  final fmt = DateFormat('d MMM yyyy');
  final s = fmt.format(start);
  final e =
      end != null ? fmt.format(end.subtract(const Duration(days: 1))) : 'Present';
  return '$s – $e';
}

class FilterSheet extends StatefulWidget {
  final Filter typeFilter;
  final List<DateFilter> dateFilters;
  final List<DateFilter> cycleFilters;
  final List<DateFilter> monthFilters;
  final List<AccountOption> accountOptions;
  final Set<AccountSource> accountFilters;

  const FilterSheet({
    super.key,
    required this.typeFilter,
    required this.dateFilters,
    required this.cycleFilters,
    required this.monthFilters,
    required this.accountOptions,
    required this.accountFilters,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late Filter _type;
  late List<DateFilter> _dates;
  late Set<AccountSource> _accounts;

  @override
  void initState() {
    super.initState();
    _type = widget.typeFilter;
    _dates = List.of(widget.dateFilters);
    _accounts = Set.of(widget.accountFilters);
  }

  bool _isSelected(DateFilter f) => _dates.any((d) => d == f);

  void _toggle(DateFilter f) {
    setState(() {
      if (_isSelected(f)) {
        _dates = _dates.where((d) => d != f).toList();
      } else {
        _dates = [..._dates, f];
      }
    });
  }

  void _reset() => setState(() {
        _type = Filter.all;
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
      if (_type == Filter.income && t.type != TransactionType.income) continue;
      if (_type == Filter.expense && t.type != TransactionType.expense) {
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
            child: SegmentedButton<Filter>(
              segments: const [
                ButtonSegment(value: Filter.all, label: Text('All')),
                ButtonSegment(
                  value: Filter.income,
                  icon: Icon(Icons.arrow_downward, size: 16),
                  label: Text('Income'),
                ),
                ButtonSegment(
                  value: Filter.expense,
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
                  FilterSheetResult(_type, _dates, Set.of(_accounts)),
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
