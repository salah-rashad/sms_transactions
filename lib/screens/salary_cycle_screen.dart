import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_card.dart';

enum _Filter { all, income, expense }

class SalaryCycleScreen extends StatefulWidget {
  final DateTime cycleStart;
  final DateTime? cycleEnd;
  final String? title;

  const SalaryCycleScreen({
    super.key,
    required this.cycleStart,
    this.cycleEnd,
    this.title,
  });

  @override
  State<SalaryCycleScreen> createState() => _SalaryCycleScreenState();
}

class _SalaryCycleScreenState extends State<SalaryCycleScreen> {
  _Filter _filter = _Filter.all;

  String get _periodLabel {
    final fmt = DateFormat('d MMM yyyy');
    final start = fmt.format(widget.cycleStart);
    final end = widget.cycleEnd != null
        ? fmt.format(widget.cycleEnd!.subtract(const Duration(days: 1)))
        : 'Present';
    return '$start – $end';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? _periodLabel)),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          final inCycle = provider.transactions.where((t) {
            if (t.type == TransactionType.balanceCheck) return false;
            if (t.date.isBefore(widget.cycleStart)) return false;
            if (widget.cycleEnd != null && !t.date.isBefore(widget.cycleEnd!)) {
              return false;
            }
            return true;
          }).toList();

          final filtered = inCycle.where((t) {
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
                    ? const Center(
                        child: Text('No transactions in this period'),
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final txn = filtered[index];
                          final prevTxn = index > 0
                              ? filtered[index - 1]
                              : null;
                          final newDay =
                              prevTxn == null ||
                              !_sameDay(txn.date, prevTxn.date);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (newDay)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    10,
                                    16,
                                    2,
                                  ),
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
            ],
          );
        },
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    if (target == today) return 'Today';
    if (target == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return DateFormat('EEE, d MMM yyyy').format(date);
  }
}
