import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'currency_text.dart';

class SalarySummaryTile extends StatelessWidget {
  final double salary;
  final double otherIncome;
  final double expense;
  final double savings;
  final double remaining;
  final DateTime cycleStart;
  final DateTime? cycleEnd;
  final VoidCallback? onTap;

  const SalarySummaryTile({
    super.key,
    required this.salary,
    required this.otherIncome,
    required this.expense,
    required this.savings,
    required this.remaining,
    required this.cycleStart,
    this.cycleEnd,
    this.onTap,
  });

  String get _periodLabel {
    final fmt = DateFormat('d MMM yyyy');
    final start = fmt.format(cycleStart);
    final end = cycleEnd != null
        ? fmt.format(cycleEnd!.subtract(const Duration(days: 1)))
        : 'Present';
    return '$start – $end';
  }

  @override
  Widget build(BuildContext context) {
    final spentPercent = salary > 0 ? (expense / salary).clamp(0.0, 1.0) : 0.0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat.yMMMM().format(cycleStart),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _periodLabel,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onTap != null)
                    Icon(Icons.chevron_right, color: Colors.grey[400]),
                ],
              ),
              const Divider(),
              CurrencyText(
                amount: salary,
                color: Colors.indigo,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                prefix: 'Salary: ',
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: spentPercent,
                        backgroundColor: Colors.green.withValues(alpha: 0.15),
                        color: spentPercent > 0.9
                            ? Colors.red
                            : spentPercent > 0.7
                                ? Colors.orange
                                : Colors.green,
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(spentPercent * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: spentPercent > 0.9
                          ? Colors.red
                          : spentPercent > 0.7
                              ? Colors.orange
                              : Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildColumn('Expense', expense, Colors.red),
                  if (savings > 0) _buildColumn('Savings', savings, Colors.teal),
                  _buildColumn('Left', remaining,
                      remaining >= 0 ? Colors.green : Colors.red),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColumn(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 4),
        CurrencyText(
          amount: value,
          color: color,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          includeCurrency: false,
        ),
      ],
    );
  }
}
